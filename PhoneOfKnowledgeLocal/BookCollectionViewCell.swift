//
//  BookCollectionViewCell.swift
//  PhoneOfKnowledgeLocal
//
//  Created by Edward Sotelo Jr on 7/26/19.
//  Copyright © 2019 Edward Sotelo Jr. All rights reserved.
//

import UIKit

class BookCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var numberOfNotes: UILabel!
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        layoutIfNeeded()
        title.preferredMaxLayoutWidth = title.bounds.size.width
        layoutAttributes.bounds.size.height = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        return layoutAttributes
    }

}
