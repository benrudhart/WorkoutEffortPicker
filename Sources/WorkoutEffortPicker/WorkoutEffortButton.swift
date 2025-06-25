// Copyright (c) 2025 Ben Rudhart

import SwiftUI
import HealthKit

/// A Button (iOS) or a NavigationLink (watchOS) that displays the selected effort shows a custom picker when selected as seen in Apples Fitness App (iOS) or after a workout with the Workout app (watchOS).
@available(iOS 18.0, watchOS 11.0, *)
public struct WorkoutEffortButton: View {
    let workout: HKWorkout
    var effortScoreService: EffortScoreServiceProtocol = EffortScoreService()
    @State private var score: WorkoutEffortScore?
    @State private var isScoreViewPresented = false
    @State private var isPermissionDenied: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    public init(workout: HKWorkout) {
        self.workout = workout
        self.score = nil
    }

    fileprivate init(workout: HKWorkout, service: EffortScoreServiceProtocol) {
        self.workout = workout
        self.effortScoreService = service
    }

    public var body: some View {
        content
            .task(id: workout.uuid, fetchScore)
            .onChange(of: scenePhase, initial: true) { _, newValue in
                guard newValue == .active else { return }
                updatePermissionState()
            }
            .preferredColorScheme(.dark)
    }

    private func updatePermissionState() {
        isPermissionDenied = HKHealthStore().authorizationStatus(for: .effortType) == .sharingDenied
    }

    @Sendable
    private func fetchScore() async {
        score = nil

        do {
            score = try await effortScoreService.fetchScore(workout: workout)
        } catch {
            if !(error is CancellationError) {
                assertionFailure(error.localizedDescription)
            }
        }
    }

    private var content: some View {
#if os(iOS)
        Button {
            isScoreViewPresented = true
        } label: {
            buttonLabel
        }
        .foregroundStyle(.white)
        .sheet(isPresented: $isScoreViewPresented, content: scoreView)
#else
        NavigationLink {
            scoreView()
        } label: {
            buttonLabel
        }
        .buttonBorderShape(.roundedRectangle)
        .tint(Color.white.secondary)
#endif
    }

    private var buttonLabel: some View {
        VStack(alignment: .leading, spacing: 8) {
            title
#if os(watchOS)
            contentLabel
#else
            labeledContent
#endif
        }
    }

    @ViewBuilder
    private func scoreView() -> some View {
#if os(iOS)
        NavigationStack(root: scoreContent)
#else
        scoreContent()
#endif
    }

    @ViewBuilder
    private func scoreContent() -> some View {
        if isPermissionDenied {
            UnauthorizedView()
        } else {
            EffortScoreView(score: score) { score in
                self.score = score

                Task {
                    do {
                        try await effortScoreService.saveScore(score, workout: workout)
                    } catch {
                        assertionFailure(error.localizedDescription)
                    }
                }
            }
        }
    }

    private var title: some View {
        HStack {
            Text("scoreCell.effort", bundle: .module)
                .foregroundStyle(.white)
#if os(watchOS)
                .frame(maxWidth: .infinity, alignment: .leading)
#endif
            if score != nil {
                Image(systemName: "plusminus")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
        }
        .font(.subheadline)
#if os(watchOS)
        .textCase(.uppercase)
#endif
    }

    private var labeledContent: some View {
        HStack {
            contentLabel
                .frame(maxWidth: .infinity, alignment: .leading)
            scoreIcon
        }
        .font(.title2)
    }

    private var contentLabel: some View {
        HStack {
            EffortScoreIcon(score: score)
                .symbolRenderingMode(score != nil ? .hierarchical : .monochrome)
#if os(watchOS)
                .imageScale(.small)
#endif

            if let score = score {
                let key = score.segment?.localizedTitle ?? "common.skipped"
                Text(key, bundle: .module)
            } else {
                Text("scoreCell.addEffort", bundle: .module)
                    .font(.title)
#if os(watchOS)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
#endif
            }
        }
        .foregroundStyle(color)
#if os(watchOS)
        .font(.title2)
        .fontWeight(.medium)
        .fontDesign(.rounded)
#endif
    }

    private var color: some ShapeStyle {
        score?.color ?? .gray
    }

    /// TODO: improve icon by creating custom one
    private var scoreIcon: some View {
        let value = Double(score?.rawValue ?? 0) / Double(WorkoutEffortScore.allOut2.rawValue)
        return Image(systemName: "cellularbars", variableValue: value)
            .foregroundStyle(color)
            .imageScale(.large)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        List {
            let previewWorkout = HKWorkout(activityType: .americanFootball, start: .now, end: .now)
            let service = PreviewEffortScoreService(score: .allOut2)
            WorkoutEffortButton(workout: previewWorkout, service: service)
        }
    }
    .environment(\.locale, .init(identifier: "de"))
}

@available(iOS 18.0, watchOS 11.0, *)
private struct PreviewEffortScoreService: EffortScoreServiceProtocol {
    let score: WorkoutEffortScore
    func saveScore(_ score: WorkoutEffortScore?, workout: HKWorkout) async throws {}

    func fetchScore(workout: HKWorkout) async throws -> WorkoutEffortScore? {
        score
    }
}
