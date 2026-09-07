//
//  SupabaseEntryService.swift
//  Chronik
//

import Foundation
import Supabase
import SupabaseCore

/// The Work log, backed by Supabase.
///
/// Remote-only: there is no local cache, so every call needs a connection (D1).
/// Row-level security keyed on `auth.uid()` is what protects the data — the anon
/// key ships inside the binary and is extractable (D2).
final class SupabaseEntryService: EntryService {
    private static let table = "entries"
    private static let readLimit = 500

    private let provider: any SupabaseProvider

    init(provider: any SupabaseProvider) {
        self.provider = provider
    }

    func add(_ entry: Entry) async throws {
        let client = try await authenticatedClient()

        try await mappingErrors {
            try await client
                .from(Self.table)
                .insert(SupabaseEntryRow(entry: entry))
                .execute()
        }
    }

    func update(_ entry: Entry) async throws {
        let client = try await authenticatedClient()

        // `.select()` so a zero-row update is detectable: PostgREST reports it as
        // success, whereas the local implementation threw. See D10.
        let updated: [SupabaseEntryRow] = try await mappingErrors {
            try await client
                .from(Self.table)
                .update(SupabaseEntryRow(entry: entry))
                .eq("id", value: entry.id.uuidString)
                .select(SupabaseEntryRow.columns)
                .execute()
                .value
        }

        guard !updated.isEmpty else {
            throw EntryServiceError.notFound
        }
    }

    func fetchAll() async throws -> [Entry] {
        let client = try await authenticatedClient()

        // Ordered server-side even though `EntriesViewModelImpl` re-sorts: it
        // costs nothing and is a precondition for replacing `readLimit` with
        // real pagination.
        let rows: [SupabaseEntryRow] = try await mappingErrors {
            try await client
                .from(Self.table)
                .select(SupabaseEntryRow.columns)
                .order("day", ascending: false)
                .order("created_at", ascending: false)
                .limit(Self.readLimit)
                .execute()
                .value
        }

        return try rows.map { try $0.toEntry() }
    }

    func fetch(by id: UUID) async throws -> Entry? {
        let client = try await authenticatedClient()

        let rows: [SupabaseEntryRow] = try await mappingErrors {
            try await client
                .from(Self.table)
                .select(SupabaseEntryRow.columns)
                .eq("id", value: id.uuidString)
                .limit(1)
                .execute()
                .value
        }

        return try rows.first.map { try $0.toEntry() }
    }

    func delete(by id: UUID) async throws {
        let client = try await authenticatedClient()

        // Deliberately silent when the row is already gone, matching the local
        // implementation.
        try await mappingErrors {
            try await client
                .from(Self.table)
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        }
    }

    // MARK: - Error mapping

    /// Sign-in failures are reported separately from query failures, so the
    /// distinction survives without depending on the vendor's error type names.
    private func authenticatedClient() async throws -> SupabaseClient {
        do {
            return try await provider.client()
        } catch {
            throw Self.isOffline(error) ? EntryServiceError.offline : .notAuthenticated
        }
    }

    @discardableResult
    private func mappingErrors<T>(_ operation: () async throws -> T) async throws -> T {
        do {
            return try await operation()
        } catch let error as EntryServiceError {
            throw error
        } catch {
            throw Self.isOffline(error)
                ? EntryServiceError.offline
                : .server(error.localizedDescription)
        }
    }

    private static func isOffline(_ error: Error) -> Bool {
        let nsError = error as NSError
        guard nsError.domain == NSURLErrorDomain else { return false }

        return [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorCannotFindHost,
            NSURLErrorTimedOut,
            NSURLErrorDataNotAllowed,
            NSURLErrorInternationalRoamingOff,
            NSURLErrorSecureConnectionFailed
        ].contains(nsError.code)
    }
}
