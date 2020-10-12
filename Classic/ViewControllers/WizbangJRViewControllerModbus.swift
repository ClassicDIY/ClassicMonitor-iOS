//
//  WizbangJRViewControllerModbus.swift
//  Classic
//
//  Created by Urayoan Miranda on 10/8/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit

class WizbangJRViewControllerModbus: UIViewController, GaugeCenterViewDelegate {
    
    @IBOutlet weak var gaugeWizbangJR:              GaugeCenterView!
    @IBOutlet var battery:                          BatteryView!
    @IBOutlet weak var batterySOC:                  UILabel!
    @IBOutlet weak var buttonDeviceDescription:     UIButton!
    
    //@IBOutlet weak var centerButtonHeightConstraint: NSLayoutConstraint!
    //@IBOutlet weak var centerButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerGaugeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerGaugeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var batteryWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var batteryHeightConstraint: NSLayoutConstraint!
    
    var classicURL: NSString    = ""
    var classicPort: Int32      = 502
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil
    
    var reachability: Reachability?
    
    var selectedCurve: UIView.AnimationCurve = .easeInOut
    
    convenience init() {
        self.init()
    }
    
    deinit {
        stopNotifier()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optimizeForDeviceSize()
        //print("Constraints \(centerGaugeWidthConstraint) \(centerButtonWidthConstraint)")
        if kDebugLog { print("Recived Parameter: \(classicURL) - \(classicPort)") }
        // Do any additional setup after loading the view.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func optimizeForDeviceSize() {
        // Adjust album size to fit iPhone 4s, 6s & 6s+
        let deviceHeight = self.view.bounds.height
        print("Device Height \(deviceHeight)")
        if deviceHeight == 480 { //iPhone 4
            centerGaugeWidthConstraint.constant     = 180
            centerGaugeHeightConstraint.constant    = 180
            batteryWidthConstraint.constant         = batteryWidthConstraint.constant * 0.75
            batteryHeightConstraint.constant        = batteryHeightConstraint.constant * 0.75
            view.updateConstraints()
        }
        else if deviceHeight == 568 { //MARK: iPhone 5
            centerGaugeWidthConstraint.constant     = 200
            centerGaugeHeightConstraint.constant    = 200
            batteryWidthConstraint.constant         = batteryWidthConstraint.constant * 0.80
            batteryHeightConstraint.constant        = batteryHeightConstraint.constant * 0.80
            view.updateConstraints()
        }
        else if deviceHeight == 667 {
            centerGaugeWidthConstraint.constant     = 260
            centerGaugeHeightConstraint.constant    = 260
            view.updateConstraints()
        }
        else if deviceHeight == 896 { //MARK: iPhone 11 Pro
            centerGaugeWidthConstraint.constant     = 370
            centerGaugeHeightConstraint.constant    = 370
            view.updateConstraints()
        }
        else if deviceHeight == 1024 { //MARK: iPhone 11 Pro
            centerGaugeWidthConstraint.constant     = 430
            centerGaugeHeightConstraint.constant    = 430
            view.updateConstraints()
        }
        //else if deviceHeight > 667 {
        //    view.updateConstraints()
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if kDebugLog{ print("viewWillAppear") }
        configureGaugeViews()
        self.buttonDeviceDescription.setTitle("State of Charge", for: .normal)
        //MARK: Para verificar cuando cae en el background
        stopNotifier()
        setupReachability(classicURL as String, useClosures: true)
        startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if kDebugLog{ print("viewWillDisappear") }
        disconnectFromDevice()
        stopNotifier()
        //self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disconnectFromDevice()
        stopNotifier()
        if kDebugLog{ print("viewDidDisappear") }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("Prefered Barstatus Style")
        return .lightContent
    }
    
