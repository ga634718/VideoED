import UIKit
import Photos
import Foundation
import CropViewController
import ZKProgressHUD

class ImageViewController: UIViewController{
    
    let imagePicker = UIImagePickerController()
    var img : UIImage!
    var arr = [ModelItem]()
    @IBOutlet weak var imageViewBackGround: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = img
        setImageViewBackground()
        initFuncCollectionView()
//        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
    }
    
    
    @IBAction func btnSave(_ sender: Any) {
        let alert = UIAlertController(title: "Save image to your device ", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {(action: UIAlertAction) in
            print("Cancel")
        }))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {(action: UIAlertAction) in
            print("saved")
            UIImageWriteToSavedPhotosAlbum(self.imageView.image!, nil, nil, nil)
            ZKProgressHUD.showSuccess()
            ZKProgressHUD.dismiss(0.5)
        }))
        present(alert, animated: true)
    }
    
}

extension ImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let data = arr[indexPath.row]
        cell.initCollectionCell(title: data.title, img: data.img)
        return cell
    }
    
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.size.width/8.25, height: collectionView.frame.size.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print(indexPath.row)
            presentCropViewController()
        case 1:
            print(indexPath.row)
//            imageView.image = imageView.image?.withHorizontallyFlippedOrientation()
            imageView.image = imageView.image?.rotate(radians: .pi/2)
        default:
            print(indexPath.row)
        }
    }
}

extension ImageViewController: CropViewControllerDelegate {
    
    func presentCropViewController() {
        let cropViewController = CropViewController(image: imageView.image!)
        cropViewController.delegate = self
//        cropViewController.showActivitySheetOnDone = true
        cropViewController.rotateClockwiseButtonHidden = true
        cropViewController.rotateButtonsHidden = true
        present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        imageView.image = image
        setImageViewBackground()
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension UIImageView{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}

extension ImageViewController{
    func setImageViewBackground(){
        let x = (imageView.image!.size.width) / 4
        let y = (imageView.image!.size.height) / 4
        let width = (imageView.image!.size.width) / 2
        let height = (imageView.image!.size.height) / 2
        imageViewBackGround.image = UIImage(cgImage: (imageView.image?.cgImage?.cropping(to: CGRect(x: x, y: y, width: width, height: height)))!)
        imageViewBackGround.addBlurEffect()
    }
    func initFuncCollectionView(){
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        arr.append(ModelItem(id: 1,img: "trim", title: "RESIZE"))
        arr.append(ModelItem(id: 2,img: "rotate", title: "ROTATE"))
        arr.append(ModelItem(id: 3,img: "trim", title: "RESIZE"))
        arr.append(ModelItem(id: 4,img: "rotate", title: "ROTATE"))
        arr.append(ModelItem(id: 5,img: "trim", title: "RESIZE"))
        arr.append(ModelItem(id: 6,img: "rotate", title: "ROTATE"))
        arr.append(ModelItem(id: 7,img: "trim", title: "RESIZE"))
        arr.append(ModelItem(id: 8,img: "rotate", title: "ROTATE"))
        arr.append(ModelItem(id: 9,img: "trim", title: "RESIZE"))
        arr.append(ModelItem(id: 10,img: "rotate", title: "ROTATE"))
    }
}

extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
