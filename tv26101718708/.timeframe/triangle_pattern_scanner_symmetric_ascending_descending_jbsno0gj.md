# Triangle Pattern Scanner (Symmetric / Ascending / Descending)

- url: https://www.tradingview.com/script/JbsnO0gJ/
- type: indicator
- pine_id: PUB;c29753a6da0d4cdaa1145a4d2cc42ecb
- version: 1.0

## Description

Triangle Pattern Scanner automatically detects and draws Symmetric, 
Ascending, and Descending triangle formations on the chart in real time, 
using pivot-based geometry validation to ensure only structurally sound 
patterns are displayed. A multi-timeframe table shows at a glance which 
triangle types are currently forming across five user-defined timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BACKGROUND — WHY TRIANGLE PATTERNS?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Triangle patterns are among the most widely recognized continuation and 
reversal formations in technical analysis. They form when price makes a 
series of pivot highs and pivot lows that converge toward a single apex 
point, compressing volatility before a potential breakout in either 
direction.

Identifying them manually requires drawing trendlines across multiple 
pivots, verifying that price stays within the boundaries throughout the 
formation, checking that the lines actually converge ahead, and 
distinguishing between the three types based on the angle of each 
boundary line. This indicator automates all of those steps.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
THREE PATTERN TYPES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SYMMETRIC TRIANGLE
Both the upper trendline (connecting pivot highs) and the lower trendline 
(connecting pivot lows) slope toward each other — the upper falling, the 
lower rising. Neither side is horizontal. The pattern is considered neutral 
until the breakout direction is confirmed. A symmetry ratio check ensures 
the two slopes are reasonably balanced rather than one side being nearly 
flat while the other is very steep.

ASCENDING TRIANGLE
The upper trendline is nearly horizontal (price repeatedly tests the same 
resistance level) while the lower trendline slopes upward (higher lows). 
The pattern is considered bullish by structure, with the expectation of 
an upward breakout through the flat resistance. The angle tolerance for 
the horizontal line is configurable, giving you control over how strictly 
"flat" the upper line must be.

DESCENDING TRIANGLE
The lower trendline is nearly horizontal (price repeatedly tests the same 
support level) while the upper trendline slopes downward (lower highs). 
The pattern is considered bearish by structure, with the expectation of 
a downward breakout through the flat support. The same configurable angle 
tolerance applies to the lower line.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW IT WORKS — TECHNICAL DETAIL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PIVOT DETECTION
The indicator uses Pine Script's ta.pivothigh() and ta.pivotlow() to 
collect recent swing highs and swing lows. The Pivot Length input controls 
the symmetric left-right lookback used by both functions — a pivot high 
requires the highest high compared to an equal number of bars on both 
sides. Up to 8 recent pivots of each type are stored in memory for 
pattern scanning.

GEOMETRY VALIDATION
For each combination of two pivot highs and two pivot lows, the indicator 
calculates the slopes and intercepts of the upper and lower trendlines, 
then verifies:

— Convergence: the two lines must actually meet ahead of the current 
  bar (apex in the future), not behind it
— Containment: every bar between the formation's start and end must 
  have its high below the upper trendline and its low above the lower 
  trendline — no violations allowed
— Slope direction: upper falling + lower rising for symmetric; upper 
  flat + lower rising for ascending; lower flat + upper falling for 
  descending
— Alternating pivots: the four pivot points (2 highs, 2 lows) must 
  alternate in time order (H, L, H, L or L, H, L, H) — this prevents 
  false formations where all highs come before all lows or vice versa
— Symmetry ratio (symmetric only): the ratio of the two slopes must 
  exceed a minimum threshold so neither side dominates

ANGLE NORMALIZATION
The angle calculation normalizes price change against the formation's 
own height and bar count rather than using raw price differences. This 
makes the angle tolerance behave consistently across different symbols, 
price ranges, and timeframes — the same degree setting works on a $1 
stock and a $50,000 asset alike.

DUPLICATE FILTERING
Once a valid formation is found, its starting bar position is recorded. 
Any subsequent formation of the same type starting within a short 
distance of an existing one is treated as a duplicate and skipped, 
preventing the same structure from being drawn multiple times with 
slightly different pivot combinations.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MULTI-TIMEFRAME TABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
A table in the bottom-right corner runs the same pattern detection 
logic across five user-defined timeframes simultaneously and displays 
whether each triangle type is currently detected on each timeframe. 
A ✅ marks a detected pattern; — means none found.

This gives you a fast structural overview without switching charts — 
if the 1H and 4H both show an ascending triangle, that confluence may 
carry more weight than a pattern on a single timeframe alone.

