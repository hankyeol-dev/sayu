//
//  WriteSayuViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation

import RealmSwift

final class WriteSayuViewLogic: ObservableObject {
   enum SubFieldFocus: Int {
      case first
      case second
      case third
      case forth
      case fifth
      case sixth
   }
   
   // MARK: - subjectItems
   @Published
   var selectedSystemSubject: SubjectViewItem?
   @Published
   var systemSubjectItems: [SubjectViewItem] = []
   @Published
   var subjectFieldText: String = ""
   @Published
   var isSubjectFieldOnSubmitTapped: Bool = false
   
   // MARK: - subItems
   @Published
   var subItems: [SubViewItem] = []

   // MARK: - sayuType
   @Published
   var sayuTypes: [SayuTypeItem] = ThinkType.allCases.map { .init(
      type: $0,
      title: $0.byKoreanTypes)
   }
   @Published
   var selectedSayuType: ThinkType = .stay
   
   // MARK: - timer
   @Published
   var sayuTimerTypes: [SayuTimerTypeItem] = SayuTimerType.allCases.map {
      .init(type: $0, title: $0.byKoreanTitle)
   }
   
   @Published
   var selectedTimerType: SayuTimerType = .timer
   
   @Published
   var sayuTime: SayuTime = .init(hours: 0, minutes: 0, seconds: 0)
   
   // MARK: - databases
   @ObservedResults(Subject.self)
   private var subjects
   @ObservedResults(Sub.self)
   private var subs
   
   init() {
      setSystemSubjectViewItems()
   }
}

extension WriteSayuViewLogic {
   private func setSystemSubjectViewItems() {
      systemSubjectItems = subjects.filter { subject in
         subject.isSystemSubject
      }.map { .init(id: $0._id.stringValue, subject: $0.title, isSelected: false) }
   }

   func setSystemSubItems(_ item: SubjectViewItem?) {
      if let item {
         selectedSystemSubject = item
         setSystemSubs(item)
      } else {
         selectedSystemSubject = nil
         subItems = []
      }
   }
}

extension WriteSayuViewLogic {
   private func setSystemSubs(_ item: SubjectViewItem) {
      let filtered = SystemSubjects.allCases.first { subject in
         subject.byKoreanSubject == item.subject
      }
      
      if let filtered {
         subItems = filtered.getKoreanSubTitles.map { .init(sub: $0) }
      } else {
         subItems = []
      }
   }
   
   func addSubItem() { subItems.append(.init(sub: "")) }
   func removeSubItem(_ index: Int) { subItems.remove(at: index) }
}

// MARK: timer logic
extension WriteSayuViewLogic {
   func resetTimer() { sayuTime = .init(hours: 0, minutes: 0, seconds: 0) }
}
