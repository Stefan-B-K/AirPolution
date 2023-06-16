
import SwiftUI

struct FlatRidgedRoundRect: ViewModifier {
  let cornerRadius: CGFloat
  var isOn: Bool = true
  
  func body(content: Content) -> some View {
    if isOn {
    content
      .padding(2)
      .background {
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(Color.backgroundColor, lineWidth: 1)
          .foregroundColor(.backgroundColor)
          .shadow(color: .shadow, radius: cornerRadius * 0.05,
                  x: cornerRadius * 0.1, y: cornerRadius * 0.1)
          .shadow(color: .highlight, radius: cornerRadius * 0.1,
                  x: cornerRadius * -0.05, y: cornerRadius * -0.05)
          .offset(x: cornerRadius * 0.1, y: cornerRadius * 0.1)
          .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      }
      .padding(-3)
      .background {
        RoundedRectangle(cornerRadius: cornerRadius-2)
          .foregroundColor(.backgroundColor)
          .shadow(color: .shadow, radius: cornerRadius * 0.05,
                  x: cornerRadius * 0.1, y: cornerRadius * 0.1)
          .shadow(color: .highlight, radius: cornerRadius * 0.1,
                  x: cornerRadius * -0.1, y: cornerRadius * -0.1)
          .offset(x: cornerRadius * 0.1, y: cornerRadius * 0.1)
      }
    } else {
      content
    }
  }
}
