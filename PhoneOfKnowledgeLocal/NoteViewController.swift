//
//  NoteViewController.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/12/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

class NoteViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate {
    
    var note: Note?
    @IBOutlet weak var notetext: UITextView!
    @IBOutlet weak var noteimage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notetext.delegate = self
        updateSaveButtonState()

        // Do any additional setup after loading the view.
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (notetext.text.count > 1) {
            saveButton.isEnabled = true
        }
    }
    

    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
        navigationItem.title = textView.text
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            noteimage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectedImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        notetext.resignFirstResponder()
        imagePickerController.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePickerController.sourceType = .photoLibrary
        
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
        let bookindex = 2
        let notet = notetext.text ?? ""
        let notei = noteimage.image
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        note = Note(bookindex: bookindex, notetext: notet, image: notei)
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = notetext.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
   

}