The MTF scan uses a sampled bar validation (checking approximately 12 
evenly-spaced points within the formation rather than every bar) to 
keep performance reasonable across multiple timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. SET PIVOT LENGTH
   Controls how significant a swing high or low must be. Lower values 
   (2–5) detect more frequent, shorter-term pivots. Higher values 
   (10–20) require more surrounding bars and detect only major structure.

2. SET LOOKBACK
   Maximum bar span a formation can cover. Increase this to allow 
   larger, longer-term formations; decrease it to focus on recent 
   structure only.

3. ADJUST FLAT LINE ANGLE TOLERANCE
   For ascending and descending triangles, this controls how strictly 
   the flat boundary must be horizontal. At 0° only perfectly 
   horizontal lines qualify; at 10–15° a moderate slope is allowed. 
   Increase if you want more patterns detected; decrease for stricter 
   horizontal requirement.

4. CONTROL MAX PATTERNS
   Each pattern type has a separate maximum count. Set to 1 to show 
   only the most recent valid formation per type, or increase to see 
   multiple simultaneous formations.

5. SET LINE EXTENSION
   How many bars beyond the formation the trendlines extend, giving 
   a visual projection of where the boundaries will be in the future.

6. READ THE MTF TABLE
   Use the bottom-right table to check whether the same pattern type 
   is forming on higher timeframes, and prioritize formations that 
   appear on multiple timeframes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHERE TO USE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Works on any asset class (crypto, forex, equities, indices, commodities) 
and any timeframe. Particularly useful for:

— Breakout traders who want to be positioned before a triangle resolves
— Swing traders looking for compression zones where volatility is 
  contracting ahead of an expansion move
— Multi-timeframe analysis where higher-timeframe triangle formations 
  provide context for lower-timeframe entries
— Market structure analysis where triangle patterns help define the 
  current phase of price action (consolidation vs. expansion)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pivot Length           — symmetric lookback for swing high/low detection
Lookback               — maximum bar span a formation may cover
Max Triangles (each)   — maximum formations shown per pattern type
Show/Hide (each type)  — toggle each pattern type independently
Line Width             — visual thickness of the trendlines
Line Extension (Bars)  — how far beyond the formation lines extend
Show Labels            — enable/disable the formation labels on chart
Flat Line Angle Tolerance — horizontal strictness for ascending/descending
MTF Timeframes (TF 1–5)   — the five timeframes scanned in the MTF table

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGINALITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Triangle pattern detection is a known concept, but this indicator's 
specific implementation combines several elements not commonly found 
together: full bar-by-bar containment validation (not just endpoint 
checking), alternating pivot order enforcement, normalized angle 
calculation that works consistently across different assets and 
timeframes, and a simultaneous five-timeframe detection table — all 
within a single indicator. The flat-line angle tolerance using 
formation-height normalization is the author's own approach to making 
ascending and descending triangle detection robust across varied market 
conditions.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
This indicator is intended for educational and analytical purposes only. 
Triangle patterns do not guarantee a breakout in any particular 
direction. Always use proper risk management and combine multiple forms 
of analysis before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Onuriano

//@version=6
indicator('Triangle Pattern Scanner (Symmetric / Ascending / Descending)', shorttitle = 'TriSAD', overlay = true, max_lines_count = 500, max_labels_count = 500)

// ─── SETTINGS ───────────────────────────────────────────────────────────────
grp1 = 'Pivot Settings'
pivotLen = input.int(3, 'Pivot Length', minval = 2, maxval = 30, group = grp1)
lookback = input.int(200, 'Lookback', minval = 30, maxval = 500, group = grp1)
maxTri = input.int(1, 'Max Symmetric Triangles', minval = 1, maxval = 5, group = grp1)
maxAsc = input.int(1, 'Max Ascending Triangles', minval = 1, maxval = 5, group = grp1)
maxDesc = input.int(1, 'Max Descending Triangles', minval = 1, maxval = 5, group = grp1)

grp2 = 'Appearance'
showTri = input.bool(true, 'Show Symmetric Triangle', group = grp2)
showAsc = input.bool(true, 'Show Ascending Triangle', group = grp2)
showDesc = input.bool(true, 'Show Descending Triangle', group = grp2)
lineWidth = input.int(1, 'Line Width', minval = 1, maxval = 4, group = grp2)
extBars = input.int(5, 'Line Extension (Bars)', minval = 0, maxval = 200, step = 5, group = grp2)
showLabels = input.bool(true, 'Show Labels', group = grp2)

grp4 = 'Tolerance Settings'
flatTolDeg = input.float(10.0, 'Flat Line Angle Tolerance (°)', minval = 0.0, maxval = 25.0, step = 0.5, group = grp4, tooltip = '0° = perfectly horizontal. Defines the maximum angle the upper line in an ascending triangle (or lower line in a descending triangle) may deviate from horizontal. Adjustable between 0–25°.')

