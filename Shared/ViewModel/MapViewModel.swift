//
//  MapViewModel.swift
//  MapRoutes (iOS)
//
//  Created by Michele Manniello on 31/10/21.
//

import SwiftUI
import MapKit
import CoreLocation

//All Map Data Goes Here...

class MapViewModel: NSObject,ObservableObject,CLLocationManagerDelegate {
    
    @Published var mapview = MKMapView()
    let locationManager = CLLocationManager()
//    Region...
    @Published var region : MKCoordinateRegion!
    
//    Alert...
    @Published var permissionDenied = false
    
//    Map type...
    @Published var mapType : MKMapType = .standard
    
//    Search text...
    @Published var serachTxt = ""
    
//    Searched Places..
    @Published var places : [Place] = []
    
//    Updating Map Type..
    func updateMapType(){
        if mapType == .standard{
            mapType = .hybrid
            mapview.mapType = mapType
        }else{
            mapType = .standard
            mapview.mapType = mapType
        }
    }
    
//    Search Places...
    func searchQuery(){
        
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = serachTxt
        
//        Fetch
        MKLocalSearch(request: request).start { response, _ in
            guard let result = response else { return }
            
            self.places = result.mapItems.compactMap({ item -> Place? in
                return Place(placemark: item.placemark)
            })
        }
    }
    
//    Pick Search Results...
    func selectePlace(place: Place){
//        showing Pin On Map..
        serachTxt = ""
        guard let coordinate = place.placemark.location?.coordinate else { return }
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.placemark.name ?? "No Name"
        
//        Removing All Old Ones...
        mapview.removeAnnotations(mapview.annotations)
        mapview.addAnnotation(pointAnnotation)
//        Moving Map To that Location...
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapview.setRegion(coordinateRegion, animated: true)
        mapview.setVisibleMapRect(mapview.visibleMapRect, animated: true)
        
    }
    
//    focus Location...
    func focusLocation(){
        guard let _ = region else { return }
        mapview.setRegion(region, animated: true)
        mapview.setVisibleMapRect(mapview.visibleMapRect, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        Checking Permission...
            switch manager.authorizationStatus{
            case .denied:
    //            alert
                permissionDenied.toggle()
            case .notDetermined:
    //            Requesting..
                manager.requestLocation()
            case .authorizedWhenInUse:
                manager.requestLocation()
            default:
                ()
            }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        Error..
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //
    }
    
//  Getting user Region...
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        self.mapview.setRegion(self.region, animated: true)
//        Smooth Animation...
        self.mapview.setVisibleMapRect(self.mapview.visibleMapRect, animated: true)
    }
}
