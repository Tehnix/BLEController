//
//  ScanTableViewController.swift
//  Doors
//
//  Created by Christian Kjær Laustsen on 20/08/15.
//  Copyright © 2015 codetalk. All rights reserved.
//

import UIKit
import CoreBluetooth


class ScanTableViewController: UITableViewController {
    
    var bleController: BLE?
    
    var devices: [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bleController = BLE()
        // Perform a scan a bit delayed form the load, since the Central Manager
        // isn't powered on yet.
        let seconds = 0.5
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            {
                self.scanForDevices()
            }
        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.scanForDevices()
    }
    
    func scanForDevices() {
        if let ble = self.bleController {
            ble.startScanning(3.0)
            self.devices = ble.peripherals
        }
        self.tableView.reloadData()
    }
    
    // Scan for BLE devices, and insert them into the table view
    @IBAction func scanForDevices(sender: AnyObject) {
        self.scanForDevices()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceListCell", forIndexPath: indexPath)
        let device = self.devices[indexPath.row]
        cell.textLabel!.text = device.name
        cell.detailTextLabel!.text = "UUID: " + device.identifier.UUIDString
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
        performSegueWithIdentifier("showDeviceDetails", sender: nil)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDeviceDetails" {
            let deviceViewController = segue.destinationViewController as! DeviceTableViewController
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            // Connect to the device
            let device = self.devices[indexPath.row]
            bleController!.connectToPeripheral(device)
            // Pass through the controller and device instances
            deviceViewController.bleController = self.bleController
            deviceViewController.bleDevice = device
        }
    }

}
