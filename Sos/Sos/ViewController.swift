//
//  ViewController.swift
//  Sos
//
//  Created by Иван Белоконь on 4/2/19.
//  Copyright © 2019 Иван Белоконь. All rights reserved.
//


import UIKit
import MessageUI
import CoreLocation

class ViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func displayMessageInterface() {
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [allNumberText]
        composeVC.body = addressLabel.text
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        } else {
            print("Can't send messages.")
        }
        
    }
    
    @IBOutlet weak var allNumber: UILabel!
    var allNumberText: String = ""{
        didSet{
            allNumber?.text = allNumberText
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let numberVC = segue.destination as? NumberViewController{
            numberVC.previousVC = self
        }
    }
    
    
    @IBAction func sendMessageButtonAction(_ sender: Any) {
        displayMessageInterface()
    }
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var findLocationButton: UIButton!
    
    
    
    let locationManager = CLLocationManager ()
    var location: CLLocation?
    var isUpdationLocation = false
    var lastLocationError: Error?
    
    // geocoder
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var isPerformingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allNumber.text = allNumberText
        updateUI()
    }
    func updateUI() {
        if let location = location {
            // TODO: populate the location labels with cordinate info
            if let placemark = placemark{
                addressLabel.text = getAdress(from: placemark)
            } else if isPerformingReverseGeocoding{
                addressLabel.text = "Searching for address.."
            }else if lastGeocodingError != nil {
                addressLabel.text = "Error finding a valid address."
            } else {
                addressLabel.text = "address Not Found"
            }
        } else {
            statusLabel.text = "Add contacts and then tap to 'Find location' to start."
            //            latitudeLabel.text = "-"
            //            longitutdeLabel.text = "-"
            addressLabel.text = " "
        }
    }
    @IBAction func fidnLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
            return
        }
        if authorizationStatus == .denied || authorizationStatus == .restricted{
            reportLocationServisesDeniedError()
            return
        }
        if isUpdationLocation {
            stopLocationManager()
        }else {
            placemark = nil
            lastGeocodingError = nil 
            location = nil
            lastLocationError = nil
            startLocationManager()
        }
        updateUI()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            isUpdationLocation = true
        }
    }
    
    func stopLocationManager() {
        if isUpdationLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            isUpdationLocation = false
        }
    }
    
    func reportLocationServisesDeniedError() {
        let alert = UIAlertController (title: "Oops! Location Services Disable.", message: "Please go to Settings > Privacy to enable location services for this app", preferredStyle: .alert)
        let okAction = UIAlertAction (title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func getAdress(from placemark: CLPlacemark) -> String {
        // 123 Test Street
        // CityName, State Zipcode
        // Country
        
        var line1 = ""
        if let street1 = placemark.subThoroughfare {
            line1 += street1 + " "
        }
        if let street2 = placemark.thoroughfare {
            line1 += street2
        }
        
        var line2 = " "
        if let city = placemark.locality {
            line2 += city + ", "
        }
        if let stateOrProvince = placemark.administrativeArea {
            line2 += stateOrProvince + " "
        }
        if let postalCode = placemark.postalCode {
            line2 += postalCode
        }
        
        var line3 = ""
        if let country = placemark.country {
            line3 += country
        }
        return line1 + "\n" + line2 + "\n" + line3
    }   
}

extension ViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR!! locationManager-didFailWithError:\(error)")
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last!
        print("GOT IT! locationManager-didUpdateLocation: \(location)")
        stopLocationManager()
        updateUI()
        
        if location != nil{
            if !isPerformingReverseGeocoding {
                print("*** Start performing geocoding...")
                isPerformingReverseGeocoding = true
                
                geocoder.reverseGeocodeLocation(location!) { (placemarks, error) in
                    self.lastGeocodingError = error
                    if error == nil, let placemarks = placemarks, !placemarks.isEmpty {
                        self.placemark = placemarks.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.isPerformingReverseGeocoding = false
                    self.updateUI()
                }
            }
        }
    }
}
