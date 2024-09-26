//
//  BottomAddTimerTimeAlert.swift
//  sayu
//
//  Created by 강한결 on 9/26/24.
//

import SwiftUI

import MijickPopupView

struct BottomAddTimerTimeAlert: BottomPopup {
   @State
   var sayuTime: SayuTime = .init(hours: 0, minutes: 0, seconds: 0)
   
   private var confirmHandler: (SayuTime) -> Void
   
   init(confirmHandler: @escaping (SayuTime) -> Void) {
      self.confirmHandler = confirmHandler
   }
   
   func createContent() -> some View {
      VStack {
         Text("사유 시간 추가")
            .byCustomFont(.gmMedium, size: 16.0)
            .padding(.top, 12.0)
         Spacer.height(16.0)
         
         HStack {
            Picker("시", selection: $sayuTime.hours) {
               ForEach(0..<3) { Text("\($0) 시") }
            }
            
            Picker("분", selection: $sayuTime.minutes) {
               ForEach(0..<60) { Text("\($0) 분") }
            }
            
            Picker("초", selection: $sayuTime.seconds) {
               ForEach(0..<60) { Text("\($0) 초") }
            }
         }
         .labelStyle(.titleOnly)
         .pickerStyle(.inline)
         .frame(maxHeight: 80)
         Spacer.height(16.0)
         
         Button {
            confirmHandler(sayuTime)
         } label: {
            asRoundedRect(
               title: "시간 추가하기",
               radius: 8.0,
               background: checkIsSettingTime() ? .baseGreen : .grayMd,
               foreground: checkIsSettingTime() ? .white : .grayXl,
               height: 48.0,
               fontSize: 15.0,
               font: .gmMedium)
         }
         .disabled(!checkIsSettingTime())
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.vertical, 12.0)
      .padding(.horizontal, 16.0)
      .background(.white)
      .clipShape(.rect(cornerRadius: 16.0))
   }
   
   private func checkIsSettingTime() -> Bool {
      return !(sayuTime.hours == 0 && sayuTime.minutes == 0 && sayuTime.seconds == 0)
   }
}
