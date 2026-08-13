//
//  FilterViewModel.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//


public struct RangeSelectionValue {
    public let value: Double
    public let text: String
}

public struct RangeBorders {
    public let min: Double
    public let max: Double
}

public struct RangeSelectionState {
    let lower: RangeSelectionValue
    let upper: RangeSelectionValue
    let rangeBorders: RangeBorders
}

public protocol RangeSelectionViewModel {
    var rangeSelectionState: RangeSelectionState { get }
    func update(upper value: Double)
    func update(lower value: Double)
}
