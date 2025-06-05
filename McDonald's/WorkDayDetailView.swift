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
        ScrollView {
            VStack(spacing: 20) {
                headerView

                detailCard(icon: "calendar", title: "날짜", value: formattedDate(workDay.date))
                detailCard(icon: "clock", title: "근무 시간", value: "\(workDay.startTime) - \(workDay.endTime)")
                detailCard(icon: "hourglass", title: "근무 시간 합계", value: String(format: "%.1f시간", workDay.hoursWorked))
                detailCard(icon: "dollarsign.circle", title: "일급", value: formattedCurrency(workDay.dailyWage))
            }
            .padding()
        }
        .navigationTitle("근무 상세")
        .navigationBarTitleDisplayMode(.inline)
    }

    var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title2)
                .foregroundColor(.white)
            Text("근무 요약")
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .cyan]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
    }

    func detailCard(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.title3.bold())
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: NSNumber(value: value))! + "원"
    }
}
