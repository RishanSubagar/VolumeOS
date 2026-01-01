//
//  AudioDevice.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation
import CoreAudio

/// Represents a Core Audio device
struct AudioDevice: Identifiable, Equatable {
    let id: AudioObjectID
    let name: String
    let manufacturer: String
    let isInput: Bool
    let isOutput: Bool
    let sampleRate: Double
    let channelCount: UInt32
    
    var isVirtual: Bool {
        // Virtual devices typically have specific manufacturers
        manufacturer.contains("Virtual") || manufacturer.contains("Aggregate")
    }
}
