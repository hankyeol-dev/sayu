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
   private let sayuPointManager: SayuPointManager = .manager
   private let databaseManager: DatabaseManager = .manager
   private let motionManager: MotionManager = .init()
   
   var body: some Scene {
      WindowGroup {
         Home()
            .implementNavigationView(config: navigationConfig)
            .implementPopupView(config: configurePopup)
            .environment(\.realmConfiguration, databaseManager.getDBConfig())
            .environmentObject(sayuPointManager)
            .task {
               notificationManager.askPermission()
               sayuPointManager.addJoinPoint()
               motionManager.getAuth()
               setInitialUserDefaults()
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
   
   func configurePopup(_ config: GlobalConfig) -> GlobalConfig {
      config.top { $0.dragGestureEnabled(true) }
      .centre { $0.tapOutsideToDismiss(true) }
      .bottom { $0.tapOutsideToDismiss(true)  }
   }
   
   private func setInitialUserDefaults() {
      let standard = UserDefaults.standard
      guard standard.object(forKey: AppEnvironment.isShowAppDeleteNotiKey) != nil else {
         standard.setValue(false, forKey: AppEnvironment.isShowAppDeleteNotiKey)
         return
      }
      guard standard.object(forKey: AppEnvironment.isShowAppDeleteChartNotiKey) != nil else {
         standard.setValue(false, forKey: AppEnvironment.isShowAppDeleteChartNotiKey)
         return
      }
   }
}
