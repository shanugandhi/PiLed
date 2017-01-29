//
//  Device.swift
//  PiLed
//
//  Created by Tejaswi Rohit Anupindi on 11/9/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import Foundation
import UIKit

class Devices{
    var userDevices: [String:[String:String]]
    let defaults: UserDefaults
    
    init() {
        defaults = UserDefaults.standard
        if (defaults.object(forKey: "devicesData") != nil){
            userDevices = defaults.dictionary(forKey: "devicesData")! as! [String : [String : String]]
        }
        else{
            userDevices = [:]
        }
    }
    
    class func add(service: NetService){
        let classObj = Devices()
        let serviceDictionary = NetService.dictionary(fromTXTRecord: service.txtRecordData()!)
        if serviceDictionary["mac"] != nil{
            let mac = String(bytes: serviceDictionary["mac"]!, encoding: String.Encoding.ascii)!
            classObj.userDevices[mac] = [:]
            classObj.userDevices[mac]!["name"] = service.name
            classObj.save()
        }
    }
    
    class func macList() -> Array<String>{
        let classObj = Devices()
        let macIDs = Array(classObj.userDevices.keys)
        return macIDs
    }
    
    class func paired() -> [(String, [String:String])]{
        let classObj = Devices()
        var deviceArray = [(String, [String:String])]()
        for key in Array(classObj.userDevices.keys){
            let deviceInfo = (key, classObj.userDevices[key]!)
            deviceArray.append(deviceInfo)
        }
        return deviceArray
    }
    
    func save(){
        defaults.set(userDevices, forKey: "devicesData")
    }
    
    class func delete(macID: String){
        let classObj = Devices()
        classObj.userDevices.removeValue(forKey: macID)
        classObj.save()
    }
}
