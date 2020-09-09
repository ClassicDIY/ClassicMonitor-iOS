//
//  ViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/7/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GaugeViewDelegate, GaugeViewFloatDelegate {
    
    @IBOutlet weak var gaugePowerView: GaugeView!
    @IBOutlet weak var gaugeEnergyView: GaugeViewFloat!
    @IBOutlet weak var gaugeInputView: GaugeView!
    @IBOutlet weak var gaugeBatteryAmpsView: GaugeViewFloat!
    @IBOutlet weak var gaugeBatteryVoltsView: GaugeViewFloat!
    
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var voltsLabel: UILabel!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var batAmpsLabel: UILabel!
    
    @IBOutlet weak var deviceModel: UILabel!
    
    var isConnected: Bool = false
    var timeDelta: Double = 10.0/24 //MARK: For the timer to read
    
    let swiftLibModbus = SwiftLibModbus(ipAddress: classicURL, port: classicPort, device: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureGaugeViews()
        // Create a timer to update value for gauge view
        Timer.scheduledTimer(timeInterval: timeDelta,
                             target: self,
                             selector: #selector(readValues),
                             userInfo: nil,
                             repeats: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
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
    
    func configureGaugeViews() {
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
    }
    
    func setStyle() {
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        //deviceModel.textColor = .white
        gaugePowerView.ringBackgroundColor = .black
        gaugePowerView.valueTextColor = .white
        gaugePowerView.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugePowerView.setNeedsDisplay()
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
    
    @IBAction func connect(_ sender: Any) {
        swiftLibModbus.connect(
            success: { () -> Void in
                if kDebugLog { print("Conectado") }
        },
            failure: { (error: NSError) -> Void in
                //Handle error
                if kDebugLog { print("error 1 \(error)") }
                self.swiftLibModbus.disconnect()
        })
    }
    
    //MARK: From ModbusTask.java del app de Android
    @IBAction func callFunction(_ sender: Any) {
        readValues()
    }
    
    @objc func readValues() {
        swiftLibModbus.readRegistersFrom(startAddress: 4100, count: 44,
                                         success: { (array: [AnyObject]) -> Void in
                                            if kDebugLog { print("Recived Data: \(array)") }
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
                                            
                                            if kDebugLog { print(String(format: "Mac Addess: %02x:%02x:%02x:%02x:%02x:%02x", msb8, lsb8, msb7, lsb7, msb6, lsb6)) }
                                            
                                            let unitId = Int(truncating: array[0] as! NSNumber)
                                            if kDebugLog { print("Unit Type: \(unitId & 0xFF) PCB revision: \(unitId >> 8 & 0xFF)") }
                                            
                                            switch (unitId & 0xFF) {
                                            case 150:
                                                if kDebugLog { print("Unit Type: Classic 150V Revision: \(unitId >> 8 & 0xFF)") }
                                            case 200:
                                                if kDebugLog { print("Unit Type: Classic 200V Revision: \(unitId >> 8 & 0xFF)") }
                                            case 250:
                                                if kDebugLog { print("Unit Type: Classic 250V Revision: \(unitId >> 8 & 0xFF)") }
                                            case 251:
                                                if kDebugLog { print("Unit Type: Classic 250V with 120V Battery bank capability (lower current than 250) Revision: \(unitId >> 8 & 0xFF)") }
                                            default:
                                                if kDebugLog { print("Not Recognized") }
                                            }
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
                                            
                                            //self.swiftLibModbus.disconnect()
        },
                                         failure:  { (error: NSError) -> Void in
                                            //Handle error
                                            print("error 2.1 \(error)")
                                            self.swiftLibModbus.disconnect()
        })
    }
    
    @IBAction func getData2(_ sender: Any) {
        swiftLibModbus.readRegistersFrom(startAddress: 20480, count: 11,
                                         success: { (array: [AnyObject]) -> Void in
                                            if kDebugLog { print("Recived Network Data: \(array)") }
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
                                            if kDebugLog { print("Error Getting Network Data \(error)") }
                                            self.swiftLibModbus.disconnect()
        })
    }
    
    @IBAction func disconnects(_ sender: Any) {
        if kDebugLog { print("Disconnect") }
        self.swiftLibModbus.disconnect()
    }
}

