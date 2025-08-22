//
//  Store.swift
//  SimDevTools
//
//  Created by Muhammad Rezky on 22/08/25.
//

import SwiftUI

@MainActor
public final class Store<R: Reducer>: ObservableObject {
    
    @Published public private(set) var state: R.State
    
    private var reducer: R
    
    public init(initial: R.State, reducer: R) {
        self.state = initial
        self.reducer = reducer
    }
    
    public func send(_ intent: R.Intent) {
        let effects = reducer.reduce(state: &state, intent: intent)
        for effect in effects {
            Task {
                if let followUp = await effect.run() {
                    self.send(followUp)
                }
            }
        }
    }
}
