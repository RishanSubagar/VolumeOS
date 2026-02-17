//
//  UserDefaultsVolumePreferencesRepository.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-05.
//

import Foundation

final class UserDefaultsVolumePreferencesRepository: VolumePreferencesRepository {
    private let key = "com.volumeos.volume_preferences"

    func saveVolumePreference(bundleId: String, volume: VolumeLevel) async throws {
        var prefs = try await getAllPreferences()
        prefs[bundleId] = volume
        let data = try JSONEncoder().encode(prefs)
        UserDefaults.standard.set(data, forKey: key)
    }

    func loadVolumePreference(bundleId: String) async throws -> VolumeLevel? {
        let prefs = try await getAllPreferences()
        return prefs[bundleId]
    }

    func deleteVolumePreference(bundleId: String) async throws {
        var prefs = try await getAllPreferences()
        prefs.removeValue(forKey: bundleId)
        let data = try JSONEncoder().encode(prefs)
        UserDefaults.standard.set(data, forKey: key)
    }

    func getAllPreferences() async throws -> [String: VolumeLevel] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let prefs = try? JSONDecoder().decode([String: VolumeLevel].self, from: data) else {
            return [:]
        }
        return prefs
    }
}
