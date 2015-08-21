//
//  RBLProtocol.swift
//  Doors
//
//  Created by Christian Kjær Laustsen on 20/08/15.
//  Copyright © 2015 codetalk. All rights reserved.
//

import Foundation


enum RBLPinState: UInt8 {
    case High = 0x01
    case Low = 0x00
}

struct RBLProtocol {
    // Message types
    let messageTypeCustomData: Character = "Z"
    let messageTypeProtocolVersion: Character = "V"
    let messageTypePinCount: Character = "C"
    let messageTypePinCapability: Character = "P"

    // Pin modes
    let unavailable = 0xFF
    let input = 0x00
    let output = 0x01
    let analog = 0x02
    let pwm = 0x03
    let servo = 0x04

    // Pin types (analog is already defined above)
    let digital = 0x01

    // Pin capabilities
    let pinCapabilityNone = 0x00
    let pinCapabilityDigital = 0x01
    let pinCapabilityAnalog = 0x02
    let pinCapabilityPWM = 0x04
    let pinCapabilityServo = 0x08
    let pinCapabilityI2C = 0x10

    // Pin errors
    let pinErrorInvalidPin = 0x01
    let pinErrorInvalidMode = 0x02

    func write(ble: BLE, control: UInt8, value: RBLPinState) {
        // Write bytes to the BLE device
        let data = NSData(bytes: [control, value.rawValue] as [UInt8], length: 3)
        print("[DEBUG] Sending raw data: \(data)")
        ble.write(data)
    }
}
