//
//  SupabaseCoreAssembly.swift
//  SupabaseCore
//

import Foundation
import Swinject

public final class SupabaseCoreAssembly: Assembly {
    private let configuration: SupabaseConfiguration

    public init(configuration: SupabaseConfiguration = .fromBundle()) {
        self.configuration = configuration
    }

    public func assemble(container: Container) {
        let configuration = self.configuration

        container.register((any SupabaseProvider).self) { _ in
            SupabaseProviderImpl(configuration: configuration)
        }.inObjectScope(.container)
    }
}
