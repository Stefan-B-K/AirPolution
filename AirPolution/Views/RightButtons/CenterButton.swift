
import SwiftUI
import ArcGIS.AGSMapView

struct CenterButton: View {
  @EnvironmentObject var locationManager: LocationManager
  @Binding var mapView: AGSMapView!
  
  var body: some View {
    Button {
      guard let location = locationManager.location else { return }
      
      let agsPoint = AGSPoint(
        clLocationCoordinate2D: CLLocationCoordinate2D(
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude)
      )
      
      locationManager.dismissCallout(in: mapView)
      mapView.setViewpointCenter(agsPoint, scale: 30000)
      
    } label: {
      Image(systemName: "location.circle")
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


