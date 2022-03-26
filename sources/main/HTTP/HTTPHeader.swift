import Foundation

/**
 Frequently used HTTP headers.

 See also: <doc:What-is-a-header>.
*/
public enum HTTPHeader: String
{
    /// Accept: application/json
    case acceptJSON

    /// Content-Type: application/x-www-form-urlencoded
    case contentTypeForm

    /// Content-Type: application/json
    case contentTypeJSON

    public var value: [String: String] {
        switch self {
        case .acceptJSON: return ["Accept": "application/json"]
        case .contentTypeForm: return ["Content-Type": "application/x-www-form-urlencoded"]
        case .contentTypeJSON: return ["Content-Type": "application/json"]
        }
    }
}
