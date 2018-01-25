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
import Alamofire
import AlamofireImage
class MapVC: UIViewController ,UIGestureRecognizerDelegate{

    @IBOutlet weak var pullUpViewHeight: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!

    @IBOutlet weak var mapView: MKMapView!
    
    var regionRadious:Double = 1000
    var locationManger = CLLocationManager()
    var authorizationStatus = CLLocationManager.authorizationStatus()
    
    var spinner : UIActivityIndicatorView?
    var progressLbl : UILabel?
    var screenSize = UIScreen.main.bounds
    
    var collectionView : UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManger.delegate = self
        
        configureLocationServices()
        addDoubleTap()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotosCell.self, forCellWithReuseIdentifier: "PhotosCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(collectionView!)
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
    func addSpinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x:(screenSize.width/2)-((spinner?.frame.width)!/2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    func removeSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: (screenSize.width/2)-120, y: 175, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir next", size: 18)
        progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    func RemoveProgressLbl(){
        if progressLbl != nil
        {
            progressLbl?.removeFromSuperview()
        }
    }
    func AnimateViewUp(){
    pullUpViewHeight.constant = 300
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()

        }
    }
    @objc func AnimateViewdown(){
        cancelAllSessions()
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
    
    func retrieveUrls(forAnnotation annotation :DrobablePin , handler: @escaping(_ status: Bool)->()){
        
        Alamofire.request(flickUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotes: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else{return}
            let photoDict = json["photos"] as! Dictionary<String,AnyObject>
            let photoDictArray = photoDict["photo"] as![Dictionary<String,AnyObject>]
            for photo in photoDictArray{
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_z_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
            
        }
        
    }
    
    
    func retrieveImages(handler : @escaping (_ status:Bool)->()){
       
        for url in imageUrlArray{
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else {return}
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 Images Downloaded"
            
                if self.imageArray.count == self.imageUrlArray.count{
                    handler(true)
                }
            })
        }
    }
    
    
    func cancelAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, UploadData, downloadData) in
            sessionDataTask .forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
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
        removeSpinner()
        RemoveProgressLbl()
        cancelAllSessions()
        
        imageArray = []
        imageUrlArray = []
        collectionView?.reloadData()
        
        AnimateViewUp()
        AddSwipe()
        addSpinner()
        addProgressLbl()
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      let annotation = DrobablePin(coordinate: touchCoordinate, identifier: "DropabalePin")
     //   let annotation : MKPointAnnotation = MKPointAnnotation()
       // annotation.coordinate = touchCoordinate
        //annotation.title = " hello"
        
        mapView.addAnnotation(annotation)
        
       // print(flickUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotes: 40))
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadious * 2.0 , regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        print (touchCoordinate)
       
        
        retrieveUrls(forAnnotation: annotation) { (finished ) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished{
                        self.removeSpinner()
                        self.RemoveProgressLbl()
                        self.collectionView?.reloadData()
                    }
                })
            }
            
        }
        
        
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


extension MapVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as? PhotosCell else{return UICollectionViewCell()}
       let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        
        return cell
        
        }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pop = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else{return}
        pop.initData(forImage: imageArray[indexPath.row])
        present(pop , animated: true, completion: nil)
        }
    
}
