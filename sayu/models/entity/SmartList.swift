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
   var emoji: String
   
   @Persisted
   var descript: String?
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      title: String,
      emoji: String,
      descript: String? = nil
   ) {
      self.init()
      
      self.title = title
      self.emoji = emoji
      self.descript = descript
   }
}
