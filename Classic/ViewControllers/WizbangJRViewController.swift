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

    //MARK: Demo variables
    var velocity: Double        = 0
    var acceleration: Double    = 500
    //MARK: End Demo Variables
    
    var timeDelta: Double       = 10.0/24 //MARK: For the timer to read
    var timer: Timer?           = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func demoMode() {
        if kDebugLog { print("Setting Demo Mode Values") }
        // Calculate velocity
        velocity += timeDelta * acceleration
        if velocity > gaugeWizbangJR.maxValue {
            velocity = gaugeWizbangJR.maxValue
            acceleration = -1
        }
        if velocity < gaugeWizbangJR.minValue {
            velocity = gaugeWizbangJR.minValue
            acceleration = 1
        }
        // Set value for gauge view
        gaugeWizbangJR.value        = velocity
    }
}
