//
//  PagaEu2App.swift
//  PagaEu2
//
//  Created by Nillia Sousa on 16/05/22.
//

import SwiftUI

@main
struct PagaEu2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
