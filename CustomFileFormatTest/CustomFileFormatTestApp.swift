//
//  CustomFileFormatTestApp.swift
//  CustomFileFormatTest
//
//  Created by Maks Winters on 18.01.2024.
//

import SwiftUI
import SwiftData

@main
struct CustomFileFormatTestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TestData.self)
    }
}
