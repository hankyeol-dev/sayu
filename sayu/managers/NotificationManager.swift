//
//  NotificationManager.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import UIKit
import UserNotifications

struct NotificationManager {
   private let notificationCenter = UNUserNotificationCenter.current()
   
   enum NotificationIdentifiers: String {
      case sayuTimeEnded
   }
   
   func askPermission() {
      notificationCenter.requestAuthorization(options: [.alert, .sound]) {
         _, error in
      }
   }
   
   func addNotification(
      title: String,
      body: String,
      identifier: NotificationIdentifiers
   ) {
      notificationCenter.requestAuthorization(options: [.alert, .sound]) { isPermitted, error in
         guard error == nil else { return }
         if isPermitted {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
            let request = UNNotificationRequest(
               identifier: identifier.rawValue,
               content: content,
               trigger: trigger
            )
            
            notificationCenter.add(request)
         }
      }
   }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
   ) {
      completionHandler([.banner, .sound])
   }
}
