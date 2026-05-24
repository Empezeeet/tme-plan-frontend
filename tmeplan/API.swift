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
    var teacher: String;
    var classroom: String;
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

class API {
    static public let instance: API = .init();
    private let baseURL: String = "http://127.0.0.1:8000/"
    private let days: [String] = ["Pn", "Wt", "Sr", "Czw", "Pt"]
    private init() {
        
    }
    public func getClassnames() async -> [String] {
        return ["4Tp"]
    }
    public func getTimetable(classname: String) async -> Timetable? {
        var timetable: Timetable = Timetable();
        
        for i in 0..<5 {
            guard let day = await self.getDay(classname: classname, day: UInt8(i)) else {
                return nil;
            }
            timetable.lessons.append(day.lessons);
        }
        return timetable;
        
        
    }
    public func getDay(classname: String, day: UInt8) async -> Day? {
        if day > 4 {
            return nil;
        }
        
        var res: Day? = nil;
            var components = URLComponents(string: baseURL + "timetable/\(self.days[Int(day)])")
            
            components?.queryItems = [
                URLQueryItem(name: "className", value: classname)
            ]
            
            guard let url = components?.url else {
                return nil;
            }
            
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return nil;
                }
                
                let decoder = JSONDecoder()
                
                res = try decoder.decode(Day.self, from: data)
            } catch { return nil}
                
                   
        return res;
        
        
    }
}
