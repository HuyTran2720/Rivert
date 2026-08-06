//
//  MockReadingSource.swift
//  Flood-Detection
//
//  WHAT: The one ReadingSource implementation that's actually finished. It
//        loads the bundled sample_flood_event.json and replays it as a
//        live stream, at a configurable speed multiplier, so the app is
//        fully demoable without any real sensor or backend.
//
//  WHY:  The real data source is undecided — see ReadingSource.swift and
//        APIReadingSource.swift. This lets every other layer of the app
//        (controllers, views, alerting) be built and tested against
//        realistic-looking, reproducible data today.
//
//  USED BY: Not yet wired in anywhere. Intended as the default
//           ReadingSource passed into DashboardController once that's
//           connected to a real view.
//
//  STATUS: Implemented. Reads a bundled JSON resource; no networking, no
//          persistence.
//

import Foundation

/// Replays Resources/SampleData/sample_flood_event.json as a ReadingSource.
///
/// `latest()` and `history(since:)` operate over the full recorded
/// dataset. `stream` replays the dataset in timestamp order, sleeping
/// between readings to simulate real-time arrival, sped up by
/// `playbackSpeedMultiplier`.
final class MockReadingSource: ReadingSource {

    private let allReadings: [Reading]

    /// How much faster than real time to replay the stream. 1.0 = readings
    /// arrive spaced exactly as far apart as their real timestamps; 60.0 =
    /// an hour of recorded data plays out in a minute.
    private let playbackSpeedMultiplier: Double

    init(playbackSpeedMultiplier: Double = 1.0) {
        self.playbackSpeedMultiplier = max(playbackSpeedMultiplier, 0.001)
        self.allReadings = Self.loadSampleReadings()
    }

    func latest() async throws -> Reading {
        guard let last = allReadings.last else {
            throw MockReadingSourceError.noSampleData
        }
        return last
    }

    func history(since: Date) async throws -> [Reading] {
        allReadings.filter { $0.timestamp >= since }
    }

    var stream: AsyncStream<Reading> {
        AsyncStream { continuation in
            let task = Task {
                var previousTimestamp: Date?
                for reading in allReadings {
                    if let previousTimestamp {
                        let deltaSeconds = reading.timestamp.timeIntervalSince(previousTimestamp)
                        let sleepSeconds = max(0, deltaSeconds) / playbackSpeedMultiplier
                        try? await Task.sleep(nanoseconds: UInt64(sleepSeconds * 1_000_000_000))
                    }
                    previousTimestamp = reading.timestamp
                    continuation.yield(reading)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private static func loadSampleReadings() -> [Reading] {
        guard let url = Bundle.main.url(forResource: "sample_flood_event", withExtension: "json") else {
            assertionFailure("sample_flood_event.json not found in bundle — check Resources/SampleData is included in the target")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Reading].self, from: data).sorted { $0.timestamp < $1.timestamp }
        } catch {
            assertionFailure("Failed to decode sample_flood_event.json: \(error)")
            return []
        }
    }
}

enum MockReadingSourceError: Error {
    /// Thrown when the bundled sample JSON is missing or failed to decode.
    case noSampleData
}
