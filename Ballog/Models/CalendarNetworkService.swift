import Foundation
import SwiftUI

// MARK: - Calendar API Models
struct CalendarMonthResponse: Codable {
    let year: Int
    let month: Int
    let monthName: String
    let weeks: [CalendarWeek]
    let totalWeeks: Int
    let holidays: [Int]
    
    enum CodingKeys: String, CodingKey {
        case year, month, monthName = "month_name", weeks, totalWeeks = "total_weeks", holidays
    }
}

struct CalendarWeek: Codable {
    let weekNumber: Int
    let days: [CalendarDay]
    
    enum CodingKeys: String, CodingKey {
        case weekNumber = "week_number", days
    }
}

struct CalendarDay: Codable {
    let date: String
    let day: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let weekday: Int
    
    enum CodingKeys: String, CodingKey {
        case date, day, isCurrentMonth = "is_current_month", isToday = "is_today", weekday
    }
}

struct NetworkCalendarEvent: Codable {
    let id: Int
    let title: String
    let date: String
    let type: String
    let description: String
}

struct WeekOfMonthResponse: Codable {
    let year: Int
    let month: Int
    let day: Int
    let weekNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case year, month, day, weekNumber = "week_number"
    }
}

// MARK: - Calendar Network Service
class CalendarNetworkService: ObservableObject {
    private let baseURL = "http://localhost:5000/api/calendar"
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func getMonthCalendar(year: Int, month: Int) async -> CalendarMonthResponse? {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/month/\(year)/\(month)") else {
            errorMessage = "잘못된 URL입니다"
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "서버 응답 오류"
                return nil
            }
            
            let calendarResponse = try JSONDecoder().decode(CalendarMonthResponse.self, from: data)
            return calendarResponse
        } catch {
            errorMessage = "네트워크 오류: \(error.localizedDescription)"
            return nil
        }
    }
    
    func getWeekOfMonth(year: Int, month: Int, day: Int) async -> WeekOfMonthResponse? {
        guard let url = URL(string: "\(baseURL)/week-of-month/\(year)/\(month)/\(day)") else {
            errorMessage = "잘못된 URL입니다"
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "서버 응답 오류"
                return nil
            }
            
            let weekResponse = try JSONDecoder().decode(WeekOfMonthResponse.self, from: data)
            return weekResponse
        } catch {
            errorMessage = "네트워크 오류: \(error.localizedDescription)"
            return nil
        }
    }
    
    func getCurrentCalendar() async -> CalendarMonthResponse? {
        guard let url = URL(string: "\(baseURL)/current") else {
            errorMessage = "잘못된 URL입니다"
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "서버 응답 오류"
                return nil
            }
            
            let calendarResponse = try JSONDecoder().decode(CalendarMonthResponse.self, from: data)
            return calendarResponse
        } catch {
            errorMessage = "네트워크 오류: \(error.localizedDescription)"
            return nil
        }
    }
    
    func getEvents() async -> [NetworkCalendarEvent]? {
        guard let url = URL(string: "\(baseURL)/events") else {
            errorMessage = "잘못된 URL입니다"
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "서버 응답 오류"
                return nil
            }
            
            let events = try JSONDecoder().decode([NetworkCalendarEvent].self, from: data)
            return events
        } catch {
            errorMessage = "네트워크 오류: \(error.localizedDescription)"
            return nil
        }
    }
    
    func addEvent(title: String, date: String, type: String, description: String) async -> NetworkCalendarEvent? {
        guard let url = URL(string: "\(baseURL)/events") else {
            errorMessage = "잘못된 URL입니다"
            return nil
        }
        
        let eventData = [
            "title": title,
            "date": date,
            "type": type,
            "description": description
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: eventData)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                errorMessage = "서버 응답 오류"
                return nil
            }
            
            let event = try JSONDecoder().decode(NetworkCalendarEvent.self, from: data)
            return event
        } catch {
            errorMessage = "네트워크 오류: \(error.localizedDescription)"
            return nil
        }
    }
} 