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
            Color.beigeBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                calendarHeader
                Text("총 월급: \(formattedWage(viewModel.totalWageForCurrentMonth()))원")
                    .font(.subheadline)
                    .foregroundColor(.textPrimaryColor)
                    .padding(.bottom, 4)
                calendarBody
            }
        }
        .sheet(item: Binding(
            get: { selectedDate.map { IdentifiableDate(date: $0) } },
            set: { selectedDate = $0?.date }
        )) { identifiableDate in
            if let workDay = viewModel.workDays[identifiableDate.date] {
                WorkDayDetailView(workDay: workDay)
            }
        }
    }

    private var calendarHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Button(action: { viewModel.changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.textPrimaryColor)
                        .frame(width: 36, height: 36)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .embossShadow, radius: 1.5, x: 1, y: 1)
                        .shadow(color: .embossHighlight, radius: 1, x: -1, y: -1)
                }

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation {
                            viewModel.jumpToMonth(of: Date())
                        }
                    }) {
                        Text("오늘")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .embossShadow, radius: 1.5, x: 1, y: 1)
                            .shadow(color: .embossHighlight, radius: 1, x: -1, y: -1)
                    }

                    Button(action: { viewModel.changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .foregroundColor(.textPrimaryColor)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .embossShadow, radius: 1.5, x: 1, y: 1)
                            .shadow(color: .embossHighlight, radius: 1, x: -1, y: -1)
                    }
                }
            }
            .overlay(
                Text(monthYearString(from: viewModel.currentMonth))
                    .font(.title2.weight(.bold))
                    .foregroundColor(.textPrimaryColor)
            )
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }


    private var calendarBody: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 1
            let width = (geometry.size.width - (spacing * 6)) / 7
            let height = (geometry.size.height - 32) / 6
            let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
            let dates = viewModel.generateCurrentMonthDates()

            VStack(spacing: 0) {
                HStack(spacing: spacing) {
                    ForEach(weekdays, id: \ .self) { day in
                        Text(day)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .textPrimaryColor))
                            .frame(width: width, height: 28)
                    }
                }

                VStack(spacing: spacing) {
                    ForEach(0..<6, id: \ .self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<7, id: \ .self) { column in
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
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .embossShadow, radius: 1.5, x: 1, y: 1)
                .shadow(color: .embossHighlight, radius: 1, x: -1, y: -1)

            VStack(spacing: 4) {
                HStack {
                    Spacer()
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(isToday ? .white : .textPrimaryColor)
                        .frame(width: 24, height: 24)
                        .background(isToday ? Color.blue : Color.clear)
                        .clipShape(Circle())
                        .padding(.top, 6)
                        .padding(.trailing, 6)
                }

                Spacer()

                if let workDay = workDay {
                    VStack(spacing: 2) {
                        if workDay.startTime.contains("OFF") || workDay.startTime.contains("주휴") {
                            Text(workDay.startTime.replacingOccurrences(of: "~", with: ""))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.textPrimaryColor)
                        } else {
                            Text(String(format: "%.1f시간", workDay.hoursWorked))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.mint)
                        }

                        Spacer(minLength: 4)

                        Text("\(formattedWage(Int(workDay.dailyWage)))원")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 6)
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                } else {
                    Spacer(minLength: 24)
                }
            }
            .frame(width: width - 6, height: height - 6)
        }
        .frame(width: width, height: height)
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
