//
//  LessonBlockView.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 31/05/2026.
//

import SwiftUI
extension View {
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
         if conditional {
             return AnyView(content(self))
         } else {
             return AnyView(self)
         }
     }
}
struct LessonBlockView: View {
    let lesson: [Lesson];
    let light: Bool;
    let currentTime: String;
    init(l: [Lesson]) {
        self.lesson = l;
        self.currentTime = Date().formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits));
        
        
        self.light = lesson[0].start_time < self.currentTime && self.currentTime < lesson[0].end_time;
       
        print(lesson[0])
       
    }
    
    var body: some View {
        if (lesson.count == 1) {
            normalbody
        } else if (lesson.count == 2) {
            doublebody
        }
    }
    
    var normalbody: some View {
        HStack {
            Spacer()
            VStack {
                HStack {
                    Spacer()
                    Text("\(lesson[0].start_time) - \(lesson[0].end_time)").foregroundStyle(.gray).if(light, content: {
                        $0.foregroundStyle(.white).bold(true)
                    })
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text(lesson[0].subject).padding(3).if(light, content: {
                        $0.bold(true)
                    })
                    Spacer()
                }
                if(lesson[0].group != nil) {
                    HStack {
                        Text(lesson[0].group!).fontWeight(.light).foregroundStyle(Color.gray)
                        Spacer()
                        Text(lesson[0].classroom).fontWeight(.light).foregroundStyle(Color.gray)
                        
                    }
                }
                else {
                    HStack {
                        Text("")
                        Spacer()
                        Text(lesson[0].classroom).fontWeight(.light).foregroundStyle(Color.gray)
                        Spacer()
                        Text("")
                    }
                }
                
            }
            Spacer()
        }.if(light, content: {
            $0.padding().listRowBackground(Color.white.opacity(0.15))
        })
    }
    var doublebody: some View {
        VStack {
            HStack {
                Text(lesson[0].group!)
                Spacer()
                Text("\(lesson[0].start_time) - \(lesson[0].end_time)").foregroundStyle(Color.gray)
                Spacer()
                Text(lesson[1].group!)
            }
            HStack {
                ForEach(lesson, id: \.self) { l in
                    VStack {
                        HStack {
                            Spacer()
                            Text(l.subject_short)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Text(l.classroom).fontWeight(.light).foregroundStyle(Color.gray)
                            Spacer()
                        }
                    }
                    if (l != lesson[1]) {
                        Divider()

                    }
                }
            }
        }
    }
}

