import UIKit
import os.log
import FirebaseFirestore
import Firebase

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate  {
    
    @IBOutlet weak var notetext: UITextView!
    @IBOutlet weak var pageNumber: UITextField!
    @IBOutlet weak var noteimage: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var stackView: UIStackView!
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    var note: Note?
    var userNoteCollection:AnyObject?
    let db = Firestore.firestore()
    
    @IBAction func AddImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else {
                print("Camera not available")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        print("in cropviewcontroller")
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
      //  bookimage.image = self.resizeImage(image: image, targetSize: CGSize(width: 150, height: 200))
        print("in update image view function")
        if cropViewController.croppingStyle != .circular {
        //    bookimage.isHidden = true
            print("in update image view ")
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: stackView.subviews[0],
                                                   toFrame: CGRect.zero,
                                                   setup: { },
                                                   completion: nil)
        }
        else {
          //  self.bookimage.isHidden = false
            
            print("in update View with image")
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        print("selected image")
        let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
        cropController.delegate = self
        let newImage = UIImageView()
        newImage.image =  selectedImage
        stackView.addArrangedSubview(newImage)
        picker.dismiss(animated: true, completion: {
            print("presenting crop controller")
            self.present(cropController, animated: true, completion: nil)
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(notetext.constraints)
        notetext.delegate = self
        saveButton.isEnabled = false
        updateSaveButtonState()
        notetext.font = UIFont.preferredFont(forTextStyle: .headline)
        notetext.isScrollEnabled = false
        textViewDidChange(notetext)
    }
    

    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
        //navigationItem.title = textView.text
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("cancel")
        dismiss(animated: true, completion: nil)
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

extension NoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
