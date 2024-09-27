//
//  +Date.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation

extension Date {
   func formattedAppConfigure() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "yyyy-MM-dd"
      return formatter.string(from: self)
   }
   
   func formattedForView() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.timeZone = .autoupdatingCurrent
      formatter.dateFormat = "M월 d일"
      return formatter.string(from: self)
   }
   
   func formattedForCalendarYear() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.dateFormat = "yyyy"
      return formatter.string(from: self)
   }
   
   func formattedForCalendarMonth() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.dateFormat = "M월"
      return formatter.string(from: self)
   }
   
   func formattedForCalendarDay() -> String {
      let formatter = DateFormatter()
      formatter.locale = .init(identifier: "ko_KR")
      formatter.dateFormat = "d일"
      return formatter.string(from: self)
   }
   
   func getAllDatesInMonth() -> [Self]? {
      let calendar = Calendar.current
      guard let startDate = calendar.date(
         from: calendar.dateComponents([.year, .month], from: self))
      else { return nil }
      
      let range = calendar.range(of: .day, in: .month, for: startDate)
      
      return range?.compactMap { day in
         return calendar.date(byAdding: .day, value: day - 1, to: startDate)
      }
   }
}
