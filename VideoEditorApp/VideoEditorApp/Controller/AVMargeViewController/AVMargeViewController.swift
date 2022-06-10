//
//  AVMargeViewController.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit
import AVKit
import AVFoundation
import AssetsLibrary

protocol avMargeDelegate {
    func avMarge(_ url: URL)
}

class AVMargeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    var share = VideoEditorManager()
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectVideoButton: UIButton!
    @IBOutlet weak var selectAudioButton: UIButton!
    @IBOutlet weak var audioFileName: UILabel!
        
    var selectVideoUrl: URL?
    var selectAudioUrl: URL?

    var videoTotalsec = 0.0
    var audioTotalsec = 0.0
    var pickedFileName: String = ""
    var mergeslidermaximumValue : Double = 0.0
    var mergesliderminimumValue : Double = 0.0
    var delegate: avMargeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Private Methods.
    func setupUI(){
        selectVideoButton.layer.cornerRadius = 20
        selectAudioButton.layer.cornerRadius = 20
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let movieUrl = info[.mediaURL] as? URL else { return }
        print(movieUrl)
        selectVideoUrl = movieUrl
        
        let thumbImg = share.generateThumbnail(path: movieUrl)
        self.selectVideoButton.setBackgroundImage(thumbImg, for: .normal)
    }
    
    func mergeVideoWithAudio(videoUrl: URL, audioUrl: URL){
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        
        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)
            
            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                    try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                    
                } catch{
                    print(error)
                }
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration)
            }
        }
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)
        
        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("fileName").m4v")
            
            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch { }
            
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: { [self] in
                    switch exportSession.status {
                    case .failed:
                        if exportSession.error != nil {
                            print("error")
                        }
                        
                    case .cancelled:
                        if exportSession.error != nil {
                            print("error")
                        }
                        
                    default:
                        print("finished")
                        print("avMarge URL--", outputURL)
                        if let delegate = delegate {
                            delegate.avMarge(outputURL)
                        }
                    }
                })
            } else {
                // failure(nil)
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
    
    @IBAction func addVideoButtonAction(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func addAudioButtonAction(_ sender: UIButton) {
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.audio","public.mp3","public.mpeg-4-audio","public.aifc-audio","public.aiff-audio"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func avMargeDoneButtonAction(_ sender: UIButton) {
        guard let videoURL = selectVideoUrl else { return }
        guard let audioURL = selectAudioUrl else { return }
        mergeVideoWithAudio(videoUrl: videoURL, audioUrl: audioURL)
        
        UIView.animate(withDuration: 0.3) {
            self.containerView.frame.origin.y = 896
        } completion: { [self] (finished) in
            if finished{
                self.remove()
            }
        }
    }
    
}

// MARK: - Mp3 Document Picker
extension AVMargeViewController : UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if(urls.count > 0) {
                let asset = AVAsset(url: urls.first!)
                self.audioTotalsec = CMTimeGetSeconds(asset.duration)
                self.pickedFileName =  urls.first!.lastPathComponent
                self.selectAudioUrl = urls.first!
                audioFileName.text = self.pickedFileName
                self.mergeslidermaximumValue = self.audioTotalsec
            }
        }
    }
}
