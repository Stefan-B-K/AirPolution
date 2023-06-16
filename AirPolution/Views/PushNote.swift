
import SwiftUI
import ArcGIS.AGSMapView

struct PushNote: View {
  @EnvironmentObject var locationManager: LocationManager
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Binding var locationId: Int?
  @Binding var mood: Mood?
  @Binding var pmType: String?
  @Binding var pmLevel: Int?
  @Binding var mapView: AGSMapView!
  
  
  var address: Address? {
    if let locationId = locationId {
      return locationManager.favoriteLocations.first { $0.location.id == locationId }?.address
    }
    return nil
  }

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 5) {
        HStack(alignment: .lastTextBaseline) {
          Text("\(mood?.rawValue.capitalized ?? "") PM\(pmType ?? "") level:")
            .font(.callout.weight(.bold))
            .foregroundColor(mood?.colorText)
          Text("\(pmLevel ?? 0)")
            .font(.title3.weight(.black))
            .foregroundColor(mood?.colorText)
          Spacer()
        }
        Text(address?.city ?? "City unknown")
          .font(.headline)
        Text(Address.fullAddress(address) ?? "No Address")
          .font(.footnote)
      }
      .padding(.top, 0)
      .padding(.bottom, 5)
      .padding(.horizontal, 5)
      .overlay(alignment: .topTrailing) {
        Button {
          AppState.shared.showPushNote = false
        } label: {
          Image(systemName: "xmark.circle.fill")
            .offset(x: 5, y: -5)
            .padding(0)
        }
        .padding(5)
        .foregroundColor(mood?.colorText)
      }
      
    }
    .frame(maxWidth: 500)
    .padding(10)
    .background(mood?.color.brightness(0.3))
    .cornerRadius(20)
  }
}
