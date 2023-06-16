
import SwiftUI

struct MeasureButton: View {
  var type: MeasureType
  @Binding var selectedType: MeasureType?
  let action: (MeasureType) -> Void
  
  var body: some View {
      Button() {
        action(type)
      } label: {
        if ProcessInfo.processInfo.isiOSAppOnMac {
          Text(type.text)
        } else {
          if type == .temperature || type == .humidity {
            Image(systemName: type.image)
          } else {
            Text(type.text)
          }
        }
      }
    .ignoresSafeArea(.all)
    .font(Font.footnote.weight(type == selectedType ? .heavy : .regular))
    .padding(7)
    .frame(minWidth: ProcessInfo.processInfo.isiOSAppOnMac ? 110 : 50)
    .if(type == selectedType) { measureButton in
      measureButton.flatRidgedRoundRect(cornerRadius: 10)
    }
    .if(type != selectedType) { measureButton in
      measureButton.raisedRoundedRect(cornerRadius: 10)
    }
    .background {
      RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor)
    }
    .padding([.bottom], 0)
  }
}

