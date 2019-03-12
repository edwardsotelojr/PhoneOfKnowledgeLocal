//
//  Note.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/12/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

class Note: NSObject, NSCoding {
    
    var bookindex: Int
    var notetext: String
    var image: UIImage?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("notes")
    
    struct PropertyKey {
        static let bookindex = "bookindex"
        static let notetext = "notetext"
        static let image = "image"
    }
    
    init?(bookindex: Int, notetext: String, image: UIImage?) {
        guard !notetext.isEmpty else {
            return nil
        }
        
        self.bookindex = bookindex
        self.notetext = notetext
        self.image = image
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(bookindex, forKey: PropertyKey.bookindex)
        aCoder.encode(notetext, forKey: PropertyKey.notetext)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let notetext = aDecoder.decodeObject(forKey: PropertyKey.notetext) as? String else {
            os_log("Unable to decode the note text for a Note object.", log: OSLog.default, type: .debug)
            return nil
        }
        // Because photo is an optional property of Meal, just use conditional cast.
        
        let bookindex = aDecoder.decodeInteger(forKey: PropertyKey.bookindex)
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
   
        // Must call designated initializer.
        self.init(bookindex: bookindex, notetext: notetext, image: image)
        
    }
    
}
