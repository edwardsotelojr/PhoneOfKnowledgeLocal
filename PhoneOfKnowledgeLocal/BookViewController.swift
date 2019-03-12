//
//  BookViewController.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/12/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

var myIndex2 = 0
var curentbookindex: Int?
class BookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var books = [Book]()
    var notes = [Note]()
    @IBOutlet weak var bookimage: UIImageView!
    @IBOutlet weak var authorname: UILabel!
    @IBOutlet weak var notetable: UITableView!
    @IBOutlet weak var booktitle: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notecell", for: indexPath) as? NotesCell else {
            fatalError("The dequeued cell is not an instance of Note table .")
        }
        let note = notes[indexPath.row]
        cell.notetext.text = note.notetext
        cell.noteimage.image = note.image
        // Configure the cell...
        
        return cell
    }
    
   
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.notetable.dataSource = self;
        self.notetable.delegate = self;
        if let savedBooks = loadBooks() {
            books += savedBooks
        }
        if let savedNotes = loadNotes() {
            notes += savedNotes
        }
       // bookimage.image = UIImage(named: Book[myIndex])
        let book = books[myIndex]
        curentbookindex = book.bookindex
        authorname.text = book.author
        bookimage.image = book.image
        booktitle.text = book.title
        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NoteViewController, let note = sourceViewController.note {
            if let selectedIndexPath = notetable.indexPathForSelectedRow {
                notes[selectedIndexPath.row] = note
                notetable.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: notes.count, section: 0)
                
                notes.append(note)
                notetable.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveNotes()
            
        }
    }
    private func saveNotes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(notes, toFile: Note.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Notes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save notes...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadBooks() -> [Book]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Book.ArchiveURL.path) as? [Book]
    }
    
    private func loadNotes() -> [Note]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Note.ArchiveURL.path) as? [Note]
    }
}
    
  

