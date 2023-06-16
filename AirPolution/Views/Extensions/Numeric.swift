
import Foundation

extension Numeric {
  var thousandsSpace: String { Formatter.withSeparator.string(for: self) ?? "" }
}
