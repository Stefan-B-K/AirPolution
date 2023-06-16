import SwiftUI

enum Mood: String, CaseIterable {
  case good, moderate, bad, unhealthy, hazardous, unknown = "--"  // faceFiles names == rawValues

  var color: Color {
    switch self {
    case .good: return .green
    case .moderate: return .yellow
    case .bad: return .orange
    case .unhealthy: return .red
    case .hazardous: return .purple
    case .unknown: return .offlineColor
    }
  }
  
  var colorText: Color {
    switch self {
    case .good: return .good
    case .moderate: return .moderate
    case .bad: return .bad
    case .unhealthy: return .unhealthy
    case .hazardous: return .hazardous
    case .unknown: return .unknown
    }
  }
  
  static func setMood(for valueType: MeasureType, with value: Double) -> Mood {
    
    switch valueType {
    case .p1:
      switch value {
      case 0..<30: return .good
      case 30..<40: return .moderate
      case 40..<60: return .bad
      case 60..<150: return .unhealthy
      case 150.0...1500.0: return .hazardous
      default: return .unknown
      }
    case .p2:
      switch value {
      case 0..<15: return .good
      case 15..<25: return .moderate
      case 25..<40: return .bad
      case 40..<90: return .unhealthy
      case 90.0...900.0: return .hazardous
      default: return .unknown
      }
    case .temperature:
      switch value {
      case 15..<22: return .good
      case 22..<26, 10..<15: return .moderate
      case 4..<10, 26..<31: return .bad
      case -5..<4, 31..<35: return .unhealthy
      case -50 ..< -5, 35...55: return .hazardous
      default: return .unknown
      }
    case .humidity:
      switch value {
      case 45..<70: return .good
      case 20..<45, 70..<85: return .moderate
      case 0..<20, 85...100: return .bad
      default: return .unknown
      }
    case .pressure, .pressureAtSealevel:
      switch value {
      case 998..<1023: return .good
      case 990..<998, 1023..<1030: return .moderate
      case 970..<990, 1030..<1045: return .bad
      case 950..<970, 1045..<1060: return .unhealthy
      case 920..<950, 1060...1100: return .hazardous
      default: return .unknown
      }

    case .unsupported: return .unknown
    }
  }
  
}
