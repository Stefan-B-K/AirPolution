
import SwiftUI
import ArcGIS.AGSMapView

class PopupView: UIView {
  
  static func instance(
    for record: Record,
    width: Int = 300,
    height: Int = 200,
    address: Address?,
    mapView: Binding<AGSMapView?>,
    selectedType: Binding<MeasureType?>,
    isCallout: Bool = true) -> UIView {
      
    let locationMeasureView = LocationMeasureView(
      mapView: mapView,
      selectedType: selectedType,
      record: record,
      width: width,
      height: height,
      address: address,
      isCallout: isCallout)
    let host = UIHostingController(rootView: locationMeasureView)
    let hostView = host.view!
    return hostView
      
  }
  
}
