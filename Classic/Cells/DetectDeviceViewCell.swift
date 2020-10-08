//
//  DeviceTableViewCell.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//
//https://blog.usejournal.com/easy-tableview-setup-tutorial-swift-4-ad48ec4cbd45
//https://softauthor.com/custom-uitableview-and-uitableviewcell-programmatically-in-swift/

import Foundation
import UIKit
import CoreData

class DetectDeviceViewCell: UITableViewCell {
    
    @IBOutlet weak var ipLabel:             UILabel!
    @IBOutlet weak var portLabel:           UILabel!
    @IBOutlet weak var deviceNameLabel:     UILabel!
    @IBOutlet weak var serialNumberLabel:   UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ipLabel.font                    = UIFont(name: GaugeView.defaultFontName, size: 20)
        ipLabel.textColor               = UIColor(white: 0.7, alpha: 1)
        portLabel.font                  = UIFont(name: GaugeView.defaultFontName, size: 20)
        portLabel.textColor             = UIColor(white: 0.7, alpha: 1)
        deviceNameLabel.font            = UIFont(name: GaugeView.defaultFontName, size: 22)
        deviceNameLabel.textColor       = UIColor(white: 0.7, alpha: 1)
        serialNumberLabel.font          = UIFont(name: GaugeView.defaultFontName, size: 20)
        serialNumberLabel.textColor     = UIColor(white: 0.7, alpha: 1)
        // set table selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor    = UIColor(red: 78/255, green: 82/255, blue: 93/255, alpha: 0.6)
        selectedBackgroundView          = selectedView
    }
    
    func configureDeviceCell(deviceList: NSManagedObject) {
        // Configure the cell...
        self.layer.cornerRadius = 10
        //print("PUERTO EN EL CELL: \(String(describing: deviceList.value(forKeyPath: "port")))")
        //deviceList.value(forKeyPath: "deviceName") as? String
        ipLabel.text            = "IP: \(deviceList.value(forKeyPath: "visualUrl") ?? "127.0.0.1")"
        portLabel.text          = "Port: \(deviceList.value(forKeyPath: "port") ?? "0")"
        deviceNameLabel.text    = "Name: \(deviceList.value(forKeyPath: "deviceName") ?? "CLASSIC")"
        serialNumberLabel.text  = "Serial #: \(deviceList.value(forKeyPath: "serialNumber") ?? "000000")"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ipLabel.text            = nil
        portLabel.text          = nil
        deviceNameLabel.text    = nil
        serialNumberLabel.text  = nil
    }
}
