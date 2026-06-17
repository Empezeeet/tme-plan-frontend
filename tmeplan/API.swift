//
//  API.swift
//  tmeplan
//
//  Created by Mateusz Pawełko on 31/05/2026.
//

import Foundation


struct Lesson: Codable, Hashable {
    var subject: String;
    var subject_short: String;
    var day: String;
    var start_time: String;
    var slot_count: Int;
    var group: String?;
    var className: String?;
    var teacher: String?;
    var classroom: String?;
    var end_time: String;
}


class Day: Codable {
    var times: [[String]]?
    var lessons: [[Lesson]]
    init(lessons: [[Lesson]]) {
        self.lessons = lessons;
    }
}

class Timetable: Codable {
    var times: [[String]]? = []
    var groups: [String] = []
    var lessons: [[[Lesson]]] = []
}
class ClassList: Codable {
    var num: String;
    var classes: Dictionary<Int, String>
}
class TeacherList: Codable {
    var num: String;
    var teachers: Dictionary<Int, String>
}

class API {
    static public let instance: API = .init();
    private let baseURL: String = "http://127.0.0.1:8000/"
    private let days: [String] = ["Pn", "Wt", "Sr", "Czw", "Pt"]
    private init() {
        
    }
    public func getTeacherList() async -> TeacherList? {
        var res: TeacherList? = nil;
        
        var components = URLComponents(string: baseURL + "teachers")
        guard let url = components?.url else {
            print("Error1");
            return nil;
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error2");
                return nil;
            }
            res = try JSONDecoder().decode(TeacherList.self, from: data)
            
        } catch { print("Error3: \(error)"); return nil; }
        
        
        return res;
    }
    
    
    public func getClassList() async -> ClassList? {
        var res: ClassList? = nil;
        
        var components = URLComponents(string: baseURL + "classes")
        guard let url = components?.url else {
            print("Error1");
            return nil;
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error2");
                return nil;
            }
            res = try JSONDecoder().decode(ClassList.self, from: data)
            
        } catch { print("Error3: \(error)"); return nil; }
        
        
        return res;
    }
    public func getClassnames() async -> [String] {
        return Array(await getClassList()?.classes.values ?? Dictionary<Int, String>().values).sorted();
    }
    public func getTimetable(teacherName: String) async -> Timetable? {
        let timetable: Timetable = Timetable();
        for i in 0..<5 {
            guard let day = await self.getDay(teacherName: teacherName, day: UInt8(i)) else {
                print("empty day")
                return nil;
            }
            timetable.lessons.append(day.lessons);
        }
        return timetable;
    }
    public func getTimetable(classname: String) async -> Timetable? {
        let timetable: Timetable = Timetable();
        
        for i in 0..<5 {
            guard let day = await self.getDay(classname: classname, day: UInt8(i)) else {
                print("empty day")
                return nil;
            }
            timetable.lessons.append(day.lessons);
        }
        return timetable;
        
        
    }
    public func getDay(teacherName: String, day: UInt8) async -> Day? {
        if (day > 4) {
            return nil;
        }
        var res: Day? = nil;
        var components = URLComponents(string: baseURL + "timetable/\(self.days[Int(day)])")
        components?.queryItems = [
            URLQueryItem(name: "teacherName", value: teacherName.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: "").removingPolishLetters().lowercased())
        ]
        guard let url = components?.url else {
            return nil;
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url);
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...399).contains(httpResponse.statusCode) else {
                return nil;
            }
            res = try JSONDecoder().decode(Day.self, from: data)
        } catch {
            print("error: \(error)")
            return nil;
        }
        return res;
        
    }
    public func getDay(classname: String, day: UInt8) async -> Day? {
        if day > 4 {
            print("day \(day) out of range")
            return nil;
        }
        
        var res: Day? = nil;
            var components = URLComponents(string: baseURL + "timetable/\(self.days[Int(day)])")
            
            components?.queryItems = [
                URLQueryItem(name: "className", value: classname)
            ]
            
            guard let url = components?.url else {
                print("bad components @ getDay")
                return nil;
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error code @ getDay")
                    return nil;
                }
                
                let decoder = JSONDecoder()
                
                res = try decoder.decode(Day.self, from: data)
            } catch {
                print("Error decoding @ getDay \(error)")
                print("")
                return nil
            }
                
                   
        return res;
        
        
    }
}
extension String {
    func removingPolishLetters() -> String {
        let polishReplacements: [Character: Character] = [
            "ą": "a", "ć": "c", "ę": "e", "ł": "l", "ń": "n", "ó": "o", "ś": "s", "ź": "z", "ż": "z",
            "Ą": "A", "Ć": "C", "Ę": "E", "Ł": "L", "Ń": "N", "Ó": "O", "Ś": "S", "Ź": "Z", "Ż": "Z"
        ]
        
     
        return String(self.map { polishReplacements[$0] ?? $0 })
    }
}
