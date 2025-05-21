// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
struct EffortScorePicker: View {
    private enum DragState: Equatable {
        case dragging(offset: CGFloat)
        case idle
    }

    @Binding var score: AppleEffortScore?
    @State private var totalWidth: CGFloat?
    @State private var dragState: DragState = .idle
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
        guard let totalWidth else { return 0 }
        let numberOfSegmentSpacings = AppleEffortScoreSegment.allCases.count - 1
        let totalSegmentSpacing = CGFloat(numberOfSegmentSpacings) * segmentSpacing
        let stepWidth = (totalWidth - totalSegmentSpacing) / CGFloat(range.count)
        return max(stepWidth, 0)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundSegments

            if score != nil,
               score != .skipped,
               totalWidth != nil { // check required to prevent initial animation glitch
                selectionIndicator
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(.rect) // required for tap gesture in non drawing areas
        .gesture(dragGesture)
        .onGeometryChange(
            for: CGFloat.self,
            of: { $0.size.width },
            action: { totalWidth = $0 }
        )
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
                SegmentBackground(
                    segment: segment,
                    stepWidth: stepWidth,
                    leftHeight: indicatorHeight(at: segment.scores.lowerBound),
                    rightHeight: indicatorHeight(at: segment.scores.upperBound)
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
            .animation(.smooth, value: indicatorOffset)
    }

    private var indicatorHeight: CGFloat {
        let height = indicatorHeight(at: indicatorOffset)
        return max(0, height)
    }

    private var indicatorOffset: CGFloat {
        guard let totalWidth else { return 0 }
        let offset = switch dragState {
        case .dragging(let offset):
            offset - stepWidth / 2 // subtract stepWidth / 2 do horizontally center the indicator to the finger
        case .idle:
            score.map(indicatorOffset(at:)) ?? 0
        }

        let maxValue = totalWidth - stepWidth
        return offset.clamped(to: 0...maxValue)
    }

    private func indicatorOffset(at score: AppleEffortScore) -> CGFloat {
        guard let segmentIndex = score.segmentIndex else { return 0 }

        let step = score.rawValue - 1
        let offset = CGFloat(step) * stepWidth
        let segmentSpacingAtOffset = segmentSpacing * CGFloat(segmentIndex)
        return offset + segmentSpacingAtOffset
    }

    private func indicatorHeight(at score: AppleEffortScore?) -> CGFloat {
        guard let score, let totalWidth else { return 0 }
        let stepWidth = totalWidth / CGFloat(range.count)
        let offsetX = stepWidth * CGFloat(score.rawValue - 1)
        return indicatorHeight(at: offsetX)
    }

    private func indicatorHeight(at offsetX: CGFloat) -> CGFloat {
        stepWidth + offsetX * tan(openingAlpha.radians)
    }

    // MARK: - Tapping and Dragging

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged(handleDragChanged(_:))
            .onEnded(handleDragEnded(_:))
    }

    private func handleDragChanged(_ value: DragGesture.Value) {
        dragState = .dragging(offset: value.location.x)
        score = score(at: value.location.x)
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        score = score(at: value.location.x)
        dragState = .idle
    }

    private func score(at offset: CGFloat) -> AppleEffortScore {
        guard let totalWidth else { return .skipped }
        let stepWidth = totalWidth / CGFloat(range.count)
        let scoreValue = Int(offset / stepWidth) + 1
        return AppleEffortScore(safeScoreValue: scoreValue)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    @Previewable @State var score: AppleEffortScore? = .allOut2

    VStack(spacing: 50) {
        VStack {
            Text(score?.segment?.localizedTitle ?? "common.skipped", bundle: .module)
            Text(score?.rawValue ?? 0, format: .number)
        }
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
