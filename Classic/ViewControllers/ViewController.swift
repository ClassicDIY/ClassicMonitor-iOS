//
//  ViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/7/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//
//MARK: Timer example
//https://www.raywenderlich.com/113835-ios-timer-tutorial
//https://medium.com/@dkw5877/reachability-in-ios-172fc3709a37

//Discovery
//https://stackoverflow.com/questions/27650143/receiving-ssdp-response-using-cocoaasyncsocket-in-swift

//https://stackoverflow.com/questions/28760541/programmatically-go-back-to-previous-viewcontroller-in-swift

import UIKit

class ViewController: UIViewController, GaugeViewDelegate, GaugeViewFloatDelegate {
    
    @IBOutlet weak var gaugePowerView:          GaugeView!
    @IBOutlet weak var gaugeEnergyView:         GaugeViewFloat!
    @IBOutlet weak var gaugeInputView:          GaugeViewFloat!
    @IBOutlet weak var gaugeBatteryAmpsView:    GaugeViewFloat!
    @IBOutlet weak var gaugeBatteryVoltsView:   GaugeView!
    @IBOutlet weak var powerLabel:              UILabel!
    @IBOutlet weak var energyLabel:             UILabel!
    @IBOutlet weak var voltsLabel:              UILabel!
    @IBOutlet weak var inputLabel:              UILabel!
    @IBOutlet weak var batAmpsLabel:            UILabel!
    @IBOutlet weak var buttonDeviceDescription: UIButton!
    @IBOutlet weak var buttonReturn:            UIButton!
    
    //@IBOutlet weak var deviceModel: UILabel!
    
    var classicURL: NSString    = ""
    var classicPort: Int32      = 0
    
    var isConnected: Bool       = false
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil
    var swiftLibModbus:         SwiftLibModbus?
    
    var reachability: Reachability?
    
    //MARK: To store and retrieve connect values
    let defaults          = UserDefaults.standard
    struct defaultsKeys {
        static let keyOne = "classicURL"
        static let keyTwo = "classicPort"
    }
    
    convenience init() {
        self.init()
    }
    
    deinit {
        stopNotifier()
        swiftLibModbus = nil
        //swiftLibModbus.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Recived Parameter: \(classicURL) - \(classicPort)")
        swiftLibModbus = SwiftLibModbus(ipAddress: classicURL, port: classicPort, device: 1)
        // Do any additional setup after loading the view.
        configureGaugeViews()
        //MARK: Para verificar cuando cae en el background
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        //getChargerConnectValues()
    }
    
    @objc func appMovedToBackground() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if kDebugLog{ print("viewWillAppear") }
        stopNotifier()
        setupReachability(classicURL as String, useClosures: true)
        startNotifier()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if kDebugLog{ print("viewWillDisappear") }
        disconnectFromDevice()
        //self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if kDebugLog{ print("viewDidDisappear") }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("Prefered Barstatus Style")
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        //MARK: Power
        gaugePowerView.ringBackgroundColor = .black
        gaugePowerView.valueTextColor = .white
        gaugePowerView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugePowerView.setNeedsDisplay()
        //MARK: Energy
        gaugeEnergyView.ringBackgroundColor = .black
        gaugeEnergyView.valueTextColor = .white
        gaugeEnergyView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeEnergyView.setNeedsDisplay()
        //MARK: Battery Volts
        gaugeBatteryVoltsView.ringBackgroundColor = .black
        gaugeBatteryVoltsView.valueTextColor = .white
        gaugeBatteryVoltsView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeBatteryVoltsView.setNeedsDisplay()
        
        //MARK: Battery Amps
        gaugeBatteryAmpsView.ringBackgroundColor = .black
        gaugeBatteryAmpsView.valueTextColor = .white
        gaugeBatteryAmpsView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeBatteryAmpsView.setNeedsDisplay()
        
        //MARK: Input Volts
        gaugeInputView.ringBackgroundColor = .black
        gaugeInputView.valueTextColor = .white
        gaugeInputView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeInputView.setNeedsDisplay()
        
