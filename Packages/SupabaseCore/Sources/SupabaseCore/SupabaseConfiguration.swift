//
//  SupabaseConfiguration.swift
//  SupabaseCore
//

import Foundation

/// Supabase credentials, resolved from `Chronik/Config/Supabase.local.xcconfig`
/// through the Info.plist template.
///
/// A missing value means that gitignored file is absent or blank. Constructing a
/// client against an empty URL would fail later with an opaque networking error,
/// so this traps instead — see D5 in
/// `docs/superpowers/specs/2026-09-07-supabase-persistence-design.md`.
public struct SupabaseConfiguration: Sendable {
    public let url: URL
    public let anonKey: String

    public init(url: URL, anonKey: String) {
        self.url = url
        self.anonKey = anonKey
    }

    public static func fromBundle(_ bundle: Bundle = .main) -> SupabaseConfiguration {
        let rawURL = requiredValue(for: "SupabaseURL", variable: "SUPABASE_URL", in: bundle)
        let anonKey = requiredValue(for: "SupabaseAnonKey", variable: "SUPABASE_ANON_KEY", in: bundle)

        guard let url = normalizedURL(rawURL) else {
            fatalError("SUPABASE_URL is not a valid URL: \(rawURL)")
        }

        return SupabaseConfiguration(url: url, anonKey: anonKey)
    }

    /// `//` opens a comment in xcconfig, so a bare `https://…` value is truncated
    /// at the slashes. Writing the host alone is the documented way out, and this
    /// supplies the scheme; a full URL escaped with `$()` is passed through.
    private static func normalizedURL(_ raw: String) -> URL? {
        // `https://host` survives xcconfig as the bare scheme `https:`. That would
        // otherwise sail past every check and produce a URL pointing nowhere, so
        // name the cause rather than failing later against a nonsense host.
        if raw.hasSuffix(":") {
            fatalError(
                """
                SUPABASE_URL is "\(raw)" — an xcconfig comment truncated it.

                `//` starts a comment in xcconfig, so `https://your-project.supabase.co` \
                is cut at the slashes. In Chronik/Config/Supabase.local.xcconfig, drop \
                the scheme:

                    SUPABASE_URL = your-project.supabase.co

                Or escape the slashes if you need a full URL: http:/$()/localhost:54321
                """
            )
        }

        return raw.contains("://") ? URL(string: raw) : URL(string: "https://\(raw)")
    }

    private static func requiredValue(for key: String, variable: String, in bundle: Bundle) -> String {
        let value = (bundle.object(forInfoDictionaryKey: key) as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let value, !value.isEmpty else {
            fatalError(
                """
                \(variable) is not set.

                Chronik reads Supabase credentials from a gitignored xcconfig. Create \
                it and fill in both values:

                    cp Chronik/Config/Supabase.local.xcconfig.example \\
                       Chronik/Config/Supabase.local.xcconfig

                Then build again. No environment variables are involved, and Xcode \
                launched from the Dock works fine.
                """
            )
        }

        return value
    }
}
