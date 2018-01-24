//
//  MapVC.swift
//  pixel-city
//
//  Created by ahmed on 1/23/18.
//  Copyright © 2018 ahmed. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class MapVC: UIViewController ,UIGestureRecognizerDelegate{

    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!

    @IBOutlet weak var mapView: MKMapView!
    var regionRadious:Double = 1000
    var locationManger = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManger.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        
    }

    func addDoubleTap()  {
        let doubleTab = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTab.numberOfTapsRequired = 2
        doubleTab.delegate = self
        mapView.addGestureRecognizer(doubleTab)
    }
    func AddSwipe()  {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(AnimateViewdown))
       swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
        
    }
    func AnimateViewUp(){
    pullUpViewHeight.constant = 300
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()

        }
    }
    @objc func AnimateViewdown(){
        pullUpViewHeight.constant = 0
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
            
        }
    }
    @IBAction func CenterMapBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    

}
extension MapVC : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DropabalePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManger.location?.coordinate else{return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadious * 2.0, regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    @objc func dropPin(sender : UITapGestureRecognizer){
        RemovePin()
        AnimateViewUp()
        AddSwipe()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      let annotation = DrobablePin(coordinate: touchCoordinate, identifier: "DropabalePin")
     //   let annotation : MKPointAnnotation = MKPointAnnotation()
       // annotation.coordinate = touchCoordinate
        //annotation.title = " hello"
        
        mapView.addAnnotation(annotation)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadious * 2.0 , regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        print (touchCoordinate)
    }
    
    func RemovePin(){
        
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}
extension MapVC : CLLocationManagerDelegate{
    func configureLocationServices(){
        if authorizationStatus == .notDetermined {
            locationManger.requestAlwaysAuthorization()
        }else{
            return
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
