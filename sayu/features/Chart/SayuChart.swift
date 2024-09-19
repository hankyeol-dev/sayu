//
//  SayuChart.swift
//  sayu
//
//  Created by 강한결 on 9/17/24.
//

import SwiftUI

struct SayuChart: View {
   var body: some View {
      VStack {
         Text("여기는 사유 차트를 관장하고 유저 데이터를 확인할 뷰가 올거에요~")
            .byCustomFont(.kjcRegular, size: 22)         
      }
   }
}

#Preview {
   SayuChart()
}
