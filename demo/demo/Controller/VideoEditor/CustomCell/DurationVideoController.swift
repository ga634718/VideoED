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
    
    
    var player: AVPlayer?
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
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let asset = AVAsset(url: path as URL)
        loadAsset(asset)
        trimmerView.asset = asset
        trimmerView.delegate = self
    }
    
    @IBAction func back(_ sender: Any) {
        player?.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        player?.pause()
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
    
    @IBAction func nomal(_ sender: UIButton) {
        rate = 1.0
        player?.rate = rate
    }
    
    @IBAction func backwardsPressed(_ sender: Any) {
        rate = 0.5
        player?.rate = rate
    }
    
    @IBAction func forwardPressed(_ sender: Any) {
        rate = 2.0
        player?.rate = rate
    }
    
    
    @IBAction func duplicate(_ sender: Any) {
        
    }
    
    func changeIconBtnPlay() {
        if player!.isPlaying {
            playButton.setImage(UIImage(named: "Pause"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "Play"), for: .normal)
        }
    }
    
    @IBAction func play(_ sender: Any) {
        
        if player!.isPlaying {
            player?.pause()
            stopPlaybackTimeChecker()
        } else {
            player?.play()
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
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
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
    func currentDate()->String{
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddhhmmss"
        return df.string(from: Date())
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
    
    @objc func onPlaybackTimeChecker() {
        
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
            trimmerView.seek(to: startTime)
        }
    }
}

extension DurationVideoController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        print(duration)
    }
}
