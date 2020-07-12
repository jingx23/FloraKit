//
//  FloraObserver.swift
//  Example
//
//  Created by Jan Scheithauer on 10.07.20.
//  Copyright © 2020 Jan Scheithauer. All rights reserved.
//

import Combine
import FloraKit

class FloraObserver: ObservableObject {
    private let floraKit: FloraKit = FloraKit()
    private var numberOfDevices = 0
    
    @Published var loading: Bool = false
    
    @Published private(set) var floraViewDataset: [FloraViewData] = [] {
        didSet {
            didChange.send(self)
        }
    }
    
    var didChange = PassthroughSubject<FloraObserver, Never>()

    init() {
        floraKit.delegate = self
        self.loading = true
        floraKit.scan { uuids in
            self.floraKit.read(uuids: uuids)
            self.numberOfDevices = uuids.count
        }
    }

}

extension FloraObserver: FloraKitDelegate {
    func floraKit(_ floraKit: FloraKit, stateChanged state: FloraServiceState) {
        switch state {
        case .deviceConnected(let name, let uuid):
            print("Connected to \(name ?? "") \(uuid.uuidString)")
        case .recievedSensorData(let sensorData):
            DispatchQueue.main.async {
                let floraViewData = FloraViewData(sensorName: sensorData.sensorName, temp: sensorData.temp, lux: sensorData.lux, moisture: sensorData.moisture, conductivity: sensorData.conductivity, battery: sensorData.battery)
                self.floraViewDataset.append(floraViewData)
                if self.floraViewDataset.count == self.numberOfDevices {
                    self.loading = false
                }
            }
        }
    }
}
