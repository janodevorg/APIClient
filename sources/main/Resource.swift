import Foundation

/**
 A value that represents a URL loading request.
 The resource returned will be decoded to a generic type `T`.

 Expressing a request as a struct let us serialize and store requests, and build requests in a
 simplified way thanks to default values
 */
public struct Resource<T>
{
    /// MARK: - Instance Properties

    /// A dictionary containing HTTP headers to include in the request.
    public var additionalHeaders: [String: String]

    /// The HTTP request method.
    public var method: HTTPMethod

    /// The path component of the URL.
    public var path: String

    /// An array of query items for the URL.
    public var queryItems: [URLQueryItem]

    /// Closure capable of building a type T from a response.
    public var decode: (Data?, HTTPURLResponse) throws -> T

    /// MARK: - Initializer

    /**
     Initialize a resource with the given parameters.

     - Parameters:
       - additionalHeaders: A dictionary containing HTTP headers to include in the request.
                            Defaults to empty.
       - method: The HTTP request method. Defaults to ``HTTPMethod/get``.
       - path: The path component of the URL. Defaults to empty string.
       - queryItems: An array of query items for the URL. Defaults to empty.
       - decode: Closure capable of building a type T from a response.
     */
    public init(additionalHeaders: [String: String] = [:],
                method: HTTPMethod = .get,
                path: String = "",
                queryItems: [String: String] = [:],
                decode: @escaping (Data?, HTTPURLResponse) throws -> T)
    {
        self.additionalHeaders = additionalHeaders
        self.method = method
        self.path = path
        self.queryItems = queryItems.map { URLQueryItem(name: $0, value: $1) }
        self.decode = decode
    }
}
