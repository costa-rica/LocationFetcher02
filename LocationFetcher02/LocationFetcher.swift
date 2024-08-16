//
// This one work

import Foundation
import CoreLocation


enum LocationFetcherError:Error{
    case failedDecode
    case somethingWentWrong
    var localizedDescription:String{
        switch self{
        case.failedDecode: return "Failed to decode"
        default:return "uhhh Idk?"
        }
    }
}


class LocationFetcher: NSObject, CLLocationManagerDelegate {
    static let shared = LocationFetcher()
    
    let locationManager = CLLocationManager()
    var arryUserDayLocation: [UserDayLocation] = []
    var updateStatus: ((Int) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.stopUpdatingLocation() // Stop collecting locations
        loadUserLocation() // Called after stopping location updates
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    func stopMonitoringLocationChanges() {
//        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let userDayLocation = UserDayLocation()
        userDayLocation.timestamp = timeStampsForFileNames()
        userDayLocation.latitude = location.coordinate.latitude
        userDayLocation.longitude = location.coordinate.longitude
        print("saving data: time: \(userDayLocation.timestamp!), lat: \(userDayLocation.latitude!), lon: \(userDayLocation.longitude!)")
        arryUserDayLocation.append(userDayLocation)

        saveUserLocation()
        updateStatus?(arryUserDayLocation.count)
    }
    
    func saveUserLocation() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(arryUserDayLocation) {
            UserDefaults.standard.set(encoded, forKey: "arryUserLocation")
            print("saved to UserDefaults user_location")
        } else {
            print("failed to save ")
        }
    }
    
    func loadUserLocation() {
        arryUserDayLocation = []
        if let encodedData = UserDefaults.standard.data(forKey: "arryUserLocation") {
            do {
                let decodedArray = try JSONDecoder().decode([UserDayLocation].self, from: encodedData)
                arryUserDayLocation = decodedArray
                print("Successfully loaded arryDataSourceObjects from UserDefaults")
            } catch {
                print("Failed to decode DataSourceObject: \(error)")
            }
        }
    }
    
    
}





//
//class UpdateUserLocationDetailsDictionary: Codable {
//    var location_permission_device: Bool?
//    var location_permission_ws: Bool?
////    var user_location: [[String]]?
//    var user_location: [UserDayLocation]?
//}

class UserDayLocation: Codable {
    var timestamp: String!
    var latitude: Double!
    var longitude: Double!
}

