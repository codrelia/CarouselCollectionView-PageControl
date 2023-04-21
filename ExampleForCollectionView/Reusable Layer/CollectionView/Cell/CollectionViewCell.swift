//
//  CollectionViewCell.swift
//  App
//
//  Created by Дарья Шевченко on 14/04/2023.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .green.withAlphaComponent(0.5)
        layer.cornerRadius = 10
    }

}
