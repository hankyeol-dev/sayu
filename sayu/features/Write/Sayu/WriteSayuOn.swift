//
//  WriteSayuOn.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import SwiftUI

import MijickNavigationView
import RealmSwift

struct WriteSayuOn: NavigatableView {
   
   private var createdSayuId: ObjectId
   
   @StateObject
   private var viewLogic: WriteSayuOnViewLogic = .init()
   
   @Environment(\.scenePhase)
   private var scenePhase
   
   init(createdSayuId: ObjectId) {
      self.createdSayuId = createdSayuId
   }
   
   var body: some View {
      VStack {
         if viewLogic.sayu != nil {
            AppNavbar(title: "\(viewLogic.sayuDate)의 사유", isLeftButton: false, isRightButton: false)
            
            ScrollView {
               VStack {
                  GeometryReader { proxy in
                     VStack(spacing: 15.0) {
                        ZStack {
                           
                           Circle()
                              .stroke(.baseGreenSm.opacity(0.2), lineWidth: 36.0)
                           
                           Circle()
                              .fill(.baseBlack)
                           
                           Circle()
                              .trim(from: 0.0, to: viewLogic.sayuTimerProgress)
                              .stroke(.baseGreen, lineWidth: 10.0)
                           
                           GeometryReader { proxy in
                              let size = proxy.size
                              
                              Circle()
                                 .fill(.baseGreenLg)
                                 .frame(width: 24, height: 24)
                                 .overlay {
                                    Circle()
                                       .fill(.baseGreenSm)
                                       .padding(4.0)
                                 }
                                 .frame(width: size.width, height: size.height, alignment: .center)
                                 .offset(x: size.height / 2)
                                 .rotationEffect(.init(degrees: viewLogic.sayuTimerProgress * 360))
                           }
                           
                           // 타이머 타임
                           
                           Text(viewLogic.sayuSettingTime.convertTimeToString())
                              .byCustomFont(.gmMedium, size: 24.0)
                              .foregroundStyle(.white)
                              .rotationEffect(.init(degrees: 90.0))
                              .animation(.easeInOut, value: viewLogic.sayuTimerProgress)
                           
                           
                        }
                        .padding(36.0)
                        .frame(height: proxy.size.width)
                        .rotationEffect(.init(degrees: -90))
                        .animation(.easeInOut, value: viewLogic.sayuTimerProgress)
                        
                        createTimerButtonSet()
                     }
                     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                  }
               }
               .padding(.all, 16.0)
               .background(.baseBlack)
               .frame(height: 450)
            }
            
         } else { EmptyView() }
      }
      .task {
         viewLogic.setSayu(for: createdSayuId)
      }
      .onChange(of: scenePhase) { phaseStatus in
         if !viewLogic.isPaused {
            // 1. 돌아가고 있는 상태인데,
            if phaseStatus == .background {
               // 2. background 전환이 된다면,
               viewLogic.isActiveLastTimeStamp = .init()
            }
            
            if phaseStatus == .active {
               // 3. 다시 active 상태로 전환된다면,
               let difference = Date().timeIntervalSince(viewLogic.isActiveLastTimeStamp)
               if (viewLogic.sayuSettingTime - Int(difference)) <= 0 {
                  viewLogic.isPaused = true
                  viewLogic.isStopped = true
                  viewLogic.sayuSettingTime = 0
                  viewLogic.sayuTimerProgress = 1.0
               } else {
                  viewLogic.sayuSettingTime -= Int(difference)
               }
            }
         }
      }
   }
}

extension WriteSayuOn {
   @ViewBuilder
   private func createTimerButtonSet() -> some View {
      HStack {
         Spacer()
         Button {
            if viewLogic.isPaused {
               viewLogic.startTimer()
            } else {
               viewLogic.pauseTimer()
            }
         } label: {
            Image(systemName: viewLogic.isPaused ? "play.fill" : "pause" )
               .font(.title3.bold())
               .foregroundStyle(.white)
               .frame(width: 48, height: 48)
               .background(
                  Circle()
                     .fill(.baseGreenLg)
               )
         }
         
         Spacer.width(36.0)
         
         Button {
            viewLogic.stopTimer()
            UNUserNotificationCenter
               .current()
               .removeAllPendingNotificationRequests()
         } label: {
            Image(systemName: "square.fill")
               .font(.title3.bold())
               .foregroundStyle(.white)
               .frame(width: 48.0, height: 48.0)
               .background(Circle().fill(.grayXl))
         }
         Spacer()
      }
      .frame(maxWidth: .infinity)
   }
}
