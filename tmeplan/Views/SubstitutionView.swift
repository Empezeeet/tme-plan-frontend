//
//  SubstitutionView.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 08/06/2026.
//

import SwiftUI
private struct DayPicker: View {
    @Bindable var handler: AppHandler
    
    public var body: some View {
        HStack {
            Spacer()
            Picker("Dzień", selection: Binding(
                get: { handler.daySelector },
                set: { handler.daySelector = $0 }
            )) {
             
                ForEach(DayEnum.allCases) { day in
                    Text(day == handler.daySelector ? day.fullName : day.shortName)
                        .tag(day)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            .pickerStyle(.segmented)
            Spacer()
        }
        .padding(.horizontal)
    }
}
private struct ClassMenu: View {
    let handler: AppHandler
    
    var body: some View {
        Menu {
            ForEach(handler.classNames, id: \.self) { classname in
                Button {
                    Task { await handler.selectClass(handler.getClassId(className: classname) ?? 0) }
                } label: {
                    Text(classname)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease")
        }
    }
}
private struct SettingsMenu: View {
    let handler: AppHandler
    
    public var body: some View {
        Menu {
            Button {
                Task {
                    await handler.setTecherMode(!handler.isTeacherModeEnabled);
                }
                
            } label: {
                if handler.isTeacherModeEnabled {
                    Text("Wyłącz tryb nauczyciela")
                } else {
                    Text("Włącz tryb nauczyciela")
                }
            }
            Button {
                if (handler.selectedClassId != handler.defaultClassId) {
                    handler.setDefaultClass(classId: handler.selectedClassId)
                }
            } label: {
                // set default class
                if (handler.selectedClassId == handler.defaultClassId) {
                    Text("Ustawiono jako domyślną klasę")
                } else {
                    Text("Ustaw jako domyślną klasę")
                }
            }
        } label: {
            Image(systemName: "gear")
        }
    }
}
struct SubstitionsListView: View {
    @Environment(AppHandler.self) private var handler;
    init() {
        //
    }
    var body: some View {
        Text("plae")
    }
}
// MAIN
struct SubstitutionView: View {
    @Environment(AppHandler.self) private var handler
    
    var body: some View {
        NavigationStack {
            VStack {
                DayPicker(handler: self.handler)
                SubstitionsListView()
                
            }
                .navigationTitle(handler.getShortClassName(classId: handler.selectedClassId) ?? "Error")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        ClassMenu(handler: handler)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        SettingsMenu(handler: handler)
                    }
                }
        }
    }
}

#Preview {
    SubstitutionView()
}
