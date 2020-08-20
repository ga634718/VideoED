import UIKit
import AVFoundation
import MobileCoreServices
import PryntTrimmerView
import ZKProgressHUD

class DuplicateVideoViewController: AssetSelectionVideoViewController {
    
    @IBOutlet weak var selectAssetButton: UIButton!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var LblStartTime: UILabel!
    @IBOutlet weak var LblEndTime: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    var player = AVPlayer()
    var playbackTimeCheckerTimer: Timer?
    var trimmerPositionChangedTimer: Timer?
    var quality: String = "None"
    var path:NSURL!
    var duplicateURL: URL!
    var isSave = false
    var ratio:CGFloat!
    var width:Int!
    var height:Int!
    var delegate: TransformCropVideoDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let asset = AVAsset(url: path as URL)
        loadAsset(asset)
        setlabel()
        ratio = getVideoRatio(url: path as URL)
        width = Int(getVideoWidth(url: path as URL))
        height = Int(getVideoheight(url: path as URL))
    }
    
    @IBAction func back(_ sender: Any) {
        player.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        
        player.pause()
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        
        let startTime = CGFloat(CMTimeGetSeconds(trimmerView.startTime!))
        let endTime = CGFloat(CMTimeGetSeconds(trimmerView.endTime!))
        let durationTime = CGFloat(CMTimeGetSeconds((trimmerView.endTime!) - trimmerView.startTime!))
        let lateTime = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)! - trimmerView.endTime!))
        //        let currentTime = CGFloat(CMTimeGetSeconds((player?.currentTime())!))
        let duration = CGFloat(CMTimeGetSeconds((player.currentItem?.asset.duration)!))
        let dr = duration - endTime
        let dr2 = endTime + durationTime
        
        let url = createUrlInApp(name: "cutvideo1.MOV")
        removeFileIfExists(fileURL: url)
        let url1 = createUrlInApp(name: "cutvideo2.MOV")
        removeFileIfExists(fileURL: url1)
        let url2 = createUrlInApp(name: "cutvideo3.MOV")
        removeFileIfExists(fileURL: url2)
        let furl1 = createUrlInApp(name: "videodemo1.MOV")
        removeFileIfExists(fileURL: furl1)
        let furl2 = createUrlInApp(name: "videodemo2.MOV")
        removeFileIfExists(fileURL: furl2)
        let audio1 = createUrlInApp(name: "audio.MOV")
        removeFileIfExists(fileURL: audio1)
        let audio2 = createUrlInApp(name: "audio2.MOV")
        removeFileIfExists(fileURL: audio2)
        let final = createUrlInApp(name: "\(currentDate()).MOV")
        removeFileIfExists(fileURL: final)
        
        if quality == "None" {
            if startTime == 0 {
                let cut1 = "-ss 0 -i \(filePath) -to \(durationTime) -c copy \(url1)"
                MobileFFmpeg.execute(cut1)
                let cut2 = "-ss \(endTime) -i \(filePath) -to \(lateTime) -c copy \(url2)"
                MobileFFmpeg.execute(cut2)
                let duplicate = "-i \(url1) -i \(url1) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] concat=n=3:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
                
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(duplicate)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.duplicateURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.duplicateURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss(0.5)
                        ZKProgressHUD.showSuccess()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else if endTime == duration {
                let cut1 = "-ss \(startTime) -i \(filePath) -to \(durationTime) -c copy \(url1)"
                MobileFFmpeg.execute(cut1)
                
                let cut2 = "-ss 0 -i \(filePath) -to \(startTime) -c copy \(url2)"
                MobileFFmpeg.execute(cut2)
                print(url2)
                
                let duplicate = "-i \(url2) -i \(url1) -i \(url1) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] concat=n=3:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(final)"
                DispatchQueue.main.async {
                    ZKProgressHUD.show()
                }
                let serialQueue = DispatchQueue(label: "serialQueue")
                serialQueue.async {
                    MobileFFmpeg.execute(duplicate)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.duplicateURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.duplicateURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss(0.5)
                        ZKProgressHUD.showSuccess()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                let cut = "-ss 0 -i \(filePath) -to \(startTime) -c copy \(url)"
                let cut1 = "-ss \(startTime) -i \(filePath) -to \(durationTime) -c copy \(url1)"
                let cut2 = "-ss \(endTime) -i \(filePath) -to \(lateTime) -c copy \(url2)"
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
                    self.removeFileIfExists(fileURL: url)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.removeFileIfExists(fileURL: furl1)
                    self.removeFileIfExists(fileURL: furl2)
                    self.removeFileIfExists(fileURL: audio1)
                    self.removeFileIfExists(fileURL: audio2)
                    self.duplicateURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.duplicateURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss(0.5)
                        ZKProgressHUD.showSuccess()
                        self.player.pause()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            let cut = "-ss \(startTime) -i \(filePath) -to \(durationTime) -c copy \(url)"
            MobileFFmpeg.execute(cut)
            let cut1 = "-ss 0 -i \(filePath) -to \(endTime) -c copy \(url1)"
            MobileFFmpeg.execute(cut1)
            let cut2 = "-ss \(endTime) -i \(filePath) -to \(dr) -c copy \(url2)"
            MobileFFmpeg.execute(cut2)
            var cmdfinal1 = ""
            var cmdfinal2 = ""
            
            let cmdvd1 = "-i \(url1) -i \(url) -filter_complex \"[0:v]setpts=PTS-STARTPTS[v0]; [1:v]setpts=PTS-STARTPTS,tpad=start_duration=\(endTime)[v1]; [v0][v1]hstack,crop=iw/2:ih:x='clip(2000*(t-\(endTime)),0,iw/2)':y=0[out]\" -map '[out]' \(furl1)"
            let cmdvd11 = "-i \(furl1) -i \(url2) -filter_complex \"[0:v]setpts=PTS-STARTPTS[v0]; [1:v]setpts=PTS-STARTPTS,tpad=start_duration=\(dr2)[v1]; [v0][v1]hstack,crop=iw/2:ih:x='clip(2000*(t-\(dr2)),0,iw/2)':y=0[out]\" -map '[out]' \(furl2)"
            
            let cmdvd2 = "-i \(url1) -i \(url) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(endTime):d=1:alpha=1,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1,setpts=PTS-STARTPTS+\(endTime)/TB[va1];[2:v]scale=\(width!)x\(height!),trim=duration=\(endTime-2.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl1)"
            let cmdvd22 = "-i \(furl1) -i \(url2) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(dr2):d=1:alpha=1,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=1:alpha=1,setpts=PTS-STARTPTS+\(dr2)/TB[va1];[2:v]scale=\(width!)x\(height!),trim=duration=\(dr2-2.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl2)"
            
            let cmdvd3 = "-i \(url1) -i \(url) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(endTime-0.5):d=0.5,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=0.5,setpts=PTS-STARTPTS+\(endTime)/TB[va1];[2:v]scale=\(width!)x\(height!),trim=duration=\(endTime-1.0)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl1)"
            let cmdvd33 = "-i \(furl1) -i \(url2) -f lavfi -i color=black -filter_complex \"[0:v]format=pix_fmts=yuva420p,fade=t=out:st=\(dr2-0.2):d=0.2,setpts=PTS-STARTPTS[va0];[1:v]format=pix_fmts=yuva420p,fade=t=in:st=0:d=0.2,setpts=PTS-STARTPTS+\(dr2)/TB[va1];[2:v]scale=\(width!)x\(height!),trim=duration=\(dr2-0.4)[over]; [over][va0]overlay[over1]; [over1][va1]overlay=format=yuv420[outv]\" -vcodec libx264 -map [outv] \(furl2)"
            
            let cmdaudio = "-i \(url1) -i \(url) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] concat=n=2:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(audio1)"
            let cmdaudio2 = "-i \(url1) -i \(url) -i \(url2) -filter_complex \"[0:v:0] [0:a:0] [1:v:0] [1:a:0] [2:v:0] [2:a:0] concat=n=3:v=1:a=1 [v] [a]\" -map \"[v]\" -map \"[a]\" \(audio2)"
            
            if ratio == 1 {
                cmdfinal1 = "-i \(furl1) -i \(audio1) -aspect 1:1 -c copy -map 0:v -map 1:a \(final)"
                cmdfinal2 = "-i \(furl2) -i \(audio2) -aspect 1:1 -c copy -map 0:v -map 1:a \(final)"
            } else if ratio < 1 {
                cmdfinal1 = "-i \(furl1) -i \(audio1) -aspect 9:16 -c copy -map 0:v -map 1:a \(final)"
                cmdfinal2 = "-i \(furl2) -i \(audio2) -aspect 9:16 -c copy -map 0:v -map 1:a \(final)"
            } else {
                cmdfinal1 = "-i \(furl1) -i \(audio1) -aspect 16:9 -c copy -map 0:v -map 1:a \(final)"
                cmdfinal2 = "-i \(furl2) -i \(audio2) -aspect 16:9 -c copy -map 0:v -map 1:a \(final)"
            }

            DispatchQueue.main.async {
                ZKProgressHUD.show()
            }
            let serialQueue = DispatchQueue(label: "serialQueue")
            serialQueue.async {
                if endTime == duration {
                    if self.quality == "PushRight"{
                        MobileFFmpeg.execute(cmdvd1)
                    }
                    if self.quality == "CrossFade"{
                        MobileFFmpeg.execute(cmdvd2)
                    }
                    if self.quality == "ColorFade"{
                        MobileFFmpeg.execute(cmdvd3)
                    }
                    MobileFFmpeg.execute(cmdaudio)
                    MobileFFmpeg.execute(cmdfinal1)
                    self.removeFileIfExists(fileURL: url)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.removeFileIfExists(fileURL: furl1)
                    self.removeFileIfExists(fileURL: furl2)
                    self.removeFileIfExists(fileURL: audio1)
                    self.removeFileIfExists(fileURL: audio2)
                    self.duplicateURL = final
                    self.isSave = true
                    self.delegate.transformReal(url: self.duplicateURL!)
//                    CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss(0.5)
                        ZKProgressHUD.showSuccess()
                        self.player.pause()
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    if self.quality == "PushRight"{
                        MobileFFmpeg.execute(cmdvd1)
                        MobileFFmpeg.execute(cmdvd11)
                    }
                    if self.quality == "CrossFade"{
                        MobileFFmpeg.execute(cmdvd2)
                        MobileFFmpeg.execute(cmdvd22)
                    }
                    if self.quality == "ColorFade"{
                        MobileFFmpeg.execute(cmdvd3)
                        MobileFFmpeg.execute(cmdvd33)
                    }
                    MobileFFmpeg.execute(cmdaudio2)
                    MobileFFmpeg.execute(cmdfinal2)
                    self.removeFileIfExists(fileURL: url)
                    self.removeFileIfExists(fileURL: url1)
                    self.removeFileIfExists(fileURL: url2)
                    self.removeFileIfExists(fileURL: furl1)
                    self.removeFileIfExists(fileURL: furl2)
                    self.removeFileIfExists(fileURL: audio1)
                    self.removeFileIfExists(fileURL: audio2)
                    self.duplicateURL = final
//                    CustomPhotoAlbum.sharedInstance.saveVideo(url: final)
                    self.isSave = true
                    self.delegate.transformReal(url: self.duplicateURL!)
                    DispatchQueue.main.async {
                        ZKProgressHUD.dismiss(0.5)
                        ZKProgressHUD.showSuccess()
                        self.player.pause()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @IBAction func duplicate(_ sender: Any) {
        player.pause()
        playButton.setImage(UIImage(named: "icon_play"), for: .normal)
        chooseQuality()
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(TrimmerViewController.itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.black.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        //        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    func getVideoRatio(url:URL) -> CGFloat{
        let size = resolutionSizeForLocalVideo(url: url)
        return size!.width/size!.height
    }
    
    func getVideoWidth(url:URL) -> CGFloat{
        let size = resolutionSizeForLocalVideo(url: url)
        return size!.width
    }
    
    func getVideoheight(url:URL) -> CGFloat{
        let size = resolutionSizeForLocalVideo(url: url)
        return size!.height
    }
    
    func resolutionSizeForLocalVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    func setlabel(){
        LblStartTime.text = trimmerView.startTime?.positionalTime
        LblEndTime.text = trimmerView.endTime?.positionalTime
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
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(TrimmerViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
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
    
    func changeIconBtnPlay() {
         if player.isPlaying {
             playButton.setImage(UIImage(named: "icon_pause"), for: .normal)
         } else {
             playButton.setImage(UIImage(named: "icon_play"), for: .normal)
         }
     }
}

extension DuplicateVideoViewController: TrimmerViewDelegate, PassQualityDelegate {
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
