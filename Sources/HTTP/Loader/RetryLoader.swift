import Foundation

public actor RetryLoader: HTTPLoader {
    
    public init() { }
    
    public func load(request: HTTPRequest, token: HTTPRequestToken) async -> HTTPResult {
        return await withNextLoader(for: request) { next in
            
            var strategy: any HTTPRetryStrategy = request[option: \.retryStrategy] ?? NoRetry()
            
            var latestResult: HTTPResult?
            var attemptCount = 0
            
            while true {
                if token.isCancelled {
                    break
                }
                
                let attemptResult = await next.load(request: request, token: token)
                latestResult = attemptResult
                
                if attemptResult.failure?.code == .cancelled {
                    break
                } else if let delay = strategy.nextDelay(after: attemptResult) {
                    attemptCount += 1
                    // this will loop around and attempt the request again
                    // as long as the request hasn't been cancelled
                    if delay > 0 {
                        do {
                            try await Task.sleep(for: Duration(delay))
                        } catch {
                            let error = HTTPError(code: .internal,
                                                  request: request,
                                                  response: attemptResult.response,
                                                  message: "Async task was cancelled",
                                                  underlyingError: error)
                            latestResult = .failure(error)
                            break
                        }
                    }
                } else {
                    // no retry delay;
                    break
                }
            }
            
            var result = latestResult ?? .failure(HTTPError(code: .internal, request: request))
            result = result.modifyResponse {
                $0[header: .xRetryCount] = "\(attemptCount)"
            }
            return result
        }
    }
    
}

extension HTTPHeader {
    
    public static let xRetryCount = HTTPHeader(rawValue: "X-HTTP-Retry-Count")
    
}

private struct NoRetry: HTTPRetryStrategy {
    mutating func nextDelay(after result: HTTPResult) -> TimeInterval? { return nil }
}
