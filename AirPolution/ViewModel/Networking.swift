
import UIKit

enum Networking {
  
  static var shared: URLSession {
    return urlSession
  }
  
  private static let urlSession: URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForResource = 20
    configuration.timeoutIntervalForRequest = 20
    configuration.httpAdditionalHeaders = ["User-Agent": UserAgent.UAString()]
    return URLSession(configuration: configuration)
  }()
  
  
  private enum UserAgent {
    
    static func UAString() -> String {
      return "\(appNameAndVersion()) \(deviceName()) \(deviceVersion()) \(CFNetworkVersion()) \(DarwinVersion())"
    }
    
    //eg. Darwin/16.3.0
    static func DarwinVersion() -> String {
      var sysinfo = utsname()
      uname(&sysinfo)
      let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
      return "Darwin/\(dv)"
    }
    //eg. CFNetwork/808.3
    static func CFNetworkVersion() -> String {
      let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
      let version = dictionary?["CFBundleShortVersionString"] as! String
      return "CFNetwork/\(version)"
    }
    
    //eg. iOS/10_1
    static func deviceVersion() -> String {
      let os = ProcessInfo.processInfo.isiOSAppOnMac ? "macOS" : UIDevice.current.systemName
      let version = ProcessInfo.processInfo.isiOSAppOnMac ?
      "\(ProcessInfo.processInfo.operatingSystemVersionString.split(separator: " ")[1])" :
      UIDevice.current.systemVersion
      return "\(os)/\(version)"
    }
    
    //eg. iPhone5,2
    static func deviceName() -> String {
      var deviceName: String
      var sysinfo = utsname()
      uname(&sysinfo)
      deviceName = String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
      if ProcessInfo.processInfo.isiOSAppOnMac {
        var size:Int = 0
        sysctlbyname("hw.model", nil, &size, nil, 0);
        var answer = [CChar](repeating: 0,  count: size)
        sysctlbyname("hw.model", &answer, &size, nil, 0)
        if answer.count > 0, let device = String(cString: answer, encoding: .utf8) {
          deviceName = device
        }
      }
      if let _ = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
        if let arch = ProcessInfo().environment["SIMULATOR_ARCHS"],
           arch.contains("x86_64") {
          deviceName = "64-bit Simulator"
        } else {
          deviceName = "32-bit Simulator"
        }
      }
      return deviceName
    }
    
    //eg. MyApp/1
    static func appNameAndVersion() -> String {
      let dictionary = Bundle.main.infoDictionary!
      let version = dictionary["CFBundleShortVersionString"] as! String
      let name = dictionary["CFBundleName"] as! String
      return "\(name)/\(version)"
    }
  }
  
}
