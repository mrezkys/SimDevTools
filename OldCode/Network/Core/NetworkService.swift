//
//  NetworkService.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

class NetworkService: NetworkServiceProtocol {
    private let logger: NetworkLoggerProtocol

    required init(logger: NetworkLoggerProtocol = NetworkLogger.shared) {
        self.logger = logger
    }

    func fetchData(
        from urlString: String,
        method: NetworkRequestType,
        headers: [String: String]?,
        requestBody: Encodable?,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if let body = requestBody {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(NetworkError.decodingError(error, "Encoding request body")))
                return
            }
        }

        logger.log(request: request)

        URLSession.shared.dataTask(with: request) { data, response, error in
            self.logger.log(response: response, data: data)

            if let error = error {
                completion(.failure(NetworkError.unknown(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.custom("Invalid response")))
                return
            }

            guard 200...299 ~= httpResponse.statusCode else {
                completion(.failure(NetworkError.badResponse(statusCode: httpResponse.statusCode, data: data)))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            completion(.success(data))
        }.resume()
    }
}
