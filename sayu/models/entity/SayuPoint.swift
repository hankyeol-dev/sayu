//
//  SayuPoint.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation
import RealmSwift

final class SayuPoint: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true)
   var _id: ObjectId
   
   @Persisted
   var point: Int
   
   @Persisted
   var accumulated: Int
   
   @Persisted
   var pointType: Int
   
   @Persisted
   var descript: String
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      point: Int,
      accumulated: Int,
      pointType: Int,
      descript: String
   ) {
      self.init()
      
      self.point = point
      self.accumulated = accumulated
      self.pointType = pointType
      self.descript = descript
   }
}
