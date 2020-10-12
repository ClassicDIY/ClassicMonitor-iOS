//
//  ConsumptionViewControllerModbus.swift
//  Classic
//
//  Created by Urayoan Miranda on 10/8/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit
import Foundation

class ConsumptionViewControllerModbus: UIViewController, GaugeViewDelegate {
    
    @IBOutlet weak var gaugeConsumptionView:        GaugeView!
    @IBOutlet weak var buttonDeviceDescription:     UIButton!
    @IBOutlet weak var centerButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerGaugeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerGaugeHeightConstraint: NSLayoutConstraint!
    
    var reachability: Reachability?
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil
    
    var classicURL: NSString      = ""
    var classicPort: Int32      = 502
    
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
        print("VIEW DID LOAD ConsumptionViewControllerModbus")
        optimizeForDeviceSize()
        //MARK: To check if app goes to background
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
            centerButtonWidthConstraint.constant    = 180
            centerButtonHeightConstraint.constant   = 180
            view.updateConstraints()
        }
        else if deviceHeight == 568 { //MARK: iPhone 5
            centerGaugeWidthConstraint.constant     = 200
            centerGaugeHeightConstraint.constant    = 200
            centerButtonWidthConstraint.constant    = 200
            centerButtonHeightConstraint.constant   = 200
            view.updateConstraints()
        }
        else if deviceHeight == 667 {
            centerGaugeWidthConstraint.constant     = 260
            centerGaugeHeightConstraint.constant    = 260
            centerButtonWidthConstraint.constant    = 260
            centerButtonHeightConstraint.constant   = 260
            view.updateConstraints()
        }
        else if deviceHeight == 896 { //MARK: iPhone 11 Pro
            centerGaugeWidthConstraint.constant     = 370
            centerGaugeHeightConstraint.constant    = 370
            centerButtonWidthConstraint.constant    = 370
            centerButtonHeightConstraint.constant   = 370
            view.updateConstraints()
        }
        else if deviceHeight == 1024 { //MARK: iPhone 11 Pro
            centerGaugeWidthConstraint.constant     = 430
            centerGaugeHeightConstraint.constant    = 430
            centerButtonWidthConstraint.constant    = 430
            centerButtonHeightConstraint.constant   = 430
            view.updateConstraints()
        }
        //else if deviceHeight > 667 {
        //    view.updateConstraints()
        //}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureGaugeViews()
        self.buttonDeviceDescription.setTitle("Consumption", for: .normal)
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
        if kDebugLog{ print("viewDidDisappear") }
        disconnectFromDevice()
        stopNotifier()
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
    
    @objc func readValues() {
        print("Read Values ConsumtionViewControllerModbus")
        if (classicURL == "demo") {
            demoMode()
        } else {
            DataManager.readRegistersValues(classicURL: classicURL as NSString, classicPort: classicPort, device: 1, startAddress: 4100, count: 44) { readData1, error in
                //print("ENTRO AL DATAMANAGER: \(String(describing: array))")
                if error != nil {
                    if kDebugLog { print("Error nil - ViewControllers: \(String(describing: error))") }
                    return
                } else {
                    if kDebugLog { print("Received Data Array1: \(String(describing: readData1))") }
                    DataManager.readRegistersValues(classicURL: self.classicURL as NSString, classicPort: self.classicPort, device: 1, startAddress: 4360, count: 22) { readData2, error in
                        if error != nil {
                            if kDebugLog { print("Error nil - ViewControllers: \(String(describing: error))") }
                            return
                        } else {
                            if kDebugLog { print("Received Data Array2: \(String(describing: readData2))") }
                            print("Received Data Array2: \(String(describing: readData2))")
                            let whizbangBatCurrent          = readData2?[10] as! NSNumber
                            let batteryCurrent              = Int8(truncating: whizbangBatCurrent)
                            let loadCurrent                 = Double(truncating: readData1?[16] as! NSNumber)/10 - Double(batteryCurrent)/10
                            let batteryVolts                = Double(truncating: readData1?[14] as! NSNumber)/10
                            self.gaugeConsumptionView.value = loadCurrent * batteryVolts
                        }
                    }
                }
            }
        }
    }
    
    func setValues(array1: [AnyObject], array2: [AnyObject]) {
        //print("ARRAY SIZE \(array1.count) - \(array2.count)")

        //From Android Graham do this
        /*float batteryCurrent = readings.getFloat(RegisterName.WhizbangBatCurrent);
                        float loadCurrent = readings.getFloat(RegisterName.BatCurrent) - batteryCurrent;
                        if (bidirectionalUnitsInWatts) {
                            float batteryVolts = readings.getFloat(RegisterName.BatVoltage);
                            gaugeView.setTargetValue(loadCurrent * batteryVolts);
                        } else {
                            gaugeView.setTargetValue(loadCurrent);
                        }*/
        //Received Data Array2: Optional([53, 11, 0, 0, 91, 0, 65452, 65535, 7, 0, 65535, 56148, 98, 65535, 65535, 3, 197, 14522, 250, 0, 200, 49])
        //Received Data Array1: Optional([1274, 2018, 518, 15, 0, 41976, 3840, 24605, 7, 0, 56116, 38041, 7616, 1, 534, 1669, 57, 28, 305, 1284, 20, 1736, 3520, 0, 50, 12410, 0, 23216, 0, 4100, 45568, 307, 519, 577, 0, 300, 502, 10328, 9600, 57, 480, 11, 0, 0])
        print("Values RAW: \(Double(truncating: array2[10] as! NSNumber)) - \(Double(truncating: array1[16] as! NSNumber)) - \(Double(truncating: array1[14] as! NSNumber))")

        let batteryCurrent              = Double(truncating: array2[10] as! NSNumber)/10
        
        let loadCurrent                 = Double(truncating: array1[16] as! NSNumber)/10 - batteryCurrent
        let batteryVolts                = Double(truncating: array1[14] as! NSNumber)/10
        print("Values: \(batteryCurrent) - \(loadCurrent) - \(batteryVolts)")
        self.gaugeConsumptionView.value = loadCurrent * batteryVolts
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
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
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
    
    func connectToDevice() {
        self.createTimer()
    }
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        invalidateTimer()
        //self.swiftLibModbus!.disconnect()
        stopNotifier()
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
            gaugeConsumptionView.rotateCustom(rotation: CGFloat.pi*2, duration: 1.0, options: selectedCurve.animationOption)
        case .portraitUpsideDown:
            print("Upside Down")
            gaugeConsumptionView.rotateCustom(rotation: CGFloat.pi, duration: 1.0, options: selectedCurve.animationOption)
        case .landscapeLeft:
            print("Landscape MqttViewController")
            //gaugePowerView.rotate(value: CGFloat.pi/2)
            gaugeConsumptionView.rotateCustom(rotation: CGFloat.pi/2, duration: 1.0, options: selectedCurve.animationOption)
            return
        case .landscapeRight:
            print("Landscape MqttViewController")
            gaugeConsumptionView.rotateCustom(rotation: CGFloat.pi*3/2, duration: 1.0, options: selectedCurve.animationOption)
        case .faceUp:
            print("Face Up")
        case .faceDown:
            print("Face Down")
        @unknown default:
            return
        }
    }
    
    func configureGaugeViews() {
        print("MQTT PAGE GAUGE VIEWS CONFIGURE")
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        //MARK: Power
        gaugeConsumptionView.ringBackgroundColor        = .black
        gaugeConsumptionView.valueTextColor             = .white
        gaugeConsumptionView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeConsumptionView.setNeedsDisplay()
        
        //MARK: Configure Buttons
        buttonDeviceDescription.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20) ?? UIFont.systemFont(ofSize: 20)
        buttonDeviceDescription.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        
        // Configure gauge view
        //MARK: Gauge Power View
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugeConsumptionView.divisionsRadius          = 1.25 * ratio
        gaugeConsumptionView.subDivisionsRadius       = (1.25 - 0.5) * ratio
        gaugeConsumptionView.ringThickness            = 6 * ratio
        //print("RING THICKNESS: \(6 * ratio)")
        gaugeConsumptionView.valueFont                = UIFont(name: GaugeView.defaultFontName, size: CGFloat(80 * ratio))!
        gaugeConsumptionView.unitOfMeasurementFont    = UIFont(name: GaugeView.defaultFontName, size: CGFloat(12 * ratio))!
        gaugeConsumptionView.minMaxValueFont          = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        gaugeConsumptionView.upperTextFont            = UIFont(name: GaugeView.defaultFontName, size: CGFloat(18 * ratio))!
        //powerLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(24 * ratio))!
        //powerLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeConsumptionView.minValue                 = 0
        gaugeConsumptionView.maxValue                 = 3500
        gaugeConsumptionView.limitValue               = 0
        gaugeConsumptionView.unitOfMeasurement        = "Watts"
    }
    
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        //if nightModeSwitch.isOn {
        //    return UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
        //}
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }
}
