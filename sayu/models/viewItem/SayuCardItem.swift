//
//  SayuCardItem.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import Foundation
import RealmSwift

struct SayuCardItem: Identifiable, Hashable {
   let id: ObjectId
   let subject: String
   let content: String
   let subCount: Int
   let smartList: [String]
   let thinkType: String
   let timeTake: String
   let isSaved: Bool
}

struct SayuCardListSectionItem: Identifiable, Hashable {
   let id: UUID = .init()
   let sectionKey: String
   var sectionCardItems: [SayuCardItem]
}
