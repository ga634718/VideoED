import UIKit
import Photos
import PryntTrimmerView
import AVFoundation
import AVKit
import ZKProgressHUD

class CropVideoViewController: AssetSelectionVideoViewController {
    
    @IBOutlet weak var videoCropView: VideoCropView!
    @IBOutlet weak var selectThumbView: ThumbSelectorView!
    var path : NSURL!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        load()
        videoCropView.setAspectRatio(CGSize(width: 3, height: 2), animated: false)
    }
    @IBAction func back(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    @IBAction func selectAsset(_ sender: Any) {
        let asset = AVAsset(url: path as URL)
        videoCropView.asset = asset
        selectThumbView.asset = asset
        selectThumbView.delegate = self
    }
    func load() {
        let asset = AVAsset(url: path as URL)
        videoCropView.asset = asset
        selectThumbView.asset = asset
        selectThumbView.delegate = self
    }
 
    
    @IBAction func rotate(_ sender: Any) {
        
        let newRatio = videoCropView.aspectRatio.width < videoCropView.aspectRatio.height ? CGSize(width: 9, height: 16) :
            CGSize(width: 3, height: 4)
        videoCropView.setAspectRatio(newRatio, animated: true)
    }
    
    @IBAction func crop(_ sender: Any) {
        
        //        if let selectedTime = selectThumbView.selectedTime, let asset = videoCropView.asset {
        //            let generator = AVAssetImageGenerator(asset: asset)
        //            generator.requestedTimeToleranceBefore = CMTime.zero
        //            generator.requestedTimeToleranceAfter = CMTime.zero
        //            generator.appliesPreferredTrackTransform = true
        //            var actualTime = CMTime.zero
        //            let image = try? generator.copyCGImage(at: selectedTime, actualTime: &actualTime)
        //            if let image = image {
        //                let selectedImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
        //                let croppedImage = selectedImage.crop(in: videoCropView.getImageCropFrame())!
        //                UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        //            }
        try? prepareAssetComposition()
        
        //        }
    }
    
    func prepareAssetComposition() throws {
        
        guard let asset = videoCropView.asset, let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first else {
            return
        }
        
        let assetComposition = AVMutableComposition()
        let frame1Time = CMTime(seconds: 0.2, preferredTimescale: asset.duration.timescale)
        let trackTimeRange = CMTimeRangeMake(start: .zero, duration: frame1Time)
        
        guard let videoCompositionTrack = assetComposition.addMutableTrack(withMediaType: .video,
                                                                           preferredTrackID: kCMPersistentTrackID_Invalid) else {
                                                                            return
        }
        
        try videoCompositionTrack.insertTimeRange(trackTimeRange, of: videoTrack, at: CMTime.zero)
        
        if let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first {
            let audioCompositionTrack = assetComposition.addMutableTrack(withMediaType: AVMediaType.audio,
                                                                         preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(trackTimeRange, of: audioTrack, at: CMTime.zero)
        }
        
        let cropFrame = videoCropView.getImageCropFrame()
        
        let w = cropFrame.width
        let h = cropFrame.height
        let x = cropFrame.minX
        let y = cropFrame.minY
        
        
        let furl = createUrlInApp(name: "VDCROP.MOV")
        removeFileIfExists(fileURL: furl)
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        let crop = "-i \(filePath) -vf \"crop=\(w):\(h):\(x):\(y)\" \(furl)"
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.async {
            MobileFFmpeg.execute(crop)
            CustomPhotoAlbum.sharedInstance.saveVideo(url: furl)
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showSuccess()
            }       
        }
    }
    
    private func getTransform(for videoTrack: AVAssetTrack) -> CGAffineTransform {
        
        let renderSize = CGSize(width: 16 * videoCropView.aspectRatio.width * 18,
                                height: 16 * videoCropView.aspectRatio.height * 18)
        let cropFrame = videoCropView.getImageCropFrame()
        let renderScale = renderSize.width / cropFrame.width
        let offset = CGPoint(x: -cropFrame.origin.x, y: -cropFrame.origin.y)
        let rotation = atan2(videoTrack.preferredTransform.b, videoTrack.preferredTransform.a)
        
        var rotationOffset = CGPoint(x: 0, y: 0)
        
        if videoTrack.preferredTransform.b == -1.0 {
            rotationOffset.y = videoTrack.naturalSize.width
        } else if videoTrack.preferredTransform.c == -1.0 {
            rotationOffset.x = videoTrack.naturalSize.height
        } else if videoTrack.preferredTransform.a == -1.0 {
            rotationOffset.x = videoTrack.naturalSize.width
            rotationOffset.y = videoTrack.naturalSize.height
        }
        
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: renderScale, y: renderScale)
        transform = transform.translatedBy(x: offset.x + rotationOffset.x, y: offset.y + rotationOffset.y)
        transform = transform.rotated(by: rotation)
        
        
        print("track size \(videoTrack.naturalSize)")
        print("preferred Transform = \(videoTrack.preferredTransform)")
        print("rotation angle \(rotation)")
        print("rotation offset \(rotationOffset)")
        print("actual Transform = \(transform)")
        return transform
    }
    func createUrlInApp(name: String ) -> URL {
        return URL(fileURLWithPath: "\(NSTemporaryDirectory())\(name)")
    }

    func removeFileIfExists(fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
}

extension CropVideoViewController: ThumbSelectorViewDelegate {
    
    func didChangeThumbPosition(_ imageTime: CMTime) {
        videoCropView.player?.seek(to: imageTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
    }
}

extension UIImage {
    
    func crop(in frame: CGRect) -> UIImage? {
        
        if let croppedImage = self.cgImage?.cropping(to: frame) {
            return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}
