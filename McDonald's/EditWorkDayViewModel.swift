//
//  EditWorkDayViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 6/17/25.
//

import Foundation
import SwiftUI

class EditWorkDayViewModel: ObservableObject {
    @Published var selectedStartHour: Int
    @Published var selectedStartMinute: Int
    @Published var selectedEndHour: Int
    @Published var selectedEndMinute: Int

    var formattedStartTime: String {
        String(format: "%02d:%02d", selectedStartHour, selectedStartMinute)
    }

    var formattedEndTime: String {
        String(format: "%02d:%02d", selectedEndHour, selectedEndMinute)
    }

    init(startTime: String, endTime: String) {
        let (startHour, startMinute) = Self.extractTimeComponents(from: startTime)
        let (endHour, endMinute) = Self.extractTimeComponents(from: endTime)

        self.selectedStartHour = startHour
        self.selectedStartMinute = startMinute
        self.selectedEndHour = endHour
        self.selectedEndMinute = endMinute
    }

    /// 시간 문자열("09:30")을 (9, 30)으로 분리
    private static func extractTimeComponents(from time: String) -> (Int, Int) {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return (9, 0) // 기본값
        }
        return (hour, minute)
    }

    /// 수정된 결과를 반환 (저장 시 사용 가능)
    func updatedTimeStrings() -> (startTime: String, endTime: String) {
        (formattedStartTime, formattedEndTime)
    }
}
