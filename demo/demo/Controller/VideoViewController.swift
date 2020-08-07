//
//  VideoViewController.swift
//  demo
//
//  Created by Z on 6/26/20.
//  Copyright © 2020 Z. All rights reserved.
//

import UIKit
import AVKit
import ZKProgressHUD

class VideoViewController: UIViewController {
    var videoTimelineView : VideoTimelineView!
    var arrFuncCell = [ModelItem]()
    var originalVideoURL:NSURL!
    var fixedVideoURL:NSURL!
    var secondVideoURL:NSURL!
    var playerLayer:AVPlayerLayer!
    let videoPicker = UIImagePickerController()
    var playButtonStatus: Bool = true
    @IBOutlet weak var collectionViewFunc: UICollectionView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var tlView: UIView!
    @IBOutlet weak var buttonPlay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoPicker.sourceType = .photoLibrary
        videoPicker.delegate = self
        videoPicker.mediaTypes = ["public.movie"]
        videoPicker.modalPresentationStyle = .overFullScreen
        initVideoTimeline(url: originalVideoURL as URL)
        initFuncCollectionView()
        buttonPlay.isHidden = true
        fixedVideoURL = originalVideoURL
        print(originalVideoURL!)
    }

    @IBAction func btnBack(_ sender: Any) {
        resetPlayer()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        let alert = UIAlertController(title: "Save video to your device", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction) in
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {(action: UIAlertAction) in
            UISaveVideoAtPathToSavedPhotosAlbum(self.fixedVideoURL.path!, nil, nil, nil)
            ZKProgressHUD.showSuccess()
            ZKProgressHUD.dismiss(0.5)
        }))
        present(alert, animated: true)
    }
    
    
    @IBAction func btnPlay(_ sender: Any) {
        playButtonStatus = !playButtonStatus
        if playButtonStatus {
            videoTimelineView.play()
        } else {
            videoTimelineView.stop()
        }
        setPlayButtonImage()
    }


    @IBAction func playButton(_ sender: Any) {
        playButtonStatus = !playButtonStatus
        
        if playButtonStatus {
            videoTimelineView.play()
        } else {
            videoTimelineView.stop()
        }
        setPlayButtonImage()
    }
}

extension VideoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrFuncCell.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
            let data = arrFuncCell[indexPath.row]
            cellView.initCollectionCell(title: data.title, img: data.img)
            return cellView
    }
    	
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width/6.5, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Index: \(indexPath.row)")
        switch indexPath.row {
        case 0:
            videoTimelineView.stop()
            getVideo()
//            insertVideo()
        case 1:
            print(videoTimelineView.currentTime)
        case 2:
            navigateOtherView(view: "Duration")
        case 3:
            navigateOtherView(view: "CROP")
        case 4:
            navigateOtherView(view: "TF")
        case 5:
            navigateOtherView(view: "BGCOLOR")
        case 6:
            navigateOtherView(view: "Duplicate")
        case 7:
            navigateOtherView(view: "TRIMMER")
        default:
            break
        }
    }
}

extension VideoViewController : TimelinePlayStatusReceiver{
    func initVideoTimeline(url : URL){
        videoTimelineView = VideoTimelineView()
        videoTimelineView.backgroundColor = UIColor.clear
        videoTimelineView.frame = CGRect(x: 0, y: tlView.frame.size.height/4, width: tlView.frame.size.width, height: tlView.frame.size.height/2)
        videoTimelineView.new(asset:AVAsset(url: url))
        videoTimelineView.playStatusReceiver = self
        videoTimelineView.repeatOn = true
        videoTimelineView.setTrimIsEnabled(false)
        videoTimelineView.setTrimmerIsHidden(true)
        tlView.addSubview(videoTimelineView)
        videoTimelineView.play()
        playerLayer = AVPlayerLayer(player: videoTimelineView.player!)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.player!.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        playerLayer.frame = videoView.bounds
//        playerLayer.backgroundColor = UIColor.black.cgColor
        self.videoView.layer.addSublayer(playerLayer)
        setPlayButtonImage()
    }
    func videoTimelineStopped() {
        playButtonStatus = false
        setPlayButtonImage()
    }
        
    func videoTimelineMoved() {
        let time = videoTimelineView.currentTime
        print("time: \(time)")
    }
        
    func videoTimelineTrimChanged() {
//        let trim = videoTimelineView.currentTrim()
//        print("start time: \(trim.start)")
//        print("end time: \(trim.end)")
    }
}

