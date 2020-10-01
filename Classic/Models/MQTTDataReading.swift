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
    
    var BatTemperature:         Double?
    var NetAmpHours:            Int?
    var ChargeState:            Int?
    var InfoFlagsBits:          Int?
    var ReasonForResting:       Int?
    var NegativeAmpHours:       Int?
    var BatVoltage:             Int?
    var PVVoltage:              Int?
    var VbattRegSetPTmpComp:    Int?
    var TotalAmpHours:          Int?
    var WhizbangBatCurrent:     Double?
    var BatCurrent:             Double?
    var PVCurrent:              Double?
    var ConnectionState:        Int?
    var EnergyToday:            Double?
    var EqualizeTime:           Int?
    var SOC:                    Int?
    var Aux1:                   Bool?
    var Aux2:                   Bool?
    var Power:                  Double?
    var FETTemperature:         Double?
    var PositiveAmpHours:       Int?
    var TotalEnergy:            Double?
    var FloatTimeTodaySeconds:  Double?
    var RemainingAmpHours:      Int?
    var AbsorbTime:             Int?
    var ShuntTemperature:       Double?
    var PCBTemperature:         Double?
    
    init(BatTemperature: Double? = 0.0,NetAmpHours: Int? = 0, ChargeState: Int? = 0, InfoFlagsBits: Int? = 0, ReasonForResting: Int? = 0,
         NegativeAmpHours: Int?, BatVoltage: Int?, PVVoltage: Int?, VbattRegSetPTmpComp: Int?, TotalAmpHours: Int?, WhizbangBatCurrent: Double?, BatCurrent: Double?,
         PVCurrent: Double?, ConnectionState: Int?, EnergyToday: Double?, EqualizeTime: Int?, SOC: Int?, Aux1: Bool?, Aux2: Bool?,
         Power: Double?, FETTemperature: Double?, PositiveAmpHours: Int?, TotalEnergy: Double?, FloatTimeTodaySeconds: Double?, RemainingAmpHours: Int?, AbsorbTime: Int?,
         ShuntTemperature: Double?, PCBTemperature: Double?) {
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
