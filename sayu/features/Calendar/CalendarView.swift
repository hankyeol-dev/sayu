//
//  Calendar.swift
//  sayu
//
//  Created by 강한결 on 9/22/24.
//

import SwiftUI

struct CalendarView: View {
   @EnvironmentObject
   var calendarViewLogic: SayuCalendarViewLogic
   
   var body: some View {
      VStack(spacing: 20.0) {
         createPicker(calendarViewLogic.current)
      }
      .padding(.horizontal, 16.0)
      .padding(.top, 8.0)
   }
}

extension CalendarView {
   private func createPicker(_ current: Date) -> some View {
      VStack {
         createMonthNavigator()
         .padding(.horizontal, 16.0)
         .padding(.top, 16.0)
         Spacer.height(24.0)
         
         if calendarViewLogic.calendarViewType == .calendar {
            createDayGrid()
            Spacer.height(16.0)
            
            createCalendarView()
            Spacer.height(16.0)            
         }
      }
      .onChange(of: calendarViewLogic.currentMonth) { _ in
         calendarViewLogic.setCurrentMonth()
      }
   }
  
}

extension CalendarView {
   private func createMonthNavigator() -> some View {
      HStack {
         Spacer.width(8.0)
         Button {
            calendarViewLogic.setPreviousMonth()
         } label: {
            Image(.arrowBack)
               .font(.title3)
         }
         
         Spacer()
         
         VStack(alignment: .center, spacing: 10.0) {
            Text(calendarViewLogic.current.formattedForCalendarYear())
               .byCustomFont(.gmlight, size: 13.0)
            Text(calendarViewLogic.current.formattedForCalendarMonth())
               .byCustomFont(.gmMedium, size: 18.0)
         }
         
         Spacer()
         
         Button {
            calendarViewLogic.setNextMonth()
         } label: {
            Image(.arrowBack)
               .rotationEffect(.degrees(180))
               .font(.title3)
         }
         Spacer.width(8.0)
      }
   }
   
   private func createDayGrid() -> some View {
      HStack(spacing: 4.0) {
         ForEach(calendarViewLogic.dayConstant, id: \.self) { day in
            Text(day)
               .byCustomFont(.satoshiLight, size: 15.0)
               .foregroundStyle(day == "일" ? .error : day == "토" ? .errorSm : .grayLg)
               .frame(maxWidth: .infinity)
         }
      }
   }
   
   private func createCalendarView() -> some View {
      LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 15.0) {
         ForEach(calendarViewLogic.createMonthDates(), id: \.id) { date in
            createDayView(date)
         }
      }
   }
   
   
   private func createDayView(_ date: SayuCalendarItem) -> some View {
      let dateString = date.date.formattedAppConfigure()
      let sayuCount = calendarViewLogic.getSayuCountByDate(dateString)
      
      return VStack {
         if date.day != 0 {
            if Calendar.current.isDateInToday(date.date) {
               Text("\(date.day)")
                  .byCustomFont(.gmBold, size: 15.0)
                  .background(Circle().fill(.baseGreenSm).frame(width: 28.0, height: 28.0))
            } else {
               Text("\(date.day)")
                  .byCustomFont(.gmMedium, size: 15.0)
            }
            
            if sayuCount != 0 {
               Spacer.height(8.0)
               VStack(alignment: .center) {
                  Image(.sayuCloud)
                     .resizable()
                     .frame(width: 12.0, height: 12.0)
                  Text(String(sayuCount))
                     .byCustomFont(.gmlight, size: 14.0)
               }
            }
         }
      }
      .padding(.vertical, 8.0)
      .padding(.horizontal, 8.0)
      .frame(height: 72.0, alignment: .top)
      .background(calendarViewLogic.selectedDayString == dateString ? .graySm : .clear)
      .clipShape(.rect(cornerRadius: 12.0))
      .onTapGesture {
         calendarViewLogic.setSelectedDay(dateString)
         calendarViewLogic.setSayuCardList()
      }
   }
   
}
