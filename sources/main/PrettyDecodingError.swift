import Foundation
import os

/**
 Slightly more readable DecodingError.

 The description will look like this:
 ```
 [networking] PrettyDecodingErrorTests.te…: 17 · Error decoding. Details follow...
 Decodable type: Beer
 Error: keyNotFound(CodingKeys(stringValue: "name", intValue: nil),
        Swift.DecodingError.Context(codingPath: [],
        debugDescription: "No value associated with key CodingKeys(stringValue: \"name\", intValue: nil) (\"name\").", underlyingError: nil))
 JSON contents:
 {
     ...JSON document
 }
 ```
 */
public struct PrettyDecodingError: Error, CustomStringConvertible
{
    private let error: DecodingError
    private let offendingJSON: Data?
    private let intendedType: Decodable.Type
    private let log = Logger(subsystem: "dev.jano", category: "api")

    init(_ error: DecodingError, offendingJSON: Data?, intendedType: Decodable.Type) {
        self.error = error
        self.offendingJSON = offendingJSON
        self.intendedType = intendedType
    }

    public var description: String
    {
        let errorMessage = "\(error)"
            .components(separatedBy: "Swift.DecodingError.Context")
            .joined(separator: "\n       Swift.DecodingError.Context")
            .components(separatedBy: ", debugDescription:")
            .joined(separator: ",\n       debugDescription:")

        var desc = """
            Error decoding. Details follow...
            Decodable type: \(intendedType)
            Error: \(errorMessage)
            """

        if let prettyJSON = offendingJSON?.toJSONString() {
            desc += "\nJSON: \n\(prettyJSON)"

            if let fileURL = save(filename: "failedDecoding.json", string: prettyJSON) {
                desc += "\nFile saved to: \(fileURL)"
            }
        }

        return desc
    }

    /// Saves a string to a temporary directory.
    /// The filename will be `<timestamp>-<filenameprefix>`.
    private func save(filename: String, string: String) -> URL?
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = formatter.string(from: Date())

        let filename = "DecodeFailed-\(timestamp).json"
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try string.write(to: temp, atomically: true, encoding: .utf8)
            return temp
        } catch {
            log.error("Error writing \(filename): \(String(describing: error))")
            return nil
        }
    }
}

private extension Data
{
    /**
     Serialize this byte buffer to a JSON object.
     Returns nil on serialization errors.
     - Returns: A JSON object or nil.
     */
    func toJSON() -> Any? {
        try? JSONSerialization.jsonObject(with: self, options: [])
    }

    /**
     Serialize this byte buffer to a JSON string.
     Returns nil on serialization errors.
     - Returns: A JSON object as a string or nil.
     */
    func toJSONString() -> String? {
        guard
            let jsonObject = toJSON(),
            JSONSerialization.isValidJSONObject(jsonObject),
            let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.sortedKeys, .prettyPrinted])
        else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}

