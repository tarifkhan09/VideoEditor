//
//  SpeedCollectionViewCell.swift
//  VideoEditorApp
//
//  Created byMD Tarif khan on 28/3/22.
//

import UIKit

class SpeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var speedNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.cornerRadius = 2
    }
    
}
