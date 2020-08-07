
import UIKit
import AVKit
import AVFoundation
import ZKProgressHUD

class DurationVideoController: UIViewController {
    
    @IBOutlet weak var viewVideo1: UIView!
    
    var playerController = AVPlayerViewController()
    var player: AVPlayer!
    var isVideoPlay = false
    var path: NSURL!
    
    
    @IBOutlet weak var timeSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        path = Bundle.main.path(forResource: "Test", ofType: "mp4")
        player = AVPlayer(url: path as URL)
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        addTimeObserver()
        playerController.player = player
        playerController.showsPlaybackControls = false
        playerController.view.frame = CGRect(x: 0, y: 0, width: viewVideo1.frame.width, height:  viewVideo1.frame.height)
        self.viewVideo1.addSubview(playerController.view)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        _ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player.currentItem else {return}
            guard currentItem.status.rawValue == AVPlayerItem.Status.readyToPlay.rawValue else {return}
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
        })
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        if player.rate == 2.0{
            guard let filePath = path else {
                debugPrint("Video not found")
                return
            }
            player.pause()
            //SpeeđAuio
            let furl = createUrlInApp(name: "1.mp4")
            removeFileIfExists(fileURL: furl)
            let cut = "-i \(filePath) -filter_complex \"[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]\" -map \"[v]\" -map \"[a]\" \(furl)"
            
            
            //SpeedVideo
            let furl2 = createUrlInApp(name: "2.mp4")
            removeFileIfExists(fileURL: furl2)
            let cut2 = "-itsscale 0.5 -i \(filePath) -c copy \(furl2)"
            
            
            //graft
            let furl3 = createUrlInApp(name: "3.mp4")
            removeFileIfExists(fileURL: furl3)
            let cut3 = "-i \(furl2) -i \(furl) -c copy -map 0:v -map 1:a \(furl3)"
            
            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                MobileFFmpeg.execute(cut)
                MobileFFmpeg.execute(cut2)
                MobileFFmpeg.execute(cut3)
               CustomPhotoAlbum.sharedInstance.saveVideo(url: furl3)
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss()
                    ZKProgressHUD.showSuccess()
                }
            }
            
        }else if player.rate == 0.5 {
            guard let filePath = path else {
                debugPrint("Video not found")
                return
            }
            player.pause()
            //SpeeđAuio
            let furl = createUrlInApp(name: "1.mp4")
            removeFileIfExists(fileURL: furl)
            let cut = "-i \(filePath) -filter_complex \"[0:v]setpts=2.0*PTS[v];[0:a]atempo=0.5[a]\" -map \"[v]\" -map \"[a]\" \(furl)"
            MobileFFmpeg.execute(cut)
            
            //SpeedVideo
            let furl2 = createUrlInApp(name: "2.mp4")
            removeFileIfExists(fileURL: furl2)
            let cut2 = "-itsscale 2.0 -i \(filePath) -c copy \(furl2)"
            MobileFFmpeg.execute(cut2)
            
            //graft
            let furl3 = createUrlInApp(name: "3.mp4")
            removeFileIfExists(fileURL: furl3)
            let cut3 = "-i \(furl2) -i \(furl) -c copy -map 0:v -map 1:a \(furl3)"
            MobileFFmpeg.execute(cut3)
            
            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                MobileFFmpeg.execute(cut3)
                CustomPhotoAlbum.sharedInstance.saveVideo(url: furl3)
                DispatchQueue.main.async {
                    ZKProgressHUD.dismiss()
                    ZKProgressHUD.showSuccess()
                }
                
            }
        }
    }
    
    @IBAction func btnPlayy(_ sender: UIButton) {
        player.rate = 1.0
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
    
    @IBAction func forwardPressed(_ sender: Any) {
        player.rate = 0.5
        
    }
    
    @IBAction func backwardsPressed(_ sender: Any) {
        player.rate = 2.0
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        player.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
        }
    }
    
    func getTimeString(from time: CMTime) -> String{
        let totalSecond = CMTimeGetSeconds(time)
        let hours = Int(totalSecond/3600)
        let minutes = Int(totalSecond/60) % 60
        let seconds = Int(totalSecond.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else{
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
}
