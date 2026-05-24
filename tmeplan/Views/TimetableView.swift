//
//  TimetableView.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 24/05/2026.
//

import SwiftUI

struct TimetableView: View {
    
    @State private var isLoading: Bool = false
    @State private var loadError: String?
    @State var handler: AppHandler = AppHandler.getInstance()
    
    @MainActor
    func loadData() async -> Void {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        
    }
    
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        Picker(selection: $handler.daySelector) {
                            Text("pon").tag(DayEnum.Monday)
                            Text("wt").tag(DayEnum.Tuesday)
                            Text("sr").tag(DayEnum.Wednesday)
                            Text("cz").tag(DayEnum.Thursday)
                            Text("pt").tag(DayEnum.Friday)
                        } label: {
                            Text("picker")
                        }
                        .pickerStyle(.segmented)
                        Spacer()
                    }
                    
                    if handler.isLoading {
                        Spacer()
                        ProgressView("Wczytywanie…")
                        Spacer()
                    } else if let loadError {
                        Spacer()
                        VStack(spacing: 12) {
                            Text(loadError)
                            Button {
                                Task { await loadData() }
                            } label: {
                                Label("Spróbuj ponownie", systemImage: "arrow.circlepath")
                            }
                        }
                        Spacer()
                    } else if handler.getLessons().isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Text("Brak lekcji do wyświetlenia.")
                            Button {
                                Task { await loadData() }
                            } label: {
                                Label("Odśwież", systemImage: "arrow.circlepath")
                            }
                        }
                        Spacer()
                    } else {
                        List(AppHandler.getInstance().getLessons().filter({$0.isEmpty == false}), id: \.self)  { lesson in
                            if (!lesson.isEmpty) {
                                LessonBlockView(l: lesson)
                            }
                            
                            
                        }
                    }
                    
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Menu {
                            ForEach(handler.getClassNames(), id: \.self) { classname in
                                Button {
                                    handler.setSelectedClass(classname);
                                } label: {
                                    Text(classname)
                                }
                            }
                        }
                         label: {
                            Image(systemName: "line.3.horizontal.decrease")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.right")
                        }
                    }
                    ToolbarItem(placement:.topBarTrailing) {
                        Button {
                            
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.left")
                        }
                    }
                   
                }.navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("29.11 - 6.12 ") // TODO: fix
                    .onChange(of: AppHandler.getInstance().daySelector, {
                        AppHandler.getInstance().updateLessons();
                    })
            }
        }

    }
}

