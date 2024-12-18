//
//  SayuChartViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/25/24.
//

import Foundation

final class SayuChartViewLogic: ObservableObject {
   private let sevenDays = [6, 5, 4, 3, 2, 1, 0]
   
   @Published
   var sayuStatisticItems: [SayuStatisticItem] = []
   
   @Published
   var sayuBarChartItems: [SayuBarChartItem] = []
   
   @Published
   var sayuBarChartAverage: Double = 0.0
   
   @Published
   var todaySteps: Int?
   
   // MARK: - db & manager
   private let sayuRepository: Repository<Think> = .init()
   private let subjectRepository: Repository<Subject> = .init()
   private let motionManager: MotionManager = .manager
   
   init() {
      setSayuStatisticItems()
      setSayuBarChartItems()
      setTodaySteps()
   }
}

extension SayuChartViewLogic {
   func setSayuStatisticItems() {
      if motionManager.checkAuth() {
         sayuStatisticItems = [
            mappingTotalSayuCount(),
            mappingTotalSubCount(),
            mappingMaxSelectedSubject(),
            mappingTotalSayuTimeTake(),
            mappingTotalSteps(),
            mappingTotalDistance(),
            mappingTotalWalkingCount(),
            mappingTotalRunningCount()
         ]
      } else {
         sayuStatisticItems = [
            mappingTotalSayuCount(),
            mappingTotalSubCount(),
            mappingTotalSayuTimeTake(),
            mappingMaxSelectedSubject()
         ]
      }
   }
   
   private func mappingTotalSayuCount() -> SayuStatisticItem {
      let count = sayuRepository.getRecordsByQuery { sayu in
         sayu.isSaved
      }.count
      
      return .init(title: "지금까지 저장된 사유", content: String(count.formatted()))
   }
   
   private func mappingTotalSubCount() -> SayuStatisticItem {
      let quried = sayuRepository.getRecordsByQuery { sayu in
         !sayu.subs.isEmpty && sayu.isSaved
      }
      let count = quried.reduce(0) { cv, sayu in
         cv + sayu.subs.count
      }
      
      return .init(title: "함께 저장된 세부 사유", content: String(count.formatted()))
   }
   
   private func mappingTotalSayuTimeTake() -> SayuStatisticItem {
      let queried = sayuRepository.getRecordsByQuery { sayu in
         sayu.isSaved
      }
      let timeTake = queried.reduce(0) { cv, sayu in
         cv + sayu.timeTake
      }
      
      return .init(title: "총 사유 시간",
                   content: timeTake == 0 ? "0" : timeTake.converTimeToCardViewString())
   }
   
   private func mappingMaxSelectedSubject() -> SayuStatisticItem  {
      let queried = subjectRepository.getRecords().sorted { a, b in
         a.thinks.count > b.thinks.count
      }
      
      let sayus = sayuRepository.getRecords()

      if !sayus.isEmpty, let first = queried.first {
         return .init(title: "가장 많이 사유한 주제", content: first.title)
      } else {
         return .init(title: "가장 많이 사유한 주제", content: "-")
      }
   }
   
   private func mappingTotalSteps() -> SayuStatisticItem {
      let quried = sayuRepository.getRecordsByQuery { sayu in sayu.isSaved }
      let count = quried.reduce(0) { cv, sayu in
         if let steps = sayu.steps {
            return cv + steps
         } else {
            return cv
         }
      }
      return .init(title: "총 사유 걸음 수", content: String(count.formatted()) + " 보")
   }
   
   private func mappingTotalDistance() -> SayuStatisticItem {
      let quried = sayuRepository.getRecordsByQuery { sayu in sayu.isSaved }
      let count = quried.reduce(0) { cv, sayu in
         if let distance = sayu.distance {
            return cv + distance
         } else {
            return cv
         }
      }
      return .init(title: "총 사유 거리", content: String(Double(round(count * 100) / 100)) + " km")
   }
   
   private func mappingTotalWalkingCount() -> SayuStatisticItem {
      let queried = sayuRepository.getRecordsByQuery { sayu in
         sayu.isSaved && sayu.thinkType == ThinkType.walk.rawValue
      }
      return .init(title: "총 걸으면서 사유한 횟수", content: String(queried.count.formatted()) + " 회")
   }
   
   private func mappingTotalRunningCount() -> SayuStatisticItem {
      let queried = sayuRepository.getRecordsByQuery { sayu in
         sayu.isSaved && sayu.thinkType == ThinkType.run.rawValue
      }
      return .init(title: "총 달리면서 사유한 횟수", content: String(queried.count.formatted()) + " 회")
   }
}

extension SayuChartViewLogic {
   func setSayuBarChartItems() {
      let quried: [(String, Int)] = sevenDays.map { day in
         let records = sayuRepository.getRecordsByQuery { [weak self] sayu in
            guard let self else { return false }
            return sayu.isSaved && (sayu.date == calcNdaysAgo(day))
         }
         if let first = records.first {
            return (first.date, records.count)
         }
         return (calcNdaysAgo(day), records.count)
      }
      let total = quried.map { $0.1 }.reduce(0, { cv, value in return cv + value })
      let average = round((Double(total) / 7.0) * 10) / 10
      
      sayuBarChartAverage = average
      
      if average == 0 {
         sayuBarChartItems = []
      } else {
         let baseHeight = 75.0 / average
         sayuBarChartItems = quried.map { query in
               .init(date: query.0.formattedForView()?.formattedForCalendarDay() ?? "",
                     figure: query.1,
                     height: round((Double(query.1) * baseHeight) * 10) / 10 >= 150.0 ? 150.0 :  round((Double(query.1) * baseHeight) * 10) / 10
               )
         }
      }
   }
   
   private func calcNdaysAgo(_ value: Int) -> String {
      if let date = Calendar.current.date(byAdding: .day, value: -value, to: Date()) {
         return date.formattedAppConfigure()
      }
      return ""
   }
}

extension SayuChartViewLogic {
   func setTodaySteps() {
      motionManager.getTodaySteps { [weak self] steps in
         guard let self else { return }
         todaySteps = steps
      }
   }
}
