/// Result of the attempt to understand and satisfy an HTTP request.
public enum HTTPStatus
{
    case clientError_4xx(Int)
    case informational_1xx(Int)
    case redirection_3xx(Int)
    case serverError_5xx(Int)
    case successful_2xx(Int)


    /// Initializer.
    /// - Parameter code: HTTP status code.
    public init?(code: Int) {
        guard 100 ..< 600 ~= code else { return nil }
        switch code {
        case 100..<200: self = .informational_1xx(code)
        case 200..<300: self = .successful_2xx(code)
        case 300..<400: self = .redirection_3xx(code)
        case 400..<500: self = .clientError_4xx(code)
        case 500..<600: self = .serverError_5xx(code)
        default: return nil
        }
    }

    /// HTTP status code.
    public var code: Int {
        switch self {
        case .informational_1xx(let code): return code
        case .successful_2xx(let code): return code
        case .redirection_3xx(let code): return code
        case .clientError_4xx(let code): return code
        case .serverError_5xx(let code): return code
        }
    }

    /// True if the status code represents a client or server error.
    public var isError: Bool {
        switch self {
        case .clientError_4xx: return true
        case .serverError_5xx: return true
        default: return false
        }
    }

    /// True if it doesn’t represent an error.
    public var isSuccess: Bool {
        !isError
    }

    /// Returns true when the status code is cacheable by default according to [RFC 7231 6.1](https://tools.ietf.org/html/rfc7231#section-6.1).
    public var isDefaultCacheable: Bool {
        [200, 203, 204, 206, 300, 301, 404, 405, 410, 414, 501].contains(code)
    }
}
