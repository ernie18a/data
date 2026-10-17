# Price Void Atlas [AGPro Series]

- url: https://www.tradingview.com/script/o5IOncgB-Price-Void-Atlas-AGPro-Series/
- type: indicator
- pine_id: PUB;71063aea91214e59b1da481faa5b570e
- version: 4.0

## Description

Price Void Atlas [AGPro Series]

🗺️ OVERVIEW

Price Void Atlas maps the chart's low-interaction price corridors — zones where price travelled fast and spent very little time — and tracks how price behaves when it returns. Unlike volume-based profiles that highlight crowded price levels, this indicator surfaces the opposite: the empty highways of the chart. Every corridor carries a live state (Fresh, Entered, Passed, Rejected) so you can read return behavior at a glance.


🧭 UNIQUE EDGE

Most volume profile and imbalance tools show where price concentrated. Price Void Atlas inverts the question: where did price refuse to concentrate? The detection engine is purely time-weighted and ATR-normalized, so it works identically on instruments without reliable volume data (forex, many altcoins, CFDs). The state machine adds a second layer — it does not just detect voids, it follows their return stories. This combination (time-based emptiness detection + entry-side-aware state tracking) is the core differentiator.


🔬 METHODOLOGY

The Scan Length window is sliced into 40 horizontal price bands. For each historical bar in the window, every band it intersects receives an ATR-normalized time weight. Bands that accumulate weight below a sensitivity-driven percentile threshold are flagged as empty. Contiguous empty bands form a corridor. Height is capped at 50% of total range to keep corridors structurally meaningful. Candidates are scored on a 65/35 weighted blend of emptiness intensity and ATR-normalized height, then the top N survivors are kept. Optional vertical proximity merging (0.3×ATR) consolidates nearby corridors into larger atlas-feel zones.

The state machine then observes price behavior per corridor:
- Fresh → never touched since birth
- Entered → price crossed inside; entry side is locked (top or bottom)
- Passed → close crossed beyond the far boundary (clean traversal)
- Rejected → close reversed beyond entry side by 35% of corridor depth


🔔 SIGNALS & ALERTS

Three independent alert channels:
- Void Entered — price re-enters an active corridor
- Void Passed — price closes through the far boundary
- Void Rejected — price reverses past its entry side

Each alert fires once per bar on confirmed close. Corridors are drawn as persistent ATR-aware rectangles with state-colored borders and labels. A dominant corridor (highest rank score) gets a thicker border as a visual hierarchy cue.


🎛️ KEY INPUTS

Core Engine
- Scan Length (100–1000): window of bars analyzed
- Sensitivity (Strict / Balanced / Loose): emptiness threshold
- Max Voids (1–6): hard cap on simultaneous corridors
- Hide Resolved Voids: removes Passed/Rejected for a clean view
- Merge Vertically Close Voids: atlas consolidation

Visual
- Panel Location (5 positions), Panel Theme (Dark / Light)
- Panel Font Size, Label Font Size (tiny → large, default normal)
- Show Entry Side Hint (↑ / ↓ arrows on Entered labels)

Alerts
- Individual toggles for Entered / Passed / Rejected


🎯 HOW TO USE

1. Apply on a chart with enough history (200+ bars recommended for 300 Scan Length)
2. Fresh amber zones are untouched voids — potential re-interaction targets
3. When price approaches a Fresh zone, the corridor turns indigo (Entered)
4. Observe whether the interaction resolves as a traversal (Passed, teal) or a turn-away (Rejected, pink)
5. Use corridor boundaries as structural reference points alongside your own system
6. The dominant corridor (thickest border) represents the cleanest void by rank score
7. Works across all timeframes; adaptive rebuild cadence keeps performance consistent


⚠️ LIMITATIONS & TRANSPARENCY

- This is an analysis aid, not a trading strategy. It does not generate buy or sell signals.
- Corridor detection requires at least Scan Length bars of history; newly loaded charts render progressively as history accumulates.
- The time-weighted emptiness metric depends on ATR stability; very low-volatility environments may produce fewer meaningful voids.
- State transitions are evaluated on confirmed bar closes to prevent intrabar repainting.
- Corridors persist across bars but are rebuilt on an adaptive cadence (5–25 bars depending on timeframe) for CPU efficiency.
- All visuals are computed from the visible historical data on the current chart; extending the lookback will refresh the atlas.


