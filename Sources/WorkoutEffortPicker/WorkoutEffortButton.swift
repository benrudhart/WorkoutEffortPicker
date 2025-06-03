// Copyright (c) 2025 Ben Rudhart

import SwiftUI
import HealthKit

/// A Button (iOS) or a NavigationLink (watchOS) that displays the selected effort shows a custom picker when selected as seen in Apples Fitness App (iOS) or after a workout with the Workout app (watchOS).
@available(iOS 18.0, watchOS 11.0, *)
public struct WorkoutEffortButton: View {
    @State private var viewModel: WorkoutEffortButtonViewModelProtocol
    @State private var isScoreViewPresented = false
    @Environment(\.scenePhase) private var scenePhase

    /// convenience initializer, provides the default ViewModel
    public init(workout: HKWorkout) {
        self.viewModel = WorkoutEffortButtonViewModel(workout: workout)
    }

    public init(viewModel: WorkoutEffortButtonViewModelProtocol) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .onAppear(perform: viewModel.onAppear)
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active {
                    viewModel.onForeground()
                }
            }
            .preferredColorScheme(.dark)
    }

    @ViewBuilder
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
        if viewModel.isPermissionDenied {
            UnauthorizedView()
        } else {
            EffortScoreView(score: viewModel.score, onSaveScore: saveScore(_:))
        }
    }

    private func saveScore(_ score: WorkoutEffortScore?) {
        viewModel.saveScore(score)
    }

    private var title: some View {
        HStack {
            Text("scoreCell.effort", bundle: .module)
                .foregroundStyle(.white)
#if os(watchOS)
                .frame(maxWidth: .infinity, alignment: .leading)
#endif
            if viewModel.score != nil {
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
            EffortScoreIcon(score: viewModel.score)
                .symbolRenderingMode(viewModel.score != nil ? .hierarchical : .monochrome)
#if os(watchOS)
                .imageScale(.small)
#endif

            if let score = viewModel.score {
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
        viewModel.score?.color ?? .gray
    }

    /// TODO: improve icon by creating custom one
    private var scoreIcon: some View {
        let value = Double(viewModel.score?.rawValue ?? 0) / Double(WorkoutEffortScore.allOut2.rawValue)
        return Image(systemName: "cellularbars", variableValue: value)
            .foregroundStyle(color)
            .imageScale(.large)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        List {
            WorkoutEffortButton(viewModel: PreviewScoreViewModel())
        }
    }
    .environment(\.locale, .init(identifier: "de"))
}

@available(iOS 18.0, watchOS 11.0, *)
@Observable
private class PreviewScoreViewModel: WorkoutEffortButtonViewModelProtocol {
    var score: WorkoutEffortScore?
    var isPermissionDenied = false

    func saveScore(_ score: WorkoutEffortScore?) {
        self.score = score
    }

    func onAppear() {}
    func onForeground() {}
}
