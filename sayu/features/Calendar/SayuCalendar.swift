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
         AppMainNavbar {
            createLeftPointButtonView()
         } rightButton: {
            createRightViewChangeButtonView()
         }

         ScrollView(.vertical, showsIndicators: false) {
            CalendarView()
            .environmentObject(viewLogic)
            
            if viewLogic.calendarViewType == .calendar {
               SayuCardListView(dateString: viewLogic.selectedDayString,
                                sayuCardItemList: viewLogic.daySayuCardList)
            } else {
               ForEach(viewLogic.sayuCardSectionList, id:\.id) { list in
                  SayuCardListView(dateString: list.sectionKey,
                                   sayuCardItemList: list.sectionCardItems)
               }
            }
         }
         .background(.basebeige)
         .padding(.vertical, -8.0)
      }
   }
}

extension SayuCalendar {
   @ViewBuilder
   private func createLeftPointButtonView() -> some View {
      Button {
         SayuPointView()
            .push(with: .horizontalSlide)
            .environmentObject(pointManager)
      } label: {
         HStack(alignment: .center) {
            Image(.sayuPoint)
               .resizable()
               .frame(width: 20.0, height: 20.0)
            Spacer.width(4.0)
            Text(String(pointManager.getLastAccumulatedPoint()))
               .byCustomFont(.gmMedium, size: 13.0)
               .foregroundStyle(.grayXl)
         }
      }
   }
   
   @ViewBuilder
   private func createRightViewChangeButtonView() -> some View {
      Button {
         withAnimation(.snappy) {
            viewLogic.setCalendarViewType()
         }
      } label: {
         HStack(alignment: .center) {
            Text(viewLogic.calendarViewType == .calendar ? "타임라인 뷰" : "캘린더 뷰")
               .byCustomFont(.gmMedium, size: 13.0)
               .foregroundStyle(.grayXl)
            Spacer.width(8.0)
            Image(viewLogic.calendarViewType == .calendar ? .listSegmentSelected : .calendarPixeledSelected)
               .resizable()
               .frame(width: 16.0, height: 16.0)
         }
      }
   }
}
