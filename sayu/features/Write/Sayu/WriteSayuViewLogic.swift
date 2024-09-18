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
   
   enum WriteSayuValidErrors: Error {
      case needToSetSubject
      case needToSetTime
      case needToConfirm
   }
   
   private var writeDate: String = ""
   
   @Published
   var writeDateForView: String = ""
   
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
   
   // MARK: - valid
   @Published
   var isWriteValid: WriteSayuValidErrors? = nil
   
   // MARK: - databases
   @ObservedResults(Subject.self)
   private var subjects
   
   private let subjectRepository = Repository<Subject>()
   private let subRepository = Repository<Sub>()
   private let thinkRepository = Repository<Think>()
   
   init() {
      setSystemSubjectViewItems()
   }
}

extension WriteSayuViewLogic {
   private func setSystemSubjectViewItems() {
      systemSubjectItems = subjects.filter { subject in
         subject.isSystemSubject
      }.map { .init(id: $0._id, subject: $0.title, isSelected: false) }
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
   
   func setDate(_ date: Date) {
      writeDate = date.formattedAppConfigure()
      writeDateForView = date.formattedForView()
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

extension WriteSayuViewLogic {
   private func validStartSayu() throws {
      if subjectFieldText.isEmpty && selectedSystemSubject == nil {
         throw WriteSayuValidErrors.needToSetSubject
      }
      
      if selectedTimerType == .timer {
         if sayuTime.hours == 0 && sayuTime.minutes == 0 && sayuTime.seconds == 0 {
            throw WriteSayuValidErrors.needToSetTime
         }
         
         if sayuTime.convertTimeToSeconds <= 5 * 60 {
            throw WriteSayuValidErrors.needToConfirm
         }
      }
   }
   
   private func addThinkRecord() {
      var sayuSubs: [Sub] = []
      let sayu = Think(date: writeDate,
                       content: "",
                       thinkType: selectedSayuType.rawValue,
                       isSaved: false)
      
      if !subItems.isEmpty {
         sayuSubs = subItems.map { item in
               .init(title: item.sub, content: "")
         }
      }
      
      if let selectedSystemSubject {
         do {
            try subjectRepository.updateRecord(selectedSystemSubject.id) { subject in
               subject.thinks.append(sayu)
            }
            try thinkRepository.addSingleRecord(sayu) { think in
               sayuSubs.forEach { sub in
                  think.subs.append(sub)
               }
            }
            try subRepository.addMultiRecords(sayuSubs)
         } catch {
            dump(error)
         }
      } else {
         if !subjectFieldText.isEmpty {
            do {
               try subjectRepository.addSingleRecord(.init(title: subjectFieldText)) { subject in
                  subject.thinks.append(sayu)
               }
               try thinkRepository.addSingleRecord(sayu) { think in
                  sayuSubs.forEach { sub in
                     think.subs.append(sub)
                  }
               }
               try subRepository.addMultiRecords(sayuSubs)
            } catch {
               dump(error)
            }
         }
      }
   }
   
   func writeSayu(_ confirmHandler: @escaping () -> Bool) {
      do {
         try validStartSayu()
         addThinkRecord()
      } catch WriteSayuValidErrors.needToSetSubject {
         isWriteValid = .needToSetSubject
      } catch WriteSayuValidErrors.needToSetTime {
         isWriteValid = .needToSetTime
      } catch WriteSayuValidErrors.needToConfirm {
         isWriteValid = .needToConfirm
         if confirmHandler() {
            addThinkRecord()
         }
      } catch {
         // TODO: - 이미 저장된 주제인지 확인하는 에러 필요
      }
   }
   
   
}
