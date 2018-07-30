import UIKit
import AVKit
import Foundation
import AudioToolbox
import CorePlot

class DisplayScreen : ViewController {
    var data : [Float64] = [Float64]()
    var imgg : UIImage = UIImage()
    var yMax : Float64 = 0.0
    var yMin : Float64 = 0.0
    var TitleText : String = "Seismic Data"
    var playing : Bool = false
    
    @IBOutlet weak var GraphTitle: UILabel!
    @IBOutlet weak var SoundSlideLayout: UISlider!
    @IBOutlet weak var PlayPause: UIButton!
    
    @IBAction func PlayPausePressed(_ sender: Any) {
        if (self.playing) {
            pauseSound()
        } else {
            playSound()
        }
    }
    
    @IBAction func SoundSlider(_ sender: Any) {
        player?.currentTime = TimeInterval(SoundSlideLayout.value)
    }
    
    func playSound() {
        SoundSlideLayout.maximumValue = Float((player?.duration)!)
        player?.prepareToPlay()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        player?.play()
        self.playing = true
        PlayPause.setTitle("Pause", for: .normal)
    }
    
    @objc func updateSlider(_ timer: Timer) {
        SoundSlideLayout.value = Float((player?.currentTime)!)
    }
    
    func pauseSound() {
        if (player?.isPlaying)! {
            PlayPause.setTitle("Play", for: .normal)
            self.playing = false
            player?.stop()
        }
    }
    
    @IBAction func BackButton(_ sender: Any) {
        pauseSound()
        performSegue(withIdentifier: "BackToInput", sender: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player?.numberOfLoops = -1
            playSound()
        } catch {
            print("Audio Player Not Found.")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initplot()
        GraphTitle.text = TitleText
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
            return self.data[Int(idx)] as NSNumber
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


















