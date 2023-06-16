
import SwiftUI


@main
struct MapsApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(LocationManager())
    }
  }
  
}
