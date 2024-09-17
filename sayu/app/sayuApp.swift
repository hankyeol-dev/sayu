//
//  sayuApp.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import MijickNavigationView

@main
struct sayuApp: App {
   var body: some Scene {
      WindowGroup {
         Home()
            .implementNavigationView(config: navigationConfig)
      }
   }
}

extension sayuApp {
   var navigationConfig: NavigationGlobalConfig {
      var config = NavigationGlobalConfig()
      config.backGestureThreshold = 0.2
      return config
   }
}
