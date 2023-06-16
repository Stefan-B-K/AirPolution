
import UIKit

class ImageDownloader {
  static let shared = ImageDownloader()
  
  private init () { }
  
  func downloadImage(forURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data else {
        completion(.failure(DownloadError.emptyData))
        return
      }
      
      guard let image = UIImage(data: data) else {
        completion(.failure(DownloadError.invalidImage))
        return
      }
      
      completion(.success(image))
    }
    
    task.resume()
  }
}

enum DownloadError: Error {
  case emptyData
  case invalidImage
}
