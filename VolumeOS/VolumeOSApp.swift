//
//  VolumeOSApp.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import SwiftUI

@main
struct VolumeOSApp: App {
    private let viewModel: VolumeViewModel
    private let coordinator: AudioDriverCoordinator

    init() {
        // Initialize Services
        let sessionService = CoreAudioSessionManager()
        let deviceService = CoreAudioDeviceService()
        let volumeService = DefaultVolumeControlService(deviceService: deviceService)
        let duckingService = DefaultDuckingDetectionService()
        let processingService = DefaultAudioProcessingService()

        // Initialize Coordinator
        self.coordinator = AudioDriverCoordinator(
            sessionService: sessionService,
            volumeService: volumeService,
            deviceService: deviceService,
            duckingService: duckingService,
            processingService: processingService
        )

        // Initialize View Model
        self.viewModel = VolumeViewModel(
            sessionService: sessionService,
            volumeService: volumeService,
            deviceService: deviceService
        )

        // Start the audio driver system
        Task {
            do {
                try await coordinator.initialize(configuration: .default)
                try await coordinator.start()
            } catch {
                print("Note: Audio Driver Coordinator start failed (likely due to missing virtual driver): \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
