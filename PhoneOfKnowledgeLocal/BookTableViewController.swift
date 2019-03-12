//
//  BookTableViewController.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/11/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

var myIndex = 0
var nextbookindex = 0
class BookTableViewController: UITableViewController {
    var books = [Book]()
    var newBook: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        nextbookindex = books.count + 1
        // Load any saved meals, otherwise load sample data.
        if let savedBooks = loadBooks() {
            books += savedBooks
        }
        print("book array " , books)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return books.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? BookCell else {
           fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let book = books[indexPath.row]
        cell.authorLabel.text = book.author
        cell.imagePhoto.image = book.image
        cell.titleLabel.text = book.title
        // Configure the cell...

        return cell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            books.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    @IBAction func unwindToBookList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewBookViewController, let book = sourceViewController.book {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                books[selectedIndexPath.row] = book
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: books.count, section: 0)
                
                books.append(book)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveBooks()
            
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "bookselected", sender: self)
    }
    
    
    
    
    private func saveBooks() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(books, toFile: Book.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Books successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save books...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadBooks() -> [Book]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Book.ArchiveURL.path) as? [Book]
    }
}
