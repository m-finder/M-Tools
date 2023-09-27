//
//  M_ToolsApp.swift
//  M-Tools
//
//  Created by 吴雲放 on 2023/9/22.
//

import SwiftUI

@main
struct M_ToolsApp: App {
    let persistenceController = PersistenceController.shared

    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {

        Settings {
            EmptyView()
        }
    }
}
