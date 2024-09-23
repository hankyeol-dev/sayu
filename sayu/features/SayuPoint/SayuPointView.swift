//
//  SayuPointView.swift
//  sayu
//
//  Created by 강한결 on 9/23/24.
//

import SwiftUI
import MijickNavigationView

struct SayuPointView: NavigatableView {
   
   func configure(view: NavigationConfig) -> NavigationConfig {
      view.navigationBackGesture(.drag)
   }
   var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
   }
}
