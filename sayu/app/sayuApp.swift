//
//  sayuApp.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import RealmSwift
import MijickNavigationView
import MijickPopupView

@main
struct sayuApp: App {
   private let databaseManager: DatabaseManager = .manager
   
   var body: some Scene {
      WindowGroup {
         Home()
            .implementNavigationView(config: navigationConfig)
            .implementPopupView()
            .environment(\.realmConfiguration, databaseManager.getDBConfig())
         //            .task {
//               databaseManager.getDBURL()
//            }
      }
   }
}

extension sayuApp {
   var navigationConfig: NavigationGlobalConfig {
      var config = NavigationGlobalConfig()
      config.backGestureThreshold = 0.2
      config.backgroundColour = .white
      return config
   }
}
