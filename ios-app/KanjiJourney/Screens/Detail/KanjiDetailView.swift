import SwiftUI
import SharedCore

/// Kanji detail screen. Mirrors Android's KanjiDetailScreen.kt.
/// Large kanji display, info chips, practice stats, readings, vocabulary with example sentences.
struct KanjiDetailView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel = KanjiDetailViewModel()
    let kanjiId: Int32
    var onBack: () -> Void = {}
    var onKanjiClick: ((Int32) -> Void)? = nil
    var onPracticeWriting: ((Int32) -> Void)? = nil
    var onPracticeCamera: ((Int32) -> Void)? = nil

    var body: some View {
        ZStack {
            KanjiJourneyTheme.background.ignoresSafeArea()

            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading...").font(KanjiJourneyTheme.bodyLarge)
                }
            } else if let kanji = viewModel.kanji {
                ScrollView {
                    VStack(spacing: 12) {
                        // Large kanji
                        KanjiText(
                            text: kanji.literal,
                            font: .system(size: 120, weight: .regular, design: .serif)
                        )
                        .padding(.vertical, 16)

                        // Info chips
                        infoChips(kanji)

                        // Practice stats
                        if viewModel.totalPracticeCount > 0 {
                            practiceStatsCard
                        }

                        // Practice mode buttons
                        if onPracticeWriting != nil || onPracticeCamera != nil {
                            practiceButtons
                        }

                        // Meanings
                        sectionCard(title: "Meanings") {
                            Text(kanji.meaningsEn.joined(separator: ", "))
                                .font(KanjiJourneyTheme.bodyLarge)
                        }

                        // On'yomi
                        if !kanji.onReadings.isEmpty {
                            sectionCard(title: "On'yomi (Chinese readings)") {
                                Text(kanji.onReadings.joined(separator: "   "))
                                    .font(KanjiJourneyTheme.bodyLarge)
                            }
                        }

                        // Kun'yomi
                        if !kanji.kunReadings.isEmpty {
                            sectionCard(title: "Kun'yomi (Japanese readings)") {
                                Text(kanji.kunReadings.joined(separator: "   "))
                                    .font(KanjiJourneyTheme.bodyLarge)
                            }
                        }

                        // Related vocabulary
                        if !viewModel.vocabulary.isEmpty {
                            sectionCard(title: "Related Vocabulary") {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(viewModel.vocabulary.prefix(10), id: \.id) { vocab in
                                        vocabItem(vocab)
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }

            // Deck chooser
            if viewModel.showDeckChooser {
                deckChooserOverlay
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
                Text(viewModel.kanji?.literal ?? "Kanji Detail")
                    .font(.headline).foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.toggleFlashcard() }) {
                    Image(systemName: viewModel.isInFlashcardDeck ? "star.fill" : "star")
                        .foregroundColor(viewModel.isInFlashcardDeck ? KanjiJourneyTheme.xpGold : .white)
                }
            }
        }
        .toolbarBackground(KanjiJourneyTheme.primary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { viewModel.load(container: container, kanjiId: kanjiId) }
    }

    // MARK: - Info Chips

    private func infoChips(_ kanji: Kanji) -> some View {
        let chips: [(String, String)] = {
            var items: [(String, String)] = []
            if let grade = kanji.grade { items.append(("grade", "Grade \(grade)")) }
            if let jlpt = kanji.jlptLevel { items.append(("jlpt", "JLPT N\(jlpt)")) }
            items.append(("strokes", "\(kanji.strokeCount) strokes"))
            if let freq = kanji.frequency { items.append(("freq", "Freq #\(freq)")) }
            return items
        }()

        return FlowLayout(spacing: 8) {
            ForEach(chips, id: \.0) { chip in
                Text(chip.1)
                    .font(KanjiJourneyTheme.labelMedium)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(KanjiJourneyTheme.surfaceVariant)
                    .cornerRadius(16)
            }
        }
    }

    // MARK: - Practice Stats

    private var practiceStatsCard: some View {
        HStack {
            VStack {
                Text("\(viewModel.totalPracticeCount)")
                    .font(KanjiJourneyTheme.titleMedium).fontWeight(.bold)
                Text("Practiced")
                    .font(KanjiJourneyTheme.labelSmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity)

            if let acc = viewModel.accuracy {
                VStack {
                    Text("\(Int(acc * 100))%")
                        .font(KanjiJourneyTheme.titleMedium).fontWeight(.bold)
                        .foregroundColor(acc >= 0.8 ? Color(hex: 0x4CAF50) : acc >= 0.6 ? Color(hex: 0xFF9800) : Color(hex: 0xF44336))
                    Text("Accuracy")
                        .font(KanjiJourneyTheme.labelSmall)
                        .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(12)
        .background(KanjiJourneyTheme.surfaceVariant)
        .cornerRadius(KanjiJourneyTheme.radiusM)
    }

    // MARK: - Practice Buttons

    private var practiceButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Practice:")
                .font(KanjiJourneyTheme.titleSmall).fontWeight(.bold)

            HStack(spacing: 8) {
                if let onWriting = onPracticeWriting {
                    let trial = viewModel.modeTrials["writing"]
                    let canPractice = viewModel.isPremium || viewModel.isAdmin || (trial?.canPractice ?? false)
                    Button {
                        if !viewModel.isPremium && !viewModel.isAdmin {
                            _ = viewModel.useModeTrial(mode: "writing")
                        }
                        onWriting(kanjiId)
                    } label: {
                        VStack(spacing: 2) {
                            Text("Writing").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            if !viewModel.isPremium && !viewModel.isAdmin, let t = trial {
                                Text(canPractice ? "\(t.trialsRemaining) left" : "No trials")
                                    .font(.system(size: 9)).foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(canPractice ? Color(hex: 0x4CAF50) : Color(hex: 0x4CAF50).opacity(0.3))
                        .cornerRadius(10)
                    }
                    .disabled(!canPractice)
                }

                if let onCamera = onPracticeCamera {
                    let trial = viewModel.modeTrials["camera_challenge"]
                    let canPractice = viewModel.isPremium || viewModel.isAdmin || (trial?.canPractice ?? false)
                    Button {
                        if !viewModel.isPremium && !viewModel.isAdmin {
                            _ = viewModel.useModeTrial(mode: "camera_challenge")
                        }
                        onCamera(kanjiId)
                    } label: {
                        VStack(spacing: 2) {
                            Text("Camera").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                            if !viewModel.isPremium && !viewModel.isAdmin, let t = trial {
                                Text(canPractice ? "\(t.trialsRemaining) left" : "No trials")
                                    .font(.system(size: 9)).foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 48)
                        .background(canPractice ? Color(hex: 0x9C27B0) : Color(hex: 0x9C27B0).opacity(0.3))
                        .cornerRadius(10)
                    }
                    .disabled(!canPractice)
                }
            }
        }
    }

    // MARK: - Vocab Item

    private func vocabItem(_ vocab: Vocabulary) -> some View {
        let sentence = viewModel.vocabSentences[vocab.id]
        return VStack(alignment: .leading, spacing: 2) {
            Text("\(vocab.kanjiForm)  (\(vocab.reading))")
                .font(KanjiJourneyTheme.bodyMedium).fontWeight(.medium)
            Text(vocab.primaryMeaning)
                .font(KanjiJourneyTheme.bodySmall)
                .foregroundColor(KanjiJourneyTheme.onSurfaceVariant)
            if let s = sentence {
                Text(s.japanese)
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.primary)
                Text(s.english)
                    .font(KanjiJourneyTheme.bodySmall)
                    .foregroundColor(KanjiJourneyTheme.onSurfaceVariant.opacity(0.8))
            }
        }
    }

    // MARK: - Section Card

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

    // MARK: - Deck Chooser

    private var deckChooserOverlay: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture { viewModel.dismissDeckChooser() }

            VStack(spacing: 16) {
                Text("Add to Deck")
                    .font(KanjiJourneyTheme.titleLarge).fontWeight(.bold)

                ForEach(viewModel.deckGroups, id: \.id) { deck in
                    let isInDeck = viewModel.kanjiInDecks.contains(deck.id)
                    Button {
                        if isInDeck {
                            viewModel.removeFromDeck(deck.id)
                        } else {
                            viewModel.addToDeck(deck.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: isInDeck ? "checkmark.square.fill" : "square")
                                .foregroundColor(isInDeck ? KanjiJourneyTheme.primary : KanjiJourneyTheme.onSurfaceVariant)
                            Text(deck.name)
                                .font(KanjiJourneyTheme.bodyLarge)
                                .foregroundColor(KanjiJourneyTheme.onSurface)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }

                Button("Done") { viewModel.dismissDeckChooser() }
                    .fontWeight(.bold).foregroundColor(KanjiJourneyTheme.primary)
            }
            .padding(24)
            .background(KanjiJourneyTheme.surface)
            .cornerRadius(16)
            .padding(32)
        }
    }
}

/// Simple flow layout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += lineHeight + spacing
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }

        return CGSize(width: maxWidth, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x: CGFloat = bounds.minX
        var y: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
