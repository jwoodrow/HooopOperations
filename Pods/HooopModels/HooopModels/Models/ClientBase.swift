//
//  ClientBase.swift
//  HOOOP
//
//  Created by James Woodrow on 26/01/2018.
//  Copyright © 2018 Hooop. All rights reserved.
//

import UIKit
import CoreData

open class ClientBase: NSManagedObject, Encodable {
    @NSManaged open var email: String?
    @NSManaged open var phone: String?
    @NSManaged open var gif: GifBase
}

