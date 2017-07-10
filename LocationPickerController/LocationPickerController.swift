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
    case locate = 100
    func convert() -> UIBarButtonSystemItem {
        return UIBarButtonSystemItem(rawValue: self.rawValue)!
    }
}

extension UIBarButtonItem {
    convenience init(barButtonHiddenItem item:UIBarButtonHiddenItem, target: AnyObject?, action: Selector) {
        self.init(barButtonSystemItem: item.convert(), target:target, action: action)
    }
}

public typealias successClosure = (CLLocationCoordinate2D) -> Void
public typealias failureClosure = (NSError) -> Void

open class LocationPickerController: UIViewController {

    fileprivate var mapView: MKMapView!
    fileprivate var pointAnnotation: MKPointAnnotation!
    fileprivate var userTrackingButton: MKUserTrackingBarButtonItem!

    fileprivate let locationManager: CLLocationManager = CLLocationManager()

    fileprivate var success: successClosure?
    fileprivate var failure: failureClosure?

    fileprivate var isInitialized = false

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    convenience public init(success: @escaping successClosure, failure: failureClosure? = nil) {
        self.init()
        self.success = success
        self.failure = failure
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func loadView() {
        super.loadView()

        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.mapView)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                               target: self,
                                               action: #selector(LocationPickerController.didTapCancelButton))
        self.navigationItem.leftBarButtonItem = cancelButtonItem

        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                             target: self,
                                             action: #selector(LocationPickerController.didTapDoneButton))
        self.navigationItem.rightBarButtonItem = doneButtonItem

        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                             target: nil, action: nil)
        self.userTrackingButton = MKUserTrackingBarButtonItem(mapView: self.mapView)
        self.toolbarItems = [self.userTrackingButton, flexibleButton]
        self.navigationController?.isToolbarHidden = false

        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Internal methods

internal extension LocationPickerController {

    @objc func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapDoneButton() {
        guard CLLocationCoordinate2DIsValid(self.mapView.centerCoordinate) else {
            self.failure?(NSError(domain: "LocationPickerControllerErrorDomain",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid coordinate"]))
            return
        }

        self.success?(self.mapView.centerCoordinate)

        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MKMapView delegate

extension LocationPickerController: MKMapViewDelegate {

    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard self.isInitialized else {
            return
        }
        self.pointAnnotation.coordinate = mapView.region.center
    }
}


// MARK: - CLLocationManager delegate

extension LocationPickerController: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last, !self.isInitialized else {
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
