//
//  ContentView.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 24/05/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppHandler.self) private var handler

    
    var body: some View {
        TabView(selection: Binding(
            get: { handler.tabViewSelection },
            set: { handler.tabViewSelection = $0 }
        )) {
            if (handler.isTeacherModeEnabled) {
                Tab("Plan lekcji (Nauczyciel)", systemImage: "tablecells", value: 0) {
                    TeacherTimetableView()
                }
            } else {
                Tab("Plan lekcji", systemImage: "tablecells", value: 0) {
                    TimetableView()
                }
            }
            
//            Tab("Substitution", systemImage: "person.3.sequence.fill", value: 2) {
//
//            }
        }
    }
}
#Preview {
    ContentView()
}
