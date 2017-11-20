//
//  MapFeatures.swift
//  BAD App
//
//  Created by Cody and Dalton Senior Project on 2/5/16.
//  Copyright © 2016 Cody and Dalton Senior Project. All rights reserved.
//
//
//  This class is not actually used in current version of the app,
//  but it provides a start to using geocoding rather than reading
//  out actual coordinates
//


import Foundation
import CoreLocation
import AddressBookUI
import GoogleMaps

class MapFeatures: NSObject {
    
    //Variables for google geocoding
    let initialGeocodeURL = "https://maps.googleapis.com/maps/api/geocode/json?"
    var lookupAddress: Dictionary<NSObject, AnyObject>!
    var formattedAdress: String!
    var addressLong: Double!
    var addressLat: Double!
    var long:CLLocationDegrees!
    var lat:CLLocationDegrees!
    
    
    override init(){
       super.init()
    }
    
    //Geocoding using Apple maps
    //Uses the CLGeocoder class from CoreLocation to geocode an address from input
    //Parse the response and see what placemark objects we find. If there are more than one search for area of interest
    func geocodeAddress(address: String) -> String
    {
        // Variables for the file path of the data to be saved
        let filePath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true) [0] as String
        let fileName = "/coordinates"
        let pathToTheFile = filePath.stringByAppendingString(fileName)
      //  var coordinates: [CLLocationDegrees]
        
        var lat:CLLocationDegrees = 0
        var long:CLLocationDegrees = 0
            CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error) in
            
            if error != nil {
               // print(error)
                return
            }
            if placemarks?.count > 0 {
                let placemark = placemarks?[0]
                let location = placemark?.location
                let coordinate = location?.coordinate
                let stringCoordinates:String
                lat = coordinate!.latitude
                long = coordinate!.longitude
                stringCoordinates = String(lat) + ", " + String(long)

                do {
                    try stringCoordinates.writeToFile(pathToTheFile, atomically: true, encoding: NSUTF8StringEncoding)
                }
                catch {print("Error in writing Coordinates")}
                
                
                
                print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
                if placemark?.areasOfInterest?.count > 0 {
                    let areaOfInterest = placemark!.areasOfInterest![0]
                    print(areaOfInterest)
                }
                else{
                    print("No area of interest found.")
                }
            }
            
        })
       
        var giveString:String = ""
        do {
            let text2 = try NSString(contentsOfFile: pathToTheFile, encoding: NSUTF8StringEncoding)
            giveString = text2 as String
        }
        catch {print("Error reading the file")}
      // print("text2")
       
        
        
        //var giveCoordinates: [CLLocationDegrees] = []
        
        //print("END")
       // print(giveString)
        return giveString
    }
  
}