// ─── ANGLE HELPER ────────────────────────────────────────────────────────
// Calculates the visual angle of the line between two pivot points.
// Normalization: price change (dy) is scaled by the formation height (formHeight),
// bar count (dx) is scaled by lookback. This gives consistent angles across symbols/TFs.
// Result is in degrees between 0–90.
f_lineAngle(x1, y1, x2, y2, formHeight, barsTotal) =>
    dx = math.abs(x2 - x1)
    dy = math.abs(y2 - y1)
    if dx == 0 or formHeight <= 0 or barsTotal <= 0
        0.0
    // Normalize: divide dy by formation height, dx by total bar count
    else // This makes the ratio dimensionless and produces a meaningful angle via atan
        normDy = dy / formHeight
        normDx = dx / float(barsTotal)
        math.abs(math.atan(normDy / normDx) * 180.0 / math.pi)

// Symmetric Triangle colors
var array<color> triColors = array.from(color.new(#7B2FBE, 0), color.new(#5856D6, 0), color.new(#AF52DE, 0), color.new(#0A84FF, 0), color.new(#30B0C7, 0))

// Ascending Triangle colors
var array<color> ascColors = array.from(color.new(#34C759, 0), color.new(#30D158, 0), color.new(#32ADE6, 0), color.new(#00C7BE, 0), color.new(#64D2FF, 0))

// Descending Triangle colors
var array<color> descColors = array.from(color.new(#FF3B30, 0), color.new(#FF2D55, 0), color.new(#FF6B35, 0), color.new(#FF9500, 0), color.new(#FFD60A, 0))

grp3 = 'MTF Table'
tf1 = input.timeframe('15', 'TF 1', group = grp3)
tf2 = input.timeframe('60', 'TF 2', group = grp3)
tf3 = input.timeframe('120', 'TF 3', group = grp3)
tf4 = input.timeframe('240', 'TF 4', group = grp3)
tf5 = input.timeframe('D', 'TF 5', group = grp3)

// ─── PIVOT COLLECTION ─────────────────────────────────────────────────────────
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var array<int> phX = array.new_int(0)
var array<float> phY = array.new_float(0)
var array<int> plX = array.new_int(0)
var array<float> plY = array.new_float(0)

MAX_PIV = 8

if not na(ph)
    array.unshift(phX, bar_index - pivotLen)
    array.unshift(phY, ph)
    if array.size(phX) > MAX_PIV
        array.pop(phX)
        array.pop(phY)

if not na(pl)
    array.unshift(plX, bar_index - pivotLen)
    array.unshift(plY, pl)
    if array.size(plX) > MAX_PIV
        array.pop(plX)
        array.pop(plY)

// ─── HELPERS ───────────────────────────────────────────────────────────────
f_slope(x1, y1, x2, y2) =>
    (y2 - y1) / (x2 - x1)
f_intercept(x1, y1, s) =>
    y1 - s * x1
f_y(s, i, x) =>
    s * x + i

// ─── BAR-BY-BAR VALIDATION — FULL ─────────────────────────────────────────
f_barsValid(uS, uI, lS, lI, xS, xE) =>
    valid = true
    barCount = xE - xS
    if barCount > 0 and barCount <= 500
        for b = 0 to barCount by 1
            bIdx = xS + b
            bOff = bar_index - bIdx
            if bOff >= 0
                if high[bOff] > f_y(uS, uI, bIdx) or low[bOff] < f_y(lS, lI, bIdx)
                    valid := false
                    break
    valid

// ─── BAR-BY-BAR VALIDATION — SAMPLED (MTF) ──────────────────────────────
f_barsValidSampled(uS, uI, lS, lI, xS, xE) =>
    valid = true
    barCount = xE - xS
    if barCount > 0
        step = math.max(1, math.round(barCount / 12))
        b = 0
        while b <= barCount and valid
            bIdx = xS + b
            bOff = bar_index - bIdx
            if bOff >= 0 and bOff < bar_index
                if high[bOff] > f_y(uS, uI, bIdx) or low[bOff] < f_y(lS, lI, bIdx)
                    valid := false
                    valid
            b := b + step
            b
    valid

// ─── ALTERNATING ORDER CHECK: upper-lower-upper-lower pivot theme ──────────
// Sort pivots in time order and verify that upper/lower contacts alternate
// kind: 0=symmetric, 1=ascending, 2=descending
// Pivots touching the upper line are Highs, lower line pivots are Lows
// Order: must alternate consecutively — one upper contact then one lower contact
f_checkAlternating(hx1, hx2, lx1, lx2) =>
    // We have at least 2 high and 2 low pivots
    // Time order: hx1 < hx2 (high pivots), lx1 < lx2 (low pivots)
    // All 4 pivots must alternate: H, L, H, L or L, H, L, H
    p1x = int(na)
    p1t = int(na) // 0=high, 1=low
    p2x = int(na)
    p2t = int(na)
    p3x = int(na)
    p3t = int(na)
    p4x = int(na)
    p4t = int(na)

    // Sort the 4 pivots
    arr = array.from(hx1, hx2, lx1, lx2)
    typ = array.from(0, 0, 1, 1) // 0=high, 1=low

    // Simple bubble sort (4 elements)
    for pass = 0 to 2 by 1
        for idx = 0 to 2 by 1
            if array.get(arr, idx) > array.get(arr, idx + 1)
                tmpX = array.get(arr, idx)
                tmpT = array.get(typ, idx)
                array.set(arr, idx, array.get(arr, idx + 1))
                array.set(typ, idx, array.get(typ, idx + 1))
                array.set(arr, idx + 1, tmpX)
                array.set(typ, idx + 1, tmpT)

    t0 = array.get(typ, 0)
    t1 = array.get(typ, 1)
    t2 = array.get(typ, 2)
    t3 = array.get(typ, 3)

    // Alternating order check: HLHL or LHLH
    altOk = t0 != t1 and t1 != t2 and t2 != t3
    altOk

// ─── SYMMETRIC TRIANGLE GEOMETRY CHECK ─────────────────────────────────────
f_checkTriangle(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, mode) =>
    ok = false
    uS_ = float(na)
    uI_ = float(na)
    lS_ = float(na)
    lI_ = float(na)
    span = math.max(hx2 - hx1, lx2 - lx1)

    if span >= pivotLen * 2 and span <= lookback
        uS_ := f_slope(hx1, hy1, hx2, hy2)
        uI_ := f_intercept(hx1, hy1, uS_)
        lS_ := f_slope(lx1, ly1, lx2, ly2)
        lI_ := f_intercept(lx1, ly1, lS_)

        sDiff = uS_ - lS_
        xS = math.min(hx1, lx1)
        xE = math.max(hx2, lx2)

        // Symmetric triangle: upper falling, lower rising
        triOk = uS_ < 0 and lS_ > 0

        if triOk and math.abs(sDiff) > 1e-10
            crossX = (lI_ - uI_) / sDiff

            convergeOk = crossX > float(xE)

            absUS = math.abs(uS_)
            absLS = math.abs(lS_)
            symRatio = math.min(absUS, absLS) / math.max(absUS, absLS)
            symmetryOk = symRatio >= 0.3

            edgesOk = f_y(uS_, uI_, xS) > f_y(lS_, lI_, xS) and f_y(uS_, uI_, xE) > f_y(lS_, lI_, xE)

            midPrice = (hy1 + hy2 + ly1 + ly2) / 4.0
            slopeOk = math.abs(uS_) / midPrice * 100.0 > 0.001 and math.abs(lS_) / midPrice * 100.0 > 0.001

            // Alternating pivot order check
            altOk = f_checkAlternating(hx1, hx2, lx1, lx2)

            if convergeOk and symmetryOk and edgesOk and slopeOk and altOk
                barsOk = false
                if mode == 0
                    barsOk := f_barsValid(uS_, uI_, lS_, lI_, xS, xE)
                    barsOk
                else
                    barsOk := f_barsValidSampled(uS_, uI_, lS_, lI_, xS, xE)
                    barsOk
                if barsOk
                    ok := true
                    ok
    [ok, uS_, uI_, lS_, lI_]

// ─── ASCENDING TRIANGLE GEOMETRY CHECK ─────────────────────────────────────
// Upper line: nearly horizontal (angle tolerance in degrees, normalized to formation height)
// Lower line: rising upward (lS_ > 0)
f_checkAscending(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, mode, tolDeg) =>
    ok = false
    uS_ = float(na)
    uI_ = float(na)
    lS_ = float(na)
    lI_ = float(na)
    span = math.max(hx2 - hx1, lx2 - lx1)

    if span >= pivotLen * 2 and span <= lookback
        uS_ := f_slope(hx1, hy1, hx2, hy2)
        uI_ := f_intercept(hx1, hy1, uS_)
        lS_ := f_slope(lx1, ly1, lx2, ly2)
        lI_ := f_intercept(lx1, ly1, lS_)

        xS = math.min(hx1, lx1)
        xE = math.max(hx2, lx2)

        // Formation height: upper-lower distance at the left side of the formation
        formHeight = math.max(f_y(uS_, uI_, xS) - f_y(lS_, lI_, xS), 1e-10)
        barsTotal = float(math.max(xE - xS, 1))

        // Upper line angle (normalized)
        uAngle = f_lineAngle(hx1, hy1, hx2, hy2, formHeight, barsTotal)

        // Lower line angle — for meaningful rising check
        lAngle = f_lineAngle(lx1, ly1, lx2, ly2, formHeight, barsTotal)

        // Upper: nearly horizontal → angle within tolerance; direction doesn't matter (slight up/down both OK)
        upperFlatOk = uAngle <= tolDeg

        // Lower: clearly rising (lS_ > 0) and visually meaningful slope (at least 2x the upper line angle)
        lowerRisingOk = lS_ > 0 and lAngle > tolDeg * 2.0 + 1.0

        sDiff = uS_ - lS_

        if upperFlatOk and lowerRisingOk and math.abs(sDiff) > 1e-10
            crossX = (lI_ - uI_) / sDiff
            convergeOk = crossX > float(xE)

            edgesOk = f_y(uS_, uI_, xS) > f_y(lS_, lI_, xS) and f_y(uS_, uI_, xE) > f_y(lS_, lI_, xE)

            altOk = f_checkAlternating(hx1, hx2, lx1, lx2)

            if convergeOk and edgesOk and altOk
                barsOk = false
                if mode == 0
                    barsOk := f_barsValid(uS_, uI_, lS_, lI_, xS, xE)
                    barsOk
                else
                    barsOk := f_barsValidSampled(uS_, uI_, lS_, lI_, xS, xE)
                    barsOk
                if barsOk
                    ok := true
                    ok
    [ok, uS_, uI_, lS_, lI_]

// ─── DESCENDING TRIANGLE GEOMETRY CHECK ──────────────────────────────────
// Lower line: nearly horizontal (angle tolerance in degrees, normalized to formation height)
// Upper line: falling downward (uS_ < 0)
f_checkDescending(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, mode, tolDeg) =>
    ok = false
    uS_ = float(na)
    uI_ = float(na)
    lS_ = float(na)
    lI_ = float(na)
    span = math.max(hx2 - hx1, lx2 - lx1)

    if span >= pivotLen * 2 and span <= lookback
        uS_ := f_slope(hx1, hy1, hx2, hy2)
        uI_ := f_intercept(hx1, hy1, uS_)
        lS_ := f_slope(lx1, ly1, lx2, ly2)
        lI_ := f_intercept(lx1, ly1, lS_)

        xS = math.min(hx1, lx1)
        xE = math.max(hx2, lx2)

        formHeight = math.max(f_y(uS_, uI_, xS) - f_y(lS_, lI_, xS), 1e-10)
        barsTotal = float(math.max(xE - xS, 1))

        lAngle = f_lineAngle(lx1, ly1, lx2, ly2, formHeight, barsTotal)
        uAngle = f_lineAngle(hx1, hy1, hx2, hy2, formHeight, barsTotal)

        // Lower: nearly horizontal
        lowerFlatOk = lAngle <= tolDeg

        // Upper: clearly falling (uS_ < 0) and visually meaningful slope
        upperFallingOk = uS_ < 0 and uAngle > tolDeg * 2.0 + 1.0

        sDiff = uS_ - lS_

        if lowerFlatOk and upperFallingOk and math.abs(sDiff) > 1e-10
            crossX = (lI_ - uI_) / sDiff
            convergeOk = crossX > float(xE)

            edgesOk = f_y(uS_, uI_, xS) > f_y(lS_, lI_, xS) and f_y(uS_, uI_, xE) > f_y(lS_, lI_, xE)

            altOk = f_checkAlternating(hx1, hx2, lx1, lx2)

            if convergeOk and edgesOk and altOk
                barsOk = false
                if mode == 0
                    barsOk := f_barsValid(uS_, uI_, lS_, lI_, xS, xE)
                    barsOk
                else
                    barsOk := f_barsValidSampled(uS_, uI_, lS_, lI_, xS, xE)
                    barsOk
                if barsOk
                    ok := true
                    ok
    [ok, uS_, uI_, lS_, lI_]

// ─── FORMATION ARRAYS ────────────────────────────────────────────────────────
var array<int> found_x1 = array.new_int(0)
var array<int> found_x2 = array.new_int(0)
var array<float> found_uS = array.new_float(0)
var array<float> found_uI = array.new_float(0)
var array<float> found_lS = array.new_float(0)
var array<float> found_lI = array.new_float(0)
var array<int> found_kind = array.new_int(0) // 0=symmetric, 1=ascending, 2=descending

var array<line> drawnLines = array.new_line(0)
var array<label> drawnLabels = array.new_label(0)
var array<linefill> drawnFills = array.new_linefill(0)

// ─── DUPLICATE CHECK ─────────────────────────────────────────────────────────
f_isDuplicate(xS, k) =>
    dup = false
    sz = array.size(found_x1)
    if sz > 0
        for d = 0 to sz - 1 by 1
            if array.get(found_kind, d) == k and math.abs(array.get(found_x1, d) - xS) < pivotLen * 2
                dup := true
                dup
    dup

// ─── SYMMETRIC TRIANGLE SCAN ────────────────────────────────────────────────
f_scanTriangle() =>
    hSize = array.size(phX)
    lSize = array.size(plX)
    cnt = 0
    if hSize >= 2 and lSize >= 2
        for i = hSize - 1 to 1 by 1
            if cnt >= maxTri
                break
            for j = 0 to i - 1 by 1
                if cnt >= maxTri
                    break
                hx1 = array.get(phX, i)
                hy1 = array.get(phY, i)
                hx2 = array.get(phX, j)
                hy2 = array.get(phY, j)
                for k = lSize - 1 to 1 by 1
                    if cnt >= maxTri
                        break
                    for l = 0 to k - 1 by 1
                        if cnt >= maxTri
                            break
                        lx1 = array.get(plX, k)
                        ly1 = array.get(plY, k)
                        lx2 = array.get(plX, l)
                        ly2 = array.get(plY, l)
                        [ok, uS, uI, lS, lI] = f_checkTriangle(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, 0)
                        if ok
                            xS = math.min(hx1, lx1)
                            xE = math.max(hx2, lx2)
                            if not f_isDuplicate(xS, 0)
                                array.push(found_x1, xS)
                                array.push(found_x2, xE)
                                array.push(found_uS, uS)
                                array.push(found_uI, uI)
                                array.push(found_lS, lS)
                                array.push(found_lI, lI)
                                array.push(found_kind, 0)
                                cnt := cnt + 1
                                cnt
    cnt

// ─── ASCENDING TRIANGLE SCAN ────────────────────────────────────────────────
f_scanAscending() =>
    hSize = array.size(phX)
    lSize = array.size(plX)
    cnt = 0
    if hSize >= 2 and lSize >= 2
        for i = hSize - 1 to 1 by 1
            if cnt >= maxAsc
                break
            for j = 0 to i - 1 by 1
                if cnt >= maxAsc
                    break
                hx1 = array.get(phX, i)
                hy1 = array.get(phY, i)
                hx2 = array.get(phX, j)
                hy2 = array.get(phY, j)
                for k = lSize - 1 to 1 by 1
                    if cnt >= maxAsc
                        break
                    for l = 0 to k - 1 by 1
                        if cnt >= maxAsc
                            break
                        lx1 = array.get(plX, k)
                        ly1 = array.get(plY, k)
                        lx2 = array.get(plX, l)
                        ly2 = array.get(plY, l)
                        [ok, uS, uI, lS, lI] = f_checkAscending(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, 0, flatTolDeg)
                        if ok
                            xS = math.min(hx1, lx1)
                            xE = math.max(hx2, lx2)
                            if not f_isDuplicate(xS, 1)
                                array.push(found_x1, xS)
                                array.push(found_x2, xE)
                                array.push(found_uS, uS)
                                array.push(found_uI, uI)
                                array.push(found_lS, lS)
                                array.push(found_lI, lI)
                                array.push(found_kind, 1)
                                cnt := cnt + 1
                                cnt
    cnt

// ─── DESCENDING TRIANGLE SCAN ─────────────────────────────────────────────
f_scanDescending() =>
    hSize = array.size(phX)
    lSize = array.size(plX)
    cnt = 0
    if hSize >= 2 and lSize >= 2
        for i = hSize - 1 to 1 by 1
            if cnt >= maxDesc
                break
            for j = 0 to i - 1 by 1
                if cnt >= maxDesc
                    break
                hx1 = array.get(phX, i)
                hy1 = array.get(phY, i)
                hx2 = array.get(phX, j)
                hy2 = array.get(phY, j)
                for k = lSize - 1 to 1 by 1
                    if cnt >= maxDesc
                        break
                    for l = 0 to k - 1 by 1
                        if cnt >= maxDesc
                            break
                        lx1 = array.get(plX, k)
                        ly1 = array.get(plY, k)
                        lx2 = array.get(plX, l)
                        ly2 = array.get(plY, l)
                        [ok, uS, uI, lS, lI] = f_checkDescending(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, 0, flatTolDeg)
                        if ok
                            xS = math.min(hx1, lx1)
                            xE = math.max(hx2, lx2)
                            if not f_isDuplicate(xS, 2)
                                array.push(found_x1, xS)
                                array.push(found_x2, xE)
                                array.push(found_uS, uS)
                                array.push(found_uI, uI)
                                array.push(found_lS, lS)
                                array.push(found_lI, lI)
                                array.push(found_kind, 2)
                                cnt := cnt + 1
                                cnt
    cnt

// ─── MTF SIGNAL FUNCTION ────────────────────────────────────────────────────
f_mtfSignal() =>
    _ph = ta.pivothigh(high, pivotLen, pivotLen)
    _pl = ta.pivotlow(low, pivotLen, pivotLen)

    var array<int> _phX = array.new_int(0)
    var array<float> _phY = array.new_float(0)
    var array<int> _plX = array.new_int(0)
    var array<float> _plY = array.new_float(0)

    if not na(_ph)
        array.unshift(_phX, bar_index - pivotLen)
        array.unshift(_phY, _ph)
        if array.size(_phX) > MAX_PIV
            array.pop(_phX)
            array.pop(_phY)
    if not na(_pl)
        array.unshift(_plX, bar_index - pivotLen)
        array.unshift(_plY, _pl)
        if array.size(_plX) > MAX_PIV
            array.pop(_plX)
            array.pop(_plY)

    _hSize = array.size(_phX)
    _lSize = array.size(_plX)
    _foundT = false
    _foundA = false
    _foundD = false
    _limitBar = bar_index - 200

    if _hSize >= 2 and _lSize >= 2
        _hMax = math.min(_hSize, 4)
        _lMax = math.min(_lSize, 4)

        for i = _hMax - 1 to 1 by 1
            if _foundT and _foundA and _foundD
                break
            for j = 0 to i - 1 by 1
                if _foundT and _foundA and _foundD
                    break
                hx1 = array.get(_phX, i)
                hy1 = array.get(_phY, i)
                hx2 = array.get(_phX, j)
                hy2 = array.get(_phY, j)
                if hx1 < _limitBar or hx2 < _limitBar
                    continue
                for k = _lMax - 1 to 1 by 1
                    if _foundT and _foundA and _foundD
                        break
                    for l = 0 to k - 1 by 1
                        if _foundT and _foundA and _foundD
                            break
                        lx1 = array.get(_plX, k)
                        ly1 = array.get(_plY, k)
                        lx2 = array.get(_plX, l)
                        ly2 = array.get(_plY, l)
                        if lx1 < _limitBar or lx2 < _limitBar
                            continue
                        if not _foundT
                            [okT, _, _, _, _] = f_checkTriangle(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, 1)
                            if okT
                                _foundT := true
                                _foundT
                        if not _foundA
                            [okA, _, _, _, _] = f_checkAscending(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, 1, flatTolDeg)
                            if okA
                                _foundA := true
                                _foundA
                        if not _foundD
                            [okD, _, _, _, _] = f_checkDescending(hx1, hy1, hx2, hy2, lx1, ly1, lx2, ly2, 1, flatTolDeg)
                            if okD
                                _foundD := true
                                _foundD

    (_foundT ? 1 : 0) + (_foundA ? 2 : 0) + (_foundD ? 4 : 0)

// ─── MTF DATA ──────────────────────────────────────────────────────────────
sig1 = request.security(syminfo.tickerid, tf1, f_mtfSignal(), lookahead = barmerge.lookahead_off)
sig2 = request.security(syminfo.tickerid, tf2, f_mtfSignal(), lookahead = barmerge.lookahead_off)
sig3 = request.security(syminfo.tickerid, tf3, f_mtfSignal(), lookahead = barmerge.lookahead_off)
sig4 = request.security(syminfo.tickerid, tf4, f_mtfSignal(), lookahead = barmerge.lookahead_off)
sig5 = request.security(syminfo.tickerid, tf5, f_mtfSignal(), lookahead = barmerge.lookahead_off)

// ─── MAIN BLOCK ──────────────────────────────────────────────────────────────
if barstate.islast or not na(ph) or not na(pl)
    sz = array.size(drawnLines)
    if sz > 0
        for i = 0 to sz - 1 by 1
            line.delete(array.get(drawnLines, i))
    sz2 = array.size(drawnLabels)
    if sz2 > 0
        for i = 0 to sz2 - 1 by 1
            label.delete(array.get(drawnLabels, i))
    sz3 = array.size(drawnFills)
    if sz3 > 0
        for i = 0 to sz3 - 1 by 1
            linefill.delete(array.get(drawnFills, i))

    array.clear(drawnLines)
    array.clear(drawnLabels)
    array.clear(drawnFills)
    array.clear(found_x1)
    array.clear(found_x2)
    array.clear(found_uS)
    array.clear(found_uI)
    array.clear(found_lS)
    array.clear(found_lI)
    array.clear(found_kind)

    if showTri
        f_scanTriangle()
    if showAsc
        f_scanAscending()
    if showDesc
        f_scanDescending()

    total = array.size(found_x1)
    if total > 0
        for i = 0 to total - 1 by 1
            x1 = array.get(found_x1, i)
            x2 = array.get(found_x2, i)
            uS = array.get(found_uS, i)
            uI = array.get(found_uI, i)
            lS = array.get(found_lS, i)
            lI = array.get(found_lI, i)
            kind = array.get(found_kind, i)

            col = kind == 0 ? array.get(triColors, math.min(i, array.size(triColors) - 1)) : kind == 1 ? array.get(ascColors, math.min(i, array.size(ascColors) - 1)) : array.get(descColors, math.min(i, array.size(descColors) - 1))

            ext = x2 + extBars

            ul = line.new(x1, f_y(uS, uI, x1), ext, f_y(uS, uI, ext), color = col, width = lineWidth, style = line.style_solid)
            ll = line.new(x1, f_y(lS, lI, x1), ext, f_y(lS, lI, ext), color = col, width = lineWidth, style = line.style_solid)
            array.push(drawnLines, ul)
            array.push(drawnLines, ll)

            lf = linefill.new(ul, ll, color = color.new(col, 88))
            array.push(drawnFills, lf)

            if showLabels
                midX = x1 + math.round((x2 - x1) / 2)
                midY = f_y(uS, uI, midX)
                txt = kind == 0 ? '🔺 Symmetric Triangle\n(Await Breakout)' : kind == 1 ? '📈 Ascending Triangle\n(Bullish Breakout)' : '📉 Descending Triangle\n(Bearish Breakout)'
                lb = label.new(midX, midY, txt, style = label.style_label_down, color = color.new(col, 15), textcolor = color.white, size = size.small)
                array.push(drawnLabels, lb)

// ─── INFO PANEL ──────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 7, bgcolor = color.new(color.black, 65), border_color = color.gray, border_width = 1, frame_color = color.gray, frame_width = 1)

if barstate.islast
    table.cell(tbl, 0, 0, 'Formation', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 1, 0, 'Signal', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 0, 1, '🔺 Sym. Triangle', text_color = #7B2FBE, text_size = size.small)
    table.cell(tbl, 1, 1, 'Await Breakout', text_color = color.purple, text_size = size.small)
    table.cell(tbl, 0, 2, '📈 Ascending Triangle', text_color = #34C759, text_size = size.small)
    table.cell(tbl, 1, 2, 'Bullish Breakout', text_color = color.green, text_size = size.small)
    table.cell(tbl, 0, 3, '📉 Descending Triangle', text_color = #FF3B30, text_size = size.small)
    table.cell(tbl, 1, 3, 'Bearish Breakout', text_color = color.red, text_size = size.small)
    table.cell(tbl, 0, 4, '─────────', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 1, 4, '─────────', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 0, 5, 'Pivot', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 1, 5, str.tostring(pivotLen), text_color = color.white, text_size = size.small)
    table.cell(tbl, 0, 6, 'Lookback', text_color = color.gray, text_size = size.small)
    table.cell(tbl, 1, 6, str.tostring(lookback), text_color = color.white, text_size = size.small)

// ─── MTF TABLE ───────────────────────────────────────────────────────────────
var table mtfTbl = table.new(position.bottom_right, 4, 6, bgcolor = color.new(color.black, 65), border_color = color.gray, border_width = 1, frame_color = color.gray, frame_width = 1)

if barstate.islast
    table.cell(mtfTbl, 0, 0, 'TF', text_color = color.gray, text_size = size.small, bgcolor = color.new(color.black, 50))
    table.cell(mtfTbl, 1, 0, '🔺 Sym.', text_color = #7B2FBE, text_size = size.small, bgcolor = color.new(color.black, 50))
    table.cell(mtfTbl, 2, 0, '📈 Asc.', text_color = #34C759, text_size = size.small, bgcolor = color.new(color.black, 50))
    table.cell(mtfTbl, 3, 0, '📉 Desc.', text_color = #FF3B30, text_size = size.small, bgcolor = color.new(color.black, 50))

    tfs = array.from(tf1, tf2, tf3, tf4, tf5)
    sigs = array.from(sig1, sig2, sig3, sig4, sig5)

    for r = 0 to 4 by 1
        tfLabel = array.get(tfs, r)
        sig = array.get(sigs, r)
        hasTri = math.floor(sig / 1) % 2 != 0
        hasAsc = math.floor(sig / 2) % 2 != 0
        hasDesc = math.floor(sig / 4) % 2 != 0
        table.cell(mtfTbl, 0, r + 1, tfLabel, text_color = color.white, text_size = size.small)
        table.cell(mtfTbl, 1, r + 1, hasTri ? '✅' : '—', text_color = hasTri ? color.new(#7B2FBE, 0) : color.new(color.gray, 30), text_size = size.small)
        table.cell(mtfTbl, 2, r + 1, hasAsc ? '✅' : '—', text_color = hasAsc ? color.new(#34C759, 0) : color.new(color.gray, 30), text_size = size.small)
        table.cell(mtfTbl, 3, r + 1, hasDesc ? '✅' : '—', text_color = hasDesc ? color.new(#FF3B30, 0) : color.new(color.gray, 30), text_size = size.small)
````
