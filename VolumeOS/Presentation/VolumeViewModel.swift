//
//  VolumeViewModel.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-05.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class VolumeViewModel: ObservableObject {
    @Published var applications: [AudioApplication] = []
    @Published var isLoading = false
    @Published var error: Error?

    private let sessionService: AudioSessionService
    private let volumeService: VolumeControlService
    private let deviceService: AudioDeviceService
    private var cancellables = Set<AnyCancellable>()

    init(
        sessionService: AudioSessionService,
        volumeService: VolumeControlService,
        deviceService: AudioDeviceService
    ) {
        self.sessionService = sessionService
        self.volumeService = volumeService
        self.deviceService = deviceService

        setupSubscriptions()
        refreshApplications()
    }

    func refreshApplications() {
        isLoading = true
        Task {
            do {
                let apps = try await sessionService.getActiveApplications()
                var updatedApps: [AudioApplication] = []
                for var app in apps {
                    app.volume = try await volumeService.getVolume(for: app.id)
                    app.isMuted = try await volumeService.getMuted(for: app.id)
                    updatedApps.append(app)
                }
                self.applications = updatedApps
                self.isLoading = false
            } catch {
                self.error = error
                self.isLoading = false
            }
        }
    }

    func updateVolume(for app: AudioApplication, to value: Float) {
        let volume = VolumeLevel(value)
        Task {
            do {
                try await volumeService.setVolume(volume, for: app.id)
                if let index = applications.firstIndex(where: { $0.id == app.id }) {
                    applications[index].volume = volume
                }
            } catch {
                self.error = error
            }
        }
    }

    func toggleMute(for app: AudioApplication) {
        Task {
            do {
                let newMuted = !app.isMuted
                try await volumeService.setMuted(newMuted, for: app.id)
                if let index = applications.firstIndex(where: { $0.id == app.id }) {
                    applications[index].isMuted = newMuted
                }
            } catch {
                self.error = error
            }
        }
    }

    private func setupSubscriptions() {
        sessionService.applicationEvents
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleEvent(event)
            }
            .store(in: &cancellables)
    }

    private func handleEvent(_ event: AudioMixerEvent) {
        switch event {
        case .applicationStartedAudio(let app):
            if !applications.contains(where: { $0.id == app.id }) {
                applications.append(app)
            }
        case .applicationStoppedAudio(let pid):
            applications.removeAll(where: { $0.id == pid })
        case .volumeChanged(let pid, let volume):
            if let index = applications.firstIndex(where: { $0.id == pid }) {
                applications[index].volume = volume
            }
        case .muteStateChanged(let pid, let isMuted):
            if let index = applications.firstIndex(where: { $0.id == pid }) {
                applications[index].isMuted = isMuted
            }
        default:
            break
        }
    }
}
