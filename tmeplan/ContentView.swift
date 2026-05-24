//
//  ContentView.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 24/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State var tabviewselection: Int = 0;
   
    
    var body: some View {
        TabView(selection: $tabviewselection) {
            Tab("Timetable", systemImage: "tablecells", value: 0) {
                TimetableView()
            }
//            Tab("Substitution", systemImage: "person.3.sequence.fill", value: 1) {
//                
//            }
        }
    }
}
#Preview {
    ContentView()
}
