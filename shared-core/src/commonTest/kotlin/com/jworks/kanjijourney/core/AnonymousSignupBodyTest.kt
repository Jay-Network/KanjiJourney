package com.jworks.kanjijourney.core

import com.jworks.kanjijourney.core.data.remote.anonymousSignupBody
import kotlin.test.Test
import kotlin.test.assertEquals

class AnonymousSignupBodyTest {

    @Test
    fun validCountry_isSentUppercase() {
        assertEquals("""{"data":{"country":"US"}}""", anonymousSignupBody("US"))
        assertEquals("""{"data":{"country":"JP"}}""", anonymousSignupBody(" jp "))
    }

    @Test
    fun missingOrEmptyCountry_isOmitted() {
        assertEquals("{}", anonymousSignupBody(null))
        assertEquals("{}", anonymousSignupBody(""))
    }

    @Test
    fun notAnAlpha2Code_isOmitted() {
        // Locale.getDefault().country can be a 3-digit UN M.49 region such as "419"
        assertEquals("{}", anonymousSignupBody("419"))
        assertEquals("{}", anonymousSignupBody("USA"))
        assertEquals("{}", anonymousSignupBody("U\"S"))
    }
}
