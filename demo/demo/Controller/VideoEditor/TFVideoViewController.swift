
import UIKit
import AVKit
import AVFoundation
import ZKProgressHUD


class TFVideoViewController: UIViewController {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var player = AVPlayer()
    var playerController = AVPlayerViewController()
    var currentAnimation = 0
    var currentAnimation2 = 0
    var str = ""
    var path:NSURL!
    var tfURL: URL!
    var isSave = false
    var delegate: TransformCropVideoDelegate!
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()      
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let player = AVPlayer(url: path as URL)
        playerController.player = player
        playerController.view.frame.size.height = videoView.frame.size.height
        playerController.view.frame.size.width = videoView.frame.size.width
        playerController.showsPlaybackControls = false
        let asset = AVAsset(url: path as URL)
        let playerItem = AVPlayerItem(asset: asset)
        playerController.player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(_:)),
        name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerController.view.frame = CGRect(x: 0, y: 0, width: videoView.frame.width, height:  videoView.frame.height)
        self.videoView.addSubview(playerController.view)
    }
    
    @IBAction func back(_ sender: Any) {
        playerController.player?.pause()
        clearTempDirectory()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        
        playerController.player?.pause()
        
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        let final = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: final)
        //\"transpose=1\"
        
        let transform = "-i \(filePath) -vf \(str) -codec:a copy \(final)"
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.async {
            MobileFFmpeg.execute(transform)
            self.tfURL = final
            self.isSave = true
            self.delegate.transformReal(url: self.tfURL!)
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss(0.5)
                ZKProgressHUD.showSuccess()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @IBAction func flip(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            switch self.currentAnimation{
            case 0:
                self.playerController.view.transform = .identity
                
                self.playerController.view.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.str = "\"hflip\""
            case 1:
                self.playerController.view.transform = .identity
                
            default:
                break
            }
        })
        currentAnimation += 1
        if currentAnimation > 1 {
            currentAnimation = 0
        }
    }
    
    @IBAction func turn(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            switch self.currentAnimation2{
            case 0:
                self.playerController.view.transform = .identity
                self.playerController.view.transform = CGAffineTransform(rotationAngle: .pi / -2)
                self.str = "\"transpose=2\""
            case 1:
                self.playerController.view.transform = CGAffineTransform(rotationAngle: .pi )
                self.str = "\"transpose=2,transpose=2\""
            case 2:
                self.playerController.view.transform = CGAffineTransform(rotationAngle: .pi / 2)
                self.str = "\"transpose=1\""
            case 3:
                self.playerController.view.transform = .identity
            default:
                break
            }
        })
        currentAnimation2 += 1
        if currentAnimation2 > 3 {
            currentAnimation2 = 0
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
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
