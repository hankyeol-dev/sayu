//
//  SayuBarChartItem.swift
//  sayu
//
//  Created by 강한결 on 9/25/24.
//

import Foundation

struct SayuBarChartItem: Identifiable, Hashable {
   let id: UUID = .init()
   let date: String
   let figure: Int
   let height: Double
}
