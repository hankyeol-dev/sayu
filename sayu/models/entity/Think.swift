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
   var timerType: Int
   
   @Persisted
   var timeSetting: Int = 0
   
   @Persisted
   var timeTake: Int = 0
   
   @Persisted
   var steps: Int?
   
   @Persisted
   var distance: Double?
   
   @Persisted
   var avgPace: Double?
   
   @Persisted
   var isSaved: Bool = false
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      date: String,
      content: String,
      thinkType: Int = ThinkType.stay.rawValue,
      timerType: Int = SayuTimerType.timer.rawValue,
      timeSetting: Int = 0,
      timeTake: Int = 0,
      steps: Int? = nil,
      distance: Double? = nil,
      avgPace: Double? = nil,
      isSaved: Bool = false
   ) {
      self.init()
      
      self.date = date
      self.content = content
      self.thinkType = thinkType
      self.timerType = timerType
      self.timeSetting = timeSetting
      self.timeTake = timeTake
      self.steps = steps
      self.distance = distance
      self.avgPace = avgPace
      self.isSaved = isSaved
   }
}
