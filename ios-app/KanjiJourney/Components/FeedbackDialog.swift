import SwiftUI
import SharedCore

/// Feedback dialog. Mirrors Android's FeedbackDialog.kt.
/// Category chips, text input, submit, feedback history list.
struct FeedbackDialogView: View {
    @ObservedObject var viewModel: FeedbackViewModel
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    viewModel.closeDialog()
                    onDismiss()
                }

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Send Feedback")
                        .font(KanjiJourneyTheme.headlineSmall).fontWeight(.bold)
                    Spacer()
                    Button {
                        viewModel.closeDialog()
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    }
                }
                .padding(16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Category selection
                        Text("Category")
                            .font(KanjiJourneyTheme.labelMedium).fontWeight(.semibold)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(FeedbackCategory.allCases, id: \.self) { category in
                                    Button {
                                        viewModel.selectCategory(category)
                                    } label: {
                                        Text(category.label)
                                            .font(KanjiJourneyTheme.labelSmall)
                                            .foregroundColor(viewModel.selectedCategory == category ? .white : KanjiJourneyTheme.primary)
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(viewModel.selectedCategory == category ? KanjiJourneyTheme.primary : KanjiJourneyTheme.surfaceVariant)
                                            .cornerRadius(16)
                                    }
                                }
                            }
                        }

                        // Feedback text
                        VStack(alignment: .leading, spacing: 4) {
                            TextEditor(text: $viewModel.feedbackText)
                                .frame(height: 120)
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(viewModel.error != nil ? KanjiJourneyTheme.error : KanjiJourneyTheme.onSurfaceVariant.opacity(0.3), lineWidth: 1)
                                )
                                .overlay(alignment: .topLeading) {
                                    if viewModel.feedbackText.isEmpty {
                                        Text("Tell us what you think...")
                                            .foregroundColor(KanjiJourneyTheme.onSurfaceVariant.opacity(0.5))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 16)
                                            .allowsHitTesting(false)
                                    }
                                }

                            Text("\(viewModel.feedbackText.count)/1000")
                                .font(KanjiJourneyTheme.labelSmall)
                                .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                        }

                        // Error/Success
                        if let error = viewModel.error {
                            Text(error)
                                .font(KanjiJourneyTheme.bodySmall)
                                .foregroundColor(KanjiJourneyTheme.error)
                        }
                        if let success = viewModel.successMessage {
                            Text(success)
                                .font(KanjiJourneyTheme.bodySmall)
                                .foregroundColor(KanjiJourneyTheme.primary)
                        }

                        // Submit button
                        Button {
                            viewModel.submitFeedback()
                        } label: {
                            HStack {
                                if viewModel.isSubmitting {
                                    ProgressView()
                                        .frame(width: 20, height: 20)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Send Feedback")
                                }
                            }
                            .fontWeight(.bold).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(
                                (!viewModel.isSubmitting && viewModel.feedbackText.count >= 10)
                                ? KanjiJourneyTheme.primary : Color.gray
                            )
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isSubmitting || viewModel.feedbackText.count < 10)

                        // Feedback history
                        Text("Your Previous Feedback")
                            .font(KanjiJourneyTheme.titleSmall).fontWeight(.semibold)

                        if viewModel.isLoadingHistory {
                            ProgressView().padding(16)
                        } else if viewModel.feedbackList.isEmpty {
                            Text("No feedback submitted yet")
                                .font(KanjiJourneyTheme.bodyMedium)
                                .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                                .padding(16)
                        } else {
                            ForEach(viewModel.feedbackList, id: \.feedback.id) { item in
                                feedbackHistoryItem(item)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: 500)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
            .background(KanjiJourneyTheme.surface)
            .cornerRadius(16)
            .padding(16)
        }
    }

    private func feedbackHistoryItem(_ item: FeedbackWithHistory) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.feedback.category.label)
                    .font(KanjiJourneyTheme.labelSmall).fontWeight(.semibold)
                    .foregroundColor(KanjiJourneyTheme.primary)
                Spacer()
                HStack(spacing: 4) {
                    Text(item.feedback.status.emoji)
                        .font(KanjiJourneyTheme.labelMedium)
                    Text(item.feedback.status.label)
                        .font(KanjiJourneyTheme.labelSmall)
                        .foregroundColor(statusColor(item.feedback.status.value))
                }
            }

            Text(item.feedback.feedbackText)
                .font(KanjiJourneyTheme.bodySmall)
                .lineLimit(2)

            if let note = item.feedback.completionNote {
                Text("Note: \(note)")
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                    .italic()
            }
        }
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(KanjiJourneyTheme.onSurfaceVariant.opacity(0.2), lineWidth: 1)
        )
    }

    private func statusColor(_ value: String) -> Color {
        switch value {
        case "deployed": return KanjiJourneyTheme.primary
        case "rejected", "cancelled": return KanjiJourneyTheme.error
        case "in_progress", "testing": return KanjiJourneyTheme.tertiary
        default: return KanjiJourneyTheme.onSurfaceVariant
        }
    }
}
