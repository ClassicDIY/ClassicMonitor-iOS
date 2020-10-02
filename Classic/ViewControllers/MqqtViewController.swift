//
//  MqqtViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/30/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
// https://stackoverflow.com/questions/41065876/mqtt-client-using-moscapsule-in-swift-3


import UIKit
import MQTTClient

class MqqtViewController: UIViewController, MQTTSessionDelegate, GaugeViewDelegate  {
    
    @IBOutlet weak var gaugePowerView:          GaugeView!
    @IBOutlet weak var gaugeEnergyView:         GaugeView!
    @IBOutlet weak var gaugeInputView:          GaugeView!
    @IBOutlet weak var gaugeBatteryAmpsView:    GaugeView!
    @IBOutlet weak var gaugeBatteryVoltsView:   GaugeView!
    @IBOutlet weak var buttonDeviceDescription: UIButton!
    @IBOutlet weak var buttonReturn:            UIButton!
    @IBOutlet weak var stageButton:             UIButton!
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil
    
    var classicURL: NSString    = ""
    var classicPort: Int32      = 502
    
    var reachability: Reachability?
    
    private var session = MQTTSession()!
    private var subscribed = false

    convenience init() {
        self.init()
    }
    
    deinit {
        stopNotifier()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGaugeViews()
        session.transport       = MQTTCFSocketTransport()
        session.transport.host  = "mqtt.dioty.co"
        session.transport.port  = 1883
        session.userName        = "urayoan.miranda@gmail.com"
        session.password        = "8d2176c3"
        session.clientId        = "Classic_Monitor"
        session.delegate        = self
        
        //MARK: First Connect to server
        connectDisconnect()
        publish()
    }
    
    @objc func appMovedToBackground() {
        if kDebugLog{ print("appMovedToBackground") }
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
    

    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        switch eventCode {
        case .connected:
            //self.status.text = "Connected"
            print("MQTT Connected")
            publish()
            subscribeUnsubscribe()
        case .connectionClosed:
            //self.status.text = "Closed"
            print("MQTT Closed")
            subscribeUnsubscribe()
        case .connectionClosedByBroker:
            //self.status.text = "Closed by Broker"
            print("MQTT Closed by Broker")
        case .connectionError:
            //self.status.text = "Error"
            print("MQTT Error")
        case .connectionRefused:
            //self.status.text = "Refused"
            print("MQTT Refused")
        case .protocolError:
            //self.status.text = "Protocol Error"
            print("MQTT Protocol Error")
        @unknown default:
            print("MQTT Unkown")
            return
        }
    }
    
    func newMessage(_ session: MQTTSession!, data: Data!, onTopic topic: String!, qos: MQTTQosLevel, retained: Bool, mid: UInt32) {
        if data != nil {
            let decoder = JSONDecoder()
            do {
                let readings = try decoder.decode(MQTTDataReading.self, from: data)
                print("READINGS: \(readings)")
            } catch {
                debugPrint("Error in JSON Parsing")
            }
        }
    }
    
    func subAckReceived(_ session: MQTTSession!, msgID: UInt16, grantedQoss qoss: [NSNumber]!) {
        self.subscribed                 = true
        print("Subscribed")
    }
    
    func unsubAckReceived(_ session: MQTTSession!, msgID: UInt16) {
        self.subscribed                 = false
        print("Unsubscribed")
    }
    
    func subscribeUnsubscribe() {
        if self.subscribed {
            print("Unsuscribed")
            session.unsubscribeTopic(" /urayoan.miranda@gmail.com/CLASSIC250/stat/readings")
        } else {
            print("Suscribed")
            session.subscribe(toTopic: "/urayoan.miranda@gmail.com/CLASSIC250/stat/readings", at: .atMostOnce)
        }
        
    }
    func publish() {
        print("PUBLISH")
        self.session.publishData(("{\"wake\"}").data(using: String.Encoding.utf8, allowLossyConversion: false),
                                 onTopic: "/urayoan.miranda@gmail.com/CLASSIC250/cmnd",
                                 retain: false,
                                 qos: .atMostOnce)
    }
    
