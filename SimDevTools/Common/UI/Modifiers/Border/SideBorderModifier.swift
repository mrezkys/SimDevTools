//
//  BorderExtension.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 27/09/24.
//

import SwiftUI

enum BorderSide {
    case top, bottom, leading, trailing
}

struct BorderModifier: ViewModifier {
    var color: Color
    var width: CGFloat
    var sides: [BorderSide]

    func body(content: Content) -> some View {
        content
            .overlay(borderOverlay)
    }

    @ViewBuilder
    private var borderOverlay: some View {
        ZStack {
            if sides.contains(.top) {
                Rectangle()
                    .fill(color)
                    .frame(height: width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            if sides.contains(.bottom) {
                Rectangle()
                    .fill(color)
                    .frame(height: width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            if sides.contains(.leading) {
                Rectangle()
                    .fill(color)
                    .frame(width: width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            if sides.contains(.trailing) {
                Rectangle()
                    .fill(color)
                    .frame(width: width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
        }
    }
}

extension View {
    func border(color: Color, width: CGFloat, sides: [BorderSide]) -> some View {
        self.modifier(BorderModifier(color: color, width: width, sides: sides))
    }
}
