//
//  AudioDriverCoordinator.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-04.
//

import Foundation

/// Main coordinator for the audio driver system
final class AudioDriverCoordinator: AudioDriverService {
    private let sessionService: AudioSessionService
    private let volumeService: VolumeControlService
    private let deviceService: AudioDeviceService
    private let duckingService: DuckingDetectionService
    private let processingService: AudioProcessingService
    
    private var configuration: AudioDriverConfiguration?
    private var virtualDevice: AudioDevice?
    private var isActive = false
    
    init(
        sessionService: AudioSessionService,
        volumeService: VolumeControlService,
        deviceService: AudioDeviceService,
        duckingService: DuckingDetectionService,
        processingService: AudioProcessingService
    ) {
        self.sessionService = sessionService
        self.volumeService = volumeService
        self.deviceService = deviceService
        self.duckingService = duckingService
        self.processingService = processingService
    }
    
    func initialize(configuration: AudioDriverConfiguration) async throws {
        self.configuration = configuration
        
        // Create virtual audio device
        virtualDevice = try await deviceService.createVirtualDevice(configuration: configuration)
        
        // Set as default output if needed
        try await deviceService.setDefaultOutputDevice(virtualDevice!)
    }
    
    func start() async throws {
        guard !isActive else { return }
        guard virtualDevice != nil else {
            throw AudioMixerError.invalidConfiguration
        }
        
        // Start monitoring audio sessions
        try await sessionService.startMonitoring()
        
        // Enable ducking prevention if configured
        if configuration?.enableDuckingPrevention == true {
            try await duckingService.setDuckingPrevention(enabled: true)
        }
        
        isActive = true
    }
    
    func stop() async throws {
        guard isActive else { return }
        
        sessionService.stopMonitoring()
        
        if let device = virtualDevice {
            try await deviceService.removeVirtualDevice(device.id)
        }
        
        isActive = false
    }
    
    func isRunning() async -> Bool {
        isActive
    }
    
    func getVirtualDevice() async throws -> AudioDevice {
        guard let device = virtualDevice else {
            throw AudioMixerError.deviceNotFound
        }
        return device
    }
}
