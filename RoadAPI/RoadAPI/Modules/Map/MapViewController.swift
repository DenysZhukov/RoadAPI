//
//  MapViewController.swift
//  RoadAPI
//
//  Created by Denys on 11/18/17.
//  Copyright © 2017 Denys Zhukov. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    private let baseURLDirections = "https://roads.googleapis.com/v1/snapToRoads?path="
    private let googleAPIKey = "AIzaSyCE0ZVytP96wIWjJMz9NONwzVqjxGTrY_A"
    private weak var routeDataTask: URLSessionDataTask?
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var waypoints: [CLLocationCoordinate2D] = []
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    let differenceFactor: Double = 1E5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // commented for simulator
        //configureUserLocation()
        let coordinate = CLLocationCoordinate2D(latitude: 49.9984, longitude: 36.2428)
        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 15.0)
        mapView.animate(with: cameraUpdate)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }
    
    @IBAction func clearButtonAction() {
        mapView.clear()
        waypoints.removeAll()
    }
    
    @IBAction func routeButtonAction() {
        guard let routeString = configureRouteRequestString(), let routeURL = URL(string: routeString) else { return }
        let routeTask = URLSession.shared.dataTask(with: routeURL) { [weak self] data, _, _ in
            self?.routeDataTask = nil
            if let jsonData = data {
                do {
                    guard let json =
                        try JSONSerialization.jsonObject(with: jsonData,
                                                         options: .mutableContainers) as? [String : AnyObject] else { return }
                    guard let points = json["snappedPoints"] as? [[String : Any]] else { return }
                    var coordinates: [CLLocationCoordinate2D] = []
                    for point in points {
                        guard let location = point["location"] as? [String : Any],
                            let latitude = location["latitude"] as? Double,
                            let longitude = location["longitude"] as? Double else { continue }
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        coordinates.append(coordinate)
                    }
                    let filteredCoordinates = self?.removeCloseCoordintes(coordinates: coordinates)
                    DispatchQueue.main.async { [weak self] in
                        guard let coordinates = filteredCoordinates,
                            let path =  self?.configurePathFor(coordinates: coordinates) else { return }
                        self?.addRouteWith(path: path)
                    }
                } catch {
                    fatalError("JSON serialization has failed")
                }
            }
        }
        routeDataTask = routeTask
        routeTask.resume()
    }
    
    private func configurePathFor(coordinates: [CLLocationCoordinate2D]) -> String {
        var path: String = ""
        for (idx, coordinate) in coordinates.enumerated() {
            let ltdDif: CLLocationDegrees
            let lngDif: CLLocationDegrees
            if idx > 0 {
                ltdDif = coordinate.latitude - coordinates[idx - 1].latitude
                lngDif = coordinate.longitude - coordinates[idx - 1].longitude
            } else {
                ltdDif = coordinate.latitude
                lngDif = coordinate.longitude
            }
            if let ltdPath = convert(degree: ltdDif), let lngPath = convert(degree: lngDif) {
                path.append(ltdPath)
                path.append(lngPath)
            }
        }
        return path
    }
    
    //for converting 'CLLocationDegrees' into 'String' was used algorithm which is presented by Google
    //https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    private func convert(degree: CLLocationDegrees) -> String? {
        let startValue = lround(degree * 1E5)
        guard let str = startValue.binaryString() else { return nil }
        guard var decimal = str.intFromBinaryString() else { return nil }
        decimal = decimal << 1
        guard var binary = decimal.binaryString() else { return nil }
        if startValue.isNegative, let reversed = binary.reversBinaryString() {
            binary = reversed
        }
        var subgroups = separateBinaryForSubgroups(binary: binary)
        subgroups.reverse()
        var path: String = ""
        for (idx, subgroup) in subgroups.enumerated() {
            var binaryCode = subgroup
            if idx < subgroups.count - 1 {
                guard var decimal = subgroup.intFromBinaryString() else { return nil }
                decimal += 0x20
                guard let result = decimal.binaryString() else { return nil }
                binaryCode = result
            }
            guard let subgroupCode = Int(binaryCode, radix: 2) else { return nil }
            let asciiCode = subgroupCode + 63
            guard let unicode = UnicodeScalar(asciiCode) else { return nil }
            let asciiChar = Character(unicode)
            path.append(asciiChar)
        }
        return path
    }
    
    private func separateBinaryForSubgroups(binary: String) -> [String] {
        let lengthOfSubgroup = 5
        var clearBinary = binary.removeLeading(with: "0")
        var subgroups: [String] = []
        while clearBinary.count > lengthOfSubgroup {
            let subgroup = clearBinary.suffix(lengthOfSubgroup)
            clearBinary.removeLast(lengthOfSubgroup)
            subgroups.insert(String(subgroup), at: 0)
        }
        if !clearBinary.isEmpty {
            let zeroString = String(repeating: "0",
                                    count: lengthOfSubgroup - clearBinary.count)
            let subgroup = zeroString + clearBinary
            subgroups.insert(subgroup, at: 0)
        }
        
        return subgroups
    }
    
    private func removeCloseCoordintes(coordinates: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        var result: [CLLocationCoordinate2D] = coordinates
        var previousCoordinate: CLLocationCoordinate2D? = nil
        for (idx, coordinate) in result.enumerated() {
            guard let previous = previousCoordinate else {
                previousCoordinate = coordinate
                continue
            }
            let ltdDif = coordinate.latitude - previous.latitude
            let lngDif = coordinate.longitude - previous.longitude
            let nimDifference = 1.0 / differenceFactor
            let isClose = (ltdDif.magnitude < nimDifference) && (lngDif.magnitude < nimDifference)
            if isClose {
                result.remove(at: idx)
            }
        }
        return result
    }

    private func configureRouteRequestString() -> String? {
        var routeUrlString = baseURLDirections
        for (idx, waypoint) in waypoints.enumerated() {
            let separator = idx == 0 ? "" : "%7C"
            routeUrlString += separator + "\(waypoint.latitude),\(waypoint.longitude)"
        }
        routeUrlString += "&interpolate=true&key=" + googleAPIKey
        return routeUrlString
    }
    
    private func addRouteWith(path: String) {
        let path = GMSPath(fromEncodedPath: path)
        guard let routePath = path else { return }
        let polyline = GMSPolyline(path: path)
        polyline.map = mapView
        polyline.geodesic = true
        polyline.strokeWidth = 3.0
        polyline.strokeColor = .red
        let edgeOffset = UIEdgeInsets(top: 20.0, left: 40.0, bottom: 20.0, right: 40.0)
        let coordinateBounds = GMSCoordinateBounds(path: routePath)
        let updatesCamera = GMSCameraUpdate.fit(coordinateBounds, with: edgeOffset)
        mapView?.moveCamera(updatesCamera)
    }

    private func configureUserLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationManager.stopUpdatingLocation()
        }
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView,
                 didTapAt coordinate: CLLocationCoordinate2D) {
        waypoints.append(coordinate)
        let marker = GMSMarker(position: coordinate)
        marker.isTappable = false
        marker.appearAnimation = .pop
        marker.map = mapView
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locaiton = locations.first else { return }
        let cameraUpdate = GMSCameraUpdate.setTarget(locaiton.coordinate)
        mapView.animate(with: cameraUpdate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Location Error", message: error.localizedDescription, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
    }
    
}
