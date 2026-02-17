//
//  DefaultDuckingDetectionService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-05.
//

import Foundation
import Combine

final class DefaultDuckingDetectionService: DuckingDetectionService {
    private let duckingSubject = CurrentValueSubject<DuckingState, Never>(.inactive)
    private var isEnabled = false

    var duckingEvents: AnyPublisher<DuckingState, Never> {
        duckingSubject.eraseToAnyPublisher()
    }

    func getCurrentDuckingState() async -> DuckingState {
        duckingSubject.value
    }

    func setDuckingPrevention(enabled: Bool) async throws {
        isEnabled = enabled
    }

    func isDuckingPreventionEnabled() async -> Bool {
        isEnabled
    }
}
