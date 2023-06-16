import SwiftUI
import UserNotifications
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  private let userLocationsManager = UserLocationsManager.shared
  
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    
    AppState.shared.registeredForPushNotifications = UserDefaults.standard.bool(forKey: Constants.registeredForPushNotifications)
    userLocationsManager.setDeviceToken(withSaved: UserDefaults.standard.string(forKey: Constants.deviceToken))
    
    if !AppState.shared.registeredForPushNotifications {
      registerForPushNotifications()
    }
    
    toggleNotifications(on: UIApplication.didBecomeActiveNotification)
    toggleNotifications(on: .init("NSWindowDidBecomeMainNotification"))
    
    func  toggleNotifications(on didBecomeActive: NSNotification.Name?) {
      NotificationCenter.default.addObserver(forName: didBecomeActive, object: nil, queue: .main) { _ in
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          DispatchQueue.main.async {
            if settings.authorizationStatus == .authorized {
              if !AppState.shared.notificationsEnabled {
                AppState.shared.notificationsEnabled = true
              }
            } else {
              if AppState.shared.notificationsEnabled {
                AppState.shared.notificationsEnabled = false
              }
            }
          }
        }
      }
    }
    
    FirebaseApp.configure()
    
    return true
  }
  
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    print("***********************************************************************")      //===================== print ===========================
    print("Device Token: \(token)")                                                       //===================== print ===========================
    userLocationsManager.setDeviceToken(with: token)
    print("***********************************************************************")      //===================== print ===========================
    UserDefaults.standard.set(true, forKey: Constants.registeredForPushNotifications)
    AppState.shared.registeredForPushNotifications = true
  }
  
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
  
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler:
                   @escaping (UIBackgroundFetchResult) -> Void
  ) {
    guard let info = userInfo["info"] as? [String: AnyObject],
          let pm = info["pm"] as? [String: AnyObject]
    else {
      completionHandler(.failed)
      return
    }
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      if settings.authorizationStatus == .authorized && AppState.shared.hasFavorites {
        DispatchQueue.main.async {
          guard let locationId = info["location_id"] as? Int,
                let _ = UserDefaults(suiteName: Constants.savedLocationsSuite)?.object(forKey: "\(locationId)") as? Data
          else { return }
          AppState.shared.locationId = locationId
          AppState.shared.mood = Mood.allCases.first { $0.rawValue == (info["mood"] as? String) }
          AppState.shared.pmType = pm["type"] as? String
          AppState.shared.pmLevel = pm["level"] as? Int
          AppState.shared.showPushNote = true
        }
      }
    }
  }
  
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      if settings.authorizationStatus == .authorized {
        AppState.shared.notificationsEnabled = true
      } else {
        AppState.shared.notificationsEnabled = false
      }
    }
  }
  
  
  // MARK: Reqister and ask for permission
  
  private func registerForPushNotifications() {
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
  
  static func allowNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {_, _ in}
  }
  
  
}


extension AppDelegate : UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    
    let userInfo = response.notification.request.content.userInfo
    guard let info = userInfo["info"] as? [String: AnyObject] else {
      completionHandler()
      return
    }

    UNUserNotificationCenter.current().getNotificationSettings { settings in
      if settings.authorizationStatus == .authorized {
        DispatchQueue.main.async {
          guard let locationId = info["location_id"] as? Int,
                let _ = UserDefaults(suiteName: Constants.savedLocationsSuite)?.object(forKey: "\(locationId)") as? Data
          else { return }
          AppState.shared.locationId = locationId
          AppState.shared.mood = Mood.allCases.first { $0.rawValue == (info["mood"] as? String) }
          
        }
      }
    }
    
    completionHandler()
  }
  
  
  
}

