//
//  Book.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/11/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

class Book: NSObject, NSCoding {
    var bookindex: Int
    var title: String
    var author: String
    var image: UIImage?
    var rating: Int
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("books")
    
    struct PropertyKey {
        static let bookindex = "bookindex"
        static let title = "title"
        static let author = "author"
        static let image = "image"
        static let rating = "rating"
    }
    
    init?(bookindex: Int, title: String, author: String, image: UIImage?, rating: Int) {
        guard !title.isEmpty else {
            return nil
        }
        
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        self.bookindex = bookindex
        self.title = title
        self.author = author
        self.image = image
        self.rating = rating
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(bookindex, forKey: PropertyKey.bookindex)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(author, forKey: PropertyKey.author)
        aCoder.encode(image, forKey: PropertyKey.image)
        aCoder.encode(rating, forKey: PropertyKey.rating)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
       
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the title for a Book object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let author = aDecoder.decodeObject(forKey: PropertyKey.author) as? String else {
            os_log("Unable to decode the author for a Book object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Because photo is an optional property of Meal, just use conditional cast.
    
        
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        let bookindex = aDecoder.decodeInteger(forKey: PropertyKey.bookindex)
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initializer.
        self.init(bookindex: bookindex, title: title, author: author, image: image, rating: rating)
        
    }

}
