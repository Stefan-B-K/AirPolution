
import SwiftUI
import ArcGIS.AGSMapView

struct RightButtonsView: View {
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @EnvironmentObject var locationManager: LocationManager
  @Binding var mapView: AGSMapView!
  @Binding var selectedType: MeasureType?
  let measures: [MeasureType] = [.p2, .p1, .temperature, .humidity, .pressure]
  
  var hasTopNotch: Bool {
      if #available(iOS 11.0, tvOS 11.0, *) {
        return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
      }
      return false
  }
  
  var body: some View {
    
    VStack {
      HStack {
        Spacer()
        VStack(spacing: horizontalSizeClass == .compact ? 5 : 10) {
          if locationManager.favoriteLocations.count > 0 {
            StarButton(mapView: $mapView, selectedType: $selectedType)
          }
          if ProcessInfo.processInfo.isiOSAppOnMac {
            ZoomButton(zoomIn: true, action: zoomMap(in:))
            ZoomButton(zoomIn: false, action: zoomMap(in:))
          }
          if locationManager.location != nil {
            CenterButton(mapView: $mapView)            
          }
        }
        .padding(.top, 5)
        .padding(.horizontal, horizontalSizeClass == .compact ? 10 : 20)
      }
      
      Spacer()
      HStack {
        Group {
          if locationManager.location != nil {
            HStack {
              if horizontalSizeClass == .compact {
                Spacer()
              }
              ForEach(measures) { type in
                MeasureButton(type: type, selectedType: $selectedType) { type in
                  locationManager.setMarkersForMeasureType(in: mapView, type)
                  selectedType = type
                }
              }
              if horizontalSizeClass == .compact {
                Spacer()
              }
            }
          } else {
            HStack {
              if horizontalSizeClass == .compact {
                Spacer()
              }
              Text("Pick location for sensor data to be loaded")
                .multilineTextAlignment(.center)
                .font(.headline)
                .foregroundColor(.red)
                .zIndex(100)
              if horizontalSizeClass == .compact {
                Spacer()
              }
            }
          }
        }
        .padding(.top, 10)
        .padding(.bottom, hasTopNotch ? 0 : 10)
        .padding(.horizontal, horizontalSizeClass == .compact ? 0 : 30)
        .if(horizontalSizeClass == .compact) { buttons in
          buttons.background(Color.backgroundColor)
        }
        .if(horizontalSizeClass == .regular) { buttons in
          buttons.background(Rectangle().fill(Color.backgroundColor).cornerRadius(20, corners: [.topLeft, .topRight]))
        }
        .backRoundRectBlur(cornerRadius: 10)
        .ignoresSafeArea(.all)

      }
    }
  }
  
  private func zoomMap(in zoomIn: Bool) {
    let currentMapCenter = mapView.screen(toLocation: mapView.center)
    let currentMapScale = mapView.mapScale
    mapView.setViewpointCenter(currentMapCenter, scale: currentMapScale * (zoomIn ? 0.7 : 1.3))
  }

}
