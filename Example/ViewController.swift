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
    private let floraKit = FloraKit()
    
    private var modelData: [FloraSensorData] = []
    private var numberOfDevices = 0
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.dataSource = self
        tableView.register(FloraTableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        indicatorView.style = .large
        indicatorView.center = self.view.center
        return indicatorView
    }()
    
    // MARK: View-Lifecycle
    
    /// View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.floraKit.delegate = self
        self.floraKit.scan { (uuids) in
            self.numberOfDevices = uuids.count
            self.floraKit.read(uuids: uuids)
        }        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.activityIndicator)
        
        self.activityIndicator.startAnimating()
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.activityIndicator.center = self.view.center
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FloraTableViewCell else {
            assertionFailure("Wrong cell type")
            return UITableViewCell()
        }
        cell.configure(withFloraSensorData: modelData[indexPath.row])

        return cell
    }
    
}

extension ViewController: FloraKitDelegate {
    func floraKit(_ floraKit: FloraKit, stateChanged state: FloraServiceState) {
        switch state {
        case .deviceConnected(let name, let uuid):
            print("Connected to \(name ?? "") \(uuid.uuidString)")
        case .recievedSensorData(let sensorData):
            DispatchQueue.main.async {
                self.modelData.append(sensorData)
                self.tableView.reloadData()
                if self.modelData.count == self.numberOfDevices {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}
