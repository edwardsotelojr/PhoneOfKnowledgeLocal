import UIKit
import os.log
import FirebaseFirestore
import Firebase

class NoteViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,  CropViewControllerDelegate  {
    
    @IBOutlet weak var notetext: UITextView!
    @IBOutlet weak var pageNumber: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var stackView: UIStackView!
    
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    var note: Note?
    var userNoteCollection:AnyObject?
    let db = Firestore.firestore()
    var images: Array<UIImage> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notetext.delegate = self
        saveButton.isEnabled = false
        notetext.font = UIFont.preferredFont(forTextStyle: .headline)
        notetext.isScrollEnabled = false
        textViewDidChange(notetext)
    }
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        print("selected image")
        let cropController = CropViewController(croppingStyle: croppingStyle, image: selectedImage)
        cropController.delegate = self
        picker.dismiss(animated: true, completion: {
            print("presenting crop controller")
            self.present(cropController, animated: true, completion: nil)
            
        })
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        print("in cropviewcontroller")
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }

    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        let view = UIView()
        let newImage = UIImageView()
        newImage.image =  self.resizeImage(image: image, targetSize: CGSize(width: 150, height: stackView.frame.height))
        newImage.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        //newImage.widthAnchor.constraint(equalToConstant: 150).isActive = true
        //let cancelButton = UIButton()
        //cancelButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        //cancelButton.backgroundColor = UIColor.black
       // cancelButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        
        view.addSubview(newImage)
        //view.addSubview(cancelButton)
        
        images.append(newImage.image!)
        print(images)
        stackView.addArrangedSubview(view)
        
        
        print("in update image view function")
        if cropViewController.croppingStyle != .circular {
        //    bookimage.isHidden = true
            print("in update image view ")
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: stackView,
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
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        picker.dismiss(animated: true, completion: nil)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == pageNumber{
            pageNumber.resignFirstResponder()
            notetext.becomeFirstResponder()
            return true
        }else{
            notetext.resignFirstResponder()
            return true
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func Save(_ sender: Any) {
        let docId = randomString(length: 20)
        let storageRef = Storage.storage().reference().child(docId)
        if(pageNumber.text == nil) {
            print("nil")
            pageNumber.text = ""
        }
        
        // no image
        if(stackView.arrangedSubviews.count == 0){
            db.collection("users").document(email!).collection("books").document(currentBook!.documentID).collection("notes").document(docId).setData(["text": notetext.text!, "image": "", "pageNumber": pageNumber.text!]){
                err in
                if let err = err{
                    print(err)
                } else {
                    print("success")
                }
            }
        }
        else if (stackView.arrangedSubviews.count > 0){
            print("stackview has more thatn one view")
            if let imagesURL: Array<String> = storeImages(docID: docId, storageRef: storageRef , images: images){
            self.db.collection("users").document(email!).collection("books").document(currentBook!.documentID).collection("notes").document(docId).setData(["text":self.notetext.text!, "images": imagesURL, "pageNumber": pageNumber.text!]){ err in
                    if let err = err {
                        print("saving document error: ", err)
                    } else {
                        print("success with user photo \(imagesURL)")
                        self.note = Note(documentId: docId, text: self.notetext.text!, images: imagesURL, pageNumber: self.pageNumber.text!, imagesUI: self.images)
                    }
                }
            }
        }
            /*
             db.collection("users").document(email!).collection("books").document(currentBook!.documentID).collection("notes").document(docId).setData(["text":notetext.text!, "image": "", "pageNumber": pageNumberText!]){
             err in
             if let err = err{
             print(err)
             } else {
             imageURL = []
             print("success")
             }
             }*/
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.performSegue(withIdentifier: "noteCreated", sender: self)
        }
    }
    
    private func storeImages(docID: String, storageRef: StorageReference, images: Array<UIImage>) -> Array<String>{
        var imagesURL: Array<String> = Array()
        for x in images{
            if let uploadData = x.pngData(){
                let upload = storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("storage error: ", error!)
                        return
                    }
                })
                upload.observe(.success) { snapshot in
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("download URL error: ", error!)
                        } else {
                            imagesURL.append(url!.absoluteString)
                            print("imagesURL", imagesURL)
                        }
                    })

                }
            }
        }
        return imagesURL
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        if(notetext.text != ""){
            saveButton.isEnabled = true
        }
    }
    
    private func resizeImage(image: UIImage, targetSize:CGSize) -> UIImage {
        let originalSize = image.size
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        var newSize:CGSize
        
        if widthRatio > heightRatio {
            newSize = CGSize(width: originalSize.width * heightRatio, height: originalSize.height * heightRatio)
        } else {
            newSize = CGSize(width: originalSize.width * widthRatio, height: originalSize.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

extension NoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateSaveButtonState()
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach{ (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
