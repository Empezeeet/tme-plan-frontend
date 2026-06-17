//
//  TeacherTimetableView.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 17/06/2026.
//

import SwiftUI

struct TeacherTimetableView: View {
    @Environment(AppHandler.self) private var handler
    
    var body: some View {
        NavigationStack {
            TeacherTimetableContent(handler: handler)
                .navigationTitle(handler.getTeacherName(teacherID: handler.selectedTeacherId) ?? "Nauczyciel")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        TeacherSelectionMenu(handler: handler)
                        
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        SettingsMenu(handler: handler)
                    }
                }
        }
    }
}

private struct SettingsMenu: View {
    let handler: AppHandler
    
    public var body: some View {
        Menu {
            Button {
                Task {
                    await handler.setTecherMode(!handler.isTeacherModeEnabled)
                    if (handler.isTeacherModeEnabled) {
                        handler.tabViewSelection = 1;
                    } else {
                        handler.tabViewSelection = 0;
                    }
                }
               
            } label: {
                if handler.isTeacherModeEnabled {
                    Text("Wyłącz tryb nauczyciela")
                } else {
                    Text("Włącz tryb nauczyciela")
                }
            }
            Button {
                if (handler.defaultTeacherId == nil || handler.defaultTeacherId != handler.selectedTeacherId) {
                    handler.setDefaultTeacher(teacherId: handler.selectedTeacherId)
                }
            } label: {
                // set default teacher
                if (handler.defaultTeacherId == nil || handler.defaultTeacherId != handler.selectedTeacherId) {
                    Text("Ustaw domyślnego nauczyciela")
                } else {
                    Text("Ustawiono domyślnego nauczyciela")
                }
            }
        } label: {
            Image(systemName: "gear")
        }
    }
}
private struct TeacherTimetableContent: View {
    let handler: AppHandler
    
    var body: some View {
        VStack {
            DayPicker(handler: handler)
            
            if handler.lessons.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Text("Brak lekcji do wyświetlenia.")
                    Button {
                        Task { await handler.reload() }
                    } label: {
                        Label("Odśwież", systemImage: "arrow.circlepath")
                    }
                }
                Spacer()
            } else {
                // if no lessons at current day, show that there are no lessons
                LessonList(lessons: handler.lessons)
            }
        }
        
    }
}

private struct DayPicker: View {
    @Bindable var handler: AppHandler
    
    public var body: some View {
        HStack {
            Spacer()
            Picker("Dzień", selection: Binding(
                get: { handler.daySelector },
                set: { handler.daySelector = $0 }
            )) {
                Text("pon").tag(DayEnum.Monday)
                Text("wt").tag(DayEnum.Tuesday)
                Text("sr").tag(DayEnum.Wednesday)
                Text("cz").tag(DayEnum.Thursday)
                Text("pt").tag(DayEnum.Friday)
            }
            .pickerStyle(.segmented)
            Spacer()
        }
        .padding(.horizontal)
    }
}

private struct TeacherSelectionMenu: View {
    let handler: AppHandler
    
    var body: some View {
        Menu {
            ForEach(handler.teacherNames, id: \.self) { teacher in
                Button {
                    Task { await handler.selectTeacher(handler.getTeacherId(teacher) ?? 0)}
                } label: {
                    Text(teacher)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }
}

private struct LessonList: View {
    let lessons: [[Lesson]]
    
    var body: some View {
        if (lessons.filter { !$0.isEmpty }.isEmpty) {
            VStack {
                Spacer()
                VStack(spacing: 12) {
                    Text("Brak lekcji dzisiaj 😁").foregroundStyle(.gray)
                }
                Spacer()
            }
            
        } else {
            List(lessons.filter { !$0.isEmpty }, id: \.self) { lessonBlock in
                LessonBlockView(l: lessonBlock)
            }
        }
        
    }
}

#Preview {
    TeacherTimetableView()
}
