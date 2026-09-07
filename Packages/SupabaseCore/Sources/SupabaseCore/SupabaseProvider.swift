//
//  SupabaseProvider.swift
//  SupabaseCore
//

import Foundation
import Supabase

/// The only way to reach a `SupabaseClient`.
///
/// `client()` guarantees an authenticated session before returning, so there is no
/// reachable state in which a caller holds a client without one. Sign-in is lazy
/// rather than eager at launch: a failed sign-in then surfaces through the paths
/// the UI already handles instead of stalling a launch screen. See D8.
public protocol SupabaseProvider: Sendable {
    func client() async throws -> SupabaseClient
}

public actor SupabaseProviderImpl: SupabaseProvider {
    private let supabase: SupabaseClient
    private var hasSession = false

    public init(configuration: SupabaseConfiguration) {
        self.supabase = SupabaseClient(
            supabaseURL: configuration.url,
            supabaseKey: configuration.anonKey
        )
    }

    public func client() async throws -> SupabaseClient {
        try await ensureSession()
        return supabase
    }

    /// Restores the persisted session, or creates an anonymous one.
    ///
    /// Anonymous sign-in must be enabled in the Supabase dashboard. The resulting
    /// identity is per-install and can be linked to a real account later without
    /// migrating data.
    private func ensureSession() async throws {
        guard !hasSession else { return }

        do {
            _ = try await supabase.auth.session
        } catch {
            _ = try await supabase.auth.signInAnonymously()
        }

        hasSession = true
    }
}
