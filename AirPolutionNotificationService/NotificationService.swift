//

import UserNotifications
import SwiftUI

class NotificationService: UNNotificationServiceExtension {
  var contentHandler: ((UNNotificationContent) -> Void)?
  var bestAttemptContent: UNMutableNotificationContent?
  
  override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
    self.contentHandler = contentHandler
    bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
    guard let bestAttemptContent = bestAttemptContent else { return }
    
    guard let info = bestAttemptContent.userInfo["info"] as? [String: AnyObject],
          let locationId = info["location_id"] as? Int,
          let data = UserDefaults(suiteName: Constants.savedLocationsSuite)?.object(forKey: "\(locationId)") as? Data,
          let favorite = try? JSONDecoder().decode(CityAddress.self, from: data),
          let mood = info["mood"] as? String,
          let iconsUrl = info["icons_url"] as? String,
          let pm = info["pm"] as? [String: AnyObject],
          let pmType = pm["type"] as? String,
          let pmLevel = pm["level"] as? Int
    else {
      contentHandler(UNNotificationContent())
      return
    }
    
    bestAttemptContent.title = "\(pmLevel) µg/m³"
    bestAttemptContent.subtitle = "\(mood.capitalized) PM\(pmType)"
    bestAttemptContent.body = "\(favorite.city)\n\(favorite.address)"
    
    
    let iconURL = iconsUrl + mood + ".png"
    getMediaAttachment(for: iconURL) { [weak self] image in
      guard let self = self,
            let image = image,
            let fileURL = self.saveImageAttachment(image: image,
                                                   forIdentifier: "attachment.png")
      else {
        contentHandler(bestAttemptContent)
        return
      }

      let imageAttachment = try? UNNotificationAttachment(
        identifier: "image",
        url: fileURL,
        options: nil)

      if let imageAttachment = imageAttachment {
        bestAttemptContent.attachments = [imageAttachment]
      }

      contentHandler(bestAttemptContent)
    }
  }
  
  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
      contentHandler(bestAttemptContent)
    }
  }
  
  
  // MARK: Helpers
  
  private func saveImageAttachment(image: UIImage,
                                   forIdentifier identifier: String) -> URL? {
    
    let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
    
    let directoryPath = tempDirectory.appendingPathComponent(
      ProcessInfo.processInfo.globallyUniqueString,
      isDirectory: true)
    
    do {
      try FileManager.default.createDirectory(at: directoryPath,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
      
      let fileURL = directoryPath.appendingPathComponent(identifier)
      
      guard let imageData = image.pngData() else { return nil }
      
      try imageData.write(to: fileURL)
      return fileURL
    } catch {
      return nil
    }
  }
  
  private func getMediaAttachment(for urlString: String,
                                  completion: @escaping (UIImage?) -> Void) {
    
    guard let url = URL(string: urlString) else {
      completion(nil)
      return
    }
    
    ImageDownloader.shared.downloadImage(forURL: url) { result in
      guard let image = try? result.get() else {
        completion(nil)
        return
      }
      
      completion(image)
    }
  }
  
}


