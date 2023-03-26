import Foundation
import os
import Report

/**
 API client for HTTP Requests.
 */
open class APIClient
{
    private let log = Logger(subsystem: "dev.jano", category: "network")
    private let baseURL: URL
    public var delegate: APIClientDelegate?

    /// If true, any JSON causing a decoding error is saved to the temp directory.
    public var isStoringDecodingErrors = false

    /// MARK: - Creating a client object

    /**
     Creates an API client with the given base URL and delegate.

     - Parameters:
       - baseURL: Used when building URLRequests from a Resource.
       - delegate: A delegate that receives callbacks during the execution of a request.
     */
    public init(baseURL: URL, delegate: APIClientDelegate? = nil) {
        self.baseURL = baseURL
        self.delegate = delegate
    }

    /// MARK: - Sending a URL request

    /**
     Execute the given URL request.

     Calls ``APIClientDelegate``.``APIClientDelegate/willExecute(request:)`` before executing the request.

     - Parameter request: A URL request object that provides request-specific information such as
                          the URL, cache policy, request type, and body data or body stream.

     - Returns: An asynchronously-delivered tuple that contains the URL contents as a Data
                instance, and a URLResponse.

     - Throws: APIClientError
     */
    public func request(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
    {
        var newRequest = request
        delegate?.willExecute(request: &newRequest)

        do {
            let (data, response) = try await URLSession.shared.data(for: newRequest, delegate: nil)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponseNotHTTP
            }
            log.trace("\(Report(request: newRequest, response: httpResponse, data: data))")
            return (data, httpResponse)
        } catch {
            throw APIClientError(error)
        }
    }


    /**
     Execute the given URL request.
     - Parameter resource: A resource representing a URL request.
     - Returns: The type decoded by the ``Resource/decode`` closure.
     */
    public func request<T>(_ resource: Resource<T>) async throws -> T {
        let urlrequest = try URLRequest(resource: resource, baseURL: baseURL)
        let (data, response) = try await request(urlrequest)
        return try resource.decode(data, response)
    }

    /// MARK: - Decoding from JSON

    /**
     Parse the given response.

     Note that this method will throw if the HTTP status code of the response is an error. If your
     API returns a JSON document as an error message you’ll have to override this method to ignore
     the error.

     - Parameters:
     - data: A byte buffer containing the response to a URL request.
     - response: Metadata associated with the response to an HTTP URL request.
     - Returns: The decoded object.
     - Throws: APIClientError.invalidResponseEmpty if the response is empty.
     - Throws: APIClientError.statusErrorHTTP if the response represents an error.
     */
    public func decode<T: Decodable>(data: Data?, response: HTTPURLResponse) throws -> T
    {
        guard let data = data else {
            throw APIClientError.invalidResponseEmpty
        }
        guard HTTPStatus(code: response.statusCode)?.isError == false else {
            throw APIClientError.statusErrorHTTP(response.statusCode)
        }
        return try decode(jsonData: data)
    }

    /**
     Parse a byte buffer as the given Decodable.

     - Parameter data: A byte buffer containing a JSON document as a String.
     - Returns: The Decodable decoded from the parameter JSON data.
     - Throws: APIClientError.JSONDecodingFailure on decoding failure.
     - Throws: APIClientError.other for any other error.
    */
    public func decode<T: Decodable>(jsonData: Data) throws -> T
    {
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch {
            guard let decodingError = error as? DecodingError else {
                throw APIClientError.other(error)
            }
            if isStoringDecodingErrors {
                storeInTempFolder(data: jsonData)
            }
            let prettyDecodingError = PrettyDecodingError(decodingError, offendingJSON: jsonData, intendedType: T.self)
            throw APIClientError.JSONDecodingFailure(prettyDecodingError)
        }
    }

    private func storeInTempFolder(data: Data) {
        if let url = TempFile(data: data).save() {
            log.debug("Saved decoding failure to \(url.description)")
        } else {
            log.error("Failed to store decoding error.")
        }
    }
}

/// A file to be stored in the temp folder.
struct TempFile
{
    private let data: Data
    private let formatter: DateFormatter
    private let log = Logger(subsystem: "dev.jano", category: "file")

    private var timestamp: String {
        formatter.string(from: Date())
    }

    /// Initialize a temp file with data.
    /// - Parameter data: Data to be stored in the file.
    init(data: Data) {
        self.data = data
        self.formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
    }

    /// Saves the file as `DecodingFailure-yyyyMMdd_HHmmss.json` in the temporal folder.
    /// - Returns: URL of the file stored.
    func save() -> URL? {
        save(filename: "DecodingFailure-\(timestamp).json")
    }

    // MARK: - Private

    private func save(filename: String) -> URL? {
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: temp, options: .atomic)
            return temp
        } catch {
            log.error("Error writing \(filename): \(String(describing: error))")
            return nil
        }
    }
}
