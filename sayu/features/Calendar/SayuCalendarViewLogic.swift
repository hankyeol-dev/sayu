//
//  SayuCalendarViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation

final class SayuCalendarViewLogic: ObservableObject {
   @Published
   var current: Date = .init()
   
   @Published
   var currentMonth: Int = 0
   
   @Published
   var dayConstant: [String] = ["일", "월", "화", "수", "목", "금", "토"]
   
   @Published
   var daySayuCardList: [SayuCardItem] = []
   
   private let pointManager: SayuPointManager = .manager
   private let sayuRepository: Repository<Think> = .init()
}

extension SayuCalendarViewLogic {
   func setNextMonth() { currentMonth += 1 }
   func setPreviousMonth() { currentMonth -= 1 }
   
   func createMonthDates() -> [SayuCalendarItem] {
      let calendar = Calendar.current
      guard let month = calendar.date(byAdding: .month, value: currentMonth, to: .now),
            let dates = month.getAllDatesInMonth()
      else { return [] }
      
      var days = dates.compactMap { date -> SayuCalendarItem in
         let day = calendar.component(.day, from: date)
         return .init(day: day, date: date)
      }
      
      let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? .now)
      
      for _ in 0..<firstWeekday - 1 {
         days.insert(.init(day: 0, date: .now), at: 0)
      }
      
      return days
   }
   
   func getCurrentMonth() -> Date {
      let calendar = Calendar.current
      guard let month = calendar.date(byAdding: .month, value: currentMonth, to: .now)
      else { return .now }
      
      return month
   }
}

extension SayuCalendarViewLogic {
   func getSayuCountByDate(_ dateString: String) -> Int {
      sayuRepository.getRecordsByQuery { sayu in
         sayu.date == dateString && sayu.isSaved
      }.count
   }
   
   func setSayuList(_ dateString: String) {
      let queriedSayu = sayuRepository.getRecordsByQuery { sayu in
         if Date().formattedAppConfigure() == sayu.date {
            return sayu.date == dateString
         } else {
            return sayu.date == dateString && sayu.isSaved
         }
      }
      
      daySayuCardList = queriedSayu.map { sayu in
         return .init(
            id: sayu._id,
            subject: mappingSubject(sayu),
            content: sayu.content,
            thinkType: mappingThinkType(sayu.thinkType),
            timeTake: sayu.timeTake.converTimeToCardViewString(),
            isSaved: sayu.isSaved
         )
      }
   }
   
   private func mappingSubject(_ sayu: Think) -> String {
      guard let subject = sayu.subject.first else { return "정해진 주제가 없어요." }
      return subject.title
   }
   
   private func mappingThinkType(_ index: Int) -> String {
      return ThinkType(rawValue: index)?.byKoreanTypes ?? "정해진 사유 방식이 없어요."
   }
}
