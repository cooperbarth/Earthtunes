import UIKit
import AVKit
import Foundation
import AudioToolbox

class DisplayScreen : ViewController {
    @IBOutlet weak var GraphTitle: UILabel!
    @IBOutlet weak var SoundSlideLayout: UISlider!
    @IBOutlet weak var GraphView: UIImageView!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var PlayPauseButton: UIButton!

    lazy var locate = ud.string(forKey: "Location")!
    lazy var date = ud.string(forKey: "Date")!
    lazy var time = ud.string(forKey: "Time")!
    lazy var duration = ud.string(forKey: "Duration")!
    lazy var inputFreq = ud.string(forKey: "Frequency")!
    lazy var inputAmp = ud.string(forKey: "Amplitude")!
    lazy var inputRate = ud.string(forKey: "Rate")!
    lazy var inputSChannel = ud.string(forKey: "SChannel")!
    lazy var inputGChannel = ud.string(forKey: "GChannel")!
    var favorites : [event] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if (ud.bool(forKey: "Save")) {
            UIImageWriteToSavedPhotosAlbum(img!, self, nil, nil)
        }
        let newImg = cropGraph(image: img!)

        GraphView.image = newImg
        favorites = retrieveFavorites()!
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setUpPlayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        GraphTitle.text = ud.string(forKey: "Title")
        SoundSlideLayout.value = 0.0
        updateSavedPic()
    }

    @IBAction func SavePressed(_ sender: Any) {
        if (inFavorites()) {
            removeFavorite()
        } else {
            favorites.append(event(Location: locate, Date: date, Time: time, Duration: duration, Frequency: inputFreq, Amplitude: inputAmp, SChannel: inputSChannel, GChannel: inputGChannel, S32: [], Descript: ""))
        }
        saveFavorites(events: favorites)
        updateSavedPic()
    }

    func updateSavedPic() {
        if (inFavorites()) {
            if let image = UIImage(named: "YellowStar.png") {
                SaveButton.setImage(image, for: .normal)
            }
        } else {
            if let image = UIImage(named: "BlackStar.png") {
                SaveButton.setImage(image, for: .normal)
            }
        }
    }

    @IBAction func PlayPauseButtonPressed(_ sender: Any) {
        if (player?.isPlaying)! {
            pauseSound()
        } else {
            playSound()
        }
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
    func setUpPlayer() {
        do {
            if !firstTime() {
                player = try AVAudioPlayer(contentsOf: url)
                playSound()
            }
        } catch {
            print("Audio Player Not Found.")
        }

        SoundSlideLayout.maximumValue = Float((player?.duration)!)
        player?.enableRate = true
        player?.rate = Float(inputRate)!
        Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        player?.delegate = self
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (ud.bool(forKey: "Loop")) {
            player.currentTime = TimeInterval(0.0)
            playSound()
        } else {
            pauseSound()
        }
    }

    func playSound() {
        player?.prepareToPlay()
        player?.play()

        if let image = UIImage(named: "Pause.png") {
            PlayPauseButton.setImage(image, for: .normal)
        }
    }

    func pauseSound() {
        if (player?.isPlaying)! {
            player?.stop()
        }

        if let image = UIImage(named: "Play.png") {
            PlayPauseButton.setImage(image, for: .normal)
        }
    }

    @objc func updateSlider(_ timer: Timer) {
        SoundSlideLayout.value = Float((player?.currentTime)!)
    }
}

extension DisplayScreen {
    func cropGraph(image: UIImage) -> UIImage {
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size

        let rect: CGRect = CGRect(x: 75.0, y: 25.0, width: contextSize.width * 0.9, height: contextSize.height)
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        return image
    }
}
