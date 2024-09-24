//
//  Home.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import MijickNavigationView

struct Home: NavigatableView {
   @StateObject private var homeViewLogic: HomeViewLogic = .init()
   @StateObject private var sayuPointManager: SayuPointManager = .manager
   
   var body: some View {
      VStack {
         ZStack {
            // TODO: - selectedTabIndex에 따라서 View 체인지
            if homeViewLogic.selectedTabIndex == 0 {
               SayuCalendar()
                  .environmentObject(sayuPointManager)
            }
            
            if homeViewLogic.selectedTabIndex == 2 {
               SayuChart()
            }
         }
         
         Spacer()
         
         AppTabbar(selectedTabIndex: $homeViewLogic.selectedTabIndex)
      }
   }
}

#Preview {
   Home()
}
