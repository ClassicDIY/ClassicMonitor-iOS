//
//  ConsumptionViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 10/5/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import Foundation
import UIKit
import MQTTClient

class ConsumptionViewControllerMqtt: UIViewController, GaugeViewDelegate, MQTTSessionDelegate {
    
    @IBOutlet weak var gaugeConsumptionView:        GaugeView!
    @IBOutlet weak var buttonDeviceDescription:     UIButton!
    
    @IBOutlet weak var centerButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerGaugeWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerGaugeHeightConstraint: NSLayoutConstraint!
        
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
    
    var selectedCurve: UIView.AnimationCurve = .easeInOut
    
    convenience init() {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD ConsumptionViewControllerMqtt")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureGaugeViews()
        print("Received Parameters ConsumptionViewController: \(classicURL) - \(classicPort) - \(mqttUser) - \(mqttPassword) - \(mqttTopic) - \(classicName)")
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
    
    func ringStokeColor(gaugeView: GaugeView, value: Double) -> UIColor {
        if value >= gaugeView.limitValue {
            return UIColor(red: 1, green: 59.0/255, blue: 48.0/255, alpha: 1)
        }
        //if nightModeSwitch.isOn {
        //    return UIColor(red: 76.0/255, green: 217.0/255, blue: 100.0/255, alpha: 1)
        //}
        return UIColor(red: 11.0/255, green: 150.0/255, blue: 246.0/255, alpha: 1)
    }
    
    @objc func publish() {
        print("PUBLISH TO TOPIC: \(mqttTopic)\(classicName)/cmnd")
        self.session.publishData(("{\"wake\"}").data(using: String.Encoding.utf8, allowLossyConversion: false),
                                 onTopic: "\(mqttTopic)\(classicName)/cmnd",
                                 retain: false,
                                 qos: .atMostOnce)
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
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        connectDisconnect()
        invalidateTimer()
    }
    
    func invalidateTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    func setValuesInfo(info: MQTTDataInfo) {
        //self.buttonDeviceDescription.setTitle(info.model, for: .normal)
    }
    
    func setValues(readings: MQTTDataReading) {
        print("SET VALUES TO GAUGE \(readings)")
        let batteryCurrent  = readings.WhizbangBatCurrent
        let loadCurrent     = readings.BatCurrent! - batteryCurrent!
        let batteryVolts    = readings.BatVoltage
        self.gaugeConsumptionView.value    = Double(loadCurrent * batteryVolts!)
    }
    
    func handleEvent(_ session: MQTTSession!, event eventCode: MQTTSessionEvent, error: Error!) {
        switch eventCode {
        case .connected:
            //self.status.text = "Connected"
            print("MQTT Connected")
            publish()
            suscribe()
        case .connectionClosed:
            //self.status.text = "Closed"
            print("MQTT Closed")
            unSuscribe()
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
    
    func suscribe() {
        session.subscribe(toTopic: "\(mqttTopic)#", at: .atMostOnce)
    }
    
    func unSuscribe() {
        session.unsubscribeTopic("\(mqttTopic)#")
    }
}
