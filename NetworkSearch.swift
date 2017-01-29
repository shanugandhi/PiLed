//
//  NetworkSearch.swift
//  PiLed
//
//  Created by Tejaswi Rohit Anupindi on 10/29/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import Foundation
import UIKit

class NetworkSearch: NSObject, NetServiceBrowserDelegate, NetServiceDelegate{
    var serviceBrowser: NetServiceBrowser!
    var devices: [NetService]!
    var validatePresence: Bool!
    var isSearching: Bool!
    
    init(validatePresence: Bool=false) {
        super.init()
        serviceBrowser = NetServiceBrowser()
        serviceBrowser.delegate = self
        self.devices = []
        self.validatePresence = validatePresence
    }
    
    func startNetworkSearch() {
        print("Network Search Started")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        serviceBrowser.searchForServices(ofType: "_piled._udp", inDomain: "local.")
        self.isSearching = true
    }
    
    func stopNetworkSearch() {
        print("Network Search Stopped")
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.serviceBrowser.stop()
        self.devices = []
        self.isSearching = false
    }
    
    func refreshNetworkSearch(){
        devices = []
        NotificationCenter.default.post(name: Notification.Name("Device List Updated:Refresh"), object: nil)
        self.stopNetworkSearch()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.startNetworkSearch() })
    }
    
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 5)
        devices.append(service)
        print(service.name)
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Removed \(service.name)")
        let cachedService = devices[devices.index(of: service)!]
        devices.remove(at: devices.index(of: service)!)
        
        let serviceDictionary = NetService.dictionary(fromTXTRecord: cachedService.txtRecordData()!)
        if serviceDictionary["mac"] != nil{
            let mac = String(bytes: serviceDictionary["mac"]!, encoding: String.Encoding.ascii)!
            NotificationCenter.default.post(name: Notification.Name("Device List Updated:Removed"), object: nil, userInfo: ["mac":mac,"service":service])
        }
        else{
            NotificationCenter.default.post(name: Notification.Name("Device List Updated:Removed"), object: service)
        }
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("Something went wrong", errorDict)
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        print("Found \(sender.name) on \(sender.hostName!)")
        
        let serviceDictionary = NetService.dictionary(fromTXTRecord: sender.txtRecordData()!)
        if serviceDictionary["mac"] != nil{
            let mac = String(bytes: serviceDictionary["mac"]!, encoding: String.Encoding.ascii)!
            if (!validatePresence && Devices.macList().contains(mac)){
                devices.remove(at: devices.index(of: sender)!)
            }
            NotificationCenter.default.post(name: Notification.Name("Device List Updated:Added"), object: nil, userInfo: ["mac":mac,"service":sender])
        }
        else{
            netService(sender, didNotResolve: ["duplicate":0])
        }
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Failed to resolve -> Device Name: \(sender.name)")
        print (errorDict)
    }
}
