// Copyright (c) 2025 Ben Rudhart

import SwiftUI
import HealthKit

@available(iOS 18.0, watchOS 11.0, *)
public struct AppleEffortScoreCell: View {
    @State private var viewModel: AppleEffortScoreCellViewModelProtocol
    @State private var isScoreViewPresented = false

    /// convenience initializer, provides the default ViewModel
    public init(workout: HKWorkout) {
        self.viewModel = AppleEffortScoreCellViewModel(workout: workout)
    }

    public init(viewModel: AppleEffortScoreCellViewModelProtocol) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .onAppear(perform: viewModel.onAppear)
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
#endif
    }

    private var buttonLabel: some View {
        VStack(alignment: .leading) {
            title
#if os(watchOS)
            contentLabel
#else
            labeledContent
#endif
        }
    }

    private func scoreView() -> some View {
        EffortScoreView(score: viewModel.score, onSaveScore: saveScore(_:))
    }

    private func saveScore(_ score: AppleEffortScore?) {
        viewModel.saveScore(score)
    }

    private var title: some View {
        HStack {
            Text("scoreCell.effort", bundle: .module)
#if os(watchOS)
                .frame(maxWidth: .infinity, alignment: .leading)
#endif
            Image(systemName: "plusminus")
                .imageScale(.small)
                .foregroundStyle(.secondary)
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
            }
        }
        .foregroundStyle(color)
#if os(watchOS)
        .font(.title2)
        .fontWeight(.medium)
        .fontDesign(.rounded)
#endif
    }

    private var color: Color {
        viewModel.score?.color ?? .gray
    }

    /// TODO: improve icon by creating custom one
    private var scoreIcon: some View {
        let value = Double(viewModel.score?.rawValue ?? 0) / Double(AppleEffortScore.allOut2.rawValue)
        return Image(systemName: "cellularbars", variableValue: value)
            .foregroundStyle(color)
            .imageScale(.large)
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        List {
            AppleEffortScoreCell(viewModel: PreviewScoreViewModel())
        }
    }
    .environment(\.locale, .init(identifier: "de"))
}

@available(iOS 18.0, watchOS 11.0, *)
@Observable
private class PreviewScoreViewModel: AppleEffortScoreCellViewModelProtocol {
    var score: AppleEffortScore? = .allOut1

    func saveScore(_ score: AppleEffortScore?) {
        self.score = score
    }

    func onAppear() {}
}
