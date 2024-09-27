//
//  SayuPointEarningButtonItem.swift
//  sayu
//
//  Created by 강한결 on 9/24/24.
//

import Foundation

struct SayuPointEarningButtonItem: Identifiable, Hashable {
   let id: UUID = .init()
   let title: String
   var canEarned: Bool
   var isEarned: Bool
   let point: Int
}
