//
//  ConfigurationRepository.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation

/// Protocol for managing driver configuration
protocol ConfigurationRepository {
    /// Save configuration
    func saveConfiguration(_ configuration: AudioDriverConfiguration) async throws
    
    /// Load configuration
    func loadConfiguration() async throws -> AudioDriverConfiguration
}