    func connectDisconnect() {
        switch self.session.status {
        case .connected:
            self.session.disconnect()
        case .closed, .created, .error:
            self.session.connect()
        default:
            return
        }
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
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachability = nil
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
    
    func createTimer() {
        // 1
        if timer == nil {
            // 2
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(readValues),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    @objc func readValues() {
       print("READ VALUES TODO")
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
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
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        invalidateTimer()
        //self.swiftLibModbus!.disconnect()
        stopNotifier()
    }
    
    func configureGaugeViews() {
        //MARK: Configure Buttons
        buttonDeviceDescription.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20) ?? UIFont.systemFont(ofSize: 20)
        buttonDeviceDescription.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        
        stageButton.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 24) ?? UIFont.systemFont(ofSize: 24)
        stageButton.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        
        buttonReturn.titleLabel?.font =  UIFont(name: GaugeView.defaultFontName, size: 20) ?? UIFont.systemFont(ofSize: 20)
        buttonReturn.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .normal)
        buttonReturn.tintColor = UIColor(white: 0.7, alpha: 1)
        
        // Configure gauge view
        //MARK: Gauge Power View
        let screenMinSize = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        let ratio = Double(screenMinSize)/320
        gaugePowerView.divisionsRadius          = 1.25 * ratio
        gaugePowerView.subDivisionsRadius       = (1.25 - 0.5) * ratio
        gaugePowerView.ringThickness            = 6 * ratio
        //print("RING THICKNESS: \(6 * ratio)")
        gaugePowerView.valueFont                = UIFont(name: GaugeView.defaultFontName, size: CGFloat(80 * ratio))!
        gaugePowerView.unitOfMeasurementFont    = UIFont(name: GaugeView.defaultFontName, size: CGFloat(12 * ratio))!
        gaugePowerView.minMaxValueFont          = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        gaugePowerView.upperTextFont            = UIFont(name: GaugeView.defaultFontName, size: CGFloat(24 * ratio))!
        //powerLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(24 * ratio))!
        //powerLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugePowerView.minValue = 0
        gaugePowerView.maxValue = 3500
        gaugePowerView.limitValue = 0
        gaugePowerView.unitOfMeasurement = "Watts"
        
        //MARK: Gauge Energy View
        gaugeEnergyView.divisionsRadius = 1.25 * ratio
        gaugeEnergyView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeEnergyView.ringThickness = 4 * ratio
        gaugeEnergyView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(30 * ratio))!
        gaugeEnergyView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeEnergyView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(8 * ratio))!
        //energyLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        //energyLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeEnergyView.minValue = 0
        gaugeEnergyView.maxValue = 10
        gaugeEnergyView.limitValue = 0
        gaugeEnergyView.unitOfMeasurement = "kWh"
        
        //MARK: Battery Volts
        gaugeBatteryVoltsView.divisionsRadius = 1.25 * ratio
        gaugeBatteryVoltsView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeBatteryVoltsView.ringThickness = 4 * ratio
        gaugeBatteryVoltsView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(30 * ratio))!
        gaugeBatteryVoltsView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeBatteryVoltsView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(8 * ratio))!
        //voltsLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        //voltsLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeBatteryVoltsView.minValue = 0.0
        gaugeBatteryVoltsView.maxValue = 67.0
        gaugeBatteryVoltsView.limitValue = 0.0
        gaugeBatteryVoltsView.unitOfMeasurement = "Volts"
        
        //MARK: Battery Amps
        gaugeBatteryAmpsView.divisionsRadius = 1.25 * ratio
        gaugeBatteryAmpsView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeBatteryAmpsView.ringThickness = 4 * ratio
        gaugeBatteryAmpsView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(30 * ratio))!
        gaugeBatteryAmpsView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeBatteryAmpsView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(8 * ratio))!
        //batAmpsLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        //batAmpsLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeBatteryAmpsView.minValue = 0.0
        gaugeBatteryAmpsView.maxValue = 55.0
        gaugeBatteryAmpsView.limitValue = 0.0
        gaugeBatteryAmpsView.unitOfMeasurement = "Amps"
        
        //MARK: Input Volts
        gaugeInputView.divisionsRadius = 1.25 * ratio
        gaugeInputView.subDivisionsRadius = (1.25 - 0.5) * ratio
        gaugeInputView.ringThickness = 4 * ratio
        gaugeInputView.valueFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(30 * ratio))!
        gaugeInputView.unitOfMeasurementFont = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        gaugeInputView.minMaxValueFont = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(8 * ratio))!
        //inputLabel.font = UIFont(name: GaugeView.defaultFontName, size: CGFloat(10 * ratio))!
        //inputLabel.textColor = UIColor(white: 0.7, alpha: 1)
        // Update gauge view
        gaugeInputView.minValue = 0
        gaugeInputView.maxValue = 250
        gaugeInputView.limitValue = 0
        gaugeInputView.unitOfMeasurement = "Volts"
        
        //getChargerConnectValues()
    }
}
