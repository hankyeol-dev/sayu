//
//  SayuCalendar.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct SayuCalendar: View {
   @EnvironmentObject
   var pointManager: SayuPointManager
   
   @StateObject
   private var viewLogic: SayuCalendarViewLogic = .init()
   
   var body: some View {
      VStack {
         AppMainNavbar(point: pointManager.getLastAccumulatedPoint())
         Spacer.height(12.0)
         
         ScrollView(.vertical, showsIndicators: false) {
            CalendarView()
            .environmentObject(viewLogic)
            
            SayuCardListView(dateString: viewLogic.selectedDayString,
                             sayuCardItemList: $viewLogic.daySayuCardList)
         }
      }
   }
}

#Preview {
   SayuCalendar()
}
