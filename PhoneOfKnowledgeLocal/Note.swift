//
//  Note.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 6/4/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//


import UIKit

class Note {
    var documentId: String
    var text: String
    var images: Array<UIImage>
    var pageNumber: Int
    //var imageArray: Array<String>
    
    init?(documentId: String, text: String, images: Array<UIImage>, pageNumber: Int) {
        guard !text.isEmpty else {
            return nil
        }
        
        self.documentId = documentId
        self.text = text
        self.images = images
        self.pageNumber = pageNumber
    }
}
