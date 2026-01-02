//
//  AudioDriverService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation

/// Protocol for the main audio driver that coordinates all services
protocol AudioDriverService {
    /// Initialize the driver with configuration
    func initialize(configuration: AudioDriverConfiguration) async throws
    
    /// Start the audio driver
    func start() async throws
    
    /// Stop the audio driver
    func stop() async throws
    
    /// Check if driver is running
    func isRunning() async -> Bool
    
    /// Get the virtual device created by this driver
    func getVirtualDevice() async throws -> AudioDevice
}
