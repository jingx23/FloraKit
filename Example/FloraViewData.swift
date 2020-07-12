//
//  FloraViewData.swift
//  Example
//
//  Created by Jan Scheithauer on 12.07.20.
//  Copyright © 2020 Jan Scheithauer. All rights reserved.
//

import Foundation

struct FloraViewData: Identifiable, Hashable {
    public let id: UUID = UUID()
    private(set) var sensorName: String?
    private(set) var temp: Float
    private(set) var lux: Int
    private(set) var moisture: Int
    private(set) var conductivity: Int
    private(set) var battery: Int

    init(sensorName: String?, temp: Float, lux: Int, moisture: Int, conductivity: Int, battery: Int) {
        self.sensorName = sensorName
        self.temp = temp
        self.lux = lux
        self.moisture = moisture
        self.conductivity = conductivity
        self.battery = battery
    }

}
