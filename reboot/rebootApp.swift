//
//  rebootApp.swift
//  reboot
//
//  Created by 喜悦 on 2026/4/7.
//

import SwiftUI

@main
struct rebootApp: App {
    @StateObject private var store = RebootStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
