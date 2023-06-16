
import Foundation

extension String {
  
  func getFromPlist() -> String {
    let dataFilePath = Bundle.main.url(forResource: "Private", withExtension: "plist")
    let data = try! Data(contentsOf: dataFilePath!)
    let result = try! PropertyListDecoder().decode([String:String].self, from: data)
    return result[self]!
  }
  
}
