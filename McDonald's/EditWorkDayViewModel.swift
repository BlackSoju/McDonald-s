//
//  EditWorkDayViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 6/17/25.
//

import SwiftUI

class EditWorkDayViewModel: ObservableObject {
    @Published var selectedStartHour: Int
    @Published var selectedStartMinute: Int
    @Published var selectedEndHour: Int
    @Published var selectedEndMinute: Int

    init(startTime: String, endTime: String) {
        let (startHour, startMinute) = EditWorkDayViewModel.timeComponents(from: startTime)
        let (endHour, endMinute) = EditWorkDayViewModel.timeComponents(from: endTime)
        self.selectedStartHour = startHour
        self.selectedStartMinute = startMinute
        self.selectedEndHour = endHour
        self.selectedEndMinute = endMinute
    }

    var formattedStartTime: String {
        String(format: "%02d:%02d", selectedStartHour, selectedStartMinute)
    }

    var formattedEndTime: String {
        String(format: "%02d:%02d", selectedEndHour, selectedEndMinute)
    }

    private static func timeComponents(from time: String) -> (Int, Int) {
        let components = time.split(separator: ":")
        if components.count == 2,
           let hour = Int(components[0]),
           let minute = Int(components[1]) {
            return (hour, minute)
        }
        return (9, 0) // 기본값
    }
}
