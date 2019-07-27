//
//  BookCollectionView.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 7/26/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

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

class BookCollectionView: UICollectionViewController {
    
    var books = [Book]()
    let db = Firestore.firestore()
    var userBookCollection:AnyObject?
    
    let columnLayout = FlowLayout(
        cellsPerRow: 2,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
        let userAuth = Auth.auth().currentUser
        if let userinfo = userAuth {
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
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionCell", for: indexPath) as! BookCollectionViewCell
        let book = books[indexPath.row]
        cell.layer.borderColor = UIColor.cyan.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8 // optional
        cell.author.text = book.author
        cell.bookImage.image = self.resizeImage(image: book.imageUI, targetSize: CGSize(width: 100, height: 100))
        cell.title.text = book.title
        return cell
        }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentBook = books[indexPath.row]
        currentBookImage = books[indexPath.row].imageUI
        print(currentBook!.author)
        performSegue(withIdentifier: "bookselected", sender: self)
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
                                    self.books.append(Book(documentID: document.documentID, title: document.data()["title"] as! String, image: document.data()["image"] as! String, author: document.data()["author"] as! String, imageUI: imageUI)!)
                                    self.collectionView.reloadData()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        })
                    }else {
                        var imageUI = UIImage(named: "defaultPhoto")
                        self.books.append(Book(documentID: document.documentID, title: document.data()["title"] as! String, image: document.data()["image"] as! String, author: "author", imageUI: imageUI!)!)
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @IBAction func SignOut(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let signInController = storyBoard.instantiateViewController(withIdentifier: "signedIn") as! GoogleSignIn
        self.present(signInController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToBookList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewBookViewController, let book = sourceViewController.book {
            let newIndexPath = IndexPath(row: books.count, section: 0)
            print("image string:  \(book.image)")
            books.append(book)
            collectionView.insertItems(at: [newIndexPath])
        }
    }

}
