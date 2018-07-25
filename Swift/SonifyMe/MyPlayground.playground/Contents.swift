//import UIKit
import AVKit
import Foundation
import AVFoundation






































var audio = [Float64]()
for _ in 1...10000 {
    audio.append(Float64(100000))
}

func saveFile(buff : [Float64]) -> URL{
    let SAMPLE_RATE =  Float64(160.0)
    
    let outputFormatSettings = [
        AVFormatIDKey:kAudioFormatLinearPCM,
        AVLinearPCMBitDepthKey:32,
        AVLinearPCMIsFloatKey: true,
        AVSampleRateKey: SAMPLE_RATE,
        AVNumberOfChannelsKey: 1
        ] as [String : Any]
    
    let url = Bundle.main.url(forResource:"ryerson", withExtension:"wav")
    
    let audioFile = try? AVAudioFile(forWriting: url!, settings: outputFormatSettings, commonFormat: AVAudioCommonFormat.pcmFormatFloat32, interleaved: true)
    
    let bufferFormat = AVAudioFormat(settings: outputFormatSettings)
    
    let outputBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat!, frameCapacity: AVAudioFrameCount(buff.count))
    
    for i in 0..<buff.count {
        outputBuffer?.floatChannelData!.pointee[i] = Float(buff[i])
    }
    
    outputBuffer?.frameLength = AVAudioFrameCount( buff.count )
    
    do{
        try audioFile?.write(from: outputBuffer!)
    } catch let error as NSError {
        print("error:", error.localizedDescription)
    }
    
    return url!
}

var audioPlayer : AVAudioPlayer = AVAudioPlayer()

func playSound(path:String) {
    if let soundURL = Bundle.main.url(forResource:path, withExtension:"wav") {
        do {
            audioPlayer = try! AVAudioPlayer(contentsOf: soundURL)
            audioPlayer.numberOfLoops = 1000
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print("shit")
        }
    } else {
        print("Error: Path Not Found")
    }
}

let theURL:URL = saveFile(buff:audio)
//playSound(url: theURL)










