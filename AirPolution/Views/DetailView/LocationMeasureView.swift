
import SwiftUI
import ArcGIS.AGSMapView

struct LocationMeasureView: View {
  @State private var pressedDetail: MeasureType = .unsupported
  @State private var zIndex: MeasureType = .unsupported
  @Binding var mapView: AGSMapView?
  @Binding var selectedType: MeasureType?
  
  let record: Record
  let width: Int, height: Int
  var address: Address?
  var isCallout = true
  
  private func measurmentForType(_ type: MeasureType) -> SensorData {
    if let index = type.index(in: record.sensordatavalues) {
      return record.sensordatavalues[index]
    }
    return SensorData()
  }
  
  private func measureDataOrEmpty(measureType: MeasureType, width: CGFloat, anchor: UnitPoint) -> some View {
    let widthKoef = [.p1, .p2].contains(measureType) ? 0.40 : 0.25
    let offsetKoef = [.p1, .p2].contains(measureType) ? 0.03 : 0.01
    
    return MeasurementView(measureType: measureType,
                           sensorData: measurmentForType(measureType),
                           width: width * widthKoef)
    .scaleOnTap(pressedDetail: $pressedDetail, zIndex: $zIndex, measureType: measureType,
                anchor: anchor, scale: 2.4, offset: width * offsetKoef,
                popoverContent: zoodmedMeasureDataOrEmpty(measureType: measureType, width: width))
    .zIndex(zIndex == measureType ? 1 : 0)
  }
  
  private func zoodmedMeasureDataOrEmpty(measureType: MeasureType, width: CGFloat) -> ZoomedMeasureView {
    return ZoomedMeasureView(measureType: measureType,
                             sensorData: measurmentForType(measureType),
                             width: width * 0.4)
  }
  
  
  var body: some View {
    GeometryReader { geometry in
      let width = min(geometry.size.width, 400)
      
      VStack {
        
        HeaderRowView(address: address,
                      location: Location(id: record.locationId,
                                         latitude: String(record.latitude),
                                         longitude: String(record.longitude)),
                      mapView: $mapView,
                      selectedType: $selectedType,
                      isCallout: isCallout)
        .frame(maxWidth: width * 1.05)
        
        HStack {
          HStack {
            HStack {
              Image(systemName: MeasureType.p1.image)
                .resizableFrame()
                .foregroundColor((measurmentForType(.p1).mood == .unknown) ? .offlineColor : .primary)
                .padding(width * 0.01)
                .frame(maxWidth: width * 0.28, maxHeight: width * 0.26)
              VStack(spacing: width * 0.02) {
                measureDataOrEmpty(measureType: .p1, width: width, anchor: .top)
                  .padding([.vertical], 1)
                measureDataOrEmpty(measureType: .p2, width: width, anchor: .bottom)
                  .padding([.vertical], 2)
              }
            }
            .padding(width * 0.02)
          }
          .ridgedRoundedRect(isOn: !(pressedDetail == .p1 || pressedDetail == .p2))
          .zIndex((pressedDetail == .p1 || pressedDetail == .p2) ? 1 : 0)
          
          VStack(spacing: width * 0.025) {
            measureDataOrEmpty(measureType: .temperature, width: width, anchor: .topTrailing)
            measureDataOrEmpty(measureType: .humidity, width: width, anchor: .trailing)
            measureDataOrEmpty(measureType: .pressure, width: width, anchor: .bottomTrailing)
          }
          .padding(.leading, width * 0.01)
        }
        
      }
      .padding(width * 0.02)
      .backRoundRectBlur()
      .offset(x: max(0, (geometry.size.width * (1-2*0.03) - 400)/2))
    }
    .frame(width: CGFloat(width), height: CGFloat(height))
  }
}

