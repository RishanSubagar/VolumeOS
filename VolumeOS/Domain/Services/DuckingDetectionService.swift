//
//  DuckingDetectionService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation
import Combine

/// Protocol for detecting and preventing audio ducking
protocol DuckingDetectionService {
    /// Publisher that emits ducking state changes
    var duckingEvents: AnyPublisher<DuckingState, Never> { get }
    
    /// Get current ducking state
    func getCurrentDuckingState() async -> DuckingState
    
    /// Enable/disable ducking prevention
    func setDuckingPrevention(enabled: Bool) async throws
    
    /// Check if ducking prevention is enabled
    func isDuckingPreventionEnabled() async -> Bool
}
