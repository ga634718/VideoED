
import Foundation


func clearTempDirectory() {
    do {
        let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory())
        try tmpDirectory.forEach({ file in
            let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
            try FileManager.default.removeItem(atPath: path)
        })
        print("Removed temp file")
    } catch {
        print(error)
    }
}

func currentDate()->String{
    let df = DateFormatter()
    df.dateFormat = "yyyyMMddhhmmss"
    return df.string(from: Date())
}
