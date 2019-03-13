//
//  Book+CoreDataProperties.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/13/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//
//

import Foundation
import CoreData


extension Book {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Book> {
        return NSFetchRequest<Book>(entityName: "Book")
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var image: NSData?
    @NSManaged public var notee: NSSet?

}

// MARK: Generated accessors for notee
extension Book {

    @objc(addNoteeObject:)
    @NSManaged public func addToNotee(_ value: NNote)

    @objc(removeNoteeObject:)
    @NSManaged public func removeFromNotee(_ value: NNote)

    @objc(addNotee:)
    @NSManaged public func addToNotee(_ values: NSSet)

    @objc(removeNotee:)
    @NSManaged public func removeFromNotee(_ values: NSSet)

}
