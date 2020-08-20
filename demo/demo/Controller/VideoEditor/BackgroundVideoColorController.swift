
import UIKit
import AVKit
import AVFoundation
import ZKProgressHUD
import AssetsLibrary
import Photos
import PryntTrimmerView

class BackgroundVideoColorController: UIViewController {
    @IBOutlet weak var collBgColor: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var player = AVPlayer()
    var arr2 = [ModelBackgroundColor]()
    var playerController = AVPlayerViewController()
    var str = ""
    var path:NSURL!
    var BgURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var ratio:CGFloat!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collBgColor.register(UINib(nibName: "BackgroundColorViewCell", bundle: nil), forCellWithReuseIdentifier: "BackgroundColorViewCell")
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 187/255, green: 187/255, blue: 187/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 136/255, green: 136/255, blue: 136/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 68/255, green: 68/255, blue: 68/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)))
         arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 17/255, green: 17/255, blue: 17/255, alpha: 1)))
         arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 250/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 221/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 204/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 187/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 170/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 153/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 136/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 119/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 102/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 85/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 68/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 51/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 34/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 17/255, green: 0/255, blue: 0/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 204/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 153/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 102/255, alpha: 1)))
        arr2.append(ModelBackgroundColor(uiColor: UIColor.init(red: 255/255, green: 255/255, blue: 51/255, alpha: 1)))
        
        
        
        let player = AVPlayer(url: path as URL)
        playerController.player = player
        playerController.showsPlaybackControls = false
        let asset = AVAsset(url: path as URL)
        let playerItem = AVPlayerItem(asset: asset)
        playerController.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height:  videoView.frame.height)
        self.videoView.addSubview(playerController.view)
        playerController.view.backgroundColor = nil
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ratio = getVideoRatio(url: path as URL)
    }
    
    @IBAction func back(_ sender: Any) {
        playerController.player?.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func play(_ sender: Any) {
        if playerController.player!.isPlaying {
            playerController.player?.pause()
            stopPlaybackTimeChecker()
        } else {
            playerController.player?.play()
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
    }
    
    func changeIconBtnPlay() {
        if playerController.player!.isPlaying {
            playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        playerController.player?.pause()
        if str == "" {
            self.navigationController?.popViewController(animated: true)
        } else {
            var s = ""
            let final = createUrlInApp(name: "\(currentDate()).MOV")
            removeFileIfExists(fileURL: final)
            
            if ratio == 1 {
                self.navigationController?.popViewController(animated: true)
            }
            else if ratio > 1{
                s = "-i \(filePath)  -aspect 1:1 -vf \"pad=iw:ih*\(ratio!):(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(final)"
            }
            else {
                s = "-i \(filePath)  -aspect 1:1 -vf \"pad=iw/\(ratio!):ih:(ow-iw)/2:(oh-ih)/2:color=\(self.str)\" \(final)"
            }
            
            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                MobileFFmpeg.execute(s)
                self.BgURL = final
                self.isSave = true
                self.delegate.transformBackground(url: self.BgURL!)
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss(0.5)
                    ZKProgressHUD.showSuccess()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
//    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
//        let playerItem = AVPlayerItem(asset: asset)
//        player = AVPlayer(playerItem: playerItem)
//        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
//        layer.backgroundColor = UIColor.white.cgColor
//        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
//        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
//        playerView.layer.addSublayer(layer)
//    }
    
    func getVideoRatio(url:URL) -> CGFloat{
        let size = resolutionSizeForLocalVideo(url: url)
        return size!.width/size!.height
    }
    
    func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
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
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BackgroundVideoColorController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        playerController.player!.seek(to: CMTime.zero)
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
    }
    
    @objc func onPlaybackTimeChecker() {
        
        let playbackTime = playerController.player!.currentTime()
        if playbackTime >= (playerController.player?.currentItem?.asset.duration)! {
            player.seek(to: CMTime.zero, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
}

extension BackgroundVideoColorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundColorViewCell", for: indexPath) as! BackgroundColorViewCell
        let data = arr2[indexPath.row]
        cell.initView(uiColor: data.uiColor )
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:collectionView.frame.width/15, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        playerController.view.backgroundColor = arr2[indexPath.row].uiColor
        switch indexPath.row {
        case 0: str = "EEEEEE"
        case 1: str = "DDDDDD"
        case 2: str = "CCCCCC"
        case 3: str = "BBBBBB"
        case 4: str = "AAAAAA"
        case 5: str = "999999"
        case 6: str = "888888"
        case 7: str = "777777"
        case 8: str = "666666"
        case 9: str = "555555"
        case 10: str = "444444"
        case 11: str = "333333"
        case 12: str = "222222"
        case 13: str = "111111"
        case 14: str = "000000"
        case 15: str = "FF0000"
        case 16: str = "DD0000"
        case 17: str = "CC0000"
        case 18: str = "BB0000"
        case 19: str = "AA0000"
        case 20: str = "990000"
        case 21: str = "880000"
        case 22: str = "770000"
        case 23: str = "660000"
        case 24: str = "550000"
        case 25: str = "440000"
        case 26: str = "330000"
        case 27: str = "220000"
        case 28: str = "110000"
        case 29: str = "FFFFFF"
        case 30: str = "FFFFCC"
        case 31: str = "FFFF99"
        case 32: str = "FFFF66"
        case 33: str = "FFFF33"
        case 34: str = "AAAAAA"
        case 35: str = "999999"
        case 36: str = "888888"
        case 37: str = "777777"
        case 38: str = "666666"
        case 39: str = "555555"
            
        default:
            print(indexPath.row)
        }
    }
}

