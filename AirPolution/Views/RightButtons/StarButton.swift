
import SwiftUI
import ArcGIS.AGSMapView

struct StarButton: View {
  @EnvironmentObject var locationManager: LocationManager
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Binding var mapView: AGSMapView!
  @Binding var selectedType: MeasureType?
  
  var body: some View {
    Button {
      if locationManager.favoriteLocations.count == 1 {
        locationManager.selectedFavoriteLocation = locationManager.favoriteLocations.first!
        let location = locationManager.selectedFavoriteLocation?.location
        
        let displace = horizontalSizeClass == .compact ? 0.001 : 0
        let agsPoint = AGSPoint(
          clLocationCoordinate2D: CLLocationCoordinate2D(
            latitude: Double(location!.latitude)! + displace,
            longitude: Double(location!.longitude)!)
        )
        mapView.setViewpointCenter(agsPoint,
                                   scale: locationManager.currentMapScale > 10000 ? 10000 : locationManager.currentMapScale)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { timer in
          withAnimation {
            locationManager.showCallout(in: $mapView, for: locationManager.selectedFavoriteLocation!, mapSelectedType: $selectedType)
          }
          timer.invalidate()
        }
        
        
      } else {
        var zeroTransition = Transaction()
        zeroTransition.disablesAnimations = true
        withTransaction(zeroTransition) {
          locationManager.showFavorites = true
        }
      }
    } label: {
      Image(systemName: "star.fill")
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
