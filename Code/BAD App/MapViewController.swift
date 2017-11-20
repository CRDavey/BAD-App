//
//  MapViewController.swift
//  BAD App
//
//  Created by Cody and Dalton Senior Project on 1/20/16.
//  Copyright (c) 2016 Cody and Dalton Senior Project. All rights reserved.
//

import UIKit
import GoogleMaps
import CSwiftV



class ViewController: UIViewController, CLLocationManagerDelegate {
    
        
    // Map outlet
    @IBOutlet weak var mapView: GMSMapView!

    // Filter Outlet
    @IBOutlet weak var filterButton: UIButton!
    
    // Variables for location
    let locationManager = CLLocationManager()
    var foundLocation = false
    
    // Blank file for the initial download of the app
    var blankFile = "0,0,0,0,0,0,0,0,0,0,0,0\n0,0,0,0,0,0,0,0,0,0,0,0"
    
    let semaphore = dispatch_semaphore_create(0)
    
    // Variables for storing and sorting business info
    var loopCount = 0
    var markerCount = 0
    var businessArray = [Business]()
    var fileToRead:String = ""
    var businessCount:Int = 0
    var currentCategory:String = ""
    var totalCount:Int = 1
    var previousCount:Int = 0
    var sectionCount:Int = 0
    var tail:Int = 0
    var head:Int = 0
    var categoryNames: [String] = []
    var categorySizes: [Int] = []
    var tempArray: [Business] = []
    var coordinates: [CLLocationDegrees] = []
    var viewLocation = CGPoint(x: 0, y: 0)
    var needObserver = false
    
    // Variable for filters
    var filterClicked = false
    var artCultureFilter = true
    var foodDrinkFilter = true
    var publicArtFilter = true
    var otherFilter = true
    
    // Variable for focussing camera
    var lat = 42.549797
    var long = -70.880914
    var segueLat = ""
    var segueLong = ""
    var zoom:Float = 14
    
    // To divide table into sections
    struct Objects {
        var sectionName : String = ""
        var sectionObjects : [Business] = []
    }
    
    var objectsArray = [Objects]()
    
    // Variables for search
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // requestWhenInUseAuthorization() - user will be presented with an alert view asking to use current location
        // if app runs for the first time, otherwise returns preference previously specified
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Let our class observe for changes in myLocation of the mapView
        mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
        
        doesFileExist()
 
