//
//  DeviceTableViewController.swift
//  Doors
//
//  Created by Christian Kjær Laustsen on 20/08/15.
//  Copyright © 2015 codetalk. All rights reserved.
//
import UIKit
import CoreBluetooth


class DeviceTableViewController: UITableViewController {
    
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceUUIDLabel: UILabel!
    @IBOutlet weak var deviceRSSILabel: UILabel!
    @IBOutlet weak var doorButton: UIButton!
    
    let rblProtocol = RBLProtocol()
    
    var ble: BLE?
    
    var bleDevice: CBPeripheral?
    
    var rssi: NSNumber?
    
    var doorOpen: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Insert the device information into the view
        if let device = self.bleDevice {
            self.deviceNameLabel.text = "Name: \(device.name!)"
            self.deviceUUIDLabel.text = "UUID: \(device.identifier.UUIDString)"
            self.deviceRSSILabel.text = "RSSI: N/A"
            device.readRSSI()
            if let rssi = self.rssi {
                self.deviceRSSILabel.text = "RSSI: \(rssi.stringValue)"
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Disconnect from the device when the back button is pressed/the view dissapears
        super.viewWillDisappear(animated)
        if let device = self.bleDevice {
            self.ble!.disconnectFromPeripheral(device)
        }
    }
    
    @IBAction func openDoor(sender: AnyObject) {
        // The control code 0x01 indicates a specific pin on the Arduino board
        if self.doorOpen {
            print("[DEBUG] Close the door!")
            if let ble = self.ble {
                self.rblProtocol.write(ble, control: 0x01, value: .Low)
                self.doorButton.setTitle("Open Door", forState: .Normal)
                self.doorOpen = false
            }
        } else {
            print("[DEBUG] Open the door!")
            if let ble = self.ble {
                self.rblProtocol.write(ble, control: 0x01, value: .High)
                self.doorButton.setTitle("Close Door", forState: .Normal)
                self.doorOpen = true
            }
        }
    }
    
    @IBAction func resetControls(sender: AnyObject) {
        // Send a reset controls command
        if let ble = self.ble {
            self.rblProtocol.write(ble, control: 0x04, value: .Low)
            self.doorButton.setTitle("Open Door", forState: .Normal)
            self.doorOpen = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // This is static and is viewed from the IB view of the table
        return 3
    }

}
