
import SwiftUI

final class AppState: ObservableObject {
  static let shared = AppState()
  private init() {}
  @Published var hasFavorites = false
  @Published var registeredForPushNotifications = false
  @Published var notificationsEnabled = false
  @Published var showPushNote = false
  @Published var locationId: Int?
  @Published var mood: Mood?
  @Published var pmType: String?
  @Published var pmLevel: Int?
}
