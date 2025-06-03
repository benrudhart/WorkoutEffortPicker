// Copyright (c) 2025 Ben Rudhart

import SwiftUI

@available(iOS 18.0, watchOS 11.0, *)
struct UnauthorizedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Label {
                    Text("unauthorized.title", bundle: .module)
                } icon: {
                    Image(systemName: "hand.raised.circle.fill")
                        .foregroundStyle(.yellow)
                        .imageScale(.large)
                }
                .font(.title3)

                Text("unauthorized.message", bundle: .module)
                    .font(.caption)

                instructions
            }
        }
        .scenePadding()
    }

    @ViewBuilder
    private var instructions: some View {
        label(key: "unauthorized.step1", step: 1)
        label(key: "unauthorized.step2", step: 2)
        label(key: "unauthorized.step3", step: 3)
        label(key: "unauthorized.step4", step: 4)
    }

    private func label(key: LocalizedStringKey, step: Int) -> some View {
        Label {
            Text(key, bundle: .module)
        } icon: {
            Image(systemName: "\(step).circle.fill")
                .foregroundStyle(.yellow)
                .symbolRenderingMode(.hierarchical)
                .imageScale(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.headline.weight(.semibold))
    }
}

@available(iOS 18.0, watchOS 11.0, *)
#Preview {
    NavigationStack {
        UnauthorizedView()
    }
    .preferredColorScheme(.dark)
}
