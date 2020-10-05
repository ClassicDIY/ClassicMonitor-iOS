//
//  MqqtViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/30/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
// https://stackoverflow.com/questions/41065876/mqtt-client-using-moscapsule-in-swift-3


import UIKit
import MQTTClient

class MqttViewController: UIViewController, MQTTSessionDelegate, GaugeViewDelegate {
    
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
    
    var classicURL: String      = ""
    var classicPort: Int32      = 1883
    var mqttUser: String        = ""
    var mqttPassword: String    = ""
    var mqttTopic: String       = ""
    var classicName: String     = ""
    
    //var reachability: Reachability?
    
    private var session = MQTTSession()!
    private var subscribed = false
    
    convenience init() {
        self.init()
    }
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD MqttViewController")
        configureGaugeViews()
        //stopNotifier()
        //setupReachability(classicURL as String, useClosures: true)
        //startNotifier()
        //MARK: First Connect to server
        
        //MARK: To check if app goes to background
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        if kDebugLog{ print("appMovedToBackground") }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if kDebugLog{ print("viewWillAppear MqttViewController") }
        print("Received Parameters MqttViewController: \(classicURL) - \(classicPort) - \(mqttUser) - \(mqttPassword) - \(mqttTopic) - \(classicName)")
        self.buttonDeviceDescription.setTitle("Connecting to broker", for: .normal)
        self.stageButton.setTitle("Loading Stage", for: .normal)
        
        session.transport       = MQTTCFSocketTransport()
        session.transport.host  = classicURL
        session.transport.port  = UInt32(classicPort)
        session.userName        = mqttUser //"urayoan.miranda@gmail.com"
        session.password        = mqttPassword//"8d2176c3"
        session.clientId        = "Classic_Monitor"
        session.delegate        = self
        connectDisconnect()
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
        print("Prefered Barstatus Style MqttViewController MqttViewController")
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
        if (data != nil && topic != nil) {
            //let str1 = String(decoding: data, as: UTF8.self)
            //let str2 = topic
            //print("DATAURA: \(str1)")
            //print("TOPICURA: \(String(describing: str2))")
            
            if (topic.contains("info")) {
                let decoder = JSONDecoder()
                do {
                    let info = try decoder.decode(MQTTDataInfo.self, from: data)
                    print("INFO: \(info)")
                    setValuesInfo(info: info)
                } catch {
                    debugPrint("Error in JSON Parsing")
                }
                return
            } else if (topic.contains("readings")) {
                let decoder = JSONDecoder()
                do {
                    let readings = try decoder.decode(MQTTDataReading.self, from: data)
                    print("READINGS: \(readings)")
                    setValues(readings: readings)
                } catch {
                    debugPrint("Error in JSON Parsing")
                }
                return
            } else if (topic.contains("LWT")) {
                
            } else if (topic.contains("cmdn")) {
                
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
            session.unsubscribeTopic("\(mqttTopic)#")
        } else {
            print("Suscribed")
            session.subscribe(toTopic: "\(mqttTopic)#", at: .atMostOnce)
        }
        
    }
    @objc func publish() {
        print("PUBLISH TO TOPIC: \(mqttTopic)\(classicName)/cmnd")
        self.session.publishData(("{\"wake\"}").data(using: String.Encoding.utf8, allowLossyConversion: false),
                                 onTopic: "\(mqttTopic)\(classicName)/cmnd",
                                 retain: false,
                                 qos: .atMostOnce)
    }
    
    func connectDisconnect() {
        switch self.session.status {
        case .connected:
            //MARK: Desconecta
            self.session.disconnect()
        case .closed, .created, .error:
            //MARK: Trata de conectarte
            self.session.connect()
            self.publish()
            self.createTimer()
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
    
    func createTimer() {
        // 1
        if timer == nil {
            // 2
            timer = Timer.scheduledTimer(timeInterval: 55.0,
                                         target: self,
                                         selector: #selector(publish),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func setValues(readings: MQTTDataReading) {
        print("SET VALUES TO GAUGE \(readings)")
        self.gaugeBatteryVoltsView.value    = Double(readings.BatVoltage!)
        self.gaugeInputView.value           = Double(readings.PVVoltage!)
        self.gaugeBatteryAmpsView.value     = Double(readings.BatCurrent!)
        self.gaugeEnergyView.value          = Double(readings.EnergyToday!)
        //MARK: Energy Today
        self.gaugePowerView.value           = Double(readings.Power!)
        
        switch (readings.ChargeState) {
        case -1:
            self.stageButton.setTitle("", for: .normal)
        case 0:
            self.stageButton.setTitle("Resting", for: .normal)
        case 3:
            self.stageButton.setTitle("Absorb", for: .normal)
        case 4:
            self.stageButton.setTitle("Bulk MPPT", for: .normal)
        case 5:
            self.stageButton.setTitle("Float", for: .normal)
        case 6:
            self.stageButton.setTitle("Float MPPT", for: .normal)
        case 7:
            self.stageButton.setTitle("Equalized", for: .normal)
        case 10:
            self.stageButton.setTitle("HyperVoc", for: .normal)
        case 18:
            self.stageButton.setTitle("Equalizing", for: .normal)
        default:
            if kDebugLog { print("Not Recognized") }
            self.stageButton.setTitle("Unknown", for: .normal)
        }
    }
    
    func setValuesInfo(info: MQTTDataInfo) {
        self.buttonDeviceDescription.setTitle(info.model, for: .normal)
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        connectDisconnect()
        invalidateTimer()
    }
    
    func configureGaugeViews() {
        print("MQTT PAGE GAUGE VIEWS CONFIGURE")
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
