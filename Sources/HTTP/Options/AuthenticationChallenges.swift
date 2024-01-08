import Foundation

public struct HTTPAuthenticationChallengeResponse {
    public static let cancelRequest = HTTPAuthenticationChallengeResponse(disposition: .cancelAuthenticationChallenge, credential: nil)
    
    public static let performDefaultAction = HTTPAuthenticationChallengeResponse(disposition: .performDefaultHandling, credential: nil)
    
    public static let rejectProtectionSpace = HTTPAuthenticationChallengeResponse(disposition: .rejectProtectionSpace, credential: nil)
    
    public static func useCredential(_ credential: URLCredential) -> HTTPAuthenticationChallengeResponse {
        return HTTPAuthenticationChallengeResponse(disposition: .useCredential, credential: credential)
    }
    
    internal let disposition: URLSession.AuthChallengeDisposition
    internal let credential: URLCredential?
}

public protocol HTTPAuthenticationChallengeHandler {
    func evaluate(_ challenge: URLAuthenticationChallenge, for request: HTTPRequest) async -> HTTPAuthenticationChallengeResponse
}

extension HTTPOptions {
    
    public var authenticationChallengeHandler: (any HTTPAuthenticationChallengeHandler)? {
        get { self[HTTPAuthenticationChallengeOption.self] }
        set { self[HTTPAuthenticationChallengeOption.self] = newValue }
    }
    
}

private enum HTTPAuthenticationChallengeOption: HTTPOption {
    static let defaultValue: (any HTTPAuthenticationChallengeHandler)? = nil
}
