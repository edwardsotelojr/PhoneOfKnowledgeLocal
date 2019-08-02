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
    var note: String
    var images: Array<String> = Array()
    var pageNumber: String
    var imagesUI: Array<UIImage> = Array()
    //var imageArray: Array<String>
    
    init?(documentId: String, note: String, images: Array<String>, pageNumber: String, imagesUI: Array<UIImage>) {
        guard !note.isEmpty else {
            return nil
        }
        
        self.documentId = documentId
        self.note = note
        self.images = images
        self.pageNumber = pageNumber
        self.imagesUI = imagesUI
    }
}
