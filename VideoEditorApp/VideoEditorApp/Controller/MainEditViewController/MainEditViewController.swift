//
//  MainEditViewController.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit
import AVKit
import AVFoundation

class MainEditViewController: UIViewController {

    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoRangeSliderCollectionView: UICollectionView!
    
    // variable Declartion
    var orginalVideoURL: URL?
    var playerController = AVPlayerViewController()
    var player: AVPlayer?
    var menuList = ["Trim", "Volume", "Speed", "Filters", "AVMarge", "Effect", "Sticker"]
    var frames:[UIImage] = []
    private var generator:AVAssetImageGenerator!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        addVideoPlayer(videoURL: orginalVideoURL!)
    }
   
    // MARK: - Private Methods.
    func setupUI(){
        
    }
    
    func setupCollectionView(){
        let nib = UINib(nibName: "MenuCollectionViewCell", bundle: nil)
        menuCollectionView.register(nib, forCellWithReuseIdentifier: "cell")
        menuCollectionView.delegate = self
        menuCollectionView.dataSource  = self
    }
    
    public func addVideoPlayer(videoURL: URL) {
        player = AVPlayer(url: videoURL)
        playerController.player = self.player
        playerController.view.frame = self.videoView.frame
        self.videoView.addSubview(playerController.view)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height: videoView.frame.height)
        player?.play()
    }
    
    func videoSaveAndShare(url: URL) {
        /// Save PDF file
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(UUID())").appendingPathExtension("mp4")
        else { fatalError("Destination URL not created") }
        
        if let data = NSData(contentsOf: url as URL) {
            do {
                // writes the image data to disk
                try data.write(to: outputURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
                    
        if FileManager.default.fileExists(atPath: outputURL.path){
            let url = URL(fileURLWithPath: outputURL.path)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            //If user on iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                }
            }
            
            //present(activityViewController, animated: true, completion: nil)
            present(activityViewController, animated: true)
            
            activityViewController.completionWithItemsHandler = { activity, success, items, error in
                //print("activity: \(String(describing: activity)), success: \(success), items: \(String(describing: items)), error: \(error)")
                if activity == nil {
                    guard ((try? FileManager.default.removeItem(at: url)) != nil) else { return }
                }
            }
        } else {
            print("document was not found")
        }
    }
    
    // MARK: - Button Action.
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        videoSaveAndShare(url: orginalVideoURL!)
    }

}

// MARK: - Menu Collection View Datasorce & Delegate Methods
extension MainEditViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MenuCollectionViewCell
        cell.configure(icon: UIImage(named: menuList[indexPath.row])!, name: menuList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Trim")
            trim()

        case 1:
            print("Volume")
            volume()
            
        case 2:
            print("Speed")
            speed()
            
        case 3:
            print("Filters")
            filter()
            
        case 4:
            print("AVMarge")
            avMarge()
            
        case 5:
            print("Effect")
            effect()
        
        default:
            print("Sticker")
            sticker()
        }
    }
}

extension MainEditViewController {
    func trim(){
        let storyboard = UIStoryboard(name: "TrimViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TrimViewController") as! TrimViewController
        vc.delegate = self
        vc.videoUrl = orginalVideoURL
        self.add(vc, frame: self.view.bounds, contentView: self.view)
        UIView.animate(withDuration: 0.3) {
            vc.containerView.frame.origin.y = -623 //646
        }
        player?.pause()
    }
    
    func volume(){
    }
    
    func speed(){
        let storyboard = UIStoryboard(name: "SpeedViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SpeedViewController") as! SpeedViewController
        vc.delegate = self
        vc.videoUrl = orginalVideoURL
        self.add(vc, frame: self.view.bounds, contentView: self.view)
        UIView.animate(withDuration: 0.3) {
            vc.containerView.frame.origin.y = -623 //646
        }
        player?.pause()
    }
    
    func filter(){
        let storyboard = UIStoryboard(name: "FilterViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FilterViewController") as! FilterViewController
        vc.delegate = self
        vc.videoUrl = orginalVideoURL
        self.add(vc, frame: self.view.bounds, contentView: self.view)
        UIView.animate(withDuration: 0.3) {
            vc.containerView.frame.origin.y = -623 //646
        }
        player?.pause()
    }
    
    func avMarge(){
        let storyboard = UIStoryboard(name: "AVMargeViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AVMargeViewController") as! AVMargeViewController
        vc.delegate = self
        self.add(vc, frame: self.view.bounds, contentView: self.view)
        UIView.animate(withDuration: 0.3) {
            vc.containerView.frame.origin.y = -623 //646
        }
        player?.pause()
    }
    
    func effect(){
    }
    
    func sticker(){
        let storyboard = UIStoryboard(name: "StickerViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "StickerViewController") as! StickerViewController
//        vc.delegate = self
        vc.videoUrl = orginalVideoURL
        self.add(vc, frame: self.view.bounds, contentView: self.view)
        UIView.animate(withDuration: 0.3) {
            vc.containerView.frame.origin.y = -623 //646
        }
        player?.pause()
    }
}

// CropVideo Delegate
extension MainEditViewController: TrimDelegate {
    func trimViedo(_ url: URL) {
        orginalVideoURL = url
        let item = AVPlayerItem(url: orginalVideoURL!)
        player?.replaceCurrentItem(with: item)
    }
}

// Filter Delegate
extension MainEditViewController: FilterDelegate {
    func filterdVideo(_ url: URL) {
        orginalVideoURL = url
        let item = AVPlayerItem(url: orginalVideoURL!)
        player?.replaceCurrentItem(with: item)
    }
}

// Speed Delegate
extension MainEditViewController: SpeedDelegate {
    func speedVideo(_ url: URL) {
        orginalVideoURL = url
        let item = AVPlayerItem(url: orginalVideoURL!)
        player?.replaceCurrentItem(with: item)
    }
}

// avMarge Delegate
extension MainEditViewController: avMargeDelegate {
    func avMarge(_ url: URL) {
        orginalVideoURL = url
        let item = AVPlayerItem(url: orginalVideoURL!)
        player?.replaceCurrentItem(with: item)
    }
}














//extension MainEditViewController {
//    func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
//        DispatchQueue.global().async {
//            let asset = AVAsset(url: url)
//            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
//            avAssetImageGenerator.appliesPreferredTrackTransform = true
//            let thumnailTime = CMTimeMake(value: 2, timescale: 1)
//            do {
//                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
//                let thumbImage = UIImage(cgImage: cgThumbImage)
//                DispatchQueue.main.async {
//                    completion(thumbImage)
//                }
//            } catch {
//                print(error.localizedDescription)
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            }
//        }
//    }
//}
//
//// get all frames
//extension MainEditViewController {
//    func getAllFrames() {
//        let asset:AVAsset = AVAsset(url:self.orginalVideoURL!)
//        let duration:Float64 = CMTimeGetSeconds(asset.duration)
//        self.generator = AVAssetImageGenerator(asset:asset)
//        self.generator.appliesPreferredTrackTransform = true
//        self.frames = []
//        for index:Int in 0 ..< Int(duration) {
//            self.getFrame(fromTime:Float64(index))
//        }
//        self.generator = nil
//    }
//
//    private func getFrame(fromTime:Float64) {
//        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
//        let image:CGImage
//        do {
//            try image = self.generator.copyCGImage(at:time, actualTime:nil)
//        } catch {
//            return
//        }
//        self.frames.append(UIImage(cgImage:image))
//    }
//}
