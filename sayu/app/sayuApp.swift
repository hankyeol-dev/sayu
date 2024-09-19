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
   private let databaseManager: DatabaseManager = .manager
   
   var body: some Scene {
      WindowGroup {
         WriteSayuOn(createdSayuId: .init("66ebd66badbfb2ea8e02e9fd"))
//         Home()
            .implementNavigationView(config: navigationConfig)
            .implementPopupView()
            .environment(\.realmConfiguration, databaseManager.getDBConfig())
            .task {
//               databaseManager.getDBURL()
               notificationManager.askPermission()
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
