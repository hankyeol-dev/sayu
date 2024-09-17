//
//  Think.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation
import RealmSwift

final class Think: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true)
   var _id: ObjectId
   
   @Persisted(indexed: true)
   var date: String
   
   @Persisted(originProperty: "thinks")
   var subject: LinkingObjects<Subject>
   
   @Persisted
   var subs: List<Sub>
   
   @Persisted
   var smartList: List<SmartList>
   
   @Persisted
   var content: String
   
   @Persisted
   var thinkType: Int
   
   @Persisted
   var timeTake: Int = 0
   
   @Persisted
   var isSaved: Bool = false
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      date: String,
      content: String,
      thinkType: Int = ThinkType.stay.rawValue,
      timeTake: Int = 0,
      isSaved: Bool = false
   ) {
      self.init()
      
      self.date = date
      self.content = content
      self.thinkType = thinkType
      self.timeTake = timeTake
      self.isSaved = isSaved
      self.createdAt = createdAt
   }
}
