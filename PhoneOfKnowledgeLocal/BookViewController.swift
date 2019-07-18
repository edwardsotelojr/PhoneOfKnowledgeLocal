import UIKit
import os.log
import FirebaseFirestore
import Firebase

var currentNote: Note?

class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let db = Firestore.firestore()
    var notes = [Note]()
    var userNoteCollection:AnyObject?
    var bookTitle:String = ""
    var bookAuthor:String = ""
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var bookimage: UIImageView!
    @IBOutlet weak var authorname: UILabel!
    @IBOutlet weak var notetable: UITableView!
    @IBOutlet weak var booktitle: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userAuth = Auth.auth().currentUser
        print("current book author: " + currentBook!.title)
        loadData()
        table.reloadData()
        let userBook = user?.collection("books").document(currentBook!.documentID)
        userBook!.getDocument { (document, error) in
            if let document = document {
                self.authorname.text = document.data()!["author"] as? String
                self.booktitle.text = document.data()!["title"] as? String
                self.bookimage.image = self.resizeImage(image: currentBookImage!, targetSize: CGSize(width: 100, height: 100))
            }
       }
        let userNote = userBook?.collection("notes").document()
        userNoteCollection = userNote
    }

    func loadData() {
        user!.collection("books").document(currentBook!.documentID).collection("notes").getDocuments() {
            (snapshot, error) in
            if let err = error {
                print(err)
            } else {
                for document in snapshot!.documents {
                
                    let imagesArray = document.data()["images"] as! NSArray
                    var imagesUIArray: Array<UIImage> = Array()
                    var count = 0
                    for image in imagesArray{
                        count += 1
                        if(image as! String != ""){
                            let storageRef = Storage.storage().reference(forURL: image as! String)
                            storageRef.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    print("error downloading image \(error)")
                                } else {
                                    do {
                                        let data = try Data(contentsOf: url!)
                                        let image = UIImage(data: data)
                                        print("got image")
                                        imagesUIArray.append(image!)
                                        print("\(image)")
                                        if(count == imagesArray.count){
                                            
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            })
                            
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.notes.append(Note(documentId: document.documentID, text: document.data()["text"] as! String, images: imagesUIArray, pageNumber: document.data()["pageNumber"] as! Int)!)
                    print("imagesUIArray = \(imagesUIArray.count)")
                    print("\(imagesUIArray)")
                         self.table.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notecell", for: indexPath) as? NotesCell else {
            fatalError("The dequeued cell is not an instance of Note table .")
        }
        let note = notes[indexPath.row]
        for image in note.images{ cell.imagesStack.addArrangedSubview(UIImageView(image: image))
        }
        cell.imagesStack.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap(_:))))
        cell.notetext.text = note.text
        if (note.pageNumber == -1){
            cell.pageNumber.text = nil
        } else {
            cell.pageNumber.text = String(note.pageNumber)
        }
        return cell
    }
    
    @objc func tap(_ gestureRecognizer: UITapGestureRecognizer) {
        print("lmaooo")
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            userNoteCollection?.collection("notes").document(notes[indexPath.row].text).delete(){
                err in
                if let err = err {
                    print(err)
                } else {
                    print("delete success")
                }
            }
            // Delete the row from the data source
            notes.remove(at: indexPath.row)
            table.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NoteViewController, let note = sourceViewController.note {
            let newIndexPath = IndexPath(row: notes.count, section: 0)
            notes.append(note)
            table.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentNote = notes[indexPath.row]
        performSegue(withIdentifier: "bookselected", sender: self)
    }
}
