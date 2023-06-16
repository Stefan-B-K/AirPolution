
import Foundation

extension FileManager {
  static var docsDirectoryURL: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
}
