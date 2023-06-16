
enum MeasureType: String, Identifiable, CaseIterable {
  var id: Int { hashValue }
  case p2 = "P2", p1 = "P1", temperature, humidity, pressure, pressureAtSealevel = "pressure_at_sealevel", unsupported
  
  
  var text: String {
    switch self {
    case .p1: return " PM 10"
    case .p2: return " PM 2.5"
    case .temperature: return "Temperature"
    case .pressure: return "Atm. pressure"
    case .humidity: return "Humidity"
    case .pressureAtSealevel: return ""
    case .unsupported: return ""
    }
  }
  
  var unit: String {
    switch self {
    case .p1: return "µg/㎥"
    case .p2: return "µg/㎥"
    case .temperature: return "°C"
    case .pressure: return "hPa"
    case .humidity: return "%"
    case .pressureAtSealevel: return "hPa"
    case .unsupported: return ""
    }
  }
  
  var image: String {
    switch self {
    case .p1: return "allergens"
    case .p2: return "allergens"
    case .temperature: return "thermometer"
    case .pressure: return "speedometer"
    case .humidity: return "humidity"
    case .pressureAtSealevel: return "speedometer"
    case .unsupported: return ""
    }
  }
  
  func index(in data: [SensorData]?) -> Int? {
    if let data = data {
      return  data.firstIndex { $0.valueType == self }
    } else {
      return nil
    }
  }
  
}
