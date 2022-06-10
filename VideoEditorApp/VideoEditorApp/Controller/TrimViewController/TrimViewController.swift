//
//  TrimViewController.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit
import AVKit
import AVFoundation

protocol TrimDelegate {
    func trimViedo(_ url: URL)
}

class TrimViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var videoUrl: URL?
    var startTime = 0
    var endTime = 0
    var delegate: TrimDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSliderView()
    }
    
    // MARK: - Private Method
    func setupSliderView(){
        let kWidth: CGFloat = 300
        let rangeSlider = GZRangeSlider(frame: CGRect(x: 0.5 * (view.frame.width - kWidth),y: 64,width: kWidth,height: 120))
        
        let asset = AVAsset(url: videoUrl!)
        let duration = asset.duration.seconds
        
        rangeSlider.setRange(minRange: 0, maxRange: Int(duration), accuracy: 1)
        rangeSlider.valueChangeClosure = { [self]
            (left, right) -> () in
            print("left = \(left)  right = \(right) \n")
            
            startTime = left
            endTime = right
        }
        containerView.addSubview(rangeSlider)
    }
    
    func cropVideo(sourceURL1: URL, statTime:Float, endTime:Float){
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {return}
        let mediaType = "mp4"
        let asset = AVAsset(url: sourceURL1 as URL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        let start = statTime
        let end = endTime
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(UUID().uuidString).\(mediaType)")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        
        let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously{ [self] in
            switch exportSession.status {
            case .completed:
                print("exported at \(outputURL)")
                if let delegate = delegate {
                    delegate.trimViedo(outputURL)
                }
            case .failed:
                print("failed \(String(describing: exportSession.error))")
                
            case .cancelled:
                print("cancelled \(String(describing: exportSession.error))")
                
            default: break
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
    
    @IBAction func cropDoneButtonAction(_ sender: UIButton) {
        DispatchQueue.main.async { [self] in
            cropVideo(sourceURL1: videoUrl!, statTime: Float(startTime), endTime: Float(endTime))
            
            UIView.animate(withDuration: 0.3) {
                self.containerView.frame.origin.y = 896
            } completion: { (finished) in
                if finished{
                    self.remove()
                }
            }
        }
    }
    
}
