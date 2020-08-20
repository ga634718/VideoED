import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import ZKProgressHUD

class DurationVideoController: UIViewController {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var LblStartTime: UILabel!
    @IBOutlet weak var LblEndTime: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    
    var player = AVPlayer()
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var path:NSURL!
    var rate: Float!
    var delegate: TransformCropVideoDelegate!
    var url: URL!
    var isSave = false
    var counter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeSlider(sliderName: slider)
        rate = 1
        player.pause()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let asset = AVAsset(url: path as URL)
        loadAsset(asset)
        setlabel()
    }
    
    @IBAction func back(_ sender: Any) {
        player.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func changeSpeed(_ sender: UISlider) {
        slider.value = roundf(slider.value)
        rate = slider.value * 0.1
        player.rate = rate
        playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        startPlaybackTimeChecker()
    }
    
    @IBAction func save(_ sender: Any) {
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        player.pause()
        isSave = true
        
        let furl = createUrlInApp(name: "audio.MOV")
        removeFileIfExists(fileURL: furl)
        let furl2 = createUrlInApp(name: "video.MOV")
        removeFileIfExists(fileURL: furl2)
        let final = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: final)
        
        //SpeeđAuio
        let audio = "-i \(filePath) -filter_complex \"[0:v]setpts=1/\(rate!)*PTS[v];[0:a]atempo=\(rate!)[a]\" -map \"[v]\" -map \"[a]\" \(furl)"
        
        //SpeedVideo
        let newrate = 1/rate!
        let video = "-itsscale \(newrate) -i \(filePath) -c copy \(furl2)"
        
        //graft
        let speed = "-i \(furl2) -i \(furl) -c copy -map 0:v -map 1:a \(final)"
        
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.async {
            MobileFFmpeg.execute(audio)
            MobileFFmpeg.execute(video)
            MobileFFmpeg.execute(speed)
            self.removeFileIfExists(fileURL: furl)
            self.removeFileIfExists(fileURL: furl2)
            self.url = final
            self.isSave = true
            self.delegate.transformDuration(url: self.url!)
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss(0.5)
                ZKProgressHUD.showSuccess()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func changeIconBtnPlay() {
        if player.isPlaying {
            playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        }
    }
    
    @IBAction func play(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            stopPlaybackTimeChecker()
        } else {
            player.play()
            player.rate = rate
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
    }
    
    
    func loadAsset (_ asset: AVAsset) {
        addVideoPlayer(with: asset, playerView: playerView)
        trimmerView.asset = asset
        trimmerView.delegate = self
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
//        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player.seek(to: startTime)
        }
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
    }
    
    func createUrlInApp(name: String ) -> URL {
        return URL(fileURLWithPath: "\(NSTemporaryDirectory())\(name)")
    }
    
    func setlabel() {
        LblStartTime.text = trimmerView.startTime?.positionalTime
        LblEndTime.text = trimmerView.endTime?.positionalTime
    }
    
    func removeFileIfExists(fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    func customizeSlider(sliderName:UISlider) {
        // change UIbutton propertie
        let color = (UIColor(red: 252/255, green: 186/255, blue: 3/255, alpha: 1.0))
        
        slider.layer.cornerRadius = 10
        slider.layer.borderWidth = 0.8
        slider.layer.borderColor = color.cgColor
        
        slider.layer.shadowColor = color.cgColor
        slider.layer.shadowOpacity = 0.8
        slider.layer.shadowRadius = 7
        slider.layer.shadowOffset = CGSize(width: 1, height: 1)
        
    }

    func startPlaybackTimeChecker() {
        
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(TrimmerViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
//    @objc func onPlaybackTimeChecker() {
//
//        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
//            return
//        }
//
//        let playBackTime = player.currentTime()
//        trimmerView.seek(to: playBackTime)
//
//        if playBackTime >= endTime {
//            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
//            trimmerView.seek(to: startTime)
//        }
//    }
//}
    @objc func onPlaybackTimeChecker() {
        guard let start = trimmerView.startTime, let end = trimmerView.endTime else {
            return
        }
        
        let playbackTime = player.currentTime()
        trimmerView.seek(to: playbackTime)
        
        if playbackTime >= end {
            player.seek(to: start, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: start)
        }
    }
}

extension DurationVideoController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        
        player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        startPlaybackTimeChecker()
        setlabel()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        player.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        setlabel()
    }
}
