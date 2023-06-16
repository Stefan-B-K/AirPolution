
import SwiftUI
import CoreLocation
import ArcGIS

@MainActor
final class LocationManager: NSObject, ObservableObject {
  let locationManager = CLLocationManager()
  private let urlAPI = "https://data.sensor.community/airrohr/v1/filter/"

  @Published var records: [Record]!
  @Published var favoriteRecords: [Record]!
  
  var locationEnabled = false
  
  @Published var location: CLLocation? {
    didSet {
      if let newLocation = location, oldValue == nil {
        stopLocationServices()
        currentMapCenter = newLocation
        currentMapScale = 30000
        records = nil
        if favoriteLocations.isEmpty {
          loadAll(for: newLocation){}
        } else {
          loadFavorites() {
            self.loadAll(for: newLocation){}
          }
        }
      }
    }
  }
  @Published var showSettings = false
  @Published var locationServicesEnabled = false
  
  @Published var showFavorites = true {
    didSet {
      if showFavorites == false && AppState.shared.locationId != nil {
        AppState.shared.locationId = nil
        AppState.shared.mood = nil
      }
    }
  }
  @Published var selectedFavoriteLocation: FavoriteLocation?
  @Published var favoriteSensorsLoaded = false
  @Published var loadingAllSensors = false
  @Published var favoriteLocations = [FavoriteLocation]() {
    didSet {
      saveFavoriteLocations()
      if oldValue.count == 0 && favoriteLocations.count > 0 {
        favoriteSensorsLoaded = true
      }
      if favoriteLocations.count == 0 {
        showFavorites = false
        favoriteSensorsLoaded = false
      }
    }
  }
  
  @Published var currentMapCenter = CLLocation(latitude: 0, longitude: 0)
  @Published var currentMapScale: Double = 100000000
  var panMapCenter = CLLocation(latitude: 0, longitude: 0)
  var scrollMapScale: Double = 0
  
  
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.favoriteLocations = loadFavoriteLocations()
    DispatchQueue.main.async {
      AppState.shared.hasFavorites = !self.favoriteLocations.isEmpty
    }
    if location == nil {
      self.startLocationServices() {auth in
        self.locationEnabled = auth == .authorizedAlways || auth == .authorizedWhenInUse
        if !self.locationEnabled && self.favoriteLocations.count != 0 {
          self.loadFavorites(){}
        }
      }
    }
  }
  
  
  
  func startLocationServices(completionHadler: @escaping (_ auth: CLAuthorizationStatus) -> ()) {
    location = nil
    let auth = locationManager.authorizationStatus
    if auth == .authorizedAlways || auth == .authorizedWhenInUse {
      locationEnabled = true
      locationManager.startUpdatingLocation()
    } else if auth == .notDetermined {
      locationManager.requestWhenInUseAuthorization()
    } else {
      DispatchQueue.main.async { [self] in
        currentMapCenter = CLLocation(latitude: 30, longitude: 22)
      }
    }
    completionHadler(auth)
  }
  
  func stopLocationServices() {
    locationManager.stopUpdatingLocation()
  }
  
  func loadSensors(location: CLLocation, radiusKM: Double = 1) async throws {
    let urlString = "\(urlAPI)area=\(location.coordinate.latitude),\(location.coordinate.longitude),\(radiusKM)"
    let url = URL(string: urlString)!
    let (data, _) = try await Networking.shared.data(from: url)
    records = try JSONDecoder().decode([Record].self, from: data)
      .sorted { $0.timestamp > $1.timestamp }
  }
  
  func loadAll(for newLocation: CLLocation, completionHandler: @escaping () -> ()) {
    loadingAllSensors = true
    Task {
      do {
        print(">>>>>>>>>>>>>>>>>>>> try loadSensors")                       //===================== print ===========================
        try await self.loadSensors(location: newLocation, radiusKM: 50)
        print(">>>>>>>>>>>>>>>>>>>> loadSensors")                           //===================== print ===========================
        if self.favoriteRecords != nil {
          self.records.append(contentsOf: self.favoriteRecords)
        }
        self.records.clearOldTimestamps()
        self.records = self.records.mergeSensors()
        loadingAllSensors = false
        completionHandler()
      } catch {
        print(error.localizedDescription)
        if records == nil { records = [] }
        loadingAllSensors = false
      }
    }
  }
  
  func loadFavoriteSensors() async throws {
    let favoriteData = await downloadFavoriteSensorsData()
    if favoriteRecords == nil { favoriteRecords = [] }
    guard !favoriteData.isEmpty else { return }
    try favoriteData.forEach { data in
      let sensor = try JSONDecoder().decode([Record].self, from: data)
        .sorted { $0.timestamp > $1.timestamp }
     
      favoriteRecords.append(contentsOf: sensor)
    }
  }
  
  private func downloadFavoriteSensorsData() async  -> [Data] {
    await withTaskGroup(of: (Int, Data?).self) { [self] group in
      for favorite in favoriteLocations {
        let favorteLat = Double(favorite.location.latitude)!
        let favorteLon = Double(favorite.location.longitude)!
        let urlString = "\(urlAPI)box=\(favorteLat - 0.0002),\(favorteLon - 0.0002),\(favorteLat + 0.0002),\(favorteLon + 0.0002)"
        let url = URL(string: urlString)!
        group.addTask { await (favorite.location.id, try? Networking.shared.data(from: url).0) }
      }
      
      let dictionary = await group.reduce(into: [:]) { $0[$1.0] = $1.1 }
      return favoriteLocations.compactMap { dictionary[$0.location.id] }
    }
  }
  
  func loadFavorites(completionHandler: @escaping () -> ()) {
    favoriteSensorsLoaded = false
    Task {
      do {
        print(">>>>>>>>>>>>>>>>>>>> try loadFavoriteSensors")                     //===================== print ===========================
        try await loadFavoriteSensors()
        print(">>>>>>>>>>>>>>>>>>>> loadFavoriteSensors")                         //===================== print ===========================
        favoriteRecords.clearOldTimestamps()
        favoriteRecords = favoriteRecords.mergeSensors()
        if records == nil {
          records = []
        }
        records.append(contentsOf: favoriteRecords)
        records.clearOldTimestamps()
        records = records.mergeSensors()
        self.favoriteSensorsLoaded = true
        completionHandler()
      } catch {
        print(error)
      }
    }
  }

}

