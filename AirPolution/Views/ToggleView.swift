
import SwiftUI

struct ToggleView: View {
  @Binding var isOn: Bool
  var text: String
  
    var body: some View {
      Button {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
      } label: {
        Toggle(isOn: $isOn) {
          Text(text)
            .font(.headline)
        }
        .allowsHitTesting(false)
      }
      .buttonStyle(.borderless)
      .padding([.top, .bottom], 10)
    }
}


