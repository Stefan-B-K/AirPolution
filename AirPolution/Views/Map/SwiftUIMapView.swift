
import SwiftUI
import ArcGIS

struct SwiftUIMapView {
  let map: AGSMap
  var graphicsOverlay = AGSGraphicsOverlay()
  let location: CLLocation?
  let currentMapCenter: CLLocation
  let currentMapScale: Double
  var records: [Record]?
  @Binding var mapView: AGSMapView?
  
  init(
    map: AGSMap = AGSMap(basemap: AGSBasemap(baseLayer: AGSOpenStreetMapLayer())),
    location: CLLocation?,
    currentMapCenter: CLLocation,
    currentMapScale: Double,
    records: [Record]?,
    mapView: Binding<AGSMapView?>
  ) {
    self.map = map
    self.location = location
    self.currentMapCenter = currentMapCenter
    self.currentMapScale = currentMapScale
    self.records = records
    self._mapView = mapView
    if let location = location {
      graphicsOverlay.graphics.add(SwiftUIMapView.addGraphic(location: location))
      graphicsOverlay.graphics.addObjects(from: SwiftUIMapView.addGraphics(records: records, measureType: .p2))
    }
  }
  
  private var onSingleTapAction: ((AGSGeoView, CGPoint, AGSPoint) -> Void)?
  
  static func addGraphic(location: CLLocation) -> AGSGraphic {
    let point = AGSPoint(x: location.coordinate.longitude, y: location.coordinate.latitude, spatialReference: .wgs84())
    let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: .yellow, size: 12.0)
    pointSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: .blue, width: 3.0)
    return AGSGraphic(geometry: point, symbol: pointSymbol)
  }
  
  static func addGraphics(records: [Record]?, measureType: MeasureType) -> [AGSGraphic] {
    var graphics = [AGSGraphic]()
    guard let records = records else { return graphics }
    for record in records {
      let point = AGSPoint(x: record.longitude, y: record.latitude, spatialReference: .wgs84())
      let measureTypeColor = record.sensordatavalues.first {$0.valueType == measureType }?.mood.color ?? .clear
      let pointSymbol = AGSSimpleMarkerSymbol(style: .circle, color: UIColor(measureTypeColor.opacity(0.5)), size: 15.0)
      pointSymbol.outline = AGSSimpleLineSymbol(style: .solid, color: UIColor(measureTypeColor), width: 2.0)
      let pointGraphic = AGSGraphic(geometry: point, symbol: pointSymbol)
      pointGraphic.attributes.setValue(record, forKey: Constants.record)
      graphics.append(pointGraphic)
    }
    return graphics
  }
  
  func onSingleTap(perform action: @escaping (AGSGeoView, CGPoint, AGSPoint) -> Void) -> Self {
    var copy = self
    copy.onSingleTapAction = action
    return copy
  }
  
}


extension SwiftUIMapView: UIViewRepresentable {
  
  typealias UIViewType = AGSMapView
  
  func makeCoordinator() -> Coordinator {
    Coordinator(
      onSingleTapAction: onSingleTapAction
    )
  }
  
  func makeUIView(context: Context) -> AGSMapView {
    let uiView = AGSMapView()
   
  
    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
      uiView.map = map
      uiView.interactionOptions.isRotateEnabled = false
      uiView.graphicsOverlays.setArray([graphicsOverlay])
      uiView.touchDelegate = context.coordinator
      let agsViewpoint = AGSViewpoint(
        latitude: currentMapCenter.coordinate.latitude,
        longitude: currentMapCenter.coordinate.longitude,
        scale: currentMapScale)
      uiView.setViewpoint(agsViewpoint)
      
      timer.invalidate()
    }
   
    
    DispatchQueue.main.async {
      self.mapView = uiView
    }
    return uiView
  }
  
  func updateUIView(_ uiView: AGSMapView, context: Context) {
    if map != uiView.map {
      uiView.map = map
    }
    if [graphicsOverlay] != uiView.graphicsOverlays as? [AGSGraphicsOverlay] {
      uiView.graphicsOverlays.setArray([graphicsOverlay])
    }
    context.coordinator.onSingleTapAction = onSingleTapAction
  }
  
  
}

extension SwiftUIMapView {
  class Coordinator: NSObject {
    var onSingleTapAction: ((AGSGeoView, CGPoint, AGSPoint) -> Void)?
    
    init(
      onSingleTapAction: ((AGSGeoView, CGPoint, AGSPoint) -> Void)?
    ) {
      self.onSingleTapAction = onSingleTapAction
    }
    
  }
}

extension SwiftUIMapView.Coordinator: AGSGeoViewTouchDelegate {
  func geoView(_ geoView: AGSGeoView, didTapAtScreenPoint screenPoint: CGPoint, mapPoint: AGSPoint) {
    onSingleTapAction?(geoView, screenPoint, mapPoint)
  }
}
