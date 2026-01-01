//
//  AudioMixerEvent.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation
import CoreAudio

// Documentation of VolumeOS's behaviour
enum AudioMixerEvent {
    case applicationStartedAudio(AudioApplication)
    case applicationStoppedAudio(pid_t)
    case volumeChanged(pid_t, VolumeLevel)
    case muteStateChanged(pid_t, Bool)
    case duckingDetected(DuckingState)
    case deviceAdded(AudioDevice)
    case deviceRemoved(AudioObjectID)
}
