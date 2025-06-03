// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
struct SegmentBackground: View {
    private let color = Color.white.opacity(0.12)
    let segment: WorkoutEffortScoreSegment
    let stepWidth: CGFloat
    let leftHeight: CGFloat
    let rightHeight: CGFloat

    private var numberOfSegments: Int { segment.scores.count }
    private var cornerRadius: CGFloat { stepWidth / 2 }
    private var totalWidth: CGFloat { CGFloat(numberOfSegments) * stepWidth }

    var body: some View {
        color
            .frame(width: totalWidth, height: rightHeight)
            .clipShape(SlantedTopShape(cornerRadius: cornerRadius, leftHeight: leftHeight))
            .overlay(alignment: .bottom, content: segmentDots)
    }

    private func segmentDots() -> some View {
        HStack(spacing: 0) {
            ForEach(0..<numberOfSegments, id: \.self) { _ in
                Circle()
                    .fill(.white.tertiary)
                    .frame(width: dotSize, height: dotSize)
                    .frame(width: stepWidth, alignment: .center) // dot views should use the whole width of a step
            }
        }
        .padding(.bottom, bottomPadding)
    }

    private var bottomPadding: CGFloat {
#if os(watchOS)
        4
#else
        12
#endif
    }

    private var dotSize: CGFloat {
#if os(watchOS)
        2.5
#else
        6
#endif
    }
}

private struct SlantedTopShape: Shape {
    let cornerRadius: CGFloat
    let leftHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        var path = Path()

        // move to bottom left corner
        path.move(to: CGPoint(x: cornerRadius, y: height))

        // bottom left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )

        // left edge
        path.addLine(to: CGPoint(x: 0, y: height - leftHeight + cornerRadius))

        // top left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: height - leftHeight + cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 180),
            endAngle: topLeftAngle,
            clockwise: false
        )

        // top edge (slanted)
        path.addLine(to: topRightTangentPoint(in: rect))

        // top right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: topLeftAngle,
            endAngle: Angle(degrees: 0),
            clockwise: false
        )

        // right edge
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))

        // bottom right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }

    private var topLeftAngle: Angle {
        Angle(degrees: 245)
    }

    private func topRightTangentPoint(in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.width - cornerRadius * 1.32, y: 0.05 * cornerRadius)
    }
}
