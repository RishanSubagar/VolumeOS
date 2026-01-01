//
//  AudioMixerError.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation

// Error Types
enum AudioMixerError: LocalizedError {
    case deviceNotFound
    case permissionDenied
    case driverInstallationFailed
    case audioUnitCreationFailed
    case invalidConfiguration
    case applicationNotFound(pid_t)
    case volumeControlFailed
    
    var errorDescription: String? {
        switch self {
        case .deviceNotFound:
            return "Audio device not found"
        case .permissionDenied:
            return "Permission Denied. Please grant audio access in System Settings."
        case .driverInstallationFailed:
            return "Failed to install audio driver"
        case .audioUnitCreationFailed:
            return "Failed to create audio unit"
        case .invalidConfiguration:
            return "Invalid audio configuration"
        case .applicationNotFound(let pid):
            return "Application with PID \(pid) not found"
        case .volumeControlFailed:
            return "Failed to control volume"
        }
    }
}
