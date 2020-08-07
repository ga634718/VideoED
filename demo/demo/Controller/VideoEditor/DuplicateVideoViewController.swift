import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import ZKProgressHUD

class DuplicateVideoViewController: AssetSelectionVideoViewController {
    
    @IBOutlet weak var selectAssetButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    
    var player: AVPlayer?
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var quality: String = "None"
    var path:NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let asset = AVAsset(url: path as URL)
        loadAsset(asset)
        trimmerView.asset = asset
        trimmerView.delegate = self
    }
    
    @IBAction func selectAsset(_ sender: Any) {
        loadAssetRandomly()
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
        
        let st = CGFloat(CMTimeGetSeconds(trimmerView.startTime!))
        let st1 = CGFloat(CMTimeGetSeconds(trimmerView.endTime!))
        let tl = CGFloat(CMTimeGetSeconds((trimmerView.endTime!) - trimmerView.startTime!))
        let end = CGFloat(CMTimeGetSeconds((player?.currentItem?.asset.duration)! - trimmerView.endTime!))
        let crtime = CGFloat(CMTimeGetSeconds((player?.currentTime())!))
        let curr = CGFloat(CMTimeGetSeconds((player?.currentItem?.asset.duration)!))
        let dr = curr - crtime
        let dr2 = crtime + tl
        
        let url = createUrlInApp(name: "cut0.MOV")
        removeFileIfExists(fileURL: url)
        let url1 = createUrlInApp(name: "cut1.MOV")
        removeFileIfExists(fileURL: url1)
        let url2 = createUrlInApp(name: "cut2.MOV")
        removeFileIfExists(fileURL: url2)
        let furl = createUrlInApp(name: "vd1.MOV")
        removeFileIfExists(fileURL: furl)
        let furl1 = createUrlInApp(name: "vd2.MOV")
        removeFileIfExists(fileURL: furl1)
        let audio2 = createUrlInApp(name: "audio.MOV")
        removeFileIfExists(fileURL: audio2)
        let final = createUrlInApp(name: "final.MOV")
        removeFileIfExists(fileURL: final)
        
        if quality == "None" {
            if st == 0 {
                let cut1 = "-ss 0 -i \(filePath) -to \(tl) -c copy \(url1)"
                MobileFFmpeg.execute(cut1)
                let cut2 = "-ss \(st1) -i \(filePath) -to \(end) -c copy \(url2)"
                MobileFFmpeg.execute(cut2)
                let cut3 = "-i \(url1) -i \(url1) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] concat=n=3:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
                
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(cut3)
                    CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                    }
                }
            } else if st1 == curr {
                let cut1 = "-ss \(st) -i \(filePath) -to \(tl) -c copy \(url1)"
                MobileFFmpeg.execute(cut1)
                
                let cut2 = "-ss 0 -i \(filePath) -to \(st) -c copy \(url2)"
                MobileFFmpeg.execute(cut2)
                print(url2)
                
                let cut3 = "-i \(url2) -i \(url1) -i \(url1) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] concat=n=3:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(cut3)
                    CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                    }
                }
            } else {
                let cut = "-ss 0 -i \(filePath) -to \(st) -c copy \(url)"
                let cut1 = "-ss \(st) -i \(filePath) -to \(tl) -c copy \(url1)"
                let cut2 = "-ss \(st1) -i \(filePath) -to \(end) -c copy \(url2)"
                let cut3 = "-i \(url) -i \(url1) -i \(url1) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] [3:v:0] [3:a:0] concat=n=4:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
                
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(cut)
                    MobileFFmpeg.execute(cut1)
                    MobileFFmpeg.execute(cut2)
                    MobileFFmpeg.execute(cut3)
                    CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                    }
                }
            }
        } else {
            let cut = "-ss \(st) -i \(filePath) -to \(tl) -c copy \(url)"
            MobileFFmpeg.execute(cut)
            let cut1 = "-ss 0 -i \(filePath) -to \(crtime) -c copy \(url1)"
            MobileFFmpeg.execute(cut1)
            let cut2 = "-ss \(crtime) -i \(filePath) -to \(dr) -c copy \(url2)"
            MobileFFmpeg.execute(cut2)
            
            let cmdvd1 = "-i \(url1) -i \(url) -filter_complex \"[0:v]setpts=PTS-STARTPTS[v0]; [1:v]setpts=PTS-STARTPTS,tpad=start_duration=\(crtime)[v1]; [v0][v1]hstack,crop=iw/2:ih:x='clip(2000*(t-\(crtime)),0,iw/2)':y=0[out]\" -map '[out]' \(furl)"
            let cmdvd2 = "-i \(filePath) -i \(url) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(crtime):d=1:alpha=1,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1,setpts=PTS-STARTPTS+\(crtime)/TB[va1];[2:v]scale=1280x720,trim=duration=\(crtime-1.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl)"
            let cmdvd22 = "-i \(furl) -i \(url2) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(dr2):d=1:alpha=1,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1,setpts=PTS-STARTPTS+\(dr2)/TB[va1];[2:v]scale=1280x720,trim=duration=\(dr2-1.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl1)"
            let cmdvd3 = "-i \(filePath) -i \(url) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(crtime-0.5):d=1.5,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1.5,setpts=PTS-STARTPTS+\(crtime)/TB[va1];[2:v]scale=1280x720,trim=duration=\(crtime-1.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl)"
            let cmdvd33 = "-i \(furl) -i \(url2) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(dr2-0.5):d=1.5,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1.5,setpts=PTS-STARTPTS+\(dr2)/TB[va1];[2:v]scale=1280x720,trim=duration=\(dr2-1.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl1)"
            
            if quality == "PushRight"{
                let ad2 = "-i \(url1) -i \(url) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] concat=n=2:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(audio2)"
                
                let cmdvd4 = "-i \(furl) -i \(audio2) -c copy -map 0:v -map 1:a \(furl1)"
                
                let fn = "-i \(furl1) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] concat=n=2:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
                
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(cmdvd1)
                    MobileFFmpeg.execute(ad2)
                    MobileFFmpeg.execute(cmdvd4)
                    MobileFFmpeg.execute(fn)
                    CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                    }
                }
            } else {
                let ad2 = "-i \(url1) -i \(url) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] concat=n=3:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(audio2)"
                
                let cmdvd4 = "-i \(furl1) -i \(audio2) -c copy -map 0:v -map 1:a \(final)"
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    if self.quality == "CrossFade"{
                        MobileFFmpeg.execute(cmdvd2)
                        MobileFFmpeg.execute(cmdvd22)
                        MobileFFmpeg.execute(ad2)
                        MobileFFmpeg.execute(cmdvd4)
                        CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    }
                    if self.quality == "ColorFade"{
                        MobileFFmpeg.execute(cmdvd3)
                        MobileFFmpeg.execute(cmdvd33)
                        MobileFFmpeg.execute(ad2)
                        MobileFFmpeg.execute(cmdvd4)
                        CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    }
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss()
                        ZKProgressHUD.showSuccess()
                    }
                }
            }
        }
    }
    
    @IBAction func duplicate(_ sender: Any) {
        player?.pause()
        chooseQuality()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(TrimmerViewController.itemDidFinishPlaying(_:)),
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
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TrimmerViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
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

extension DuplicateVideoViewController: TrimmerViewDelegate, PassQualityDelegate {
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
    func chooseQuality() {
        let view = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConfigView") as! TbvViewController
        view.delegate = self
        view.myQuality = quality
        view.modalPresentationStyle = .overCurrentContext
        self.present(view, animated: true)
    }
    func getQuality(quality: String) {
        self.quality = quality
    }
}
