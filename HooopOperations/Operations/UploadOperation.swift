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
    
    private let manager: SessionManager
    private let config: NSDictionary
    
    init(withGif gif:GifBase, andManager manager: SessionManager) {
        self.manager = manager
        self.config = NSDictionary()
        super.init()
        self.gif = gif
    }
    override open func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        let upload_endpoint = "https://admin.hooop.fr/api/events/\(gif.event.id.intValue)/create_new_gif2"
        let encoded_gif = try? gif.asDictionary()
        if let _ = encoded_gif {
            manager.request(upload_endpoint, method: HTTPMethod.post, parameters: ["gif": encoded_gif!], encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: gif.callback)
        }
    }
}

