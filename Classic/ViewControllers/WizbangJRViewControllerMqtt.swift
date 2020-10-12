//
//  WizbangJRViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/25/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit
import MQTTClient

class WizbangJRViewControllerMqtt: UIViewController, GaugeCenterViewDelegate {

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
    
    
    var classicURL: String      = ""
    var classicPort: Int32      = 1883
    var mqttUser: String        = ""
    var mqttPassword: String    = ""
    var mqttTopic: String       = ""
    var classicName: String     = ""
    
    private var session         = MQTTSession()!

    //MARK: Demo variables
    var velocity: Double        = 0
    var acceleration: Double    = 4
    //MARK: End Demo Variables
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil
    
    var selectedCurve: UIView.AnimationCurve = .easeInOut
    
    convenience init() {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        optimizeForDeviceSize()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureGaugeViews()
        print("Received Parameters MqttViewController: \(classicURL) - \(classicPort) - \(mqttUser) - \(mqttPassword) - \(mqttTopic) - \(classicName)")
        session.transport       = MQTTCFSocketTransport()
        session.transport.host  = classicURL
        session.transport.port  = UInt32(classicPort)
        session.userName        = mqttUser //"urayoan.miranda@gmail.com"
        session.password        = mqttPassword//"8d2176c3"
        session.clientId        = "Classic_Monitor_WZ"
        session.delegate        = self
        connectDisconnect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear WizbangJRViewController")
        disconnectFromDevice()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("Prefered Barstatus Style")
        return .lightContent
    }
    
    func ringStokeColor(gaugeView: GaugeCenterView, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
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
}

extension WizbangJRViewControllerMqtt: MQTTSessionDelegate {
    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        switch eventCode {
        case .connected:
            //self.status.text = "Connected"
            print("MQTT Connected")
            publish()
            subscribe()
        case .connectionClosed:
            //self.status.text = "Closed"
            print("MQTT Closed")
            unSubscribe()
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
        print("Subscribed")
    }
    
    func unsubAckReceived(_ session: MQTTSession!, msgID: UInt16) {
        print("Unsubscribed")
    }
    
    func subscribe() {
        session.subscribe(toTopic: "\(mqttTopic)#", at: .atMostOnce)
    }
    
    func unSubscribe() {
        session.unsubscribeTopic("\(mqttTopic)#")
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
            self.invalidateTimer()
        case .closed, .created, .error:
            //MARK: Trata de conectarte
            self.session.connect()
            self.publish()
            self.createTimer()
        default:
            return
        }
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
        } else {
            invalidateTimer()
            timer = Timer.scheduledTimer(timeInterval: 55.0,
                                         target: self,
                                         selector: #selector(publish),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func invalidateTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        connectDisconnect()
        invalidateTimer()
    }
    
    func setValues(readings: MQTTDataReading) {
        print("SET VALUES TO GAUGE \(readings)")
        let batteryCurrent          = readings.WhizbangBatCurrent
        //let batteryVolts           = readings.BatVoltage
        //self.gaugeWizbangJR.value  = Double(batteryCurrent!) * Double(batteryVolts!)
        self.gaugeWizbangJR.value   = Double(batteryCurrent!)
        self.battery.level          = readings.SOC!
        self.batterySOC.text        = "\(readings.SOC ?? 0)%"
    }
    
    func setValuesInfo(info: MQTTDataInfo) {
        //self.buttonDeviceDescription.setTitle(info.model, for: .normal)
    }
}
