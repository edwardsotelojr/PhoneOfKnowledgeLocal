//
//  Book.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 6/4/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit

class Book {
    var documentID: String
    var title: String
    var image: String
    var author: String
    var imageUI: UIImage
    
    init?(documentID: String, title: String, image: String, author: String, imageUI: UIImage) {
        guard !title.isEmpty else {
            return nil
        }
        
        guard !author.isEmpty else {
            return nil
        }
        self.documentID = documentID
        self.title = title
        self.image = image
        self.author = author
        self.imageUI = imageUI
    }
}
