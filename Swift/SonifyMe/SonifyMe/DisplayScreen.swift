import UIKit
import AVKit
import Foundation
import AudioToolbox

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
    
    @IBOutlet weak var GraphHeight: NSLayoutConstraint!
    @IBOutlet weak var GraphWidth: NSLayoutConstraint!
    @IBOutlet weak var PauseHeight: NSLayoutConstraint!
    @IBOutlet weak var PauseWidth: NSLayoutConstraint!
    @IBOutlet weak var PlayHeight: NSLayoutConstraint!
    @IBOutlet weak var PlayWidth: NSLayoutConstraint!
    @IBOutlet weak var FFHeight: NSLayoutConstraint!
    @IBOutlet weak var FFWidth: NSLayoutConstraint!
    @IBOutlet weak var RewindHeight: NSLayoutConstraint!
    @IBOutlet weak var RewindWidth: NSLayoutConstraint!
    @IBOutlet weak var TitleToTopDistance: NSLayoutConstraint!
    @IBOutlet weak var TitleToGraphDistance: NSLayoutConstraint!
    @IBOutlet weak var SliderToPlayDistance: NSLayoutConstraint!
    
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
        formatScreen()
        if (ud.bool(forKey: "Save")) {
            UIImageWriteToSavedPhotosAlbum(img!, self, nil, nil)
        }
        let newImg = cropGraph(image: graphImage!)
        
        self.GraphView.image = newImg
        favorites = retrieveFavorites()!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        do {
            if !firstTime() {
                player = try AVAudioPlayer(contentsOf: url)
                playSound()
            }
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
    
    func firstTime() -> Bool {
        if (!ud.bool(forKey: "Opened Display Previously?")) {
            ud.set(true, forKey: "Opened Display Previously?")
            let alertController = UIAlertController(title: "Audio", message: ringerText, preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { (_) -> Void in
                player = try? AVAudioPlayer(contentsOf: url)
                self.playSound()
            })
            alertController.addAction(continueAction)
            self.present(alertController, animated: true, completion: nil)
            return true
        }
        return false
    }
}

extension DisplayScreen {
    func formatScreen() {
        graphImage = img!
        switch screenSize.height {
        case 1136.0:
            format1136Screen()
            break
        case 2208.0:
            if (!zoomed) {
                format2208Screen()
            }
            break
        case 2436.0:
            if (zoomed) {
                format2208Screen()
            } else {
                format2436Screen()
            }
            break
        default:
            if (zoomed) {
                format1136Screen()
            }
            break
        }
        PauseWidth.constant = PauseHeight.constant
        PlayHeight.constant = PauseHeight.constant
        PlayWidth.constant = PlayHeight.constant
        FFHeight.constant = PlayHeight.constant
        FFWidth.constant = FFHeight.constant
        RewindHeight.constant = FFHeight.constant
        RewindWidth.constant = RewindHeight.constant
    }
    
    func format1136Screen() {
        GraphWidth.constant = GraphWidth.constant * 0.85
        GraphHeight.constant = GraphHeight.constant * 0.75
        PauseHeight.constant = PauseHeight.constant * 0.8
    }
    
    func format2208Screen() {
        GraphWidth.constant = GraphWidth.constant * 1.15
        GraphHeight.constant = GraphHeight.constant * 1.25
    }
    
    func format2436Screen() {
        TitleToTopDistance.constant = TitleToTopDistance.constant * 1.25
        TitleToGraphDistance.constant = TitleToGraphDistance.constant * 1.5
        PauseHeight.constant = PauseHeight.constant
        SliderToPlayDistance.constant = SliderToPlayDistance.constant * 2
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
    func cropGraph(image: UIImage) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size

        let rect: CGRect = CGRect(x: 75.0, y: 0.0, width: contextSize.width * 0.9, height: contextSize.height)
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
}
