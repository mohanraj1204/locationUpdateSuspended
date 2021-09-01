//
//  LocationViewModel.swift
//  LocationUpdate
//
//  Created by Mohanraj on 01/09/21.
//

import Foundation
import CoreData

protocol LocationViewModel {
    var  locatioListCount : Int {get}
    func cellViewModelForLocationList(at index: Int) -> LocationListCellViewModel?
    func getLocationListLocalDB(sucess: ()->Void, failed: ()->Void)
    func saveUserCurrentLocation(location : CLLocation)
}

class LocationViewModelImpl {
     var arrLocationList : [UserLocation]? = []
    private var totalListCount : Int = 0
    
}


extension LocationViewModelImpl : LocationViewModel {
    
    var locatioListCount: Int {
        return arrLocationList?.count ?? 0
    }
    
    func cellViewModelForLocationList(at index: Int) -> LocationListCellViewModel? {
        if let locatinDetail = arrLocationList?[index] {
            return LocationListCelViewModelImpl(obj: locatinDetail, index: index)
        }
        return nil
    }
    
    // MARK: Methods to Open, Store and Fetch data
    func saveUserCurrentLocation(location : CLLocation){
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
        let UserDBObj = NSManagedObject(entity: entity!, insertInto: context)
        UserDBObj.setValue(location.coordinate.latitude, forKey: "latitude")
        UserDBObj.setValue(location.coordinate.longitude, forKey: "longitude")
        UserDBObj.setValue(Date(), forKey: "time")
        print("Storing Data..")
        do {
            try context.save()
        } catch {
            print("Storing data Failed")
        }
    }

    func getLocationListLocalDB(sucess: ()->Void, failed: ()->Void){
        context = appDelegate?.persistentContainer.viewContext
        print("Fetching Data..")
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            self.arrLocationList = [];
            for data in result as! [NSManagedObject] {
                let lat = data.value(forKey: "latitude") as? Double
                let long = data.value(forKey: "longitude") as? Double
                let date = data.value(forKey: "time") as? Date
                arrLocationList?.append(UserLocation(latitude: lat, longitude: long, time: date))
            }
            
            sucess()
        } catch {
            print("Fetching data Failed")
            failed()
        }
    }

    
    
    
}
