import UIKit
import AVKit
import Foundation
import AudioToolbox
import CorePlot

class DisplayScreen : ViewController {
    @IBOutlet weak var GraphTitle: UILabel!
    @IBOutlet weak var SoundSlideLayout: UISlider!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var FFButton: UIButton!
    @IBOutlet weak var RewindButton: UIButton!
    @IBOutlet weak var BlackButton: UIButton!
    @IBOutlet weak var YellowButton: UIButton!
    @IBOutlet weak var GraphView: UIImageView!
    
    var locate = UserDefaults.standard.string(forKey: "Location")!
    let date = UserDefaults.standard.string(forKey: "Date")!
    let time = UserDefaults.standard.string(forKey: "Time")!
    let duration = UserDefaults.standard.string(forKey: "Duration")!
    let inputFreq = UserDefaults.standard.string(forKey: "Frequency")!
    let inputAmp = UserDefaults.standard.string(forKey: "Amplitude")!
    let inputRate = UserDefaults.standard.string(forKey: "Rate")!
    let inputSChannel = UserDefaults.standard.string(forKey: "SChannel")!
    let inputGChannel = UserDefaults.standard.string(forKey: "GChannel")!
    let data = UserDefaults.standard.array(forKey: "Data")!
    let yMax = UserDefaults.standard.double(forKey: "Max")
    var favorites : [event] = []
    
    var graphImage : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphImage = img!
        let newImg = cropToBounds(image: graphImage!, width: 320, height: 350)
        self.GraphView.image = newImg
        favorites = retrieveFavorites()!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            playSound()
        } catch {
            print("Audio Player Not Found.")
        }
        player?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GraphTitle.text = ud.string(forKey: "Title")
        SoundSlideLayout.value = 0.0
        if (inFavorites()) {
            BlackButton.isHidden = true
            BlackButton.isEnabled = false
        } else {
            YellowButton.isHidden = true
            YellowButton.isEnabled = false
        }
    }
    
    @IBAction func BlackPressed(_ sender: Any) {
        if (!inFavorites()) {
            favorites.append(event(Location: locate, Date: date, Time: time, Duration: duration, Frequency: inputFreq, Amplitude: inputAmp, SChannel: inputSChannel, GChannel: inputGChannel, S32: [], Descript: ""))
        }
        saveFavorites(events: favorites)
        YellowButton.isHidden = false
        YellowButton.isEnabled = true
        BlackButton.isHidden = true
        BlackButton.isEnabled = false
    }
    
    @IBAction func YellowPressed(_ sender: Any) {
        removeFavorite()
        saveFavorites(events: favorites)
        BlackButton.isHidden = false
        YellowButton.isHidden = true
        YellowButton.isEnabled = false
        BlackButton.isEnabled = true
    }
    
    @IBAction func PauseButtonPressed(_ sender: Any) {
        pauseSound()
    }
    
    @IBAction func PlayButtonPressed(_ sender: Any) {
        playSound()
    }
    
    @IBAction func FFButtonPressed(_ sender: Any) {
        let newTime = (player?.currentTime)! + TimeInterval(7.5)
        if (Float(newTime) < Float((player?.duration)!)) {
            player?.currentTime = newTime
        } else {
            player?.currentTime = TimeInterval(0.0)
            pauseSound()
        }
    }
    
    @IBAction func RewindButtonPressed(_ sender: Any) {
        let newTime = (player?.currentTime)! - TimeInterval(7.5)
        if (Float(newTime) > 0.0) {
            player?.currentTime = newTime
        } else {
            player?.currentTime = TimeInterval(0.0)
        }
    }
    
    @IBAction func SoundSlider(_ sender: Any) {
        player?.currentTime = TimeInterval(SoundSlideLayout.value)
    }
    
    
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "BackToInput", sender: self)
        pauseSound()
    }
}

extension DisplayScreen {
    func inFavorites() -> Bool {
        for e in favorites {
            if (e.location == locate && e.date == date && e.time == time && e.duration == duration && e.frequency == inputFreq && e.amplitude == inputAmp && e.schannel == inputSChannel && e.gchannel == inputGChannel) {
                return true
            }
        }
        return false
    }
    
    func removeFavorite() {
        var count = 0
        for e in favorites {
            if (e.location == locate && e.date == date && e.time == time && e.duration == duration && e.frequency == inputFreq && e.amplitude == inputAmp && e.schannel == inputSChannel && e.gchannel == inputGChannel) {
                favorites.remove(at: count)
                break
            }
            count += 1
        }
    }
}

extension DisplayScreen : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (ud.bool(forKey: "Loop")) {
            player.currentTime = TimeInterval(0.0)
            playSound()
        } else {
            pauseSound()
        }
    }
    
    func playSound() {
        SoundSlideLayout.maximumValue = Float((player?.duration)!)
        player?.prepareToPlay()
        player?.enableRate = true
        player?.rate = Float(inputRate)!
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        player?.play()
        PlayButton.isHidden = true
        PlayButton.isEnabled = false
        PauseButton.isHidden = false
        PauseButton.isEnabled = true
    }
    
    @objc func updateSlider(_ timer: Timer) {
        SoundSlideLayout.value = Float((player?.currentTime)!)
    }
    
    func pauseSound() {
        if (player?.isPlaying)! {
            player?.stop()
        }
        PauseButton.isHidden = true
        PauseButton.isEnabled = false
        PlayButton.isHidden = false
        PlayButton.isEnabled = true
    }
}

extension DisplayScreen {
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
}

















