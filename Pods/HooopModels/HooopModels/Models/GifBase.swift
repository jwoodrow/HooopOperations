//
//  GifBase.swift
//  HOOOP
//
//  Created by James Woodrow on 26/01/2018.
//  Copyright © 2018 Hooop. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

open class GifBase: NSManagedObject, Encodable {
    @NSManaged open var uuid: UUID
    @NSManaged open var frameImagesData: [NSData]?
    @NSManaged open var event: EventBase
    @NSManaged open var clients: NSMutableOrderedSet?
    @NSManaged open var created_at: NSDate
    
    open var frameImages: [UIImage]? {
        get {
            if (frameImagesData == nil) {
                return nil
            }
            var ret:[UIImage]? = []
            for fID:Data in self.frameImagesData! as [Data] {
                ret!.append(UIImage(data: fID)!)
            }
            return ret
        }
        set {
            if (newValue == nil) {
                self.frameImagesData = nil
            } else {
                var ret:[NSData]? = []
                for fI:UIImage in newValue! as [UIImage] {
                    ret!.append((UIImagePNGRepresentation(fI) as NSData?)!)
                }
                self.frameImagesData = ret
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case photoUrls
        case event_id
        case created_at
        case clients_attributes
    }
    
    open func encode(to encoder: Encoder) throws {
        let encodingGroup = DispatchGroup()
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid.uuidString, forKey: .uuid)
        var framesData: [Data?] = []
        var frameUrls: [String] = []
        for image in frameImages! {
            framesData.append(UIImageJPEGRepresentation(image, 1))
        }
        for (index, frameData) in framesData.enumerated() {
            encodingGroup.enter()
            NetworkManager.uploadData(data: frameData!, contentType: "image/jpeg", destination: "hooop/events/\(event.url_id)/gifs/\(uuid)/photos", key: "photo\(index).jpg") { (url, error) in
                if (error == nil) {
                    print("Photo \(index) uploaded")
                    frameUrls.append(url!)
                    encodingGroup.leave()
                } else {
                    print(error!)
                }
            }
        }
        encodingGroup.wait()
        try container.encode(frameUrls, forKey: .photoUrls)
        try container.encode(event.id.int64Value, forKey: .event_id)
        try container.encode(clients?.array as! [ClientBase], forKey: .clients_attributes)
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        try container.encode(formatter.string(from: created_at as Date), forKey: .created_at)
    }
    
    open func callback(response:DataResponse<Any>) {
        if (response.response?.statusCode == 200) {
            self.delete()
        }
    }
}


