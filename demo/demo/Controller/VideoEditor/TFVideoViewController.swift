
import UIKit
import AVKit
import AVFoundation
import ZKProgressHUD


class TFVideoViewController: UIViewController {
    @IBOutlet weak var ViewVideo: UIView!
    
    var playerController = AVPlayerViewController()
    var currentAnimation = 0
    var str = ""
    var path:NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let player = AVPlayer(url: path as URL)
        playerController.player = player
        playerController.view.frame.size.height = ViewVideo.frame.size.height
        playerController.view.frame.size.width = ViewVideo.frame.size.width
        playerController.showsPlaybackControls = false
        playerController.view.frame = CGRect(x: 0, y: 0, width: ViewVideo.frame.width, height:  ViewVideo.frame.height)
        self.ViewVideo.addSubview(playerController.view)
        playerController.player?.play()
        
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        playerController.player?.pause()
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
        guard let filePath = path else {
            debugPrint("Video not found")
            return
        }
        let furl = createUrlInApp(name: "video.MOV")
        removeFileIfExists(fileURL: furl)
        //\"transpose=1\"
        
        let transform = "-i \(filePath) -vf \(str) -codec:a copy \(furl)"
        DispatchQueue.main.async {
            ZKProgressHUD.show()
        }
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.async {
            MobileFFmpeg.execute(transform)
            CustomPhotoAlbum.sharedInstance.saveVideo(url: furl)
            DispatchQueue.main.async {
                ZKProgressHUD.dismiss()
                ZKProgressHUD.showSuccess()
            }
            
        }
    }
    
    @IBAction func flip(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            switch self.currentAnimation{
            case 0:
                self.playerController.view.transform = .identity
                
                self.playerController.view.transform = CGAffineTransform(scaleX: 1, y: -1)
                self.str = "\"vflip\""
            case 1:
                self.playerController.view.transform = .identity
            case 2:
                self.playerController.view.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.str = "\"hflip\""
            case 3:
                self.playerController.view.transform = .identity
            default:
                break
            }
        })
        currentAnimation += 1
        if currentAnimation > 3 {
            currentAnimation = 0
        }
    }
    
    @IBAction func turn(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            switch self.currentAnimation{
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
        currentAnimation += 1
        if currentAnimation > 3 {
            currentAnimation = 0
        }
    }
    
}
