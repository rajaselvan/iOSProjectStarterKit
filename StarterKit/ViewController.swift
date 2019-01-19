//
//  ViewController.swift
//
//  Created by Rajaselvan Thangaraj on 17/01/19.
//  Copyright © 2019 Rajaselvan Thangaraj. All rights reserved.
//

import UIKit
import Alamofire
import Zip
class ViewController: UIViewController, FileManagerDelegate {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createDownloadRequest()
//        self.upload()
    }
    
    func upload() {
        let image = UIImage(named: "cocktail.png")!
        APIClient.uploadImage(image: image, progressCompletion: {
            (progress) in
            DispatchQueue.main.async {
                self.progressView.progress = self.progressView.progress + Float(progress)
            }
        }, completion: { (response) in
            DispatchQueue.main.async {
                self.progressView.progress = 0
            }
        })
    }
    
    func getPostsResponse() {
        GeneralInfoServices.getUserPosts() {
            (success, response) in
            DispatchQueue.main.async {
                if success {
                    if let responseArray = response as? NSArray {
                        //                        print(responseArray)
                    }
                } else {
                    if let errorMsg = response as? String {
                        //                        print(errorMsg)
                    }
                }
            }
        }
    }
    
    func getCommentsResponse() {
        GeneralInfoServices.getComments() {
            (success, response) in
            DispatchQueue.main.async {
                if success {
                    if let responseArray = response as? NSArray {
                        //                        print(responseArray)
                    }
                } else {
                    if let errorMsg = response as? String {
                        //                        print(errorMsg)
                    }
                }
            }
        }
    }
    
    
    func createDownloadRequest() {
        let destination = getDocumentsDirectory().appendingPathComponent("archive.zip")
        APIClient.downloadFile(urlString: "https://github.com/i2iselvan/prenatalZip/raw/master/PrenatalWorkout.zip", downloadLocation: destination, progressCompletion: {
            (progress) in
            DispatchQueue.main.async {
                self.progressView.progress = self.progressView.progress + Float(progress)
            }
        }, completion: { (response) in
            DispatchQueue.main.async {
                self.unzip(filePath: destination)
                self.progressView.progress = 0
            }
        })
    }
    
    
    
    func unzip(filePath: URL) {
        do {
            let unzipDirectory = try? Zip.quickUnzipFile(filePath, progress:  { (progress) -> () in
                if progress == 1.0 {
                    self.deleteDownloadedZipFile()
                    self.moveImagesToDocumentsDirectory()
                    self.deleteUnZippedFile()
                }
            })
        }
        catch {
            print("Something went wrong")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func deleteDownloadedZipFile() {
        do {
            let destination = getDocumentsDirectory().appendingPathComponent("archive.zip")
            try FileManager.default.removeItem(at: destination)
        } catch {
            print("File could not be deleted")
        }
    }
    
    func deleteUnZippedFile() {
        do {
            let destination = getDocumentsDirectory().appendingPathComponent("archive")
            try FileManager.default.removeItem(at: destination)
        } catch {
            print("File could not be deleted")
        }
    }
    
    func moveImagesToDocumentsDirectory() {
        let fileManager = FileManager.default
        do {
            let source = getDocumentsDirectory().appendingPathComponent("archive/PrenatalWorkout/images")
            let destination = getDocumentsDirectory().appendingPathComponent("images")
            try fileManager.moveItem(at: source, to: destination)
        }
        catch {
            print(error)
        }
    }
}


