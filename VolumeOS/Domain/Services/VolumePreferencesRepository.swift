//
//  VolumePreferencesRepository.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation

/// Protocol for persisting application volume preferences
protocol VolumePreferencesRepository {
    /// Save volume preference for an application
    func saveVolumePreference(bundleId: String, volume: VolumeLevel) async throws
    
    /// Load volume preference for an application
    func loadVolumePreference(bundleId: String) async throws -> VolumeLevel?
    
    /// Delete volume preference for an application
    func deleteVolumePreference(bundleId: String) async throws
    
    /// Get all saved preferences
    func getAllPreferences() async throws -> [String: VolumeLevel]
}
