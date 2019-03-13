//
//  NNote+CoreDataProperties.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/13/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension NNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NNote> {
        return NSFetchRequest<NNote>(entityName: "NNote")
    }

    @NSManaged public var text: String?
    @NSManaged public var image: NSData?
    @NSManaged public var book: Book?

}
