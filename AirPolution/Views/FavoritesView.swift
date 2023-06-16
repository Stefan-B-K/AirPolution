
import SwiftUI
import ArcGIS.AGSMapView

struct FavoritesView: View {
  @EnvironmentObject var locationManager: LocationManager
  @Binding var mapView: AGSMapView!
  @Binding var selectedType: MeasureType?
  
  var body: some View {
    
    ZStack {
      Color.backgroundColor
        .edgesIgnoringSafeArea(.all)
      
      ScrollView {
        VStack {
          ZStack {
            Text("FAVORITES")
              .font(.headline)
              .padding(.top, 70)
              .overlay(alignment: .leading) {
                if !locationManager.favoriteSensorsLoaded || locationManager.loadingAllSensors {
                  
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                    .foregroundColor(.gray)
                    .padding(.top, 70)
                    .padding(.leading, 50)
                    .offset(x: 88, y: 0)
                }
              }
          }
          .padding(.vertical, 0)
          
          ForEach(locationManager.favoriteLocations, id: \.self) { favorite in
            if locationManager.favoriteLocations.count > 2 {
              RowButton(mapView: $mapView, selectedType: $selectedType, favorite: favorite)
            } else {
              let station = locationManager.records?.first { $0.locationId == favorite.location.id} ??
              Record(locationId: favorite.location.id,
                     latitude: Double(favorite.location.latitude)!,
                     longitude: Double(favorite.location.longitude)!,
                     sensorId: 0,
                     sensordatavalues: [],
                     timestamp: "--")
              
              LocationMeasureView(mapView: $mapView,
                                  selectedType: $selectedType,
                                  record: station,
                                  width: 350,
                                  height: 200,
                                  address: favorite.address,
                                  isCallout: false)
              .padding(.top, 10)
              .padding(.bottom, 50)
            }
          }
        }
      }
    }
  }
  
}





