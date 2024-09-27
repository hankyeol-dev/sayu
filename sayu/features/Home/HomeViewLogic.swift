//
//  HomeViewLogic.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import Foundation

final class HomeViewLogic: ObservableObject {
   @Published var selectedTabIndex: Int = 0
}

extension HomeViewLogic {
   func updateSelectedTabIndex(for index: Int) {
      selectedTabIndex = index
   }
}
