//
//  APIReadingSource.swift
//  Flood-Detection
//
//  WHAT: Placeholder ReadingSource for whatever real backend we end up
//        using — our own sensor's API, a government flood data archive,
//        or something else entirely.
//
//  WHY:  The data source decision is genuinely not made yet (see the
//        project brief). This file exists so the shape of "a real,
//        networked ReadingSource" is visible in the codebase and every
//        other piece of code can already be written against the
//        ReadingSource protocol, ready to swap MockReadingSource for this
//        the moment the decision is made.
//
//  USED BY: Nothing yet — not wired in anywhere. Will replace
//           MockReadingSource as DashboardController's ReadingSource once
//           implemented.
//
//  STATUS: Stub only. No networking code, by design — see project
//          constraints. Every method throws NotImplementedError.
//

import Foundation

/// Stand-in for a real, networked ReadingSource. Not implemented — the
/// backend (own sensor vs. government archive vs. something else) is not
/// yet decided.
struct APIReadingSource: ReadingSource {

    // TODO: backend not yet decided. Once it is, this will likely need
    // init parameters for an endpoint/credentials and a URLSession.

    func latest() async throws -> Reading {
        throw NotImplementedError()
    }

    func history(since: Date) async throws -> [Reading] {
        throw NotImplementedError()
    }

    var stream: AsyncStream<Reading> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}

/// Marks a code path that's intentionally not built yet, so it fails
/// loudly instead of silently doing nothing.
struct NotImplementedError: Error {}
