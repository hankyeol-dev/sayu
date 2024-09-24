//
//  SayuDetailViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/23/24.
//

import Foundation
import RealmSwift
import SwiftUI

final class SayuDetailViewLogic: ObservableObject {
   
   @Published
   var isEditMode: Bool = false

   @Published
   var sayu: Think?

   @Published
   var sayuSubject: String = ""
   
   @Published
   var sayuContents: String = ""
   
   @Published
   var sayuSubs: [SubViewItem] = []
   
   @Published
   var isSavedError: Bool = false
   
   // MARK: - db & managers
   private let sayuRepository: Repository<Think> = .init()
   private let subRepository: Repository<Sub> = .init()
   private let motionManager: MotionManager = .init()
}

extension SayuDetailViewLogic {
   func setSayu(_ id: ObjectId) {
      sayu = sayuRepository.getRecordById(id)
      setSayuSubject()
      setSayuContents()
   }
   
   private func setSayuSubject() {
      if let sayu {
         if let subject = sayu.subject.first {
            sayuSubject = subject.title
         }
      }
   }
   
   private func setSayuContents() {
      if let sayu {
         sayuContents = sayu.content
         sayuSubs = sayu.subs.map({ .init(sub: $0.title, content: $0.content) })
      }
   }
}

// MARK: - Edit Logic
extension SayuDetailViewLogic {
   func turnOnEditMode() {
      isEditMode = true
   }
   
   func turnOffEditModeAndSave() {
      reSave()
      if !isSavedError {
         isEditMode = false
      }
   }
   
   private func reSave() {
      if let sayu {
         do {
            try sayuRepository.updateRecord(sayu._id) { [weak self] record in
               guard let self else { return }
               record.content = sayuContents
               record.subs.enumerated().forEach { [weak self] index, sub in
                  guard let self else { return }
                  sub.content = sayuSubs[index].content
               }
            }
            try sayu.subs.enumerated().forEach { index, sub in
               try subRepository.updateRecord(sub._id) { [weak self] record in
                  guard let self else { return }
                  record.content = sayuSubs[index].content
               }
            }
            isSavedError = false
         } catch {
            isSavedError = true
         }
      }
   }
}
