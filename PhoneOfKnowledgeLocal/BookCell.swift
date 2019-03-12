//
//  BookCell.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 3/11/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit

class BookCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var ratingc: RatingControl!
    @IBOutlet weak var authorLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
