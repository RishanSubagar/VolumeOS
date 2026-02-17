//
//  UserDefaultsConfigurationRepository.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-05.
//

import Foundation

final class UserDefaultsConfigurationRepository: ConfigurationRepository {
    private let key = "com.volumeos.configuration"

    func saveConfiguration(_ configuration: AudioDriverConfiguration) async throws {
        let data = try JSONEncoder().encode(configuration)
        UserDefaults.standard.set(data, forKey: key)
    }

    func loadConfiguration() async throws -> AudioDriverConfiguration {
        guard let data = UserDefaults.standard.data(forKey: key),
              let config = try? JSONDecoder().decode(AudioDriverConfiguration.self, from: data) else {
            return .default
        }
        return config
    }
}
