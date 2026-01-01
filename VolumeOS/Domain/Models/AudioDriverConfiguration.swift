//
//  AudioDriverConfiguration.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation

/// Configuration for the audio driver
struct AudioDriverConfiguration {
    let deviceName: String
    let sampleRate: Double
    let channelCount: UInt32
    let bufferSize: UInt32
    let enableDuckingPrevention: Bool
    
    static let `default` = AudioDriverConfiguration(
        deviceName: "AudioMixer Virtual Device",
        sampleRate: 44100.0,
        channelCount: 2,
        bufferSize: 512,
        enableDuckingPrevention: true
    )
}
