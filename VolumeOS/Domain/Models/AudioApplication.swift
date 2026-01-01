//
//  AudioApplication.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import Foundation

/// Represents an application that is currently outputting audio
struct AudioApplication: Identifiable, Hashable {
    let id: pid_t
    let name: String
    let bundleIdentifier: String?
    let iconData: Data?
    
    var volume: VolumeLevel
    var isMuted: Bool
    var isActive: Bool
    

    static func == (lhs: AudioApplication, rhs: AudioApplication) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
