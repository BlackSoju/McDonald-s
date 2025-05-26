//
//  ViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import Foundation

class WorkCalendarViewModel: ObservableObject {
    @Published var workDays: [WorkDay] = []
    @Published var hourlyWage: Double = 10030
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
              let endDate = timeFormatter.date(from: end) else { return 0 }
        let total = endDate.timeIntervalSince(startDate) / 3600
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
        workDays.append(workDay)
    }

    func addRestDay(weekday: String, label: String, weekStartDate: Date) {
        let date = dateFor(weekday: weekday, weekStartDate: weekStartDate)
        let workDay = WorkDay(date: date, startTime: label, endTime: "", hoursWorked: 0, dailyWage: 0)
        workDays.append(workDay)
    }

    func dateFor(weekday: String, weekStartDate: Date) -> Date {
        let weekdayMapping = ["월요일": 2, "화요일": 3, "수요일": 4, "목요일": 5, "금요일": 6, "토요일": 7, "일요일": 1]
        let calendar = Calendar.current
        guard let weekdayIndex = weekdayMapping[weekday] else { return weekStartDate }
        return calendar.date(bySetting: .weekday, value: weekdayIndex, of: weekStartDate)!
    }

    func wageForDate(_ date: Date) -> Int? {
        if let day = workDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            return Int(day.dailyWage)
        }
        return nil
    }

    func labelForDate(_ date: Date) -> String? {
        if let day = workDays.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }),
           day.dailyWage == 0 {
            return day.startTime // "OFF" 또는 "주휴"
        }
        return nil
    }

    func totalWageForCurrentMonth() -> Int {
        let calendar = Calendar.current
        let total = workDays
            .filter { calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
            .map { Int($0.dailyWage) }
            .reduce(0, +)
        
        print("🧾 현재 월: \(currentMonth), 총 일수: \(workDays.count), 합계: \(total)")
        return total
    }


    func changeMonth(by offset: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newDate
        }
    }
}
