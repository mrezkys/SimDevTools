//
//  FrameModifier.swift
//  InternalDeveloperTool
//
//  Created by Muhammad Rezky on 30/09/24.
//

import SwiftUI

struct ContentFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 300, height: 500)
    }
}

struct AppFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 400, height: 500)
    }
}

extension View {
    func resizeToContentFrame() -> some View {
        self.modifier(ContentFrameModifier())
    }
    
    func resizeToAppFrame() -> some View {
        self.modifier(AppFrameModifier())
    }
}
