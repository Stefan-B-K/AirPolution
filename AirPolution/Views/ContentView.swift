
import SwiftUI
import ArcGIS

struct ContentView: View {
  @EnvironmentObject var locationManager: LocationManager
  @State var mapView: AGSMapView!
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @StateObject var appState = AppState.shared
  @State var reloads = 0
  @State var showInfo = false
  @State private var selectedType: MeasureType? = .p2
  
  var pushNavigationBinding : Binding<Bool> {
    .init { () -> Bool in
      appState.locationId != nil
    } set: { (newValue) in
      if !newValue { appState.locationId = nil }
    }
  }
  
  var body: some View {
    ZStack {
      OSMapView(mapView: $mapView, selectedType: $selectedType)
        .edgesIgnoringSafeArea(.all)
        .zIndex(locationManager.showFavorites ? 0 : 200)
      
      RightButtonsView(mapView: $mapView, selectedType: $selectedType)
        .zIndex(locationManager.showFavorites || showInfo ? 0 : 200)
      
      FavoritesView(mapView: $mapView, selectedType: $selectedType)
        .zIndex(locationManager.showFavorites ? 200 : 0)
      
      SettingsView(appState: appState)
        .zIndex(locationManager.showSettings ? 200 : 0)
      
      AppInfoView()
        .zIndex(showInfo ? 201 : 0)
      
      LeftButtonsView(reloads: $reloads,
                      mapView: $mapView,
                      appState: appState,
                      showInfo: $showInfo,
                      selectedType: $selectedType)
        .zIndex(222)
      
      VStack {
        Spacer()
        PushNote(locationId: $appState.locationId, mood: $appState.mood,
                 pmType: $appState.pmType, pmLevel: $appState.pmLevel,
                 mapView: $mapView)
      }
      .opacity(appState.showPushNote ? 1 : 0)
      .padding()
      .zIndex(appState.showPushNote ? 300 : 0)
      
      if locationManager.loadingAllSensors ||
          (locationManager.favoriteLocations.count > 0 && !locationManager.favoriteSensorsLoaded) {
        VStack {
          Spacer()
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(5)
            .foregroundColor(.gray)
            .aspectRatio(contentMode: .fit)
            .padding(.bottom, 15)
          Spacer()
        }
        .zIndex(locationManager.showFavorites ? 0 : 300)
      }
    }
    .onChange(of: locationManager.location == nil, perform: { _ in
      guard let location = locationManager.location else { return }
      let agsPoint = AGSPoint(
        clLocationCoordinate2D: CLLocationCoordinate2D(
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude)
      )
      Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { timer in
        mapView.setViewpointCenter(agsPoint, scale: locationManager.currentMapScale )
        timer.invalidate()
      }
    })
    .onChange(of: locationManager.records?.count, perform: { recordsCount in
      guard let location = locationManager.location else { return }
      let agsPoint = AGSPoint(
        clLocationCoordinate2D: CLLocationCoordinate2D(
          latitude: location.coordinate.latitude,
          longitude: location.coordinate.longitude)
      )
      mapView.setViewpointCenter(agsPoint, scale: locationManager.currentMapScale )
    })
    .onReceive(appState.$locationId) { locationId in
      if let locationId = locationId,
          locationManager.favoriteLocations.contains(where: { $0.location.id == locationId }) {
        locationManager.favoriteSensorsLoaded = false
        locationManager.showFavorites = true
        locationManager.loadFavorites() {
          if let location = locationManager.location {
            locationManager.loadAll(for: location){}
          }
        }
        reloads += 1
      }
    }
    .onAppear {
      if locationManager.favoriteLocations.count > 0 {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          if settings.authorizationStatus == .notDetermined {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              AppDelegate.allowNotifications()
            }
          }
        }
      }
    }
  }
  
  private func setMap() {
    let agsViewpoint = AGSViewpoint(
      latitude: locationManager.currentMapCenter.coordinate.latitude,
      longitude: locationManager.currentMapCenter.coordinate.longitude,
      scale: locationManager.currentMapScale)
    mapView.setViewpoint(agsViewpoint)
  }
}


class AppThemeViewModel: ObservableObject {
  @AppStorage("isDarkMode") var isDarkMode: Bool = true
}
