//
//  GeneralInfoServices.swift
//  ZipDownloadPOC
//
//  Created by Rajaselvan Thangaraj on 18/01/19.
//  Copyright © 2019 Rajaselvan Thangaraj. All rights reserved.
//

import Foundation

class GeneralInfoServices: NSObject {
    
    static func getUserPosts(completionHandler: @escaping ((_ status: Bool,_ obj: Any)->())){
            APIClient.sendRequest(route: APIRouter.getUserPostsAPIEndPoint) { (response) in
                DispatchQueue.main.async {
                    if let responseDict = response as? NSArray {
                        print("\(responseDict)")
                        completionHandler(true, responseDict)
                    } else {
                        if let errorMsg = response as? String {
                            print("\(errorMsg)")
                        }
                        completionHandler(false, response as AnyObject)
                    }
                }
            }
    }
    
    
    static func getComments(completionHandler: @escaping ((_ status: Bool,_ obj: Any)->())){
        APIClient.sendRequest(route: APIRouter.getComments(1)) { (response) in
            DispatchQueue.main.async {
                if let responseDict = response as? NSArray {
                    print("\(responseDict)")
                    completionHandler(true, responseDict)
                } else {
                    if let errorMsg = response as? String {
                        print("\(errorMsg)")
                    }
                    completionHandler(false, response as AnyObject)
                }
            }
        }
    }
}
