
import SwiftUI
import CoreLocation.CLLocation
import ArcGIS.AGSMapView

struct FavoritesButton: View {
  private let userLocationsManager = UserLocationsManager.shared
  @EnvironmentObject var locationManager: LocationManager
  @Binding var mapView: AGSMapView?
  @Binding  var isSavedToFavorites: Bool
  let location: Location?
  let address: Address?
  
  
    var body: some View {
      Button {
        if isSavedToFavorites {
          locationManager.favoriteLocations.removeAll { $0.location.id == location?.id }
          userLocationsManager.registerLocationWithServer(location: location!, action: .remove)
          UserDefaults(suiteName: Constants.savedLocationsSuite)?.removeObject(forKey: "\(location!.id)")
        } else {
          userLocationsManager.registerLocationWithServer(location: location!, action: .add)
          locationManager.favoriteLocations.append(FavoriteLocation(location: location!,
                                                                    address: address!))
          let cityAddress = CityAddress(city: address!.city!,
                                        address: Address.fullAddress(address)!)
          let encoded = try! JSONEncoder().encode(cityAddress)
          UserDefaults(suiteName: Constants.savedLocationsSuite)?.set(encoded, forKey: "\(location!.id)")
        }
        
        locationManager.currentMapCenter = CLLocation(latitude: locationManager.panMapCenter.coordinate.latitude,
                                                      longitude: locationManager.panMapCenter.coordinate.longitude)
        locationManager.currentMapScale = locationManager.scrollMapScale
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          if settings.authorizationStatus == .notDetermined {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              AppDelegate.allowNotifications()
            }
          }
        }
        
       
        
      } label: {
        Image(systemName: !isSavedToFavorites ? "star" : "star.fill")
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .foregroundColor(.orange)
          .opacity(!isSavedToFavorites ? 0.5 : 1)
          .padding(5)
          .if(isSavedToFavorites) { starImage in
            starImage.flatRidgedRoundRect(cornerRadius: 7)
          }
          .if(!isSavedToFavorites) { starImage in
            starImage.raisedRoundedRect(cornerRadius: 7)
          }
          .frame(width: 35, height: 33)
          .padding(.trailing, 2)
      }
    }
}
