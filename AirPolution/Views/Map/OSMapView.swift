
import SwiftUI
import ArcGIS

struct OSMapView: View {
  @EnvironmentObject var locationManager: LocationManager
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Binding var mapView: AGSMapView!
  @Binding var selectedType: MeasureType?

  let geocoderGoogle = ReverseGeocodingGoogle()
  
  private struct CropFrame: Shape {
    func path(in rect: CGRect) -> Path {
      let size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/1.2)
      let origin = CGPoint(x: rect.midX - size.width / 2, y: rect.midY - size.height / 2)
      return Path(CGRect(origin: origin, size: size).integral)
    }
  }
  
  var body: some View {
    ZStack {
      SwiftUIMapView(location: locationManager.location,
                     currentMapCenter: locationManager.currentMapCenter,
                     currentMapScale: locationManager.currentMapScale,
                     records: locationManager.records,
                     mapView: $mapView)
        .onSingleTap { geoView, screenPoint, mapPoint in
          if locationManager.location == nil {
            let location = AGSGeometryEngine.projectGeometry(mapPoint, to: .wgs84()) as! AGSPoint
            locationManager.location = CLLocation(latitude: location.y, longitude: location.x)
          } else {
            centerMap(geoView: geoView, mapPoint: mapPoint)
            if let graphicsOverlay = geoView.graphicsOverlays.firstObject as? AGSGraphicsOverlay {
              showCallout(for: graphicsOverlay, in: geoView, screenPoint: screenPoint, mapPoint: mapPoint)
            }
          }
        }
        .preferredColorScheme(.light)
        .clipShape(CropFrame())
        .scaleEffect(1.2)
    }
  }
  
  private func centerMap(geoView: AGSGeoView, mapPoint: AGSPoint) {
 
    if let geoView = geoView as? AGSMapView {
      
      let height = horizontalSizeClass == .compact ? geoView.frame.height * min(geoView.mapScale, 10000) : 0
      let agsPoint = AGSPoint(x: mapPoint.x, y: mapPoint.y + height/50000, spatialReference: mapPoint.spatialReference)
      geoView.setViewpointCenter(agsPoint, scale: mapView.mapScale > 10000 ? 10000 : mapView.mapScale )
    }
  }
  
  private func showCallout(for graphicsOverlay: AGSGraphicsOverlay, in geoView: AGSGeoView, screenPoint: CGPoint, mapPoint: AGSPoint) {
    let tolerance: Double = 12
    geoView.identify(graphicsOverlay,
                     screenPoint: screenPoint,
                     tolerance: tolerance,
                     returnPopupsOnly: false,
                     maximumResults: 10) { (result: AGSIdentifyGraphicsOverlayResult) in
      
      locationManager.dismissCallout(in: geoView)
      if let error = result.error {
        print("error while identifying : \(error.localizedDescription)")
      } else {
        if !result.graphics.isEmpty,
           let selectedStation = result.graphics.first!.attributes.value(forKey: Constants.record) as? Record  {
          geocoderGoogle.getAddress(for: CLLocation(latitude: selectedStation.latitude, longitude: selectedStation.longitude))
        }
                
        if !result.graphics.isEmpty {
          Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { timer in
            if let selectedStation = result.graphics.first!.attributes.value(forKey: Constants.record) as? Record {
              geoView.callout.customView = PopupView.instance(for: selectedStation,
                                                              address: geocoderGoogle.address,
                                                              mapView: $mapView,
                                                              selectedType: $selectedType)
              geoView.callout.leaderPositionFlags = .any
              
              if let geoView = geoView as? AGSMapView {
                let mapCenter = geoView.visibleArea!.extent.center
                let location = AGSGeometryEngine.projectGeometry(mapCenter, to: .wgs84()) as! AGSPoint
                locationManager.panMapCenter = CLLocation(latitude: location.y, longitude: location.x)
                locationManager.scrollMapScale = geoView.mapScale
              }
              
            } else {
              let location = AGSGeometryEngine.projectGeometry(mapPoint, to: .wgs84()) as! AGSPoint
              geoView.callout.customView = nil
              geoView.callout.title = "My Location"
              geoView.callout.detail = String(format: "latitude: %.4f, longitude: %.4f", location.y, location.x)
            }
            geoView.callout.cornerRadius = 15
            geoView.callout.show(at: mapPoint, screenOffset: .zero, rotateOffsetWithMap: true, animated: true)
            timer.invalidate()
          }
        }
      }
    }
  }
  
}




