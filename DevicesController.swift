//
//  DevicesController.swift
//  PiLed
//
//  Created by Tejaswi Rohit Anupindi on 11/9/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit

class DevicesController: UITableViewController, UIApplicationDelegate{
    
    var deviceTableIdentifications: [String:IndexPath]!
    var networkSearch: NetworkSearch!
    var networkSelected :NetService!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: Notification.Name("App Coming Foreground"), object: nil)

        deviceTableIdentifications = [:]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if (self.networkSearch != nil && self.networkSearch.isSearching){
            self.networkSearch.stopNetworkSearch()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Device List Updated:Added"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Device List Updated:Removed"), object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.tableView.numberOfRows(inSection: 0) != Devices.paired().count{
            tableView.reloadData()
        }
        if self.networkSearch != nil && !self.networkSearch.isSearching{
            self.networkSearch.startNetworkSearch()
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        deviceTableIdentifications = [:]
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Devices.paired().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath) as! DeviceTableCell
        
        let deviceInfo = Devices.paired()
        cell.deviceName?.text = deviceInfo[indexPath.row].1["name"]
        cell.deviceIP?.text = ""
        cell.deviceMac = deviceInfo[indexPath.row].0
        cell.powerSwitch.isEnabled = false
        
        deviceTableIdentifications[cell.deviceMac] =  indexPath
        
        if indexPath.row == Devices.paired().count - 1{
            self.searchForDevices()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let cell = tableView.cellForRow(at: indexPath) as! DeviceTableCell
            Devices.delete(macID: cell.deviceMac)
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DeviceTableCell
        if !cell.powerSwitch.isEnabled{
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    @IBAction func refreshDevices(_ sender: UIRefreshControl) {
        if self.networkSearch == nil{
            self.networkSearch = NetworkSearch(validatePresence: true)
            self.networkSearch.startNetworkSearch()
        }
        else{
            self.networkSearch.stopNetworkSearch()
            self.networkSearch.startNetworkSearch()
        }
        sender.endRefreshing()
    }
    
    
    func updateTableData(){
        self.tableView.reloadData()
    }
    
    func searchForDevices(){
        NotificationCenter.default.addObserver(self, selector: #selector(foundDevice), name: Notification.Name("Device List Updated:Added"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removedDevice), name: Notification.Name("Device List Updated:Removed"), object: nil)
        
        if self.networkSearch == nil{
            self.networkSearch = NetworkSearch(validatePresence: true)
            self.networkSearch.startNetworkSearch()
        }
        
    }
    
    func foundDevice(notification: Notification){
        let notificationUserInfo = notification.userInfo
        let macID = notificationUserInfo?["mac"] as! String
        let service = notificationUserInfo?["service"] as! NetService
        if let indexPath = deviceTableIdentifications[macID]{
             //Get IP Address
             let theAddress = service.addresses!.first! as NSData
             var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
             if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t((theAddress.length)),
             &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
             let numAddress = String(cString: hostname)
                
            let cell = tableView.cellForRow(at: indexPath) as! DeviceTableCell
            cell.powerSwitch.isEnabled = true
            cell.deviceIP?.text = numAddress
            cell.hostPort = String(service.port)
            cell.hostName = service.hostName
            cell.service = service
            cell.getSwitchState()
            }
        }
    }
    
    func removedDevice(notification: Notification){
        let notificationUserInfo = notification.userInfo
        if (notificationUserInfo != nil){
            let macID = notificationUserInfo?["mac"] as! String
            if let indexPath = deviceTableIdentifications[macID]{
                let cell = tableView.cellForRow(at: indexPath) as! DeviceTableCell
                cell.powerSwitch.isEnabled = false
                cell.deviceIP?.text = ""
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "DeviceDetail"{
            let cell = sender as! DeviceTableCell
            if cell.powerSwitch.isEnabled{
                return true
            }
            else{
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DeviceDetail"{
            let pageViewController = segue.destination as! DevicePageViewController
            let cell = self.tableView.cellForRow(at: self.tableView.indexPathForSelectedRow!) as! DeviceTableCell
            pageViewController.service = cell.service
        }
    }
    
    deinit {
        networkSearch.stopNetworkSearch()
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Color Changed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Going Background"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("App Coming Foreground"), object: nil)
    }
    
    func applicationDidEnterBackground(){
        print("Devices Background")
        networkSearch.stopNetworkSearch()
    }
    
    func applicationWillEnterForeground(){
        print("Devices Foreground")
        networkSearch.startNetworkSearch()
    }

}
