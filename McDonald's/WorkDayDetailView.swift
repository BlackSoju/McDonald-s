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
        VStack(alignment: .leading, spacing: 12) {
            Text("상세 근무 정보")
                .font(.title2).bold()
                .padding(.bottom)

            HStack {
                Text("날짜:")
                    .bold()
                Text(dateString(workDay.date))
            }

            HStack {
                Text("시간:")
                    .bold()
                Text(workDay.timeRangeString)
            }

            HStack {
                Text("근무 시간:")
                    .bold()
                Text(workDay.formattedDurationString)
            }

            HStack {
                Text("일급:")
                    .bold()
                Text("\(formattedWage(Int(workDay.dailyWage)))원")
            }

            Spacer()
        }
        .padding()
    }

    func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월 d일 (E)"
        f.locale = Locale(identifier: "ko_KR")
        return f.string(from: date)
    }

    func formattedWage(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
