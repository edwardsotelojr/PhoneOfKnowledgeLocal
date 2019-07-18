//
//  NotesCell.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/12/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {
    @IBOutlet weak var notetext: UILabel!
    @IBOutlet weak var pageNumber: UILabel!
    @IBOutlet weak var imagesStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
