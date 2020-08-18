
import Foundation
import AVFoundation

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
extension CMTime {
    var roundedSeconds: TimeInterval {
        return seconds.rounded()
    }
    var hours:  Int { return Int(roundedSeconds / 3600) }
    var minute: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 3600) / 60) }
    var second: Int { return Int(roundedSeconds.truncatingRemainder(dividingBy: 60)) }
    
    var positionalTime: String {
        return hours > 0 ?
            String(format: "%d:%02d:%02d",
                   hours, minute, second) :
            String(format: "%02d:%02d",
                   minute, second)
    }
}

