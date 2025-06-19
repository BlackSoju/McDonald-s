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
    @Published var image: UIImage?
    @Published var filteredLines: [String] = []
    @Published var showingAlert = false
    @Published var showingDuplicateAlert = false
    @Published var pendingWeekStart: Date?
    @Published var pendingLines: [String] = []

    private let weekdaysSet = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
    private let ocrService: OCRServiceProtocol
    var calendarViewModel: WorkCalendarViewModel

    init(calendarViewModel: WorkCalendarViewModel, ocrService: OCRServiceProtocol = OCRService()) {
        self.calendarViewModel = calendarViewModel
        self.ocrService = ocrService
    }

    func handleImageSelection(item: PhotosPickerItem?) async {
        guard let item = item,
              let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else { return }

        await MainActor.run {
            self.image = uiImage
        }

        ocrService.recognizeText(from: uiImage) { [weak self] words in
            Task { @MainActor in
                guard let self = self else { return }

                if let words = words {
                    self.processOCRWords(words)
                } else {
                    self.showingAlert = true
                }
            }
        }
    }


    func processOCRWords(_ words: [OCRWord]) {
        let fullText = words.map { $0.text }.joined(separator: "\n")
        self.pendingWeekStart = extractWeekStartDate(from: fullText)

        let groupedLines = groupWordsIntoLines(words)
        var weekdays: [String] = []
        var times: [String] = []

        for line in groupedLines {
            let lineText = line.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespaces)

            if let day = weekdaysSet.first(where: { lineText.contains($0) }), !weekdays.contains(day) {
                weekdays.append(day)
            }

            if let time = extractTime(from: lineText) {
                times.append(time)
            }
        }

        if times.count > 7 { times = Array(times.prefix(7)) }

        guard weekdays.count == 7, times.count == 7, let start = self.pendingWeekStart else {
            print("⚠️ 요일 수(\(weekdays.count))와 시간 수(\(times.count))가 일치하지 않거나 날짜 인식 실패")
            self.filteredLines = []
            self.pendingLines = []
            self.showingAlert = true
            return
        }

        let resultLines = (0..<7).map { "\(weekdays[$0]) \(times[$0])" }
        self.filteredLines = resultLines
        self.pendingLines = resultLines

        if calendarViewModel.containsWeek(starting: start) {
            self.showingDuplicateAlert = true
        } else {
            applySchedule(weekStart: start, lines: resultLines)
        }
    }

    func extractTime(from text: String) -> String? {
        let timePattern = #"\d{1,2}:\d{2}\s*~\s*\d{1,2}:\d{2}"#
        let offPattern = #"\b(OFF|오프|주휴)\b"#

        if let match = text.range(of: timePattern, options: .regularExpression) {
            return String(text[match])
        } else if let offMatch = text.range(of: offPattern, options: .regularExpression) {
            return String(text[offMatch])
        }
        return nil
    }

    func applySchedule(weekStart: Date, lines: [String]) {
        for line in lines {
            let parts = line.split(separator: " ", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }

            let weekday = parts[0]
            let timeText = parts[1]

            if ["OFF", "오프", "주휴"].contains(where: { timeText.contains($0) }) {
                let label = timeText.contains("주휴") ? "주휴" : "OFF"
                calendarViewModel.addRestDay(weekday: weekday, label: label, weekStartDate: weekStart)
            } else {
                calendarViewModel.addWorkDay(weekday: weekday, timeRange: timeText, weekStartDate: weekStart)
            }
        }
    }

    func groupWordsIntoLines(_ words: [OCRWord], yThreshold: CGFloat = 0.02) -> [[OCRWord]] {
        var lines: [[OCRWord]] = []
        let sortedWords = words.sorted { $0.y > $1.y }

        for word in sortedWords {
            if let index = lines.firstIndex(where: { abs($0.first!.y - word.y) < yThreshold }) {
                lines[index].append(word)
            } else {
                lines.append([word])
            }
        }

        return lines.filter {
            let lineText = $0.map { $0.text }.joined(separator: " ")
            return weekdaysSet.contains(where: lineText.contains) ||
                   lineText.contains("~") ||
                   lineText.contains("OFF") ||
                   lineText.contains("주휴")
        }
    }

    func extractWeekStartDate(from text: String) -> Date? {
        let lines = text.components(separatedBy: .newlines)
        let weekRangePattern = #"20\d{2}-\d{2}-\d{2}\s*~\s*20\d{2}-\d{2}-\d{2}"#
        let regex = try? NSRegularExpression(pattern: weekRangePattern)

        var matchedRanges: [(String, Int)] = []

        for (index, line) in lines.enumerated() {
            if let _ = regex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                matchedRanges.append((line, index))
            }
        }

        if let targetIndex = lines.firstIndex(where: { $0.contains("월요일") }) {
            let sorted = matchedRanges.sorted { abs($0.1 - targetIndex) < abs($1.1 - targetIndex) }
            if let (matchedLine, _) = sorted.first {
                let datePattern = #"(\d{4})-(\d{2})-(\d{2})"#
                if let dateMatch = matchedLine.range(of: datePattern, options: .regularExpression) {
                    let dateString = String(matchedLine[dateMatch])
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.date(from: dateString)
                }
            }
        }

        return nil
    }
}
