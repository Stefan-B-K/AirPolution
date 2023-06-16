
import SwiftUI
import ArcGIS.AGSMapView

struct MapButton: View {
  @EnvironmentObject var locationManager: LocationManager
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Binding var mapView: AGSMapView?
  @Binding var selectedType: MeasureType?
  let location: Location?
  
  var body: some View {
    Button {
      var zeroTransition = Transaction()
      zeroTransition.disablesAnimations = true
      withTransaction(zeroTransition) {
        AppState.shared.showPushNote = false
        locationManager.showFavorites = false
      }
      
      locationManager.selectedFavoriteLocation = locationManager.favoriteLocations.first { $0.location.id == location!.id}
      
      let displace = horizontalSizeClass == .compact ? 0.001 : 0
      let agsViewpoint = AGSViewpoint(
        latitude: Double(location!.latitude)! + displace,
        longitude: Double(location!.longitude)!,
        scale: locationManager.currentMapScale > 10000 ? 10000 : locationManager.currentMapScale)
      Timer.scheduledTimer(withTimeInterval: 0.002, repeats: false) { timer in
        withAnimation {
          if locationManager.location != nil {
            locationManager.setMarkersForMeasureType(in: mapView, selectedType!)
          }
          mapView?.setViewpoint(agsViewpoint)
          locationManager.showCallout(in: $mapView,
                                      for: locationManager.selectedFavoriteLocation!,
                                      mapSelectedType: $selectedType)
        }
        timer.invalidate()
      }
      
    } label: {
      Image(systemName: "location")
        .resizable()
        .aspectRatio(1, contentMode: .fit)
        .foregroundColor(.orange)
        .opacity(1)
        .padding(5)
        .raisedRoundedRect(cornerRadius: 7)
        .frame(width: 35, height: 33)
    }
  }
}

