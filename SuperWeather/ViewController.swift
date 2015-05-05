//
//  ViewController.swift
//  SuperWeather
//
//  Created by Wang, Xinran on 5/5/15.
//  Copyright (c) 2015 Comcast. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

extension String{
    func URIencoded() -> String{
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
}

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    var temp : Float!
    var manager : CLLocationManager!
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var txtCity: UITextField!
    @IBOutlet var lstUnit: UISegmentedControl!
    @IBOutlet var lblTemp: UILabel!
    @IBOutlet var sidebarConstraint: NSLayoutConstraint!
    @IBOutlet var imgIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initLocationManager()
        
        let storage = NSUserDefaults.standardUserDefaults()
        let unit = storage.integerForKey("unit")
        lstUnit.selectedSegmentIndex = unit
        imgIcon.contentMode = UIViewContentMode.ScaleAspectFit
        
        getWeatherByLocation(manager.location)
    }
    
    func initLocationManager() -> Void {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        
        if manager.respondsToSelector(Selector("requestWhenInUseAuthorization")){
            manager.requestWhenInUseAuthorization()
        }

        manager.startUpdatingLocation()
    }
    
    @IBAction func getLocation(sender: AnyObject) {
        let location = manager.location
        getWeatherByLocation(location)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var region = MKCoordinateRegion()
        region.center = manager.location.coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        map.setRegion(region, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    }
    
    func getWeatherByLocation(location: CLLocation){
        let unit = lstUnit.selectedSegmentIndex==0 ? "metric" : "imperial"
        let urlString = "http://api.openweathermap.org/data/2.5/weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&units=\(unit)"
        getWeatherByURL(urlString)
    }
    
    func getWeatherByURL(urlString : String){
        lblTemp.alpha = 0
        imgIcon.alpha = 0
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            println("getting data with \(urlString)")
            let url = NSURL(string: urlString.URIencoded())!
            let json = NSString(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil)
            println("data received")
            println(json)
            
            if let jsonString = json {
                let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
                var error : NSError?
                let object : AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error)
                
                if let actualObject : AnyObject = object {
                    let root = actualObject as! NSDictionary
                    let cityName = root.objectForKey("name") as! String
                    let main = root.objectForKey("main") as! NSDictionary
                    self.temp = (main.objectForKey("temp") as! NSNumber).floatValue
                    let tempUnit = self.lstUnit.selectedSegmentIndex==0 ? "C" : "F"
                    
                    let weather = root.objectForKey("weather") as! NSArray
                    let firstWeather = weather[0] as! NSDictionary
                    let iconName = firstWeather.objectForKey("icon") as! String
                    let iconUrl = "http://openweathermap.org/img/w/\(iconName).png"
                    var image = UIImage(data: NSData(contentsOfURL: NSURL(string: iconUrl)!)!)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("updating temp")
                        self.lblTemp.text = "\(self.temp) °\(tempUnit)"
                        self.txtCity.text = cityName
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.lblTemp.alpha = 1
                        })
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        println("updating icon")
                        self.imgIcon.image = image
                        UIView.animateWithDuration(1, animations: { () -> Void in
                            self.imgIcon.alpha = 1
                        })
                    })
                }
            }
        })
    }
    
    
    @IBAction func getWeather(sender: AnyObject) {
        if txtCity.text == "" {
            return
        }
        let unit = lstUnit.selectedSegmentIndex==0 ? "metric" : "imperial"
        let urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(self.txtCity.text)&units=\(unit)"
        getWeatherByURL(urlString)
    }
    
    @IBAction func unitChanged(sender: AnyObject) {
        let storage = NSUserDefaults.standardUserDefaults()
        let oldUnit = storage.integerForKey("unit")
        
        getWeather(sender)
        
        storage.setInteger(lstUnit.selectedSegmentIndex, forKey: "unit")
        storage.synchronize()
    }
    
    @IBAction func backgroundDidTap(sender: AnyObject) {
        dismissKeyboard(self.view)
    }
    
    func dismissKeyboard(container: UIView){
        for var i = 0; i < container.subviews.count; i++ {
            let currentView : UIView = container.subviews[i] as! UIView
            
            if currentView.isKindOfClass(UITextField) {
                currentView.resignFirstResponder()
            } else if currentView.isMemberOfClass(UIView){
                dismissKeyboard(currentView)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
}

