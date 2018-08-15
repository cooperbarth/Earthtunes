import UIKit
import AVKit
import Foundation
import AudioToolbox
import CorePlot

class DisplayScreen : ViewController, AVAudioPlayerDelegate {
    var locate = UserDefaults.standard.string(forKey: "Location")!
    let date = UserDefaults.standard.string(forKey: "Date")!
    let time = UserDefaults.standard.string(forKey: "Time")!
    let duration = UserDefaults.standard.string(forKey: "Duration")!
    
    let inputFreq = UserDefaults.standard.string(forKey: "Frequency")!
    let inputAmp = UserDefaults.standard.string(forKey: "Amplitude")!
    let inputRate = UserDefaults.standard.string(forKey: "Rate")! //doesn't do anything yet
    let inputSChannel = UserDefaults.standard.string(forKey: "SChannel")!
    let inputGChannel = UserDefaults.standard.string(forKey: "GChannel")!
    
    let data = UserDefaults.standard.array(forKey: "Data")!
    let yMax = UserDefaults.standard.double(forKey: "Max")
    
    var favorites : [event] = []
    
    @IBOutlet weak var GraphTitle: UILabel!
    @IBOutlet weak var SoundSlideLayout: UISlider!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var FFButton: UIButton!
    @IBOutlet weak var RewindButton: UIButton!
    
    @IBOutlet weak var BlackButton: UIButton!
    @IBAction func BlackPressed(_ sender: Any) {
        if (!inFavorites()) {
            favorites.append(event(Location: locate, Date: date, Time: time, Duration: duration, Frequency: inputFreq, Amplitude: inputAmp, Rate: inputRate, SChannel: inputSChannel, GChannel: inputGChannel, G32: [], S32: []))
        }
        saveFavorites(events: favorites)
        YellowButton.isHidden = false
        YellowButton.isEnabled = true
        BlackButton.isHidden = true
        BlackButton.isEnabled = false
    }
    
    @IBOutlet weak var YellowButton: UIButton!
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
    
    @IBAction func BackButton(_ sender: Any) {
        performSegue(withIdentifier: "BackToInput", sender: self)
        pauseSound()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            playSound()
            favorites = retrieveFavorites()!
            if (inFavorites()) {
                BlackButton.isHidden = true
                BlackButton.isEnabled = false
            } else {
                YellowButton.isHidden = true
                YellowButton.isEnabled = false
            }
        } catch {
            print("Audio Player Not Found.")
        }
        player?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initplot()
        GraphTitle.text = ud.string(forKey: "Title")
        SoundSlideLayout.value = 0.0
    }
    
    @IBOutlet weak var hostView: CPTGraphHostingView!
    var plot: CPTScatterPlot!
    
    func initplot() {
        configureHostView()
        configureGraph()
        configureChart()
        configureAxes()
    }
    
    func inFavorites() -> Bool {
        for e in favorites {
            if (e.location == locate && e.date == date && e.time == time && e.duration == duration && e.frequency == inputFreq && e.amplitude == inputAmp && e.rate == inputRate && e.schannel == inputSChannel && e.gchannel == inputGChannel) {
                return true
            }
        }
        return false
    }
    
    func removeFavorite() {
        var count = 0
        for e in favorites {
            if (e.location == locate && e.date == date && e.time == time && e.duration == duration && e.frequency == inputFreq && e.amplitude == inputAmp && e.rate == inputRate && e.schannel == inputSChannel && e.gchannel == inputGChannel) {
                favorites.remove(at: count)
                break
            }
            count += 1
        }
    }
}

extension DisplayScreen : CPTScatterPlotDelegate, CPTScatterPlotDataSource {
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(data.count)
    }
    
    func number(for plot: CPTPlot, field: UInt, record idx: UInt) -> Any? {
        switch CPTScatterPlotField(rawValue: Int(field)) {
        case .X?:
            return idx
        case .Y?:
            return self.data[Int(idx)] as! NSNumber
        default:
            return 0.0 as NSNumber
        }
    }
    
    func symbol(for plot: CPTScatterPlot, record idx: UInt) -> CPTPlotSymbol? {
        let symbol : CPTPlotSymbol = CPTPlotSymbol()
        symbol.symbolType = CPTPlotSymbolType(rawValue: 1)!
        symbol.size = CGSize(width: 1, height: 1)
        symbol.fill = CPTFill(color: CPTColor.blue())
        return symbol
    }
    
    func configureHostView() {
        hostView.allowPinchScaling = false
    }
    
    func configureGraph() {
        let graph = CPTXYGraph(frame: hostView.bounds)
        graph.plotAreaFrame?.masksToBorder = false
        hostView.hostedGraph = graph
        
        graph.apply(CPTTheme(named: CPTThemeName.plainWhiteTheme))
        graph.fill = CPTFill(color: CPTColor.clear())
        graph.paddingBottom = 0.0
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.axisSet = nil
        
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Bold"
        titleStyle.fontSize = 16.0
        titleStyle.textAlignment = .center
        
        let xMin = 0.0
        let xMax = Double(data.count)
        let yMin = -yMax
        guard let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace else {return}
        plotSpace.xRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(xMin), lengthDecimal: CPTDecimalFromDouble(xMax - xMin))
        plotSpace.yRange = CPTPlotRange(locationDecimal: CPTDecimalFromDouble(yMin), lengthDecimal: CPTDecimalFromDouble(yMax - yMin))
    }
    
    func configureChart() {
        let graph = hostView.hostedGraph!
        let plot = CPTScatterPlot()
        plot.delegate = self
        plot.dataSource = self
        plot.identifier = NSString(string: "plot")
        
        let plotLineStyle = CPTMutableLineStyle()
        plotLineStyle.lineWidth = 1
        plotLineStyle.lineColor = CPTColor.black()
        plot.dataLineStyle = plotLineStyle
        
        graph.add(plot, to: graph.defaultPlotSpace)
    }
    
    func configureAxes() {}
}


















