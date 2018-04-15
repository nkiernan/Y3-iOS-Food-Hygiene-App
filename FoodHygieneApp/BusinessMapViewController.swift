//
//  BusinessMapViewController.swift
//  FoodHygieneApp
//
//  Created by Nathan Kiernan on 19/03/2018.
//  Copyright © 2018 Nathan Kiernan. All rights reserved.
//

import UIKit
import MapKit

class BusinessMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var businessMapView: MKMapView!
    // information passed from ViewController via segue
    var latitude: Double!
    var longitude: Double!
    var businessMapList = [Business]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        businessMapView.delegate = self
        businessMapView.showsUserLocation = true
        // setup map zoom and focus
        let span :MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let location :CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        let region :MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        // use region to set map
        businessMapView.setRegion(region, animated: true)
        businessMapView.mapType = .standard
        
        // set up annotation to add to map
        let userAnnotation = CustomPin()
        userAnnotation.coordinate = location
        businessMapView.addAnnotation(userAnnotation)
        
        // add each business to map as annotion
        for b in businessMapList {
            let annotation = CustomPin()
            annotation.image = UIImage(named: "pin\(b.RatingValue)")
            annotation.coordinate = CLLocationCoordinate2DMake(Double(b.Latitude)!, Double(b.Longitude)!)
            annotation.title = b.BusinessName
            annotation.subtitle = "\(b.DistanceKM!)km away"
            businessMapView.addAnnotation(annotation)
        }
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
