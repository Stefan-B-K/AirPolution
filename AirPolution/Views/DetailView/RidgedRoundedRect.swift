
import SwiftUI

struct RidgedRoundedRect: ViewModifier {
  let cornerRadius: CGFloat
  var isOn: Bool = true
  
  func body(content: Content) -> some View {
    if isOn {
      content
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .background {
          RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(Color.backgroundColor, lineWidth: 2)
            .foregroundColor(.backgroundColor)
            .shadow(color: .shadow, radius: 1, x: 2, y: 2)
            .shadow(color: .highlight, radius: 1, x: -2, y: -2)
            .offset(x: -1, y: -1)
        }
    } else {
      content
    }
    
  }
}
