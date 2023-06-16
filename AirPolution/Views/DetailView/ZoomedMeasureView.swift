
import SwiftUI

struct ZoomedMeasureView: View {
  let measureType: MeasureType
  var sensorData: SensorData
  
  let width: CGFloat
  
  var body: some View {
    
    GeometryReader { geometry in
      let width = geometry.size.width
      let height = width / 3
      
      HStack(spacing: 0) {
        
        Image(systemName: measureType.image)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(height: height)
          .padding(.leading, width * 0.03)
        
        VStack(spacing: width * 0.01) {
          Text(measureType.text)
            .fontWeight(.medium)
            .font(.system(size: height * 0.21) )
            .kerning(-1)
            .multilineTextAlignment(.center)
            .frame(width: width * 0.45)
                   
          HStack(alignment: .firstTextBaseline , spacing: width * 0.02) {
            Text("\(sensorData.value?.thousandsSpace ?? "--")")
              .kerning(-0.5)
              .fontWeight(.bold)
              .font(.system(size: height * 0.30))
            Text(measureType.unit)
              .font(.system(size: height * 0.2))
          }
          .frame(width: width * 0.45)
                  
          Text(sensorData.timestamp)
            .fontWeight(.regular)
            .kerning(-0.6)
            .font(.system(size: height * 0.15) )
            .multilineTextAlignment(.center)
            .foregroundColor((sensorData.mood == .unknown) ? .offlineColor : .primary)
            .frame(width: width * 0.45)
        }
        .padding([.top, .bottom], width * 0.01)
        .padding(.leading, width * 0.02)
        
        Image(sensorData.mood.rawValue)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(height: height)
          .padding([.leading, .trailing], width * 0.03)
      }
    }
    .frame(width: width, height: width / 3)
    .foregroundColor((sensorData.mood == .unknown) ? .offlineColor : .primary)
    .background {
      RoundedRectangle(cornerRadius: 5)
        .frame(width: width * 0.85 , height: width / 6)
        .foregroundColor(sensorData.mood.color.opacity(0.7))
        .blur(radius: 10)
    }
    .raisedRoundedRect()
  }
}
