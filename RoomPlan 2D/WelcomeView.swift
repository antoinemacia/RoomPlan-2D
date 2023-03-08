//
//  WelcomeView.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 24/02/2023.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "house")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            Text("RoomPlan 2D")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .fontWeight(.bold)
            Text("Scan your room and create a 2D map.")
            
            Spacer()
                .frame(height: 50)
            
            NavigationLink("Start Scanning") {
                RoomCaptureScanView()
            }
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WelcomeView()
        }
    }
}
