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
    var images: Array<String> = Array()
    var pageNumber: String
    var imagesUI: Array<UIImage> = Array()
    //var imageArray: Array<String>
    
    init?(documentId: String, text: String, images: Array<String>, pageNumber: String, imagesUI: Array<UIImage>) {
        guard !text.isEmpty else {
            return nil
        }
        
        self.documentId = documentId
        self.text = text
        self.images = images
        self.pageNumber = pageNumber
        self.imagesUI = imagesUI
    }
}
