//
//  Model.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import Foundation

struct WorkDay: Identifiable {
    let id = UUID()
    let date: Date
    var startTime: String
    var endTime: String
    let hoursWorked: Double
    let dailyWage: Double
    var durationHours: Double {
        calculatedWorkDuration
    }
}

extension WorkDay {
    var timeRangeString: String {
        "\(startTime)~\(endTime)"
    }
    
    var calculatedWorkDuration: Double {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let start = formatter.date(from: startTime),
              let end = formatter.date(from: endTime) else { return 0 }
        
        let hours = end.timeIntervalSince(start) / 3600
        return max(0, hours - 1) // 휴식 1시간 제외
    }
    
    var formattedDurationString: String {
        String(format: "%.1f시간", hoursWorked)
    }

}