        return .lightContent
    }
    
    func createTimer() {
        // 1
        isConnected.toggle()
        if timer == nil {
            // 2
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(readValues),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func ivalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func setChargerConnectValues() {
        defaults.set(classicURL, forKey: defaultsKeys.keyOne)
        defaults.set(classicPort, forKey: defaultsKeys.keyTwo)
    }
    
    func getChargerConnectValues() {
        //defaults.set(nil, forKey: defaultsKeys.keyOne)
        //defaults.set(nil, forKey: defaultsKeys.keyTwo)
        
        if let stringOne = defaults.string(forKey: defaultsKeys.keyOne) {
            print("String ONE: \(stringOne)") // Some String Value
        } else {
            defaults.set(classicURL, forKey: defaultsKeys.keyOne)
        }
        if let stringTwo = defaults.string(forKey: defaultsKeys.keyTwo) {
            print("String TWO: \(stringTwo)") // Another String Value
        } else {
            defaults.set(classicPort, forKey: defaultsKeys.keyTwo)
        }
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
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
                self.ivalidateTimer()
                self.swiftLibModbus!.disconnect()
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
    
    @objc func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.connection != .unavailable {
            self.ivalidateTimer()
            self.swiftLibModbus!.disconnect()
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
            disconnectFromDevice()
        case .unavailable:
            if kDebugLog { print("Network not reachable") }
            disconnectFromDevice()
        case .none:
            if kDebugLog {print("Unknown") }
            disconnectFromDevice()
        }
    }
    
    func configureGaugeViews() {
        //MARK: Configure Buttons
        buttonDeviceDescription.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20)
        buttonDeviceDescription.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        
        buttonReturn.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20)
        buttonReturn.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        buttonReturn.tintColor = UIColor(white: 0.7, alpha: 1)
        
        // Configure gauge view
        //MARK: Gauge Power View
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugePowerView.divisionsRadius = 1.25 * ratio
        gaugePowerView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugePowerView.ringThickness = 12 * ratio
        gaugePowerView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(140 * ratio))!
        gaugePowerView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gaugePowerView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        powerLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(24 * ratio))!
        powerLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugePowerView.minValue = 0
        gaugePowerView.maxValue = 3500
        gaugePowerView.limitValue = 0
        gaugePowerView.unitOfMeasurement = "Watts"
        
        //MARK: Gauge Energy View
        gaugeEnergyView.divisionsRadius = 1.25 * ratio
        gaugeEnergyView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeEnergyView.ringThickness = 4 * ratio
        gaugeEnergyView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(40 * ratio))!
        gaugeEnergyView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeEnergyView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(10 * ratio))!
        energyLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        energyLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeEnergyView.minValue = 0
        gaugeEnergyView.maxValue = 10
        gaugeEnergyView.limitValue = 0
        gaugeEnergyView.unitOfMeasurement = "kWh"
        
        //MARK: Battery Volts
        gaugeBatteryVoltsView.divisionsRadius = 1.25 * ratio
        gaugeBatteryVoltsView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeBatteryVoltsView.ringThickness = 4 * ratio
        gaugeBatteryVoltsView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(40 * ratio))!
        gaugeBatteryVoltsView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeBatteryVoltsView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(10 * ratio))!
        voltsLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        voltsLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeBatteryVoltsView.minValue = 0.0
        gaugeBatteryVoltsView.maxValue = 67.0
        gaugeBatteryVoltsView.limitValue = 0.0
        gaugeBatteryVoltsView.unitOfMeasurement = "Volts"
        
        //MARK: Battery Amps
        gaugeBatteryAmpsView.divisionsRadius = 1.25 * ratio
        gaugeBatteryAmpsView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeBatteryAmpsView.ringThickness = 4 * ratio
        gaugeBatteryAmpsView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(40 * ratio))!
        gaugeBatteryAmpsView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeBatteryAmpsView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(10 * ratio))!
        batAmpsLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        batAmpsLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeBatteryAmpsView.minValue = 0.0
        gaugeBatteryAmpsView.maxValue = 55.0
        gaugeBatteryAmpsView.limitValue = 0.0
        gaugeBatteryAmpsView.unitOfMeasurement = "Amps"
        
        //MARK: Input Volts
        gaugeInputView.divisionsRadius = 1.25 * ratio
        gaugeInputView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeInputView.ringThickness = 4 * ratio
        gaugeInputView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(40 * ratio))!
        gaugeInputView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeInputView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(10 * ratio))!
        inputLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        inputLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeInputView.minValue = 0
        gaugeInputView.maxValue = 250
        gaugeInputView.limitValue = 0
        gaugeInputView.unitOfMeasurement = "Volts"
        
        getChargerConnectValues()
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
    
    func ringStokeColorFloat(gaugeView: GaugeViewFloat, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        //if nightModeSwitch.isOn {
        //    return UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
        //}
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }
    
    func connectToDevice() {
        if (!isConnected) {
            swiftLibModbus!.connect(
                success: { () -> Void in
                    if kDebugLog { print("Conectado") }
                    self.createTimer()
            },
                failure: { (error: NSError) -> Void in
                    //Handle error
                    if kDebugLog { print("Error Connecting: \(error)") }
                    let message = "Failed to connect. Check your network and try again."
                    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                        case .cancel:
                            print("cancel")
                        case .destructive:
                            print("destructive")
                        @unknown default:
                            if kDebugLog { print("Unknown Default Error in Alert") }
                        }}))
                    self.present(alert, animated: true, completion: nil)
            })
        } else {
            if kDebugLog { print("Is already connected and getting data") }
        }
    }
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        ivalidateTimer()
        self.swiftLibModbus!.disconnect()
        isConnected.toggle()
        stopNotifier()
    }
    
    @objc func readValues() {
        swiftLibModbus!.readRegistersFrom(startAddress: 4100, count: 44,
                                          success: { (array: [AnyObject]) -> Void in
                                            if kDebugLog { print("Received Data 1: \(array)") }
                                            
                                            let unitId = Int(truncating: array[0] as! NSNumber)
                                            if kDebugLog { print("Unit Type: \(unitId & 0xFF) PCB revision: \(unitId >> 8 & 0xFF)") }
                                            switch (unitId & 0xFF) {
                                            case 150:
                                                if kDebugLog { print("Classic 150: \(unitId >> 8 & 0xFF)") }
                                                self.buttonDeviceDescription.setTitle("Classic 150", for: .normal)
                                            case 200:
                                                if kDebugLog { print("Classic 200: \(unitId >> 8 & 0xFF)") }
                                                self.buttonDeviceDescription.setTitle("Classic 200", for: .normal)
                                            case 250:
                                                if kDebugLog { print("Classic 250: \(unitId >> 8 & 0xFF)") }
                                                self.buttonDeviceDescription.setTitle("Classic 250", for: .normal)
                                            case 251:
                                                if kDebugLog { print("Classic 250 KS: \(unitId >> 8 & 0xFF)") }
                                                self.buttonDeviceDescription.setTitle("Classic 250 KS", for: .normal)
                                            default:
                                                if kDebugLog { print("Not Recognized") }
                                            }
                                            
                                            //MARK: Ejemplo de data actual
                                            //Received Data 1: [1274, 2018, 518, 10, 0, 41976, 3840, 24605, 0, 0, 56116, 38041, 24597, 1, 542, 1458, 184, 6, 1012, 1028, 75, 1776, 2432, 0, 11, 11929, 0, 22326, 0, 12292, 45568, 303, 524, 560, 0, 300, 502, 2, 7198, 184, 557, 11, 3600, 0]
                                            //https://stackoverflow.com/questions/39110991/calculating-most-and-least-significant-bytemsb-lsb-with-swift
                                            let reg6 = Int(truncating: array[5] as! NSNumber)
                                            let reg7 = Int(truncating: array[6] as! NSNumber)
                                            let reg8 = Int(truncating: array[7] as! NSNumber)
                                            
                                            let lsb6 = reg6 & 0xFF
                                            let msb6 = (reg6 >> 8) & 0xFF
                                            
                                            let lsb7 = reg7 & 0xFF
                                            let msb7 = (reg7 >> 8) & 0xFF
                                            
                                            let lsb8 = reg8 & 0xFF
                                            let msb8 = (reg8 >> 8) & 0xFF
                                            
                                            if kDebugLog { print("***************************") }
                                            if kDebugLog { print(String(format: "Mac Addess: %02x:%02x:%02x:%02x:%02x:%02x", msb8, lsb8, msb7, lsb7, msb6, lsb6)) }
                                            
                                            //Name
                                            //Value
                                            //Description
                                            //Classic150 Classic200 Classic250 Classic250 KS
                                            //150         Classic 150
                                            //200     Classic 200
                                            //250     Classic 250
                                            //251     Classic 250 with 120 V Battery bank capability (lower current than 250)
                                            
                                            let dispavgVbatt = Double(truncating: array[14] as! NSNumber) / 10
                                            if kDebugLog { print("Battery Volts: \(dispavgVbatt) V") }
                                            self.gaugeBatteryVoltsView.value = dispavgVbatt
                                            
                                            
                                            let dispavgVpv = Double(truncating: array[15] as! NSNumber) / 10
                                            if kDebugLog { print("Battery Volts: \(dispavgVpv) V") }
                                            self.gaugeInputView.value = dispavgVpv
                                            
                                            let IbattDisplayS = Double(truncating: array[16] as! NSNumber) / 10
                                            if kDebugLog { print("Battery Volts: \(IbattDisplayS) Amps") }
                                            self.gaugeBatteryAmpsView.value = IbattDisplayS
                                            
                                            
                                            let kWHours = Double(truncating: array[17] as! NSNumber) / 10
                                            self.gaugeEnergyView.value = kWHours
                                            if kDebugLog { print("Generated Energy : \(kWHours) kWatt-Hours") }
                                            
                                            let comboChargeStage = array[19]
                                            if kDebugLog { print("Charge Stage: \((Int(truncating: comboChargeStage as! NSNumber) >> 8) & 0xFF)") }
                                            if kDebugLog { print("Stage: \(Int(truncating: comboChargeStage as! NSNumber) & 0xFF)") }
                                            
                                            let watts = Double(truncating: array[18] as! NSNumber)
                                            self.gaugePowerView.value = watts
        },
                                          failure:  { (error: NSError) -> Void in
                                            //Handle error
                                            if kDebugLog { print("Error Getting Network Data 1: \(error)") }
                                            self.swiftLibModbus!.disconnect()
        })
    }
    
    func getData2() {
        swiftLibModbus!.readRegistersFrom(startAddress: 20480, count: 11,
                                          success: { (array: [AnyObject]) -> Void in
                                            if kDebugLog { print("Recived Network Data: \(array)") }
                                            //MARK: Ejemplo de data actual
                                            //Recived Network Data: [2, 43200, 12801, 43200, 257, 65535, 255, 43200, 257, 2056, 2056]
                                            let reg3 = Int(truncating: array[2] as! NSNumber)
                                            let reg2 = Int(truncating: array[1] as! NSNumber)
                                            
                                            let lsb3 = reg3 & 0xFF
                                            let msb3 = (reg3 >> 8) & 0xFF
                                            let lsb2 = reg2 & 0xFF
                                            let msb2 = (reg2 >> 8) & 0xFF
                                            if kDebugLog { print("IP Address: \(lsb2).\(msb2).\(lsb3).\(msb3)") }
        },
                                          failure:  { (error: NSError) -> Void in
                                            //Handle error
                                            if kDebugLog { print("Error Getting Network Data 2: \(error)") }
                                            self.swiftLibModbus!.disconnect()
        })
    }
}

