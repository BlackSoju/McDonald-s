//
//  UploadViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import SwiftUI
import Vision
import PhotosUI

class UploadViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var extractedText: String = ""
    @Published var filteredLines: [String] = []
    @Published var showingAlert = false
    
    var calendarViewModel: WorkCalendarViewModel
    
    init(calendarViewModel: WorkCalendarViewModel) {
        self.calendarViewModel = calendarViewModel
    }
    
    func handleImageSelection(item: PhotosPickerItem?) async {
        guard let item = item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }
        
        await MainActor.run {
            self.image = uiImage
        }
        recognizeText(from: uiImage)
    }
    
    func recognizeText(from uiImage: UIImage) {
        guard let cgImage = uiImage.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                DispatchQueue.main.async {
                    self.showingAlert = true
                }
                return
            }
            
            let texts = observations.compactMap { $0.topCandidates(1).first?.string }
            let combined = texts.joined(separator: "\n")
            //            print("🧾 OCR 결과 전체 텍스트:")
            //            print(combined)
            
            DispatchQueue.main.async {
                self.extractedText = combined
                self.parseWorkInfo(from: combined)
            }
        }
        
        request.recognitionLanguages = ["ko-KR"]
        request.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    func parseWorkInfo(from rawText: String) {
        guard let (weekStart, lines) = extractOpenWeekSchedule(from: rawText) else {
            print("❌ 접기 표시된 주를 찾지 못했습니다.")
            return
        }

        let weekdayList = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
        var resultLines: [String] = []

        // 요일 줄 추출
        var weekdays: [String] = []
        var times: [String] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if weekdayList.contains(trimmed) {
                weekdays.append(trimmed)
            } else {
                times.append(trimmed)
            }
        }

        guard weekdays.count == times.count else {
            print("⚠️ 요일 수와 시간 수가 일치하지 않습니다.")
            return
        }

        for i in 0..<weekdays.count {
            let weekday = weekdays[i]
            let timeText = times[i]

            print("✅ \(weekday) → '\(timeText)'")

            if timeText.contains("OFF") || timeText.contains("주휴") || timeText.contains("오프") {
                let label = timeText.contains("주휴") ? "주휴" : "OFF"
                calendarViewModel.addRestDay(weekday: weekday, label: label, weekStartDate: weekStart)
            } else if timeText.contains("~") {
                calendarViewModel.addWorkDay(weekday: weekday, timeRange: timeText, weekStartDate: weekStart)
            } else {
                print("⚠️ 시간 형식이 아니어서 무시됨")
            }

            resultLines.append("\(weekday) \(timeText)")
        }

        self.filteredLines = resultLines
    }

    
    func extractOpenWeekSchedule(from text: String) -> (Date, [String])? {
        let lines = text.components(separatedBy: .newlines)
        let regex = try! NSRegularExpression(pattern: #"(\d{4})[-./](\d{2})[-./](\d{2})\s*~\s*(\d{4})[-./](\d{2})[-./](\d{2})"#)
        
        var weekStartDate: Date?
        var resultLines: [String] = []
        
        for i in 0..<lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespaces)
            
            if trimmed.contains("접기") {
                for offset in (1...5) {
                    let j = i - offset
                    if j >= 0 {
                        let maybeDateLine = lines[j]
                        if let match = regex.firstMatch(in: maybeDateLine, range: NSRange(maybeDateLine.startIndex..., in: maybeDateLine)) {
                            let yearRange = match.range(at: 1)
                            let monthRange = match.range(at: 2)
                            let dayRange = match.range(at: 3)
                            
                            let year = String(maybeDateLine[Range(yearRange, in: maybeDateLine)!])
                            let month = String(maybeDateLine[Range(monthRange, in: maybeDateLine)!])
                            let day = String(maybeDateLine[Range(dayRange, in: maybeDateLine)!])
                            
                            let startStr = "\(year)-\(month)-\(day)"
                            weekStartDate = DateFormatter.yyyyMMdd.date(from: startStr)
                            break
                        }
                    }
                }
                
                for k in (i+1)..<lines.count {
                    let content = lines[k].trimmingCharacters(in: .whitespaces)
                    if content.contains("상세") { break }
                    if content.contains("요일") || content.contains("OFF") || content.contains("주휴") || content.contains("~") {
                        resultLines.append(content)
                    }
                }
                break
            }
        }
        
        if let start = weekStartDate, !resultLines.isEmpty {
            return (start, resultLines)
        }
        return nil
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

