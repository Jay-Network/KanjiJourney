import SwiftUI
import SharedCore

/// Word detail screen. Mirrors Android's WordDetailScreen.kt.
/// Large kanji form, reading, info chips, meanings list, related kanji.
struct WordDetailView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = WordDetailViewModel()
    let wordId: Int64
    var onBack: () -> Void = {}
    var onKanjiClick: ((Int32) -> Void)? = nil

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading...").font(KanjiJourneyTheme.bodyLarge)
                }
            } else if let vocab = viewModel.vocabulary {
                ScrollView {
                    VStack(spacing: 12) {
                        // Large kanji form
                        KanjiText(
                            text: vocab.kanjiForm,
                            font: .system(size: 80, weight: .regular, design: .serif)
                        )
                        .padding(.vertical, 16)

                        // Reading
                        Text(vocab.reading)
                            .font(KanjiJourneyTheme.headlineSmall)
                            .foregroundColor(KanjiJourneyTheme.primary)

                        // Info chips
                        HStack(spacing: 8) {
                            if let jlpt = vocab.jlptLevel {
                                chipLabel("JLPT N\(jlpt)")
                            }
                            if let freq = vocab.frequency {
                                chipLabel("Freq #\(freq)")
                            }
                        }

                        Spacer().frame(height: 4)

                        // Meanings
                        sectionCard(title: "Meanings") {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(vocab.meaningsEn.enumerated()), id: \.offset) { index, meaning in
                                    Text("\(index + 1). \(meaning)")
                                        .font(KanjiJourneyTheme.bodyLarge)
                                }
                            }
                        }

                        // Related kanji
                        if !viewModel.relatedKanji.isEmpty {
                            sectionCard(title: "Related Kanji") {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.relatedKanji, id: \.id) { kanji in
                                        Button {
                                            onKanjiClick?(kanji.id)
                                        } label: {
                                            HStack(spacing: 12) {
                                                KanjiText(
                                                    text: kanji.literal,
                                                    font: .system(size: 32, weight: .bold, design: .serif)
                                                )
                                                VStack(alignment: .leading) {
                                                    Text(kanji.meaningsEn.joined(separator: ", "))
                                                        .font(KanjiJourneyTheme.bodyMedium).fontWeight(.medium)
                                                        .foregroundColor(KanjiJourneyTheme.onSurface)
                                                    if let grade = kanji.grade {
                                                        Text("Grade \(grade)")
                                                            .font(KanjiJourneyTheme.bodySmall)
                                                            .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                            }
                        }

                        Spacer().frame(height: 16)
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left"); Text("Back")
                }.foregroundColor(.white)
            }
            ToolbarItem(placement: .principal) {
                Text("Word Detail").font(.headline).foregroundColor(.white)
            }
        }
        .toolbarBackground(KanjiJourneyTheme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { viewModel.load(container: container, wordId: wordId) }
    }

    private func chipLabel(_ text: String) -> some View {
        Text(text)
            .font(KanjiJourneyTheme.labelMedium)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(KanjiJourneyTheme.surfaceVariant)
            .cornerRadius(16)
    }

    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(KanjiJourneyTheme.titleSmall).fontWeight(.bold)
                .foregroundColor(KanjiJourneyTheme.primary)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KanjiJourneyTheme.surface)
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }
}
