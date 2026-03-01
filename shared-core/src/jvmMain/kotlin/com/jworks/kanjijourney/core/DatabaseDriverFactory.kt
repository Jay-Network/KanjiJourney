package com.jworks.kanjijourney.core.data

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.jdbc.sqlite.JdbcSqliteDriver
import com.jworks.kanjijourney.db.KanjiJourneyDatabase

actual class DatabaseDriverFactory(private val dbPath: String = "kanjijourney.db") {
    actual fun createDriver(): SqlDriver {
        val driver = JdbcSqliteDriver("jdbc:sqlite:$dbPath")
        KanjiJourneyDatabase.Schema.create(driver)
        return driver
    }
}
