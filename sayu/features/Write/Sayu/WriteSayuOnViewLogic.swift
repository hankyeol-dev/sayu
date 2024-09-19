//
//  WriteSayuOnViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import Foundation
import UIKit

import RealmSwift

final class WriteSayuOnViewLogic: ObservableObject {
   @Published
   var sayu: Think?
   
   @Published
   var sayuDate: String = ""
   
   // MARK: - timer
   @Published
   var timer: Timer? = nil
   
   @Published
   var isPaused: Bool = true
   
   @Published
   var isStopped: Bool = false
   
   @Published
   var sayuTimerProgress: CGFloat = 1.0
   
   @Published
   var sayuSettingTime: Int = 0
   
   @Published
   private var sayuStaticTime: Int = 0
   
   @Published
   var isActiveLastTimeStamp: Date = .init()
   
   
   // MARK: - database & managers
   private let thinkRepository = Repository<Think>()
   private let notificationManager: NotificationManager = .init()
}

extension WriteSayuOnViewLogic {
   func setSayu(for id: ObjectId) {
      sayu = thinkRepository.getRecordById(id)
      setSayuDate()
      setSayuTime()
   }
   
   private func setSayuDate() {
      if let sayu, let date = sayu.date.formattedForView() {
         sayuDate = date.formattedForView()
      }
   }
   
   private func setSayuTime() {
      if let sayu {
         if sayu.timerType == SayuTimerType.timer.rawValue {
            sayuSettingTime = sayu.timeSetting
            sayuStaticTime = sayu.timeSetting
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
               guard let self else { return }
               self.startTimer()
            }
         }
         
         if sayu.timerType == SayuTimerType.stopWatch.rawValue {
            sayuSettingTime = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
               guard let self else { return }
               startStopwatch()
            }
         }
      }
   }
}

// MARK: - timer setting
extension WriteSayuOnViewLogic {
   func startTimer() {
      isPaused = false
      isStopped = false
      
      guard timer == nil else { return }
      
      timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
         guard let self else { return }
         if sayuSettingTime > 0 {
            sayuSettingTime -= 1
            sayuTimerProgress = CGFloat(sayuSettingTime) / CGFloat(sayuStaticTime)
            sayuTimerProgress = sayuTimerProgress < 0 ? 0 : sayuTimerProgress
         } else {
            stopTimer()
            notificationManager.addNotification(
               title: "지정한 사유 시간이 다 되었어요!",
               body: "시간을 추가하셔도 좋고, 조금더 사유하셔도 좋아요 :)",
               identifier: .sayuTimeEnded)
         }
      }
   }
   
   func pauseTimer() {
      isPaused = true
      isStopped = false
      timer?.invalidate()
      timer = nil
   }
   
   func stopTimer() {
      isPaused = true
      isStopped = true
      sayuTimerProgress = 1.0
      sayuSettingTime = 0
      sayuStaticTime = 1
      timer?.invalidate()
      timer = nil
   }
   
   private func addNotification() {
      let content = UNMutableNotificationContent()
      content.title = "설정한 사유 시간 종료"
      content.subtitle = "오늘도 풍부한 사유를 즐겨주셔서 감사합니다. :)"
   }
}

// MARK: - stopwatch setting
extension WriteSayuOnViewLogic {
   func startStopwatch() {
      isPaused = false
      isStopped = false
      
      guard timer == nil else { return }
      
      timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
         guard let self else { return }
         sayuSettingTime += 1
      }
   }
}
