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
    
    var ble: BLE = BLE()
    
    var devices: [CBPeripheral] = []
    
    var keepScanningForDevices: Bool = true
    
    var scanningTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        // When the view is shown, start scanning repeatedly
        self.keepScanningForDevices = true
        if self.scanningTimer == nil  {
            print("[DEBUG] Starting main scanning timer")
            self.scanningTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("scanForDevices"), userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // When the view dissapears, make sure we stop scanning
        print("[DEBUG] Stopping main scanning timer")
        self.scanningTimer?.invalidate()
        self.scanningTimer = nil
        self.keepScanningForDevices = false
    }
    
    func scanForDevices() {
        // Start the scanner, and update the table with the list of peripherals
        if self.keepScanningForDevices {
            print("[DEBUG] Scanning for devices and updating table")
            self.ble.startScanning(3.0)
            self.devices = self.ble.peripherals
            self.tableView.reloadData()
        }
    }
    
    @IBAction func forceScanForDevices(sender: AnyObject) {
        // For a scan for the devices
        self.scanForDevices()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows correspond to the number of devices found
        return self.devices.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Get the cell at the index
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceListCell", forIndexPath: indexPath)
        // Get the device at the same index as the cell
        let device = self.devices[indexPath.row]
        let rssi = self.ble.peripheralRSSI[device]!
        // Update the cell labels with the device information
        cell.textLabel!.text = device.name
        cell.detailTextLabel!.text = "RSSI: \(rssi)"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // When a cell is pushed, start the seque into the detail view
        performSegueWithIdentifier("showDeviceDetails", sender: nil)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDeviceDetails" {
            // Get the view controller for the detail view
            let deviceViewController = segue.destinationViewController as! DeviceTableViewController
            // Get the index of the cell that was pushed
            let indexPath: NSIndexPath = self.tableView.indexPathForSelectedRow!
            // Connect to the device
            let device = self.devices[indexPath.row]
            self.ble.connectToPeripheral(device)
            // Pass through the controller and device instances
            deviceViewController.ble = self.ble
            deviceViewController.bleDevice = device
            deviceViewController.rssi = self.ble.peripheralRSSI[device]
        }
    }

}