extension LocationManager: CLLocationManagerDelegate {
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus == .authorizedAlways ||
        manager.authorizationStatus == .authorizedWhenInUse {
      locationServicesEnabled = true
      if location == nil {
        locationManager.startUpdatingLocation()
      }
    } else {
      locationServicesEnabled = false
      if location == nil {
        DispatchQueue.main.async { [self] in
          currentMapCenter = CLLocation(latitude: 30, longitude: 22)
        }
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.last else { return }
    self.location = location
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    guard let clError = error as? CLError else { return }
    switch clError {
    case CLError.denied:
      print("Access denied")
    default:
      print("Some location error: \(clError)")
    }
  }
  
}


// MARK:  Saved (Favorite) Locations

extension LocationManager {
  var savedLocationsPlistURL:URL { return URL(fileURLWithPath: "FavoriteLocations",
                                              relativeTo: FileManager.docsDirectoryURL).appendingPathExtension("plist") }
  
  private func loadFavoriteLocations() -> [FavoriteLocation] {
    guard FileManager.default.fileExists(atPath: savedLocationsPlistURL.path) else { return [] }
    do {
      let stationData = try Data(contentsOf: savedLocationsPlistURL)
      return try PropertyListDecoder().decode([FavoriteLocation].self, from: stationData)
    } catch {
      fatalError("Failed to load favorites: \(error.localizedDescription)")
    }
  }
  
  private func saveFavoriteLocations() {
    do {
      let stationData = try PropertyListEncoder().encode(favoriteLocations)
      try stationData.write(to: savedLocationsPlistURL)
    } catch {
      fatalError("Failed to save favorites: \(error.localizedDescription)")
    }
  }
  
}


// MARK:  Helper UI

extension LocationManager {
  
  func showCallout(in mapView: Binding<AGSMapView?>, for favorite: FavoriteLocation, mapSelectedType: Binding<MeasureType?>) {
    let geoView = mapView.wrappedValue! as AGSGeoView
    
    let selectedStation = records?.first { $0.locationId == favorite.location.id} ??
    Record(locationId: favorite.location.id,
           latitude: Double(favorite.location.latitude)!,
           longitude: Double(favorite.location.longitude)!,
           sensorId: 0,
           sensordatavalues: [],
           timestamp: "--")
    geoView.callout.customView = PopupView.instance(for: selectedStation,
                                                    address: favorite.address,
                                                    mapView: mapView,
                                                    selectedType: mapSelectedType)
    geoView.callout.leaderPositionFlags = .any
    geoView.callout.cornerRadius = 15
    geoView.callout.show(
      at: AGSPoint(clLocationCoordinate2D: CLLocationCoordinate2D(latitude: Double(favorite.location.latitude)!,
                                                                  longitude: Double(favorite.location.longitude)!)),
      screenOffset: .zero,
      rotateOffsetWithMap: true,
      animated: false
    )
  }
  
   func dismissCallout(in geoView: AGSGeoView) {
    if !geoView.callout.isHidden  {
      geoView.callout.dismiss()
    }
  }
  
   func setMarkersForMeasureType(in mapView: AGSMapView?, _ measureType: MeasureType) {
    mapView?.graphicsOverlays.removeAllObjects()
    dismissCallout(in: mapView!)
    let graphicsOverlay = AGSGraphicsOverlay()
    graphicsOverlay.graphics.add(SwiftUIMapView.addGraphic(location: location!))
    graphicsOverlay.graphics.addObjects(from: SwiftUIMapView.addGraphics(records: records, measureType: measureType))
    mapView?.graphicsOverlays.setArray([graphicsOverlay])
  }

}
