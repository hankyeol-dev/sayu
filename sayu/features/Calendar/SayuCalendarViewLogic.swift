//
//  SayuCalendarViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation
import RealmSwift

final class SayuCalendarViewLogic: ObservableObject {
   enum CalendarViewType: CaseIterable, Hashable {
      case calendar
      case timeline
   }
   
   @Published
   var calendarViewType: CalendarViewType = .calendar
   
   @Published
   var current: Date = .init()
   
   @Published
   var currentMonth: Int = 0
   
   @Published
   var selectedDayString: String = Date().formattedAppConfigure()
   
   @Published
   var dayConstant: [String] = ["일", "월", "화", "수", "목", "금", "토"]
   
   @Published
   var daySayuCardList: [SayuCardItem] = []
   
   @Published
   var sayuCardSectionList: [SayuCardListSectionItem] = []
   
   private let pointManager: SayuPointManager = .manager
   private let sayuRepository: Repository<Think> = .init()
   
   init() {
      setList()
   }
}

extension SayuCalendarViewLogic {
   func setCalendarViewType() {
      if calendarViewType == .calendar {
         calendarViewType = .timeline
      } else {
         calendarViewType = .calendar
      }
      setList()
   }
   
   func setNextMonth() {
      currentMonth += 1
   }
   func setPreviousMonth() {
      currentMonth -= 1
   }
   
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
   
   func setCurrentMonth() {
      let calendar = Calendar.current
      guard let month = calendar.date(byAdding: .month, value: currentMonth, to: .now)
      else { return }
      
      current = month
      
      setList()
   }
}

extension SayuCalendarViewLogic {
   func setSelectedDay(_ dateString: String) {
      if selectedDayString != dateString {
         selectedDayString = dateString
      }
   }
   
   func getSayuCountByDate(_ dateString: String) -> Int {
      sayuRepository.getRecordsByQuery { sayu in
         sayu.date == dateString && sayu.isSaved
      }.count
   }
}

extension SayuCalendarViewLogic {
   func setList() {
      if calendarViewType == .calendar {
         setSayuCardList()
      } else {
         setSayuCardSectionList()
      }
   }
   
   func setSayuCardList() {
      let queriedSayu = sayuRepository.getRecordsByQuery { [weak self] sayu in
         return sayu.date == self?.selectedDayString
      }
      daySayuCardList = queriedSayu.map { sayu in
         self.mappingSayuToCardItem(sayu)
      }.sorted(by: { item, _ in
         item.isSaved
      })
   }
   
   func setSayuCardSectionList() {
      let targetMonth = current.formattedForCalendarMonth()
      
      let queried = sayuRepository.getRecordsByQuery { sayu in
         if let date = sayu.date.formattedForView() {
            return date.formattedForCalendarMonth() == targetMonth
         } else {
            return false
         }
      }
      
      var lists: [SayuCardListSectionItem] = []
      queried.forEach { sayu in
         if var first = lists.first(where: { item in item.sectionKey == sayu.date }) {
            if let index = lists.firstIndex(of: first) {
               first.sectionCardItems.append(mappingSayuToCardItem(sayu))
               lists[index] = first
            }
         } else {
            lists.append(.init(sectionKey: sayu.date, sectionCardItems: [mappingSayuToCardItem(sayu)]))
         }
      }
      
      sayuCardSectionList = lists.reversed()
   }
   
   private func mappingSayuToCardItem(_ sayu: Think) -> SayuCardItem {
      return .init(
         id: sayu._id,
         subject: mappingSubject(sayu),
         content: sayu.content,
         subCount: sayu.subs.count,
         smartList: sayu.smartList.map { $0.title },
         thinkType: mappingThinkType(sayu.thinkType),
         timeTake: sayu.timeTake.converTimeToCardViewString(),
         isSaved: sayu.isSaved
      )
   }
   
   private func mappingSubject(_ sayu: Think) -> String {
      guard let subject = sayu.subject.first else { return "정해진 주제가 없어요." }
      return subject.title
   }
   
   private func mappingThinkType(_ index: Int) -> String {
      return ThinkType(rawValue: index)?.byKoreanTypes ?? "정해진 사유 방식이 없어요."
   }
}
