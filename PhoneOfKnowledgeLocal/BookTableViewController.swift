import UIKit
import os.log
import GoogleSignIn
import FirebaseFirestore
import Firebase

var currentBookImage: UIImage?
var myIndex = 0
var user:AnyObject?
var currentBook:Book?
var email:String?

class BookTableViewController: UITableViewController {
    var books = [Book]()
    let db = Firestore.firestore()
    var userBookCollection:AnyObject?
   
    @IBOutlet weak var navBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userAuth = Auth.auth().currentUser
        print("userAuth = ", userAuth)
        if let userinfo = userAuth {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = userinfo.uid
            let email = userinfo.email
            let photoURL = userinfo.photoURL
            self.title = userinfo.displayName! + "'s Books"
            // ...
        }
        
        email = (GIDSignIn.sharedInstance()?.currentUser.profile.email!)!
        loadData()
        let setUser = db.collection("users").document(email!).setData([:])
        let userDocument = db.collection("users").document(email!)
        user = userDocument
        print("here")
        let userBook = userDocument.collection("books").document()
        userBookCollection = userDocument
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableView.automaticDimension

    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
  
    
    func loadData() {
        var imageUI = UIImage(named: "defaultPhoto")!
        db.collection("users").document(email!).collection("books").getDocuments() {
            (snapshot, error) in
            if let err = error {
                print(err)
            } else {
                for document in snapshot!.documents {
                    if (document.data()["image"] as! String != ""){ // has image
                         var storageRef = Storage.storage().reference(forURL: document.data()["image"] as! String)
                         storageRef.downloadURL(completion: { (url, error) in
                            if error != nil {
                                print("error in download url: ", error!)
                            } else{
                                do{
                                    let data = try Data(contentsOf: url!)
                                    let image = UIImage(data: data)
                                    print("got image", image!)
                                    var imageUI = image!
                                    self.books.append(Book(documentID: document.documentID, title: document.data()["title"] as! String, image: document.data()["image"] as! String, author: "author", imageUI: imageUI)!)
                                     self.tableView.reloadData()
                                   
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        })
                    }else {
                        var imageUI = UIImage(named: "defaultPhoto")
                        self.books.append(Book(documentID: document.documentID, title: document.data()["title"] as! String, image: document.data()["image"] as! String, author: "author", imageUI: imageUI!)!)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func SignOut(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signInController = storyBoard.instantiateViewController(withIdentifier: "signedIn") as! GoogleSignIn
        self.present(signInController, animated: true, completion: nil)
    }
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
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
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookCell else {
           fatalError("The dequeued cell is not an instance of BookCell.")
        }
        let book = books[indexPath.row]
        cell.authorLabel.text = book.author
        cell.imagePhoto.image = self.resizeImage(image: book.imageUI, targetSize: CGSize(width: 100, height: 100))
        cell.titleLabel.text = book.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            userBookCollection?.collection("books").document(books[indexPath.row].documentID).delete(){ err in
                if let err = err {
                    print(err)
                } else {
                    print("delete success")
                }
            }
            books.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func unwindToBookList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewBookViewController, let book = sourceViewController.book {
            let newIndexPath = IndexPath(row: books.count, section: 0)
            print("image string:  \(book.image)")
            books.append(book)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentBook = books[indexPath.row]
        currentBookImage = books[indexPath.row].imageUI
        print(currentBook!.author)
        performSegue(withIdentifier: "bookselected", sender: self)
    }
}
