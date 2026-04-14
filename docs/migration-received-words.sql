-- Migration: KanjiSage → KanjiJourney Word Transfer
-- Supabase table for cross-app kanji transfer
-- KanjiSage inserts rows; KanjiJourney pulls and processes them

CREATE TABLE IF NOT EXISTS kj_received_words (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    kanji_literal TEXT NOT NULL,
    source_app TEXT NOT NULL DEFAULT 'kanjisage',
    context TEXT,                          -- optional: sentence/image context from scan
    received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    pulled_at TIMESTAMPTZ,                 -- set when KanjiJourney pulls this word
    processed_at TIMESTAMPTZ,              -- set when KanjiJourney creates SRS card
    UNIQUE(user_id, kanji_literal, source_app)
);

-- RLS policies
ALTER TABLE kj_received_words ENABLE ROW LEVEL SECURITY;

-- KanjiSage (service_role or authenticated) can insert
CREATE POLICY "Authenticated users can insert received words"
    ON kj_received_words FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- KanjiJourney (authenticated) can read own words
CREATE POLICY "Users can read own received words"
    ON kj_received_words FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- KanjiJourney (authenticated) can update own words (mark pulled/processed)
CREATE POLICY "Users can update own received words"
    ON kj_received_words FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

-- Service role full access
CREATE POLICY "Service role full access"
    ON kj_received_words FOR ALL
    TO service_role
    USING (true);

-- Index for efficient pull queries
CREATE INDEX idx_kj_received_words_user_pending
    ON kj_received_words(user_id, pulled_at)
    WHERE pulled_at IS NULL;
