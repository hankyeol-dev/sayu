//
//  SayuTypeItem.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation

struct SayuTypeItem: Identifiable, Hashable {
   let id: UUID = .init()
   var type: ThinkType
   var title: String
}
