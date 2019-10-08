//
//  ViewController.swift
//  Example
//
//  Created by Jan Scheithauer on 10 Jun 2019.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

import UIKit
import FloraKit

// MARK: - ViewController

/// The ViewController
class ViewController: UIViewController {

    // MARK: Properties
    let floraKit = FloraKit()
    
    /// The Label
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = "🚀\nFloraKit\nExample"
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.floraKit.delegate = self
        self.view.backgroundColor = .white
        self.floraKit.readAll()
    }
    
    /// LoadView
    override func loadView() {
        self.view = self.label
    }

}

extension ViewController: FloraKitDelegate {
    func floraKit(_ floraKit: FloraKit, stateChanged state: FloraServiceState) {
        switch state {
        case .beginScan:
            print("Begin Scan")
        case .endScan:
            print("Scan complete")
        case .deviceConnected(let name, let uuid):
            print("Connected to \(name ?? "") \(uuid.uuidString)")
        case .recievedSensorData(let sensorData):
            print(sensorData.debugDescription)
            print("Sensor data recieved!")
        }
    }
}
