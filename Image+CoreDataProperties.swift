//
//  Image+CoreDataProperties.swift
//  PhotoCollection
//
//  Created by Apple on 24/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//
//

import Foundation
import CoreData


extension Image {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }

    @NSManaged public var createdDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var photo: Data?
    @NSManaged public var lists: List?

}
