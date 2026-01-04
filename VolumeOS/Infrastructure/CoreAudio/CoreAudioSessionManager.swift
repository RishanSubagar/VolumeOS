//
//  CoreAudioSessionManager.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-04.
//

import Foundation
import CoreAudio
import AppKit
import Combine

// MARK: - Core Audio Session Manager

final class CoreAudioSessionManager: AudioSessionService {
    private let eventSubject = PassthroughSubject<AudioMixerEvent, Never>()
    private var propertyListenerQueue: DispatchQueue?
    private var isMonitoring = false
    
    var applicationEvents: AnyPublisher<AudioMixerEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    func startMonitoring() async throws {
        guard !isMonitoring else { return }
        
        propertyListenerQueue = DispatchQueue(label: "com.audiomixer.sessionmonitor")
        
        // Register for audio session notifications
        registerAudioPropertyListeners()
        
        isMonitoring = true
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        
        unregisterAudioPropertyListeners()
        isMonitoring = false
    }
    
    func getActiveApplications() async throws -> [AudioApplication] {
        // Query Core Audio for active audio processes
        var apps: [AudioApplication] = []
        
        var propSize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcesses,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var status = AudioObjectGetPropertyDataSize(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propSize
        )
        
        guard status == noErr else {
            throw AudioMixerError.deviceNotFound
        }
        
        let processCount = Int(propSize) / MemoryLayout<pid_t>.size
        var processes = [pid_t](repeating: 0, count: processCount)
        
        status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &propSize,
            &processes
        )
        
        guard status == noErr else {
            throw AudioMixerError.deviceNotFound
        }
        
        for pid in processes {
            if let app = try? await getApplication(pid: pid) {
                apps.append(app)
            }
        }
        
        return apps
    }
    
    func getApplication(pid: pid_t) async throws -> AudioApplication {
        let runningApps = NSWorkspace.shared.runningApplications
        
        guard let app = runningApps.first(where: { $0.processIdentifier == pid }) else {
            throw AudioMixerError.applicationNotFound(pid)
        }
        
        let iconData = app.icon?.tiffRepresentation
        
        return AudioApplication(
            id: pid,
            name: app.localizedName ?? "Unknown",
            bundleIdentifier: app.bundleIdentifier,
            iconData: iconData,
            volume: .default,
            isMuted: false,
            isActive: true
        )
    }
    
    private func registerAudioPropertyListeners() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcesses,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectAddPropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            audioPropertyListener,
            Unmanaged.passUnretained(self).toOpaque()
        )
    }
    
    private func unregisterAudioPropertyListeners() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyProcesses,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        AudioObjectRemovePropertyListener(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            audioPropertyListener,
            Unmanaged.passUnretained(self).toOpaque()
        )
    }
}

// MARK: - C Callbacks

/// C callback for audio property changes
/// - Note: Must be a free function (not a method) to work with Core Audio C APIs
private func audioPropertyListener(
    _ inObjectID: AudioObjectID,
    _ inNumberAddresses: UInt32,
    _ inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    _ inClientData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let clientData = inClientData else { return noErr }
    
    let manager = Unmanaged<CoreAudioSessionManager>
        .fromOpaque(clientData)
        .takeUnretainedValue()
    
    // Notify about audio session changes
    Task {
        if let apps = try? await manager.getActiveApplications() {
            for app in apps {
                manager.eventSubject.send(.applicationStartedAudio(app))
            }
        }
    }
    
    return noErr
}
