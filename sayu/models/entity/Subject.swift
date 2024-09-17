//
//  Subject.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation
import RealmSwift

final class Subject: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true)
   var _id: ObjectId
   
   @Persisted
   var title: String
   
   @Persisted
   var thinks: List<Think>
   
   @Persisted
   var isSystemSubject: Bool
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      title: String,
      isSystemSubject: Bool = false
   ) {
      self.init()
      self.title = title
      self.isSystemSubject = isSystemSubject
   }
}
