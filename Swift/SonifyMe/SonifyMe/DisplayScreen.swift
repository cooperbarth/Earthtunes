import UIKit
import AVKit
import Foundation
import AudioToolbox
import CorePlot

class DisplayScreen : ViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var GraphTitle: UILabel!
    @IBOutlet weak var SoundSlideLayout: UISlider!
    @IBOutlet weak var PauseButton: UIButton!
    @IBOutlet weak var PlayButton: UIButton!
    @IBOutlet weak var FFButton: UIButton!
    @IBOutlet weak var RewindButton: UIButton!
    
    let data = UserDefaults.standard.array(forKey: "Data")!
    let yMax = UserDefaults.standard.double(forKey: "Max")
    
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
            player = try AVAudioPlayer(contentsOf: url!)
            playSound()
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
}


















