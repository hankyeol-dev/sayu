//
//  WriteSayuOn.swift
//  sayu
//
//  Created by 강한결 on 9/19/24.
//

import SwiftUI

import MijickNavigationView
import MijickPopupView
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
         if let sayu = viewLogic.sayu{
            AppNavbar(title: "\(viewLogic.sayuDate)의 사유", isLeftButton: false, isRightButton: false)
            
            ScrollView {
               VStack {
                  if sayu.timerType == SayuTimerType.timer.rawValue {
                     createTimerView()
                  }
                  
                  if sayu.timerType == SayuTimerType.stopWatch.rawValue {
                     createStopwatchView()
                  }
                  
                  // 서브 내용 작성 뷰
                  createSayuSubView()
               }
               .padding(.horizontal, 16.0)
            }
            
            Button {

            } label: {
               asRoundedRect(
                  title: "사유 저장 하기",
                  radius: 8.0,
                  background: .baseGreen,
                  foreground: .white,
                  fontSize: 16.0,
                  font: .gmMedium)
            }
            .padding()
            .background(.graySm)
            
         } else { EmptyView() }
      }
      .task {
         viewLogic.setSayu(for: createdSayuId)
      }
      
   }
}

// MARK: - timer & stopwatch
extension WriteSayuOn {
   private func createTimerView() -> some View {
      VStack(spacing: 15.0) {
         ZStack {
            Circle()
               .trim(from: 0.0, to: viewLogic.sayuTimerProgress)
               .stroke(.baseGreen, lineWidth: 10.0)
            
            GeometryReader { proxy in
               let size = proxy.size
               Circle()
                  .fill(.baseGreen)
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
            Text(viewLogic.sayuSettingTime.convertTimeToString())
               .byCustomFont(.gmBold, size: 44.0)
               .foregroundStyle(.baseBlack)
               .rotationEffect(.init(degrees: 90.0))
         }
         .padding(12.0)
         .frame(height: 320)
         .rotationEffect(.init(degrees: -90))
         .animation(.easeInOut, value: viewLogic.sayuTimerProgress)
         
         createTimerButtonSet()
         
         Spacer()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      .padding(.top, 12.0)
      .background(.white)
      .clipShape(.rect(cornerRadius: 12.0))
      .shadow(color: .grayMd, radius: 1.2, y: 0.3)
      .onChange(of: scenePhase) { phaseStatus in
         if !viewLogic.isPaused {
            if phaseStatus == .background {
               viewLogic.isActiveLastTimeStamp = .init()
            }
            
            if phaseStatus == .active {
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
                     .fill(.baseGreen)
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
   
   private func createStopwatchView() -> some View {
      VStack {
         Spacer.height(12.0)
         
         HStack {
            Spacer()
            Text(viewLogic.sayuSettingTime.convertTimeToString())
               .byCustomFont(.gmBold, size: 56.0)
               .foregroundStyle(.baseBlack)
            Spacer()
         }
         
         Spacer.height(20.0)
         
         HStack {
            let isPaused = viewLogic.isPaused
            
            Button {
               withAnimation(.snappy) {
                  if isPaused {
                     viewLogic.startStopwatch()
                  } else {
                     viewLogic.pauseTimer()
                  }
               }
            } label: {
               asRoundedRect(
                  title: isPaused ? "다시 사유하기" : "잠시 멈추기",
                  radius: 8.0,
                  background: isPaused ? .baseGreen : .grayMd,
                  foreground: isPaused ? .white : .grayXl,
                  height: 48.0,
                  fontSize: 16.0,
                  font: .gmMedium)
            }
            
            Button {
               viewLogic.pauseTimer()
               displayStopConfirmAlert()
            } label: {
               asRoundedRect(
                  title: "완전 멈추기",
                  radius: 8.0,
                  background: .grayXl,
                  foreground: .white,
                  height: 48.0,
                  fontSize: 16.0,
                  font: .gmMedium)
            }
         }
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(.white)
      .clipShape(.rect(cornerRadius: 12.0))
      .shadow(color: .grayMd, radius: 1.2, y: 0.3)
      .onChange(of: scenePhase) { phaseStatus in
         if !viewLogic.isPaused {
            if phaseStatus == .background {
               viewLogic.isActiveLastTimeStamp = .init()
            }
            
            if phaseStatus == .active {
               let difference = Date().timeIntervalSince(viewLogic.isActiveLastTimeStamp)
               viewLogic.sayuSettingTime += Int(difference)
            }
         }
      }
   }
   
   private func displayStopConfirmAlert() {
      let buttons: [BottomPopupButtonItem] = [
         .init(title: "안 멈출게요", background: .grayMd, foreground: .grayXl, action: {
            viewLogic.startStopwatch()
            dismiss()
         }),
         .init(title: "네 멈출게요", background: .grayXl, foreground: .grayMd, action: {
            viewLogic.stopTimer()
            dismiss()
         })
      ]
      BottomAlert(title: "사유 시간을 멈춰요", 
                  content: "지금까지 흘러간 사유 시간을 초기화 할 수 있습니다.\n측정한 시간은 임시 저장됩니다.",
                  buttons: buttons)
      .showAndStack()
   }
}

extension WriteSayuOn {
   private func createSayuSubView() -> some View {
      SayuSubCreator(subItems: $viewLogic.sayuSubs, isAddMode: false, contentMode: true)
   }
}
