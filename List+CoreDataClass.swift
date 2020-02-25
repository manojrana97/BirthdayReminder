//
//  List+CoreDataClass.swift
//  PhotoCollection
//
//  Created by Apple on 24/02/20.
//  Copyright © 2020 Apple. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(List)
public class List: NSManagedObject {
    private static let startOrderIndex: Double = 0.0
    private static let incrementIndexBy: Double = 0.0001
    
    static private let listEntity = NSEntityDescription.entity(forEntityName: "List", in: DataManager.mainContext)
    
    class func set(id: String, name: String?,icon: NSData?, createdDate: NSDate? = NSDate(), images: [Image]? = nil) -> List? {
        var list: List!
        list = get(ids: [id])?.first // Get existing List
        if list == nil {
            list = List(entity: listEntity!, insertInto: DataManager.mainContext) as List // Create new List
            
           // let currentCount = UserDefaultManager().getCreatedListCount()
                   //   UserDefaultManager().setCreatedListCount(currentCount + 1)
        }
        
        
        list.id = id
        list.name = name
        list.image = icon as Data?
        list.createdDate = createdDate as Date?
        var orderIndex = startOrderIndex
        if let lastIndex = getAll()?.last?.orderIndex {
            orderIndex = lastIndex + incrementIndexBy
        }
        list.orderIndex = orderIndex
//        list = get(ids: [id])?.first // Get existing List
//        if list == nil {
//            list = List(entity: listEntity!, insertInto: DataManager.mainContext) as List // Create new List
//
//            let currentCount = UserDefaultManager().getCreatedListCount()
//                      UserDefaultManager().setCreatedListCount(currentCount + 1)
//        }
  
        DataManager.persist(synchronously: true)
        return list
    }
    
    
    /**
        Get the lists based on Ids
        */
       class func get(ids: [String]) -> [List]? {
           let predicate = NSPredicate(format: "id IN %@", ids)
             let sorter = NSSortDescriptor(key: "orderIndex", ascending: true)
           return DataManager.fetchObjects(entity: List.self,  predicate: predicate, sortDescriptors: [sorter] , context: DataManager.mainContext)
       }
       
    
    
    /**
     Get the user based on Ids
     */
    class func getAll() -> [List]? {
        let sorter = NSSortDescriptor(key: "orderIndex", ascending: true)
        return DataManager.fetchObjects(entity: List.self,  predicate: nil, sortDescriptors: [sorter], context: DataManager.mainContext)
    }

}


