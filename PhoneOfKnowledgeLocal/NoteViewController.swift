import UIKit
import os.log
import FirebaseFirestore
import Firebase

class NoteViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UITextFieldDelegate  {
    @IBOutlet weak var notetext: UITextView!
    @IBOutlet weak var pageNumber: UITextField!
    @IBOutlet weak var noteimage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    let imagePickerController = UIImagePickerController()
    var note: Note?
    var userNoteCollection:AnyObject?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notetext.delegate = self
        updateSaveButtonState()
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
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        
        print("clicked")
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let docId = randomString(length: 20)
       var imageURL:NSArray = []
        var pageNumberText = Int(pageNumber.text!)
        if(pageNumberText == nil) {
            print("nil")
            pageNumberText = -1
        }
        if noteimage.image == UIImage(named: "notepad"){
            db.collection("users").document(email!).collection("books").document(currentBook!.documentID).collection("notes").document(docId).setData(["text":notetext.text!, "image": "", "pageNumber": pageNumberText!]){
                err in
                if let err = err{
                    print(err)
                } else {
                     imageURL = []
                    print("success")
                }
            }
        } else {
            let storageRef = Storage.storage().reference().child(docId)
            if let uploadData = self.noteimage.image!.pngData(){
                storageRef.putData(uploadData, metadata: nil, completion: {
                    (metadata, error) in
                    if error != nil {
                        print("storage error: ", error)
                    } else {
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print("downloadURL error: ", error)
                            } else {
                                self.db.collection("users").document(email!).collection("books").document(currentBook!.documentID).collection("notes").document(docId).setData(["text":self.notetext.text!, "image": url!.absoluteString, "pageNumber": pageNumberText!]){
                                    err in
                                    if let err = err{
                                        print(err)
                                    } else {
                                        imageURL = []
                                        print("success")
                                    }
                                }
                            }
                        })
                    }
                })
            }
            
        let text = notetext.text!
        
            note = Note(documentId: docId, text: text, images: imageURL as! Array<UIImage>, pageNumber: pageNumberText!)
    }
    }
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = notetext.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
   

}
