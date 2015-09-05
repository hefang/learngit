//
//  ViewController.swift
//  Swift Weather
//
//  Created by hefang on 15/9/3.
//  Copyright (c) 2015年 hefang. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate{
    let locationManger:CLLocationManager = CLLocationManager();
    
    @IBOutlet weak var loction: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var erro: UILabel!
    
//    @IBOutlet weak var time1: UILabel!
//    @IBOutlet weak var time2: UILabel!
//    @IBOutlet weak var time3: UILabel!
//    @IBOutlet weak var time4: UILabel!
//    
//    @IBOutlet weak var image1: UIImageView!
//    @IBOutlet weak var image2: UIImageView!
//    @IBOutlet weak var image3: UIImageView!
//    @IBOutlet weak var image4: UIImageView!
//    
//    @IBOutlet weak var temp1: UILabel!
//    @IBOutlet weak var temp2: UILabel!
//    @IBOutlet weak var temp3: UILabel!
//    @IBOutlet weak var temp4: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest;
//        if(isIOS8()){
//            locationManger.requestAlwaysAuthorization();
//        }
        locationManger.requestAlwaysAuthorization();

        locationManger.startUpdatingLocation();
        loading.startAnimating();
        
        let background = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage:background!)
    }
    
    func isIOS8() ->Bool{
        return UIDevice.currentDevice().systemVersion=="8.0"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!){
        var location:CLLocation = locations[locations.count-1] as! CLLocation
        if(location.horizontalAccuracy > 0){
            println(location.coordinate.latitude);
            println(location.coordinate.longitude);
            self.updataWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
            
            locationManger.stopUpdatingLocation();
            locationManger.stopUpdatingHeading();
        }
    }
    
    func updataWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        let manager:AFHTTPRequestOperationManager = AFHTTPRequestOperationManager();
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude,"lon":longitude,"cnt":0]
        manager.GET(url,
            parameters: params,
            success: { (operation:AFHTTPRequestOperation!, responseObject: AnyObject!) in
                println("JSON: "+responseObject.description)
                
                self.updataUISuccess(responseObject as! NSDictionary!)
            },
            failure: { (operation:AFHTTPRequestOperation!, error:NSError!) in
                println("Error: "+error.localizedDescription)
            }
        )
        
    }
    
    func updataUISuccess(jsonResult:NSDictionary!){
        loading.stopAnimating();
        loading.hidden = true;

        if let tempResult = jsonResult["main"]?["temp"] as? Double{
            var temperature: Double
            if(jsonResult["sys"]?["country"] as! String == "US"){
                temperature = round(((tempResult-273.15)*1.8)+32)
            }
            else {
                temperature = round(tempResult-273.15)
            }
            self.temperature.text = "\(temperature)°"
            var name = jsonResult["name"] as! String
            self.loction.text = "\(name)";
            
            var condition = (jsonResult["weather"] as? NSArray)? [0]["id"] as! Int
            var sunrise = jsonResult["sys"]?["sunrise"] as? Double
            var sunset = jsonResult["sys"]?["sunset"] as? Double
            
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            
            if(now<sunrise||now>sunset){
                nightTime = true
            }
            self.updataWeatherIcon(condition,nightTime:nightTime)

            // Get forecast
//            for index in 1...4 {
//                println(jsonResult["list"][index])
//                if let tempResult = jsonResult["list"][index]["main"]["temp"].double {
//                    // Get and convert temperature
//                    var temperature = service.convertTemperature(country, temperature: tempResult)
//                    if (index==1) {
//                        self.temp1.text = "\(temperature)°"
//                    }
//                    else if (index==2) {
//                        self.temp2.text = "\(temperature)°"
//                    }
//                    else if (index==3) {
//                        self.temp3.text = "\(temperature)°"
//                    }
//                    else if (index==4) {
//                        self.temp4.text = "\(temperature)°"
//                    }
//                    
//                    // Get forecast time
//                    var dateFormatter = NSDateFormatter()
//                    dateFormatter.dateFormat = "HH:mm"
//                    let rawDate = json["list"][index]["dt"].doubleValue
//                    let date = NSDate(timeIntervalSince1970: rawDate)
//                    let forecastTime = dateFormatter.stringFromDate(date)
//                    if (index==1) {
//                        self.time1.text = forecastTime
//                    }
//                    else if (index==2) {
//                        self.time2.text = forecastTime
//                    }
//                    else if (index==3) {
//                        self.time3.text = forecastTime
//                    }
//                    else if (index==4) {
//                        self.time4.text = forecastTime
//                    }
//                    
//                    // Get and set icon
//                    let weather = json["list"][index]["weather"][0]
//                    let condition = weather["id"].intValue
//                    var icon = weather["icon"].stringValue
//                    var nightTime = service.isNightTime(icon)
//                    service.updateWeatherIcon(condition, nightTime: nightTime, index: index, callback: self.updatePictures)
//                }
//                else {
//                    continue
//                }
//            }
            
        }else {
            erro.text = "获取天气数据失败！"
        }
    }

    func updataWeatherIcon(condition:Int,nightTime:Bool){
        if(condition<300){
            if(nightTime){
                self.icon.image = UIImage(named: "tstorm1_night")
            }else {
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
        else if(condition<500){
            self.icon.image = UIImage(named: "light_rain")
        }
        else if(condition<600){
            self.icon.image = UIImage(named: "shower3")
            
        }
        else if(condition<700){

            self.icon.image = UIImage(named: "show4")
            
        }
        else if(condition<771){
            if(nightTime){
                self.icon.image = UIImage(named: "fog_night")
            }else {
                self.icon.image = UIImage(named: "fog")
            }
        }
        else if(condition<800){

            self.icon.image = UIImage(named: "tstorm3")
        }
        else if(condition==800){
            if(nightTime){
                self.icon.image = UIImage(named: "sunny_night")
            }else {
                self.icon.image = UIImage(named: "sunny")
            }
        }

        else if(condition<804){
            if(nightTime){
                self.icon.image = UIImage(named: "cloudy2_night")
            }else {
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
        else if(condition==804){
            self.icon.image = UIImage(named: "overcast")
        }
        else if((condition>=900&&condition<903)||(condition>904&&condition<1000)){
            self.icon.image = UIImage(named: "tstorm3")

        }
        else if(condition==903){
            self.icon.image = UIImage(named: "snow5")

        }
        else if(condition==904){
            self.icon.image = UIImage(named: "sunny")
            
        }
        else {
            self.icon.image = UIImage(named: "dunno")
            
        }
    }
    

    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!){
        println(error);
    }
    

}

