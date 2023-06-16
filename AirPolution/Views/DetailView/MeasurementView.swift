
import SwiftUI
//import UIKit

struct MeasurementView: View {
  let measureType: MeasureType
  var sensorData: SensorData
  
  let width: CGFloat
  
  var body: some View {
    
    switch measureType {
    case .p1, .p2:
      P1P2ButtonView(measureType: measureType, sensorData: sensorData, width: width)
       
    case .temperature, .humidity, .pressure, .pressureAtSealevel:
      TempHumidPressButtonView(measureType: measureType, sensorData: sensorData, width: width)
      
    case .unsupported:
        EmptyView()
    }
  
  }
}

struct P1P2ButtonView: View {
  let measureType: MeasureType
  var sensorData: SensorData
  
  let width: CGFloat
  
  var body: some View {
    
    GeometryReader { geometry in
      let width = geometry.size.width
      let height = width / 3
      
      HStack(spacing: 0) {
        
        VStack {
          Text(measureType.text.prefix(4))
            .fontWeight(.medium)
            .kerning(-0.5)
            .font(.system(size: height * 0.3) )
            .multilineTextAlignment(.center)
          Text(measureType.text.dropFirst(4))
            .fontWeight(.medium)
            .kerning(-0.5)
            .font(.system(size: height * 0.3) )
            .multilineTextAlignment(.center)
        }
        .frame(width: width * 0.25, height: height)
        .padding(.leading, width * 0.02)
        
        Image(sensorData.mood.rawValue)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(height: height)
          .padding(.leading, width * 0.03)
        
        VStack(spacing: 0) {
          Text("\(sensorData.value?.thousandsSpace ?? "--")")
            .kerning(-0.5)
            .fontWeight(.heavy)
            .font(.system(size: height * 0.43))
          Text(measureType.unit)
            .kerning(1)
            .font(.system(size: height * 0.25))
        }
        .frame(width: width * 0.45, height: height)
        .padding(.trailing, width * 0.02)
        
      }
    }
    .frame(width: width, height: width / 3)
    .foregroundColor(sensorData.mood == .unknown ? .offlineColor : .primary)
    .background {
      RoundedRectangle(cornerRadius: 5)
        .frame(width: width * 0.85 , height: width / 6)
        .foregroundColor(sensorData.mood.color.opacity(0.7))
        .blur(radius: 10)
    }
    .raisedRoundedRect()
  }
}


struct TempHumidPressButtonView: View {
  let measureType: MeasureType
  var sensorData: SensorData
  
  let width: CGFloat
  
  var body: some View {
    
    GeometryReader { geometry in
      let width = geometry.size.width
      let height = width * 0.35
      
      HStack(spacing: 0) {
        
        Image(systemName: measureType.image)
          .resizable()
          .aspectRatio(1, contentMode: .fit)
          .frame(height: height)
          .padding(.leading, width * 0.03)
        
        Text("\(sensorData.value?.thousandsSpace ?? "--")")
          .kerning(-1)
          .fontWeight(.heavy)
          .font(.system(size: height * 0.50))
          .frame(width: width * 0.45, height: height, alignment: .trailing)
          .padding(.leading, width * 0.02)
        
        Text(measureType.unit)
          .kerning(-1)
          .fontWeight(.medium)
          .font(.system(size: height * 0.4))
          .frame(width: width * 0.3, height: height)
          .padding(.trailing, width * 0.02)
      }
    }
    .frame(width: width, height: width * 0.35)
    .foregroundColor(sensorData.mood == .unknown ? .offlineColor : .primary)
    .background {
      RoundedRectangle(cornerRadius: 5)
        .frame(width: width * 0.8, height: width * 0.17)
        .foregroundColor(sensorData.mood.color.opacity(0.7))
        .blur(radius: 6)
    }
    .raisedRoundedRect()
    
  }
}
