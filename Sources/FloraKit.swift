//
//  FloraKit.swift
//  FloraKit
//
//  Created by Jan Scheithauer on 10 Jun 2019.
//  Copyright © 2019 Jan Scheithauer. All rights reserved.
//

// Include Foundation
@_exported import Foundation

public class FloraKit: NSObject {
    private let scanner = FloraScanner()

    public func start() {
        scanner.startScanning(duration: 10)
    }
}
