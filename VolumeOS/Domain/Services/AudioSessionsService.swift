//
//  AudioSessionsService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation
import Combine

/// Protocol for managing audio sessions and detecting active applications
protocol AudioSessionsService {
    /// Publisher that emits events when applications start/stop audio
    var applicationEvents: AnyPublisher<AudioMixerEvent, Never> { get }
    
    /// Get all currently active audio applications
    func getActiveApplication() async throws -> [AudioApplication]
    
    /// Get information about a specific application
    func getApplication(pid: pid_t) async throws -> AudioApplication
    
    /// Start monitoring for audio session changes
    func startMonintoring() async throws
    
    /// Stop monitoring
    func stopMonitoring()
}
