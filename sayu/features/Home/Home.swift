//
//  Home.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct Home: View {
   var body: some View {
      VStack {
         Image(systemName: "globe")
            .imageScale(.large)
            .foregroundStyle(.tint)
         Text("Hello, world!")
      }
      .padding()
   }
}

#Preview {
   Home()
}
