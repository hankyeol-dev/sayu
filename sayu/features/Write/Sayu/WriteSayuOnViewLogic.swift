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
   
   var sayuTimeTakes: [Int] = []
   
   // MARK: - about sayu
   @Published
   var sayuSubject: String = ""
   
   @Published
   var sayuSubs: [SubViewItem] = []
   
   @Published
   var sayuContent: String = ""
   
   // MARK: - motion
   private var motionStart: Date?
   private var motionEnd: Date?
   private var steps: Int = 0
   private var distance: Double = 0.0
   private var avgPace: Double = 0.0
   
   // MARK: - save & errors
   @Published
   var isSaveError: Bool = false
   
   @Published
   var isEarningTodaySayu: Bool = false
   
   // MARK: - database & managers
   private let sayuRepository = Repository<Think>()
   private let subRepository = Repository<Sub>()
   private let notificationManager: NotificationManager = .init()
   private let motionManager: MotionManager = .init()
   private let sayuPointManager: SayuPointManager = .manager
}

extension WriteSayuOnViewLogic {
   func setSayu(for id: ObjectId) {
      sayu = sayuRepository.getRecordById(id)
      setSayuDate()
      setSayuTime()
      setSayuSubject()
      setSayuSubs()
      setSayuContent()
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
            sayuStaticTime = sayu.timeSetting + sayu.timeTake
         }
         
         if sayu.timerType == SayuTimerType.stopWatch.rawValue {
            sayuSettingTime = 0
         }
         
         sayuTimeTakes.append(sayu.timeTake)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            startTimer()
         }
      }
   }
   
   private func setSayuSubject() {
      if let sayu, let first = sayu.subject.first {
         sayuSubject = first.title
      }
   }
   
   private func setSayuSubs() {
      if let sayu {
         sayuSubs = sayu.subs.map { .init(sub: $0.title, content: $0.content) }
      }
   }
   
   private func setSayuContent() {
      if let sayu {
         sayuContent = sayu.content
      }
   }
}

// MARK: - timer & stopwatch setting
extension WriteSayuOnViewLogic {
   func startTimer() {
      isPaused = false
      isStopped = false
      
      guard timer == nil else { return }
      
      if let sayu {
         setMotionStart(sayu)
         
         if sayu.timerType == SayuTimerType.timer.rawValue {
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
         
         if sayu.timerType == SayuTimerType.stopWatch.rawValue {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
               guard let self else { return }
               sayuSettingTime += 1
            }
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
      
      saveTimeTake()
      
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
   
   private func saveTimeTake() {
      if let sayu {
         if sayu.timerType == SayuTimerType.timer.rawValue {
            sayuTimeTakes.append(sayuStaticTime - sayuSettingTime - sayu.timeTake)
         }
         
         if sayu.timerType == SayuTimerType.stopWatch.rawValue {
            sayuTimeTakes.append(sayuSettingTime)
         }
      }
   }
   
   func addTimeSetting(_ timeSetting: SayuTime) {
      sayuSettingTime = timeSetting.convertTimeToSeconds
      sayuStaticTime = sayuSettingTime
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
         guard let self else { return }
         startTimer()
      }
   }
}

// MARK: - motion setting
extension WriteSayuOnViewLogic {
   private func setMotionStart(_ sayu: Think) {
      if sayu.thinkType == ThinkType.run.rawValue
            || sayu.thinkType == ThinkType.walk.rawValue {
         motionStart = .init()
      }
   }
   private func setMotionEnd(_ sayu: Think) {
      if sayu.thinkType == ThinkType.run.rawValue
            || sayu.thinkType == ThinkType.walk.rawValue {
         motionEnd = .init()
      }
   }
}

// MARK: - save
extension WriteSayuOnViewLogic {
   func saveSayu(_ isTemp: Bool) {
      isStopped = true
      saveTimeTake()
      
      if let sayu {
         setMotionEnd(sayu)
         let totalTime = sayuTimeTakes.reduce(0) { cv, fv in return (cv + fv) }
         let remainTime = sayuSettingTime <= totalTime ? 0 : sayuStaticTime - totalTime
         
         if motionManager.checkAuth() 
               && (sayu.thinkType == ThinkType.walk.rawValue
                   || sayu.thinkType == ThinkType.run.rawValue) {
            saveMotionPermitted(sayu, isTemp: isTemp, totalTime: totalTime, remainTime: remainTime)
         } else {
            updateSayu(sayu, isMotion: false, isTemp: isTemp, totalTime: totalTime, remainTime: remainTime)
         }
         
         isSaveError = false
      }
   }
   
   private func saveMotionPermitted(_ sayu: Think, isTemp: Bool, totalTime: Int, remainTime: Int) {
      guard let start = motionStart, let end = motionEnd else { return }
      do {
         try motionManager.getMotionData(
            start: start,
            end: end) { [weak self] s, d, a in
               guard let self else { return }
               steps = s
               distance = d
               avgPace = a
               updateSayu(sayu, isMotion: true, isTemp: isTemp, totalTime: totalTime, remainTime: remainTime)
            }
         motionStart = nil
         motionEnd = nil
      } catch MotionManager.MotionManagerError.authorizationDenied {
         isSaveError = true
      } catch {
         isSaveError = true
      }
   }
   
   private func updateSayu(_ sayu: Think, isMotion: Bool, isTemp: Bool, totalTime: Int, remainTime: Int) {
      do {
         try sayuRepository.updateRecord(sayu._id) { [weak self] record in
            guard let self else { return }
            
            record.content = sayuContent
            record.timeTake = totalTime
            record.timeSetting = remainTime
            record.isSaved = !isTemp
            if isMotion {
               record.avgPace = avgPace
               record.distance = distance
               record.steps = steps
            }
            
            if !sayuSubs.isEmpty {
               sayuSubs.enumerated().forEach { idx, sub in
                  sayu.subs[idx].content = sub.content
               }
            }
         }
         
         if !sayuSubs.isEmpty {
            try sayu.subs.forEach { sub in
               try subRepository.updateRecord(sub._id) { record in
                  record.content = sub.content
               }
            }
         }
         
         if !isTemp {
            isEarningTodaySayu = sayuPointManager.earningTodaySayu()
         }
         
      } catch {
         isSaveError = true
      }
   }
   
   private func checkIsToday() -> Bool {
      return sayuDate == Date().formattedForView()
   }
}
