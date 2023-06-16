

struct Address: Codable, Identifiable, Hashable {
  var id: some Hashable { address }
  var address: String?        //    formatted_address
  var street: String?         //    route
  var No: String?
  var neighbourhood: String?   //  neighborhood  ||  sublocality || administrative_area_level_2 || administrative_area_level_3
  var city: String?             //  locality  ||  administrative_area_level_1
  
  static func fullAddress(_ address: Address?) -> String? {
    var fullAddress: String? = nil
    if let address = address?.street {
      fullAddress = address
    }
    if let No = address?.No {
      fullAddress! += " " + No
    }
    if let neighbourhood = address?.neighbourhood {
      fullAddress = fullAddress != nil ? fullAddress! + ", " + neighbourhood : neighbourhood
    }
    return fullAddress
  }
}

struct CityAddress: Codable {
  let city: String
  let address: String
}
