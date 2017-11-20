//
//  BusinessDetailViewController.swift
//  BAD App
//
//  Created by Cody and Dalton Senior Project on 4/16/16.
//  Copyright © 2016 Cody and Dalton Senior Project. All rights reserved.
//

import Foundation
import UIKit

class BusinessDetailViewController: UIViewController {
    
    
    // Outlets for business info
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var descrip: UILabel!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var address: UILabel!
    
    // Variables to store filter data
    // true means display marker, false means do not display
    var artCultureFilter = true
    var foodDrinkFilter = true
    var publicArtFilter = true
    var otherFilter = true
    
    // Empty business to store info passed from the table view controller
    var business:Business = Business(name: "",latitude: "",longitude: "",address: "",category: "", type: "", phone: "",website: "",description: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fill in page info
        name.text = business.name
        address.text = business.address
        descrip.text = business.description
        websiteButton.setTitle(business.website, forState: .Normal)
        phoneButton.setTitle(business.phone, forState: .Normal)
        if(business.website == ""){
            websiteButton.hidden = true
        }
        if(business.phone == ""){
            phoneButton.hidden = true
        }
        
  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        // Go back to the list
        if segue.identifier == "backToList" {
            let destination = segue.destinationViewController as! UITabBarController
            let targetController = destination.viewControllers![0] as! ViewController
            destination.selectedIndex = 0
            targetController.artCultureFilter = self.artCultureFilter
            targetController.foodDrinkFilter = self.foodDrinkFilter
            targetController.publicArtFilter = self.publicArtFilter
            targetController.otherFilter = self.otherFilter
            
            destination.selectedIndex = 1
        }
        
        // Find business on map
        if segue.identifier == "findBusiness" {
            print(artCultureFilter)
            print(foodDrinkFilter)
            print(publicArtFilter)
            print(otherFilter)
            print(business.category)
            if(business.category == "Arts + Culture")
            {
                artCultureFilter = true
                foodDrinkFilter = false
                publicArtFilter = false
                otherFilter = false
            }
            if(business.category == "Food + Drink")
            {
                artCultureFilter = false
                foodDrinkFilter = true
                publicArtFilter = false
                otherFilter = false
            }
            if(business.category == "Public Art")
            {
                artCultureFilter = false
                foodDrinkFilter = false
                publicArtFilter = true
                otherFilter = false
            }
            if(business.category == "Other")
            {
                artCultureFilter = false
                foodDrinkFilter = false
                publicArtFilter = false
                otherFilter = true
            }
            let destination = segue.destinationViewController as! UITabBarController
            let targetController = destination.viewControllers![0] as! ViewController
            targetController.segueLat = business.latitude
            targetController.segueLong = business.longitude
            targetController.zoom = 19
            targetController.artCultureFilter = self.artCultureFilter
            targetController.foodDrinkFilter = self.foodDrinkFilter
            targetController.publicArtFilter = self.publicArtFilter
            targetController.otherFilter = self.otherFilter
        }
    }
    
    // Go to the business's website
    @IBAction func goToWebsite(sender: AnyObject) {
        let urlString = "http://" + business.website
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    // Call the business's phone number
    @IBAction func callNumber(sender: AnyObject) {
        let urlString = "tel://" + business.phone
        if let url = NSURL(string: urlString) {
            UIApplication.sharedApplication().openURL(url)
        }
        
    }
}
