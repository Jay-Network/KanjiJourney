package com.jworks.kanjijourney.core

import com.jworks.kanjijourney.core.data.feedbackUpdatesQuery
import io.ktor.http.parseQueryString
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull

class FeedbackUpdatesQueryTest {

    @Test
    fun plusInEmail_survivesRoundTrip() {
        val email = "jay+kj@example.com"
        val query = feedbackUpdatesQuery(email, appId = "kanjijourney", sinceId = null)

        // A raw "+" decodes to a space server-side and looks up the wrong user (BUG-009)
        assertFalse(query.contains("+"))
        assertEquals(email, parseQueryString(query)["user_email"])
    }

    @Test
    fun reservedCharsInEmail_areEncoded() {
        val email = "a&b=c#d@example.com"
        val query = feedbackUpdatesQuery(email, appId = "kanjijourney", sinceId = null)

        val params = parseQueryString(query)
        assertEquals(email, params["user_email"])
        assertEquals("kanjijourney", params["app_id"])
    }

    @Test
    fun sinceId_isAppendedWhenPresent() {
        val query = feedbackUpdatesQuery("jay@example.com", appId = "kanjijourney", sinceId = 42L)

        assertEquals("42", parseQueryString(query)["since_id"])
    }

    @Test
    fun sinceId_isOmittedWhenNull() {
        val query = feedbackUpdatesQuery("jay@example.com", appId = "kanjijourney", sinceId = null)

        assertNull(parseQueryString(query)["since_id"])
    }
}
