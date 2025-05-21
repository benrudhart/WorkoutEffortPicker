// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
struct EffortScorePicker: View {
    @Binding var score: AppleEffortScore?
    @State private var totalWidth: CGFloat = 0
    @State private var draggingOffset: CGFloat?
    @Namespace private var indicatorAnimation
    private let range = AppleEffortScore.easy1 ... .allOut2
    private let backgroundColor: Color = .white.opacity(0.2)
#if os(iOS)
    private let segmentSpacing: CGFloat = 8
#else
    private let segmentSpacing: CGFloat = 2

    private var crownBinding: Binding<Double> {
        Binding {
            Double(score?.rawValue ?? range.lowerBound.rawValue)
        } set: { newValue in
            let scoreValue = Int(newValue.rounded())
            score = .init(safeScoreValue: scoreValue)
        }
    }
#endif

    /// The opening angle of the picker-triangle shape, measured in the bottom left corner
    /// The value has been determined by measuring the actual implementation on the phone
    private let openingAlpha = Angle(degrees: 20.1)

    /// the distributed stepWidth which takes the segment spacings into account
    private var stepWidth: CGFloat {
        let numberOfSegmentSpacings = AppleEffortScoreSegment.allCases.count - 1
        let totalSegmentSpacing = CGFloat(numberOfSegmentSpacings) * segmentSpacing
        let stepWidth = (totalWidth - totalSegmentSpacing) / CGFloat(range.count)
        return max(stepWidth, 0)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundSegments

            if score != nil {
                selectionIndicator
            }
        }
        .frame(maxWidth: .infinity)
        .updateWidth($totalWidth)
        .contentShape(.rect) // required for tap gesture in non drawing areas
        .onTapGesture { score = score(at: $0.x) } // TODO: should already update on finger down, no only on finger up
#if os(watchOS)
        .focusable(true)
        .digitalCrownRotation(
            crownBinding,
            from: Double(range.lowerBound.rawValue),
            through: Double(range.upperBound.rawValue),
            sensitivity: .low
        )
#endif
    }

    private var backgroundSegments: some View {
        HStack(alignment: .bottom, spacing: segmentSpacing) {
            ForEach(AppleEffortScoreSegment.allCases) { segment in
                let scores = segment.scores
                SegmentBackground(
                    segment: segment,
                    stepWidth: stepWidth,
                    leftHeight: indicatorHeight(at: scores.first!),
                    rightHeight: indicatorHeight(at: scores.last!)
                )
            }
        }
    }

    // MARK: - Indicator

    private var selectionIndicator: some View {
        Capsule()
            .fill(.white)
            .frame(width: stepWidth, height: indicatorHeight)
            .matchedGeometryEffect(id: "selectionIndicator", in: indicatorAnimation)
            .offset(x: indicatorOffset)
            .gesture(indicatorDragGesture)
            .animation(.smooth, value: score)
    }

    private var indicatorHeight: CGFloat {
        let height = if draggingOffset != nil {
            // TODO: this seems to be off for higher values
            indicatorHeight(at: indicatorOffset)
        } else {
            indicatorHeight(at: score)
        }

        return max(0, height)
    }

    private var indicatorOffset: CGFloat {
        guard let score else { return 0 }
        var offset = indicatorOffset(at: score)

        if let draggingOffset {
            offset += draggingOffset
        }

        let maxValue = totalWidth - stepWidth
        return offset.clamped(to: 0...maxValue)
    }

    private func indicatorOffset(at score: AppleEffortScore) -> CGFloat {
        let step = score.rawValue - 1
        let offset = CGFloat(step) * stepWidth
        let segmentSpacingAtOffset = segmentSpacing * CGFloat(score.segmentIndex)
        return offset + segmentSpacingAtOffset
    }

    private func indicatorHeight(at score: AppleEffortScore?) -> CGFloat {
        guard let score else { return 0 }
        let offsetX = stepWidth * CGFloat(score.rawValue - 1)
        return indicatorHeight(at: offsetX)
    }

    private func indicatorHeight(at offsetX: CGFloat) -> CGFloat {
        let height = offsetX * tan(openingAlpha.radians)
        let min = stepWidth
        return min + height
    }

    // MARK: - Tapping & Dragging

    private var indicatorDragGesture: some Gesture {
        DragGesture()
            .onChanged { draggingOffset = $0.translation.width }
            .onEnded { handleDragEnded(value: $0) }
    }

    private func handleDragEnded(value: DragGesture.Value) {
        draggingOffset = value.translation.width + stepWidth / 2 // when releasing we need + stepWidth / 2 to snap to the proper score
        let newScore = score(at: indicatorOffset)
        score = newScore
        draggingOffset = nil
        // TODO: fix snapping animation -> indicator must not jump back to current position
    }

    /// - note: Due to the differing sizes of segments and the spacing the actual geometric middle between scores might slightly differ from the ones computed and used in the implementation. But it is "close enough" for the user not noticing the difference.
    private func score(at offset: CGFloat) -> AppleEffortScore {
        let scoreWidth = totalWidth / CGFloat(range.count)
        let scoreValue = Int(offset / scoreWidth) + 1
        return AppleEffortScore(safeScoreValue: scoreValue)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
private extension View {
    func updateWidth(_ width: Binding<CGFloat>) -> some View {
        background {
            GeometryReader { proxy in
                Color.clear
                    .onChange(of: proxy.size.width, initial: true) { _, newValue in
                        width.wrappedValue = newValue
                    }
            }
        }
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    @Previewable @State var score: AppleEffortScore? = .easy1

    VStack(spacing: 50) {
        Text(score?.segment.localizedTitle ?? "common.skipped", bundle: .module)
#if os(iOS)
            .font(.largeTitle)
            .fontWeight(.bold)
#endif

        EffortScorePicker(score: $score)
    }
    .scenePadding()
    .preferredColorScheme(.dark)
    .frame(maxHeight: .infinity)
    .background(BackgroundGradient(score: score))
}
