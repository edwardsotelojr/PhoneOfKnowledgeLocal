//
//  NewBookViewController.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/11/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

class NewBookViewController: UIViewController, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var book: Book?
    @IBOutlet weak var bookimage: UIImageView!
    @IBOutlet weak var booktitleField: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var authorField: UITextField!
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        booktitleField.delegate = self
        // Do any additional setup after loading the view.
           updateSaveButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        booktitleField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
         saveButton.isEnabled = false
    }
 
    func textFieldDidEndEditing(_ textField: UITextField) {
       updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("cancel")
         dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
        bookimage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectedImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        booktitleField.resignFirstResponder()
      
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        print("clicked")
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let title = booktitleField.text ?? ""
        let author = authorField.text ?? ""
        let image = bookimage.image
        let bookindex = nextbookindex
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        book = Book(bookindex: bookindex, title: title, author: author, image: image, rating: 0)
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = booktitleField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
