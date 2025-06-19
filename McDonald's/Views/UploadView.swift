//
//  UploadView.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @StateObject var viewModel: UploadViewModel

    init(calendarViewModel: WorkCalendarViewModel) {
         _viewModel = StateObject(wrappedValue: UploadViewModel(calendarViewModel: calendarViewModel))
     }

    var body: some View {
        VStack {
            Text("근무표 사진을 업로드해주세요")
                .font(.title2)
                .bold()
                .padding(.top, 40)

            Spacer()

            PhotosPicker(selection: $selectedItem, matching: .images) {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 250, height: 180)
                        .overlay(
                            VStack {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("이미지를 선택해주세요")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        )
                }
            }
            .onChange(of: selectedItem) {
                Task {
                    await viewModel.handleImageSelection(item: selectedItem)
                }
            }

            Spacer()

            if !viewModel.filteredLines.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("추출된 스케줄")
                        .font(.headline)
                    ForEach(viewModel.filteredLines, id: \.self) { line in
                        Text(line)
                            .font(.body)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .alert("이미 같은 주의 스케줄이 있습니다. 어떻게 할까요?", isPresented: $viewModel.showingDuplicateAlert) {
            Button("기존 데이터에 추가", role: .none) {
                if let start = viewModel.pendingWeekStart {
                    viewModel.applySchedule(weekStart: start, lines: viewModel.pendingLines)
                }
            }
            Button("기존 데이터 덮어쓰기", role: .destructive) {
                if let start = viewModel.pendingWeekStart {
                    viewModel.calendarViewModel.removeWeek(starting: start)
                    viewModel.applySchedule(weekStart: start, lines: viewModel.pendingLines)
                }
            }
            Button("취소", role: .cancel) { }
        }

        .alert("OCR 실패", isPresented: $viewModel.showingAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("텍스트를 추출하지 못했습니다.")
        }
    }
}


struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UploadView(calendarViewModel: WorkCalendarViewModel())
        }
    }
}
