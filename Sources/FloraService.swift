//
// Created by Jan Scheithauer on 2019-06-10.
// Copyright (c) 2019 Jan Scheithauer. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol FloraServiceDelegate {
    func floraService(_ service: FloraService, didRecieveSensorData sensorData: FloraService.SensorData)
}

class FloraService: NSObject {
    
    public class SensorData: CustomDebugStringConvertible {
        let sensorId: UUID
        fileprivate(set) var temp: Float
        fileprivate(set) var lux: Int
        fileprivate(set) var moisture: Int
        fileprivate(set) var conductivity: Int
        fileprivate(set) var battery: Int

        var debugDescription: String {
            return "sensorId: \(sensorId.uuidString),\ntemp: \(temp),\nlux: \(lux),\nmoisture: \(moisture),\nconductivity: \(conductivity),\nbattery: \(battery)"
        }
        
        init(sensorId: UUID) {
            self.sensorId = sensorId
            self.temp = 0
            self.lux = 0
            self.moisture = 0
            self.conductivity = 0
            self.battery = 0
        }

    }

    private static let miFloraPrefix = "FE95"
    private var discoveredSensors: [CBPeripheral] = []
    private var discoveredSensorData: [UUID: SensorData] = [:]
    open var delegate: FloraServiceDelegate?
    private lazy var manager = CBCentralManager(delegate: self, queue: DispatchQueue.main, options: nil)

    private let serviceUUID = CBUUID(string: "00001204-0000-1000-8000-00805F9B34FB")
    private let writeModeUUID = CBUUID(string: "00001A00-0000-1000-8000-00805F9B34FB")
    private let sensorDataUUID = CBUUID(string: "00001A01-0000-1000-8000-00805F9B34FB")
    private let batteryUUID = CBUUID(string: "00001A02-0000-1000-8000-00805F9B34FB")
    
    public convenience init(delegate: FloraServiceDelegate?) {
        self.init()
        self.delegate = delegate
    }

    func scan(duration: Int, completion: @escaping (_ floraDevices: [CBPeripheral]) -> Void) {
        _ = manager
        self.discoveredSensors = []
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(duration)) { [weak self] in
            guard let self = self else { return }
            self.manager.stopScan()
            completion(self.discoveredSensors)
        }
    }

    private func discoverPeripherals() {
        manager.scanForPeripherals(withServices: [CBUUID(string: FloraService.miFloraPrefix)], options: nil)
    }

    func read(peripheral: CBPeripheral) {
        manager.connect(peripheral)
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
        print("✅", "Connected to:", "\(peripheral.name ?? ""), \(peripheral.identifier.uuidString)")
        discoveredSensorData[peripheral.identifier] = SensorData(sensorId: peripheral.identifier)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
}

extension FloraService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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
        guard let dataAndBatteryCharacteristics = characteristic.service.characteristics?.filter({ $0.uuid == sensorDataUUID || $0.uuid == batteryUUID }) else {
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
    
        guard let sensorData = discoveredSensorData[peripheral.identifier] else {
            assertionFailure("No SensorData in didUpdateValueFor!")
            return
        }
        
        if characteristic.uuid == sensorDataUUID {
            let rawTemp0 = Float(UInt16(value[0])) / 10.0
            let lux = Int((value[3] + value[4]))
            let moisture = Int(value[7])
            let conductivity = Int((value[8] + value[9]))
            
            sensorData.temp = rawTemp0
            sensorData.lux = lux
            sensorData.moisture = moisture
            sensorData.conductivity = conductivity
        } else if characteristic.uuid == batteryUUID {
            sensorData.battery = Int(value[0])
            manager.cancelPeripheralConnection(peripheral)
        }
        //TODO: manager.cancelPeripheralConnection(peripheral) only when all characteristics were seen, e.g. if we change order of peripheral.readValue(for: ...) then cancel gets called to early
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard let sensorData = discoveredSensorData[peripheral.identifier] else {
            assertionFailure("SensorData was removed before!")
            return
        }
        discoveredSensorData[peripheral.identifier] = nil
        delegate?.floraService(self, didRecieveSensorData: sensorData)
    }
}