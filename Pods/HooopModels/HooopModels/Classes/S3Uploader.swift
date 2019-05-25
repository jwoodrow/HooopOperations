//
//  S3Uploader.swift
//  HOOOP
//
//  Created by James Woodrow on 08/02/2018.
//  Copyright © 2018 Hooop. All rights reserved.
//

import Foundation

import Alamofire
import AWSCore
import AWSS3


open class NetworkManager: Alamofire.SessionManager {
    
    private static var awsConfig:NSDictionary {
        get {
            let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist")
            let config = NSDictionary(contentsOfFile: path!)!
            let awsConfig = config.value(forKey: "aws")! as! NSDictionary
            return awsConfig
        }
    }
    private static var AWSAccessKey:String {
        get {
            return awsConfig.value(forKey: "access_key") as! String
        }
    }
    private static var AWSSecret:String {
        get {
            return awsConfig.value(forKey: "secret") as! String
        }
    }
    private static var AWSRegion:AWSRegionType {
        get {
            return AWSRegionType(rawValue: (awsConfig.value(forKey: "region") as! NSNumber).intValue)!
        }
    }
    private static var S3Bucket:String {
        get {
            return awsConfig.value(forKey: "bucket") as! String
        }
    }
    private static var S3Region:String {
        get {
            return awsConfig.value(forKey: "region_name") as! String
        }
    }
    
    private static let instance: NetworkManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return NetworkManager(configuration: configuration)
    }()
    
    var backgroundQueue: DispatchQueue
    var awsConfigurationToken = 0
    
    init(configuration: URLSessionConfiguration) {
        backgroundQueue = DispatchQueue.global(qos: .background)
        super.init(configuration: configuration)
    }
    
    class public func uploadFileWithURL(URL: NSURL, contentType: String, destination: String, key: String, completion: @escaping (_ value: String?, _ error: Error?) -> Void) {
        let _: () = {
            let credentialsProvider = AWSStaticCredentialsProvider(accessKey: NetworkManager.AWSAccessKey, secretKey: NetworkManager.AWSSecret)
            let configuration = AWSServiceConfiguration(region: NetworkManager.AWSRegion, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
        }()
        
        DispatchQueue.global(qos: .background).async {
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.key = key
            uploadRequest?.body = URL as URL
            uploadRequest?.contentType = contentType
            uploadRequest?.acl = .publicRead
            uploadRequest?.bucket = NetworkManager.S3Bucket + "/" + destination
            
            let uploadExpression = AWSS3TransferUtilityUploadExpression()
            uploadExpression.setValue("public-read", forRequestHeader: "x-amz-acl")
            let transferUtility = AWSS3TransferUtility.default()
            transferUtility.uploadFile(URL as URL, key: key, contentType: contentType, expression: uploadExpression, completionHandler: { (task, error) in
                guard error == nil else {
                    debugPrint("Failed to upload file: " + error.debugDescription)
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                
                let imageURLString = "https://\(NetworkManager.S3Region).amazonaws.com/\(NetworkManager.S3Bucket)/\(destination)/\(key)"
                DispatchQueue.main.async { completion(imageURLString, nil) }
                return
            })
        }
    }
    
    class public func uploadData(data: Data, contentType: String, destination: String, key: String, completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let tmpURL = NSURL(fileURLWithPath: NSTemporaryDirectory() + "/" + UUID().uuidString)
            do {
                try data.write(to: tmpURL as URL, options: NSData.WritingOptions.atomic)
            } catch {
                completion(nil, error)
                return
            }
            uploadFileWithURL(URL: tmpURL, contentType: contentType, destination: destination, key: key, completion: completion)
        }
    }
    
    open class func uploadImage(image: UIImage, key: String, completion: @escaping (String?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if let data = image.jpegData(compressionQuality: 1.0) {
                let contentType = "image/jpeg"  // MIME type
                uploadData(data: data, contentType: contentType, destination: "images", key: key, completion: completion)
            } else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil) as Error)
                }
            }
        }
    }
    
}

