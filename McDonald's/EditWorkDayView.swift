//
//  EditWorkDayView.swift
//  McDonald's
//
//  Created by 윤준성 on 6/16/25.
//

import SwiftUI

struct EditWorkDayView: View {
    @Binding var startTime: String
    @Binding var endTime: String
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab: TimeType = .start
    @State private var selectedStartHour: Int = 9
    @State private var selectedStartMinute: Int = 0
    @State private var selectedEndHour: Int = 18
    @State private var selectedEndMinute: Int = 0

    enum TimeType: String, CaseIterable, Identifiable {
        case start = "시작 시간"
        case end = "종료 시간"
        var id: String { self.rawValue }
    }

    var body: some View {
        VStack(spacing: 20) {
            headerView

            Picker("시간 선택", selection: $selectedTab) {
                ForEach(TimeType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            timePicker(for: selectedTab)

            Spacer(minLength: 12)

            Button(action: {
                startTime = String(format: "%02d:%02d", selectedStartHour, selectedStartMinute)
                endTime = String(format: "%02d:%02d", selectedEndHour, selectedEndMinute)
                dismiss()
            }) {
                Text("저장")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding(.top)
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .onAppear {
            selectedStartHour = hour(from: startTime)
            selectedStartMinute = minute(from: startTime)
            selectedEndHour = hour(from: endTime)
            selectedEndMinute = minute(from: endTime)
        }
        .presentationDetents([.height(380)])
        .navigationTitle("근무 수정")
        .navigationBarTitleDisplayMode(.inline)
    }

    var headerView: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "pencil.circle.fill")
                .font(.title2)
                .foregroundColor(.white)
            Text("근무 시간 수정")
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

    func timePicker(for type: TimeType) -> some View {
        let hourBinding = type == .start ? $selectedStartHour : $selectedEndHour
        let minuteBinding = type == .start ? $selectedStartMinute : $selectedEndMinute

        return HStack(spacing: 8) {
            Picker("시", selection: hourBinding) {
                ForEach(0..<24, id: \.self) { hour in
                    Text(String(format: "%02d", hour))
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)

            Text(":")
                .font(.title2)

            Picker("분", selection: minuteBinding) {
                ForEach([0, 30], id: \.self) { minute in
                    Text(String(format: "%02d", minute))
                }
            }
            .pickerStyle(.wheel)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    func hour(from time: String) -> Int {
        let components = time.split(separator: ":")
        return Int(components.first ?? "0") ?? 0
    }

    func minute(from time: String) -> Int {
        let components = time.split(separator: ":")
        return Int(components.last ?? "0") ?? 0
    }
}

#Preview {
    EditWorkDayView(startTime: .constant("09:00"), endTime: .constant("18:00"))
}
