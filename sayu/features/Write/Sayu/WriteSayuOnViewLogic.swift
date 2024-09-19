//
//  WriteSayuOnViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import Foundation

import RealmSwift

final class WriteSayuOnViewLogic: ObservableObject {
   @Published
   var sayu: Think?
   
   @Published
   var sayuDate: String = ""
   
   // MARK: - database
   private let thinkRepository = Repository<Think>()
}

extension WriteSayuOnViewLogic {
   func setSayu(for id: ObjectId) {
      sayu = thinkRepository.getRecordById(id)
      setSayuDate()
   }
   
   private func setSayuDate() {
      if let sayu, let date = sayu.date.formattedForView() {
         sayuDate = date.formattedForView()
      }
   }
   
   private func setSayuTime() {
      if let sayu {
//         sayu.time
      }
   }
}
