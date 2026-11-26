# Intraday Pivot Points [DYNA]

- url: https://www.tradingview.com/script/W4JK692t-Intraday-Pivot-Points-DYNA/
- type: indicator
- pine_id: PUB;d2fa531b65094bf5b42c63c5d6b22b3a
- version: 1.0

## Description

Intraday Pivot Points draws a fresh set of horizontal price levels at the start of every trading day, calculated entirely from the previous day's high, low, and close. The central pivot anchors the day's bias -- price above it skews bullish, below it skews bearish -- and three resistance levels (R1, R2, R3) plus three support levels (S1, S2, S3) frame the typical and extreme intraday targets. Levels are computed once at session open and stay fixed all day, which makes them clean structural reference points that never repaint or shift mid-session.

Four pivot methods are built in. Classic uses the original floor-trader formula. Fibonacci offsets the levels at 38.2%, 61.8%, and 100% of yesterday's range. Woodie applies a close-weighted pivot. Camarilla produces tighter close-anchored levels often used for mean-reversion. Switch between them with one dropdown -- the rest of the indicator works the same.


[b]Key Features[/b]

[list]
[*] [b]Four Pivot Methods[/b] -- Classic, Fibonacci, Woodie, Camarilla. Pick the one that matches your style: wider levels for breakouts, tighter Camarilla levels for fades.
[*] [b]Pivot + 6 Levels[/b] -- Central pivot plus R1/R2/R3 above and S1/S2/S3 below. Each level can be toggled independently to keep the chart clean.
[*] [b]Auto-Reset Each Session[/b] -- Lines are drawn fresh at the start of every new trading day from the previous day's HLC. Default view shows only today's levels for a clean chart; raise the history limit (up to 50 sessions) when you want to study past days.
[*] [b]Live Right-Edge Labels[/b] -- Every visible level carries a price tag that tracks the latest bar so the level name and exact price stay visible at the edge of the chart.
[*] [b]Configurable Visuals[/b] -- Choose line style (solid, dashed, dotted), width for pivot vs. S/R, and toggle each level. Pivot defaults to thicker than S/R for emphasis.
[*] [b]One-Shot Alerts[/b] -- Pivot cross (bullish or bearish), R2 reached, S2 reached. Each alert latches per session, so you get one clean signal per direction per day -- no spam from re-crosses.
[*] [b]No Repainting[/b] -- Yesterday's HLC is fetched with the canonical lookahead-on + bar-offset pattern. Levels stay constant throughout the session and never reference future data.
[/list]


[b]How It Works[/b]

At the start of each trading day, the indicator pulls the previous completed daily bar's high, low, and close from the chart's symbol via [icode]request.security[/icode]. Those three numbers feed the chosen method's formula to produce the pivot and the six S/R levels. The levels are drawn as horizontal lines with the pivot rendered thicker by default, and a price-tag label is placed at the right edge of each visible line.

As new intraday bars arrive, the indicator extends the right edge of today's lines forward so they always reach the latest bar. When a new trading day begins, today's lines freeze at their final right-edge position and a new set of lines is created. Past sessions remain visible up to the [b]Max Sessions to Keep[/b] limit, then are deleted automatically to stay within TradingView's drawing budget.

Three alert conditions watch for the most actionable level interactions. The first close that crosses the central pivot in either direction fires the pivot-cross alert (bullish above, bearish below). The first close at or above R2 fires the R2-reached alert; the first close at or below S2 fires the S2-reached alert. Each alert latches when it fires and resets only at the start of the next day, so you cannot get a flood of repeat triggers from price oscillating around a level.

[image]https://www.tradingview.com/x/zf45aCYl/[/image]
[i]Classic pivots on a 15-minute chart: yellow central pivot with three red resistance levels above and three green support levels below. Each level carries a live price tag at the right edge.[/i]


[b]Settings[/b]

[b]Pivot Method[/b] (default: Classic) selects the formula. Classic is the universal default and the widest typical-range method. Fibonacci uses 38.2%/61.8%/100% range offsets which sit between Classic and Camarilla in tightness. Woodie applies a close-weighted pivot that biases the central level toward the previous close; the S/R offsets are the same as Classic. Camarilla produces close-anchored levels with a 1.1× scaling factor and is significantly tighter than the others -- often used for mean-reversion fades inside the day's range.

[b]Max Sessions to Keep[/b] (default: 1) limits how many trading sessions of pivot lines stay on the chart. The default of 1 shows only today's pivots, which is the cleanest live-trading view -- consecutive days often have overlapping S/R prices and stacking three or more days of labels can clutter the chart. Raise to 5-10 to study how price has been respecting recent days' levels, or up to 50 for a long historical record.

