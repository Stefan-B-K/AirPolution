
import SwiftUI

struct ZoomButton: View {
    var zoomIn: Bool
  let action: (Bool) -> Void
  
    var body: some View {
        
        return Button {
          action(zoomIn)
        } label: {
          Image(systemName: (zoomIn ? "plus" : "minus") +  ".magnifyingglass")
            .resizable()
            .scaledToFit()
            .padding(7)
        }
        .frame(width: 40, height: 40)
        .background {
          RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor)
        }
      }
    }


struct ZoomButton_Previews: PreviewProvider {
    static var previews: some View {
      ZoomButton(zoomIn: true, action: {_ in })
    }
}
