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
        VStack(spacing: 0) {
            calendarHeader
            calendarBody
        }
        .sheet(item: Binding(
            get: { selectedDate.map { IdentifiableDate(date: $0) } },
            set: { selectedDate = $0?.date }
        )) { identifiableDate in
            if let workDay = viewModel.workDays[identifiableDate.date] {
                WorkDayDetailView(workDay: workDay)
                    .presentationDetents([.medium])
            }
        }
    }

    private var calendarHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Button(action: { viewModel.changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                Spacer()
                Text(monthYearString(from: viewModel.currentMonth))
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: { viewModel.changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)

            Text("총 월급: \(formattedWage(viewModel.totalWageForCurrentMonth()))원")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }

    private var calendarBody: some View {
        GeometryReader { geometry in
            let width = geometry.size.width / 7
            let height = (geometry.size.height - 32) / 6
            let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let dates = viewModel.generateCurrentMonthDates()

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .gray))
                            .frame(width: width, height: 32)
                    }
                }

                VStack(spacing: 1) {
                    ForEach(0..<6, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<7, id: \.self) { column in
                                let index = row * 7 + column
                                if index < dates.count, let date = dates[index] {
                                    CalendarCell(
                                        date: date,
                                        workDay: viewModel.workDays[date],
                                        isToday: Calendar.current.isDateInToday(date),
                                        formattedWage: formattedWage,
                                        width: width,
                                        height: height,
                                        onTap: {
                                            if let workDay = viewModel.workDays[date], workDay.hoursWorked > 0 {
                                                selectedDate = date
                                            }
                                        }
                                    )
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: width, height: height)
                                }
                            }
                        }
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
}

struct CalendarCell: View {
    let date: Date
    let workDay: WorkDay?
    let isToday: Bool
    let formattedWage: (Int) -> String
    let width: CGFloat
    let height: CGFloat
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.footnote.weight(.medium))
                    .foregroundColor(isToday ? .white : .primary)
                    .frame(width: 24, height: 24)
                    .background(isToday ? Color.blue : Color.clear)
                    .clipShape(Circle())
                    .padding([.top, .trailing], 4)
            }

            Spacer()

            if let workDay = workDay {
                VStack(spacing: 2) {
                    if workDay.startTime.contains("OFF") || workDay.startTime.contains("주휴") {
                        Text(workDay.startTime.replacingOccurrences(of: "~", with: ""))
                            .font(.system(size: 10))
                            .foregroundColor(workDay.startTime.contains("주휴") ? .orange : .gray)
                    } else {
                        Text("\(String(format: "%.1f", workDay.hoursWorked))시간")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)

                Spacer()

                if !(workDay.startTime.contains("OFF") || workDay.startTime.contains("주휴")) {
                    Text("\(formattedWage(Int(workDay.dailyWage)))원")
                        .font(.system(size: 10).monospacedDigit())
                        .foregroundColor(.blue)
                        .padding(.bottom, 4)
                } else {
                    Spacer(minLength: 16)
                }
            } else {
                Spacer()
                Spacer(minLength: 16)
            }
        }
        .frame(width: width, height: height)
        .background(
            Color(uiColor: .systemBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
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
