//
//  WizbangJRViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/25/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit
import MQTTClient

class WizbangJRViewController: UIViewController, GaugeCenterViewDelegate, MQTTSessionDelegate {

    @IBOutlet weak var gaugeWizbangJR: GaugeCenterView!
    @IBOutlet var battery: BatteryView!
    @IBOutlet weak var batterySOC: UILabel!
    
    var classicURL: String      = ""
    var classicPort: Int32      = 1883
    var mqttUser: String        = ""
    var mqttPassword: String    = ""
    var mqttTopic: String       = ""
    var classicName: String     = ""
    
    private var session = MQTTSession()!
    private var subscribed = false

    //MARK: Demo variables
    var velocity: Double        = 0
    var acceleration: Double    = 4
    //MARK: End Demo Variables
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        configureGaugeViews()
        // Do any additional setup after loading the view.

        //stopNotifier()
        //setupReachability(classicURL as String, useClosures: true)
        //startNotifier()
        //MARK: First Connect to server
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc func appMovedToBackground() {
        if kDebugLog{ print("appMovedToBackground") }
        self.dismiss(animated: true, completion: nil)
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
        gaugeWizbangJR.ringThickness            = 12 * ratio
        gaugeWizbangJR.valueFont                = UIFont(name: GaugeView.defaultFontName, size: CGFloat(140 * ratio))!
        gaugeWizbangJR.unitOfMeasurementFont    = UIFont(name: GaugeView.defaultFontName, size: CGFloat(16 * ratio))!
        gaugeWizbangJR.minMaxValueFont          = UIFont(name: GaugeView.defaultMinMaxValueFont, size: CGFloat(12 * ratio))!
        // Update gauge view
        gaugeWizbangJR.minValue = -16
        gaugeWizbangJR.maxValue = 16
        gaugeWizbangJR.limitValue = 0
        gaugeWizbangJR.unitOfMeasurement = "Amps"
        
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
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func disconnectFromDevice() {
        if kDebugLog { print("Disconnect") }
        connectDisconnect()
        invalidateTimer()
    }
    
    func setValues(readings: MQTTDataReading) {
        print("SET VALUES TO GAUGE \(readings)")
        self.gaugeWizbangJR.value   = Double(readings.NetAmpHours!)
        self.battery.level          = readings.SOC!
        self.batterySOC.text        = "\(readings.SOC ?? 0)%"
        
        
        /** switch (readings.ChargeState) {
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
        }**/
    }
    
    func setValuesInfo(info: MQTTDataInfo) {
        //self.buttonDeviceDescription.setTitle(info.model, for: .normal)
    }
}
