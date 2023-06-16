
import SwiftUI

extension Image {
  func resizableFrame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View  {
    self
      .resizable()
      .aspectRatio(1, contentMode: .fit)
      .frame(width: width, height: height, alignment: alignment)
  }
}
