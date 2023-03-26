import Foundation

/**
 Errors thrown by the APIClient.
 */
public enum APIClientError: Error
{
    /// NSError in the URLError domain. This is thrown by Apple’s networking code.
    case domainError(URL: URLError)

    /// Decoding error.
    case JSONDecodingFailure(PrettyDecodingError)

    /// Response is unexpectedly empty.
    case invalidResponseEmpty

    /// Response doesn’t use the HTTP protocol.
    case invalidResponseNotHTTP

    /// Error that doesn’t require specific handling
    case other(Error)

    /// SSL error. e.g. couldn’t communicate safely because a proxy intercepted the request.
    case SSLError

    /// Custom API error status code.
    case statusErrorAPI(Int)

    /// HTTP error status code.
    case statusErrorHTTP(Int)

    /// True if the HTTP error status code is
    /// [401 Unauthorized](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401).
    public var isAuthorizationError: Bool {
        isStatus(code: 401)
    }

    /// True if the HTTP error status code is
    /// [404 Not Found](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404).
    public var isNotFoundError: Bool {
        isStatus(code: 404)
    }

    /**
     Initialize with the given error.

     - Parameter error: Error to be translated into a APIClientError.
     */
    init(_ error: Error) {
        if let apiError = error as? APIClientError {
            self = apiError
            return
        }
        if (error as NSError).isSSLError {
            self = .SSLError
            return
        }
        self = .other(error)
    }

    /**
     True if the error is statusErrorAPI or statusErrorHTTP with a status matching the `code`
     parameter.

     - Parameter code: Status code to check against.
     */
    private func isStatus(code: Int) -> Bool {
        switch self {
        case .statusErrorAPI(let status): return status == code
        case .statusErrorHTTP(let status): return status == code
        default: return false
        }
    }
}

extension NSError {

    /// True if this NSError is in the URLError domain and its code indicates a SSL error.
    var isSSLError: Bool {
        domain == NSURLErrorDomain && code == -1_200
    }
}
