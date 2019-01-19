//
//  APIClient.swift
//
//  Created by Rajaselvan on 18/01/19.
//  Copyright © 2019 Rajaselvan. All rights reserved.
//

import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
    case xml = "application/xml"
    case zip = "application/zip"
}

enum ErrorMessages: String {
    case noInternet = "Your device is not connected to the internet. Please enable mobile data / wifi in settings"
    case common = "Something went wrong. Please try again later."
    case upload = "Error while uploading file. Please try again later."
    case download = "Error while downloading file. Please try again later."
}

@objc public class APIClient: NSObject {
    static func sendRequest(route: APIRouter, completion: @escaping ((_ obj: AnyObject?)->())) {
        if Connectivity.isConnectedToInternet {
            Alamofire.request(route)
                .validate()
                .responseJSON { response in
                    guard case let .failure(error) = response.result else {
                        let value = response.result.value
                        completion(value as AnyObject?)
                        return
                    }
                    if let error = error as? AFError {
                        switch error {
                        // Returned when a URLConvertible type fails to create a valid URL
                        case .invalidURL(let url):
                            print("Invalid URL: \(url) - \(error.localizedDescription)")
                        // Returned when a parameter encoding object throws an error during the encoding process.
                        case .parameterEncodingFailed(let reason):
                            print("Parameter encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        // Returned when some step in the multipart encoding process fails.
                        case .multipartEncodingFailed(let reason):
                            print("Multipart encoding failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        // Returned when a validate() call fails. (2XX)
                        case .responseValidationFailed(let reason):
                            print("Response validation failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                            
                            switch reason {
                            case .dataFileNil, .dataFileReadFailed:
                                print("Downloaded file could not be read")
                            case .missingContentType(let acceptableContentTypes):
                                print("Content Type Missing: \(acceptableContentTypes)")
                            case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                                print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                            case .unacceptableStatusCode(let code):
                                print("Response status code was unacceptable: \(code)")
                            }
                        // Returned when a response serializer encounters an error in the serialization process.
                        case .responseSerializationFailed(let reason):
                            print("Response serialization failed: \(error.localizedDescription)")
                            print("Failure Reason: \(reason)")
                        }
                        print("Underlying error: \(String(describing: error.underlyingError))")
                    } else if let error = error as? URLError {
                        print("URLError occurred: \(error)")
                    } else {
                        print("Unknown error: \(error)")
                    }
                    completion(ErrorMessages.common.rawValue as AnyObject?)
                    return
            }
        } else {
            completion(ErrorMessages.noInternet.rawValue as AnyObject?)
        }
        
    }
    
    static func uploadImage(image: UIImage,
                            progressCompletion: @escaping (_ percent: Float) -> Void,
                            completion: @escaping ((_ obj: AnyObject?)->())) {
        
        if Connectivity.isConnectedToInternet {
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                print("Could not get JPEG representation of UIImage")
                return
            }
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imageData,
                                         withName: "imagefile",
                                         fileName: "image.jpg",
                                         mimeType: "image/jpeg")
            },
                             with: APIRouter.uploadPhotoAPIEndPoint,
                             encodingCompletion: { encodingResult in
                                switch encodingResult {
                                case .success(let upload, _, _):
                                    upload.uploadProgress { progress in
                                        progressCompletion(Float(progress.fractionCompleted))
                                    }
                                    upload.validate()
                                    upload.responseJSON { response in
                                        guard response.result.isSuccess,
                                            let value = response.result.value else {
                                                print("Error while uploading file: \(String(describing: response.result.error))")
                                                completion(ErrorMessages.upload.rawValue as AnyObject?)
                                                return
                                        }
                                        completion(value as AnyObject?)
                                    }
                                case .failure(let encodingError):
                                    print(encodingError)
                                    completion(ErrorMessages.upload.rawValue as AnyObject?)
                                }
            })
        } else {
            completion(ErrorMessages.noInternet.rawValue as AnyObject?)
        }
    }
    
    static func downloadFile(urlString: String, downloadLocation: URL, progressCompletion: @escaping (_ percent: Float) -> Void, completion: @escaping ((_ obj: AnyObject?)->()))  {
        
        if Connectivity.isConnectedToInternet {
            let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                return (downloadLocation, [.createIntermediateDirectories, .removePreviousFile])
            }
            Alamofire.download(urlString, method: .get, parameters: nil, encoding: JSONEncoding.default, to: destination)
                .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
                    progressCompletion(Float(progress.fractionCompleted))
                }
                .validate()
                .responseString { response in
                    guard response.result.isSuccess,
                        let value = response.result.value else {
                            print("Error while downloading file: \(String(describing: response.result.error))")
                            completion(ErrorMessages.download.rawValue as AnyObject?)
                            return
                    }
                    completion(value as AnyObject?)
            }
        } else {
            completion(ErrorMessages.noInternet.rawValue as AnyObject?)
        }
    }
}

