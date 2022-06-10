//
//  VideoEditorManager.swift
//  VideoEditorApp
//
//  Created by MD Tarif khan on 28/3/22.
//

import UIKit
import AVFoundation
import MobileCoreServices
import AVKit
import Photos

class VideoEditorManager: NSObject {
        
    func deleteFile(_ filePath:URL) {
        guard FileManager.default.fileExists(atPath: filePath.path) else { return }
        do {
            try FileManager.default.removeItem(atPath: filePath.path)
        }catch{
            fatalError("Unable to delete file: \(error) : \(#function).")
        }
    }
    
    //-------------------------------------------SpeedRate----------------------------------------------------//
    // MARK: - Update video speed
    func videoScaleAssetSpeed(fromURL url: URL,  by scale: Float64, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        /// Asset
        let asset = AVPlayerItem(url: url).asset
        
        // Composition Audio Video
        let mixComposition = AVMutableComposition()
        
        //TotalTimeRange
        let timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        /// Video Tracks
        let videoTracks = asset.tracks(withMediaType: AVMediaType.video)
        if videoTracks.count == 0 {
            /// Can not find any video track
            return
        }
        
        /// Video track
        let videoTrack = videoTracks.first!
        
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        /// Audio Tracks
        let audioTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if audioTracks.count > 0 {
            /// Use audio if video contains the audio track
            let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            /// Audio track
            let audioTrack = audioTracks.first!
            do {
                try compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: CMTime.zero)
                let destinationTimeRange = CMTimeMultiplyByFloat64(asset.duration, multiplier:(1/scale))
                compositionAudioTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
                
                compositionAudioTrack?.preferredTransform = audioTrack.preferredTransform
                
            } catch _ {
                /// Ignore audio error
            }
        }
        
        do {
            try compositionVideoTrack?.insertTimeRange(timeRange, of: videoTrack, at: CMTime.zero)
            let destinationTimeRange = CMTimeMultiplyByFloat64(asset.duration, multiplier:(1/scale))
            compositionVideoTrack?.scaleTimeRange(timeRange, toDuration: destinationTimeRange)
            
            /// Keep original transformation
            compositionVideoTrack?.preferredTransform = videoTrack.preferredTransform
            
            //Create Directory path for Save
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            var outputURL = documentDirectory.appendingPathComponent("SpeedVideo")
            do {
                try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
                outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
            }catch let error {
                failure(error.localizedDescription)
            }
            
            //Remove existing file
            self.deleteFile(outputURL)
            
            //export the video to as per your requirement conversion
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed :
                        success(outputURL)
                    case .failed:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    case .cancelled:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    default:
                        if let _error = exportSession.error?.localizedDescription {
                            failure(_error)
                        }
                    }
                })
            } else {
                failure(nil)
            }
        } catch {
            // Handle the error
            failure("Inserting time range failed.")
        }
    }
    
    //-------------------------------------------Filters----------------------------------------------------//
    //MARK: Thumbnail Image generate
    func generateThumbnail(path: URL) -> UIImage? {
        // getting image from video
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            return nil
        }
    }
    
    //MARK: add filter to video placeholder image
    func convertImageToBW(filterName : String ,image:UIImage) -> UIImage {
        let filter = CIFilter(name: filterName)
        
        // convert UIImage to CIImage and set as input
        let ciInput = CIImage(image: image)
        filter?.setValue(ciInput, forKey: "inputImage")
        
        // get output CIImage, render as CGImage first to retain proper UIImage scale
        let ciOutput = filter?.outputImage
        let ciContext = CIContext()
        let cgImage = ciContext.createCGImage(ciOutput!, from: (ciOutput?.extent)!)
        return UIImage(cgImage: cgImage!)
    }
    
    //MARK: Add filter to video
    func addfiltertoVideo(strfiltername : String, strUrl : URL, success: @escaping ((URL) -> Void), failure: @escaping ((String?) -> Void)) {
        
        //FilterName
        let filter = CIFilter(name: strfiltername)
        
        //Asset
        let asset = AVAsset(url: strUrl)
        
        //Create Directory path for Save
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var outputURL = documentDirectory.appendingPathComponent("EffectVideo")
        do {
            try FileManager.default.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(outputURL.lastPathComponent).m4v")
        }catch let error {
            failure(error.localizedDescription)
        }
        
        //Remove existing file
        self.deleteFile(outputURL)
        
        //AVVideoComposition
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            
            // Clamp to avoid blurring transparent pixels at the image edges
            let source = request.sourceImage.clampedToExtent()
            filter?.setValue(source, forKey: kCIInputImageKey)
            
            // Crop the blurred output to the bounds of the original image
            let output = filter?.outputImage!.cropped(to: request.sourceImage.extent)
            
            // Provide the filter output to the composition
            request.finish(with: output!, context: nil)
            
        })
        
        //export the video to as per your requirement conversion
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exportSession.outputFileType = AVFileType.mov
        exportSession.outputURL = outputURL
        exportSession.videoComposition = composition
        
        exportSession.exportAsynchronously(completionHandler: {
            switch exportSession.status {
            case .completed:
                success(outputURL)
                
            case .failed:
                failure(exportSession.error?.localizedDescription)
                
            case .cancelled:
                failure(exportSession.error?.localizedDescription)
                
            default:
                failure(exportSession.error?.localizedDescription)
            }
        })
    }
    
    //-----------------------------------------------------------------------------------------------//
}

