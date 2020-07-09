//
// Created by Jan Scheithauer on 2019-06-10.
// Copyright (c) 2019 Jan Scheithauer. All rights reserved.
//

import Foundation
import CoreBluetooth

public enum FloraServiceState {
    case deviceConnected(name: String?, uuid: UUID)
    case recievedSensorData(data: FloraSensorData)
}

protocol FloraServiceDelegate: class {
    func floraService(_ service: FloraService, stateChanged state: FloraServiceState)
}

public class FloraSensorData: CustomDebugStringConvertible {
    public fileprivate(set) var sensorId: UUID
    public fileprivate(set) var sensorName: String?
    public fileprivate(set) var temp: Float
    public fileprivate(set) var lux: Int
    public fileprivate(set) var moisture: Int
    public fileprivate(set) var conductivity: Int
    public fileprivate(set) var battery: Int

    public var debugDescription: String {
        return "sensorId: \(sensorId.uuidString),\ntemp: \(temp),\nlux: \(lux),\nmoisture: \(moisture),\nconductivity: \(conductivity),\nbattery: \(battery)"
    }
    
    init(sensorId: UUID, sensorName: String?) {
        self.sensorId = sensorId
        self.sensorName = sensorName
        self.temp = 0
        self.lux = 0
        self.moisture = 0
        self.conductivity = 0
        self.battery = 0
    }

}

class FloraService: NSObject {
    
    private static let miFloraPrefix: String = "FE95"
    public static let defaultScanDuration: Int = 10
    public static let defaultReadTimeout: Int = 10
    
    private var discoveredSensors: [CBPeripheral] = []
    private var discoveredSensorData: [UUID: FloraSensorData] = [:]
    open weak var delegate: FloraServiceDelegate?
    // swiftlint:disable implicitly_unwrapped_optional
    private var manager: CBCentralManager!
    // swiftlint:enable implicitly_unwrapped_optional
    private var sensorsToDiscover: [CBUUID] = []

    private let serviceUUID = CBUUID(string: "00001204-0000-1000-8000-00805F9B34FB")
    private let writeModeUUID = CBUUID(string: "00001A00-0000-1000-8000-00805F9B34FB")
    private let sensorDataUUID = CBUUID(string: "00001A01-0000-1000-8000-00805F9B34FB")
    private let batteryUUID = CBUUID(string: "00001A02-0000-1000-8000-00805F9B34FB")
    private let writeModeMagicBytes: [UInt8] = [0xA0, 0x1F]

    ///
    /// Initializer
    /// - Parameter delegate: `FloraServiceDelegate`.
    public init(delegate: FloraServiceDelegate? = nil) {
        super.init()
        self.delegate = delegate
        self.manager = CBCentralManager(delegate: self, queue: DispatchQueue(label: "florakit.floraService.bluetooth"), options: nil)
    }
    
    ///
    /// Scan for flora devices
    /// - Parameters:
    ///   - duration: Scanning duration in seconds (if not applied `FloraService.defaultScanDuration` is used).
    ///   - completion: Flora device UUID´s.
    func scan(withDuration duration: Int = FloraService.defaultScanDuration, completion: @escaping (_ floraDevices: [UUID]) -> Void) {
        self.scan(withDuration: duration) { (peripherals: [CBPeripheral]) in
            completion(peripherals.compactMap( { $0.identifier } ))
        }
    }

    ///
    /// Start reading from flora devices
    /// - Parameters:
    ///   - timeout: Reading timeout in seconds (if not applied `FloraService.defaultReadTimeout` is used).
    ///   - uuids: The UUID´s for flora devices to read from.
    func read(withTimeout timeout: Int = FloraService.defaultReadTimeout, uuids: [UUID]) {
        self.discoveredSensors = []
        var runCount = 0
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] timer in
            guard let self = self else {
                return
            }
            self.discoveredSensors = self.manager.retrievePeripherals(withIdentifiers: uuids)
            runCount += 1
            
            if runCount == timeout || (self.discoveredSensors.count == uuids.count) {
                timer.invalidate()
                for sensor in self.discoveredSensors {
                    self.manager.connect(sensor)
                }
            }
        }
    }
    
    private func scan(withDuration duration: Int, completion: @escaping (_ floraDevices: [CBPeripheral]) -> Void) {
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
}

extension FloraService: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            self.discoverPeripherals()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !self.discoveredSensors.contains(peripheral) {
            self.discoveredSensors.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.delegate?.floraService(self, stateChanged: .deviceConnected(name: peripheral.name, uuid: peripheral.identifier))
        discoveredSensorData[peripheral.identifier] = FloraSensorData(sensorId: peripheral.identifier, sensorName: peripheral.name)
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
        peripheral.writeValue(Data(self.writeModeMagicBytes), for: writeModeCharacteristic, type: .withResponse)
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
        delegate?.floraService(self, stateChanged: .recievedSensorData(data: sensorData))
    }
}