        // Check for updates to businesses
        let url = NSURL(string: "https://docs.google.com/spreadsheets/d/1aa3yjx3Ma9wqHo4zHmBDd7G7nLJiItIqVGMHLsGIfoc/pub?gid=0&single=true&output=csv")!
        load(url)
        
       
        self.mapView.bringSubviewToFront(self.filterButton)
        
    }
    
    
    // Code that runs everytime the view appears
    override func viewWillAppear(animated: Bool) {
        
        // Focus map on business when finding business
        if (segueLat != "") {
            lat = Double(segueLat)!
            long = Double(segueLong)!
        }
        
        let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: long, zoom: zoom, bearing: 90, viewingAngle: 0)
        self.mapView.camera = camera
        
        // Reset 
        segueLat = ""
        segueLong = ""
        
        placeMarkers()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action when Facebook button is clicked
    @IBAction func facebookButton(sender: AnyObject) {
        let urlString = "https://www.facebook.com/Beverly-Arts-District-BAD-359820437541419/"
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
  
    @IBAction func beverlyArtsButton(sender: AnyObject) {
        let urlString = "http://beverlyartsdistrict.org"
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FilterSegue" {
            if let destination = segue.destinationViewController as? FilterTableViewController {
                destination.artCultureFilter = self.artCultureFilter
                destination.foodDrinkFilter = self.foodDrinkFilter
                destination.publicArtFilter = self.publicArtFilter
                destination.otherFilter = self.otherFilter
            }
        }
    }
    
    //Set the myLocationEnabled flag to true if authorization status is given
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse{
            mapView.myLocationEnabled = true
        }
    }
    
    
    //If the users current location has not been spotted
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]? , context: UnsafeMutablePointer<Void>) {
        if !foundLocation{
       //     let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
            mapView.settings.myLocationButton = true
            
            foundLocation = true
        }
    }
    
    
    // Function for fetching the business data from Google Sheet
    func load(URL: NSURL) {
        
        
        // Where the file will be saved
        let filePath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true) [0] as String
        let fileName = "/beverlyBusinesses.csv"
        let pathToTheFile = filePath.stringByAppendingString(fileName)
        
        // Create a sessions with Google Sheets
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = "GET"
        
        
        // Download the csv
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            // Successfully connected
            if (error == nil) {
                
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                
                // Write the file
                let fileToBeWritten = data?.writeToFile(pathToTheFile, atomically: true)
                if (fileToBeWritten == false){
                    print("File Saving Error")
                    dispatch_semaphore_signal(self.semaphore)
                }
                else
                {
                    print("File Save Success")
                    self.createBusinessArray()
                    self.organizeBusinessArray()
                    dispatch_semaphore_signal(self.semaphore)
                    
                }
                
            }
            else {
                // Failure
                print("Faulure: %@", error!.localizedDescription);
                dispatch_semaphore_signal(self.semaphore)
            }
        })
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        placeMarkers()
    }

    func doesFileExist() {
        // Path to business data
        let filePath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true) [0] as String
        let fileName = "/beverlyBusinesses.csv"
        let pathToTheFile = filePath.stringByAppendingString(fileName)
        let checkValidation = NSFileManager.defaultManager()
        
        // Check to see if the file exists
        do {
            if (checkValidation.fileExistsAtPath(pathToTheFile))
            {
                print("FILE AVAILABLE");
            }
            else
            {
                print("FILE NOT AVAILABLE");
                // Place blank file there to allow app to continue running
                try blankFile.writeToFile(pathToTheFile, atomically: true, encoding: NSUTF8StringEncoding)
            }
        }
        catch {print("Error in writing business info")}

    }
    
    func placeMarkers(){
        
        // Clear map
        mapView.clear()
        
        // Place the appropriate markers
        loopCount = businessArray.count
        markerCount = 0
        while(loopCount > 0) {
            
            let addressLat = Double(businessArray[markerCount].latitude)
            let addressLong = Double(businessArray[markerCount].longitude)
            let lat = CLLocationDegrees(addressLat!)
            let long = CLLocationDegrees(addressLong!)
            let position = CLLocationCoordinate2DMake(lat,long)
            let marker = GMSMarker(position: position)
            marker.title = businessArray[markerCount].name
            marker.snippet = businessArray[markerCount].address + "\n" + businessArray[markerCount].type + "\n" + businessArray[markerCount].description + "\n" + businessArray[markerCount].phone
            if(businessArray[markerCount].category=="Arts + Culture" && artCultureFilter == true){
                marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
                marker.map = mapView
            }
            else if(businessArray[markerCount].category=="Food + Drink" && foodDrinkFilter == true){
                marker.icon = GMSMarker.markerImageWithColor(UIColor.orangeColor())
                marker.map = mapView
            }
            else if(businessArray[markerCount].category=="Public Art" && publicArtFilter == true){
                marker.icon = GMSMarker.markerImageWithColor(UIColor.cyanColor())
                marker.map = mapView
            }
            else if(businessArray[markerCount].category=="Other" && otherFilter == true){
                marker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
                marker.map = mapView
            }
            
            
            loopCount -= 1
            markerCount += 1
            
        }
    }
    
    func createBusinessArray() {
        // Path to business data
        let filePath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true) [0] as String
        let fileName = "/beverlyBusinesses.csv"
        let pathToTheFile = filePath.stringByAppendingString(fileName)
        
        // Read business file
        do
        {
            fileToRead = try String(contentsOfFile: pathToTheFile, encoding: NSUTF8StringEncoding)
        }
        catch
        {
            print("Error: can't read file")
        }
        
        // Parse the businesses
        let businessCSV = CSwiftV(String: fileToRead)
        
        // Put parsed businesses into a workable array
        loopCount = Int(businessCSV.headers[9])!
        print(loopCount)
        //loopCount = Int(businessCSV.rows[0][9])!
        while(loopCount > 0){
            self.businessArray += [Business(name: businessCSV.rows[businessCount][0], latitude: businessCSV.rows[businessCount][1], longitude: businessCSV.rows[businessCount][2], address: businessCSV.rows[businessCount][3], category: businessCSV.rows[businessCount][4], type: businessCSV.rows[businessCount][5], phone: businessCSV.rows[businessCount][6], website: businessCSV.rows[businessCount][7], description: businessCSV.rows[businessCount][8])]
            loopCount -= 1
            businessCount += 1
        }
    }
    
    func organizeBusinessArray() {
        
        // Sort the array category
        businessArray.sortInPlace({$0.category < $1.category})
        
        if(businessCount > 0) {
            currentCategory = businessArray[0].category
            categoryNames.append(currentCategory)
        }
        
        while(totalCount < businessCount){
            if(businessArray[totalCount].category != currentCategory){
                currentCategory = businessArray[totalCount].category
                categoryNames.append(currentCategory)
                categorySizes.append(totalCount - previousCount)
                previousCount = totalCount
            }
            
            totalCount += 1
            
        }
        categorySizes.append(totalCount - previousCount)
        
        
        // Put sections into an array of business obejects which are grouped by category
        while(sectionCount < categoryNames.count) {
            head = tail + categorySizes[sectionCount]
            while(tail < head) {
                tempArray.append(businessArray[tail])
                tail += 1
            }
            objectsArray += ([Objects(sectionName: categoryNames[sectionCount], sectionObjects: tempArray)])
            sectionCount += 1
            tempArray = []
        }
    }
    
}

/* For future search funtionality
//Handle the user's selection
extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(resultsController: GMSAutocompleteResultsViewController!, didAutocompleteWithPlace place: GMSPlace!) {
        searchController?.active = false
        //Do something with the selected place.
    }
    
    func resultsController(resultsController: GMSAutocompleteResultsViewController!, didFailAutocompleteWithError error: NSError!) {
        print("Error: ", error.description)
    }
    
    //Turn the network activity indicator on and off again
    func didRequestAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictionsForResultsController(resultsController: GMSAutocompleteResultsViewController!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
*/
