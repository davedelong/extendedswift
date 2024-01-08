import Foundation

public actor DeduplicatingLoader: HTTPLoader {
    
    private typealias DeduplicationHandler = (HTTPResult) -> Void
    
    private struct DeduplicationList {
        let originalRequestID: UUID
        var dedupedTasks = Pairs<UUID, DeduplicationHandler>()
    }
    
    private var ongoingRequests = [String: DeduplicationList]()
    
    public init() { }
    
    public func load(request: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult {
        guard let dedupeIdentifier = request[option: \.deduplicationIdentifier] else {
            // no deduplicationIdentifier; task will not be deduped
            return await withNextLoader(for: request) { next in
                return await next.load(request: request, token: token)
            }
        }
        
        if let existing = ongoingRequests[dedupeIdentifier] {
            let result = await result(of: dedupeIdentifier, token: token)
            let withHeader = result.modifyResponse { response in
                response[header: .xOriginalRequestID] = existing.originalRequestID.uuidString
            }
            return withHeader.apply(request: request)
        } else {
            ongoingRequests[dedupeIdentifier] = DeduplicationList(originalRequestID: request.id)
            let result = await withNextLoader(for: request) { next in
                return await next.load(request: request, token: token)
            }
            let list = ongoingRequests.removeValue(forKey: dedupeIdentifier)
            for (_, handler) in (list?.dedupedTasks ?? []) {
                handler(result)
            }
            
            return result
        }
        
    }
    
    private func result(of identifier: String, token: HTTPRequestToken) async -> HTTPResult {
        return await withUnsafeContinuation { continuation in
            let id = UUID()
            let handler: DeduplicationHandler = { continuation.resume(returning: $0) }
            
            #warning("TODO: continuing if it's cancelled?")
            token.addCancellationHandler {
                self.ongoingRequests[identifier]?.dedupedTasks.setValue(nil, for: id)
            }
            
            self.ongoingRequests[identifier]?.dedupedTasks.setValue(handler, for: id)
        }
    }
    
}

extension HTTPHeader {
    
    public static let xOriginalRequestID = HTTPHeader(rawValue: "X-HTTP-Original-Request-ID")
    
}
