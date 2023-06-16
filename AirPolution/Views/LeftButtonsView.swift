
import SwiftUI
import ArcGIS.AGSMapView

struct LeftButtonsView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @EnvironmentObject var locationManager: LocationManager
  @Binding var reloads: Int
  @Binding var mapView: AGSMapView!
  @State var showRefreshButton = true
  @State var currentMapCenter: AGSPoint?
  @State var currentMapScale: Double?
  @ObservedObject var appState: AppState
  @Binding var showInfo: Bool
  @Binding var selectedType: MeasureType?
  
  var body: some View {
    VStack {
      HStack {
        if !showInfo {
          settingsButton
            .padding(.trailing, 4)
        }
        appInfoButton
          .padding(.trailing, 4)
          .opacity(locationManager.showSettings ? 0 : 1)
        refreshButton
          .opacity(!showRefreshButton || showInfo ? 0 : 1)
        Spacer()
      }
      Spacer()
    }
    .padding(.top, 5)
    .padding(.horizontal, horizontalSizeClass == .compact ? 10 : 20)
  }
  
  var refreshButton: some View {
    Button {
      if !locationManager.showFavorites {
        currentMapCenter = mapView.screen(toLocation: mapView.center)
        currentMapScale = mapView.mapScale
      }
      locationManager.favoriteSensorsLoaded = false
      if !locationManager.showFavorites {
        mapView.setViewpointCenter(currentMapCenter!, scale: currentMapScale!)
      }
      locationManager.loadFavorites() {
        if !locationManager.showFavorites {
          Timer.scheduledTimer(withTimeInterval: 0.002, repeats: false) { timer in
            mapView.setViewpointCenter(currentMapCenter!, scale: currentMapScale!)
            timer.invalidate()
          }
        }
        if let location = locationManager.location {
          locationManager.loadAll(for: location) {
            if !locationManager.showFavorites {
              Timer.scheduledTimer(withTimeInterval: 0.002, repeats: false) { timer in
                mapView.setViewpointCenter(currentMapCenter!, scale: currentMapScale!)
                timer.invalidate()
              }
            }
          }
        }
      }
      reloads += 1
    } label: {
      Image(systemName: "arrow.clockwise")
        .resizable()
        .scaledToFit()
        .padding(7)
    }
    .frame(width: 40, height: 40)
    .background {
      RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor)
    }
    .if(locationManager.showFavorites) { refreshButton in
      refreshButton.raisedRoundedRect(cornerRadius: 10)
    }
  }
  
  var settingsButton: some View {
    Button {
      if !locationManager.showSettings {
        if locationManager.locationManager.authorizationStatus == .authorizedAlways ||
            locationManager.locationManager.authorizationStatus == .authorizedWhenInUse {
          locationManager.locationServicesEnabled = true
        } else {
          locationManager.locationServicesEnabled = false
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          DispatchQueue.main.async {
            if settings.authorizationStatus == .authorized {
              appState.notificationsEnabled = true
            } else {
              appState.notificationsEnabled = false
            }
          }
        }
      }
      toggleView(by: $locationManager.showSettings)
      showRefreshButton.toggle()
    } label: {
      Image(systemName: showRefreshButton ? "gearshape.fill" : "arrow.left.circle")
        .resizable()
        .scaledToFit()
        .padding(7)
    }
    .frame(width: 40, height: 40)
    .background {
      RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor)
    }
    .if(locationManager.showFavorites) { refreshButton in
      refreshButton.raisedRoundedRect(cornerRadius: 10)
    }
  }
  
  var appInfoButton: some View {
    Button {
      toggleView(by: $showInfo)
    } label: {
      Image(systemName: showInfo ? "arrow.left.circle" : "info.circle")
        .resizable()
        .scaledToFit()
        .padding(7)
    }
    .frame(width: 40, height: 40)
    .background {
      RoundedRectangle(cornerRadius: 10).fill(Color.backgroundColor)
    }
    .if(locationManager.showFavorites) { refreshButton in
      refreshButton.raisedRoundedRect(cornerRadius: 10)
    }
  }
  
  private func toggleView(by toggle: Binding<Bool>) {
    if !toggle.wrappedValue {
      if !locationManager.showFavorites {
        currentMapCenter = mapView.screen(toLocation: mapView.center)
        currentMapScale = mapView.mapScale
      }
      toggle.wrappedValue.toggle()
    } else {
      toggle.wrappedValue.toggle()
      if !locationManager.showFavorites {
        mapView.setViewpointCenter(currentMapCenter!, scale: currentMapScale!)
        Timer.scheduledTimer(withTimeInterval: 0.002, repeats: false) { timer in
          if locationManager.location != nil {
            locationManager.setMarkersForMeasureType(in: mapView, selectedType!)
          }
          timer.invalidate()
        }
      }
    }
  }

}

