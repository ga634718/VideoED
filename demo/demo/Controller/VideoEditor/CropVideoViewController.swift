import UIKit
import Photos
import PryntTrimmerView
import AVFoundation
import AVKit
import ZKProgressHUD

protocol TransformCropVideoDelegate {
    func transformCropVideo(url: URL)
    func transformTrimVideo(url: URL)
    func transformDuration(url: URL)
    func transformBackground(url: URL)
    func transformReal(url: URL)
    func transformDuplicate(url: URL)
}

class CropVideoViewController: AssetSelectionVideoViewController {
    
    @IBOutlet weak var videoCropView: VideoCropView!
    @IBOutlet weak var selectThumbView: ThumbSelectorView!
    @IBOutlet weak var selectRatio: UICollectionView!
    
    
    var player: AVPlayer?
    var path : NSURL!
    var cropURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var array = [RatioCrop]()
    var newRatio: CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       selectRatio.register(UINib(nibName: "CropCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CropCollectionViewCell")
        array.append(RatioCrop(ratio: "1:1"))
        array.append(RatioCrop(ratio: "4:5"))
        array.append(RatioCrop(ratio: "16:9"))
        array.append(RatioCrop(ratio: "9:16"))
        array.append(RatioCrop(ratio: "3:4"))
        array.append(RatioCrop(ratio: "4:3"))
        array.append(RatioCrop(ratio: "2:3"))
        array.append(RatioCrop(ratio: "3:2"))
        array.append(RatioCrop(ratio: "2:1"))
        array.append(RatioCrop(ratio: "1:2"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoCropView.setAspectRatio(CGSize(width: 16, height: 9), animated: false)
        let asset = AVAsset(url: path as URL)
        loadAsset(asset)
    }
    
    @IBAction func back(_ sender: Any) {
        player = nil
        clearTempDirectory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        if isSave {
            delegate.transformCropVideo(url: cropURL)
        }
        self.navigationController?.popViewController(animated: true)
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
        
        
        let final = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: final)
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        let crop = "-i \(filePath) -vf \"crop=\(w):\(h):\(x):\(y)\" \(final)"
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.async {
            MobileFFmpeg.execute(crop)
            self.cropURL = final
            self.isSave = true
            
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss(0.5)
                ZKProgressHUD.showSuccess()
                self.path = self.cropURL as NSURL?
                let videoCrop = AVAsset(url: self.path as URL)
                self.loadAsset(videoCrop)
            }       
        }
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

    override func loadAsset(_ asset: AVAsset) {
          videoCropView.asset = asset
           selectThumbView.asset = asset
           selectThumbView.delegate = self
       }
    
}

extension CropVideoViewController: ThumbSelectorViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return array.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CropCollectionViewCell", for: indexPath) as! CropCollectionViewCell
       let data = array[indexPath.row]
    cell.initView(ratio: data.ratio)
       return cell
   }
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width:collectionView.frame.width/6.1, height: collectionView.frame.height/1.5)
   }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            newRatio = CGSize(width: 1, height: 1)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 1:
            newRatio = CGSize(width: 4, height: 5)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 2:
            newRatio = CGSize(width: 16, height: 9)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 3:
            newRatio = CGSize(width: 9, height: 16)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 4:
            newRatio = CGSize(width: 3, height: 4)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 5:
            newRatio = CGSize(width: 4, height: 3)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 6:
            newRatio = CGSize(width: 2, height: 3)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 7:
            newRatio = CGSize(width: 3, height: 2)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 8:
            newRatio = CGSize(width: 2, height: 1)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        case 9:
            newRatio = CGSize(width: 1, height: 2)
            videoCropView.setAspectRatio(newRatio!, animated: true)
        default:
            print(indexPath.row)
       }
   }
    
   
    
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
