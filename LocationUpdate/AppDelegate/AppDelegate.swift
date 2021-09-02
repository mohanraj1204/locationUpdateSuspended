//
//  AppDelegate.swift
//  LocationUpdate
//
//  Created by Mohanraj on 01/09/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
    var locationManager:CLLocationManager? = CLLocationManager()
    var myLocation:CLLocation?
    var notificationCenter: UNUserNotificationCenter!

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.getPermissionForNotificaiton()
        self.handleAppLaunch(launchOptions: launchOptions)
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LocationUpdate")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


extension AppDelegate {
    
    func handleAppLaunch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        if launchOptions?[UIApplication.LaunchOptionsKey.location] != nil {
            self.handleLocationManagerWhenAppIsTerminated()
        } else {
            self.handleLocationMangerWhenAppIsLaunched()
        }
    }
    
    func handleLocationManagerWhenAppIsTerminated(){
        if locationManager == nil {
            locationManager = CLLocationManager()
        } else {
            print("Terminated location manager found")
            locationManager = nil
            locationManager = CLLocationManager()
        }//saran

        locationManager?.showsBackgroundLocationIndicator = true
        locationManager?.delegate = self
        locationManager?.distanceFilter = 10
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.startUpdatingLocation()
    }
    
    func handleLocationMangerWhenAppIsLaunched(){
        locationManager?.showsBackgroundLocationIndicator = true
        locationManager?.delegate = self
        locationManager?.distanceFilter = 10
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.allowsBackgroundLocationUpdates = true
        
        if locationManager?.authorizationStatus == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
        }
        else if locationManager?.authorizationStatus == .denied {
        }
        else if locationManager?.authorizationStatus == .authorizedWhenInUse {
            locationManager?.requestAlwaysAuthorization()
        }
        else if locationManager?.authorizationStatus == .authorizedAlways {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func getPermissionForNotificaiton(){
        self.notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
    }
    
    func createRegion(location : CLLocation){
        let geofenceRegionCenter = CLLocationCoordinate2D(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        /* Create a region centered on desired location,
         choose a radius for the region (in meters)
         choose a unique identifier for that region */
        let geofenceRegion = CLCircularRegion(
            center: geofenceRegionCenter,
            radius: 100,
            identifier: "UniqueIdentifier"
        )
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        appDelegate?.locationManager?.startMonitoring(for: geofenceRegion)
    }

    func updateUserLocationToLocalDB(loc : CLLocation){
        self.createRegion(location: loc)
        let viewModel : LocationViewModel = LocationViewModelImpl()
        viewModel.saveUserCurrentLocation(location: self.myLocation!)
            //self.scheduleLocalNotification(alert: "testing testing")
    }
    
    
    func scheduleLocalNotification(alert:String) {
        let content = UNMutableNotificationContent()
        let requestIdentifier = UUID.init().uuidString
        
        content.badge = 0
        content.title = "Location Update"
        content.body = alert
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                print(error?.localizedDescription ?? "")
            }
            print("Notification Register Success")
        }
    }
}

//MARK:- LocationManager Delegates
extension AppDelegate: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        myLocation = location
        if !(UIApplication.shared.applicationState == .active) {
            if let loc = myLocation{
                self.updateUserLocationToLocalDB(loc: loc)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            self.handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            self.handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        if region is CLCircularRegion {
            self.handleEvent(forRegion: region)
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        let content = UNMutableNotificationContent()
        content.title = "Doodleblue"
        content.body = "Hello your location is getting tracked"
        content.sound = UNNotificationSound.default
        let timeInSeconds: TimeInterval = 3
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: timeInSeconds,
            repeats: false
        )
        let identifier = region.identifier
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        completionHandler([.banner, .list, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        print(identifier)
    }
}
