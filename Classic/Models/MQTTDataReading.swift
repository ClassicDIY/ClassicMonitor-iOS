//
//  MQTTDataReading.swift
//  Classic
//
//  Created by Urayoan Miranda on 9/29/20.
//  Copyright © 2020 Urayoan Miranda. All rights reserved.
//

//{
//   "BatTemperature":18.61,
//   "NetAmpHours":0,
//   "ChargeState":0,
//   "InfoFlagsBits":-1577046016,
//   "ReasonForResting":104,
//   "NegativeAmpHours":-1459,
//   "BatVoltage":13.71,
//   "PVVoltage":15.21,
//   "VbattRegSetPTmpComp":14.7,
//   "TotalAmpHours":63,
//   "WhizbangBatCurrent":0.41,
//   "BatCurrent":0.91,
//   "PVCurrent":0.71,
//   "ConnectionState":0,
//   "EnergyToday":0.41,
//   "EqualizeTime":7200,
//   "SOC":100,
//   "Aux1":false,
//   "Aux2":false,
//   "Power":12.01,
//   "FETTemperature":31.31,
//   "PositiveAmpHours":2094,
//   "TotalEnergy":109.51,
//   "FloatTimeTodaySeconds":16842,
//   "RemainingAmpHours":63,
//   "AbsorbTime":7200,
//   "ShuntTemperature":23.01,
//   "PCBTemperature":39.41
//}

struct MQTTDataReading: Codable {
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

extension MQTTDataReading: Equatable {
    static func ==(lhs: MQTTDataReading, rhs: MQTTDataReading) -> Bool {
        return (lhs.appVersion == rhs.appVersion) && (lhs.buildDate == rhs.buildDate) && (lhs.deviceName == rhs.deviceName) && (lhs.deviceType == rhs.deviceType)
            && (lhs.endingAmps == rhs.endingAmps) && (lhs.hasWhizbang == rhs.hasWhizbang) && (lhs.lastVOC == rhs.lastVOC) && (lhs.model == rhs.model)
            && (lhs.mpptMode == rhs.mpptMode) && (lhs.netVersion == rhs.netVersion) && (lhs.nominalBatteryVoltage == rhs.nominalBatteryVoltage) && (lhs.unitID == rhs.unitID)
    }
}

//extended Structure
struct MQTTReading : Codable {
    let records: [MQTTDataReading]
}

extension MQTTReading: Equatable {
    static func ==(lhs: MQTTReading, rhs: MQTTReading) -> Bool {
        return (lhs.records == rhs.records)
    }
}
