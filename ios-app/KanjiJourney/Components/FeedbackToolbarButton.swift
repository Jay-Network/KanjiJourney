import SwiftUI

/// Feedback entry point in the top bar of the four main tabs (Main, Study, Play, Collect).
/// Matches Android's top-bar IconButton on Home, Games, Study and Collection.
/// Android renders no floating button, so iOS does not either (see FeedbackDialog.swift).
struct FeedbackToolbarButton: View {
    @EnvironmentObject var feedbackViewModel: FeedbackViewModel

    var body: some View {
        Button {
            feedbackViewModel.openDialog()
        } label: {
            Image(systemName: "envelope.fill").accessibilityHidden(true)
                .foregroundColor(GlassColors.textPrimary)
        }
        .accessibilityLabel("Send feedback")
    }
}

extension View {
    /// Top bar for a main tab: the feedback entry point plus the dark bar style Home already uses.
    func mainTabToolbar() -> some View {
        self
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    FeedbackToolbarButton()
                }
            }
            .toolbarBackground(GlassColors.surfaceDark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
