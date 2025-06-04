//
//  WorkDayDetailView.swift
//  McDonald's
//
//  Created by 윤준성 on 6/6/25.
//

import SwiftUI

struct WorkDayDetailView: View {
    let workDay: WorkDay

    var body: some View {
        VStack(spacing: 16) {
            Text("상세 근무 정보")
                .font(.title2)
                .bold()

            Text("날짜: \(formattedDate(workDay.date))")
            Text("근무 시간: \(workDay.timeRangeString)")
            Text("근무 시간: \(String(format: "%.1f", workDay.hoursWorked))시간")
            Text("일급: \(formattedWage(Int(workDay.dailyWage)))원")
        }
        .padding()
    }

    // 날짜 형식: 2025년 6월 6일
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    // 1,000 단위 콤마 포맷
    private func formattedWage(_ wage: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: wage)) ?? "\(wage)"
    }
}

struct WorkDayDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sample = WorkDay(
            date: Date(),
            startTime: "10:00",
            endTime: "19:00",
            hoursWorked: 8.0,
            dailyWage: 92000
        )
        WorkDayDetailView(workDay: sample)
    }
}
