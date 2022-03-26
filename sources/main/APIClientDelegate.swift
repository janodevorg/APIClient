import Foundation

/**
 Methods that an APIClient instance calls on its delegate along the lifecycle of a request.
 */
public protocol APIClientDelegate {

    /// Called before executing a request.
    /// - Parameter request: Request that will be executed.
    func willExecute(request: inout URLRequest)
}
