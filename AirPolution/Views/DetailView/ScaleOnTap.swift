
import SwiftUI

struct ScaleOnTap<PopoverContent: View>: ViewModifier {
  @Binding var pressedDetail: MeasureType
  @Binding var zIndex: MeasureType
  let measureType: MeasureType
  let anchor: UnitPoint
  let scale: CGFloat
  let offset: CGFloat
  let popoverContent: PopoverContent

  func body(content: Content) -> some View {
    content
      .onTapGesture {
        withAnimation(.spring()) {
          pressedDetail = measureType
          zIndex = measureType
        }
      }
      
      .overlay(alignment: .trailing) {
        popoverContent
          .scaleEffect(pressedDetail == measureType ? scale : 1, anchor: anchor)
          .offset(x: offset)
          .foregroundColor(.blue)
          .opacity(pressedDetail == measureType ? 1 : 0)
          .onTapGesture {
            withAnimation(.spring()) {
              pressedDetail = .pressureAtSealevel
            }
          }
      }
  }
}
