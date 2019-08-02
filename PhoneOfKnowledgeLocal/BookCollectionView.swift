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
var notes = [Note]()
class BookCollectionView: UICollectionViewController {
    
    var userBookCollection:AnyObject?
    
    let columnLayout = FlowLayout(
        cellsPerRow: 2,
        minimumInteritemSpacing: 10,
        minimumLineSpacing: 10,
        sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let userAuth = Auth.auth().currentUser
            if let userinfo = userAuth {
                self.title = userinfo.displayName! + "'s Books"
                // ...
            }
            email = (GIDSignIn.sharedInstance()?.currentUser.profile.email!)!
        collectionView?.collectionViewLayout = columnLayout
        collectionView?.contentInsetAdjustmentBehavior = .always
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
        loadbook(book: books[indexPath.row])
    }

    // load selected book
    private func loadbook(book: Book){
        currentBook = nil
        currentBook = book
        notes = []
        user?.document(book.documentID).collection("notes").getDocuments() {
            (snapshot, error) in
            if error != nil {
                print(error)
                return
            }
            let docArray = snapshot!.documents
            for document in snapshot!.documents {
                let documentID = document.documentID
                let note = document.data()["note"] as! String
                let pageNumber = document.data()["pageNumber"] as! String
                let imagesArray = document.data()["images"] as! Array<String>
                var imagesUIArray: Array<UIImage> = Array()
                var count = 0
                print("imagesArray \(imagesArray)")
                print("imagesArray count \(imagesArray.count)")
                if(imagesArray == []){
                    notes.append(Note(documentId: documentID, note: note, images: [], pageNumber: pageNumber, imagesUI: [])!)
                    print("appended note with no images")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        notes.append(Note(documentId: document.documentID, note: document.data()["text"] as! String, images: document.data()["images"] as! Array<String>, pageNumber: document.data()["pageNumber"] as! String, imagesUI: imagesUIArray)!)
                        self.performSegue(withIdentifier: "bookselected", sender: self)
                    }
                }else{
                    for image in imagesArray{
                        count += 1
                        if(image != ""){
                            var storageRef = Storage.storage().reference(forURL: image as! String)
                            storageRef.downloadURL(completion: { (url, error) in
                                if error != nil {
                                    print("error downloading image \(error)")
                                    return
                                }
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
                            })
                        }
                        if(image == imagesArray.last && count == imagesArray.count){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                print("segue")
                                notes.append(Note(documentId: document.documentID, note: document.data()["note"] as! String, images: document.data()["images"] as! Array<String>, pageNumber: document.data()["pageNumber"] as! String, imagesUI: imagesUIArray)!)
                                  self.performSegue(withIdentifier: "bookselected", sender: self)
                            }
                        }
                    }
               
                }
            }
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
