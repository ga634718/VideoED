import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import ZKProgressHUD

class TrimmerViewController: AssetSelectionVideoViewController {
    
    @IBOutlet weak var selectAssetButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var path:NSURL!
    var delegate: TransformCropVideoDelegate!
    var trimURL: URL!
    var isSave = false
    
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
        if isSave {
            delegate.transformTrimVideo(url: trimURL)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func duplicate(_ sender: Any) {
        player?.pause()
        isSave = true
        
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        
        //CutVideo
        let zero = 0
        let st = CGFloat(CMTimeGetSeconds(trimmerView.startTime!))
        let st1 = CGFloat(CMTimeGetSeconds(trimmerView.endTime!))
        let end = CGFloat(CMTimeGetSeconds((player?.currentItem?.asset.duration)! - trimmerView.endTime!))
        let curr = CGFloat(CMTimeGetSeconds((player?.currentItem?.asset.duration)!))
        
        let url = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: url)
        let url2 = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: url2)
        let final = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: final)
        if st == 0 {
            
            let cut2 = "-ss \(st1) -i \(filePath) -to \(end) -c copy \(final)"
            
            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                MobileFFmpeg.execute(cut2)
                self.trimURL = final
                self.isSave = true
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss(0.5)
                    ZKProgressHUD.showSuccess()
                }
            }
            
        } else if st1 == curr {
            
            let cut2 = "-ss \(zero) -i \(filePath) -to \(st) -c copy \(final)"
            
            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                MobileFFmpeg.execute(cut2)
                self.trimURL = final
                self.isSave = true
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss(0.5)
                    ZKProgressHUD.showSuccess()
                }
            }
        } else {
            
            let cut = "-ss \(zero) -i \(filePath) -to \(st) -c copy \(url)"
            let cut2 = "-ss \(st1) -i \(filePath) -to \(end) -c copy \(url2)"
            let cut3 = "-i \(url) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] concat=n=2:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                MobileFFmpeg.execute(cut)
                MobileFFmpeg.execute(cut2)
                MobileFFmpeg.execute(cut3)
                self.trimURL = final
                self.isSave = true
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss(0.5)
                    ZKProgressHUD.showSuccess()
                }
            }
        }
    }
    
    @IBAction func play(_ sender: Any) {
        
        guard let player = player else { return }
        
        if !player.isPlaying {
            player.play()
            (sender as AnyObject).setImage(UIImage(named: "Pause"), for: UIControl.State.normal)
            startPlaybackTimeChecker()
        } else {
            (sender as AnyObject).setImage(UIImage(named: "Play"), for: UIControl.State.normal)
            player.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    override func loadAsset(_ asset: AVAsset) {
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

extension TrimmerViewController: TrimmerViewDelegate {
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
