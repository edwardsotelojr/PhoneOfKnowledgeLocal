import UIKit
import os.log
import FirebaseFirestore
import GoogleSignIn
import Firebase

class NewBookViewController: UIViewController, CropViewControllerDelegate, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var bookimage: UIImageView!
    @IBOutlet weak var booktitleField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var authorField: UITextField!
    var book: Book?
    var userBookCollection:AnyObject?
    var author: String?
    private var croppingStyle = CropViewCroppingStyle.default
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        booktitleField.delegate = self
        let email = GIDSignIn.sharedInstance()?.currentUser.profile.email!
        let db = Firestore.firestore()
        let setUser = db.collection("users").document(email!)
        userBookCollection = setUser
        updateSaveButtonState()
    }
    
    @IBAction func selectedImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
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
        bookimage.image =  self.resizeImage(image: selectedImage, targetSize: CGSize(width: 250, height: 250))
        picker.dismiss(animated: true, completion: {
            print("presenting crop controller")
            self.present(cropController, animated: true, completion: nil)
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == booktitleField{
            booktitleField.resignFirstResponder()
            authorField.becomeFirstResponder()
            return true
        }else{
            booktitleField.resignFirstResponder()
            return true
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        print("in cropviewcontroller")
        updateImageViewWithImage(image, fromCropViewController: cropViewController)
    }
    
    public func updateImageViewWithImage(_ image: UIImage, fromCropViewController cropViewController: CropViewController) {
        bookimage.image = self.resizeImage(image: image, targetSize: CGSize(width: 250, height: 250))
        print("in update image view function")
        if cropViewController.croppingStyle != .circular {
            bookimage.isHidden = true
            print("in update image view ")
            cropViewController.dismissAnimatedFrom(self, withCroppedImage: image,
                                                   toView: bookimage,
                                                   toFrame: CGRect.zero,
                                                   setup: { },
                                                   completion: { self.bookimage.isHidden = false })
        }
        else {
            self.bookimage.isHidden = false
            
            print("in update View with image")
            cropViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = booktitleField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
  
    @IBAction func Save(_ sender: Any) {
        let docId = UUID().uuidString
        var imageURL:String?
        if bookimage.image == UIImage(named: "defaultPhoto"){
            print("default photo")
            self.userBookCollection?.collection("books").document(docId).setData(["title":self.booktitleField.text!, "author":self.authorField.text!, "image": ""]){ err in
                if let err = err {
                    print("saving document error: ", err)
                } else {
                    imageURL = ""
                    print("success with default photo")
                }
            }
        } else {
            let storageRef = Storage.storage().reference().child(docId)
            if let uploadData = self.bookimage.image!.pngData(){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("storage error: ", error)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("download URL error: ", error)
                        } else {
                            self.userBookCollection?.collection("books").document(docId).setData(["title":self.booktitleField.text!, "author":self.authorField.text!, "image": url!.absoluteString]){ err in
                                if let err = err {
                                    print("saving document error: ", err)
                                } else {
                                    imageURL = url!.absoluteString
                                    print("success with user photo \(imageURL)")
                                    self.book = Book(documentID: docId ,title: self.booktitleField.text!, image: imageURL!, author: self.authorField.text!, imageUI: self.bookimage.image!)
                                }
                            }
                        }
                    })
                })
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
           self.performSegue(withIdentifier: "unwindNewBook", sender: self)
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
