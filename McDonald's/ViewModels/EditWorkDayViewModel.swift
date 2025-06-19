//
//  EditWorkDayViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 6/17/25.
//

import Foundation
import SwiftUI

final class EditWorkDayViewModel: ObservableObject {
    enum TimeType: String, CaseIterable, Identifiable {
        case start = "출근"
        case end = "퇴근"

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .start: return "briefcase.fill"
            case .end: return "house.fill"
            }
        }

        var activeColor: Color {
            switch self {
            case .start: return .workStartColor
            case .end: return .workEndColor
            }
        }
    }

    @Published var selectedTab: TimeType = .start

    @Published var selectedStartHour: Int
    @Published var selectedStartMinute: Int
    @Published var selectedEndHour: Int
    @Published var selectedEndMinute: Int

    let hourOptions = Array(0..<24)
    let minuteOptions = stride(from: 0, to: 60, by: 5).map { $0 }

    var formattedStartTime: String {
        String(format: "%02d:%02d", selectedStartHour, selectedStartMinute)
    }

    var formattedEndTime: String {
        String(format: "%02d:%02d", selectedEndHour, selectedEndMinute)
    }

    init(startTime: String = "09:00", endTime: String = "18:00") {
        let (startHour, startMinute) = Self.extractTimeComponents(from: startTime)
        let (endHour, endMinute) = Self.extractTimeComponents(from: endTime)

        self.selectedStartHour = startHour
        self.selectedStartMinute = startMinute
        self.selectedEndHour = endHour
        self.selectedEndMinute = endMinute
    }

    private static func extractTimeComponents(from time: String) -> (Int, Int) {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return (9, 0)
        }
        return (hour, minute)
    }

    func updatedTimeStrings() -> (startTime: String, endTime: String) {
        (formattedStartTime, formattedEndTime)
    }

    func getCurrentHourBinding() -> Binding<Int> {
        Binding(
            get: {
                self.selectedTab == .start ? self.selectedStartHour : self.selectedEndHour
            },
            set: { newValue in
                if self.selectedTab == .start {
                    self.selectedStartHour = newValue
                } else {
                    self.selectedEndHour = newValue
                }
            }
        )
    }

    func getCurrentMinuteBinding() -> Binding<Int> {
        Binding(
            get: {
                self.selectedTab == .start ? self.selectedStartMinute : self.selectedEndMinute
            },
            set: { newValue in
                if self.selectedTab == .start {
                    self.selectedStartMinute = newValue
                } else {
                    self.selectedEndMinute = newValue
                }
            }
        )
    }

    func save() {
        let start = formattedStartTime
        let end = formattedEndTime
        print("저장 완료: 출근 \(start), 퇴근 \(end)")
    }
}
