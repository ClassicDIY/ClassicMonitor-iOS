//
//  DeviceLists.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/14/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

import Foundation

struct ClassicDeviceLists: Codable {
    var ip:             String?
    var port:           Int32?
    var deviceName:     String?
    var serialNumber:   String?
    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(ip)
//    }
    
    
    init(ip: String? = nil, port: Int32? = 0, deviceName: String? = nil, serialNumber: String? = nil) {
        self.ip             = ip
        self.deviceName     = deviceName
        self.port           = port
        self.serialNumber   = serialNumber
    }
}

extension ClassicDeviceLists: Equatable {
    static func ==(lhs: ClassicDeviceLists, rhs: ClassicDeviceLists) -> Bool {
        return (lhs.ip == rhs.ip) && (lhs.port == rhs.port) && (lhs.deviceName == rhs.deviceName) && (lhs.serialNumber == rhs.serialNumber)
    }
}

//extended Structure
struct DeviceLists : Codable {
    let records: [ClassicDeviceLists]
}

extension DeviceLists: Equatable {
    static func ==(lhs: DeviceLists, rhs: DeviceLists) -> Bool {
        return (lhs.records == rhs.records)
    }
}