🛡️ RISK DISCLOSURE

This indicator is provided for educational and analytical purposes only. It does not predict future price movement, does not generate trade recommendations, and does not constitute financial advice. Trading involves substantial risk of loss. Past corridor interactions do not guarantee future behavior. Always conduct your own research and risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────
// Price Void Atlas [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.4
//
// Maps low-interaction price voids where price travelled quickly and spent
// little time building acceptance. The atlas detects empty price corridors,
// tracks Fresh, Entered, Passed, and Rejected states, and presents each void
// with centered emptiness badges, right-edge lifecycle tags, and a clean AGPro panel
// for liquidity vacuum, imbalance zone, and unfilled price void analysis.
// ─────────────────────────────────────────────────

//@version=6
indicator("Price Void Atlas [AGPro Series]",
     shorttitle = "AG Pro PVA",
     overlay    = true,
     max_boxes_count  = 100,
     max_labels_count = 220,
     max_lines_count  = 80)

// ═════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════
g_core = "Core Engine"

scanLen = input.int(300, "Scan Length", minval = 100, maxval = 1000, step = 50, group = g_core,
     tooltip = "Number of recent bars analyzed to detect low-interaction price voids. Longer windows surface older structural voids, while shorter windows react faster to recent fast-travel zones.")
sensitivity = input.string("Balanced", "Sensitivity", options = ["Strict", "Balanced", "Loose"], group = g_core,
     tooltip = "Selection strictness for void detection. Strict shows only the emptiest voids, Balanced is the default atlas profile, and Loose surfaces more candidates.")
maxCorridors = input.int(2, "Max Voids", minval = 1, maxval = 6, group = g_core,
     tooltip = "Maximum number of simultaneous voids rendered. The default atlas focuses on the two highest-ranked corridors; increase only when broader context is needed.")
hideResolved = input.bool(true, "Hide Resolved Voids", group = g_core,
     tooltip = "When enabled, resolved voids are hidden so the chart focuses on live Fresh and Entered structures.")
mergeClose = input.bool(true, "Merge Vertically Close Voids", group = g_core,
     tooltip = "When enabled, vertically close voids are merged into a single larger corridor to preserve a clean atlas view.")

g_vis = "Visual"
showVoidBadges = input.bool(true, "Show Centered Void Badges", group = g_vis,
     tooltip = "Places a filled identity badge with the corridor emptiness percentage at the exact center of each visible void.")
showEdgeTags = input.bool(true, "Show Right Edge State Tags", group = g_vis,
     tooltip = "Shows a compact lifecycle tag at the right edge of each visible void without repeating the centered identity.")
showEntrySide = input.bool(true, "Show Entry Side Hint", group = g_vis,
     tooltip = "When enabled, Entered-state right-edge tags show an arrow hint for entry side context.")
zoneOpacity = input.int(88, "Void Fill Transparency", minval = 60, maxval = 95, group = g_vis,
     tooltip = "Base transparency of visible void corridors. Rank and lifecycle apply a small adaptive adjustment so priority remains clear without dominating price.")
labelSize = input.string("Normal", "Label Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g_vis,
     tooltip = "Font size for state tags and centered void badges.")

g_panel = "Panel"
showPanel = input.bool(true, "Show Panel", group = g_panel,
     tooltip = "Show or hide the AGPro status panel. Enabled by default for publication screenshots.")
panelLocation = input.string("Top Right", "Panel Location",
     options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = g_panel,
     tooltip = "Position of the information panel on the chart.")
panelTheme = input.string("Elite Dark", "Panel Theme", options = ["Elite Dark", "Slate", "Clean Light"], group = g_panel,
     tooltip = "Panel color theme. The blue AGPro header remains unchanged.")
panelSize = input.string("Normal", "Panel Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = g_panel,
     tooltip = "Font size of the information panel.")

g_alt = "Alerts"
alertOnEnter  = input.bool(true, "Alert: Void Entered",  group = g_alt,
     tooltip = "Fires when price enters an active void.")
alertOnPass   = input.bool(true, "Alert: Void Passed",   group = g_alt,
     tooltip = "Fires when price closes beyond the far boundary of a void it entered.")
