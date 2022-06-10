//
//  FilterViewController.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit
import AVKit
import AVFoundation

protocol FilterDelegate {
    func filterdVideo(_ url: URL)
}

class FilterViewController: UIViewController {

    let share = VideoEditorManager()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var FilterCollectionView: UICollectionView!
    
    var videoUrl: URL?
    var filterSelcted = 100
    var selectedEffect = ""
    var delegate: FilterDelegate?
    var selectedRow = -1

    var CIFilterNames = ["CISharpenLuminance", "CIPhotoEffectChrome", "CIPhotoEffectFade", "CIPhotoEffectInstant", "CIPhotoEffectNoir",
        "CIPhotoEffectProcess", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CISepiaTone", "CIColorClamp", "CIColorInvert",
        "CIColorMonochrome", "CISpotLight", "CIColorPosterize", "CIBoxBlur", "CIDiscBlur", "CIGaussianBlur", "CIMaskedVariableBlur",
        "CIMedianFilter", "CIMotionBlur", "CINoiseReduction"
    ]
    
    var filterNames = ["Luminance","Chrome","Fade","Instant","Noir","Process","Tonal","Transfer","SepiaTone","ColorClamp","ColorInvert","ColorMonochrome","SpotLight","ColorPosterize","BoxBlur","DiscBlur","GaussianBlur","MaskedVariableBlur","MedianFilter","MotionBlur","NoiseReduction"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterCollectionView()
    }
    
    // MARK: - Private Methods.
    func setupFilterCollectionView() {
        let nib = UINib(nibName: "FilterCollectionViewCell", bundle: nil)
        FilterCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        FilterCollectionView.delegate = self
        FilterCollectionView.dataSource = self
    }
    
    private func videoFilter(){
        if videoUrl != nil {
            if selectedEffect.count > 0 {
                share.addfiltertoVideo(strfiltername: selectedEffect, strUrl: videoUrl!, success: { (videoFilterUrl) in
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.3) {
                            self.containerView.frame.origin.y = 896
                        } completion: { [self] (finished) in
                            if finished{
                                print(videoFilterUrl)
                                if let delegate = delegate {
                                    delegate.filterdVideo(videoFilterUrl)
                                }
                                self.remove()
                            }
                        }
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        print("error")
                    }
                }
            }
        }
    }
    
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
    
    @IBAction func filterDoneButtonAction(_ sender: UIButton) {
        videoFilter()
    }
    
}

// MARK: - Filter Collection View DataSource & Delegate Methods.
extension FilterViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = FilterCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterCollectionViewCell
        cell.filterName.text = filterNames[indexPath.row]
        
        let thumbnail = share.generateThumbnail(path: videoUrl!)
        let filterImg = share.convertImageToBW(filterName: CIFilterNames[indexPath.row], image: thumbnail!)
        cell.filterImageView.image = filterImg
        
        //-------------------------------
        if selectedRow == indexPath.row {
            cell.layer.borderColor = UIColor.white.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 10
        }
        else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("select filter - \(indexPath.row)")
        if selectedRow == indexPath.row {
            selectedRow = -1
        } else {
            selectedRow = indexPath.row
        }
        
        filterSelcted = indexPath.row
        selectedEffect = CIFilterNames[indexPath.row]
        FilterCollectionView.reloadData()
    }

}
