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
    private var isMonitoring = false
    
    var applicationEvents: AnyPublisher<AudioMixerEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }
    
    func startMonitoring() async throws {
        guard !isMonitoring else { return }
        
        // Register for default output device changes
        registerAudioPropertyListeners()
        
        // Monitor workspace
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleAppChange),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleAppChange),
            name: NSWorkspace.didTerminateApplicationNotification,
            object: nil
        )

        isMonitoring = true
    }
    
    func stopMonitoring() {
        guard isMonitoring else { return }
        unregisterAudioPropertyListeners()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        isMonitoring = false
    }
    
    @objc private func handleAppChange(notification: Notification) {
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            if notification.name == NSWorkspace.didLaunchApplicationNotification {
                Task {
                    if let audioApp = try? await getApplication(pid: app.processIdentifier) {
                        eventSubject.send(.applicationStartedAudio(audioApp))
                    }
                }
            } else if notification.name == NSWorkspace.didTerminateApplicationNotification {
                eventSubject.send(.applicationStoppedAudio(app.processIdentifier))
            }
        }
    }

    func getActiveApplications() async throws -> [AudioApplication] {
        let runningApps = NSWorkspace.shared.runningApplications
        var apps: [AudioApplication] = []
        
        // Filtering for applications that likely produce audio
        // We include specific ones mentioned by the user: Chrome, FaceTime, Discord
        let audioConfidenceBundles = [
            "com.google.Chrome",
            "com.apple.FaceTime",
            "com.hnc.Discord",
            "com.apple.Music",
            "com.spotify.client",
            "com.apple.Safari"
        ]
        
        for app in runningApps {
            if app.activationPolicy == .regular || audioConfidenceBundles.contains(app.bundleIdentifier ?? "") {
                if let audioApp = try? await getApplication(pid: app.processIdentifier) {
                    apps.append(audioApp)
                }
            }
        }
        
        return apps
    }
    
    func getApplication(pid: pid_t) async throws -> AudioApplication {
        let runningApps = NSWorkspace.shared.runningApplications
        
        guard let app = runningApps.first(where: { $0.processIdentifier == pid }) else {
            throw AudioMixerError.applicationNotFound(pid)
        }
        
        return AudioApplication(
            id: pid,
            name: app.localizedName ?? "Unknown",
            bundleIdentifier: app.bundleIdentifier,
            iconData: app.icon?.tiffRepresentation,
            volume: .default,
            isMuted: false,
            isActive: true
        )
    }
    
    private func registerAudioPropertyListeners() {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
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
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
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

private func audioPropertyListener(
    _ inObjectID: AudioObjectID,
    _ inNumberAddresses: UInt32,
    _ inAddresses: UnsafePointer<AudioObjectPropertyAddress>,
    _ inClientData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let clientData = inClientData else { return noErr }
    let manager = Unmanaged<CoreAudioSessionManager>.fromOpaque(clientData).takeUnretainedValue()
    
    Task {
        if let apps = try? await manager.getActiveApplications() {
            for app in apps {
                manager.eventSubject.send(.applicationStartedAudio(app))
            }
        }
    }
    return noErr
}
