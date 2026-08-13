//
//  RangeSelectorView.swift
//  Chronik
//
//  Created by Vít Míchal on 25.07.2026.
//

import RangeSlider
import SwiftUI

struct RangeSelectionView: View {
    @State private var lowerValue: Double = 0.0
    @State private var upperValue: Double = 1.0
    
    @State var viewModel: RangeSelectionViewModel
    
    init(viewModel: RangeSelectionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            Text(viewModel.rangeSelectionState.lower.text)
                .padding(.trailing, Theme.dimensions.padding.s)
            
            RangeSlider(lowerValue: $lowerValue, upperValue: $upperValue)
                .onChange(of: lowerValue) { _, newValue in
                    viewModel.update(lower: viewModel.rangeSelectionState.rangeBorders.min + newValue*viewModel.rangeSelectionState.rangeBorders.max)
                }
                .onChange(of: upperValue) { _, newValue in
                    viewModel.update(upper: viewModel.rangeSelectionState.rangeBorders.min + newValue*viewModel.rangeSelectionState.rangeBorders.max)
                }
                .accentColor(.pink)
            
            Text(viewModel.rangeSelectionState.upper.text)
                .padding(.leading, Theme.dimensions.padding.s)
        }
    }
}

