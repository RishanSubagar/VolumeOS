//
//  ContentView.swift
//  VolumeOS
//
//  Created by Rishan Subagar on 2025-12-30.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: VolumeViewModel

    var body: some View {
        VStack(spacing: 0) {
            header

            if viewModel.isLoading && viewModel.applications.isEmpty {
                loadingView
            } else if viewModel.applications.isEmpty {
                emptyView
            } else {
                applicationList
            }

            footer
        }
        .frame(minWidth: 500, minHeight: 400)
    }

    private var header: some View {
        HStack {
            Text("VolumeOS")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Spacer()
            Button(action: { viewModel.refreshApplications() }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.plain)
            .help("Refresh Applications")
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Detecting audio applications...")
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack {
            Spacer()
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No active audio applications found")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top)
            Text("Make sure apps like Chrome or Discord are running.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var applicationList: some View {
        List {
            ForEach(viewModel.applications) { app in
                ApplicationVolumeRow(app: app, viewModel: viewModel)
            }
        }
        .listStyle(InsetListStyle())
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Text("Controlling audio via VolumeOS Virtual Device")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
    }
}

struct ApplicationVolumeRow: View {
    let app: AudioApplication
    @ObservedObject var viewModel: VolumeViewModel

    var body: some View {
        HStack(spacing: 12) {
            appIcon

            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.headline)
                if let bundleId = app.bundleIdentifier {
                    Text(bundleId)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(width: 140, alignment: .leading)

            volumeSlider

            muteButton
        }
        .padding(.vertical, 4)
    }

    private var appIcon: some View {
        Group {
            if let iconData = app.iconData, let nsImage = NSImage(data: iconData) {
                Image(nsImage: nsImage)
                    .resizable()
            } else {
                Image(systemName: "app.fill")
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 32, height: 32)
        .cornerRadius(6)
    }

    private var volumeSlider: some View {
        HStack {
            Slider(value: Binding(
                get: { app.volume.normalized },
                set: { viewModel.updateVolume(for: app, to: $0) }
            ), in: 0...1)

            Text("\(app.volume.percentage)%")
                .font(.system(.caption, design: .monospaced))
                .frame(width: 40, alignment: .trailing)
        }
    }

    private var muteButton: some View {
        Button(action: { viewModel.toggleMute(for: app) }) {
            Image(systemName: app.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .font(.system(size: 14))
                .foregroundColor(app.isMuted ? .red : .primary)
                .frame(width: 24)
        }
        .buttonStyle(.plain)
    }
}
