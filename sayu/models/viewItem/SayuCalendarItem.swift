//
//  SayuCalendarItem.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import SwiftUI

struct SayuCalendarItem: Identifiable, Hashable {
   let id: UUID = .init()
   var day: Int
   var date: Date
}
