//
//  CustomWheel.swift
//  McDonald's
//
//  Created by 윤준성 on 6/20/25.
//

import SwiftUI

struct CustomWheel: View {
    @Binding var selection: Int
    let range: Range<Int>
    let color: Color
    let highlightColor: Color
    let unitCount: Int

    private let totalRepeatCount = 100
    private let rowHeight: CGFloat = 48

    var loopedRange: [Int] {
        Array(repeating: Array(range), count: totalRepeatCount).flatMap { $0 }
    }

    @State private var closestIndex: Int = 0
    @State private var scrollDebounceTimer: Timer?

    var body: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(loopedRange.indices, id: \.self) { index in
                            let value = loopedRange[index]
                            let isSelected = index == closestIndex
                            Text(String(format: "%02d", value))
                                .font(.system(size: 24, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .primary : .gray.opacity(0.5))
                                .frame(height: rowHeight)
                                .frame(maxWidth: .infinity)
                                .background(
                                    GeometryReader { itemGeo in
                                        Color.clear.preference(
                                            key: OffsetPreferenceKey.self,
                                            value: [index: abs(itemGeo.frame(in: .named("scrollView")).midY - geo.size.height / 2)]
                                        )
                                    }
                                )
                                .id(index)
                        }
                    }
                    .padding(.vertical, (geo.size.height - rowHeight) / 2)
                }
                .coordinateSpace(name: "scrollView")
                .onAppear {
                    let midIndex = (totalRepeatCount / 2) * unitCount + selection
                    closestIndex = midIndex
                    proxy.scrollTo(midIndex, anchor: .center)
                }
                .onPreferenceChange(OffsetPreferenceKey.self) { distances in
                    scrollDebounceTimer?.invalidate()
                    scrollDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        guard let closest = distances.min(by: { $0.value < $1.value })?.key else { return }
                        let offset = distances[closest] ?? 0
                        if closest != closestIndex || offset > 1.0 {
                            closestIndex = closest
                            let value = loopedRange[closest % loopedRange.count] % unitCount
                            selection = value
                            withAnimation(.interactiveSpring(response: 0.45, dampingFraction: 0.85, blendDuration: 0.25)) {
                                proxy.scrollTo(closest, anchor: .center)
                            }
                        }
                    }
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
                                .frame(height: rowHeight)
                                .shadow(radius: 1)
                            Spacer()
                        }
                    }
                )
            }
        }
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}
