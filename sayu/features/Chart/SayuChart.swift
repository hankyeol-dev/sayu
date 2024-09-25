//
//  SayuChart.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

import MijickNavigationView

struct SayuChart: NavigatableView {
   @EnvironmentObject
   var pointManager: SayuPointManager
   
   @StateObject
   private var sayuChartViewLogic: SayuChartViewLogic = .init()
   
   var body: some View {
      VStack {
         AppMainNavbar {
            createLeftPointButtonView()
         } rightButton: {
            Text("")
         }
         
         ScrollView {
            VStack(spacing: 20.0) {
               createTotalStatisticSection()
               createSevenDaysChartSection()
            }
            .padding(.horizontal, 16.0)
         }
         .refreshable {
            withAnimation(.bouncy) {
               sayuChartViewLogic.setSayuStatisticItems()
            }
         }
      }
      .background(.basebeige)
      .padding(.vertical, -8.0)
   }
}

extension SayuChart {
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
   
   private func createTotalStatisticSection() -> some View {
      VStack {
         HStack(alignment: .center, spacing: 8.0) {
            Text("지금까지의 사유 활동")
               .byCustomFont(.dos, size: 15.0)
               .foregroundStyle(.grayXl)
            Image(.chartPixeledSelected)
               .resizable()
               .frame(width: 14.0, height: 14.0)
               .foregroundStyle(.baseBlack)
            Spacer()
         }
         .padding(.top, 12.0)
         .padding(.leading, 4.0)
         
         Spacer.height(12.0)
         
         VStack(spacing: 16.0) {
            let statistics = sayuChartViewLogic.sayuStatisticItems
            if !statistics.isEmpty {
               ForEach(statistics, id: \.id) { item in
                  HStack(alignment: .center) {
                     Text(item.title)
                        .byCustomFont(.gmMedium, size: 13.0)
                        .foregroundStyle(.grayLg)
                     Spacer()
                     Text(item.content)
                        .byCustomFont(.dos, size: 15.0)
                        .foregroundStyle(.baseBlack)
                  }
                  .padding(.horizontal, 4.0)
               }
            }
         }
         .padding()
         .background(
            RoundedRectangle(cornerRadius: 12.0)
               .fill(.white)
         )
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
   }
   
   private func createSevenDaysChartSection() -> some View {
      VStack {
         HStack(alignment: .center, spacing: 8.0) {
            Text("최근 7일 사유 내역")
               .byCustomFont(.dos, size: 15.0)
               .foregroundStyle(.grayXl)
            Image(.chartPixeledSelected)
               .resizable()
               .frame(width: 14.0, height: 14.0)
               .foregroundStyle(.baseBlack)
            Spacer()
         }
         .padding(.top, 12.0)
         .padding(.leading, 4.0)
         
         Spacer.height(12.0)
         
         VStack(spacing: 16.0) {
            createChartView()
         }
         .padding()
         .background(
            RoundedRectangle(cornerRadius: 12.0)
               .fill(.white)
         )
      }.frame(maxWidth: .infinity, alignment: .topLeading)
   }
   
   private func createChartView() -> some View {
      VStack {
         if sayuChartViewLogic.sayuBarChartAverage == 0 {
            HStack {
               Spacer()
               Text("아직 충분한 사유 데이터가 저장되지 않았어요.")
                  .byCustomFont(.gmMedium, size: 15.0)
                  .lineSpacing(4.0)
                  .frame(maxWidth: .infinity)
               Spacer()
            }
         } else {
            VStack {
               ZStack {
                  RoundedRectangle(cornerRadius: 2.0)
                     .fill(.errorSm.opacity(0.5))
                     .frame(maxWidth: .infinity)
                     .frame(height: 1.0)
                  Text(String(sayuChartViewLogic.sayuBarChartAverage))
                     .byCustomFont(.dos, size: 12.0)
                     .frame(maxWidth: .infinity, alignment: .trailing)
                     .offset(x: 20.0)
               }
               .zIndex(100)
               .offset(y: 84.0)
               HStack(alignment: .bottom) {
                  ForEach(sayuChartViewLogic.sayuBarChartItems, id: \.id) { item in
                     VStack {
                        ZStack(alignment: .bottom) {
                           RoundedRectangle(cornerRadius: 8.0)
                              .fill(.baseYellow)
                              .frame(width: 36.0, height: item.height == 0 ? 10.0 : item.height)
                              .frame(maxHeight: 150.0, alignment: .bottom)
                           if item.figure != 0 {
                              Text(String(item.figure) + "개")
                                 .byCustomFont(.dos, size: 10.0)
                                 .foregroundStyle(.grayXl.opacity(0.8))
                                 .offset(y: -8.0)
                           }
                        }
                        Spacer.height(12.0)
                        Text(item.date)
                           .byCustomFont(.dos, size: 13.0)
                     }
                  }
               }
            }
         }
      }
      .padding(.horizontal, 8.0)
      .padding(.vertical, 4.0)
      .frame(maxWidth: .infinity, alignment: .topLeading)
   }
}
