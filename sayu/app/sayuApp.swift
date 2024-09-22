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
   @UIApplicationDelegateAdaptor(AppDelegate.self)
   private var appDelegate
   
   private let notificationManager: NotificationManager = .init()
   private let sayuPointManager: SayuPointManager = .init()
   private let databaseManager: DatabaseManager = .manager
   
   var body: some Scene {
      WindowGroup {
         Home()
            .implementNavigationView(config: navigationConfig)
            .implementPopupView(config: { config in
               config.bottom { bottom in
                  bottom.tapOutsideToDismiss(true)
               }
            })
            .environment(\.realmConfiguration, databaseManager.getDBConfig())
            .task {
               notificationManager.askPermission()
               sayuPointManager.addJoinPoint()
            }
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
