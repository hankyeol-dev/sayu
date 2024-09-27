//
//  SayuItem.swift
//  sayu
//
//  Created by 강한결 on 9/26/24.
//

import Foundation
import RealmSwift

final class SayuItem: Object, ObjectKeyIdentifiable {
   @Persisted(primaryKey: true)
   var _id: ObjectId
   
   @Persisted
   var name: String
   
   @Persisted
   var qualification: String

   @Persisted
   var qualificationAmount: Int

   @Persisted
   var isNeedPoint: Bool = false
   
   @Persisted
   var isOwned: Bool = false
   
   @Persisted
   var createdAt: Date = .init()
   
   convenience init(
      name: String,
      qualification: String,
      qualificationAmount: Int = 0,
      isNeedPoint: Bool = false
   ) {
      self.init()
      
      self.name = name
      self.qualification = qualification
      self.qualificationAmount = qualificationAmount
      self.isNeedPoint = isNeedPoint
   }
}
