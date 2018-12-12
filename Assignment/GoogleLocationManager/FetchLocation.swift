//
//  LocationClass.swift
//  Tul
//
//  Created by Designer on 10/5/17.
//  Copyright © 2017 Designer. All rights reserved.
//

import UIKit
import GooglePlacePicker
import GoogleMaps
import GooglePlaces
import CoreLocation

class FetchLocation: NSObject {
    
    static func placeAutocomplete(searchData: String, completion: @escaping (_ arr : [LocationModal]?) -> Void ){
        var arrLocation = [LocationModal]()
        let placesClient1 = GMSPlacesClient()
        // let filter = GMSAutocompleteFilter()
        //  filter.type = GMSPlacesAutocompleteTypeFilter.establishment
        placesClient1.autocompleteQuery(searchData, bounds: nil, filter: nil, callback: { (results, error) -> Void in
            if error != nil {
                completion([])
            }
            if results?.count != nil {
                arrLocation = []
                for result in results! {
                    let modalL = LocationModal()
                    modalL.locationText = result.attributedFullText.string
                    modalL.locationPlaceId = result.placeID
                    modalL.locationLat = 0.0
                    modalL.locationLng = 0.0
                    arrLocation.append(modalL)
                    // print(result)
                    
                }
                completion(arrLocation)
            }
        })
        
    }
    
    static func placeIdApiToGetLatLng(placeId: String, completion: @escaping (_ dict : LocationModal?) -> Void ){
        let modalL = LocationModal()
        let placesClient1 = GMSPlacesClient()
        // let filter = GMSAutocompleteFilter()
        //  filter.type = GMSPlacesAutocompleteTypeFilter.establishment
        placesClient1.lookUpPlaceID(placeId) { (place, error) in
            if error != nil {
                
                completion(nil)
            }
            else{
                modalL.locationLat = CGFloat((place?.coordinate.latitude)!)
                modalL.locationLng = CGFloat((place?.coordinate.longitude)!)
                completion(modalL)
            }
        }
        
    }
    
    static func searchLocation(searchData: String, completion: @escaping (_ arr : CLLocationCoordinate2D?, _ locString: String) -> Void ){
        let filter = GMSAutocompleteFilter()
        let placesClient = GMSPlacesClient()
        filter.type = GMSPlacesAutocompleteTypeFilter.establishment
        placesClient.autocompleteQuery(searchData, bounds: nil, filter: filter, callback: { (results, error) -> Void in
            if error != nil {
                // print("Autocomplete error \(error)")
            }
            if results?.count != nil {
                var add = String()
                var locString = String()
                for result in results! {
                    // if (result) != nil {
                    let loc = result.placeID!
                    if add == "" {
                        add = loc
                        locString = result.attributedFullText.string
                    }
                    
                    // }
                }
                
                FetchLocation.loc(placeId: add,completion: { (arr) in
                    // print(arr!)
                    completion(arr,locString)
                })
                
            }
        })
        
    }
    
    
    static func loc(placeId: String, completion: @escaping (_ arr : CLLocationCoordinate2D?) -> Void ){
        let placesClient = GMSPlacesClient()
        placesClient.lookUpPlaceID(placeId, callback: { (place, error) -> Void in
            if error != nil {
                // print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                // print("No place details for \(placeId)")
                return
                
            }
            
            completion(place.coordinate)
        })
    }
    
    static func fetchCountryAndCity(location: CLLocation, completion: @escaping (String) -> () , Error: @escaping (String) -> ()) {
        
        
        
        let geocoder = GMSGeocoder()
        
        let coordinate = location.coordinate
        
        
        
        var currentAddress = String()
        
        
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            
            if error != nil {
                
                // print("\(String(describing: error))")
                
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    
                    
                    if let error = error {
                        Error(error.localizedDescription)
                        // print(error)
                        
                    } else if let country = placemarks?.first?.country,
                        
                        let city = placemarks?.first?.locality, let place = placemarks?.first?.subLocality, let postalCode = placemarks?.first?.postalCode, let administrativeArea = placemarks?.first?.administrativeArea  {
                        
                        
                        
                        let location1 = city.appending(", ").appending(place).appending(", ").appending(administrativeArea).appending(", ").appending(postalCode).appending(", ").appending(country)
                        
                        completion(location1)
                        
                        
                        
                    }
                    
                    
                    
                    
                    
                }
                
            }
            
            if let address = response?.firstResult() {
                
                let lines = address.lines! as [String]
                
                
                
                currentAddress = lines.joined(separator: "\n")
                
                completion(currentAddress)
                
            }
            
        }
    }
    
    
}
