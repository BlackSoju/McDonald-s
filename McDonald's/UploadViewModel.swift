//
//  UploadViewModel.swift
//  McDonald's
//
//  Created by 윤준성 on 5/27/25.
//

import SwiftUI
import Vision
import PhotosUI

struct OCRWord {
    let text: String
    let x: CGFloat
    let y: CGFloat
}

class UploadViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var filteredLines: [String] = []
    @Published var showingAlert = false
    @Published var showingDuplicateAlert = false
    @Published var pendingWeekStart: Date? = nil
    @Published var pendingLines: [String] = []

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
            recognizeText(from: uiImage)
        }
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

            let words: [OCRWord] = observations.compactMap { obs in
                guard let topCandidate = obs.topCandidates(1).first else { return nil }
                let box = obs.boundingBox
                return OCRWord(text: topCandidate.string, x: box.midX, y: box.midY)
            }

            DispatchQueue.main.async {
                self.processOCRWords(words)
            }
        }

        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }

    func processOCRWords(_ words: [OCRWord]) {
        let fullText = words.map { $0.text }.joined(separator: "\n")
        self.pendingWeekStart = extractWeekStartDate(from: fullText)

        let weekdaysSet = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
        let groupedLines = groupWordsIntoLines(words)

        var weekdays: [String] = []
        var times: [String] = []

        for line in groupedLines {
            let lineText = line.map { $0.text }.joined(separator: " ").replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)

            for day in weekdaysSet {
                if lineText.contains(day) && !weekdays.contains(day) {
                    weekdays.append(day)
                }
            }

            let timePattern = #"\d{1,2}:\d{2}\s*~\s*\d{1,2}:\d{2}"#
            let offPattern = #"\b(OFF|오프|주휴)\b"#

            if let match = lineText.range(of: timePattern, options: .regularExpression) {
                times.append(String(lineText[match]))
            } else if let offMatch = lineText.range(of: offPattern, options: .regularExpression) {
                times.append(String(lineText[offMatch]))
            }
        }

        if times.count > 7 {
            times = Array(times.prefix(7))
        }

        var resultLines: [String] = []
        if weekdays.count == 7 && times.count == 7, let start = self.pendingWeekStart {
            for i in 0..<7 {
                resultLines.append("\(weekdays[i]) \(times[i])")
            }
            self.filteredLines = resultLines
            self.pendingLines = resultLines

            if calendarViewModel.containsWeek(starting: start) {
                self.showingDuplicateAlert = true
            } else {
                applySchedule(weekStart: start, lines: resultLines)
            }
        } else {
            print("⚠️ 요일 수(\(weekdays.count))와 시간 수(\(times.count))가 일치하지 않거나 날짜 인식 실패")
            self.filteredLines = []
            self.pendingLines = []
            self.showingAlert = true
        }
    }

    func applySchedule(weekStart: Date, lines: [String]) {
        for line in lines {
            let parts = line.split(separator: " ", maxSplits: 1).map { String($0) }
            guard parts.count == 2 else { continue }
            let weekday = parts[0]
            let timeText = parts[1]

            if timeText.contains("OFF") || timeText.contains("주휴") || timeText.contains("오프") {
                let label = timeText.contains("주휴") ? "주휴" : "OFF"
                calendarViewModel.addRestDay(weekday: weekday, label: label, weekStartDate: weekStart)
            } else if timeText.contains("~") {
                calendarViewModel.addWorkDay(weekday: weekday, timeRange: timeText, weekStartDate: weekStart)
            }
        }
    }

    func groupWordsIntoLines(_ words: [OCRWord], yThreshold: CGFloat = 0.02) -> [[OCRWord]] {
        var lines: [[OCRWord]] = []
        let sorted = words.sorted { $0.y > $1.y }

        for word in sorted {
            if let index = lines.firstIndex(where: { abs($0.first!.y - word.y) < yThreshold }) {
                lines[index].append(word)
            } else {
                lines.append([word])
            }
        }

        return lines.filter { line in
            let combinedText = line.map { $0.text }.joined(separator: " ")
            return combinedText.contains("~") || combinedText.contains("OFF") || combinedText.contains("주휴") || combinedText.contains("요일")
        }
    }

    func extractWeekStartDate(from text: String) -> Date? {
        let pattern = #"(\d{4})[.\-/](\d{2})[.\-/](\d{2})\s*~\s*\d{4}[.\-/]\d{2}[.\-/]\d{2}"#
        let regex = try? NSRegularExpression(pattern: pattern)

        if let match = regex?.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
            let year = Int((text as NSString).substring(with: match.range(at: 1)))!
            let month = Int((text as NSString).substring(with: match.range(at: 2)))!
            let day = Int((text as NSString).substring(with: match.range(at: 3)))!

            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return Calendar.current.date(from: components)
        }
        return nil
    }
}
