import Foundation

extension HTTPError {
    
    init(error: Error, request: HTTPRequest, response: HTTPResponse? = nil, message: String? = nil) {
        self.init(code: HTTPError.Code(error: error),
                  request: request,
                  response: response,
                  message: message,
                  underlyingError: error)
    }
    
}

extension HTTPError.Code {
    
    init(error: Error) {
        if let url = error as? URLError {
            self = urlErrorCodes[url.code] ?? .unknown
        } else if error is EncodingError {
            self = .invalidRequest
        } else if error is DecodingError {
            self = .cannotDecodeResponse
        } else {
            self = .unknown
        }
    }
    
}

private let urlErrorCodes: [URLError.Code: HTTPError.Code] = [
    .cancelled: .cancelled,
    .userCancelledAuthentication: .cancelled,

    .badURL: .invalidRequest,
    .requestBodyStreamExhausted: .invalidRequest,
    .unsupportedURL: .invalidRequest,

    .cannotFindHost: .cannotConnect,
    .cannotConnectToHost: .cannotConnect,
    .networkConnectionLost: .cannotConnect,
    .dnsLookupFailed: .cannotConnect,
    .httpTooManyRedirects: .cannotConnect,
    .notConnectedToInternet: .cannotConnect,
    .redirectToNonExistentLocation: .cannotConnect,
    .cannotLoadFromNetwork: .cannotConnect,
    .internationalRoamingOff: .cannotConnect,
    .callIsActive: .cannotConnect,
    .dataNotAllowed: .cannotConnect,

    .secureConnectionFailed: .insecureConnection,
    .appTransportSecurityRequiresSecureConnection: .insecureConnection,
    .serverCertificateHasBadDate: .insecureConnection,
    .serverCertificateUntrusted: .insecureConnection,
    .serverCertificateHasUnknownRoot: .insecureConnection,
    .serverCertificateNotYetValid: .insecureConnection,
    .clientCertificateRejected: .insecureConnection,
    .clientCertificateRequired: .insecureConnection,

    .userAuthenticationRequired: .cannotAuthenticate,

    .timedOut: .timedOut,

    .badServerResponse: .invalidResponse,
    .cannotParseResponse: .invalidResponse,
    .zeroByteResource: .invalidResponse,
    .resourceUnavailable: .invalidResponse,
    .dataLengthExceedsMaximum: .invalidResponse,

    .cannotDecodeRawData: .cannotDecodeResponse,
    .cannotDecodeContentData: .cannotDecodeResponse,
    .downloadDecodingFailedMidStream: .cannotDecodeResponse,
    .downloadDecodingFailedToComplete: .cannotDecodeResponse,
]
