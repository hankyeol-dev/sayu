//
//  SmartList.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation
import RealmSwift

final class SmartList: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true)
   var _id: ObjectId
   
   @Persisted(indexed: true)
   var title: String
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      title: String
   ) {
      self.init()
      
      self.title = title
   }
}
