//
//  TableViewController.swift
//  BAD App
//
//  Created by Cody and Dalton Senior Project on 4/4/16.
//  Copyright © 2016 Cody and Dalton Senior Project. All rights reserved.
//

import Foundation
import UIKit
import CSwiftV


class TableViewController: UITableViewController {

    // Variables for business info
    var businessArray = [Business]()
    var fileToRead:String = ""
    var loopCount:Int = 0
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
    
    // Variables to store filter data
    var artCultureFilter = true
    var foodDrinkFilter = true
    var publicArtFilter = true
    var otherFilter = true

    // To divide table into sections
    struct Objects {
        var sectionName : String = ""
        var sectionObjects : [Business] = []
    }
    
    var objectsArray = [Objects]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
       // loopCount = Int(businessCSV.rows[0][9])!
        while(loopCount > 0){
            self.businessArray += [Business(name: businessCSV.rows[businessCount][0], latitude: businessCSV.rows[businessCount][1], longitude: businessCSV.rows[businessCount][2], address: businessCSV.rows[businessCount][3], category: businessCSV.rows[businessCount][4], type: businessCSV.rows[businessCount][5], phone: businessCSV.rows[businessCount][6], website: businessCSV.rows[businessCount][7], description: businessCSV.rows[businessCount][8])]
            loopCount -= 1
            businessCount += 1
        }
        
        // Sort the array by category
        businessArray.sortInPlace({$0.category < $1.category})
        
        
        // Create array of all the different category names and the ammount of businesses in each category
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
            tempArray.sortInPlace({$0.name < $1.name})
            objectsArray += ([Objects(sectionName: categoryNames[sectionCount], sectionObjects: tempArray)])
            sectionCount += 1
            tempArray = []
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function for getting the size of each section
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return objectsArray[section].sectionObjects.count

    }
    
    // Function for putting info in cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell!
        
        cell.textLabel?.text = objectsArray[indexPath.section].sectionObjects[indexPath.row].name
        cell.detailTextLabel?.text = objectsArray[indexPath.section].sectionObjects[indexPath.row].type
        
        return cell
    }
    
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    // Pass business information to business detail page
    if segue.identifier == "businessSelected" {
            if let destination = segue.destinationViewController as? BusinessDetailViewController {
                
                let path = tableView.indexPathForSelectedRow
                //let cell = tableView.cellForRowAtIndexPath(path!)
                destination.business = objectsArray[(path?.section)!].sectionObjects[path!.row]
                
                destination.artCultureFilter = self.artCultureFilter
                destination.foodDrinkFilter = self.foodDrinkFilter
                destination.publicArtFilter = self.publicArtFilter
                destination.otherFilter = self.otherFilter
                
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return objectsArray.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return objectsArray[section].sectionName
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
      //  let row = indexPath.row
      //  let section = indexPath.section
    
        
    }
    
}