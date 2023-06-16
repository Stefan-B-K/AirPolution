
import SwiftUI
import UIKit
import ArcGIS.AGSMapView

struct HeaderRowView: View {
  @EnvironmentObject var locationManager: LocationManager
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @State private var isSavedToFavorites = false
  
  let address: Address?
  let location: Location?
  @Binding var mapView: AGSMapView?
  @Binding var selectedType: MeasureType?
  var isCallout = true
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        HStack {
          Text(address?.city ?? "City unknown")
            .font(.headline)
          Spacer()
        }
        Text(Address.fullAddress(address) ?? "Address unknown")
          .font(.caption)
          .kerning(-0.5)
          .fixedSize(horizontal: false, vertical: true)
          .multilineTextAlignment(.leading)
          .lineLimit(2)
          .padding([.top], 5)
          .padding([.trailing], 0)
      }
      .padding([.horizontal], 0)
      Spacer()
    }
    .foregroundColor(.primary)
    .padding([.top, .bottom], 8)
    .padding([.leading], 8)
    .padding([.trailing], 2)
    .ridgedRoundedRect()
    .overlay {
      if address != nil {
        buttons
          .opacity(((locationManager.favoriteSensorsLoaded && !locationManager.loadingAllSensors) ||
                    locationManager.favoriteLocations.count == 0)
                   ? 1 : 0.4)
          .disabled(!((locationManager.favoriteSensorsLoaded && !locationManager.loadingAllSensors) ||
                      locationManager.favoriteLocations.count == 0))
      }
    }
    .onAppear {
      if locationManager.favoriteLocations.map({ $0.location.id }).contains(location?.id) {
        isSavedToFavorites = true
      }
    }
    .onChange(of: locationManager.favoriteLocations.count) { newValue in
      if locationManager.favoriteLocations.map({ $0.location.id }).contains(location?.id) {
        isSavedToFavorites = true
      } else {
        isSavedToFavorites = false
      }
      if isCallout {
        let displace = horizontalSizeClass == .compact ? 0.001 : 0
        let agsViewpoint = AGSViewpoint(
          latitude: Double(location!.latitude)! + displace,
          longitude: Double(location!.longitude)!,
          scale: locationManager.currentMapScale > 10000 ? 10000 : locationManager.currentMapScale)
        Timer.scheduledTimer(withTimeInterval: 0.0, repeats: false) { timer in
          mapView?.setViewpoint(agsViewpoint)
          if isSavedToFavorites {
            locationManager.showCallout(in: $mapView,
                                        for: FavoriteLocation(location: location!,
                                                              address: address!),
                                        mapSelectedType: $selectedType)
          }
          timer.invalidate()
        }
      }
    }
  }
  
  var buttons: some View {
    ZStack {
      HStack {
        Spacer()
        VStack {
          HStack(spacing: 0) {
            Spacer()
            if locationManager.showFavorites {
              MapButton(mapView: $mapView,
                        selectedType: $selectedType,
                        location: location)
                .padding(.vertical, 1)
                .padding(.horizontal, 0)
                .scaleEffect(0.75)
            }
            FavoritesButton(mapView: $mapView,
                            isSavedToFavorites: $isSavedToFavorites, 
                            location: location, 
                            address: address)
              .padding(1)
              .scaleEffect(0.75)
          }
          Spacer()
        }
      }
    }
  }
  
}
