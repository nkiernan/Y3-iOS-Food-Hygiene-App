//
//  BusinessDetailsViewController.swift
//  FoodHygieneApp
//
//  Created by Nathan Kiernan on 22/03/2018.
//  Copyright © 2018 Nathan Kiernan. All rights reserved.
//

import UIKit
import MapKit

class BusinessDetailsViewController: UIViewController, MKMapViewDelegate {
    // information passed from ViewController via segue
    var latitude: Double!
    var longitude: Double!
    var business: Business!
    
    // outlets corresponding to selected business's details
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var addressLine1Label: UILabel!
    @IBOutlet weak var addressLine2Label: UILabel!
    @IBOutlet weak var addressLineLabel3: UILabel!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var ratingDateLabel: UILabel!
    @IBOutlet weak var ratingValueImage: UIImageView!
    @IBOutlet weak var businessLocationMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display business details using respective outlets
        businessNameLabel.text = business!.BusinessName
        addressLine1Label.text = business!.AddressLine1
        addressLine2Label.text = business!.AddressLine2
        addressLineLabel3.text = business!.AddressLine3
        postcodeLabel.text = business!.PostCode
        ratingDateLabel.text = "Rating from \(business!.RatingDate):"
        ratingValueImage.image = UIImage.init(named: "fhrs_\(business!.RatingValue)_en-gb.jpg")
        
        businessLocationMap.delegate = self
        businessLocationMap.showsUserLocation = true
        // setup map zoom and focus
        let span :MKCoordinateSpan = MKCoordinateSpanMake(0.003, 0.003)
        let location :CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(business!.Latitude)!, Double(business!.Longitude)!)
        let region :MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        // use region to set map
        businessLocationMap.setRegion(region, animated: true)
        businessLocationMap.mapType = .standard
        
        // set up annotation to add to map
        let userAnnotation = CustomPin()
        userAnnotation.coordinate = location
        businessLocationMap.addAnnotation(userAnnotation)
        let userLocation = CLLocation(latitude: latitude!, longitude: longitude!)
        let annotation = CustomPin()
        annotation.image = UIImage(named: "pin\(business.RatingValue)")
        annotation.coordinate = CLLocationCoordinate2DMake(Double(business!.Latitude)!, Double(business!.Longitude)!)
        annotation.title = business!.BusinessName
        
        // calculate distance between user and business
        let businessLocation = CLLocation(latitude: Double(business!.Latitude)!, longitude: Double(business!.Longitude)!)
        annotation.subtitle = "\(Double(round(100 * ((userLocation.distance(from: businessLocation)) / 1000)) / 100))km away"
        
        businessLocationMap.addAnnotation(annotation)
    }
    
    // add annotation to map view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPin
        annotationView!.image = customPointAnnotation.image
        return annotationView
    }
}
