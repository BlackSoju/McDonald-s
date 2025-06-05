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
        VStack(spacing: 12) {
            HStack {
                Button(action: { viewModel.changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(monthYearString(from: viewModel.currentMonth))
                    .font(.title).bold()
                Spacer()
                Button(action: { viewModel.changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            Text("총 월급: \(formattedWage(viewModel.totalWageForCurrentMonth()))")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
                .padding(.bottom, 12)

            GeometryReader { geometry in
                calendarGrid(geometry: geometry)
            }
        }
        .sheet(item: Binding(
            get: { selectedDate.map { IdentifiableDate(date: $0) } },
            set: { selectedDate = $0?.date }
        )) { identifiableDate in
            if let workDay = viewModel.workDays[identifiableDate.date],
               workDay.hoursWorked > 0 {
                WorkDayDetailView(workDay: workDay)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    func calendarGrid(geometry: GeometryProxy) -> some View {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: viewModel.currentMonth)
        let firstOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let numDays = range.count
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = firstWeekday - 1

        let days: [Date?] = (0..<(offset + numDays)).map { i in
            if i < offset { return nil }
            return calendar.date(from: DateComponents(year: components.year, month: components.month, day: i - offset + 1))
        }

        let cellWidth = geometry.size.width / 7
        let cellHeight = geometry.size.height / 7

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
            let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.subheadline).bold()
                    .frame(width: cellWidth, height: cellHeight * 0.15)
            }

            ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                if let date = date {
                    let weekday = calendar.component(.weekday, from: date)
                    let workDay = viewModel.workDays[date]
                    let isWorkDay = (workDay?.hoursWorked ?? 0) > 0

                    VStack(spacing: 2) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.caption)
                            .bold()
                            .foregroundColor(weekday == 1 ? .red : (weekday == 7 ? .blue : .primary))

                        if let workDay = workDay, isWorkDay {
                            Text(workDay.timeRangeString)
                                .font(.caption2)
                            Text(workDay.formattedDurationString)
                                .font(.caption2)
                                .foregroundColor(.gray)
                        } else if let label = viewModel.labelForDate(date) {
                            Text(label.replacingOccurrences(of: "~", with: ""))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(width: cellWidth, height: cellHeight)
                    .background(isWorkDay ? Color.yellow.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        if isWorkDay {
                            selectedDate = date
                        }
                    }
                } else {
                    Color.clear.frame(width: cellWidth, height: cellHeight)
                }
            }
        }
    }

    func monthYearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월"
        return f.string(from: date)
    }

    func formattedWage(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
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
