//
//  VolumeLevel.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation

/// Value object representing volume level with validation
struct VolumeLevel: Equatable, Codable {
    private let value: Float
    
    static let minVal: Float = 0.0
    static let maxVal: Float = 1.0
    static let `default` = VolumeLevel(0.8)
    
    init(_ value: Float) {
        self.value = min(max(value, VolumeLevel.minVal), VolumeLevel.maxVal)
    }
    
    var normalized: Float { value }
    var percentage: Int { Int(value * 100) }
    var decibels: Float {
        value > 0 ? 20 * log10(value) : -96.0
    }
    
    func adjusted(by delta: Float) -> VolumeLevel {
        VolumeLevel(value + delta)
    }
}
