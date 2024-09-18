//
//  SubjectViewItem.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation
import RealmSwift

struct SubjectViewItem: Identifiable, Hashable {
   let id: ObjectId
   var subject: String
   var isSelected: Bool
}
