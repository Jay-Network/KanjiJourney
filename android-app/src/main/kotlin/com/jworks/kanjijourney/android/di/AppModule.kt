package com.jworks.kanjijourney.android.di

import android.content.Context
import com.jworks.kanjijourney.android.BuildConfig
import com.jworks.kanjijourney.android.data.PreviewTrialManager
import com.jworks.kanjijourney.android.network.GeminiClient
import com.jworks.kanjijourney.android.ui.game.writing.AiFeedbackReporter
import com.jworks.kanjijourney.android.ui.game.writing.HandwritingChecker
import com.jworks.kanjijourney.core.data.AchievementRepositoryImpl
import com.jworks.kanjijourney.core.data.AuthRepositoryImpl
import com.jworks.kanjijourney.core.data.CollectionRepositoryImpl
import com.jworks.kanjijourney.core.data.DevChatRepositoryImpl
import com.jworks.kanjijourney.core.data.FeedbackRepositoryImpl
import com.jworks.kanjijourney.core.data.FieldJournalRepositoryImpl
import com.jworks.kanjijourney.core.data.FlashcardRepositoryImpl
import com.jworks.kanjijourney.core.data.DatabaseDriverFactory
import com.jworks.kanjijourney.core.data.JCoinRepositoryImpl
import com.jworks.kanjijourney.core.data.KanaRepositoryImpl
import com.jworks.kanjijourney.core.data.KanaSrsRepositoryImpl
import com.jworks.kanjijourney.core.data.KanjiRepositoryImpl
import com.jworks.kanjijourney.core.data.LearningSyncRepositoryImpl
import com.jworks.kanjijourney.core.data.RadicalRepositoryImpl
import com.jworks.kanjijourney.core.data.RadicalSrsRepositoryImpl
import com.jworks.kanjijourney.core.data.SessionRepositoryImpl
import com.jworks.kanjijourney.core.data.SrsRepositoryImpl
import com.jworks.kanjijourney.core.data.UserRepositoryImpl
import com.jworks.kanjijourney.core.data.VocabSrsRepositoryImpl
import com.jworks.kanjijourney.core.domain.UserSessionProvider
import com.jworks.kanjijourney.core.domain.UserSessionProviderImpl
import com.jworks.kanjijourney.core.domain.repository.AchievementRepository
import com.jworks.kanjijourney.core.domain.repository.AuthRepository
import com.jworks.kanjijourney.core.domain.repository.CollectionRepository
import com.jworks.kanjijourney.core.domain.repository.DevChatRepository
import com.jworks.kanjijourney.core.domain.repository.FeedbackRepository
import com.jworks.kanjijourney.core.domain.repository.FieldJournalRepository
import com.jworks.kanjijourney.core.domain.repository.FlashcardRepository
import com.jworks.kanjijourney.core.domain.repository.JCoinRepository
import com.jworks.kanjijourney.core.domain.repository.KanaRepository
import com.jworks.kanjijourney.core.domain.repository.KanaSrsRepository
import com.jworks.kanjijourney.core.domain.repository.KanjiRepository
import com.jworks.kanjijourney.core.domain.repository.LearningSyncRepository
import com.jworks.kanjijourney.core.domain.repository.RadicalRepository
import com.jworks.kanjijourney.core.domain.repository.RadicalSrsRepository
import com.jworks.kanjijourney.core.domain.repository.SessionRepository
import com.jworks.kanjijourney.core.domain.repository.SrsRepository
import com.jworks.kanjijourney.core.domain.repository.UserRepository
import com.jworks.kanjijourney.core.domain.repository.VocabSrsRepository
import com.jworks.kanjijourney.core.domain.usecase.CompleteSessionUseCase
import com.jworks.kanjijourney.core.domain.usecase.DataRestorationUseCase
import com.jworks.kanjijourney.core.domain.usecase.MigrateLocalDataUseCase
import com.jworks.kanjijourney.core.domain.usecase.WordOfTheDayUseCase
import com.jworks.kanjijourney.core.collection.EncounterEngine
import com.jworks.kanjijourney.core.collection.ItemLevelEngine
import com.jworks.kanjijourney.core.collection.RarityCalculator
import com.jworks.kanjijourney.core.engine.GameEngine
import com.jworks.kanjijourney.core.engine.GradeMasteryProvider
import com.jworks.kanjijourney.core.engine.KanaQuestionGenerator
import com.jworks.kanjijourney.core.engine.QuestionGenerator
import com.jworks.kanjijourney.core.engine.RadicalQuestionGenerator
import com.jworks.kanjijourney.android.ui.quiz.QuizQuestionGenerator
import com.jworks.kanjijourney.core.scoring.ScoringEngine
import com.jworks.kanjijourney.core.srs.Sm2Algorithm
import com.jworks.kanjijourney.core.srs.SrsAlgorithm
import com.jworks.kanjijourney.db.KanjiJourneyDatabase
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): KanjiJourneyDatabase {
        val driver = DatabaseDriverFactory(context).createDriver()
        return KanjiJourneyDatabase(driver)
    }

    @Provides
    @Singleton
    fun provideKanjiRepository(db: KanjiJourneyDatabase): KanjiRepository {
        return KanjiRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideSrsRepository(db: KanjiJourneyDatabase): SrsRepository {
        return SrsRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideUserRepository(db: KanjiJourneyDatabase): UserRepository {
        return UserRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideSessionRepository(db: KanjiJourneyDatabase): SessionRepository {
        return SessionRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideJCoinRepository(db: KanjiJourneyDatabase): JCoinRepository {
        return JCoinRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideSrsAlgorithm(): SrsAlgorithm {
        return Sm2Algorithm()
    }

    @Provides
    @Singleton
    fun provideScoringEngine(): ScoringEngine {
        return ScoringEngine()
    }

    @Provides
    @Singleton
    fun provideVocabSrsRepository(db: KanjiJourneyDatabase): VocabSrsRepository {
        return VocabSrsRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideAchievementRepository(db: KanjiJourneyDatabase): AchievementRepository {
        return AchievementRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideAuthRepository(): AuthRepository {
        return AuthRepositoryImpl()
    }

    @Provides
    @Singleton
    fun provideDevChatRepository(): DevChatRepository {
        return DevChatRepositoryImpl()
    }

    @Provides
    @Singleton
    fun provideFeedbackRepository(): FeedbackRepository {
        return FeedbackRepositoryImpl()
    }

    @Provides
    @Singleton
    fun provideFieldJournalRepository(db: KanjiJourneyDatabase): FieldJournalRepository {
        return FieldJournalRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideFlashcardRepository(db: KanjiJourneyDatabase): FlashcardRepository {
        return FlashcardRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideSyncEngine(db: KanjiJourneyDatabase): com.jworks.kanjijourney.core.data.sync.SyncEngine {
        return com.jworks.kanjijourney.core.data.sync.SyncEngine(db)
    }

    @Provides
    @Singleton
    fun provideLearningSyncRepository(
        db: KanjiJourneyDatabase,
        syncEngine: com.jworks.kanjijourney.core.data.sync.SyncEngine
    ): LearningSyncRepository {
        return LearningSyncRepositoryImpl(db, syncEngine)
    }

    @Provides
    @Singleton
    fun provideKanaRepository(db: KanjiJourneyDatabase): KanaRepository {
        return KanaRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideKanaSrsRepository(db: KanjiJourneyDatabase): KanaSrsRepository {
        return KanaSrsRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideRadicalRepository(db: KanjiJourneyDatabase): RadicalRepository {
        return RadicalRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideRadicalSrsRepository(db: KanjiJourneyDatabase): RadicalSrsRepository {
        return RadicalSrsRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideCollectionRepository(db: KanjiJourneyDatabase): CollectionRepository {
        return CollectionRepositoryImpl(db)
    }

    @Provides
    @Singleton
    fun provideEncounterEngine(
        collectionRepository: CollectionRepository,
        kanjiRepository: KanjiRepository
    ): EncounterEngine {
        return EncounterEngine(collectionRepository, kanjiRepository)
    }

    @Provides
    @Singleton
    fun provideItemLevelEngine(
        collectionRepository: CollectionRepository
    ): ItemLevelEngine {
        return ItemLevelEngine(collectionRepository)
    }

    @Provides
    @Singleton
    fun provideUserSessionProvider(authRepository: AuthRepository): UserSessionProvider {
        return UserSessionProviderImpl(authRepository)
    }

    @Provides
    @Singleton
    fun provideWordOfTheDayUseCase(kanjiRepository: KanjiRepository): WordOfTheDayUseCase {
        return WordOfTheDayUseCase(kanjiRepository)
    }

    @Provides
    fun provideQuizQuestionGenerator(
        kanjiRepository: KanjiRepository,
        kanaRepository: KanaRepository,
        radicalRepository: RadicalRepository
    ): QuizQuestionGenerator {
        return QuizQuestionGenerator(kanjiRepository, kanaRepository, radicalRepository)
    }

    @Provides
    fun provideQuestionGenerator(
        kanjiRepository: KanjiRepository,
        srsRepository: SrsRepository,
        vocabSrsRepository: VocabSrsRepository
    ): QuestionGenerator {
        val masteryProvider = GradeMasteryProvider { grade ->
            val total = kanjiRepository.getKanjiCountByGrade(grade)
            srsRepository.getGradeMastery(grade, total)
        }
        return QuestionGenerator(kanjiRepository, srsRepository, vocabSrsRepository, masteryProvider)
    }

    @Provides
    fun provideKanaQuestionGenerator(
        kanaRepository: KanaRepository,
        kanaSrsRepository: KanaSrsRepository
    ): KanaQuestionGenerator {
        return KanaQuestionGenerator(kanaRepository, kanaSrsRepository)
    }

    @Provides
    fun provideRadicalQuestionGenerator(
        radicalRepository: RadicalRepository,
        radicalSrsRepository: RadicalSrsRepository,
        kanjiRepository: KanjiRepository
    ): RadicalQuestionGenerator {
        return RadicalQuestionGenerator(radicalRepository, radicalSrsRepository, kanjiRepository)
    }

    @Provides
    fun provideGameEngine(
        questionGenerator: QuestionGenerator,
        srsAlgorithm: SrsAlgorithm,
        srsRepository: SrsRepository,
        scoringEngine: ScoringEngine,
        vocabSrsRepository: VocabSrsRepository,
        userRepository: UserRepository,
        userSessionProvider: UserSessionProvider,
        kanaQuestionGenerator: KanaQuestionGenerator,
        kanaSrsRepository: KanaSrsRepository,
        radicalQuestionGenerator: RadicalQuestionGenerator,
        radicalSrsRepository: RadicalSrsRepository,
        collectionRepository: CollectionRepository,
        encounterEngine: EncounterEngine,
        itemLevelEngine: ItemLevelEngine
    ): GameEngine {
        return GameEngine(
            questionGenerator, srsAlgorithm, srsRepository, scoringEngine,
            vocabSrsRepository, userRepository,
            userSessionProvider = userSessionProvider,
            kanaQuestionGenerator = kanaQuestionGenerator,
            kanaSrsRepository = kanaSrsRepository,
            radicalQuestionGenerator = radicalQuestionGenerator,
            radicalSrsRepository = radicalSrsRepository,
            collectionRepository = collectionRepository,
            encounterEngine = encounterEngine,
            itemLevelEngine = itemLevelEngine
        )
    }

    @Provides
    fun provideCompleteSessionUseCase(
        userRepository: UserRepository,
        sessionRepository: SessionRepository,
        scoringEngine: ScoringEngine,
        jCoinRepository: JCoinRepository,
        userSessionProvider: UserSessionProvider,
        learningSyncRepository: LearningSyncRepository,
        achievementRepository: AchievementRepository,
        srsRepository: SrsRepository,
        kanjiRepository: KanjiRepository
    ): CompleteSessionUseCase {
        return CompleteSessionUseCase(
            userRepository, sessionRepository, scoringEngine,
            jCoinRepository, userSessionProvider,
            learningSyncRepository, achievementRepository,
            srsRepository, kanjiRepository
        )
    }

    @Provides
    fun provideMigrateLocalDataUseCase(db: KanjiJourneyDatabase): MigrateLocalDataUseCase {
        return MigrateLocalDataUseCase(db)
    }

    @Provides
    fun provideDataRestorationUseCase(
        learningSyncRepository: LearningSyncRepository,
        userRepository: UserRepository,
        srsRepository: SrsRepository
    ): DataRestorationUseCase {
        return DataRestorationUseCase(learningSyncRepository, userRepository, srsRepository)
    }

    @Provides
    @Singleton
    fun providePreviewTrialManager(@ApplicationContext context: Context): PreviewTrialManager {
        return PreviewTrialManager(context)
    }

    @Provides
    @Singleton
    fun provideGeminiClient(): GeminiClient {
        return GeminiClient(BuildConfig.GEMINI_API_KEY)
    }

    @Provides
    @Singleton
    fun provideHandwritingChecker(geminiClient: GeminiClient): HandwritingChecker {
        return HandwritingChecker(geminiClient)
    }

    @Provides
    @Singleton
    fun provideAiFeedbackReporter(@ApplicationContext context: Context): AiFeedbackReporter {
        return AiFeedbackReporter(context)
    }
}
