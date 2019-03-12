//
//  NotesTableViewController.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/12/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit
import os.log

class NotesTableViewController: UITableViewController {
    var notes = [Note]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        if let savedNotes = loadNotes() {
             notes += savedNotes
        }
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
        return notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "notecell", for: indexPath) as? NotesCell else {
            fatalError("The dequeued cell is not an instance of Note table .")
        }
        let note = notes[indexPath.row]
        cell.notetext.text = note.notetext
        cell.noteimage.image = note.image
        // Configure the cell...
        
        return cell
    }
    
    @IBAction func unwindToNoteList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NoteViewController, let note = sourceViewController.note {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                notes[selectedIndexPath.row] = note
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: notes.count, section: 0)
                
                notes.append(note)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
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
    
    private func loadNotes() -> [Note]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Note.ArchiveURL.path) as? [Note]
    }
}

