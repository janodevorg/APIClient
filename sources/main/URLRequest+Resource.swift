import Foundation

public extension URLRequest
{
    init<T>(resource: Resource<T>, baseURL: URL) throws
    {
        let url = baseURL.appendingPathComponent(resource.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = resource.queryItems
        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        self.init(url: url)

        httpMethod = resource.method.stringValue
        allHTTPHeaderFields = resource.additionalHeaders
    }
}
