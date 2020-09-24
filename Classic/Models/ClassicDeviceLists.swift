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
    var visualUrl:      String?
    var port:           Int32?
    var deviceName:     String?
    var serialNumber:   String?
    var MQTTUser:       String?
    var MQTTPassword:   String?
    var isMQTT:         Bool?

    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(ip)
//    }
    
    
    init(ip: String? = nil,visualUrl: String? = nil, port: Int32? = 0, deviceName: String? = nil, serialNumber: String? = nil, MQTTUser: String?, MQTTPassword: String?, isMQTT: Bool?) {
        self.ip             = ip
        self.visualUrl      = visualUrl
        self.deviceName     = deviceName
        self.port           = port
        self.serialNumber   = serialNumber
        self.MQTTUser       = MQTTUser
        self.MQTTPassword   = MQTTPassword
        self.isMQTT         = isMQTT
    }
}

extension ClassicDeviceLists: Equatable {
    static func ==(lhs: ClassicDeviceLists, rhs: ClassicDeviceLists) -> Bool {
        return (lhs.ip == rhs.ip) && (lhs.visualUrl == rhs.visualUrl) && (lhs.port == rhs.port) && (lhs.deviceName == rhs.deviceName) && (lhs.serialNumber == rhs.serialNumber) && (lhs.MQTTUser == rhs.MQTTUser) && (lhs.MQTTPassword == rhs.MQTTPassword) && (lhs.isMQTT == rhs.isMQTT)
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
