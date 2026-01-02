//
//  AudioProcessingService.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2026-01-01.
//

import Foundation

/// Protocol for audio processing/routing
protocol AudioProcessingService {
    /// Process audio buffer from an application
    func processBuffer(
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
