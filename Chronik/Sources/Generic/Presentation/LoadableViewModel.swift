//
//  BaseViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 23.07.2026.
//

import Observation

public enum Loadable<State> {
    case loading
    case success(State)
    case error(Error)
    
    public func isLoading() -> Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    public func getSuccess() -> State? {
        switch self {
        case .success(let state): return state
        default: return nil
        }
    }
    
    public func getError() -> Error? {
        switch self {
        case .error(let error): return error
        default: return nil
        }
    }
}

public enum StateError: Error {
    case general
}

public enum LoadableCollection<State> {
    case loading
    case success([State])
    case error(Error)
    
    public func isLoading() -> Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
    
    public func getSuccess() -> [State]? {
        switch self {
        case .success(let state): return state
        default: return nil
        }
    }
    
    public func getError() -> Error? {
        switch self {
        case .error(let error): return error
        default: return nil
        }
    }
}

@MainActor
public protocol LoadableViewModel {
    associatedtype State: Identifiable
    var state: Loadable<State> { get set }
}

@MainActor
@Observable
public class LoadableViewModelImpl<State: Identifiable> {
    public var state: Loadable<State> = .loading
}

@MainActor
public protocol LoadableCollectionViewModel {
    associatedtype State: Identifiable
    var state: LoadableCollection<State> { get }
}

@MainActor
@Observable
open class LoadableCollectionViewModelImpl<State: Identifiable> {
    public var state: LoadableCollection<State> = .loading
    
    public init() {}
}
