//
//  MenuCollectionViewCell.swift
//  VideoEditorApp
//
//  Created byMD Tarif khan on 28/3/22.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(icon: UIImage, name: String){
        menuImageView.image = icon
        menuName.text = name
    }

}
