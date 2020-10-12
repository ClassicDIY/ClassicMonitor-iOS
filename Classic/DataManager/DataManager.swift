//
//  DataManager.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/17/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import Foundation

struct DataManager {
        
    static func readRegistersValues(classicURL: NSString, classicPort: Int32, device: Int32, startAddress: Int32, count: Int32, completion: @escaping (_ array: [AnyObject]?, _ error: Error?) -> Void) {
        //print("Call Read Registers Values")
        let swiftLibModbus = SwiftLibModbus(ipAddress: classicURL, port: classicPort, device: device)
        swiftLibModbus.readRegistersFrom(startAddress: startAddress, count: count, success: { (array: [AnyObject]) -> Void in
            if kDebugLog { print("Received Data 1: \(array)") }
            swiftLibModbus.disconnect()
            completion(array, nil)
            return
        },
        failure:  { (error: NSError) -> Void in
            //Handle error
            if kDebugLog { print("Error Getting Network DataManager: \(error)") }
            print("Error Getting Network DataManager: \(error)")
            swiftLibModbus.disconnect()
            completion(nil, error)
            return
        })
        swiftLibModbus.disconnect()
    }
}
