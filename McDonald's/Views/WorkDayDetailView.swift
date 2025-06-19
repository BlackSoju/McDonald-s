//
//  WorkDayDetailView.swift
//  McDonald's
//
//  Created by 윤준성 on 6/6/25.
//

import SwiftUI

struct WorkDayDetailView: View {
    let originalWorkDay: WorkDay
    @State private var editableStartTime: String
    @State private var editableEndTime: String
    @State private var showingEditSheet = false

    init(workDay: WorkDay) {
        self.originalWorkDay = workDay
        _editableStartTime = State(initialValue: workDay.startTime)
        _editableEndTime = State(initialValue: workDay.endTime)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView

                detailCard(icon: "calendar", title: "날짜", value: formattedDate(originalWorkDay.date))
                detailCard(icon: "clock", title: "근무 시간", value: "\(editableStartTime) - \(editableEndTime)")
                detailCard(icon: "hourglass", title: "근무 시간 합계", value: String(format: "%.1f시간", originalWorkDay.hoursWorked))
                detailCard(icon: "dollarsign.circle", title: "일급", value: formattedCurrency(originalWorkDay.dailyWage))

                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("근무 수정")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
            .padding()
        }
        .sheet(isPresented: $showingEditSheet) {
            let viewModel = EditWorkDayViewModel(
                startTime: editableStartTime,
                endTime: editableEndTime
            )
            EditWorkDayView(viewModel: viewModel)
        }
        .presentationDetents([.fraction(0.65)])
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
