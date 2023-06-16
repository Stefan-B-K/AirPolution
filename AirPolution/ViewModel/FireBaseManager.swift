
import Foundation
import FirebaseAuth
import FirebaseFirestore


final class FireBaseManager {
  private static let _fireBaseManager = FireBaseManager()
  
  static var shared: FireBaseManager { return _fireBaseManager }
  
  
  private init() {}
  
  
  func postToFirebase(location: Location, action: String, deviceToken: String) {
    
    let collection = Firestore.firestore().collection("users-locations")
    
    // Sign in
    Auth.auth().signIn(withEmail: Constants.fbEmail.getFromPlist(),
                       password: Constants.fbPass.getFromPlist()) {_, error in
      if let error = error {
        print("Error logging in: ", error)
        return
      }
    }
    
    // user-location data
    let userAgent = (Networking.shared
      .configuration.httpAdditionalHeaders!["User-Agent"] as! String)
      .data(using: .utf8)!
      .base64EncodedString()
    var json: [String: Any] = ["action" : action,
                               "locationId": location.id,
                               "device": deviceToken]
    if action == Action.add.rawValue {
      json["user_agent"] = userAgent
      json["latitude"] = location.latitude
      json["longitude"] = location.longitude
    }
    
    // check for previous add/remove data for the same user-location
    collection
      .whereField("device", isEqualTo: deviceToken)
      .whereField("locationId", isEqualTo: location.id)
      .getDocuments { snapshot, error in

        if let error = error {
          print("Error getting docs: ", error)
          return
        }
        // if previous add/remove data
        if let docs = snapshot?.documents,
           docs.count > 0,
           let docToDelete = docs.first {
          // if same action --> do nothing
          guard docToDelete["action"] as? String != action else {
            return
          }
          // if opposite action --> just delete existing
          collection.document(docToDelete.documentID).delete() { err in
            if let error = error {
              print("Error removing document: \(docToDelete.documentID)", error)
            } else {
              print("Document \(docToDelete.documentID) successfully removed!")
            }
          }
          // if no previous data --> add new document in DB
        } else {
          let result = collection.addDocument(data: json) { error in
            if let error = error {
              print("Error adding document: ", error)
            }
          }
          print("Added document ID: ", result.documentID)
        }
      }
  }
  
}



