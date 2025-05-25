// Copyright (c) 2025 Ben Rudhart

import Foundation

@available(iOS 18.0, watchOS 11.0, *)
@MainActor
public protocol AppleEffortScoreCellViewModelProtocol {
    var score: AppleEffortScore? { get }
    var isPermissionDenied: Bool { get }
    func saveScore(_ score: AppleEffortScore?)
    func onAppear()
    func onForeground()
}
