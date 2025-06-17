//
//  EditWorkDayView.swift
//  McDonald's
//
//  Created by 윤준성 on 6/16/25.
//

import SwiftUI

struct EditWorkDayView: View {
    @ObservedObject var viewModel: EditWorkDayViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: TimeType = .start

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

    var body: some View {
        VStack(spacing: 24) {
            Text("근무 시간 선택")
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.textPrimaryColor)
                .padding(.top, 24)

            HStack(spacing: 12) {
                ForEach(TimeType.allCases) { type in
                    Button {
                        selectedTab = type
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                            Text(type.rawValue)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(selectedTab == type ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            selectedTab == type ? type.activeColor : Color.gray.opacity(0.1)
                        )
                        .cornerRadius(16)
                        .shadow(color: selectedTab == type ? Color.black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal)

            CustomTimePicker(
                hour: selectedTab == .start ? $viewModel.selectedStartHour : $viewModel.selectedEndHour,
                minute: selectedTab == .start ? $viewModel.selectedStartMinute : $viewModel.selectedEndMinute
            )

            Button(action: {
                dismiss()
            }) {
                Text("저장")
                    .font(.system(size: 20, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.saveButtonColor)
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            Spacer(minLength: 0)
        }
        .padding(.bottom, 20)
        .background(Color.backgroundColor.ignoresSafeArea())
        .presentationDetents([.fraction(0.65)])
        .navigationTitle("근무 수정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CustomTimePicker: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 20) {
            CustomWheel(selection: $hour, range: 0..<24, color: .hourPickerBG, highlightColor: .hourHighlight, unitCount: 24)
            Text(":")
                .font(.title2.bold())
                .foregroundColor(.gray)
            CustomWheel(selection: $minute, range: 0..<60, color: .minutePickerBG, highlightColor: .minuteHighlight, unitCount: 60)
        }
        .frame(height: 240)
        .padding(.horizontal, 32)
    }
}

struct CustomWheel: View {
    @Binding var selection: Int
    let range: Range<Int>
    let color: Color
    let highlightColor: Color
    let unitCount: Int

    private let totalRepeatCount = 100

    var loopedRange: [Int] {
        Array(repeating: Array(range), count: totalRepeatCount).flatMap { $0 }
    }

    var middleIndex: Int {
        (loopedRange.count / 2) - ((loopedRange.count / 2) % unitCount) + selection
    }

    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(loopedRange.indices, id: \.self) { index in
                            let value = loopedRange[index]
                            Text(String(format: "%02d", value))
                                .font(.system(size: 24, weight: index == middleIndex ? .black : .regular))
                                .foregroundColor(index == middleIndex ? .primary : .gray.opacity(0.5))
                                .frame(height: 48)
                                .frame(maxWidth: .infinity)
                                .id(index)
                        }
                    }
                    .padding(.vertical, (geo.size.height - 48) / 2)
                }
                .onAppear {
                    proxy.scrollTo(middleIndex, anchor: .center)
                }
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(color)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    .blur(radius: 1)
                                    .offset(x: -1, y: -1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                    .blur(radius: 1)
                                    .offset(x: 1, y: 1)
                            )
                        VStack {
                            Spacer()
                            RoundedRectangle(cornerRadius: 10)
                                .fill(highlightColor)
                                .frame(height: 48)
                                .shadow(radius: 1)
                            Spacer()
                        }
                    }
                )
                .clipped()
            }
        }
        .frame(width: 124)
    }
}

struct EditWorkDayView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkDayView(viewModel: EditWorkDayViewModel(startTime: "09:00", endTime: "18:00"))
    }
}
