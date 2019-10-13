//
//  FloraView.swift
//  Example
//
//  Created by Jan Scheithauer on 10.10.19.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

import UIKit
import FloraKit

public final class FloraTableViewCell: UITableViewCell {
    
    private lazy var innerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        return stackView
    }()
    
    private lazy var sensorLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Sensor-ID:"
        return floraLabelView
    }()
    
    private lazy var sensorNameLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Sensor-Name:"
        return floraLabelView
    }()
    
    private lazy var temperatureLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Temperature:"
        floraLabelView.value = "TemperatureX:"
        return floraLabelView
    }()

    private lazy var luxLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Lux:"
        return floraLabelView
    }()

    private lazy var moistureLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Moisture:"
        return floraLabelView
    }()

    private lazy var conductivityLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Conductivity:"
        return floraLabelView
    }()

    private lazy var batteryLabelView: FloraValueView = {
        let floraLabelView = FloraValueView()
        floraLabelView.title = "Battery:"
        return floraLabelView
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func setupView() {
        self.contentView.addSubview(innerStackView)
        
        self.innerStackView.addArrangedSubview(self.sensorLabelView)
        self.innerStackView.addArrangedSubview(self.sensorNameLabelView)
        self.innerStackView.addArrangedSubview(self.temperatureLabelView)
        self.innerStackView.addArrangedSubview(self.luxLabelView)
        self.innerStackView.addArrangedSubview(self.moistureLabelView)
        self.innerStackView.addArrangedSubview(self.conductivityLabelView)
        self.innerStackView.addArrangedSubview(self.batteryLabelView)

        self.innerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.innerStackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.innerStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.innerStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.innerStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10)
        ])
    }
    
    public func configure(withFloraSensorData data: FloraSensorData) {
        self.sensorLabelView.value = data.sensorId.uuidString
        self.sensorNameLabelView.value = data.sensorName ?? ""
        self.temperatureLabelView.value = "\(data.temp)"
        self.luxLabelView.value = "\(data.lux)"
        self.moistureLabelView.value = "\(data.moisture)"
        self.conductivityLabelView.value = "\(data.conductivity)"
        self.batteryLabelView.value = "\(data.battery)"
    }
}
