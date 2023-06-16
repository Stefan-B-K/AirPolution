
import CoreLocation

final class ReverseGeocodingGoogle {
  
  var address: Address?
  
  private let API = "Google Geocoding API".getFromPlist()

  private struct GeocodingResults: Decodable {
    let results: [GeocodingResult]
  }
  
  private struct GeocodingResult: Decodable {
    let formatted_address: String
    let address_components: [AddressComponent]
    
    struct AddressComponent: Decodable {
      let long_name: String
      let types: [String]
    }
  }
  
  func getAddress(for coordinates: CLLocation) {
    
    let fetchTask = Task { () -> [GeocodingResult] in
      let domainURL = "https://maps.googleapis.com/maps/api/geocode/json?"
      let latLng = "latlng=\(coordinates.coordinate.latitude),\(coordinates.coordinate.longitude)"
      let locationURL = URL(string: domainURL + latLng + "&key=" + API)!
      print("API ************ \(API)")
      
      let urlRequest = URLRequest(url: locationURL)
      do {
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let geoRec = try JSONDecoder().decode(GeocodingResults.self, from: data).results
        return geoRec
      } catch {
        return []
      }
    }
    
    Task {
      let results = await fetchTask.value
      
      if !results.isEmpty {
        
        DispatchQueue.main.async { [self] in
          self.address = Address()
          
          address!.street = results.flatMap { $0.address_components }.first { $0.types.contains("route") }?.long_name
          if address!.street != nil {
            address!.No = results.flatMap { $0.address_components }.first { $0.types.contains("street_number") }?.long_name
          }
          
          address!.neighbourhood = results.flatMap { $0.address_components }.first { $0.types.contains("neighborhood") }?.long_name
          if address!.neighbourhood == nil {
            address!.neighbourhood = results.flatMap { $0.address_components }.first { $0.types.contains("sublocality") }?.long_name
          }
          if address!.neighbourhood == nil {
            address!.neighbourhood = results.flatMap { $0.address_components }.first { $0.types.contains("administrative_area_level_2") }?.long_name
          }
          if address!.neighbourhood == nil {
            address!.neighbourhood = results.flatMap { $0.address_components }.first { $0.types.contains("administrative_area_level_3") }?.long_name
          }
          if address!.neighbourhood != nil {
            let postalCode = results.flatMap { $0.address_components }.first { $0.types.contains("postal_code") }?.long_name
            if let postalCode = postalCode {
              address!.neighbourhood = postalCode + " " + address!.neighbourhood!
            }
          }
          
          address!.city = results.flatMap { $0.address_components }.first { $0.types.contains("locality") }?.long_name
          if address!.city == nil {
            address!.city = results.flatMap { $0.address_components }.first { $0.types.contains("administrative_area_level_1") }?.long_name
          }
        }
        
      } 
    }
  }
 
}

