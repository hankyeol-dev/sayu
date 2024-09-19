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
   
   init(createdSayuId: ObjectId) {
      self.createdSayuId = createdSayuId
      print(createdSayuId)
   }
   
   
   func configure(view: NavigationConfig) -> NavigationConfig {
      view.navigationBackGesture(.drag)
   }
   
   var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
   }
}

//#Preview {
//    WriteSayuOn()
//}
