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
    @State private var handler = AppHandler.getInstance()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(handler)
        }
    }
}


enum DayEnum: Int, CaseIterable, Identifiable {
    case Monday = 1
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    
    var id: Int { self.rawValue }
    
    var fullName: String {
        switch self {
        case .Monday:    return "Poniedz."
        case .Tuesday:   return "Wtorek"
        case .Wednesday: return "Środa"
        case .Thursday:  return "Czwartek"
        case .Friday:    return "Piątek"
        }
    }
    
    var shortName: String {
        switch self {
        case .Monday:    return "Pon"
        case .Tuesday:   return "Wto"
        case .Wednesday: return "Śro"
        case .Thursday:  return "Czw"
        case .Friday:    return "Pią"
        }
    }
}

@MainActor
@Observable
class AppHandler {
    private static let instance: AppHandler = AppHandler()
    
    var tabViewSelection: Int = 0;
    
    var daySelector: DayEnum = .Monday
    var selectedClassId: Int = 0;
    var selectedTeacherId: Int = 0;
    private var timetable: Timetable?
    var classNames: [String] = []
    
    var isLoading: Bool = true
    var loadError: String? = nil
    
    private(set) var classList: ClassList?;
    private(set) var teachersList: TeacherList?;
    var teacherNames: [String] = [];
    
    private(set) var isTeacherModeEnabled: Bool = false;
    var defaultClassId: Int? = nil;
    var defaultTeacherId: Int? = nil;
    
    
    
    var lessons: [[Lesson]] {
        guard let timetable else {
            print("empty timetable");
            return [];
        }
        let dayIndex = daySelector.rawValue - 1
        if dayIndex >= 0 && dayIndex < timetable.lessons.count {
            return timetable.lessons[dayIndex]
        }
        return []
    }
    
    private init() {
        Task { await loadInitialData() }
    }
    
    private func loadInitialData() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }
        classList = await API.instance.getClassList()
        classNames = Array(self.classList?.classes.values ?? Dictionary<Int, String>().values).sorted()
        //selectedClass = String(classNames.first?.prefix(3) ?? "Error")
        selectedClassId = UserDefaults.standard.integer(forKey: "defaultClass")
        teachersList = await API.instance.getTeacherList();
        teacherNames = Array(self.teachersList?.teachers.values ?? Dictionary<Int, String>().values).sorted()
        selectedTeacherId = UserDefaults.standard.integer(forKey: "defaultTeacher")
        
        isTeacherModeEnabled = UserDefaults.standard.bool(forKey: "teacherMode")
        defaultClassId = UserDefaults.standard.integer(forKey: "defaultClass")
        defaultTeacherId = UserDefaults.standard.integer(forKey: "defaultTeacher")
        if (selectedClassId == 0) {
            selectedClassId = self.classList?.classes.first?.key ?? 0
        }
        if (selectedTeacherId == 0) {
            selectedTeacherId = self.teachersList?.teachers.first?.key ?? 0;
        }

        daySelector = DayEnum(rawValue: Calendar.current.component(.weekday, from: Date()) - 1)!


        await loadTimetable()
    }
    
    public static func getInstance() -> AppHandler { instance }
    
    func selectClass(_ classId: Int) async {
        guard classId != selectedClassId else { return }
        isLoading = true
        selectedClassId = classId
        await loadTimetable()
    }
    func selectTeacher(_ teacherId: Int) async {
        guard teacherId != selectedTeacherId else { return }
        isLoading = true;
        selectedTeacherId = teacherId;
        await loadTimetable();
    }
    
    func getTeacherId(_ teacher: String) -> Int? {
        return self.teachersList?.teachers.first(where: { $0.value == teacher})?.key;
    }
    func reload() async {
        isLoading = true
        await loadTimetable()
    }
    func getClassName(classId: Int) -> String? {
        return self.classList?.classes.first(where: {$0.key == classId})?.value ?? "N/A";
    }
    func getShortClassName(classId: Int) -> String? {
        let fullClassName: String? = getClassName(classId: classId)
        guard fullClassName != "N/A" else { return "N/A" }
        return String(
            fullClassName?.split(separator: " (", maxSplits: 1).first ?? "N/A"
        )
    }
    func getClassId(className: String) -> Int? {
        return self.classList?.classes.first(where: {$0.value == className})?.key
    }
    func getTeacherShortName(teacherId: Int) -> String? {
        return self.teachersList?.teachers.first(where: {$0.key == teacherId})?.value;
    }
    func getTeacherName(teacherID: Int) -> String? {
        return self.teachersList?.teachers.first(where: {$0.key == teacherID})?.value;
    }
    func setTecherMode(_ val: Bool) async {
        
        self.isTeacherModeEnabled = val;
            self.isLoading = true;
            await loadTimetable();
        // save to user defaults
        UserDefaults.standard.set(isTeacherModeEnabled, forKey: "teacherMode")
        
    }
    func setDefaultClass(classId: Int) {
        self.defaultClassId = classId;
        // save to user defaults
        UserDefaults.standard.set(classId, forKey: "defaultClass")
    }
    func setDefaultTeacher(teacherId: Int) {
        self.defaultTeacherId = teacherId;
        // save to user defaults
        UserDefaults.standard.set(teacherId, forKey: "defaultTeacher")
    }
    
    private func loadTimetable() async {
        if (!isTeacherModeEnabled) {
            timetable = await API.instance.getTimetable(classname: self.getShortClassName(classId: selectedClassId) ?? "error")
        } else {
            timetable = await API.instance.getTimetable(teacherName: self.getTeacherShortName(teacherId: selectedTeacherId) ?? "error")
        }
        isLoading = false
    }
}
