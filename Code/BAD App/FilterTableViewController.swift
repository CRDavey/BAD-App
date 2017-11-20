//
//  FilterTableViewController.swift
//  BAD App
//
//  Created by Cody and Dalton Senior Project on 4/16/16.
//  Copyright © 2016 Cody and Dalton Senior Project. All rights reserved.
//

import Foundation
import UIKit

class FilterTableViewController: UIViewController {
    
    // Variables for filters
    var artCultureFilter = false
    var foodDrinkFilter = false
    var publicArtFilter = false
    var otherFilter = false
    
    // Outlets for switchs
    @IBOutlet weak var artCultureSwitch: UISwitch!
    @IBOutlet weak var foodDrinkSwitch: UISwitch!
    @IBOutlet weak var publicArtSwitch: UISwitch!
    @IBOutlet weak var otherSwitch: UISwitch!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set switches initial states
        if(artCultureFilter == true)
        {
            artCultureSwitch.setOn(true, animated: false)
        }
        else
        {
            artCultureSwitch.setOn(false, animated: false)
        }
        
        if(foodDrinkFilter == true)
        {
            foodDrinkSwitch.setOn(true, animated: false)
        }
        else
        {
            foodDrinkSwitch.setOn(false, animated: false)
        }
        
        if(publicArtFilter == true)
        {
            publicArtSwitch.setOn(true, animated: false)
        }
        else
        {
            publicArtSwitch.setOn(false, animated: false)
        }
        
        if(otherFilter == true)
        {
            otherSwitch.setOn(true, animated: false)
        }
        else
        {
            otherSwitch.setOn(false, animated: false)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Send status of filters to the mapView
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FilterReturn" {
            let destination = segue.destinationViewController as! UITabBarController
            let targetController1 = destination.viewControllers![1] as! TableViewController
            targetController1.artCultureFilter = self.artCultureFilter
            targetController1.foodDrinkFilter = self.foodDrinkFilter
            targetController1.publicArtFilter = self.publicArtFilter
            targetController1.otherFilter = self.otherFilter
            let targetController2 = destination.viewControllers![0] as! ViewController
            targetController2.artCultureFilter = self.artCultureFilter
            targetController2.foodDrinkFilter = self.foodDrinkFilter
            targetController2.publicArtFilter = self.publicArtFilter
            targetController2.otherFilter = self.otherFilter
            
        }
    }
    
    // Toggling the filters' statuses

    @IBAction func artCultureFilterToggle(sender: AnyObject) {
        if(artCultureSwitch.on)
        {
            artCultureFilter = true
            print("true")
        }
        else
        {
            artCultureFilter = false
            print("false")
        }
    }
   
    
    @IBAction func foodDrinkFilterToggle(sender: AnyObject) {
        if(foodDrinkSwitch.on)
        {
            foodDrinkFilter = true
            print("true")
        }
        else
        {
            foodDrinkFilter = false
            print("false")
        }
    }

    
    @IBAction func publicArtFilterToggle(sender: AnyObject) {
        if(publicArtSwitch.on)
        {
            publicArtFilter = true
            print("true")
        }
        else
        {
            publicArtFilter = false
            print("false")
        }
    }
  
    @IBAction func otherFilterToggle(sender: AnyObject) {
        if(otherSwitch.on)
        {
            otherFilter = true
            print("true")
        }
        else
        {
            otherFilter = false
            print("false")
        }
    }
    
}