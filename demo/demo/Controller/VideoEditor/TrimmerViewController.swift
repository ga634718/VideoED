import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import ZKProgressHUD

class TrimmerViewController: AssetSelectionVideoViewController {
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var LblStartTime: UILabel!
    @IBOutlet weak var LblEndTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var player = AVPlayer()
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
        setlabel()
    }
    
    @IBAction func back(_ sender: Any) {
        player.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        if isSave {
            delegate.transformTrimVideo(url: trimURL)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func deleteVideo(_ sender: Any) {
        player.pause()
        isSave = true
        
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        //CutVideo
        let zero = 0
        let st = CGFloat(CMTimeGetSeconds(trimmerView.startTime!))
        let st1 = CGFloat(CMTimeGetSeconds(trimmerView.endTime!))
        let end = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)! - trimmerView.endTime!))
        let curr = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
        
        let url1 = createUrlInApp(name: "vdCut1.MOV")
        removeFileIfExists(fileURL: url1)
        let url2 = createUrlInApp(name: "vdCut2.MOV")
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
                    let asset = AVAsset(url: final as URL)
                    self.loadAsset(asset)
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
                    let asset = AVAsset(url: final as URL)
                    self.loadAsset(asset)
                }
            }
        } else {
            
            let cut = "-ss \(zero) -i \(filePath) -to \(st) -c copy \(url1)"
            let cut2 = "-ss \(st1) -i \(filePath) -to \(end) -c copy \(url2)"
            let cut3 = "-i \(url1) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] concat=n=2:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
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
                    let asset = AVAsset(url: final as URL)
                    self.loadAsset(asset)
                }
            }
        }
        
    }
    
    @IBAction func play(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            stopPlaybackTimeChecker()
        } else {
            player.play()
            startPlaybackTimeChecker()
        }
        changeIconBtnPlay()
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
        layer.backgroundColor = UIColor.black.cgColor
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
    
    func removeFileIfExists(fileURL: URL) {
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    func setlabel() {
        LblStartTime.text = trimmerView.startTime?.positionalTime
        LblEndTime.text = trimmerView.endTime?.positionalTime
    }
    
    func changeIconBtnPlay() {
         if player.isPlaying {
             playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
         } else {
             playButton.setImage(UIImage(named: "icon_play"), for: .normal)
         }
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

extension TrimmerViewController: TrimmerViewDelegate {
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
