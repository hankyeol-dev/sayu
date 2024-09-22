//
//  SayuPointManager.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation

final class SayuPointManager: ObservableObject {
   static let manager: SayuPointManager = .init()
   private let pointRepository = Repository<SayuPoint>()
   private init() {}
   
   func addJoinPoint() {
      guard pointRepository.getLastRecord() == nil else { return }
               
      do {
         try pointRepository.addSingleRecord(
            .init(point: 20,
                  accumulated: 20,
                  pointType: SayuPointType.earn.rawValue,
                  descript: SayuPointType.EarningCase.firstJoin.rawValue))
      } catch { }
   }
   
   /// true: not earned today sayu
   /// fale: earned today sayu
   func isEarningTodaySayu() -> Bool {
      let filtered = pointRepository.getRecordsByQuery { query in
         query.descript == SayuPointType.EarningCase.dailySayu.rawValue
      }.filter { Calendar.current.isDateInToday($0.createdAt) }
      
      return filtered.isEmpty
   }
   
   func getLastAccumulatedPoint() -> Int {
      if let last = pointRepository.getLastRecord() {
         return last.accumulated
      } else {
         return 0
      }
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
   
   func earningTodaySayu() -> Bool {
      if isEarningTodaySayu() {
         addSayuPointRecord(.earn, point: 3, descript: SayuPointType.EarningCase.dailySayu.rawValue)
         return true
      }
      return false
   }
}
