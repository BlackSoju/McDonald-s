//
//  OCRService.swift
//  McDonald's
//
//  Created by 윤준성 on 5/31/25.
//

import UIKit
import Vision

struct OCRWord {
    let text: String
    let x: CGFloat
    let y: CGFloat
}

protocol OCRServiceProtocol {
    func recognizeText(from image: UIImage, completion: @escaping ([OCRWord]?) -> Void)
}

final class OCRService: OCRServiceProtocol {
    func recognizeText(from image: UIImage, completion: @escaping ([OCRWord]?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }

            let words: [OCRWord] = observations.compactMap { obs in
                guard let topCandidate = obs.topCandidates(1).first else { return nil }
                let box = obs.boundingBox
                return OCRWord(text: topCandidate.string, x: box.midX, y: box.midY)
            }

            completion(words)
        }

        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("OCR Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}
