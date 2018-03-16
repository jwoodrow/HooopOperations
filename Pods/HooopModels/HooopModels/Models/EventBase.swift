//
//  EventBase.swift
//  HOOOP
//
//  Created by James Woodrow on 26/01/2018.
//  Copyright © 2018 Hooop. All rights reserved.
//

import UIKit
import CoreData

open class EventBase: NSManagedObject {
    @NSManaged open var id: NSNumber
    @NSManaged open var url_id: String
    @NSManaged open var code: String
    @NSManaged open var gifs: NSMutableOrderedSet
    @NSManaged open var interval_photo: NSNumber
    @NSManaged open var interval_gif: NSNumber
    
    override open class func mappings() -> [String:String] {
        return ["interval_photo":"interval_between_photo","interval_gif":"interval_between_photo_gif"]
    }
}


