//
//  SpeedViewController.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit

protocol SpeedDelegate {
    func speedVideo(_ url: URL)
}

class SpeedViewController: UIViewController {

    let share = VideoEditorManager()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoSpeedRateCollectionView: UICollectionView!
    
    var selectedSpeed = ""
    var timer = Timer()
    var progressValue = 0.1
    var videoUrl: URL?
    var delegate: SpeedDelegate?
    var selectedRow = -1

    var speedRate = ["0.25", "0.5", "0.75", "1.0", "1.25", "1.5", "2.0", "2.5", "3.0", "3.5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpeedRateCollectionView()
    }
    
    // MARK: - Private Methods.
    func setupSpeedRateCollectionView() {
        let nib = UINib(nibName: "SpeedCollectionViewCell", bundle: nil)
        videoSpeedRateCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        videoSpeedRateCollectionView.delegate = self
        videoSpeedRateCollectionView.dataSource = self
    }
    
    //MARK : Timer
    func setTimer()  {
        timer.fire()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(updateProgressValue), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressValue() {
        DispatchQueue.main.async {
            self.progressValue += 0.05
            if self.progressValue < 0.9 {
//                self.progress_Vw.progress = Float(self.progress_value)
            }else{
                self.timer.invalidate()
            }
        }
    }
    
    private func vidoeSpeedRate(){
        if videoUrl != nil {
            if selectedSpeed.count > 0 {
                self.setTimer()
                let num = selectedSpeed.toDouble()
                share.videoScaleAssetSpeed(fromURL: videoUrl!, by: num ?? 1.0, success: { (speedUrl) in
                    DispatchQueue.main.async { [self] in
                        UIView.animate(withDuration: 0.3) {
                            self.containerView.frame.origin.y = 896
                        } completion: { [self] (finished) in
                            if finished{
                                print(speedUrl)
                                if let delegate = delegate {
                                    delegate.speedVideo(speedUrl)
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
    
    @IBAction func speedDoneButtonAction(_ sender: UIButton) {
        vidoeSpeedRate()
    }
    
}

// MARK: - CollectionView Datasource & Delegate Methods.
extension SpeedViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return speedRate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = videoSpeedRateCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SpeedCollectionViewCell
        cell.speedNumber.text = speedRate[indexPath.row]
        
        if selectedRow == indexPath.row {
            cell.bgView.backgroundColor = .green
        }
        else {
            cell.bgView.backgroundColor = .white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedRow == indexPath.row {
            selectedRow = -1
        } else {
            selectedRow = indexPath.row
        }
        
        print("selected item: \(indexPath.row)")
        selectedSpeed = speedRate[indexPath.row]
        videoSpeedRateCollectionView.reloadData()
    }
}

//MARK : String exiension
public extension String {
    public func toFloat() -> Float? {
        return Float.init(self)
    }
    
    public func toDouble() -> Double? {
        return Double.init(self)
    }
}
