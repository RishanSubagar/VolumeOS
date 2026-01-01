// MARK: - Service Protocols

import Foundation
import Combine
import CoreAudio

/// Protocol for managing audio sessions and detecting active applications
protocol AudioSessionService {
    /// Publisher that emits events when applications start/stop audio
    var applicationEvents: AnyPublisher<AudioMixerEvent, Never> { get }
    
    /// Get all currently active audio applications
    func getActiveApplications() async throws -> [AudioApplication]
    
    /// Get information about a specific application
    func getApplication(pid: pid_t) async throws -> AudioApplication
    
    /// Start monitoring for audio session changes
    func startMonitoring() async throws
    
    /// Stop monitoring
    func stopMonitoring()
}

/// Protocol for controlling per-application volume
protocol VolumeControlService {
    /// Set volume for a specific application
    func setVolume(_ volume: VolumeLevel, for pid: pid_t) async throws
    
    /// Get current volume for an application
    func getVolume(for pid: pid_t) async throws -> VolumeLevel
    
    /// Mute/unmute an application
    func setMuted(_ muted: Bool, for pid: pid_t) async throws
    
    /// Get mute state for an application
    func isMuted(pid: pid_t) async throws -> Bool
}

/// Protocol for managing audio devices
protocol AudioDeviceService {
    /// Publisher that emits device-related events
    var deviceEvents: AnyPublisher<AudioMixerEvent, Never> { get }
    
    /// Get all available audio devices
    func getDevices() async throws -> [AudioDevice]
    
    /// Get the default output device
    func getDefaultOutputDevice() async throws -> AudioDevice
    
    /// Set the default output device
    func setDefaultOutputDevice(_ device: AudioDevice) async throws
    
    /// Create a virtual audio device
    func createVirtualDevice(configuration: AudioDriverConfiguration) async throws -> AudioDevice
    
    /// Remove a virtual device
    func removeVirtualDevice(_ deviceId: AudioObjectID) async throws
}

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

/// Protocol for the main audio driver that coordinates all services
protocol AudioDriverService {
    /// Initialize the driver with configuration
    func initialize(configuration: AudioDriverConfiguration) async throws
    
    /// Start the audio driver
    func start() async throws
    
    /// Stop the audio driver
    func stop() async throws
    
    /// Check if driver is running
    func isRunning() async -> Bool
    
    /// Get the virtual device created by this driver
    func getVirtualDevice() async throws -> AudioDevice
}

/// Protocol for audio processing/routing
protocol AudioProcessingService {
    /// Process audio buffer from an application
    func processAudioBuffer(
        from pid: pid_t,
        buffer: UnsafeMutablePointer<Float>,
        frameCount: UInt32,
        channelCount: UInt32
    ) throws
    
    /// Mix multiple audio streams into output buffer
    func mixAudioStreams(
        streams: [(pid: pid_t, buffer: UnsafeMutablePointer<Float>)],
        outputBuffer: UnsafeMutablePointer<Float>,
        frameCount: UInt32,
        channelCount: UInt32
    ) throws
}

// MARK: - Repository Protocols

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

/// Protocol for managing driver configuration
protocol ConfigurationRepository {
    /// Save configuration
    func saveConfiguration(_ configuration: AudioDriverConfiguration) async throws
    
    /// Load configuration
    func loadConfiguration() async throws -> AudioDriverConfiguration
}
