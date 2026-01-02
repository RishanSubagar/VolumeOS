//
//  VolumeControlService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation

/// Protocol for controlling per-application volume
protocol VolumeControlService {
    /// Set volume for a specific application
    func setVolume(_ volume: VolumeLevel, for pid: pid_t) async throws
    
    /// Get current volume for an application
    func getVolume(for pid: pid_t) async throws -> VolumeLevel
    
    /// Mute/unmute an application
    func setMuted(_ muted: Bool, for pid: pid_t) async throws
    
    /// Get mute state for an application
    func getMuted(for pid: pid_t) async throws -> Bool
}
