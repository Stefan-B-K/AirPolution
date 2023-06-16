
import Foundation

protocol CLCoords {
  var latitude: Double { get }
  var longitude: Double { get }
}

struct Record: CLCoords {
  var locationId: Int
  let latitude: Double
  let longitude: Double
  
  let sensorId: Int
  var sensordatavalues: [SensorData]
  let timestamp: String
  
  enum CodingKeys: String, CodingKey {
    case location
    case sensor
    case sensordatavalues
    case timestamp
  }
}

struct SensorData {
  let valueType: MeasureType
  var value: Double?
  var timestamp: String
  var mood: Mood
  
  enum CodingKeys: String, CodingKey {
    case value_type
    case value
  }
}

struct Location: Codable, Identifiable, Hashable {
  let id: Int
  let latitude: String
  let longitude: String
}

struct Sensor: Decodable {
  let id: Int
}


extension Record: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let location = try container.decode(Location.self, forKey: .location)
    locationId = location.id
    latitude = Double(location.latitude)!
    longitude = Double(location.longitude)!
    sensorId = try container.decode(Sensor.self, forKey: .sensor).id
    let timeStr = try container.decode(String.self, forKey: .timestamp)
    timestamp = utcToLocal(dateStr: timeStr)
    sensordatavalues = try container.decode([SensorData].self, forKey: .sensordatavalues)
    
    let moodPressureAtSeaLevel = sensordatavalues.first { $0.valueType == .pressureAtSealevel }?.mood
    sensordatavalues.indices.forEach {
      sensordatavalues[$0].timestamp = timestamp
      if sensordatavalues[$0].valueType == .pressure {
        sensordatavalues[$0].mood = moodPressureAtSeaLevel ?? .unknown
      }
    }
  }
}

extension SensorData: Decodable {
  init(from decoder: Decoder) throws {
    let continer = try decoder.container(keyedBy: CodingKeys.self)
    
    let type = try continer.decode(String.self, forKey: .value_type)
    switch type {
    case MeasureType.p1.rawValue: valueType = .p1
    case MeasureType.p2.rawValue: valueType = .p2
    case MeasureType.temperature.rawValue: valueType = .temperature
    case MeasureType.humidity.rawValue: valueType = .humidity
    case MeasureType.pressure.rawValue: valueType = .pressure
    case MeasureType.pressureAtSealevel.rawValue: valueType = .pressureAtSealevel
    default: valueType = .unsupported
    }
    
    if let valueDbl = try? continer.decode(Double.self, forKey: .value) {
      if valueType == .pressure || valueType == .pressureAtSealevel {
        value = valueDbl / 100
      }
    } else {
      let valueStr = try continer.decode(String.self, forKey: .value)
      
      if let value = Double(valueStr), !value.isNaN {
        self.value = valueType == .pressure || valueType == .pressureAtSealevel ? value / 100 : value
      } else {
        self.value = nil
      }
    }
    
    timestamp = ""
    
    if let value = value {
      mood = Mood.setMood(for: valueType, with: value)
    } else {
      mood = .unknown
    }
  }
}

extension Record: Hashable, Equatable {
  var id: Int { return sensorId }
  
  static func == (lhs: Record, rhs: Record) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension SensorData {
  init() {
    self.timestamp = "--"
    self.valueType = .unsupported
    self.value = nil
    self.mood = .unknown
  }
}


fileprivate func utcToLocal(dateStr: String) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
  
  let date = dateFormatter.date(from: dateStr)!
  dateFormatter.timeZone = TimeZone.current
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
  return dateFormatter.string(from: date)
}

fileprivate func localToUtc(dateStr: String) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.timeZone = TimeZone.current
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
  
  let date = dateFormatter.date(from: dateStr)!
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
  return dateFormatter.string(from: date)
}
