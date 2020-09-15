//
//  DeviceTableViewCell.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import Foundation
import UIKit

class DetectDeviceViewCell: UITableViewCell {
    
    @IBOutlet weak var ipLabel:             UILabel!
    @IBOutlet weak var portLabel:           UILabel!
    @IBOutlet weak var deviceNameLabel:     UILabel!
    @IBOutlet weak var serialNumberLabel:   UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // set table selection color
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 78/255, green: 82/255, blue: 93/255, alpha: 0.6)
        selectedBackgroundView       = selectedView
    }
    
    func configureDeviceCell(deviceList: ClassicDeviceLists) {
        // Configure the cell...
        ipLabel.text            = deviceList.ip
        portLabel.text          = "\(deviceList.port ?? 0)"
        deviceNameLabel.text    = deviceList.deviceName
        serialNumberLabel.text  = deviceList.serialNumber
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ipLabel.text            = nil
        portLabel.text          = nil
        deviceNameLabel.text    = nil
        serialNumberLabel.text  = nil
    }
}
