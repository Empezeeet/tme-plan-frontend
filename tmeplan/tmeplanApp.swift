//
//  tmeplanApp.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 24/05/2026.
//

import SwiftUI
import SwiftData

@main
struct tmeplanApp: App {
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
enum DayEnum: Int {
    case Monday = 1
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    
}
@MainActor
@Observable
class AppHandler {
    private static let instance: AppHandler = AppHandler();
     public var daySelector: DayEnum = .Monday;
     private var selectedClass: String = "";
    
     private var timetable: Timetable?;
     private var lessons: [[Lesson]] = [];
     private var classNames: [String] = []
    
    
     public var isLoading: Bool;
     private var loadError: String?;
    
    
    private init() {
        isLoading = true;
        loadError = nil;
        Task { @MainActor in
            
            defer { isLoading = false }
            self.classNames = await API.instance.getClassnames();
            self.selectedClass = self.classNames.first!;
            
            self.timetable = await API.instance.getTimetable(classname: self.selectedClass);
            if (timetable != nil) {
                self.lessons = self.timetable!.lessons[self.daySelector.rawValue-1];
            }
            
            
        }
        
    }
    public static func getInstance() -> AppHandler { return self.instance; }
    
    public func getSelectedClass() -> String { return self.selectedClass; }
    
    public func setSelectedClass(_ className: String) {
        self.selectedClass = className;
        
        // update timetable
        self.updateTimetable();
        self.updateLessons();
        
    }
    
    public func getClassNames() -> [String] { return self.classNames; }
    private func updateTimetable() -> Void {
        Task {
            self.timetable = await API.instance.getTimetable(classname: self.selectedClass);
        }
    }
    public func getTimetable() async -> Timetable? {
       
        self.updateTimetable()
        return self.timetable;
    }
    public func updateLessons() -> Void {
        Task {
            self.lessons = self.timetable!.lessons[self.daySelector.rawValue-1];
        }
    }
    public func getLessons() -> [[Lesson]] { return self.lessons; }
    
}

