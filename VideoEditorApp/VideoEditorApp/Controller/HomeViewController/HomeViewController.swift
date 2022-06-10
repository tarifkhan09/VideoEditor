//
//  HomeViewController.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var pluseBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods.
    func setupUI(){
        pluseBackgroundView.layer.cornerRadius = 10
        pluseBackgroundView.layer.shadowColor = UIColor.gray.cgColor
        pluseBackgroundView.layer.shadowOpacity = 0.3
        pluseBackgroundView.layer.shadowOffset = CGSize.zero
        pluseBackgroundView.layer.shadowRadius = 6
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let movieUrl = info[.mediaURL] as? URL else { return }
        print(movieUrl)
                
        let storyboard = UIStoryboard(name: "MainEditViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainEditViewController") as! MainEditViewController
        vc.orginalVideoURL = movieUrl
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - Button Action.
    @IBAction func pluseButtonAction(_ sender: UIButton) {
        var imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
}
