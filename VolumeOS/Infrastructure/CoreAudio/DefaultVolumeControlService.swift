//
//  DefaultVolumeControlService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-05.
//

import Foundation
import CoreAudio

final class DefaultVolumeControlService: VolumeControlService {
    private let deviceService: AudioDeviceService

    // Custom selectors matching the HAL plugin
    private let kVolumeOSPropertyAppVolume = AudioObjectPropertySelector(bitPattern: 0x76617070) // 'vapp'
    private let kVolumeOSPropertyAppMute   = AudioObjectPropertySelector(bitPattern: 0x6d617070) // 'mapp'

    init(deviceService: AudioDeviceService) {
        self.deviceService = deviceService
    }

    func setVolume(_ volume: VolumeLevel, for pid: pid_t) async throws {
        let virtualDevice = try await getVirtualDevice()

        var address = AudioObjectPropertyAddress(
            mSelector: kVolumeOSPropertyAppVolume,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(pid)
        )

        var vol = volume.normalized
        let status = AudioObjectSetPropertyData(
            virtualDevice.id,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<Float>.size),
            &vol
        )

        guard status == noErr else { throw AudioMixerError.volumeControlFailed }
    }

    func getVolume(for pid: pid_t) async throws -> VolumeLevel {
        let virtualDevice = try await getVirtualDevice()

        var address = AudioObjectPropertyAddress(
            mSelector: kVolumeOSPropertyAppVolume,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(pid)
        )

        var vol: Float = 1.0
        var propsize = UInt32(MemoryLayout<Float>.size)
        let status = AudioObjectGetPropertyData(
            virtualDevice.id,
            &address,
            0,
            nil,
            &propsize,
            &vol
        )

        return status == noErr ? VolumeLevel(vol) : .default
    }

    func setMuted(_ muted: Bool, for pid: pid_t) async throws {
        let virtualDevice = try await getVirtualDevice()

        var address = AudioObjectPropertyAddress(
            mSelector: kVolumeOSPropertyAppMute,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(pid)
        )

        var m = muted ? UInt32(1) : UInt32(0)
        let status = AudioObjectSetPropertyData(
            virtualDevice.id,
            &address,
            0,
            nil,
            UInt32(MemoryLayout<UInt32>.size),
            &m
        )

        guard status == noErr else { throw AudioMixerError.volumeControlFailed }
    }

    func getMuted(for pid: pid_t) async throws -> Bool {
        let virtualDevice = try await getVirtualDevice()

        var address = AudioObjectPropertyAddress(
            mSelector: kVolumeOSPropertyAppMute,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: AudioObjectPropertyElement(pid)
        )

        var m: UInt32 = 0
        var propsize = UInt32(MemoryLayout<UInt32>.size)
        let status = AudioObjectGetPropertyData(
            virtualDevice.id,
            &address,
            0,
            nil,
            &propsize,
            &m
        )

        return status == noErr ? (m != 0) : false
    }

    private func getVirtualDevice() async throws -> AudioDevice {
        let devices = try await deviceService.getDevices()
        guard let virtual = devices.first(where: { $0.manufacturer == "VolumeOS Virtual" }) else {
            throw AudioMixerError.deviceNotFound
        }
        return virtual
    }
}
