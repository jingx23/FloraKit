//
// Created by Jan Scheithauer on 2019-06-10.
// Copyright (c) 2019 Jan Scheithauer. All rights reserved.
//

import Foundation
import CoreBluetooth

class FloraService: NSObject {

    private static let miFloraPrefix = "FE95"
    private var discoveredSensors: [CBPeripheral] = []
    private lazy var manager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)

    private let serviceUUID = CBUUID(string: "00001204-0000-1000-8000-00805F9B34FB")
    private let writeModeUUID = CBUUID(string: "00001A00-0000-1000-8000-00805F9B34FB")
    private let sensorDataUUID = CBUUID(string: "00001A01-0000-1000-8000-00805F9B34FB")
    private let batteryUUID = CBUUID(string: "00001A02-0000-1000-8000-00805F9B34FB")

    func scan(duration: Int, completion: @escaping (_ floraDevices: [CBPeripheral]) -> Void) {
        _ = manager
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) { [weak self] in
            guard let self = self else { return }
            self.manager.stopScan()
            completion(self.discoveredSensors)
        }
    }

    func discoverPeripherals() {
        manager.scanForPeripherals(withServices: [CBUUID(string: FloraService.miFloraPrefix)], options: nil)
    }

    func read(peripheral: CBPeripheral) {
        manager.connect(peripheral)
        /*_ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] timer in
            self?.manager.connect(peripheral)
        }*/
    }
}

extension FloraService: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.discoverPeripherals()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !discoveredSensors.contains(peripheral) {
            discoveredSensors.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅", "Connected to:", "\(peripheral.name ?? "")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension FloraService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        //print(peripheral.services?.map({ ($0, $0.uuid.uuidString) }))
        guard let writeService = peripheral.services?.filter({ $0.uuid == serviceUUID }).first else {
            return
        }
        peripheral.discoverCharacteristics(nil, for: writeService)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let writeModeCharacteristic = service.characteristics?.filter({ $0.uuid == writeModeUUID }).first else {
            return
        }
        let writeModeMagicBytes: [UInt8] = [0xA0, 0x1F]
        peripheral.writeValue(Data(writeModeMagicBytes), for: writeModeCharacteristic, type: .withResponse)
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let dataAndBatteryCharacteristics = characteristic.service.characteristics?.filter( {$0.uuid == sensorDataUUID || $0.uuid == batteryUUID}) else {
            return
        }
        let dataCharacteristic = dataAndBatteryCharacteristics[0]
        let batteryCharacteristic = dataAndBatteryCharacteristics[1]
        peripheral.readValue(for: dataCharacteristic)
        peripheral.readValue(for: batteryCharacteristic)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let value = characteristic.value else {
            return
        }
        if value[0] == 0xAA && value[1] == 0xbb {
            assertionFailure("Did magical data write happend before?")
            return
        }

        if characteristic.uuid == sensorDataUUID {
            let rawTemp0 =  Float(UInt16(value[0])) / 10.0
            let lux =  Int((value[3] + value[4]))
            let moisture = Int(value[7])
            let conductivity = Int((value[8] + value[9]))
            print("temp: \(rawTemp0),\nlux: \(lux),\nmoisture: \(moisture),\nconductivity: \(conductivity)")
        } else if characteristic.uuid == batteryUUID {
            print("battery: \(Int(value[0]))")
            manager.cancelPeripheralConnection(peripheral)
        }
    }
}
