package com.jworks.kanjijourney.core.writing

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonPrimitive

data class Point(val x: Float, val y: Float)

/**
 * Parses SVG path `d` attributes from KanjiVG data into lists of points.
 * KanjiVG uses ~109x109 coordinate space with M (moveTo) and c (relative cubicBezier) commands.
 */
object SvgPathParser {

    /** Number of sample points per cubic bezier segment for accurate curve matching. */
    private const val BEZIER_SAMPLES = 8

    /**
     * Parse a JSON array of SVG path strings into a list of stroke point lists.
     * Input format: ["M 50.25,16.5 c 0.12,1.75 ...", "M 27.5,28.25 c ..."]
     */
    fun parseStrokePaths(jsonArray: String): List<List<Point>> {
        return try {
            val array = Json.parseToJsonElement(jsonArray).jsonArray
            array.map { element ->
                parseSvgPath(element.jsonPrimitive.content)
            }
        } catch (_: Exception) {
            emptyList()
        }
    }

    /**
     * Parse a single SVG path `d` attribute into a list of points.
     * Supports M (absolute moveTo), c/C (cubicBezierTo) and s/S (smooth cubicBezierTo).
     * KanjiVG uses s/S in ~900 kanji; skipping them drops segments and shifts every later
     * relative segment of the stroke.
     */
    fun parseSvgPath(pathData: String): List<Point> {
        if (pathData.isBlank()) return emptyList()

        val points = mutableListOf<Point>()
        var currentX = 0f
        var currentY = 0f
        // Second control point of the previous cubic (absolute), for s/S reflection
        var lastCtrl2: Point? = null

        val tokens = tokenize(pathData)
        var i = 0

        while (i < tokens.size) {
            when (tokens[i]) {
                "M" -> {
                    // Absolute moveTo: M x,y
                    i++
                    val (x, y) = parseCoordPair(tokens, i)
                    i += 2
                    currentX = x
                    currentY = y
                    points.add(Point(currentX, currentY))
                    lastCtrl2 = null

                    // Implicit lineTo pairs after M
                    while (i < tokens.size && isNumber(tokens[i])) {
                        val (lx, ly) = parseCoordPair(tokens, i)
                        i += 2
                        currentX = lx
                        currentY = ly
                        points.add(Point(currentX, currentY))
                    }
                }
                "c", "C" -> {
                    // Cubic bezier: c dx1,dy1 dx2,dy2 dx,dy (relative) / C x1,y1 x2,y2 x,y (absolute)
                    val relative = tokens[i] == "c"
                    i++
                    while (i + 5 < tokens.size && isNumber(tokens[i])) {
                        val ox = if (relative) currentX else 0f
                        val oy = if (relative) currentY else 0f
                        val (x1, y1) = parseCoordPair(tokens, i); i += 2
                        val (x2, y2) = parseCoordPair(tokens, i); i += 2
                        val (x, y) = parseCoordPair(tokens, i); i += 2
                        val ctrl2 = Point(ox + x2, oy + y2)
                        sampleCubic(points, currentX, currentY, ox + x1, oy + y1, ctrl2.x, ctrl2.y, ox + x, oy + y)
                        currentX = ox + x; currentY = oy + y
                        lastCtrl2 = ctrl2
                    }
                }
                "s", "S" -> {
                    // Smooth cubic: s dx2,dy2 dx,dy (relative) / S x2,y2 x,y (absolute).
                    // First control point = previous cubic's second control point reflected
                    // through the current point, or the current point if there was none.
                    val relative = tokens[i] == "s"
                    i++
                    while (i + 3 < tokens.size && isNumber(tokens[i])) {
                        val ox = if (relative) currentX else 0f
                        val oy = if (relative) currentY else 0f
                        val (x2, y2) = parseCoordPair(tokens, i); i += 2
                        val (x, y) = parseCoordPair(tokens, i); i += 2
                        val prev = lastCtrl2
                        val cx1 = if (prev != null) 2 * currentX - prev.x else currentX
                        val cy1 = if (prev != null) 2 * currentY - prev.y else currentY
                        val ctrl2 = Point(ox + x2, oy + y2)
                        sampleCubic(points, currentX, currentY, cx1, cy1, ctrl2.x, ctrl2.y, ox + x, oy + y)
                        currentX = ox + x; currentY = oy + y
                        lastCtrl2 = ctrl2
                    }
                }
                else -> i++ // skip unknown commands
            }
        }

        return points
    }

    private fun isNumber(token: String): Boolean =
        token.firstOrNull()?.let { it.isDigit() || it == '-' || it == '.' } == true

    /** Append BEZIER_SAMPLES points along the cubic, excluding the start point. */
    private fun sampleCubic(
        points: MutableList<Point>,
        x0: Float, y0: Float, cx1: Float, cy1: Float,
        cx2: Float, cy2: Float, x3: Float, y3: Float
    ) {
        for (s in 1..BEZIER_SAMPLES) {
            val t = s.toFloat() / BEZIER_SAMPLES
            points.add(cubicBezierPoint(x0, y0, cx1, cy1, cx2, cy2, x3, y3, t))
        }
    }

    /**
     * Tokenize SVG path data into command letters and numeric values.
     * Handles formats like "M 50.25,16.5" and "c 0.12,1.75 -0.5,3.25 -1,4.5"
     */
    internal fun tokenize(pathData: String): List<String> {
        val tokens = mutableListOf<String>()
        // Insert spaces before command letters for easier splitting
        val normalized = buildString {
            for (ch in pathData) {
                when {
                    ch.isLetter() -> {
                        append(' ')
                        append(ch)
                        append(' ')
                    }
                    ch == ',' -> append(' ')
                    ch == '-' && isNotEmpty() && last() != ' ' && !last().isLetter() -> {
                        append(' ')
                        append(ch)
                    }
                    else -> append(ch)
                }
            }
        }

        for (token in normalized.split(' ').map { it.trim() }.filter { it.isNotEmpty() }) {
            tokens.add(token)
        }

        return tokens
    }

    /** Evaluate cubic bezier at parameter t (0..1). */
    private fun cubicBezierPoint(
        x0: Float, y0: Float, cx1: Float, cy1: Float,
        cx2: Float, cy2: Float, x3: Float, y3: Float, t: Float
    ): Point {
        val u = 1f - t
        val uu = u * u; val uuu = uu * u
        val tt = t * t; val ttt = tt * t
        return Point(
            uuu * x0 + 3 * uu * t * cx1 + 3 * u * tt * cx2 + ttt * x3,
            uuu * y0 + 3 * uu * t * cy1 + 3 * u * tt * cy2 + ttt * y3
        )
    }

    private fun parseCoordPair(tokens: List<String>, index: Int): Pair<Float, Float> {
        val x = tokens.getOrNull(index)?.toFloatOrNull() ?: 0f
        val y = tokens.getOrNull(index + 1)?.toFloatOrNull() ?: 0f
        return x to y
    }
}
