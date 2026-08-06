//
//  ReadingSource.swift
//  Flood-Detection
//
//  WHAT: The protocol every source of water level readings must implement:
//        get the latest reading, get history since a date, and provide a
//        live stream of new readings as they arrive.
//
//  WHY:  This is the key abstraction of the whole app. We don't yet know
//        if data will come from our own hardware, a government archive
//        API, or a recorded replay file for demos — and we don't need to
//        know yet, because every controller and view is written against
//        this protocol, never a concrete type. Swapping the real source
//        in later should not require touching any UI or controller code.
//
//  USED BY: MockReadingSource, APIReadingSource, DashboardController
//
//  STATUS: Implemented (protocol only — no logic here by definition).
//

import Foundation

/// Anything that can supply Reading values, live or historical.
///
/// Conformers decide how readings are produced (hardware, network,
/// replay file) — consumers should only ever hold a `ReadingSource`,
/// never a concrete type.
protocol ReadingSource {

    /// The most recent reading available.
    func latest() async throws -> Reading

    /// All readings recorded at or after the given date.
    func history(since: Date) async throws -> [Reading]

    /// A live stream of readings as they become available. Long-lived —
    /// callers should consume it with `for await`.
    var stream: AsyncStream<Reading> { get }
}
