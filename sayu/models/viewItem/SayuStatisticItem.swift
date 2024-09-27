//
//  SayuStatisticItem.swift
//  sayu
//
//  Created by 강한결 on 9/25/24.
//

import Foundation

struct SayuStatisticItem: Identifiable, Hashable {
   let id: UUID = .init()
   let title: String
   let content: String
}
