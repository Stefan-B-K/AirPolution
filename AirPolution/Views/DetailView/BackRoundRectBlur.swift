
import SwiftUI

struct BackRoundRectBlur: ViewModifier {
let cornerRadius: CGFloat
  
  func body(content: Content) -> some View {
    content
      .background {
        RoundedRectangle(cornerRadius: 15)
          .foregroundColor(.backgroundColor)
          .blur(radius: 7)
      }
  }
}
