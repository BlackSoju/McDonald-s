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

    var body: some View {
        VStack(spacing: 24) {
            // 제목
            Text("근무 시간 선택")
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.textPrimaryColor)
                .padding(.top, 24)

            // 출근/퇴근 탭
            HStack(spacing: 12) {
                ForEach(EditWorkDayViewModel.TimeType.allCases) { type in
                    Button {
                        viewModel.selectedTab = type
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                            Text(type.rawValue)
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.selectedTab == type ? .black : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            viewModel.selectedTab == type ? type.activeColor : Color.gray.opacity(0.1)
                        )
                        .cornerRadius(16)
                        .shadow(color: viewModel.selectedTab == type ? Color.black.opacity(0.05) : .clear, radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal)

            // 시/분 선택 휠
            CustomTimePicker(
                hour: viewModel.getCurrentHourBinding(),
                minute: viewModel.getCurrentMinuteBinding()
            )

            // 저장 버튼
            Button(action: {
                viewModel.save()
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
        .background(Color.beigeBackground.ignoresSafeArea())
        .presentationDetents([.fraction(0.65)])
        .navigationTitle("근무 수정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EditWorkDayView_Previews: PreviewProvider {
    static var previews: some View {
        EditWorkDayView(
            viewModel: EditWorkDayViewModel(startTime: "09:00", endTime: "18:00")
        )
    }
}