alertOnReject = input.bool(true, "Alert: Void Rejected", group = g_alt,
     tooltip = "Fires when price reverses away from a void after interaction.")

MAX_HEIGHT_PCT = 0.50
REJECT_RETRACE = 0.35
EXTEND_BARS = 20
MERGE_ATR_MULT = 0.30

// ═════════════════════════════════════════════════
// AGPro Color Palette
// ═════════════════════════════════════════════════
headerBg      = color.rgb(37, 99, 235)
headerText    = color.rgb(245, 247, 250)
panelBgDark   = color.rgb(15, 23, 42)
panelBgSlate  = color.rgb(30, 41, 59)
panelBgLight  = color.rgb(245, 247, 250)
panelBorderD  = color.rgb(51, 65, 85)
panelBorderL  = color.rgb(203, 213, 225)
panelLabelD   = color.rgb(148, 163, 184)
panelLabelL   = color.rgb(71, 85, 105)
panelValueD   = color.rgb(226, 232, 240)
panelValueL   = color.rgb(15, 23, 42)
bullColor     = color.rgb(34, 197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

panelIsLight = panelTheme == "Clean Light"
panelBg = panelTheme == "Slate" ? panelBgSlate : panelIsLight ? panelBgLight : panelBgDark
panelBorder = panelIsLight ? panelBorderL : panelBorderD
panelLabelCol = panelIsLight ? panelLabelL : panelLabelD
panelValueCol = panelIsLight ? panelValueL : panelValueD

// ═════════════════════════════════════════════════
// HELPERS
// ═════════════════════════════════════════════════
f_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : s == "Huge" ? size.huge : size.normal

// Luminance-aware text color so every on-chart badge stays legible on its fill
f_text_on(color bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 145 ? color.rgb(17, 24, 39) : headerText

f_panelPos(string p) =>
    p == "Top Left" ? position.top_left :
     p == "Top Center" ? position.top_center :
     p == "Top Right" ? position.top_right :
     p == "Middle Left" ? position.middle_left :
     p == "Middle Center" ? position.middle_center :
     p == "Middle Right" ? position.middle_right :
     p == "Bottom Left" ? position.bottom_left :
     p == "Bottom Center" ? position.bottom_center : position.bottom_right

f_stateColor(string st) =>
    st == "Fresh" ? neutralColor : st == "Entered" ? accentColor : st == "Passed" ? bullColor : st == "Rejected" ? bearColor : neutralColor

f_stateShort(string st) =>
    st == "Fresh" ? "FRESH" : st == "Entered" ? "ENTERED" : st == "Passed" ? "PASSED" : st == "Rejected" ? "REJECTED" : st

// ═════════════════════════════════════════════════
// CORE STATE
// ═════════════════════════════════════════════════
atr14 = math.max(nz(ta.atr(14), ta.tr(true)), syminfo.mintick)
sliceCount = 40

type Corridor
    float top = na
    float bot = na
    int bornBar = na
    float emptiness = na
    string state = "Fresh"
    int enteredBar = na
    float entrySide = na
    bool resolved = false
    float rankScore = 0.0
    box bx = na
    label tag = na
    label badge = na

var array<Corridor> corridors = array.new<Corridor>()
var bool justEntered = false
var bool justPassed = false
var bool justRejected = false

var int cnt_total = 0
var int cnt_fresh = 0
var int cnt_entered = 0
var int cnt_passed = 0
var int cnt_rejected = 0
var float dominantEmptiness = 0.0

// Fair fill proof: when a void is entered, does price follow through in the fill
// direction (1.5 ATR) before reversing (1.0 ATR)? Close-based, single slot.
var float pvaProofTarget = na
var float pvaProofStop   = na
var int   pvaProofDir    = 0
var bool  pvaProofOpen   = false
var int   pvaProofAge    = na
var int   pvaProofWins   = 0
var int   pvaProofLosses = 0

// ═════════════════════════════════════════════════
// EMPTINESS SCAN
// ═════════════════════════════════════════════════
f_priceRange() =>
    ta.highest(high, scanLen) - ta.lowest(low, scanLen)

f_buildSlices() =>
    rng = f_priceRange()
    ll = ta.lowest(low, scanLen)
    sliceH = rng / sliceCount
    counts = array.new_float(sliceCount, 0.0)
    visits = array.new_int(sliceCount, 0)
    if rng > 0 and not na(atr14) and atr14 > 0
        for i = 0 to math.min(scanLen - 1, bar_index)
            hi = high[i]
            lo = low[i]
            if not na(hi) and not na(lo)
                bottomIdx = int(math.max(0, math.min(sliceCount - 1, math.floor((lo - ll) / sliceH))))
                topIdx = int(math.max(0, math.min(sliceCount - 1, math.floor((hi - ll) / sliceH))))
                barRange = math.max(hi - lo, syminfo.mintick)
                weight = 1.0 / math.max(barRange / atr14, 0.25)
                for s = bottomIdx to topIdx
                    array.set(counts, s, array.get(counts, s) + weight)
                    array.set(visits, s, array.get(visits, s) + 1)
    [counts, visits, ll, sliceH]

// ═════════════════════════════════════════════════
// VOID DETECTION
// ═════════════════════════════════════════════════
f_percentile() =>
    sensitivity == "Strict" ? 0.25 : sensitivity == "Loose" ? 0.55 : 0.40

f_minVisits() =>
    sensitivity == "Strict" ? 2 : 1

f_percentileValue(array<float> arr, float pct) =>
    result = 0.0
    sz = array.size(arr)
    if sz > 0
        sorted = array.copy(arr)
        array.sort(sorted, order.ascending)
        idx = int(math.min(sz - 1, math.max(0, math.floor(pct * (sz - 1)))))
        result := array.get(sorted, idx)
    result

f_detectCorridors() =>
    [counts, visits, ll, sliceH] = f_buildSlices()
    result = array.new<Corridor>()
    totalRange = sliceCount * sliceH
    maxCorridorH = totalRange * MAX_HEIGHT_PCT
    if array.size(counts) > 0
        maxCnt = array.max(counts)
        if maxCnt > 0
            visitedCounts = array.new_float(0)
            for i = 0 to sliceCount - 1
                if array.get(visits, i) >= 1
                    array.push(visitedCounts, array.get(counts, i))
            threshVal = array.size(visitedCounts) > 0 ? f_percentileValue(visitedCounts, f_percentile()) : 0.0
            minVis = f_minVisits()
            inCorridor = false
            runStart = 0
            runEmpt = 0.0
            for i = 0 to sliceCount - 1
                cnt = array.get(counts, i)
                vis = array.get(visits, i)
                isEmpty = vis >= minVis and cnt <= threshVal
                v = cnt / maxCnt
                if isEmpty and not inCorridor
                    inCorridor := true
                    runStart := i
                    runEmpt := 1.0 - v
                else if isEmpty and inCorridor
                    runEmpt := math.max(runEmpt, 1.0 - v)
                else if not isEmpty and inCorridor
                    runLen = i - runStart
                    if runLen >= 1
                        height = runLen * sliceH
                        if height <= maxCorridorH
                            c = Corridor.new()
                            c.bot := ll + runStart * sliceH
                            c.top := ll + i * sliceH
                            c.bornBar := bar_index
                            c.emptiness := runEmpt
                            c.state := "Fresh"
                            array.push(result, c)
                    inCorridor := false
                    runEmpt := 0.0
            if inCorridor
                runLen = sliceCount - runStart
                if runLen >= 1
                    height = runLen * sliceH
                    if height <= maxCorridorH
                        c = Corridor.new()
                        c.bot := ll + runStart * sliceH
                        c.top := ll + sliceCount * sliceH
                        c.bornBar := bar_index
                        c.emptiness := runEmpt
                        c.state := "Fresh"
                        array.push(result, c)
    result

// ═════════════════════════════════════════════════
// MERGE / RANK
// ═════════════════════════════════════════════════
f_mergeClose(array<Corridor> arr) =>
    out = array.new<Corridor>()
    sz = array.size(arr)
    if sz > 0 and not na(atr14) and atr14 > 0
        sortedArr = array.new<Corridor>()
        used = array.new_bool(sz, false)
        for k = 0 to sz - 1
            bestI = -1
            bestBot = 1e20
            for i = 0 to sz - 1
                if not array.get(used, i)
                    c = array.get(arr, i)
                    if c.bot < bestBot
                        bestBot := c.bot
                        bestI := i
            if bestI >= 0
                array.set(used, bestI, true)
                array.push(sortedArr, array.get(arr, bestI))
        gap = MERGE_ATR_MULT * atr14
        if array.size(sortedArr) > 0
            current = array.get(sortedArr, 0)
            if array.size(sortedArr) > 1
                for i = 1 to array.size(sortedArr) - 1
                    nxt = array.get(sortedArr, i)
                    if nxt.bot - current.top <= gap
                        current.top := math.max(current.top, nxt.top)
                        current.bot := math.min(current.bot, nxt.bot)
                        current.emptiness := math.max(current.emptiness, nxt.emptiness)
                    else
                        array.push(out, current)
                        current := nxt
            array.push(out, current)
    else if sz > 0
        for i = 0 to sz - 1
            array.push(out, array.get(arr, i))
    out

f_rankScore(Corridor c) =>
    height = math.abs(c.top - c.bot)
    heightAtr = atr14 > 0 ? height / atr14 : 0.0
    c.emptiness * 0.65 + math.min(heightAtr / 3.0, 1.0) * 0.35

f_keepTopN(array<Corridor> arr, int n) =>
    kept = array.new<Corridor>()
    sz = array.size(arr)
    if sz > 0
        used = array.new_bool(sz, false)
        for k = 0 to n - 1
            bestI = -1
            bestS = -1.0
            for i = 0 to sz - 1
                if not array.get(used, i)
                    c = array.get(arr, i)
                    s = f_rankScore(c)
                    c.rankScore := s
                    if s > bestS
                        bestS := s
                        bestI := i
            if bestI >= 0
                array.set(used, bestI, true)
                array.push(kept, array.get(arr, bestI))
            else
                break
    kept

// ═════════════════════════════════════════════════
// STATE MACHINE
// ═════════════════════════════════════════════════
f_updateState(Corridor c) =>
    enteredNow = false
    passedNow = false
    rejectedNow = false
    if not c.resolved and not na(close)
        depth = c.top - c.bot
        insideNow = low <= c.top and high >= c.bot
        prevState = c.state
        if c.state == "Fresh"
            if insideNow
                c.state := "Entered"
                c.enteredBar := bar_index
                mid = (c.top + c.bot) * 0.5
                c.entrySide := close > mid ? c.top : c.bot
        else if c.state == "Entered"
            if c.entrySide == c.top and close < c.bot
                c.state := "Passed"
                c.resolved := true
            else if c.entrySide == c.bot and close > c.top
                c.state := "Passed"
                c.resolved := true
            else if c.entrySide == c.top and close > c.top + REJECT_RETRACE * depth
                c.state := "Rejected"
                c.resolved := true
            else if c.entrySide == c.bot and close < c.bot - REJECT_RETRACE * depth
                c.state := "Rejected"
                c.resolved := true
        if c.state != prevState
            enteredNow := c.state == "Entered"
            passedNow := c.state == "Passed"
            rejectedNow := c.state == "Rejected"
    [enteredNow, passedNow, rejectedNow]

f_overlap(Corridor a, Corridor b) =>
    lo = math.max(a.bot, b.bot)
    hi = math.min(a.top, b.top)
    ov = math.max(hi - lo, 0.0)
    refH = math.min(a.top - a.bot, b.top - b.bot)
    refH > 0 ? ov / refH : 0.0

// ═════════════════════════════════════════════════
// DRAWING
// ═════════════════════════════════════════════════
f_borderWidth(Corridor c, float maxScore) =>
    isDominant = maxScore > 0 and c.rankScore >= maxScore * 0.95
    c.state == "Entered" or isDominant ? 3 : 2

f_tagText(Corridor c) =>
    hint = ""
    if showEntrySide and c.state == "Entered" and not na(c.entrySide)
        hint := c.entrySide == c.bot ? " ↑" : " ↓"
    c.state == "Fresh" ? "FRESH WATCH" :
     c.state == "Entered" ? "ENTRY" + hint :
     f_stateShort(c.state)

f_badgeText(Corridor c) =>
    "PRICE VOID | " + str.tostring(math.round(c.emptiness * 100.0)) + "% EMPTY"

f_drawCorridor(Corridor c, float maxScore) =>
    tfSec = timeframe.in_seconds(timeframe.period)
    offsetBars = math.min(scanLen, bar_index - math.max(0, c.bornBar - scanLen))
    xLeftT = time - offsetBars * tfSec * 1000
    xRightT = time + EXTEND_BARS * tfSec * 1000
    xMidT = int(math.round((xLeftT + xRightT) * 0.5))
    yMid = (c.top + c.bot) * 0.5
    stCol = f_stateColor(c.state)
    isDominant = maxScore > 0 and c.rankScore >= maxScore * 0.95
    fillAlpha = c.state == "Entered" ? math.max(60, zoneOpacity - 3) : isDominant ? zoneOpacity : math.min(95, zoneOpacity + 4)
    borderAlpha = c.state == "Entered" or isDominant ? 22 : 40
    fillCol = color.new(stCol, fillAlpha)
    borderCol = color.new(stCol, borderAlpha)
    bWidth = f_borderWidth(c, maxScore)
    lSize = f_size(labelSize)

    if na(c.bx)
        c.bx := box.new(xLeftT, c.top, xRightT, c.bot, xloc = xloc.bar_time, border_color = borderCol, border_width = bWidth, bgcolor = fillCol)
    else
        box.set_lefttop(c.bx, xLeftT, c.top)
        box.set_rightbottom(c.bx, xRightT, c.bot)
        box.set_bgcolor(c.bx, fillCol)
        box.set_border_color(c.bx, borderCol)
        box.set_border_width(c.bx, bWidth)

    if showVoidBadges
        if na(c.badge)
            c.badge := label.new(xMidT, yMid, f_badgeText(c), xloc = xloc.bar_time, yloc = yloc.price, color = stCol, textcolor = f_text_on(stCol), style = label.style_label_center, size = lSize)
        else
            label.set_xy(c.badge, xMidT, yMid)
            label.set_text(c.badge, f_badgeText(c))
            label.set_color(c.badge, stCol)
            label.set_textcolor(c.badge, f_text_on(stCol))
            label.set_size(c.badge, lSize)
    else if not na(c.badge)
        label.delete(c.badge)
        c.badge := na

    if showEdgeTags
        yLbl = close > c.top ? c.top : close < c.bot ? c.bot : close
        if na(c.tag)
            c.tag := label.new(xRightT, yLbl, f_tagText(c), xloc = xloc.bar_time, yloc = yloc.price, color = stCol, textcolor = f_text_on(stCol), style = label.style_label_left, size = lSize)
        else
            label.set_xy(c.tag, xRightT, yLbl)
            label.set_text(c.tag, f_tagText(c))
            label.set_color(c.tag, stCol)
            label.set_textcolor(c.tag, f_text_on(stCol))
            label.set_size(c.tag, lSize)
    else if not na(c.tag)
        label.delete(c.tag)
        c.tag := na
    0

f_rebuildEvery() =>
    tfSec = timeframe.in_seconds(timeframe.period)
    out = 10
    if not na(tfSec)
        out := tfSec <= 60 ? 5 : tfSec <= 900 ? 10 : tfSec <= 3600 ? 15 : 25
    out

// ═════════════════════════════════════════════════
// MAIN PIPELINE
// ═════════════════════════════════════════════════
var int lastBuildBar = 0

justEntered := false
justPassed := false
justRejected := false

if barstate.isconfirmed
    doRebuild = bar_index - lastBuildBar >= f_rebuildEvery() or array.size(corridors) == 0
    if doRebuild
        lastBuildBar := bar_index
        fresh = f_detectCorridors()
        merged = mergeClose ? f_mergeClose(fresh) : fresh
        ranked = f_keepTopN(merged, maxCorridors)
        newList = array.new<Corridor>()
        sizeExisting = array.size(corridors)
        usedExisting = array.new_bool(sizeExisting, false)
        if array.size(ranked) > 0
            for i = 0 to array.size(ranked) - 1
                cand = array.get(ranked, i)
                matched = false
                if sizeExisting > 0
                    for j = 0 to sizeExisting - 1
                        if not array.get(usedExisting, j)
                            existing = array.get(corridors, j)
                            if f_overlap(cand, existing) > 0.4
                                existing.top := cand.top
                                existing.bot := cand.bot
                                existing.emptiness := math.max(existing.emptiness, cand.emptiness)
                                existing.rankScore := cand.rankScore
                                array.push(newList, existing)
                                array.set(usedExisting, j, true)
                                matched := true
                                break
                if not matched
                    array.push(newList, cand)
        if sizeExisting > 0
            for j = 0 to sizeExisting - 1
                if not array.get(usedExisting, j)
                    old = array.get(corridors, j)
                    if not na(old.bx)
                        box.delete(old.bx)
                    if not na(old.tag)
                        label.delete(old.tag)
                    if not na(old.badge)
                        label.delete(old.badge)
        corridors := newList

    if array.size(corridors) > 0
        for i = 0 to array.size(corridors) - 1
            c = array.get(corridors, i)
            [enN, paN, reN] = f_updateState(c)
            justEntered := justEntered or enN
            justPassed := justPassed or paN
            justRejected := justRejected or reN
            if enN and not pvaProofOpen and not na(atr14) and not na(c.entrySide)
                pvaProofDir    := c.entrySide == c.top ? -1 : 1
                pvaProofTarget := pvaProofDir == 1 ? close + atr14 * 1.5 : close - atr14 * 1.5
                pvaProofStop   := pvaProofDir == 1 ? close - atr14 * 1.0 : close + atr14 * 1.0
                pvaProofAge    := 0
                pvaProofOpen   := true

    if pvaProofOpen and not na(pvaProofTarget) and not na(pvaProofStop)
        proofHitStop   = pvaProofDir == 1 ? close <= pvaProofStop : close >= pvaProofStop
        proofHitTarget = pvaProofDir == 1 ? close >= pvaProofTarget : close <= pvaProofTarget
        if proofHitStop
            pvaProofLosses += 1
            pvaProofOpen := false
        else if proofHitTarget
            pvaProofWins += 1
            pvaProofOpen := false
        else
            pvaProofAge := nz(pvaProofAge) + 1
            if pvaProofAge > 40
                pvaProofOpen := false

if barstate.islast
    maxScore = 0.0
    if array.size(corridors) > 0
        for i = 0 to array.size(corridors) - 1
            c = array.get(corridors, i)
            maxScore := math.max(maxScore, c.rankScore)
        for i = 0 to array.size(corridors) - 1
            c = array.get(corridors, i)
            if hideResolved and c.resolved
                if not na(c.bx)
                    box.delete(c.bx)
                    c.bx := na
                if not na(c.tag)
                    label.delete(c.tag)
                    c.tag := na
                if not na(c.badge)
                    label.delete(c.badge)
                    c.badge := na
            else
                f_drawCorridor(c, maxScore)

// ═════════════════════════════════════════════════
// ALERTS
// ═════════════════════════════════════════════════
if justEntered and alertOnEnter
    alert("Price Void Atlas: Void ENTERED at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if justPassed and alertOnPass
    alert("Price Void Atlas: Void PASSED at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if justRejected and alertOnReject
    alert("Price Void Atlas: Void REJECTED at " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

alertcondition(justEntered, "Void Entered", "Price entered an active void.")
alertcondition(justPassed, "Void Passed", "Price passed through a void.")
alertcondition(justRejected, "Void Rejected", "Price rejected from a void.")

// ═════════════════════════════════════════════════
// PANEL COUNTERS
// ═════════════════════════════════════════════════
if barstate.islast
    cnt_total := array.size(corridors)
    cnt_fresh := 0
    cnt_entered := 0
    cnt_passed := 0
    cnt_rejected := 0
    dominantEmptiness := 0.0
    bestScore = -1.0
    if cnt_total > 0
        for i = 0 to cnt_total - 1
            c = array.get(corridors, i)
            if c.state == "Fresh"
                cnt_fresh += 1
            else if c.state == "Entered"
                cnt_entered += 1
            else if c.state == "Passed"
                cnt_passed += 1
            else if c.state == "Rejected"
                cnt_rejected += 1
            if c.rankScore > bestScore
                bestScore := c.rankScore
                dominantEmptiness := c.emptiness

f_currentSide() =>
    result = "—"
    nearestDist = 1e20
    if array.size(corridors) > 0
        for i = 0 to array.size(corridors) - 1
            c = array.get(corridors, i)
            mid = (c.top + c.bot) * 0.5
            d = math.abs(close - mid)
            if d < nearestDist
                nearestDist := d
                result := close > c.top ? "Above" : close < c.bot ? "Below" : "Inside"
    result

f_routeSummary() =>
    lastState = "None"
    lastBar = -1
    if array.size(corridors) > 0
        for i = 0 to array.size(corridors) - 1
            c = array.get(corridors, i)
            if c.state != "Fresh" and not na(c.enteredBar)
                if c.enteredBar > lastBar
                    lastBar := c.enteredBar
                    lastState := c.state
    lastState

// ═════════════════════════════════════════════════
// PANEL
// ═════════════════════════════════════════════════
var table panel = na
var string panelPosCache = ""
var string panelThemeCache = ""

if not showPanel and not na(panel)
    table.delete(panel)
    panel := na
    panelPosCache := ""
    panelThemeCache := ""

if showPanel and barstate.islast
    needPanel = na(panel) or panelPosCache != panelLocation or panelThemeCache != panelTheme
    if needPanel
        if not na(panel)
            table.delete(panel)
        panel := table.new(f_panelPos(panelLocation), 2, 9, bgcolor = panelBg, border_color = panelBorder, border_width = 1, frame_color = panelBorder, frame_width = 1)
        panelPosCache := panelLocation
        panelThemeCache := panelTheme
    table.set_position(panel, f_panelPos(panelLocation))
    table.clear(panel, 0, 0, 1, 8)
    table.merge_cells(panel, 0, 0, 1, 0)
    pSize = f_size(panelSize)
    table.cell(panel, 0, 0, "AG Pro Price Void Atlas", bgcolor = headerBg, text_color = headerText, text_size = pSize, text_halign = text.align_center)
    active = cnt_total - cnt_passed - cnt_rejected
    emptPct = dominantEmptiness * 100.0
    lastRoute = f_routeSummary()
    routeColor = lastRoute == "Passed" ? bullColor : lastRoute == "Rejected" ? bearColor : lastRoute == "Entered" ? accentColor : panelLabelCol

    table.cell(panel, 0, 1, "Active", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 1, str.tostring(active) + " / " + str.tostring(cnt_total), text_color = panelValueCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Fresh / Entered", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 2, str.tostring(cnt_fresh) + " / " + str.tostring(cnt_entered), text_color = cnt_entered > 0 ? accentColor : neutralColor, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Resolved", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 3, str.tostring(cnt_passed) + " passed · " + str.tostring(cnt_rejected) + " rejected", text_color = panelValueCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Emptiness", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 4, cnt_total > 0 ? str.tostring(emptPct, "#.0") + "%" : "—", text_color = panelValueCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)
    table.cell(panel, 0, 5, "Price", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 5, f_currentSide(), text_color = panelValueCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)
    table.cell(panel, 0, 6, "Last Route", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 6, lastRoute, text_color = routeColor, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)

    sideNow = f_currentSide()
    activeVoids = cnt_fresh + cnt_entered
    actionText = cnt_total == 0 ? "No void mapped" : sideNow == "Inside" ? "Inside void - expect fill" : activeVoids > 0 ? "Live void - watch interaction" : "Voids resolved - stand by"
    actionCol = cnt_total == 0 ? panelLabelCol : sideNow == "Inside" ? accentColor : activeVoids > 0 ? neutralColor : panelLabelCol
    pvaProofTotal = pvaProofWins + pvaProofLosses
    pvaProofRate = pvaProofTotal == 0 ? 0.0 : 100.0 * pvaProofWins / pvaProofTotal
    proofText = pvaProofTotal < 6 ? "Building (" + str.tostring(pvaProofTotal) + ")" : str.tostring(math.round(pvaProofRate)) + "% (" + str.tostring(pvaProofTotal) + ")"
    proofCol = pvaProofTotal < 6 ? panelLabelCol : pvaProofRate >= 55 ? bullColor : pvaProofRate >= 45 ? neutralColor : bearColor

    table.cell(panel, 0, 7, "Action", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 7, actionText, text_color = actionCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)
    table.cell(panel, 0, 8, "Fill Proof", text_color = panelLabelCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_left)
    table.cell(panel, 1, 8, proofText, text_color = proofCol, text_size = pSize, bgcolor = panelBg, text_halign = text.align_right)

// ═════════════════════════════════════════════════
// END
// ═════════════════════════════════════════════════
````