    func createTimer() {
        // 1
        if timer == nil {
            // 2
            timer = Timer.scheduledTimer(timeInterval: 2.0,
                                         target: self,
                                         selector: #selector(readValues),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func appMovedToBackground() {
        if kDebugLog{ print("appMovedToBackground") }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func rotated() {
        switch UIDevice.current.orientation {
        case .unknown:
            print("unknown")
        case .portrait:
            print("Portrait")
            gaugeWizbangJR.rotateCustom(rotation: CGFloat.pi*2, duration: 1.0, options: selectedCurve.animationOption)
            battery.rotateCustom(rotation: CGFloat.pi*2, duration: 1.0, options: selectedCurve.animationOption)
            batterySOC.rotateCustom(rotation: CGFloat.pi*2, duration: 1.0, options: selectedCurve.animationOption)
        case .portraitUpsideDown:
            print("Upside Down")
            gaugeWizbangJR.rotateCustom(rotation: CGFloat.pi, duration: 1.0, options: selectedCurve.animationOption)
            battery.rotateCustom(rotation: CGFloat.pi, duration: 1.0, options: selectedCurve.animationOption)
            batterySOC.rotateCustom(rotation: CGFloat.pi, duration: 1.0, options: selectedCurve.animationOption)
        case .landscapeLeft:
            print("Landscape MqttViewController")
            //gaugePowerView.rotate(value: CGFloat.pi/2)
            gaugeWizbangJR.rotateCustom(rotation: CGFloat.pi/2, duration: 1.0, options: selectedCurve.animationOption)
            battery.rotateCustom(rotation: CGFloat.pi/2, duration: 1.0, options: selectedCurve.animationOption)
            batterySOC.rotateCustom(rotation: CGFloat.pi/2, duration: 1.0, options: selectedCurve.animationOption)
        case .landscapeRight:
            print("Landscape MqttViewController")
            gaugeWizbangJR.rotateCustom(rotation: CGFloat.pi*3/2, duration: 1.0, options: selectedCurve.animationOption)
            battery.rotateCustom(rotation: CGFloat.pi*3/2, duration: 1.0, options: selectedCurve.animationOption)
            batterySOC.rotateCustom(rotation: CGFloat.pi*3/2, duration: 1.0, options: selectedCurve.animationOption)
        case .faceUp:
            print("Face Up")
        case .faceDown:
            print("Face Down")
        @unknown default:
            return
        }
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        if (hostName == "demo") {
            createTimer()
        } else {
            let reachability: Reachability?
            if let hostName = hostName {
                reachability = try? Reachability(hostname: hostName)
            } else {
                reachability = try? Reachability()
            }
            self.reachability = reachability
            if kDebugLog { print("--- Set up with host name: \(String(describing: hostName))") }
            if useClosures {
                reachability?.whenReachable = { reachability in
                    self.createTimer()
                }
                reachability?.whenUnreachable = { reachability in
                    self.invalidateTimer()
                    //self.swiftLibModbus!.disconnect()
                }
            } else {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(reachabilityChanged(_:)),
                    name: .reachabilityChanged,
                    object: reachability
                )
            }
        }
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            self.invalidateTimer()
            //self.swiftLibModbus!.disconnect()
        } else {
            self.createTimer()
        }
    }
    
    func startNotifier() {
        if kDebugLog { print("--- start notifier") }
        do {
            try reachability?.startNotifier()
        } catch {
            if kDebugLog { print("Unable to start notifier") }
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .wifi:
            if kDebugLog { print("Reachable via WiFi") }
            connectToDevice()
        case .cellular:
            if kDebugLog { print("Reachable via Cellular") }
            connectToDevice()
        case .unavailable:
            if kDebugLog { print("Network not reachable") }
            disconnectFromDevice()
        case .none:
            if kDebugLog {print("Unknown") }
            disconnectFromDevice()
        }
    }
    
    func configureGaugeViews() {
        battery.borderWidth = 7
        //MARK: Configure Buttons
        buttonDeviceDescription.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20) ?? UIFont.systemFont(ofSize: 20)
        buttonDeviceDescription.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        
        //MARK: Gauge WizbangJR View
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        //MARK: Power
        gaugeWizbangJR.ringBackgroundColor = .black
        gaugeWizbangJR.valueTextColor = .white
        gaugeWizbangJR.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeWizbangJR.setNeedsDisplay()
        
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugeWizbangJR.divisionsRadius          = 1.25 * ratio
        gaugeWizbangJR.subDivisionsRadius       = (1.25 - 0.5) * ratio
        gaugeWizbangJR.upperText                = "Power"
        gaugeWizbangJR.valueFont                = UIFont(name: GaugeView.defaultFontName, size: CGFloat(80 * ratio))!
        gaugeWizbangJR.unitOfMeasurementFont    = UIFont(name: GaugeView.defaultFontName, size: CGFloat(12 * ratio))!
        gaugeWizbangJR.minMaxValueFont          = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        gaugeWizbangJR.upperTextFont            = UIFont(name: GaugeView.defaultFontName, size: CGFloat(18 * ratio))!
        // Update gauge view
        gaugeWizbangJR.minValue                 = -32
        gaugeWizbangJR.maxValue                 = 32
        gaugeWizbangJR.limitValue               = 0
        gaugeWizbangJR.unitOfMeasurement        = "Amps"
        
    }
    
    func ringStokeColor(gaugeView: GaugeCenterView, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        //if nightModeSwitch.isOn {
        //    return UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
        //}
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }
    
    func connectToDevice() {
        self.createTimer()
    }
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        invalidateTimer()
        //self.swiftLibModbus!.disconnect()
        stopNotifier()
    }
    
    @objc func readValues() {
        if (classicURL == "demo") {
            demoMode()
        } else {
            DataManager.readRegistersValues(classicURL: classicURL as NSString, classicPort: classicPort, device: 1, startAddress: 4360, count: 22) { array, error in
                //print("ENTRO AL DATAMANAGER: \(String(describing: array))")
                if error != nil {
                    if kDebugLog { print("Error nil - ViewControllers: \(String(describing: error))") }
                } else {
                    //MARK: Data Example
                    //Received Data 1: [53, 7, 0, 0, 80, 0, 65461, 65535, 4, 0, 65530, 10068, 98, 65535, 65535, 4, 196, 38216, 250, 0, 200, 49]
                    if kDebugLog { print("Received Data 1: \(String(describing: array))") }
                    let whizbangBatCurrent      = array?[10] as! NSNumber
                    let batteryCurrent          = Int8(truncating: whizbangBatCurrent)
                    self.gaugeWizbangJR.value   = Double(batteryCurrent)/10
                    let socVal                  = array?[12] as? Int8 ?? 0
                    self.battery.level          = Int(socVal)
                    self.batterySOC.text        = "\(socVal)%"
                }
            }
        }
    }
    
    func demoMode() {
        if kDebugLog { print("Setting Demo Mode Values") }
        // Calculate velocity
        buttonDeviceDescription.setTitle("Classic Demo", for: .normal)
        //self.stageButton.setTitle("Demo Mode", for: .normal)
        //velocity += timeDelta * acceleration
        //if velocity > gaugePowerView.maxValue {
        //    velocity = gaugePowerView.maxValue
        //    acceleration = -500
        //}
        //if velocity < gaugePowerView.minValue {
        //    velocity = gaugePowerView.minValue
        //    acceleration = 500
        //}
        
        // Set value for gauge view
        //gaugePowerView.value        = velocity
        //gaugeInputView.value        = velocity / 6
        //gaugeEnergyView.value       = velocity / 200
        //gaugeBatteryAmpsView.value  = velocity / 60
        //gaugeBatteryVoltsView.value = velocity / 80
    }
}
