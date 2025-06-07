//
//  WorkCalendarView.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import SwiftUI

struct WorkCalendarView: View {
    @ObservedObject var viewModel: WorkCalendarViewModel
    @State private var selectedDate: Date?

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    monthHeader
                    totalWageText
                }
                .padding(.top, 30)

                Spacer(minLength: 0)

                weekdayHeader
                calendarCard

                Spacer(minLength: 0)
            }
        }
        .sheet(item: Binding(
            get: { selectedDate.map { IdentifiableDate(date: $0) } },
            set: { selectedDate = $0?.date }
        )) { identifiableDate in
            if let workDay = viewModel.workDays[identifiableDate.date], workDay.hoursWorked > 0 {
                WorkDayDetailView(workDay: workDay)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    var monthHeader: some View {
        HStack {
            Button(action: { viewModel.changeMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            Spacer()
            Text(monthYearString(from: viewModel.currentMonth))
                .font(.title2.bold())
                .foregroundStyle(.primary)
            Spacer()
            Button(action: { viewModel.changeMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
        }
        .padding(.horizontal)
    }

    var totalWageText: some View {
        Text("총 월급: \(formattedWage(viewModel.totalWageForCurrentMonth()))원")
            .font(.footnote)
            .foregroundColor(.secondary)
    }

    var weekdayHeader: some View {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 46), spacing: 4), count: 7), spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption.bold())
                    .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .secondary))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 4)
    }

    var calendarCard: some View {
        VStack(spacing: 8) {
            calendarGrid
                .padding(.horizontal, 4)
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
        .padding(.horizontal)
    }

    var calendarGrid: some View {
        let dates = viewModel.generateCalendar()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 12) {
            ForEach(dates, id: \.self) { date in
                CalendarCell(date: date, workDay: viewModel.workDays[date], isToday: Calendar.current.isDateInToday(date), formattedWage: formattedWage) {
                    if let workDay = viewModel.workDays[date], workDay.hoursWorked > 0 {
                        selectedDate = date
                    }
                }
            }
        }
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }

    func formattedWage(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    private struct CalendarCell: View {
        let date: Date
        let workDay: WorkDay?
        let isToday: Bool
        let formattedWage: (Int) -> String
        let onTap: () -> Void

        var body: some View {
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    Spacer(minLength: 6)
                    if let workDay = workDay {
                        if workDay.startTime.contains("OFF") || workDay.startTime.contains("주휴") {
                            Spacer()
                            Text(workDay.startTime.replacingOccurrences(of: "~", with: ""))
                                .font(.system(size: 10))
                                .foregroundColor(workDay.startTime.contains("주휴") ? .orange : .gray)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            Spacer()
                        } else {
                            Spacer()
                            Text("\(String(format: "%.1f", workDay.hoursWorked))시간")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("\(formattedWage(Int(workDay.dailyWage)))원")
                                .font(.system(size: 10).monospacedDigit())
                                .foregroundColor(.blue)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 6)
                        }
                    } else {
                        Spacer()
                        Text(" ")
                            .font(.system(size: 10))
                        Spacer()
                    }
                }

                VStack {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isToday ? .white : .primary)
                        .frame(width: 24, height: 24, alignment: .center)
                        .background(isToday ? Color.blue : Color.clear)
                        .clipShape(Circle())
                        .padding([.top, .leading], 6)
                    Spacer()
                }
            }
            .frame(minWidth: 46, maxWidth: .infinity, minHeight: 80, maxHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .onTapGesture(perform: onTap)
        }
    }
}

struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct WorkCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkCalendarView(viewModel: WorkCalendarViewModel())
        }
    }
}
