//
//  SayuTimerTypeItem.swift
//  sayu
//
//  Created by 강한결 on 9/18/24.
//

import Foundation

struct SayuTimerTypeItem: Identifiable, Hashable {
   let id: UUID = .init()
   var type: SayuTimerType
   var title: String
}
