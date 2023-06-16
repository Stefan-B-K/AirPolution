//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var locationManager: LocationManager
  @ObservedObject var appState: AppState
  
  var body: some View {
    
    ZStack {
      Color.backgroundColor
        .edgesIgnoringSafeArea(.all)
      
      VStack {
        
        Text("SETTINGS")
          .font(.headline)
          .padding(.top, 70)
        
        VStack {
          ToggleView(isOn: $locationManager.locationServicesEnabled, text: "Location Services")
          ToggleView(isOn: $appState.notificationsEnabled, text: "Push Notifications")
        }
        .frame(maxWidth: 400)
        .padding(.top, 30)
        
        Spacer()
      }
      .padding(.horizontal, 20)
      
    }
  }
}

