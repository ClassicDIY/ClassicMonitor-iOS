//
//  WizbangJRViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/25/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit

class WizbangJRViewController: UIViewController, GaugeCenterViewDelegate {

    @IBOutlet weak var gaugeWizbangJR: GaugeCenterView!
    @IBOutlet var battery: BatteryView!

    //MARK: Demo variables
    var velocity: Double        = 0
    var acceleration: Double    = 4
    //MARK: End Demo Variables
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear WizbangJRViewController")
        invalidateTimer()
    }
    
    @objc func appMovedToBackground() {
        if kDebugLog{ print("appMovedToBackground") }
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        print("Prefered Barstatus Style")
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        //MARK: Power
        gaugeWizbangJR.ringBackgroundColor = .black
        gaugeWizbangJR.valueTextColor = .white
        gaugeWizbangJR.unitOfMeasurementTextColor = UIColor(white: 0.7, alpha: 1)
        gaugeWizbangJR.setNeedsDisplay()
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
    
    func createTimer() {
        // 1
        if timer == nil {
            // 2
            timer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(demoMode),
                                         userInfo: nil,
                                         repeats: true)
        }
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc func demoMode() {
        if kDebugLog { print("Setting Demo Mode Values") }
        let randomDouble = Double.random(in: -16..<16)
        velocity = randomDouble
        gaugeWizbangJR.value        = velocity
        battery.level = Int(velocity.rounded() + 55)
    }
}
