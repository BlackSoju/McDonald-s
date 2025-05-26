//
//  WorkCalendarView.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import SwiftUI

struct WorkCalendarView: View {
    @ObservedObject var viewModel: WorkCalendarViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // 상단 월 이동 버튼 + 월급
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
            }.padding(.horizontal)
            
            Text("총 월급: \(viewModel.totalWageForCurrentMonth())원")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 4)
                .padding(.bottom, 12)

            GeometryReader { geometry in
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
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        Text(day)
                            .font(.subheadline).bold()
                            .frame(width: cellWidth, height: cellHeight * 0.15)
                    }
                    
                    ForEach(days.indices, id: \.self) { i in
                        if let date = days[i] {
                            let weekday = calendar.component(.weekday, from: date)
                            let wage = viewModel.wageForDate(date)
                            let label = viewModel.labelForDate(date)
                            
                            VStack(spacing: 4) {
                                Text("\(calendar.component(.day, from: date))")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(weekday == 1 ? .red : (weekday == 7 ? .blue : .primary))
                                
                                if let wage = wage {
                                    if wage > 0 {
                                        Text("\(wage)원")
                                            .font(.caption2)
                                    } else if let label = label {
                                        Text(label)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(width: cellWidth, height: cellHeight)
                            .background((wage ?? 0) > 0 ? Color.yellow.opacity(0.3) : Color.clear)
                            .cornerRadius(8)
                        } else {
                            Color.clear.frame(width: cellWidth, height: cellHeight)
                        }
                    }
                }
            }
        }
    }
    
    func monthYearString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy년 M월"
        return f.string(from: date)
    }
}

struct WorkCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkCalendarView(viewModel: WorkCalendarViewModel())
        }
    }
}
