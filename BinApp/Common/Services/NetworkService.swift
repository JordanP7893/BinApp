// NetworkService.swift
// BinApp
//
// Created to provide reusable, generic networking functionality.

import Foundation

protocol NetworkingService {
    func fetchData(from url: URL) async throws -> Data
    func fetchData(from baseURL: URL, withParams params: [String: Any]) async throws -> Data
}

class DefaultNetworkingService: NetworkingService {
    func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkServiceError.invalidResponse
        }
        return data
    }
    
    func fetchData(from baseURL: URL, withParams params: [String: Any]) async throws -> Data {
        guard let url = makeURL(baseURL: baseURL, params: params) else {
            throw NetworkServiceError.invalidUrl
        }
        return try await fetchData(from: url)
    }
    
    private func getParamString(params:[String:Any]) -> String {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
    private func makeURL(baseURL: URL, params: [String: Any]) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = params.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        return components?.url
    }
}

enum NetworkServiceError: Error {
    case invalidUrl
    case invalidResponse
}
