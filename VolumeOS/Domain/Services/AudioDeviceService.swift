//
//  AudioDeviceService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation
import Combine
import CoreAudio

/// Protocol for managing audio devices
protocol AudioDeviceService {
    /// Publisher that emits device-related events
    var deviceEventes: AnyPublisher<AudioMixerEvent, Never> { get }
    
    /// Get all available audio devices
    func getDevices() async throws -> [AudioDevice]
    
    /// Get the default output device
    func getDefaultOutputDevice() async throws -> AudioDevice
    
    /// Set the default output device
    func setDefaultAudioDevice(_ device: AudioDevice) async throws
    
    /// Create a virtual audio device
    func createVirtualDevice(configuration: AudioDriverConfiguration) async throws -> AudioDevice
    
    /// Remove a virtual device
    func removeVirtualDevice(_ deviceId: AudioObjectID) async throws
}
