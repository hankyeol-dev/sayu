//
//  Sub.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation
import RealmSwift

final class Sub: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true)
   var _id: ObjectId
   
   @Persisted
   var title: String
   
   @Persisted
   var content: String
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      title: String,
      content: String
   ) {
      self.init()
      self.title = title
      self.content = content
   }
}