extension VideoViewController {
    func initFuncCollectionView(){
        arrFuncCell.append(ModelItem(id: 1,img: "add", title: "INSERT"))
        arrFuncCell.append(ModelItem(id: 2,img: "music", title: "MUSIC"))
        arrFuncCell.append(ModelItem(id: 3,img: "Duration", title: "DURATION"))
        arrFuncCell.append(ModelItem(id: 4,img: "crop", title: "CROP"))
        arrFuncCell.append(ModelItem(id: 5,img: "Transform", title: "TRANSFORM"))
        arrFuncCell.append(ModelItem(id: 6,img: "Background", title: "BACKGROUND"))
        arrFuncCell.append(ModelItem(id: 7,img: "Duplicate", title: "DUPLICATE"))
        arrFuncCell.append(ModelItem(id: 8,img: "Delete", title: "DELETE"))
        
        collectionViewFunc.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
    }
    func setPlayButtonImage(){
        if playButtonStatus {
            self.buttonPlay.isHidden = true
        } else {
            self.buttonPlay.isHidden = false
            self.buttonPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    func resetPlayer(){
        playerLayer.player = nil
        videoTimelineView.player = nil
        playerLayer.removeFromSuperlayer()
        videoTimelineView.removeFromSuperview()
        playButtonStatus = true
        setPlayButtonImage()
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
    
    func insertVideo() {
//        let currentTime  = CGFloat(CMTimeGetSeconds(CMTime(seconds: videoTimelineView.currentTime, preferredTimescale: 1)))
//        let duration = CGFloat(CMTimeGetSeconds(CMTime(seconds: videoTimelineView.duration, preferredTimescale: 1)))
        let furl1 = createUrlInApp(name: "video1.ts")
        removeFileIfExists(fileURL: furl1)
        let furl2 = createUrlInApp(name: "video2.ts")
        removeFileIfExists(fileURL: furl2)
        let furl3 = createUrlInApp(name: "video3.ts")
        removeFileIfExists(fileURL: furl3)
        let furl4 = createUrlInApp(name: "video1.mp4")
        removeFileIfExists(fileURL: furl4)
        let furl5 = createUrlInApp(name: "video2.mp4")
        removeFileIfExists(fileURL: furl5)
        let furl = createUrlInApp(name: "video.MOV")
        removeFileIfExists(fileURL: furl)
        let s1 = "-i \(originalVideoURL!) -c copy \(furl1)"
        MobileFFmpeg.execute(s1)
        let s2 = "-i \(secondVideoURL!) -c copy \(furl2)"
        MobileFFmpeg.execute(s2)
//      let a = "-i \(filePath)  -aspect 1:1 -vf \"pad=iw:ih*2:iw/1:ih/2:color=\(self.str)\" \(furl)"
        let str = "-i \"concat:\(furl1)|\(furl2)\" -c copy \(furl3)"
        MobileFFmpeg.execute(str)
        let str1 = "-i \(furl3) \(furl)"
        MobileFFmpeg.execute(str1)
//        let s1 = "-i \(originalVideoURL!) \(furl4)"
//        MobileFFmpeg.execute(s1)
//        let s2 = "-i \(furl4)  -aspect 1:1 -vf \"pad=iw:ih*2:iw:ih/2:color=black\" \(furl5)"
//        MobileFFmpeg.execute(s2)
        print(furl)
        resetPlayer()
        initVideoTimeline(url: furl)
    }
    
    func getVideo(){
        present(videoPicker, animated: true, completion: nil)
    }
    
    func navigateOtherView(view: String){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        switch view {
        case "Duration":
            let View = sb.instantiateViewController(withIdentifier: view) as! DurationVideoController
            View.path = self.originalVideoURL
            self.navigationController?.pushViewController(View, animated: true)
        case "CROP":
            let View = sb.instantiateViewController(withIdentifier: view) as! CropVideoViewController
            View.path = self.originalVideoURL
            self.navigationController?.pushViewController(View, animated: true)
        case "TF":
            let View = sb.instantiateViewController(withIdentifier: view) as! TFVideoViewController
            View.path = self.originalVideoURL
            self.navigationController?.pushViewController(View, animated: true)
        case "BGCOLOR":
            let View = sb.instantiateViewController(withIdentifier: view) as! BackgroundVideoColorController
            View.path = self.originalVideoURL
            self.navigationController?.pushViewController(View, animated: true)
        case "Duplicate":
            let View = sb.instantiateViewController(withIdentifier: view) as! DuplicateVideoViewController
            View.path = self.originalVideoURL
            self.navigationController?.pushViewController(View, animated: true)
        case "TRIMMER":
            let View = sb.instantiateViewController(withIdentifier: view) as! TrimmerViewController
            View.path = self.originalVideoURL
            self.navigationController?.pushViewController(View, animated: true)
        default:
            break
        }
    }
}

extension VideoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        secondVideoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        videoPicker.dismiss(animated: true, completion: nil)
//        resetPlayer()
//        initVideoTimeline(url: insertVideo())
        insertVideo()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        videoPicker.dismiss(animated: true, completion: nil)
    }
}
