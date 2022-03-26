import Foundation

/**
 Delegate that injects headers on the outgoing request.

 Example usage
 ```
 let accessToken = "deadbeef"
 let delegate = HeaderInjectionDelegate(headers: ["Authentication": "Bearer \(accessToken)"])
 APIClient(delegate: delegate)
 ```
 */
public struct HeaderInjectionDelegate: APIClientDelegate
{
    /**
     Initialize with the headers to be injected in every request.
     If there is a header with the same key it will be overwritten.

     - Parameter headers: Headers to be injected in every request.
     */
    public init(headers: [String: String?]) {
        self.headers = headers
    }

    // MARK: - APIClientDelegate

    /// Headers injected to every request.
    public let headers: [String: String?]

    /// Called before the request is executed.
    public func willExecute(request: inout URLRequest) {
        for header in headers {
            request.setValue(header.1, forHTTPHeaderField: header.0)
        }
    }
}
