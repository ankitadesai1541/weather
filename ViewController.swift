//
//  ViewController.swift
//  weatherapp(json)
//
//  Created by Student P_08 on 12/10/19.
//  Copyright © 2019 felix. All rights reserved.
//

import UIKit
import MapKit
var la = Double()
var lo = Double()
class ViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

        @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var des: UILabel!
    enum JsonErrors:Error{
        case dataError
        case conversionError
    }
    let locationmanager = CLLocationManager()
   
        override func viewDidLoad() {
        super.viewDidLoad()
            
    }
    func ParseJson()
    {
        let urlstring = "https://api.openweathermap.org/data/2.5/weather?lat=\(la)&lon=\(lo)&appid=1edf3ad9336349d859e34fadbfc542d8"
        let url:URL = URL(string : urlstring)!
        let sessionConfigration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfigration)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            do {
                guard let data = data
                    else
                {
                    throw JsonErrors.dataError
                }
                guard let coord = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
                else                {
                    throw JsonErrors.conversionError
                }
                let wArray = coord["weather"] as! [[String:Any]]
                let wDict = wArray.last!
                let descrptStr = wDict["description"] as! String
                print(descrptStr)
                self.des.text = descrptStr
                let wDict1 = coord["main"] as! [String:Any]
                let temp = wDict1["temp"] as! NSNumber
                let tem = Double(trunc(Double(temp)))
                print(tem)
                self.temperature.text = String(tem)
                let humi = wDict1["humidity"] as! NSNumber
                let hm = Double(trunc(Double(humi)))
                print(hm)
                self.humidity.text = String(hm)
                let name1 = coord["name"] as! String
                print(name1)
                self.name.text = name1
                
            }
            catch JsonErrors.dataError
            {
                print("dataerror \(error?.localizedDescription)")
            }
            catch JsonErrors.conversionError
            {
                print("conversionerror \(error?.localizedDescription)")
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
        
    }

    func detectlocation()
    {
        
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        locationmanager.delegate = self
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentlocation = locations.last!
        let latitude = currentlocation.coordinate.latitude
        let longitude = currentlocation.coordinate.longitude
        print("latitude = \(latitude) and longitude = \(longitude)")
        la = latitude
        lo = longitude
        locationmanager.stopUpdatingLocation()
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(currentlocation.coordinate, span)
        mapview.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentlocation.coordinate
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentlocation){(placemarks,error)in
          guard  let placemark:CLPlacemark = placemarks?.first else
          {
            return
            }
            let country = placemark.country
            annotation.title = country
            self.mapview.addAnnotation(annotation)
        }  }

    @IBAction func getweather(_ sender: UIButton) {
        ParseJson()
    }
    @IBAction func currentlocation(_ sender: UIButton) {
        detectlocation()
    }
    @IBOutlet weak var mapview: MKMapView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

