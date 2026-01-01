//
//  DuckingState.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation

/// Represents the state of audio ducking
struct DuckingState: Equatable {
    let isActive: Bool
    let duckingApplication: AudioApplication?
    let affectedApplication: Set<pid_t>
    let duckingLevel: VolumeLevel
    let timestamp: Date
    
    static let inactive = DuckingState (
        isActive: false,
        duckingApplication: nil,
        affectedApplication: [],
        duckingLevel: VolumeLevel(1.0),
        timestamp: Date()
    )
}
