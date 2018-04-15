//
//  ViewController.swift
//  FoodHygieneApp
//
//  Created by Nathan Kiernan on 15/03/2018.
//  Copyright © 2018 Nathan Kiernan. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    // clear search results and display businesses around user again
    @IBAction func resetLocationButton(_ sender: Any) {
        loadUserLocation()
    }
    
    // searchbox actions and outlets:
    @IBOutlet weak var searchboxInput: UISearchBar!
    @IBOutlet weak var userSearchChoice: UISegmentedControl!
    @IBOutlet weak var searchBoxDisplay: UIView!
    
    // open search box so user can find businesses by name/postcode
    @IBAction func openSearchBoxButton(_ sender: Any) {
        searchBoxDisplay.isHidden = false
    }
    
    // closes search box, no details retreived
    @IBAction func closeSearchBoxButton(_ sender: Any) {
        searchBoxDisplay.isHidden = true
    }
    
    // generate user's search query according to details in search box
    @IBAction func generateUserSearchButton(_ sender: Any) {
        let index = userSearchChoice.selectedSegmentIndex // determine user search choice
        if index == 0 { // search by business name
            let userQuery = searchboxInput.text!.replacingOccurrences(of: " ", with: "%20") // encode spaces for URL
            generateQuery(op: "name", param1: userQuery, param2: "")
        } else { // search by business postcode
            let userQuery = searchboxInput.text!.replacingOccurrences(of: " ", with: "%20")
            generateQuery(op: "postcode", param1: userQuery, param2: "")
        }
        searchBoxDisplay.isHidden = true
    }
    // end of searchbox actions and outlets
    
    // an enumerator to keep track the user's query
    // main use is to ensure that business map only displays business around user
    enum queryType {
        case userLocation, businessName, businessPostcode
    }
    var currentQuery = queryType.userLocation
    
    var businessList = [Business]() // empty business object array
    var businessMapList = [Business]() // seperate array for local businesses to use with map
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide search box when app opens
        searchBoxDisplay.isHidden = true
        
        // Get user permssion for location access
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()
        
        // Setup location manager if services started
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            // if devices moves at least 50 meters, update location
            locationManager.distanceFilter = 50
            locationManager.startUpdatingLocation()
        }
        
        // obtain coordinates when app opens
        loadUserLocation()
    }
    
    // update information accordingly when the user physically moves around
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latitude = locations[0].coordinate.latitude
        let longitude = locations[0].coordinate.longitude
        updateUserLocation(lat: "\(latitude)", long: "\(longitude)")
    }
    
    // get user's current coordinates and pass them to updateUserLocation
    func loadUserLocation() {
        let latitude = locationManager.location!.coordinate.latitude
        let longitude = locationManager.location!.coordinate.longitude
        updateUserLocation(lat: "\(latitude)", long: "\(longitude)")
    }
    
    // display businesses from the user's current location in the table view
    func updateUserLocation(lat: String, long: String) {
        tableView.dataSource = self
        tableView.delegate = self
        generateQuery(op: "loc", param1: lat, param2: long)
    }
    
    // generate URL to obtain business data for all three types of queries
    func generateQuery(op: String, param1: String, param2: String?) {
        let url = "http://radikaldesign.co.uk/sandbox/hygiene.php?op=s_"
        
        if op == "loc" { // user location query
            if currentQuery != .userLocation {
                currentQuery = .userLocation
            }
            getBusinessData(query: "\(url)loc&lat=\(param1)&long=\(param2!)")
        } else if op == "name" { // business name query
            if currentQuery != .businessName {
                currentQuery = .businessName
            }
            getBusinessData(query: "\(url)name&name=\(param1)")
        } else if op == "postcode" { // business postcode query
            if currentQuery != .businessPostcode {
                currentQuery = .businessPostcode
            }
            getBusinessData(query: "\(url)postcode&postcode=\(param1)")
        }
    }
    
    // make network request to retreive business data according to query
    func getBusinessData(query: String) {
        // URL to retreive Business data
        let url = URL(string: query)
        // configure URLSession
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard let data = data else {
                print("error with data")
                return
            }
            do {
                if (self.currentQuery == .userLocation) {
                    self.businessMapList = try JSONDecoder().decode([Business].self, from: data)
                }
                self.businessList = try JSONDecoder().decode([Business].self, from: data)
                
                // interrupt main thread to update table with retreived data
                DispatchQueue.main.async {
                    self.tableView.reloadData();
                }
            } catch let err {
                print("Error: ", err)
            }
        }.resume() // start network call
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessList.count
    }
    
    // populate table view with specific information retreived businesses
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! BusinessTableViewCell
        // add business name to cell
        cell.businessNameLabel.text = "\(businessList[indexPath.row].BusinessName)"
        // add business hygiene rating image to cell
        cell.businessRatingImage.image = UIImage.init(imageLiteralResourceName: "fhrs_\(self.businessList[indexPath.row].RatingValue)_en-gb.jpg")
        
        return cell
    }
    
    // passes relevant information from this view to other views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let latitude = locationManager.location!.coordinate.latitude
        let longitude = locationManager.location!.coordinate.longitude
        if let cell = sender as? UITableViewCell {
            let i = tableView.indexPath(for: cell)!.row
            if segue.identifier == "businessDetails" { // passes business details to display in BusinessDetailsViewController
                let bdvc = segue.destination as! BusinessDetailsViewController
                bdvc.latitude = latitude
                bdvc.longitude = longitude
                bdvc.business = self.businessList[i]
            }
        } else if segue.identifier == "businessMap" { // passes business object array to display businesses on map in BusinessMapViewController
            loadUserLocation()
            let bmvc = segue.destination as! BusinessMapViewController
            bmvc.latitude = latitude
            bmvc.longitude = longitude
            bmvc.businessMapList = self.businessMapList
        }
    }
    
}
