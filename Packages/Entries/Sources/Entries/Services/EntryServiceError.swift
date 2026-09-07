//
//  EntryServiceError.swift
//  Chronik
//

import Foundation

/// Failures an `EntryService` can surface to the presentation layer.
///
/// Both view models render `error.localizedDescription` directly. Under local
/// persistence that path essentially never fired; with a remote source of truth
/// offline is the common case, and a raw `URLError` reads as "The operation
/// couldn't be completed." See D9.
enum EntryServiceError: LocalizedError, Equatable {
    case offline
    case notAuthenticated
    case notFound
    case server(String)

    var errorDescription: String? {
        switch self {
        case .offline:
            return "You appear to be offline. Chronik needs a connection to reach your Work log."
        case .notAuthenticated:
            // Not a connectivity problem: `.offline` covers that case. This is a
            // rejected or unavailable sign-in, so do not send people to check wifi.
            return "Chronik could not sign in, so your Work log is unavailable. Try again."
        case .notFound:
            return "That Entry no longer exists."
        case .server(let message):
            return message
        }
    }
}
