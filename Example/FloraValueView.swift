//
//  FloraValueView.swift
//  Example
//
//  Created by Jan Scheithauer on 12.10.19.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

import UIKit

public final class FloraValueView: UIView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private var valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    public var title: String = "" {
        didSet {
            self.titleLabel.text = title
        }
    }
    
    public var value: String = "" {
        didSet {
            self.valueLabel.text = value
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func setupView() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.valueLabel)

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.rightAnchor.constraint(equalTo: self.valueLabel.leftAnchor, constant: -10),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.valueLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.valueLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.valueLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
        ])
    }
}
