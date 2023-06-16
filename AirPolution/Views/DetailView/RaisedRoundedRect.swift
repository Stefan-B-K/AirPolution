
import SwiftUI

struct RaisedRoundedRect: ViewModifier {
  let cornerRadius: CGFloat
  
  func body(content: Content) -> some View {
    content
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .background {
        RoundedRectangle(cornerRadius: cornerRadius)
          .foregroundColor(.backgroundColor)
          .shadow(color: .shadow, radius: cornerRadius * 0.4,
                  x: cornerRadius * 0.5, y: cornerRadius * 0.5)
          .shadow(color: .highlight, radius: cornerRadius * 0.4,
                  x: cornerRadius * -0.5, y: cornerRadius * -0.5)
      }
  }
}
