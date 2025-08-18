//
//  NetworkLogger.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import Foundation

class NetworkLogger: NetworkLoggerProtocol {
    static let shared = NetworkLogger()

    func log(request: URLRequest) {
        print("\n - - - - - - - - - - OUTGOING REQUEST - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - - END OF REQUEST - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod!) " : ""
        let path = urlComponents?.path ?? ""
        let query = urlComponents?.query ?? ""
        let host = urlComponents?.host ?? ""
        
        var logOutput = """
                        \(method)\(urlAsString)
                        HOST: \(host)
                        PATH: \(path)
                        QUERY: \(query)
                        """
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logOutput += "\nHEADERS: ["
            for (key, value) in headers {
                logOutput += "\(key): \(value); "
            }
            logOutput += "]"
        }
        
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logOutput += "\nBODY: \(bodyString)"
        }
        
        print(logOutput)
    }
    
    func log(response: URLResponse?, data: Data?) {
        print("\n - - - - - - - - - - INCOMING RESPONSE - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - - END OF RESPONSE - - - - - - - - - - \n") }
        
        guard let response = response as? HTTPURLResponse else { return }
        
        let urlAsString = response.url?.absoluteString ?? ""
        let statusCode = response.statusCode
        let statusMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
        
        var logOutput = """
                        RESPONSE: \(urlAsString)
                        STATUS: \(statusCode) - \(statusMessage)
                        """
        
        if let data = data, let prettyPrintedJson = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers), let jsonData = try? JSONSerialization.data(withJSONObject: prettyPrintedJson, options: .prettyPrinted), let jsonString = String(data: jsonData, encoding: .utf8) {
            logOutput += "\nDATA: \(jsonString)"
        }
        
        print(logOutput)
    }
}
