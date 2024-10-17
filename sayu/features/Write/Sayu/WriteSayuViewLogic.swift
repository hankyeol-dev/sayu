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
      case unknownError
   }
   
   private var writeDate: String = ""
   
   @Published
   var writeDateForView: String = ""
   
   var lastSayuSubject: String = ""
   var lastSayuSmartList: [String] = []
   
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
   
   @Published
   var isPermittedMotion: Bool = true
   
   // MARK: - timer
   @Published
   var sayuTimerTypes: [SayuTimerTypeItem] = SayuTimerType.allCases.map {
      .init(type: $0, title: $0.byKoreanTitle)
   }
   
   @Published
   var selectedTimerType: SayuTimerType = .timer
   
   @Published
   var sayuTime: SayuTime = .init(hours: 0, minutes: 0, seconds: 0)
   
   // MARK: - smartlist
   @Published
   var smartListIcon: String = "⭐️"
   @Published
   var smartList: [String] = []
   
   // MARK: - valid
   @Published
   var isWriteValid: WriteSayuValidErrors? = nil
   
   // MARK: - databases
   @ObservedResults(Subject.self)
   private var subjects
   
   private let subjectRepository = Repository<Subject>()
   private let subRepository = Repository<Sub>()
   private let sayuRepository = Repository<Think>()
   private let smartListRepository = Repository<SmartList>()
   private let motionManager: MotionManager = .manager
   
   var createdSayuId: ObjectId?
   
   init() {
      setSystemSubjectViewItems()
      setLatestSayu()
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
   
   private func setLatestSayu() {
      if let record = sayuRepository.getLastRecord() {
         if let subject = record.subject.first {
            lastSayuSubject = subject.title
         }
         lastSayuSmartList = record.smartList.map { $0.title }
      }
   }
}

extension WriteSayuViewLogic {
   private func setSystemSubs(_ item: SubjectViewItem) {
      let filtered = SystemSubjects.allCases.first { subject in
         subject.byKoreanSubject == item.subject
      }
      
      if let filtered {
         subItems = filtered.getKoreanSubTitles.map { .init(sub: $0, content: "") }
      } else {
         subItems = []
      }
   }
   
   func addSubItem() { subItems.append(.init(sub: "", content: "")) }
   func removeSubItem(_ index: Int) { subItems.remove(at: index) }
   
   func setSayuType(_ type: ThinkType) {
      selectedSayuType = type
      if type == .run || type == .walk {
         if !motionManager.checkAuth() {
            motionManager.getAuth()
            isPermittedMotion = false
         } else {
            isPermittedMotion = true
         }
      }
   }
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
      }
   }
   
   /// 중복되는 주제일 경우, 컨펌이 필요함.
   private func validisOverlapedSubject() -> Bool {
      if subjects.first(where: { $0.title == subjectFieldText }) != nil {
         return true
      }
      return false
   }
   
   func setWriteValidNil() { isWriteValid = nil }
   
   private func addSayuRecord() {
      var sayuSubs: [Sub] = []
      var sayuSmartList: [SmartList] = []
      let sayu = Think(date: writeDate,
                       content: "",
                       thinkType: selectedSayuType.rawValue,
                       timerType: selectedTimerType.rawValue,
                       timeSetting: sayuTime.convertTimeToSeconds,
                       isSaved: false)
      
      if !subItems.isEmpty {
         sayuSubs = subItems.map { item in
               .init(title: item.sub, content: "")
         }
      }
      
      if !smartList.isEmpty {
         
         sayuSmartList = smartList.map { item in
            if let first = smartListRepository.getRecordsByQuery({ list in
               list.title == item
            }).first {
               return first
            }
            return .init(title: item)
         }
      }
      
      if let selectedSystemSubject {
         do {
            try subjectRepository.updateRecord(selectedSystemSubject.id) { subject in
               subject.thinks.append(sayu)
            }
            addThink(subs: sayuSubs, smartList: sayuSmartList, sayu: sayu)
         } catch {
            isWriteValid = .unknownError
         }
      }
      
      if !subjectFieldText.isEmpty {
         let valid = subjectRepository.getRecordsByQuery { [weak self] subject in
            guard let self else { return false }
            return subject.title == subjectFieldText
         }.first
         
         do {
            if valid == nil {
               try subjectRepository.addSingleRecord(.init(title: subjectFieldText)) { subject in
                     subject.thinks.append(sayu)
               }
            } else {
               try subjectRepository.updateRecord(valid!._id) { subject in
                  subject.thinks.append(sayu)
               }
            }
            addThink(subs: sayuSubs, smartList: sayuSmartList, sayu: sayu)
         } catch {
            isWriteValid = .unknownError
         }
      }
      
      createdSayuId = sayu._id
   }
   
   private func addThink(subs: [Sub], smartList: [SmartList], sayu: Think) {
      
      let sayuId = sayu._id
      
      do {
         try sayuRepository.addSingleRecord(sayu) { _ in }
         if !subs.isEmpty {
            try sayuRepository.updateRecord(sayuId) { think in
               subs.forEach { sub in
                  think.subs.append(sub)
               }
            }
            try subRepository.addMultiRecords(subs)
         }
         
         if !smartList.isEmpty {
            try sayuRepository.updateRecord(sayuId) { think in
               smartList.forEach { smart in
                  think.smartList.append(smart)
               }
            }
            try smartList.forEach { item in
               let target = smartListRepository.getRecordsByQuery({ list in
                  list.title == item.title
               })
               
               if target.isEmpty {
                  try smartListRepository.addSingleRecord(item)
               }
            }
         }
      } catch {
         isWriteValid = .unknownError
      }
   }
   
   func writeSayu() {
      do {
         try validStartSayu()
         addSayuRecord()
      } catch WriteSayuValidErrors.needToSetSubject {
         isWriteValid = .needToSetSubject
      } catch WriteSayuValidErrors.needToSetTime {
         isWriteValid = .needToSetTime
      } catch {}
   }
}
