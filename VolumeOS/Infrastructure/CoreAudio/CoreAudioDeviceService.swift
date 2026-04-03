//
//  CoreAudioDeviceService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-05.
//

import Foundation
import CoreAudio
import Combine

final class CoreAudioDeviceService: AudioDeviceService {
    private let eventSubject = PassthroughSubject<AudioMixerEvent, Never>()

    var deviceEvents: AnyPublisher<AudioMixerEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    func getDevices() async throws -> [AudioDevice] {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDevices,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var propsize: UInt32 = 0
        var status = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propsize)
        guard status == noErr else { throw AudioMixerError.deviceNotFound }

        let count = Int(propsize) / MemoryLayout<AudioObjectID>.size
        var deviceIDs = [AudioObjectID](repeating: 0, count: count)
        status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propsize, &deviceIDs)
        guard status == noErr else { throw AudioMixerError.deviceNotFound }

        var devices: [AudioDevice] = []
        for id in deviceIDs {
            if let device = try? await getDeviceDetails(id: id) {
                devices.append(device)
            }
        }
        return devices
    }

    func getDefaultOutputDevice() async throws -> AudioDevice {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID: AudioObjectID = 0
        var propsize = UInt32(MemoryLayout<AudioObjectID>.size)
        let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &propsize, &deviceID)
        guard status == noErr else { throw AudioMixerError.deviceNotFound }

        return try await getDeviceDetails(id: deviceID)
    }

    func setDefaultOutputDevice(_ device: AudioDevice) async throws {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID = device.id
        let propsize = UInt32(MemoryLayout<AudioObjectID>.size)
        let status = AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, propsize, &deviceID)
        guard status == noErr else { throw AudioMixerError.volumeControlFailed }
    }

    func createVirtualDevice(configuration: AudioDriverConfiguration) async throws -> AudioDevice {
        let devices = try await getDevices()
        if let existing = devices.first(where: { $0.name == configuration.deviceName }) {
            return existing
        }

        // In a real environment with the driver installed, it should already be in the list.
        // If not, we throw an error or return a mock if in development.
        throw AudioMixerError.driverInstallationFailed
    }

    func removeVirtualDevice(_ deviceId: AudioObjectID) async throws {
        // Implementation for removing virtual device if it's an aggregate device
    }

    private func getDeviceDetails(id: AudioObjectID) async throws -> AudioDevice {
        let name = getDeviceName(id: id) ?? "Unknown Device"
        let manufacturer = getDeviceManufacturer(id: id) ?? "Unknown Manufacturer"

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
        var propsize: UInt32 = 0
        AudioObjectGetPropertyDataSize(id, &address, 0, nil, &propsize)
        let isOutput = propsize > 0

        address.mScope = kAudioObjectPropertyScopeInput
        AudioObjectGetPropertyDataSize(id, &address, 0, nil, &propsize)
        let isInput = propsize > 0

        return AudioDevice(
            id: id,
            name: name,
            manufacturer: manufacturer,
            isInput: isInput,
            isOutput: isOutput,
            sampleRate: 44100.0,
            channelCount: 2
        )
    }

    private func getDeviceName(id: AudioObjectID) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var name: Unmanaged<CFString>?
        var propsize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = AudioObjectGetPropertyData(id, &address, 0, nil, &propsize, &name)
        return status == noErr ? (name?.takeRetainedValue() as String?) : nil
    }

    private func getDeviceManufacturer(id: AudioObjectID) -> String? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyManufacturer,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        var manufacturer: Unmanaged<CFString>?
        var propsize = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
        let status = AudioObjectGetPropertyData(id, &address, 0, nil, &propsize, &manufacturer)
        return status == noErr ? (manufacturer?.takeRetainedValue() as String?) : nil
    }
}
