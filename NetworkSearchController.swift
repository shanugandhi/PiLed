//
//  NetworkSearchController.swift
//  PiLed
//
//  Created by Tejaswi Rohit Anupindi on 10/30/16.
//  Copyright © 2016 Tejaswi Rohit Anupindi. All rights reserved.
//

import UIKit

class NetworkSearchController: UITableViewController{
    
    var networkSearch: NetworkSearch!
    
    @IBOutlet var deviceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.networkSearch = NetworkSearch()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableData), name: Notification.Name("Device List Updated:Added"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableData), name: Notification.Name("Device List Updated:Removed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableData), name: Notification.Name("Device List Updated:Refresh"), object: nil)
        
        self.networkSearch.startNetworkSearch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.networkSearch != nil{
            print("Network Search Controller")
            self.networkSearch.stopNetworkSearch()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Device List Updated:Added"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Device List Updated:Removed"), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Device List Updated:Refresh"), object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.networkSearch != nil{
            return self.networkSearch.devices.count
        }
        else{
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deviceCell", for: indexPath)
        
        cell.textLabel?.text = self.networkSearch.devices[indexPath.row].name
        
//         Get IP Address
         let theAddress = self.networkSearch.devices[indexPath.row].addresses!.first! as NSData
         var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
         if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t((theAddress.length)),
         &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
         let numAddress = String(cString: hostname)
         cell.detailTextLabel?.text = numAddress
         }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        let alertView = UIAlertController(title: "Add this device?", message: "\(selectedCell!.textLabel!.text!) will be added to your list of devices.", preferredStyle: UIAlertControllerStyle.alert)
        alertView.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        alertView.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { _ in
            Devices.add(service: self.networkSearch.devices[indexPath.row])
//            self.navigationController?.dismiss(animated: true, completion: nil)
            self.dismissSearch("dismiss")
        }))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func updateTableData(){
        self.deviceTableView.reloadData()
    }

    @IBAction func refreshScan(_ sender: UIRefreshControl) {
        self.networkSearch.refreshNetworkSearch()
        sender.endRefreshing()
    }

    
    @IBAction func dismissSearch(_ sender: Any) {
        self.networkSearch.stopNetworkSearch()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
}
