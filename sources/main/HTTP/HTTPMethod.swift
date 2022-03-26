import Foundation

/// HTTP methods defined in [RFC7231 4.3 Method Definitions](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3).
public enum HTTPMethod: String
{
    case get = "GET"
    case post = "POST"

    public var stringValue: String { rawValue }
}
