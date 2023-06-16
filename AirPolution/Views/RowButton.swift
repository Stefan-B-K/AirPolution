
import SwiftUI
import ArcGIS.AGSMapView

struct RowButton: View {
  @EnvironmentObject var locationManager: LocationManager
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Binding var mapView: AGSMapView!
  @Binding var selectedType: MeasureType?
  
  var favorite: FavoriteLocation
  
  var body: some View {
    
    Button {
      var zeroTransition = Transaction()
      zeroTransition.disablesAnimations = true
      withTransaction(zeroTransition) {
        AppState.shared.showPushNote = false
        locationManager.showFavorites = false
      }
      
      locationManager.selectedFavoriteLocation = favorite
      
      let displace = horizontalSizeClass == .compact ? 0.001 : 0
      let agsViewpoint = AGSViewpoint(
        latitude: Double(favorite.location.latitude)! + displace,
        longitude: Double(favorite.location.longitude)!,
        scale: locationManager.currentMapScale > 10000 ? 10000 : locationManager.currentMapScale)
      Timer.scheduledTimer(withTimeInterval: 0.002, repeats: false) { timer in
        withAnimation {
          mapView.setViewpoint(agsViewpoint)
          if locationManager.location != nil {
            locationManager.setMarkersForMeasureType(in: mapView, selectedType!)
          }
          locationManager.showCallout(in: $mapView,
                                      for: favorite,
                                      mapSelectedType: $selectedType)
        }
        timer.invalidate()
      }
      
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          HStack {
            Text(favorite.address.city ?? "No City Name")
              .font(.headline)
            Spacer()
            if let locationId = AppState.shared.locationId,
               favorite.location.id == locationId,
               let mood = AppState.shared.mood {
              Image(systemName: mood == .good ? "hand.thumbsup.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(mood.color)
                .font(.body.weight(.bold))
            }
          }
          Text(Address.fullAddress(favorite.address) ?? "No Address Found")
            .font(.subheadline)
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .padding(.trailing, 12)
        }
        Spacer()
      }
      .foregroundColor(.primary)
      .opacity((locationManager.favoriteSensorsLoaded && !locationManager.loadingAllSensors) ? 1 : 0.4)
      .frame(maxWidth: 500)
      .padding([.top, .bottom], 8)
      .padding(.leading, 12)
      .padding(.trailing, 0)
    }
    .raisedRoundedRect()
    .padding()
    .disabled(!locationManager.favoriteSensorsLoaded || locationManager.loadingAllSensors)
  }
}

