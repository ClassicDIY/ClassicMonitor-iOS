//
//  TestViewController.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/12/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import UIKit

class DetectDeviceViewController: UIViewController {
    
    var inSocket : InSocket!
    //var outSocket : OutSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inSocket = InSocket()
    }
}
