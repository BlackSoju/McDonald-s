//
//  Untitled.swift
//  McDonald's
//
//  Created by 윤준성 on 6/20/25.
//

import SwiftUI

struct CustomTimePicker: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        let buttonWidth = (UIScreen.main.bounds.width - 32 - 12) / 2

        HStack(spacing: 0) {
            CustomWheel(
                selection: $hour,
                range: 0..<24,
                color: .hourPickerBG,
                highlightColor: .hourHighlight,
                unitCount: 24
            )
            .frame(width: buttonWidth)

            Spacer().frame(width: 3)

            Text(":")
                .font(.title2.bold())
                .foregroundColor(.gray)
                .frame(width: 6)

            Spacer().frame(width: 3)

            CustomWheel(
                selection: $minute,
                range: 0..<60,
                color: .minutePickerBG,
                highlightColor: .minuteHighlight,
                unitCount: 60
            )
            .frame(width: buttonWidth)
        }
        .frame(height: 240)
        .padding(.horizontal, 16)
    }
}
