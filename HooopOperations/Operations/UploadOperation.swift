//
//  UploadOperation.swift
//  HOOOP
//
//  Created by James Woodrow on 28/01/2018.
//  Copyright © 2018 Hooop. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import HooopModels

open class UploadOperation: HooopOperation {
    private static var endPointConfig:NSDictionary {
        get {
            let path = Bundle.main.path(forResource: "AppConfig", ofType: "plist")
            let config = NSDictionary(contentsOfFile: path!)!
            let endPointConfig = config.value(forKey: "end_point")! as! NSDictionary
            return endPointConfig
        }
    }
    public var upload_endpoint: String {
        get {
            var secure_ssl : String = ""
            if (UploadOperation.endPointConfig.value(forKey: "secure_ssl") as! Bool) {
                secure_ssl.append("s")
            }
            let subdomain = UploadOperation.endPointConfig.value(forKey: "subdomain") as! String
            let domain = UploadOperation.endPointConfig.value(forKey: "domain") as! String
            let endpoint = (UploadOperation.endPointConfig.value(forKey: "upload") as! String).replacingOccurrences(of: "event_id", with: self.gif.event.id.stringValue)
            let upload_endpoint = "http\(secure_ssl)://\(subdomain).\(domain)/\(endpoint)"
            return upload_endpoint
        }
    }
    public let manager: SessionManager
    
    public init(withGif gif:GifBase, andManager manager: SessionManager) {
        self.manager = manager
        super.init()
        self.gif = gif
    }
    override open func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        let encoded_gif = try? gif.asDictionary()
        if let _ = encoded_gif {
            manager.request(upload_endpoint, method: HTTPMethod.post, parameters: ["gif": encoded_gif!], encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: gif.callback)
        }
    }
}

