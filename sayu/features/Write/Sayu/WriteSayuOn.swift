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
   
   init(createdSayuId: ObjectId) {
      self.createdSayuId = createdSayuId
   }
   
   var body: some View {
      VStack {
         if let sayu = viewLogic.sayu {
            AppNavbar(title: "\(viewLogic.sayuDate)의 사유", isLeftButton: false, isRightButton: false)
            
            ScrollView {
               
            }
            
         } else { EmptyView() }
      }
      .task {
         viewLogic.setSayu(for: createdSayuId)
      }
   }
}

//#Preview {
//    WriteSayuOn()
//}