The visual section toggles each level independently ([b]Show R1[/b] through [b]Show R3[/b], [b]Show S1[/b] through [b]Show S3[/b], [b]Show Price Labels[/b]). [b]Line Style[/b] (Solid / Dashed / Dotted) and the two width inputs ([b]Pivot Line Width[/b], [b]S/R Line Width[/b]) control appearance. The three alert toggles enable or disable the pivot-cross, R2-reach, and S2-reach alerts individually.


[b]Alerts[/b]

[list]
[*] [b]Bullish Pivot Cross[/b] -- Fires on the first close above the central pivot in a session. [i]"Intraday Pivot Points [DYNA]: Price crossed above the central pivot."[/i]
[*] [b]Bearish Pivot Cross[/b] -- Fires on the first close below the central pivot in a session. [i]"Intraday Pivot Points [DYNA]: Price crossed below the central pivot."[/i]
[*] [b]R2 Reached[/b] -- Fires on the first close at or above R2 in a session. [i]"Intraday Pivot Points [DYNA]: Price reached R2 -- extreme upside target."[/i]
[*] [b]S2 Reached[/b] -- Fires on the first close at or below S2 in a session. [i]"Intraday Pivot Points [DYNA]: Price reached S2 -- extreme downside target."[/i]
[/list]

To configure: open TradingView's Alerts panel, choose "Intraday Pivot Points [DYNA]" from the condition dropdown, pick the desired alert type, and select your notification channel.


[b]Best Practices[/b]

