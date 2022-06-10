//
//  StickerViewController.swift
//  VideoEditorApp
//
//  Created byMD Tarif khan on 28/3/22.
//

import UIKit

protocol StickerDelegate {
    func addStickerVideo(_ url: URL)
}

class StickerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!

    var videoUrl: URL?
    var delegate: StickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Private Methods.
    
    // MARK: - Button Action.
    @IBAction func crossButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.containerView.frame.origin.y = 896
        } completion: { (finished) in
            if finished{
                self.remove()
            }
        }
    }
    
}
