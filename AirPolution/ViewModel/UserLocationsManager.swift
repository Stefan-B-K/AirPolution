
import Foundation


enum Action: String {
  case add, remove
}

final class UserLocationsManager {
  private var deviceToken: String!
  private let backendUrl = "Backend".getFromPlist()
  private static let _userLocationsManager = UserLocationsManager()
  private let fireBaseManager = FireBaseManager.shared
  
  static var shared: UserLocationsManager { return _userLocationsManager }
  
  private init() {}
  
  
   func setDeviceToken(with token: String) {
    if let data = token.data(using: .utf8) {
      deviceToken = data.base64EncodedString()
      UserDefaults.standard.set(deviceToken, forKey: Constants.deviceToken)
      print("Device Token base64: \(deviceToken!)")                             //==================== print ============================
    }
  }
  
  
   func setDeviceToken(withSaved token: String?) {
    deviceToken = token
    print("Device Token base64: ", deviceToken ?? "not saved")                //==================== print ===========================
  }
  
  
  func registerLocationWithServer(location: Location, action: Action) {
    Task {
      do {
        let success = try await self.registerDeviceForLocation(location, action: action)
        if !(success?[action.rawValue] ?? false) {
          print(">>>>>>>>>>>>> \(action.rawValue) FIREBASE >>>>>>>>>>>>>>>>")
          fireBaseManager.postToFirebase(location: location,
                                         action: action.rawValue,
                                         deviceToken: deviceToken)
        }
      } catch {
        print(">>>>>>>>>>>>> \(error) \(action.rawValue) FIREBASE >>>>>>>>>>>>>>>>")
        fireBaseManager.postToFirebase(location: location,
                                       action: action.rawValue,
                                       deviceToken: deviceToken)
      }
    }
  }
  
  
  // MARK: Private methods
  
  private  func registerDeviceForLocation(_ location: Location, action: Action) async throws -> [String: Bool]? {
    let url = URL(string: backendUrl)!
    var request = URLRequest(url: url)
    request.setValue(Constants.customHeaderValue, forHTTPHeaderField: Constants.customHeaderKey)
    request.setValue(deviceToken, forHTTPHeaderField: Constants.deviceHeaderKey)
    request.setValue(Constants.appJson, forHTTPHeaderField: "Content-Type")
    request.setValue(Constants.appJson, forHTTPHeaderField: "Accept")
    request.httpMethod = "POST"
    var json: [String : Any] = ["locationId": location.id,
                                "action": action.rawValue]
    if action == .add {
      json["latitude"] = location.latitude
      json["longitude"] = location.longitude
    }
    let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
    request.httpBody = jsonData
    let (data, response) = try await Networking.shared.data(for: request)
    if (response as? HTTPURLResponse)?.statusCode == 200 {
      return try JSONSerialization.jsonObject(with: data) as? [String: Bool]
    } else {
      return [action.rawValue: false]
    }
  }
  
}

