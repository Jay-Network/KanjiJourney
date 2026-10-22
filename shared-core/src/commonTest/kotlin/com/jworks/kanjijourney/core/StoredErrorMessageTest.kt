package com.jworks.kanjijourney.core

import com.jworks.kanjijourney.core.data.storedErrorMessage
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse

class StoredErrorMessageTest {

    @Test
    fun restExceptionMessage_dropsUrlAndHeaders() {
        // Same layout as supabase-kt's RestException message; token values are placeholders
        val message = "{\"success\":false,\"error\":{\"code\":\"VALIDATION_ERROR\"}}\n" +
            "URL: https://example.test/functions/v1/jcoin-unified-earn\n" +
            "Headers: [Authorization=[Bearer TOKEN_PLACEHOLDER], apikey=[KEY_PLACEHOLDER]]\n" +
            "Http Method: POST"

        val stored = storedErrorMessage(message)

        assertEquals("{\"success\":false,\"error\":{\"code\":\"VALIDATION_ERROR\"}}", stored)
        assertFalse(stored.contains("Bearer"))
        assertFalse(stored.contains("apikey"))
    }

    @Test
    fun headersWithoutLineBreak_areDroppedToo() {
        val stored = storedErrorMessage(
            "Request failed URL: https://example.test/x Headers: [Authorization=[Bearer TOKEN_PLACEHOLDER]]"
        )

        assertEquals("Request failed", stored)
        assertFalse(stored.contains("Bearer"))
    }

    @Test
    fun plainMessage_isKept() {
        assertEquals("Request timeout has expired", storedErrorMessage("Request timeout has expired"))
    }

    @Test
    fun missingMessage_becomesUnknownError() {
        assertEquals("Unknown error", storedErrorMessage(null))
        assertEquals("Unknown error", storedErrorMessage("\nURL: https://example.test"))
    }
}
