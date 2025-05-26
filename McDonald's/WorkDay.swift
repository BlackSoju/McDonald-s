//
//  Model.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import Foundation

struct WorkDay: Identifiable {
    let id = UUID()
    let date: Date
    let startTime: String
    let endTime: String
    let hoursWorked: Double
    let dailyWage: Double
}

