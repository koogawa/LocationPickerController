//
//  LocationPickerController.swift
//  LocationPickerController
//
//  Created by koogawa on 2016/05/01.
//  Copyright © 2016 koogawa. All rights reserved.
//

import UIKit
import MapKit

enum UIBarButtonHiddenItem: Int {
    case Locate = 100
    func convert() -> UIBarButtonSystemItem {
        return UIBarButtonSystemItem(rawValue: self.rawValue)!
    }
}

extension UIBarButtonItem {
    convenience init(barButtonHiddenItem item:UIBarButtonHiddenItem, target: AnyObject?, action: Selector) {
        self.init(barButtonSystemItem: item.convert(), target:target, action: action)
    }
}

typealias successClosure = (CLLocationCoordinate2D) -> Void
typealias failureClosure = (NSError) -> Void

class LocationPickerController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    var mapView: MKMapView!
    var pointAnnotation: MKPointAnnotation!
    var currentButton: UIBarButtonItem!

    let locationManager: CLLocationManager = CLLocationManager()

    var success: successClosure? = nil
    var failure: failureClosure? = nil

    var isInitialized: Bool = false

    init(success: successClosure, failure: failureClosure?) {
        self.success = success
        self.failure = failure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func loadView() {
        super.loadView()

        self.mapView = MKMapView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(self.mapView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel,
                                               target: self,
                                               action: #selector(LocationPickerController.didTapCancelButton))
        self.navigationItem.leftBarButtonItem = cancelButtonItem

        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
                                             target: self,
                                             action: #selector(LocationPickerController.didTapDoneButton))
        self.navigationItem.rightBarButtonItem = doneButtonItem

        self.currentButton = UIBarButtonItem(barButtonHiddenItem: .Locate,
                                             target: self,
                                             action: #selector(LocationPickerController.didTapCurrentButton))
        self.currentButton.enabled = false
        self.toolbarItems = [self.currentButton]
        self.navigationController?.toolbarHidden = false

        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Internal methods

    func didTapCancelButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func didTapDoneButton() {
        guard CLLocationCoordinate2DIsValid(self.mapView.centerCoordinate) else {
            if let failure = self.failure {
                failure(NSError(domain: "LocationPickerControllerErrorDomain",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid coordinate"]))
            }
            return
        }

        if let success = self.success {
            success(self.mapView.centerCoordinate)
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func didTapCurrentButton() {
        self.mapView.setCenterCoordinate(self.mapView.userLocation.coordinate, animated: true)
        self.currentButton.enabled = false
    }

    // MARK: - MKMapView delegate

    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        guard self.isInitialized else {
            return
        }
        self.currentButton.enabled = true
    }

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard self.isInitialized else {
            return
        }
        self.pointAnnotation.coordinate = mapView.region.center
    }

    // MARK: - CLLocationManager delegate

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .Restricted, .Denied:
            break
        case .Authorized, .AuthorizedWhenInUse:
            break
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        guard !self.isInitialized else {
            return
        }

        self.locationManager.stopUpdatingLocation()

        let centerCoordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        let span = MKCoordinateSpanMake(0.005, 0.005)
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        self.mapView.setRegion(region, animated: true)

        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.coordinate = newLocation.coordinate
        self.mapView.addAnnotation(self.pointAnnotation)

        self.isInitialized = true
    }
}
