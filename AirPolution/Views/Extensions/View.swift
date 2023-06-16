
import SwiftUI

extension View {
  /// Applies the given transform if the given condition evaluates to `true`.
  @ViewBuilder func `if`<Content: View>(_ condition: Bool, do transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
  
  
  func scaleOnTap<PopoverContent: View>(pressedDetail: Binding<MeasureType>, zIndex: Binding<MeasureType>, measureType: MeasureType, anchor: UnitPoint, scale: CGFloat, offset: CGFloat = 0, popoverContent: PopoverContent) -> some View {
    modifier(ScaleOnTap(pressedDetail: pressedDetail, zIndex: zIndex, measureType: measureType, anchor: anchor, scale: scale, offset: offset, popoverContent: popoverContent))
  }
  
  
  func raisedRoundedRect(cornerRadius: CGFloat = 10) -> some View {
    modifier(RaisedRoundedRect(cornerRadius: cornerRadius))
  }
  
  
  func backRoundRectBlur(cornerRadius: CGFloat = 15) -> some View {
    modifier(BackRoundRectBlur(cornerRadius: cornerRadius))
  }
  
  
  func ridgedRoundedRect(cornerRadius: CGFloat = 10, isOn: Bool = true) -> some View {
    modifier(RidgedRoundedRect(cornerRadius: cornerRadius, isOn: isOn))
  }
  
  func flatRidgedRoundRect(cornerRadius: CGFloat = 10, isOn: Bool = true) -> some View {
    modifier(FlatRidgedRoundRect(cornerRadius: cornerRadius, isOn: isOn))
  }
  
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
      clipShape( RoundedCorner(radius: radius, corners: corners) )
  }
  
}
