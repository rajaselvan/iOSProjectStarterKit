//
//  APIRouter.swift
//
//  Created by Rajaselvan on 18/01/19.
//  Copyright © 2019 Rajaselvan. All rights reserved.
//

import Alamofire

public enum APIRouter: URLRequestConvertible {
    // Declare constants to hold the base URL and your Basic auth token
    // with your actual authorization header.
    enum Constants {
//        static let baseURLPath = "https://jsonplaceholder.typicode.com"
        static let baseURLPath = "https://api.imagga.com/v2"
        static let authenticationToken = "Basic YWNjXzI3ZWY1MTAyZGQ1Y2E4MDo4MDY0YWEzMTFjYWE0YmMwOTA2ZTNmZTU1MTRmYmRiMw"
    }
    
    // Declare the enum cases. Each case corresponds to an api endpoint
    case signupAPIEndPoint(String, String, String, Bool)
    case getComments(Int)
    case getUserPostsAPIEndPoint
    case uploadPhotoAPIEndPoint
    
    // Return the HTTP method for each api endpoint
    var method: HTTPMethod {
        switch self {
        case .signupAPIEndPoint, .uploadPhotoAPIEndPoint:
            return .post
        case .getUserPostsAPIEndPoint, .getComments:
            return .get
        }
    }
    
    // Return the path for each api endpoint
    var path: String {
        switch self {
        case .signupAPIEndPoint:
            return "/api/Users/create"
        case .getUserPostsAPIEndPoint:
            return "/posts"
        case .uploadPhotoAPIEndPoint:
            return "/content"
        case .getComments:
            return "/comments"
        }
    }
    
    // Return the parameters for each api endpoint
    var parameters: [String: Any] {
        switch self {
        case .signupAPIEndPoint(let firstName, let email, let password, let subscribeEmailUpdates):
            return ["first_name": firstName, "email": email, "password": password, "subscribe_email_updates": subscribeEmailUpdates]
        default:
            return [:]
        }
    }
    
    // Use all of the above components to create a URLRequest for
    // the requested endpoint
    public func asURLRequest() throws -> URLRequest {
        switch self {
        // For query params in URL request
        case let .getComments(page) where page > 0:
            /* https://example.com/search?q=foo%20bar&offset=50
             let result: (path: String, parameters: Parameters) = {
             return ("/comments", ["q": query, "offset": page])
             }() */
            let result: (path: String, parameters: Parameters) = {
                return ("/comments", ["postId": page])
            }()
            let url = try Constants.baseURLPath.asURL()
            var request = URLRequest(url: url.appendingPathComponent(result.path))
            request.httpMethod = method.rawValue
            request.setValue(Constants.authenticationToken, forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            request.timeoutInterval = 120
            return try URLEncoding.default.encode(request, with: result.parameters)
        default:
            let url = try Constants.baseURLPath.asURL()
            var request = URLRequest(url: url.appendingPathComponent(path))
            request.httpMethod = method.rawValue
            request.setValue(Constants.authenticationToken, forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
            request.timeoutInterval = 120
            return try URLEncoding.default.encode(request, with: parameters)
        }
    }
}
