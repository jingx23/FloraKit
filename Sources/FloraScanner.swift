//
// Created by Jan Scheithauer on 2019-06-10.
// Copyright (c) 2019 Jan Scheithauer. All rights reserved.
//

import Foundation
import CoreBluetooth

class FloraScanner: NSObject {
    private var discoveredSensors: [CBPeripheral] = []
    private lazy var manager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)

    func startScanning(duration: Int) {
        _ = manager
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) {
            print("timer fired")
            self.manager.stopScan()
        }
    }

    func discoverPeripherals() {
        manager.scanForPeripherals(withServices: nil, options: nil)
    }
}

extension FloraScanner: CBCentralManagerDelegate {

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.discoverPeripherals()
        }
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let miFloraPrefix = "FE95"
        if let advertisementData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data], advertisementData[CBUUID(string: miFloraPrefix)] != nil {
            print("🌎 UUID: \(peripheral.identifier.uuidString)")
            if !discoveredSensors.contains(peripheral) {
                discoveredSensors.append(peripheral)
            }
            print("discoveredSensorsCount: \(discoveredSensors.count)")
            //let valData: [UInt8] = [0xA0, 0x1F]
        }

    }
}
