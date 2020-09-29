//
//  MQTTData.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/23/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//https://appcodelabs.com/introduction-to-iot-how-to-send-mqtt-messages-from-ios-using-swift
//https://github.com/emqx/CocoaMQTT
//https://github.com/flightonary/Moscapsule
//https://medium.com/thefloatingpoint/mqtt-in-ios-d8574b55e006
//{
//   "appVersion":"",
//   "buildDate":"20180206",
//   "deviceName":"Workshop",
//   "deviceType":"Classic",
//   "endingAmps":10.81,
//   "hasWhizbang":true,
//   "lastVOC":5.01,
//   "model":"Classic 200 (rev 4)",
//   "mpptMode":11,
//   "netVersion":"",
//   "nominalBatteryVoltage":12,
//   "unitID":-1901700000
//}

import Foundation

struct MQTTDataInfo: Codable {
    var appVersion:             String?
    var buildDate:              String?
    var deviceName:             String?
    var deviceType:             String?
    var endingAmps:             Double?
    var hasWhizbang:            Bool?
    var lastVOC:                Double?
    var model:                  String?
    var mpptMode:               Int32?
    var netVersion:             String?
    var nominalBatteryVoltage:  Int32?
    var unitID:                 Int32?
    
    init(appVersion: String? = nil,buildDate: String? = nil, deviceName: String? = nil, deviceType: String? = nil, endingAmps: Double? = 0.0,
         hasWhizbang: Bool?, lastVOC: Double?, model: String?, mpptMode: Int32?, netVersion: String?, nominalBatteryVoltage: Int32?, unitID: Int32) {
        self.appVersion             = appVersion
        self.buildDate              = buildDate
        self.deviceName             = deviceName
        self.deviceType             = deviceType
        self.endingAmps             = endingAmps
        self.hasWhizbang            = hasWhizbang
        self.lastVOC                = lastVOC
        self.model                  = model
        self.mpptMode               = mpptMode
        self.netVersion             = netVersion
        self.nominalBatteryVoltage  = nominalBatteryVoltage
        self.unitID                 = unitID
    }
}

extension MQTTDataInfo: Equatable {
    static func ==(lhs: MQTTDataInfo, rhs: MQTTDataInfo) -> Bool {
        return (lhs.appVersion == rhs.appVersion) && (lhs.buildDate == rhs.buildDate) && (lhs.deviceName == rhs.deviceName) && (lhs.deviceType == rhs.deviceType)
            && (lhs.endingAmps == rhs.endingAmps) && (lhs.hasWhizbang == rhs.hasWhizbang) && (lhs.lastVOC == rhs.lastVOC) && (lhs.model == rhs.model)
            && (lhs.mpptMode == rhs.mpptMode) && (lhs.netVersion == rhs.netVersion) && (lhs.nominalBatteryVoltage == rhs.nominalBatteryVoltage) && (lhs.unitID == rhs.unitID)
    }
}

//extended Structure
struct MQTTInfo : Codable {
    let records: [MQTTDataInfo]
}

extension MQTTInfo: Equatable {
    static func ==(lhs: MQTTInfo, rhs: MQTTInfo) -> Bool {
        return (lhs.records == rhs.records)
    }
}

