//
//  ViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import Foundation

class WorkCalendarViewModel: ObservableObject {
    @Published var workDays: [Date: WorkDay] = [:]
    @Published var hourlyWage: Double = 13030
    @Published var currentMonth: Date = Date()

    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()

    func calculateWorkHours(start: String, end: String) -> Double {
        guard let startDate = timeFormatter.date(from: start),
              let endDateRaw = timeFormatter.date(from: end) else { return 0 }

        // endTime이 startTime보다 빠르면 익일로 간주
        let endDate = endDateRaw < startDate
            ? Calendar.current.date(byAdding: .day, value: 1, to: endDateRaw)!
            : endDateRaw

        let total = endDate.timeIntervalSince(startDate) / 3600

        // 휴게시간 적용
        let breakTime: Double = total >= 9 ? 1.0 : 0.5
        return max(total - breakTime, 0)
    }


    func addWorkDay(weekday: String, timeRange: String, weekStartDate: Date) {
        let components = timeRange.components(separatedBy: "~")
        guard components.count == 2 else { return }

        let start = components[0].trimmingCharacters(in: .whitespaces)
        let end = components[1].trimmingCharacters(in: .whitespaces)

        let hours = calculateWorkHours(start: start, end: end)
        let wage = hours * hourlyWage

        let date = dateFor(weekday: weekday, weekStartDate: weekStartDate)
        let workDay = WorkDay(date: date, startTime: start, endTime: end, hoursWorked: hours, dailyWage: wage)

        workDays[date] = workDay
    }

    func addRestDay(weekday: String, label: String, weekStartDate: Date) {
        let date = dateFor(weekday: weekday, weekStartDate: weekStartDate)
        let workDay = WorkDay(date: date, startTime: label, endTime: "", hoursWorked: 0, dailyWage: 0)

        workDays[date] = workDay
    }

    func dateFor(weekday: String, weekStartDate: Date) -> Date {
        let weekdayMapping = ["월요일": 2, "화요일": 3, "수요일": 4, "목요일": 5,
                              "금요일": 6, "토요일": 7, "일요일": 1]
        let calendar = Calendar.current
        guard let weekdayIndex = weekdayMapping[weekday] else { return weekStartDate }
        return calendar.date(bySetting: .weekday, value: weekdayIndex, of: weekStartDate)!
    }

    func wageForDate(_ date: Date) -> Int? {
        if let day = workDays[date] {
            return Int(day.dailyWage)
        }
        return nil
    }

    func labelForDate(_ date: Date) -> String? {
        if let day = workDays[date], day.dailyWage == 0 {
            return day.startTime // OFF or 주휴
        }
        return nil
    }

    func totalWageForCurrentMonth() -> Int {
        let calendar = Calendar.current
        return workDays
            .filter { calendar.isDate($0.key, equalTo: currentMonth, toGranularity: .month) }
            .map { Int($0.value.dailyWage) }
            .reduce(0, +)
    }

    func changeMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newDate
        }
    }

    func jumpToMonth(of date: Date) {
        currentMonth = date
    }

    func containsWeek(starting weekStartDate: Date) -> Bool {
        let calendar = Calendar.current
        let weekRange = (0..<7).compactMap {
            calendar.date(byAdding: .day, value: $0, to: weekStartDate)
        }

        return weekRange.contains { workDays[$0] != nil }
    }

    func removeWeek(starting weekStartDate: Date) {
        let calendar = Calendar.current
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStartDate) {
                workDays.removeValue(forKey: date)
            }
        }
    }
    
    func timeRangeForDate(_ date: Date) -> String? {
        return workDays[date]?.timeRangeString
    }
    
    func generateCalendar() -> [Date] {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")

        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
}
	
