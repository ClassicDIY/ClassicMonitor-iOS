//
//  ViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/7/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        connect()
    }

    func connect() {
        let swiftLibModbus = SwiftLibModbus(ipAddress: "192.168.1.50", port: 502, device: 1)
        swiftLibModbus.connect(
            { () -> Void in
                //connected and ready to do modbus calls
            },
            failure: { (error: NSError) -> Void in
                //Handle error
                print("error")
        })
    }

}