[list]
[*] Use intraday timeframes (1m, 5m, 15m, 1h). Pivot points are a daily-anchored intraday tool; on daily charts each bar shows its own pivots which is rarely useful.
[*] Match the method to the regime. On wide-range trending days Classic and Woodie give the most usable structure. On tight-range chop, Camarilla's narrower levels produce cleaner fade entries.
[*] Watch the pivot first, the S/R levels second. The single most important level on any session is whether price holds above or below the central pivot. R/S are secondary.
[*] Look for confluence. A pivot level that aligns with a moving average, VWAP, or a previous-day swing is much more reliable than the level on its own.
[*] R2/S2 reaches tend to be relatively uncommon on Classic pivots. When price does reach them, the move is already extended -- many traders treat that as a spot to study for a fade rather than a chase.
[*] Default [b]Max Sessions to Keep[/b] is 1 (only today's pivots) -- the cleanest view for live trading. Raise to 5-10 to back-study recent prior pivots, or up to 50 for long historical context.
[/list]


[b]Part of the DYNA Ecosystem[/b]

Intraday Pivot Points is a free indicator built with the same design standards as the DYNA premium suite. For complete trade management with automatic stop loss, break-even, trailing stops, and multi-target systems, explore the full DYNA indicator collection.


[b]Disclaimer[/b]

This indicator is a technical analysis and educational tool only -- it is not financial advice and makes no guarantee of any outcome. Past performance does not predict future results. Always do your own research and use proper position sizing and risk management.


[i]Created by Varun Nidhi · [url=https://varunnidhi.com]varunnidhi.com[/url]
A free DYNA indicator — self-contained, no repainting.[/i]

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// Intraday Pivot Points [DYNA]
// Auto-calculated daily pivot and S/R levels (Classic, Fibonacci, Woodie, Camarilla) drawn fresh at every session.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Intraday Pivot Points [DYNA]", shorttitle = "PP [DYNA]", overlay = true,
         max_lines_count = 500, max_labels_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 1: COLOR PALETTE
// ══════════════════════════════════════════════════════════════════════════════

color BULL_COLOR    = #26a69a
color BEAR_COLOR    = #ef5350
color NEUTRAL_COLOR = #787b86
color WARNING_COLOR = #ff9800

color PIVOT_COLOR = #ffeb3b   // Yellow — central pivot
color R_COLOR     = #ef5350   // Resistance levels (= BEAR_COLOR)
color S_COLOR     = #26a69a   // Support levels    (= BULL_COLOR)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: INPUTS
// ══════════════════════════════════════════════════════════════════════════════

string GRP_CORE  = "Core Settings"
string GRP_VIS   = "Visual"
string GRP_ALERT = "Alerts"

// --- Core Settings ---
string i_method      = input.string("Classic", "Pivot Method",
                                    options = ["Classic", "Fibonacci", "Woodie", "Camarilla"],
                                    group = GRP_CORE,
                                    tooltip = "Method used to derive the pivot and S/R levels from the previous day's high, low, and close.\n\n• Classic — original floor-trader pivots, P = (H+L+C)/3.\n• Fibonacci — pivot from HLC; S/R offsets at 38.2%, 61.8%, and 100% of yesterday's range.\n• Woodie — close-weighted pivot, P = (H+L+2C)/4; same R1/S1 logic as Classic.\n• Camarilla — close-anchored levels with 1.1× scaling; tighter than Classic, often used for mean-reversion.")
int    i_maxSessions = input.int(1, "Max Sessions to Keep", minval = 1, maxval = 50, group = GRP_CORE,
                                  tooltip = "How many trading sessions of pivot lines to keep on the chart. Default 1 shows only the current day's pivots — the cleanest view. Increase to 5-10 to study how recent days' pivots have been respected; raise toward the maximum (50) if you want a long historical record. Older sessions are deleted automatically to stay within TradingView's drawing budget.")

// --- Visual ---
bool   i_showR1     = input.bool(true, "Show R1", group = GRP_VIS, tooltip = "Show first resistance.")
bool   i_showR2     = input.bool(true, "Show R2", group = GRP_VIS, tooltip = "Show second resistance — typical day's-range top in trending sessions.")
bool   i_showR3     = input.bool(true, "Show R3", group = GRP_VIS, tooltip = "Show third resistance — extreme upside target.")
bool   i_showS1     = input.bool(true, "Show S1", group = GRP_VIS, tooltip = "Show first support.")
bool   i_showS2     = input.bool(true, "Show S2", group = GRP_VIS, tooltip = "Show second support — typical day's-range bottom in trending sessions.")
bool   i_showS3     = input.bool(true, "Show S3", group = GRP_VIS, tooltip = "Show third support — extreme downside target.")
string i_lineStyle  = input.string("Solid", "Line Style", options = ["Solid", "Dashed", "Dotted"],
                                    group = GRP_VIS, tooltip = "Style applied to all pivot lines.")
int    i_pivotWidth = input.int(2, "Pivot Line Width", minval = 1, maxval = 4, group = GRP_VIS,
                                 tooltip = "Line width for the central pivot. Defaults to thicker than the S/R levels for emphasis.")
int    i_levelWidth = input.int(1, "S/R Line Width",   minval = 1, maxval = 4, group = GRP_VIS,
                                 tooltip = "Line width for S1/S2/S3 and R1/R2/R3.")
bool   i_showLabels = input.bool(true, "Show Price Labels", group = GRP_VIS,
                                  tooltip = "Show level name and price tag at the right edge of the active session.")

// --- Alerts ---
bool i_alertPivotCross = input.bool(true, "Alert: Price Crosses Pivot", group = GRP_ALERT,
                                    tooltip = "Fire on the first close that crosses the central pivot in either direction during the session.")
bool i_alertR2         = input.bool(true, "Alert: Price Reaches R2",    group = GRP_ALERT,
                                    tooltip = "Fire on the first close at or above R2 during the session.")
bool i_alertS2         = input.bool(true, "Alert: Price Reaches S2",    group = GRP_ALERT,
                                    tooltip = "Fire on the first close at or below S2 during the session.")

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: CORE LOGIC
// ══════════════════════════════════════════════════════════════════════════════

// --- Previous day's HLC via daily timeframe request ---
// Use `[1]` offset on the daily series with `lookahead_on` to fetch the *previous*
// completed daily bar's HLC. This is the canonical non-repainting pattern: the
// `[1]` ensures we never see the still-forming current daily bar, and the
// returned values stay constant throughout today's intraday session.
[prevH, prevL, prevC] = request.security(syminfo.tickerid, "D", [high[1], low[1], close[1]],
                                          lookahead = barmerge.lookahead_on)

// --- Calculate the level set from yesterday's HLC ---
// Returns a tuple (pivot, R1, R2, R3, S1, S2, S3). All four methods produce the
// same set shape so the rest of the indicator can be method-agnostic.
calcLevels(string method, float h, float l, float c) =>
    float p   = na
    float r1  = na
    float r2  = na
    float r3  = na
    float s1  = na
    float s2  = na
    float s3  = na
    float rng = h - l
    if method == "Classic"
        p  := (h + l + c) / 3.0
        r1 := 2.0 * p - l
        s1 := 2.0 * p - h
        r2 := p + rng
        s2 := p - rng
        r3 := h + 2.0 * (p - l)
        s3 := l - 2.0 * (h - p)
    else if method == "Fibonacci"
        p  := (h + l + c) / 3.0
        r1 := p + 0.382 * rng
        r2 := p + 0.618 * rng
        r3 := p + 1.000 * rng
        s1 := p - 0.382 * rng
        s2 := p - 0.618 * rng
        s3 := p - 1.000 * rng
    else if method == "Woodie"
        p  := (h + l + 2.0 * c) / 4.0
        r1 := 2.0 * p - l
        s1 := 2.0 * p - h
        r2 := p + rng
        s2 := p - rng
        r3 := h + 2.0 * (p - l)
        s3 := l - 2.0 * (h - p)
    else
        // Camarilla — close-anchored S/R; pivot kept as Classic for reference
        p  := (h + l + c) / 3.0
        r1 := c + 1.1 * rng / 12.0
        r2 := c + 1.1 * rng / 6.0
        r3 := c + 1.1 * rng / 4.0
        s1 := c - 1.1 * rng / 12.0
        s2 := c - 1.1 * rng / 6.0
        s3 := c - 1.1 * rng / 4.0
    [p, r1, r2, r3, s1, s2, s3]

[pivot, r1, r2, r3, s1, s2, s3] = calcLevels(i_method, prevH, prevL, prevC)

// --- Daily session boundary ---
// `time("D")` returns the daily anchor for every bar; it changes on the first
// intraday bar of every new trading day. Robust whether or not the chart shows
// off-hours bars (see memory note pine_session_detection).
bool newDay = ta.change(time("D")) != 0 and not na(pivot)

// --- Line style selection ---
lineStyleVal() =>
    switch i_lineStyle
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        =>          line.style_solid

// --- Drawing handles per session ---
type PivotSet
    line  lP    = na
    line  lR1   = na
    line  lR2   = na
    line  lR3   = na
    line  lS1   = na
    line  lS2   = na
    line  lS3   = na
    label labP  = na
    label labR1 = na
    label labR2 = na
    label labR3 = na
    label labS1 = na
    label labS2 = na
    label labS3 = na

deletePivotSet(PivotSet ps) =>
    line.delete(ps.lP)
    line.delete(ps.lR1)
    line.delete(ps.lR2)
    line.delete(ps.lR3)
    line.delete(ps.lS1)
    line.delete(ps.lS2)
    line.delete(ps.lS3)
    label.delete(ps.labP)
    label.delete(ps.labR1)
    label.delete(ps.labR2)
    label.delete(ps.labR3)
    label.delete(ps.labS1)
    label.delete(ps.labS2)
    label.delete(ps.labS3)

extendPivotSet(PivotSet ps, int x) =>
    if not na(ps.lP)
        line.set_x2(ps.lP, x)
    if not na(ps.lR1)
        line.set_x2(ps.lR1, x)
    if not na(ps.lR2)
        line.set_x2(ps.lR2, x)
    if not na(ps.lR3)
        line.set_x2(ps.lR3, x)
    if not na(ps.lS1)
        line.set_x2(ps.lS1, x)
    if not na(ps.lS2)
        line.set_x2(ps.lS2, x)
    if not na(ps.lS3)
        line.set_x2(ps.lS3, x)
    if not na(ps.labP)
        label.set_x(ps.labP, x)
    if not na(ps.labR1)
        label.set_x(ps.labR1, x)
    if not na(ps.labR2)
        label.set_x(ps.labR2, x)
    if not na(ps.labR3)
        label.set_x(ps.labR3, x)
    if not na(ps.labS1)
        label.set_x(ps.labS1, x)
    if not na(ps.labS2)
        label.set_x(ps.labS2, x)
    if not na(ps.labS3)
        label.set_x(ps.labS3, x)

var array<PivotSet> sessions = array.new<PivotSet>()
var PivotSet        active   = na

// --- One-shot alert latches (reset each session) ---
var bool pivotCrossedToday = false
var bool r2HitToday        = false
var bool s2HitToday        = false

// --- Per-bar signal flags ---
bool bullPivotCross = false
bool bearPivotCross = false
bool r2Reached      = false
bool s2Reached      = false

// --- Bar-driven state machine (gated on confirmed bars only) ---
if barstate.isconfirmed
    if newDay
        // Start a fresh pivot set; the previous day's lines stop extending.
        active := PivotSet.new()
        style  = lineStyleVal()
        active.lP := line.new(bar_index, pivot, bar_index, pivot,
                              color = PIVOT_COLOR, style = style, width = i_pivotWidth)
        if i_showR1
            active.lR1 := line.new(bar_index, r1, bar_index, r1,
                                   color = R_COLOR, style = style, width = i_levelWidth)
        if i_showR2
            active.lR2 := line.new(bar_index, r2, bar_index, r2,
                                   color = R_COLOR, style = style, width = i_levelWidth)
        if i_showR3
            active.lR3 := line.new(bar_index, r3, bar_index, r3,
                                   color = R_COLOR, style = style, width = i_levelWidth)
        if i_showS1
            active.lS1 := line.new(bar_index, s1, bar_index, s1,
                                   color = S_COLOR, style = style, width = i_levelWidth)
        if i_showS2
            active.lS2 := line.new(bar_index, s2, bar_index, s2,
                                   color = S_COLOR, style = style, width = i_levelWidth)
        if i_showS3
            active.lS3 := line.new(bar_index, s3, bar_index, s3,
                                   color = S_COLOR, style = style, width = i_levelWidth)
        if i_showLabels
            active.labP := label.new(bar_index, pivot, "P  " + str.tostring(pivot, format.mintick),
                                     style = label.style_label_left, color = color.new(PIVOT_COLOR, 25),
                                     textcolor = color.black, size = size.small)
            if i_showR1
                active.labR1 := label.new(bar_index, r1, "R1 " + str.tostring(r1, format.mintick),
                                          style = label.style_label_left, color = color.new(R_COLOR, 25),
                                          textcolor = color.white, size = size.small)
            if i_showR2
                active.labR2 := label.new(bar_index, r2, "R2 " + str.tostring(r2, format.mintick),
                                          style = label.style_label_left, color = color.new(R_COLOR, 25),
                                          textcolor = color.white, size = size.small)
            if i_showR3
                active.labR3 := label.new(bar_index, r3, "R3 " + str.tostring(r3, format.mintick),
                                          style = label.style_label_left, color = color.new(R_COLOR, 25),
                                          textcolor = color.white, size = size.small)
            if i_showS1
                active.labS1 := label.new(bar_index, s1, "S1 " + str.tostring(s1, format.mintick),
                                          style = label.style_label_left, color = color.new(S_COLOR, 25),
                                          textcolor = color.white, size = size.small)
            if i_showS2
                active.labS2 := label.new(bar_index, s2, "S2 " + str.tostring(s2, format.mintick),
                                          style = label.style_label_left, color = color.new(S_COLOR, 25),
                                          textcolor = color.white, size = size.small)
            if i_showS3
                active.labS3 := label.new(bar_index, s3, "S3 " + str.tostring(s3, format.mintick),
                                          style = label.style_label_left, color = color.new(S_COLOR, 25),
                                          textcolor = color.white, size = size.small)

        array.push(sessions, active)
        while array.size(sessions) > i_maxSessions
            PivotSet old = array.shift(sessions)
            deletePivotSet(old)

        pivotCrossedToday := false
        r2HitToday        := false
        s2HitToday        := false
    else if not na(active)
        // Mid-session: extend the active session's lines and labels rightward.
        extendPivotSet(active, bar_index)

    // --- Crossover / extreme-level detection (one-shot per session) ---
    // Skip the very first bar of a new day so we compare close vs close[1] only
    // when both reference the same pivot value.
    if not na(pivot) and not newDay
        if not pivotCrossedToday and not na(close[1])
            if close[1] <= pivot and close > pivot
                pivotCrossedToday := true
                bullPivotCross    := true
            else if close[1] >= pivot and close < pivot
                pivotCrossedToday := true
                bearPivotCross    := true
        if not r2HitToday and not na(r2) and close >= r2
            r2HitToday := true
            r2Reached  := true
        if not s2HitToday and not na(s2) and close <= s2
            s2HitToday := true
            s2Reached  := true

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: VISUAL LAYER
// ══════════════════════════════════════════════════════════════════════════════

// All visual elements (pivot, S1-S3, R1-R3 lines + price-tag labels) are
// managed via the PivotSet handles in Section 3. No additional plot calls
// are required for this overlay indicator.

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(bullPivotCross and i_alertPivotCross, title = "Bullish Pivot Cross",
    message = "Intraday Pivot Points [DYNA]: Price crossed above the central pivot.")
alertcondition(bearPivotCross and i_alertPivotCross, title = "Bearish Pivot Cross",
    message = "Intraday Pivot Points [DYNA]: Price crossed below the central pivot.")
alertcondition(r2Reached and i_alertR2, title = "R2 Reached",
    message = "Intraday Pivot Points [DYNA]: Price reached R2 — extreme upside target.")
alertcondition(s2Reached and i_alertS2, title = "S2 Reached",
    message = "Intraday Pivot Points [DYNA]: Price reached S2 — extreme downside target.")
````
