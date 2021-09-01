//
//  LocationCellViewModel.swift
//  LocationUpdate
//
//  Created by Mohanraj on 01/09/21.
//

import Foundation

protocol LocationListCellViewModel {
    var latitude : String {get}
    var longitude : String {get}
    var time : String {get}
}


class LocationListCelViewModelImpl {
    
    private let obj : UserLocation
    private let index : Int
    
    init(obj : UserLocation,index : Int) {
        self.obj = obj
        self.index = index
    }
}


extension LocationListCelViewModelImpl : LocationListCellViewModel {
    var latitude : String  {
        return obj.latitude?.description ?? ""
    }
    var longitude : String  {
        return obj.longitude?.description ?? ""
    }
    var time : String  {
        return obj.time?.description ?? ""
    }
}
