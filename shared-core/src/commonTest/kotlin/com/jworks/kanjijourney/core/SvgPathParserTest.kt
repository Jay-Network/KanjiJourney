package com.jworks.kanjijourney.core

import com.jworks.kanjijourney.core.writing.SvgPathParser
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class SvgPathParserTest {

    @Test
    fun parseSvgPath_simpleMoveAndCubic() {
        // Simple path: move to (50, 20) then relative cubic to end point
        val path = "M 50,20 c 1,2 3,4 5,6"
        val points = SvgPathParser.parseSvgPath(path)

        // moveTo + 8 samples along the cubic (SvgPathParser.BEZIER_SAMPLES)
        assertEquals(1 + 8, points.size)
        // First point is the moveTo
        assertEquals(50f, points[0].x)
        assertEquals(20f, points[0].y)
        // Last sample (t = 1) is the cubic's end point, offset by its end delta (5, 6)
        assertEquals(55f, points.last().x)
        assertEquals(26f, points.last().y)
    }

    @Test
    fun parseSvgPath_realKanjiVgData_ichi() {
        // Real KanjiVG stroke for 一 (one) - single horizontal stroke
        val path = "M 14.5,50.25 c 7.75,0.62 17.37,0.87 26.62,0.37 c 9.25,-0.5 18.12,-1.62 24.25,-3"
        val points = SvgPathParser.parseSvgPath(path)

        assertTrue(points.isNotEmpty())
        // Starts near (14.5, 50.25)
        assertEquals(14.5f, points[0].x, 0.01f)
        assertEquals(50.25f, points[0].y, 0.01f)
        // M + 8 samples per cubic, 2 cubics
        assertEquals(1 + 2 * 8, points.size)
        // Ends at the second cubic's end point: 14.5 + 26.62 + 24.25, 50.25 + 0.37 - 3
        assertEquals(65.37f, points.last().x, 0.01f)
        assertEquals(47.62f, points.last().y, 0.01f)
    }

    @Test
    fun parseSvgPath_multipleCubicSegments() {
        val path = "M 50,16.5 c 0,1.75 -0.25,3.37 -0.75,4.87 c -0.5,1.5 -1,3 -1.5,4.5"
        val points = SvgPathParser.parseSvgPath(path)

        assertEquals(1 + 2 * 8, points.size)
        assertEquals(50f, points[0].x, 0.01f)
        assertEquals(16.5f, points[0].y, 0.01f)
    }

    @Test
    fun parseSvgPath_smoothCubic_reflectsPreviousControlPoint() {
        // c ends at (10,0) with 2nd control point (10,10); s reflects it to (10,-10)
        val path = "M 0,0 c 0,10 10,10 10,0 s 10,-10 10,0"
        val points = SvgPathParser.parseSvgPath(path)

        assertEquals(1 + 2 * 8, points.size)
        assertEquals(20f, points.last().x, 0.01f)
        assertEquals(0f, points.last().y, 0.01f)
        // Midpoint (t = 0.5) of the s segment: control points (10,-10) and (20,-10) pull it to y = -7.5
        // (without the reflection, the first control point would be (10,0) and y = -3.75)
        assertEquals(15f, points[8 + 4].x, 0.01f)
        assertEquals(-7.5f, points[8 + 4].y, 0.01f)
    }

    @Test
    fun parseSvgPath_absoluteSmoothCubic_matchesRelative() {
        val relative = SvgPathParser.parseSvgPath("M 0,0 c 0,10 10,10 10,0 s 10,-10 10,0")
        val absolute = SvgPathParser.parseSvgPath("M 0,0 C 0,10 10,10 10,0 S 20,-10 20,0")

        assertEquals(relative.size, absolute.size)
        relative.zip(absolute).forEach { (r, a) ->
            assertEquals(r.x, a.x, 0.01f)
            assertEquals(r.y, a.y, 0.01f)
        }
    }

    @Test
    fun parseSvgPath_segmentAfterSmoothCubic_startsFromItsEndPoint() {
        // s with no preceding cubic uses the current point as its first control point
        val points = SvgPathParser.parseSvgPath("M 0,0 s 5,5 10,0 c 1,1 2,2 3,3")

        assertEquals(1 + 2 * 8, points.size)
        assertEquals(10f, points[8].x, 0.01f)
        assertEquals(0f, points[8].y, 0.01f)
        assertEquals(13f, points.last().x, 0.01f)
        assertEquals(3f, points.last().y, 0.01f)
    }

    @Test
    fun parseSvgPath_realKanjiVgData_withSmoothCubic() {
        // Real KanjiVG stroke from 繦 (bundled kanjijourney.db); 816 kanji there use s, 87 use S
        val path = "M47.5,36c1.75,0,8-1.5,9.25-1.5s2,0,3,0"
        val points = SvgPathParser.parseSvgPath(path)

        assertEquals(1 + 2 * 8, points.size)
        // End = start + sum of end deltas: (47.5 + 9.25 + 3, 36 - 1.5 + 0)
        assertEquals(59.75f, points.last().x, 0.01f)
        assertEquals(34.5f, points.last().y, 0.01f)
    }

    @Test
    fun parseSvgPath_emptyInput_returnsEmpty() {
        assertEquals(emptyList(), SvgPathParser.parseSvgPath(""))
        assertEquals(emptyList(), SvgPathParser.parseSvgPath("  "))
    }

    @Test
    fun parseStrokePaths_jsonArray() {
        val json = """["M 14.5,50.25 c 7.75,0.62 17.37,0.87 26.62,0.37"]"""
        val strokes = SvgPathParser.parseStrokePaths(json)

        assertEquals(1, strokes.size)
        assertTrue(strokes[0].isNotEmpty())
        assertEquals(14.5f, strokes[0][0].x, 0.01f)
    }

    @Test
    fun parseStrokePaths_multipleStrokes() {
        // 三 (three) has 3 strokes
        val json = """[
            "M 20,25 c 5,0 10,-0.5 15,-1",
            "M 15,50 c 8,0.5 18,0 27,-1",
            "M 12,75 c 10,0.75 22,0.5 33,-1"
        ]"""
        val strokes = SvgPathParser.parseStrokePaths(json)

        assertEquals(3, strokes.size)
        for (stroke in strokes) {
            assertTrue(stroke.size >= 2)
        }
    }

    @Test
    fun parseStrokePaths_invalidJson_returnsEmpty() {
        assertEquals(emptyList(), SvgPathParser.parseStrokePaths("not json"))
        assertEquals(emptyList(), SvgPathParser.parseStrokePaths(""))
    }

    @Test
    fun tokenize_handlesNegativeNumbers() {
        val tokens = SvgPathParser.tokenize("M 50,-20 c -1,-2 -3,-4 -5,-6")
        // Should contain: M, 50, -20, c, -1, -2, -3, -4, -5, -6
        assertTrue(tokens.contains("M"))
        assertTrue(tokens.contains("c"))
        assertTrue(tokens.contains("-20"))
        assertTrue(tokens.contains("-5"))
    }

    @Test
    fun tokenize_handlesDecimalNumbers() {
        val tokens = SvgPathParser.tokenize("M 14.5,50.25")
        assertTrue(tokens.contains("14.5"))
        assertTrue(tokens.contains("50.25"))
    }
}
