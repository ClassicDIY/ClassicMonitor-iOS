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
    
    var BatTemperature:         Float?
    var NetAmpHours:            Int?
    var ChargeState:            Int?
    var InfoFlagsBits:          Int?
    var ReasonForResting:       Int?
    var NegativeAmpHours:       Int?
    var BatVoltage:             Float?
    var PVVoltage:              Float?
    var VbattRegSetPTmpComp:    Float?
    var TotalAmpHours:          Int?
    var WhizbangBatCurrent:     Float?
    var BatCurrent:             Float?
    var PVCurrent:              Float?
    var ConnectionState:        Int?
    var EnergyToday:            Float?
    var EqualizeTime:           Int?
    var SOC:                    Int?
    var Aux1:                   Bool?
    var Aux2:                   Bool?
    var Power:                  Float?
    var FETTemperature:         Float?
    var PositiveAmpHours:       Int?
    var TotalEnergy:            Float?
    var FloatTimeTodaySeconds:  Int?
    var RemainingAmpHours:      Int?
    var AbsorbTime:             Int?
    var ShuntTemperature:       Float?
    var PCBTemperature:         Float?
    
    init(BatTemperature: Float? = 0.0,NetAmpHours: Int? = 0, ChargeState: Int? = 0, InfoFlagsBits: Int? = 0, ReasonForResting: Int? = 0,
         NegativeAmpHours: Int?, BatVoltage: Float?, PVVoltage: Float?, VbattRegSetPTmpComp: Float?, TotalAmpHours: Int?, WhizbangBatCurrent: Float?, BatCurrent: Float?,
         PVCurrent: Float?, ConnectionState: Int?, EnergyToday: Float?, EqualizeTime: Int?, SOC: Int?, Aux1: Bool?, Aux2: Bool?,
         Power: Float?, FETTemperature: Float?, PositiveAmpHours: Int?, TotalEnergy: Float?, FloatTimeTodaySeconds: Int?, RemainingAmpHours: Int?, AbsorbTime: Int?,
         ShuntTemperature: Float?, PCBTemperature: Float?) {
        self.BatTemperature         = BatTemperature
        self.NetAmpHours            = NetAmpHours
        self.ChargeState            = ChargeState
        self.InfoFlagsBits          = InfoFlagsBits
        self.ReasonForResting       = ReasonForResting
        self.NegativeAmpHours       = NegativeAmpHours
        self.BatVoltage             = BatVoltage
        self.PVVoltage              = PVVoltage
        self.VbattRegSetPTmpComp    = VbattRegSetPTmpComp
        self.TotalAmpHours          = TotalAmpHours
        self.WhizbangBatCurrent     = WhizbangBatCurrent
        self.BatCurrent             = BatCurrent
        self.PVCurrent              = PVCurrent
        self.ConnectionState        = ConnectionState
        self.EnergyToday            = EnergyToday
        self.EqualizeTime           = EqualizeTime
        self.SOC                    = SOC
        self.Aux1                   = Aux1
        self.Aux2                   = Aux2
        self.Power                  = Power
        self.FETTemperature         = FETTemperature
        self.PositiveAmpHours       = PositiveAmpHours
        self.TotalEnergy            = TotalEnergy
        self.FloatTimeTodaySeconds  = FloatTimeTodaySeconds
        self.RemainingAmpHours      = RemainingAmpHours
        self.AbsorbTime             = AbsorbTime
        self.ShuntTemperature       = ShuntTemperature
        self.PCBTemperature         = PCBTemperature
    }
}

extension MQTTDataReading: Equatable {
    static func ==(lhs: MQTTDataReading, rhs: MQTTDataReading) -> Bool {
        return (lhs.BatTemperature == rhs.BatTemperature) && (lhs.NetAmpHours == rhs.NetAmpHours) && (lhs.ChargeState == rhs.ChargeState) && (lhs.InfoFlagsBits == rhs.InfoFlagsBits)
            && (lhs.ReasonForResting == rhs.ReasonForResting) && (lhs.NegativeAmpHours == rhs.NegativeAmpHours) && (lhs.BatVoltage == rhs.BatVoltage) && (lhs.VbattRegSetPTmpComp == rhs.VbattRegSetPTmpComp)
            && (lhs.TotalAmpHours == rhs.TotalAmpHours) && (lhs.WhizbangBatCurrent == rhs.WhizbangBatCurrent) && (lhs.BatCurrent == rhs.BatCurrent) && (lhs.PVCurrent == rhs.PVCurrent)
            && (lhs.ConnectionState == rhs.ConnectionState)
            && (lhs.EnergyToday == rhs.EnergyToday) && (lhs.EqualizeTime == rhs.EqualizeTime) && (lhs.SOC == rhs.SOC) && (lhs.Aux1 == rhs.Aux1)
            && (lhs.Aux2 == rhs.Aux2)
            && (lhs.Power == rhs.Power) && (lhs.FETTemperature == rhs.FETTemperature) && (lhs.PositiveAmpHours == rhs.PositiveAmpHours) && (lhs.TotalEnergy == rhs.TotalEnergy)
            && (lhs.FloatTimeTodaySeconds == rhs.FloatTimeTodaySeconds)
            && (lhs.RemainingAmpHours == rhs.RemainingAmpHours) && (lhs.AbsorbTime == rhs.AbsorbTime) && (lhs.ShuntTemperature == rhs.ShuntTemperature) && (lhs.PCBTemperature == rhs.PCBTemperature)
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
