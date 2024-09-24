//
//  SayuPointManager.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation

import RealmSwift

final class SayuPointManager: ObservableObject {
   static let manager: SayuPointManager = .init()
   private let sayuRepository: Repository<Think> = .init()
   private let pointRepository: Repository<SayuPoint> = .init()
   private let motionManager: MotionManager = .init()
   
   @Published
   var currentSayuPoint: Int = 0
   
   @Published
   var dailySayuPointButtonList: [SayuPointEarningButtonItem] = []
   
   @Published
   var isSayuPointError: Bool = false
   
   private init() {
      currentSayuPoint = getLastAccumulatedPoint()
      mappingDailyEarningButtonList()
   }
}

extension SayuPointManager {
   func isEarningTodaySayu() -> Bool {
      let filtered = pointRepository.getRecordsByQuery { query in
         query.descript == SayuPointType.EarningCase.dailySayu.rawValue
      }.filter { Calendar.current.isDateInToday($0.createdAt) }
      
      return filtered.isEmpty
   }
   
   func earningTodaySayu() -> Bool {
      if isEarningTodaySayu() {
         addSayuPointRecord(.earn,
                            point: 3,
                            descript: SayuPointType.EarningCase.dailySayu.rawValue)
         return true
      }
      return false
   }
}

extension SayuPointManager {
   func addJoinPoint() {
      guard pointRepository.getLastRecord() == nil else { return }
      
      do {
         try pointRepository.addSingleRecord(
            .init(point: SayuPointType.EarningCase.firstJoin.byEarningPoint,
                  accumulated: SayuPointType.EarningCase.firstJoin.byEarningPoint,
                  pointType: SayuPointType.earn.rawValue,
                  descript: SayuPointType.EarningCase.firstJoin.rawValue))
      } catch { }
   }
   
   func getLastAccumulatedPoint() -> Int {
      if let last = pointRepository.getLastRecord() {
         return last.accumulated
      } else {
         return 0
      }
   }

   func getLastTenRecords() -> Array<SayuPoint> {
      let records = pointRepository.getRecords().sorted(by: \.createdAt, ascending: false)
      return records.map{ $0 }.suffix(10)
   }
   
   private func addSayuPointRecord(_ type: SayuPointType, point: Int, descript: String) {
      let lastPoint = getLastAccumulatedPoint()
      
      switch type {
      case .earn:
         do {
            try pointRepository.addSingleRecord(.init(point: point,
                                                      accumulated: lastPoint + point,
                                                      pointType: type.rawValue,
                                                      descript: descript))
         } catch Repository<SayuPoint>.RepositoryErrors.failForAdd {
            
         } catch {}
      case .pay:
         print("조금 있다가 구현")
      }
   }
}

extension SayuPointManager {
   func touchDailyEarningButton(_ button: SayuPointEarningButtonItem) {
      if let index = dailySayuPointButtonList.firstIndex(of: button) {
         dailySayuPointButtonList[index].isEarned = true
         dailySayuPointButtonList[index].canEarned = false
         addSayuPointRecord(.earn, point: button.point, descript: button.title)
      }
   }
   
   private func mappingDailyEarningButtonList() {
      var list: [SayuPointType.EarningCase]
      
      if motionManager.checkAuth() {
         list = [
            .dailyVisit,
            .dailyOver5Sayu,
            .dailyOver1000Steps,
            .dailyOver5000Steps,
            .dailyOver10000Steps
         ]
         motionManager.getTodaySteps { [weak self] steps in
            DispatchQueue.main.async {
            guard let self else { return }
               self.dailySayuPointButtonList = list.map({ type in
                     .init(
                        title: type.rawValue,
                        canEarned: self.validateCanEarningDailyPoint(type, steps: steps),
                        isEarned: !self.validateDailyEarningRecord(type),
                        point: type.byEarningPoint
                     )
               })
            }
         }
      } else {
         list = [.dailyVisit, .dailyOver5Sayu]
         dailySayuPointButtonList = list.map({ type in
               .init(title: type.rawValue,
                     canEarned: validateCanEarningDailyPoint(type, steps: 0),
                     isEarned: !validateDailyEarningRecord(type),
                     point: type.byEarningPoint
               )
         })
      }
   }
   
   private func validateCanEarningDailyPoint(_ type: SayuPointType.EarningCase, steps: Int) -> Bool {
      if type == .dailyVisit {
         return validateDailyEarningRecord(type)
      }
      
      if type == .dailyOver5Sayu {
         return validateDailySayuOverFive()
      }
      
      if motionManager.checkAuth() {
         if type == .dailyOver1000Steps {
            return validateTodaySteps(1000, steps: steps)
         }
         
         if type == .dailyOver5000Steps {
            return validateTodaySteps(5000, steps: steps)
         }
         
         if type == .dailyOver10000Steps {
            return validateTodaySteps(10000, steps: steps)
         }
      }
      
      return false
   }
   
   private func validateDailyEarningRecord(
      _ type: SayuPointType.EarningCase
   ) -> Bool {
      return pointRepository.getRecordsByQuery { query in
         query.descript == type.rawValue
      }.filter { Calendar.current.isDateInToday($0.createdAt) }.isEmpty
   }
   
   private func validateDailySayuOverFive() -> Bool {
      return sayuRepository.getRecordsByQuery { sayu in
         sayu.date == Date().formattedAppConfigure() && sayu.isSaved
      }.count >= 5
   }
   
   private func validateTodaySteps(_ condition: Int, steps: Int) -> Bool {
      return steps >= condition
   }
}
