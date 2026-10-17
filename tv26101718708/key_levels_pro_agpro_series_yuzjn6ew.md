# Key Levels Pro [AGPro Series]

- url: https://www.tradingview.com/script/Yuzjn6EW-Key-Levels-Pro-AGPro-Series/
- type: indicator
- pine_id: PUB;15f7cb9d375e4940b82309aada5ca7c0
- version: 3.0

## Description

Key Levels Pro [AGPro Series]

🔑 Overview

Key Levels Pro is a comprehensive, non-repainting level tracker that consolidates every institutionally significant price reference into one clean overlay. Previous day, week, and month highs/lows (PDH, PDL, PWH, PWL, PMH, PML) are plotted alongside Asian, London, and New York session highs and lows. Every level is actively monitored — touch count, break count, and respect rate update in real time, giving you a live quality score for each price zone.

Most level scripts stop at drawing lines. Key Levels Pro goes further: lines automatically thicken on repeated touches, switch to dashed style when broken, and fade to muted color to signal invalidation. Zone rectangles extend back to the formation bar of each level, making historical respect visible at a glance. An ATR-aware label collision system keeps the chart readable on every timeframe, and same-price levels are intelligently deduplicated so you never see four overlapping labels at the same price.

───────────────────────────────────────────────────────

📐 Unique Edge

Unlike generic pivot or S/R scripts, Key Levels Pro tracks the behavioral quality of each level — not just its existence. A level that has been tested five times without breaking carries a different weight than a fresh, untested one. Key Levels Pro surfaces that difference automatically through line width, style, and panel data.

What makes it distinct:

🔹 Complete previous-period coverage (PDH/PDL, PWH/PWL, PMH/PML) in one overlay, without redundant current-period duplicates.
🔹 Live session tracking for Asian, London, and New York simultaneously, with automatic hiding on Daily and higher timeframes.
🔹 Per-level touch count, break count, and respect rate computed from actual historical price interaction.
🔹 Dynamic line thickening on repeated touches (width 1 → 2 → 3).
🔹 Auto-broken state with dashed style + muted color — no distracting flags or banners.
🔹 Historical zone boxes extending back to the formation bar of each level.
🔹 ATR-aware label collision resolution that stacks overlapping labels vertically.
🔹 Price-based deduplication: when two levels share the same price, the higher-priority one wins (Monthly > Weekly > Daily > Session).
🔹 ATR-normalized proximity to the nearest level above and below the current price.

───────────────────────────────────────────────────────

🔬 Methodology

Previous-period levels are pulled from the daily, weekly, and monthly timeframes using request.security() with lookahead enabled for the completed-period values. This approach is standard, transparent, and non-repainting — historical data does not change.

Session levels are tracked bar by bar using customizable session time inputs. Each session resets at its start time and tracks the running high and low until the session closes. The Asian, London, and New York sessions can each be configured independently.

Touch detection uses an ATR-based tolerance band (default 10% of ATR). When price closes within that tolerance of a level, the touch counter increments. A break is registered when price closes on the opposite side of a level compared to the prior bar. Respect rate is calculated as touches / (touches + breaks) × 100.

Line width scales with touch count: 1 touch = width 1, 2–4 touches = width 2, 5+ touches = width 3. Broken levels switch to dashed style and a muted color.

The label collision system operates in three stages: first, all enabled levels are collected into a sorted array; second, same-price levels are deduplicated based on priority (Monthly highest, Session lowest); third, an upward sweep enforces minimum vertical spacing using a blend of ATR and chart-range heuristics, ensuring labels never overlap regardless of market volatility.

───────────────────────────────────────────────────────

📊 Signals & States

This script is a visualization and data tool — it does not generate buy or sell signals.

Level states are communicated visually:

🔹 Active (solid line, full color): level has not been broken.
🔹 Touched (thicker line, 2–3px): level has been tested one or more times.
🔹 Broken (dashed line, muted slate color): level has been decisively closed through.

Info panel states:

🔹 Session: active market session (Asian / London / New York / Off-Hours / N/A on Daily+).
🔹 Near Above / Near Below: price of the closest active level on each side of the current close.
🔹 Dist Above / Below ATR: distance expressed as a multiple of ATR(14).
🔹 Touch and respect rate data for PDH, PDL, PWH, PWL.

───────────────────────────────────────────────────────

⚙️ Key Inputs

Level Groups: Toggle previous day, week, month, and session levels independently.
Session Times: Fully customizable start/end times for Asian, London, and New York sessions in exchange timezone.
Zone Style: Enable/disable S/R zones and adjust zone transparency.
Lines & Labels: Set line extension length, toggle labels, choose label density (All / Reduced / Minimal), set font size, and enable or disable same-price deduplication.
Info Panel: Toggle panel, set location (six positions), and choose theme (Dark / Light).
ATR Settings: Set ATR period and touch tolerance as an ATR multiple (0.02 to 0.50).

───────────────────────────────────────────────────────

📖 How to Use

1. Add the script to a chart — all major levels appear immediately.
2. Adjust session times if trading non-crypto markets.
3. Watch line thickness: thicker = more tested = stronger historical reaction zone.
4. Dashed + muted color = broken. Treat broken levels as potential new S/R from the opposite side (role reversal).
5. Use the panel's Near Above and Near Below fields to gauge proximity before entry or exit decisions.
6. Use "Reduced" density (default) for cleaner charts, or switch to "All" when you need session context.
7. Works on all asset classes: crypto, forex, equities, indices, commodities.

Recommended timeframes: 15m–4H for session levels; 1H–1D for previous-period levels.

───────────────────────────────────────────────────────

⚠️ Limitations & Transparency

🔹 Session tracking is session-relative and resets each new session.
🔹 Touch tolerance is an ATR-based heuristic and may need adjustment on extremely low-volatility instruments.
🔹 All data is historical. Touch count and respect rate describe past price behavior, not future outcomes.
🔹 This script is not a trading strategy, does not issue trade signals, and cannot predict market direction.
🔹 On exotic or illiquid instruments with large gaps, formation-bar zone boxes may appear truncated if the level formed outside the chart's visible range.

───────────────────────────────────────────────────────

🛡️ Risk Disclosure

This script is provided for informational and educational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All trading involves risk. Past level behavior does not guarantee future results. Always use proper risk management and test any approach in a demo environment before committing real capital.

## Source Code

````pine
// -------------------------------------------------
// Key Levels Pro [AGPro Series]
//
// Author  : AGProLabs | AGPro Series
// Version : 2.1
//
// Tracks every key institutional price level on a single overlay: previous
// day, week, and month highs and lows (PDH, PDL, PWH, PWL, PMH, PML) plus
// active Asian, London, and New York session highs and lows. Each level is
// monitored live - touches thicken the line, breaks dash it and fade the
// color, while an ATR relevance corridor keeps distant levels from
// compressing the chart. Filled level badges identify every visible zone. A
// per-tier Level Hold engine measures, on this chart and timeframe, how
// often confirmed touches of daily, weekly, and monthly levels actually
// rejected one full ATR away before price closed through the level. The
// nearest level is scored 0-100 (Reaction Score) from tier weight, its
// tier hold rate, freshness, and level confluence, and a focus card plus
// a clear next-action line turn the level map into a decision tool.
// -------------------------------------------------

//@version=6
indicator("Key Levels Pro [AGPro Series]",
     shorttitle       = "AG Pro KLP",
     overlay          = true,
     max_lines_count  = 100,
     max_labels_count = 100,
     max_boxes_count  = 100)

// ==================================================
// INPUTS
// ==================================================

grp_levels  = "Level Groups"
showDaily   = input.bool(true, "Show Previous Day (PDH/PDL)",     group = grp_levels, tooltip = "Previous day high and low.")
showWeekly  = input.bool(true, "Show Previous Week (PWH/PWL)",    group = grp_levels, tooltip = "Previous week high and low.")
showMonthly = input.bool(true, "Show Previous Month (PMH/PML)",   group = grp_levels, tooltip = "Previous month high and low.")
showSession = input.bool(true, "Show Session Levels",             group = grp_levels, tooltip = "Asian, London, and New York session highs and lows. Auto-hidden on Daily or higher timeframes.")

grp_sess    = "Session Times (Exchange Timezone)"
asianStart  = input.session("0000-0900", "Asian Session",    group = grp_sess, tooltip = "Asian session time range in exchange timezone.")
londonStart = input.session("0800-1700", "London Session",   group = grp_sess, tooltip = "London session time range in exchange timezone.")
nyStart     = input.session("1300-2200", "New York Session", group = grp_sess, tooltip = "New York session time range in exchange timezone.")

grp_zone  = "Zone Style"
showZones = input.bool(true, "Show S/R Zones",    group = grp_zone, tooltip = "Display a zone box around each key level, extending back to where the level was formed.")
zoneTrans = input.int(80,    "Zone Transparency", group = grp_zone, minval = 50, maxval = 95, tooltip = "Zone fill transparency. Higher = more transparent.")

grp_style     = "Lines & Labels"
lineLen       = input.int(60,           "Line Extension (bars)",    group = grp_style, minval = 10, maxval = 300, tooltip = "How far each level line extends to the right of current bar.")
showLabels    = input.bool(true,        "Show Level Labels",        group = grp_style, tooltip = "Show price labels on each level line.")
labelDensity  = input.string("Reduced", "Label Density",            group = grp_style, options = ["All", "Reduced", "Minimal"], tooltip = "All: every level. Reduced: omit session levels. Minimal: PDH/PDL/PWH/PWL only.")
labelSize     = input.string("Normal",  "Label Font Size",          group = grp_style, options = ["Tiny", "Small", "Normal", "Large"], tooltip = "Font size for every visible chart badge, including level and focus badges.")
dedupLevels   = input.bool(true,        "Deduplicate Same-Price Levels", group = grp_style, tooltip = "If two or more levels share the same price, keep only the higher-priority one. Priority: Monthly > Weekly > Daily > Session.")
showFocusCard = input.bool(true,        "Show Focus Level Card",    group = grp_style, tooltip = "Show a compact decision card on the nearest key level when price is within one ATR of it. The card reports the level, its Reaction Score, and its tier hold statistics.")

grp_panel  = "Info Panel"
showPanel  = input.bool(true,          "Show Info Panel",  group = grp_panel)
panelLoc   = input.string("Top Right", "Panel Location",   group = grp_panel, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], tooltip = "Panel position on chart.")
panelTheme = input.string("Dark",      "Panel Theme",      group = grp_panel, options = ["Dark", "Light"], tooltip = "Dark = AGPro dark. Light = white background.")
panelSize  = input.string("Normal",    "Panel Font Size",  group = grp_panel, options = ["Tiny", "Small", "Normal", "Large"], tooltip = "Font size for all panel rows. Default is Normal.")

grp_atr   = "ATR Settings"
atrLen    = input.int(14,     "ATR Period",            group = grp_atr, minval = 1, maxval = 50, tooltip = "Period for ATR used in touch tolerance, proximity display, hold tracking, and the visible-level relevance corridor.")
touchMult = input.float(0.10, "Touch Tolerance (ATR)", group = grp_atr, minval = 0.02, maxval = 0.50, step = 0.01, tooltip = "How close price must come to a level to register as a 'touch', as a multiple of ATR.")
maxVisibleATR = input.float(8.0, "Visible Level Distance (ATR)", group = grp_atr, minval = 1.0, maxval = 50.0, step = 0.5, tooltip = "Only levels within this ATR distance are drawn and ranked. This prevents very distant monthly or weekly levels from compressing the active chart view.")

// ==================================================
// COLOR PALETTE
// ==================================================
headerBg      = color.rgb(37,  99,  235)
headerText    = color.rgb(245, 247, 250)
panelBg       = color.rgb(15,  23,  42)
panelBorder   = color.rgb(51,  65,  85)
panelLabelCol = color.rgb(148, 163, 184)
panelValueCol = color.rgb(226, 232, 240)
bullColor     = color.rgb(34,  197, 166)
bearColor     = color.rgb(244, 114, 182)
neutralColor  = color.rgb(245, 189, 92)
accentColor   = color.rgb(129, 140, 248)

colDaily   = color.rgb(99,  179, 237)
colWeekly  = color.rgb(245, 189, 92)
colMonthly = color.rgb(167, 139, 250)
colSession = color.rgb(148, 163, 184)
colBroken  = color.rgb(100, 116, 139)

// ==================================================
// HELPERS
// ==================================================
f_toSize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        =>         size.normal

f_panelPos(loc) =>
    switch loc
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        =>                 position.top_right

f_priceStr(p) =>
    str.tostring(p, format.mintick)

f_lineWidth(touches) =>
    touches >= 3 ? 3 : touches >= 1 ? 2 : 1

// Luminance-based readable text color for label backgrounds
f_text_on(bg) =>
    lum = 0.299 * color.r(bg) + 0.587 * color.g(bg) + 0.114 * color.b(bg)
    lum > 150 ? color.rgb(15, 23, 42) : color.rgb(245, 247, 250)

labelTextSize = f_toSize(labelSize)
panelTextSize = f_toSize(panelSize)

// Auto-hide session on D or higher
bool sessOK = timeframe.in_seconds() < timeframe.in_seconds("D")

// ==================================================
// PREVIOUS-PERIOD HIGHS / LOWS + FORMATION BAR
// ==================================================
pdHigh = request.security(syminfo.tickerid, "D", high[1], lookahead = barmerge.lookahead_on)
pdLow  = request.security(syminfo.tickerid, "D", low[1],  lookahead = barmerge.lookahead_on)
pwHigh = request.security(syminfo.tickerid, "W", high[1], lookahead = barmerge.lookahead_on)
pwLow  = request.security(syminfo.tickerid, "W", low[1],  lookahead = barmerge.lookahead_on)
pmHigh = request.security(syminfo.tickerid, "M", high[1], lookahead = barmerge.lookahead_on)
pmLow  = request.security(syminfo.tickerid, "M", low[1],  lookahead = barmerge.lookahead_on)

// Formation-bar tracking: we record where the CURRENT period's running extreme occurred,
// and at period rollover, transfer it to the PREV-period variable.
var int pdh_bar = na
var int pdl_bar = na
var int pwh_bar = na
var int pwl_bar = na
var int pmh_bar = na
var int pml_bar = na

var float curDayHigh  = na
var float curDayLow   = na
var int   curDayHBar  = na
var int   curDayLBar  = na
var float curWeekHigh = na
var float curWeekLow  = na
var int   curWeekHBar = na
var int   curWeekLBar = na
var float curMonHigh  = na
var float curMonLow   = na
var int   curMonHBar  = na
var int   curMonLBar  = na

bool newDay  = timeframe.change("D")
bool newWeek = timeframe.change("W")
bool newMon  = timeframe.change("M")

if newDay
    pdh_bar := curDayHBar
    pdl_bar := curDayLBar
    curDayHigh := high
    curDayLow  := low
    curDayHBar := bar_index
    curDayLBar := bar_index
else
    if na(curDayHigh) or high > curDayHigh
        curDayHigh := high
        curDayHBar := bar_index
    if na(curDayLow) or low < curDayLow
        curDayLow := low
        curDayLBar := bar_index

if newWeek
    pwh_bar := curWeekHBar
    pwl_bar := curWeekLBar
    curWeekHigh := high
    curWeekLow  := low
    curWeekHBar := bar_index
    curWeekLBar := bar_index
else
    if na(curWeekHigh) or high > curWeekHigh
        curWeekHigh := high
        curWeekHBar := bar_index
    if na(curWeekLow) or low < curWeekLow
        curWeekLow := low
        curWeekLBar := bar_index

if newMon
    pmh_bar := curMonHBar
    pml_bar := curMonLBar
    curMonHigh := high
    curMonLow  := low
    curMonHBar := bar_index
    curMonLBar := bar_index
else
    if na(curMonHigh) or high > curMonHigh
        curMonHigh := high
        curMonHBar := bar_index
    if na(curMonLow) or low < curMonLow
        curMonLow := low
        curMonLBar := bar_index

// ==================================================
// SESSION HIGH / LOW
// ==================================================
inAsian  = sessOK and not na(time(timeframe.period, asianStart))
inLondon = sessOK and not na(time(timeframe.period, londonStart))
inNY     = sessOK and not na(time(timeframe.period, nyStart))

var float asH = na
var float asL = na
var float loH = na
var float loL = na
var float nyH = na
var float nyL = na
var int asHBar = na
var int asLBar = na
var int loHBar = na
var int loLBar = na
var int nyHBar = na
var int nyLBar = na

bool newAsian  = inAsian  and not inAsian[1]
bool newLondon = inLondon and not inLondon[1]
bool newNY     = inNY     and not inNY[1]

if newAsian
    asH := high
    asL := low
    asHBar := bar_index
    asLBar := bar_index
else if inAsian
    if high > asH
        asH := high
        asHBar := bar_index
    if low < asL
        asL := low
        asLBar := bar_index

if newLondon
    loH := high
    loL := low
    loHBar := bar_index
    loLBar := bar_index
else if inLondon
    if high > loH
        loH := high
        loHBar := bar_index
    if low < loL
        loL := low
        loLBar := bar_index

if newNY
    nyH := high
    nyL := low
    nyHBar := bar_index
    nyLBar := bar_index
else if inNY
    if high > nyH
        nyH := high
        nyHBar := bar_index
    if low < nyL
        nyL := low
        nyLBar := bar_index

// ==================================================
// TOUCH / BREAK LOGIC (event-based)
// A touch now counts ONCE per visit: it registers only when price
// ENTERS the tolerance band around a level, not on every bar spent
// inside it. This keeps touch counts and hold sample sizes honest.
// ==================================================
atrVal = ta.atr(atrLen)
tol    = atrVal * touchMult

f_inBand(lvl) =>
    not na(lvl) and math.abs(close - lvl) <= tol

f_break(lvl) =>
    bull = not na(lvl) and close > lvl and close[1] <= lvl
    bear = not na(lvl) and close < lvl and close[1] >= lvl
    bull or bear

pdhIn = f_inBand(pdHigh)
pdlIn = f_inBand(pdLow)
pwhIn = f_inBand(pwHigh)
pwlIn = f_inBand(pwLow)
pmhIn = f_inBand(pmHigh)
pmlIn = f_inBand(pmLow)
ashIn = f_inBand(asH)
aslIn = f_inBand(asL)
lohIn = f_inBand(loH)
lolIn = f_inBand(loL)
nyhIn = f_inBand(nyH)
nylIn = f_inBand(nyL)

confirmedBar = barstate.isconfirmed

pdhEv = confirmedBar and pdhIn and not pdhIn[1]
pdlEv = confirmedBar and pdlIn and not pdlIn[1]
pwhEv = confirmedBar and pwhIn and not pwhIn[1]
pwlEv = confirmedBar and pwlIn and not pwlIn[1]
pmhEv = confirmedBar and pmhIn and not pmhIn[1]
pmlEv = confirmedBar and pmlIn and not pmlIn[1]
ashEv = confirmedBar and ashIn and not ashIn[1]
aslEv = confirmedBar and aslIn and not aslIn[1]
lohEv = confirmedBar and lohIn and not lohIn[1]
lolEv = confirmedBar and lolIn and not lolIn[1]
nyhEv = confirmedBar and nyhIn and not nyhIn[1]
nylEv = confirmedBar and nylIn and not nylIn[1]

pdhBrkNow = confirmedBar and f_break(pdHigh)
pdlBrkNow = confirmedBar and f_break(pdLow)
pwhBrkNow = confirmedBar and f_break(pwHigh)
pwlBrkNow = confirmedBar and f_break(pwLow)
pmhBrkNow = confirmedBar and f_break(pmHigh)
pmlBrkNow = confirmedBar and f_break(pmLow)
ashBrkNow = confirmedBar and f_break(asH)
aslBrkNow = confirmedBar and f_break(asL)
lohBrkNow = confirmedBar and f_break(loH)
lolBrkNow = confirmedBar and f_break(loL)
nyhBrkNow = confirmedBar and f_break(nyH)
nylBrkNow = confirmedBar and f_break(nyL)

var int  pdh_touch  = 0
var bool pdh_broken = false
var int  pdl_touch  = 0
var bool pdl_broken = false
var int  pwh_touch  = 0
var bool pwh_broken = false
var int  pwl_touch  = 0
var bool pwl_broken = false
var int  pmh_touch  = 0
var bool pmh_broken = false
var int  pml_touch  = 0
var bool pml_broken = false
var int  ash_touch  = 0
var bool ash_broken = false
var int  asl_touch  = 0
var bool asl_broken = false
var int  loh_touch  = 0
var bool loh_broken = false
var int  lol_touch  = 0
var bool lol_broken = false
var int  nyh_touch  = 0
var bool nyh_broken = false
var int  nyl_touch  = 0
var bool nyl_broken = false

if newDay
    pdh_touch  := 0
    pdh_broken := false
    pdl_touch  := 0
    pdl_broken := false
    ash_touch  := 0
    ash_broken := false
    asl_touch  := 0
    asl_broken := false
    loh_touch  := 0
    loh_broken := false
    lol_touch  := 0
    lol_broken := false
    nyh_touch  := 0
    nyh_broken := false
    nyl_touch  := 0
    nyl_broken := false

if newWeek
    pwh_touch  := 0
    pwh_broken := false
    pwl_touch  := 0
    pwl_broken := false

if newMon
    pmh_touch  := 0
    pmh_broken := false
    pml_touch  := 0
    pml_broken := false

if pdhEv
    pdh_touch += 1
if pdlEv
    pdl_touch += 1
if pwhEv
    pwh_touch += 1
if pwlEv
    pwl_touch += 1
if pmhEv
    pmh_touch += 1
if pmlEv
    pml_touch += 1
if ashEv
    ash_touch += 1
if aslEv
    asl_touch += 1
if lohEv
    loh_touch += 1
if lolEv
    lol_touch += 1
if nyhEv
    nyh_touch += 1
if nylEv
    nyl_touch += 1

if pdhBrkNow
    pdh_broken := true
if pdlBrkNow
    pdl_broken := true
if pwhBrkNow
    pwh_broken := true
if pwlBrkNow
    pwl_broken := true
if pmhBrkNow
    pmh_broken := true
if pmlBrkNow
    pml_broken := true
if ashBrkNow
    ash_broken := true
if aslBrkNow
    asl_broken := true
if lohBrkNow
    loh_broken := true
if lolBrkNow
    lol_broken := true
if nyhBrkNow
    nyh_broken := true
if nylBrkNow
    nyl_broken := true

// ==================================================
// LEVEL HOLD ENGINE (per tier, cumulative, non-repaint)
// One independent tracker per tier (Daily, Weekly, Monthly).
// A tracking episode opens only on a CONFIRMED bar when price newly
// enters the tolerance band of that tier's high or low. The episode
// resolves as HELD when price rejects one full ATR away from the
// level, and as BROKEN when price closes through the level by the
// touch tolerance, or when 30 bars pass without resolution. Level,
// ATR, and tolerance are frozen at registration and resolution is
// evaluated on confirmed bars only, so the statistic never repaints.
// ==================================================
f_holdTracker(lvlA, lvlB, atrV, tolV) =>
    inA = not na(lvlA) and math.abs(close - lvlA) <= tolV
    inB = not na(lvlB) and math.abs(close - lvlB) <= tolV
    evA = inA and not inA[1]
    evB = inB and not inB[1]
    var bool  trkOn  = false
    var int   trkDir = 0
    var float trkLvl = na
    var float trkAtr = na
    var float trkTol = na
    var int   trkSt  = na
    var int   wins   = 0
    var int   total  = 0
    if trkOn and barstate.isconfirmed
        bool held = trkDir == -1 ? low <= trkLvl - trkAtr : high >= trkLvl + trkAtr
        bool brk  = trkDir == -1 ? close > trkLvl + trkTol : close < trkLvl - trkTol
        bool tmo  = not na(trkSt) and bar_index - trkSt >= 30
        if brk or tmo
            total += 1
            trkOn := false
        else if held
            total += 1
            wins  += 1
            trkOn := false
    if barstate.isconfirmed and not trkOn and not na(atrV) and atrV > 0 and (evA or evB)
        float pick = na
        if evA and evB
            pick := math.abs(close - lvlA) <= math.abs(close - lvlB) ? lvlA : lvlB
        else
            pick := evA ? lvlA : lvlB
        trkOn  := true
        trkDir := close < pick ? -1 : 1
        trkLvl := pick
        trkAtr := atrV
        trkTol := tolV
        trkSt  := bar_index
    [wins, total]

[dHoldW, dHoldN] = f_holdTracker(pdHigh, pdLow, atrVal, tol)
[wHoldW, wHoldN] = f_holdTracker(pwHigh, pwLow, atrVal, tol)
[mHoldW, mHoldN] = f_holdTracker(pmHigh, pmLow, atrVal, tol)

// ==================================================
// LEVEL DEDUPLICATION
// ==================================================
// Levels within this price difference are treated as the same reference.
dedupSpace   = atrVal * 0.08

// ==================================================
// LEVEL VISIBILITY (group toggles x density)
// Density semantics: All = every level. Reduced = no session levels.
// Minimal = previous day and previous week only.
// The focus engine, panel proximity, and drawn levels all use the
// SAME visibility set, so what the panel reasons about is always
// exactly what is on the chart.
// ==================================================
inclDaily   = showDaily
inclWeekly  = showWeekly
inclMonthly = showMonthly and labelDensity != "Minimal"
inclSession = showSession and sessOK and labelDensity == "All"

// ==================================================
// FOCUS ENGINE - nearest visible level + Reaction Score
// ==================================================
candP = array.new<float>()
candL = array.new<string>()
candT = array.new<int>()
candB = array.new<bool>()

f_cand(p, l, t, b, atrV, maxDist) =>
    if not na(p) and atrV > 0 and math.abs(close - p) / atrV <= maxDist
        array.push(candP, p)
        array.push(candL, l)
        array.push(candT, t)
        array.push(candB, b)

if inclDaily
    f_cand(pdHigh, "PDH", 2, pdh_broken, atrVal, maxVisibleATR)
    f_cand(pdLow,  "PDL", 2, pdl_broken, atrVal, maxVisibleATR)
if inclWeekly
    f_cand(pwHigh, "PWH", 3, pwh_broken, atrVal, maxVisibleATR)
    f_cand(pwLow,  "PWL", 3, pwl_broken, atrVal, maxVisibleATR)
if inclMonthly
    f_cand(pmHigh, "PMH", 4, pmh_broken, atrVal, maxVisibleATR)
    f_cand(pmLow,  "PML", 4, pml_broken, atrVal, maxVisibleATR)
if inclSession
    f_cand(asH, "AS-H", 1, ash_broken, atrVal, maxVisibleATR)
    f_cand(asL, "AS-L", 1, asl_broken, atrVal, maxVisibleATR)
    f_cand(loH, "LO-H", 1, loh_broken, atrVal, maxVisibleATR)
    f_cand(loL, "LO-L", 1, lol_broken, atrVal, maxVisibleATR)
    f_cand(nyH, "NY-H", 1, nyh_broken, atrVal, maxVisibleATR)
    f_cand(nyL, "NY-L", 1, nyl_broken, atrVal, maxVisibleATR)

float  nearAbove   = na
float  nearBelow   = na
float  focusP      = na
string focusLbl    = "-"
int    focusT      = 0
bool   focusBroken = false
int    focusIdx    = -1
float  focusBest   = na

if array.size(candP) > 0
    for i = 0 to array.size(candP) - 1
        float p = array.get(candP, i)
        if not na(p)
            if p > close and (na(nearAbove) or p < nearAbove)
                nearAbove := p
            if p < close and (na(nearBelow) or p > nearBelow)
                nearBelow := p
            float d = math.abs(close - p)
            if na(focusBest) or d < focusBest
                focusBest := d
                focusIdx  := i

if focusIdx >= 0
    focusP      := array.get(candP, focusIdx)
    focusLbl    := array.get(candL, focusIdx)
    focusT      := array.get(candT, focusIdx)
    focusBroken := array.get(candB, focusIdx)

distAboveATR = not na(nearAbove) and atrVal > 0 ? math.round((nearAbove - close) / atrVal * 100) / 100 : na
distBelowATR = not na(nearBelow) and atrVal > 0 ? math.round((close - nearBelow) / atrVal * 100) / 100 : na
distFocusATR = focusIdx >= 0 and atrVal > 0 ? focusBest / atrVal : na
sessState    = inAsian ? "Asian" : inLondon ? "London" : inNY ? "New York" : sessOK ? "Off-Hours" : "N/A (Daily+)"

// Tier hold stats for the focus level
int tierW = 0
int tierN = 0
if focusT == 2
    tierW := dHoldW
    tierN := dHoldN
if focusT == 3
    tierW := wHoldW
    tierN := wHoldN
if focusT == 4
    tierW := mHoldW
    tierN := mHoldN

bool  focusGated = focusT >= 2 and tierN >= 8
float tierRate   = tierN > 0 ? 100.0 * tierW / tierN : na

// Reaction Score 0-100:
//   tier weight (Monthly 28 / Weekly 22 / Daily 16 / Session 10)
// + tier hold rate x 0.42 when the sample is sufficient (n >= 8),
//   otherwise a neutral 21 so an unproven level is never overstated
// + freshness (unbroken this period 20, already broken 6)
// + confluence (another visible level within 0.6 ATR adds 10)
float tierPts  = focusT == 4 ? 28.0 : focusT == 3 ? 22.0 : focusT == 2 ? 16.0 : focusT == 1 ? 10.0 : 0.0
float holdPts  = focusGated ? tierRate * 0.42 : 21.0
float freshPts = focusBroken ? 6.0 : 20.0

bool hasConfl = false
if focusIdx >= 0
    for i = 0 to array.size(candP) - 1
        if i != focusIdx
            float p = array.get(candP, i)
            if not na(p) and math.abs(p - focusP) <= atrVal * 0.6
                hasConfl := true
float conflPts = hasConfl ? 10.0 : 0.0

int reactScore = focusIdx >= 0 ? math.min(100, math.max(0, math.round(tierPts + holdPts + freshPts + conflPts))) : 0

// Next-action line (consistent with score and distance)
string actionTxt = "> wait - no key level near"
if focusIdx >= 0 and not na(distFocusATR)
    if focusBroken and distFocusATR <= 1.0
        actionTxt := "> " + focusLbl + " broken - retest watch"
    else if distFocusATR <= 0.25
        actionTxt := "> testing " + focusLbl + " - watch reaction"
    else if distFocusATR <= 1.0
        actionTxt := "> approaching " + focusLbl

// ==================================================
// ALERTS
// Alerts are attention markers, not trade instructions.
// ==================================================
prevTouchEv = pdhEv or pdlEv or pwhEv or pwlEv or pmhEv or pmlEv
prevBreakEv = pdhBrkNow or pdlBrkNow or pwhBrkNow or pwlBrkNow or pmhBrkNow or pmlBrkNow
strongNow   = focusIdx >= 0 and not na(distFocusATR) and distFocusATR <= 0.25 and focusGated and reactScore >= 70
strongEv    = confirmedBar and strongNow and not strongNow[1]

alertcondition(prevTouchEv, "Key Level Test",          "Price is testing a previous day, week, or month level.")
alertcondition(prevBreakEv, "Key Level Break",         "Price closed through a previous day, week, or month level.")
alertcondition(strongEv,    "High Quality Level Test", "Price is testing a key level with a high Reaction Score and a sufficient hold sample.")

// ==================================================
// DRAWING LIFECYCLE
// All drawings are created once per last-bar refresh and the previous
// set is deleted first, so objects never accumulate on realtime ticks.
// ==================================================
var array<line>  vLines  = array.new<line>()
var array<box>   vBoxes  = array.new<box>()
var array<label> vLabels = array.new<label>()

f_drawLevel(lvl, lbl, col, isBroken, touches, showLbl, zoneLeft) =>
    if not na(lvl)
        lw     = f_lineWidth(touches)
        lc     = isBroken ? colBroken : col
        lstyle = isBroken ? line.style_dashed : line.style_solid
        zoneRight = bar_index + lineLen

        if showZones and not na(zoneLeft)
            bx = box.new(zoneLeft, lvl + tol, zoneRight, lvl - tol,
                 bgcolor      = color.new(lc, zoneTrans),
                 border_color = color.new(lc, math.max(zoneTrans - 15, 0)),
                 border_width = 1)
            array.push(vBoxes, bx)

        ln = line.new(bar_index, lvl, zoneRight, lvl,
             color = lc, width = lw, style = lstyle)
        array.push(vLines, ln)

        if showLbl
            stateTxt = isBroken ? "BROKEN" : touches > 0 ? "TEST " + str.tostring(touches) : "FRESH"
            lblText  = lbl + " | " + f_priceStr(lvl) + " | " + stateTxt
            badgeX   = showZones and not na(zoneLeft) ? int(math.round((zoneLeft + zoneRight) * 0.5)) : zoneRight
            badgeSty = showZones and not na(zoneLeft) ? label.style_label_center : label.style_label_left
            lb = label.new(badgeX, lvl, lblText,
                 style     = badgeSty,
                 color     = lc,
                 textcolor = f_text_on(lc),
                 size      = labelTextSize,
                 textalign = text.align_center)
            array.push(vLabels, lb)

// ==================================================
// LEVEL REGISTRY
// 12 potential levels: 6 previous-period + 6 session.
// Priority (higher wins dedup): Monthly=4, Weekly=3, Daily=2, Session=1.
// ==================================================
lvl_price   = array.new<float>(12)
lvl_label   = array.new<string>(12)
lvl_color   = array.new<color>(12)
lvl_broken  = array.new<bool>(12)
lvl_touches = array.new<int>(12)
lvl_zbar    = array.new<int>(12)
lvl_enabled = array.new<bool>(12)
lvl_prio    = array.new<int>(12)

f_registerLevel(idx, price, lbl, col, isBroken, touches, zbar, prio) =>
    array.set(lvl_price,   idx, price)
    array.set(lvl_label,   idx, lbl)
    array.set(lvl_color,   idx, col)
    array.set(lvl_broken,  idx, isBroken)
    array.set(lvl_touches, idx, touches)
    array.set(lvl_zbar,    idx, zbar)
    array.set(lvl_prio,    idx, prio)

if barstate.islast
    // Clear previous drawing set
    if array.size(vLines) > 0
        for ln in vLines
            line.delete(ln)
        array.clear(vLines)
    if array.size(vBoxes) > 0
        for bx in vBoxes
            box.delete(bx)
        array.clear(vBoxes)
    if array.size(vLabels) > 0
        for lb in vLabels
            label.delete(lb)
        array.clear(vLabels)

    // Index order: 0=PDH 1=PDL 2=PWH 3=PWL 4=PMH 5=PML 6=AS-H 7=AS-L 8=LO-H 9=LO-L 10=NY-H 11=NY-L
    f_registerLevel(0,  pdHigh, "PDH",  colDaily,   pdh_broken, pdh_touch, pdh_bar, 2)
    f_registerLevel(1,  pdLow,  "PDL",  colDaily,   pdl_broken, pdl_touch, pdl_bar, 2)
    f_registerLevel(2,  pwHigh, "PWH",  colWeekly,  pwh_broken, pwh_touch, pwh_bar, 3)
    f_registerLevel(3,  pwLow,  "PWL",  colWeekly,  pwl_broken, pwl_touch, pwl_bar, 3)
    f_registerLevel(4,  pmHigh, "PMH",  colMonthly, pmh_broken, pmh_touch, pmh_bar, 4)
    f_registerLevel(5,  pmLow,  "PML",  colMonthly, pml_broken, pml_touch, pml_bar, 4)
    f_registerLevel(6,  asH,    "AS-H", colSession, ash_broken, ash_touch, asHBar,  1)
    f_registerLevel(7,  asL,    "AS-L", colSession, asl_broken, asl_touch, asLBar,  1)
    f_registerLevel(8,  loH,    "LO-H", colSession, loh_broken, loh_touch, loHBar,  1)
    f_registerLevel(9,  loL,    "LO-L", colSession, lol_broken, lol_touch, loLBar,  1)
    f_registerLevel(10, nyH,    "NY-H", colSession, nyh_broken, nyh_touch, nyHBar,  1)
    f_registerLevel(11, nyL,    "NY-L", colSession, nyl_broken, nyl_touch, nyLBar,  1)

    // Enable flags: same visibility set as the focus engine
    array.set(lvl_enabled, 0,  inclDaily)
    array.set(lvl_enabled, 1,  inclDaily)
    array.set(lvl_enabled, 2,  inclWeekly)
    array.set(lvl_enabled, 3,  inclWeekly)
    array.set(lvl_enabled, 4,  inclMonthly)
    array.set(lvl_enabled, 5,  inclMonthly)
    array.set(lvl_enabled, 6,  inclSession)
    array.set(lvl_enabled, 7,  inclSession)
    array.set(lvl_enabled, 8,  inclSession)
    array.set(lvl_enabled, 9,  inclSession)
    array.set(lvl_enabled, 10, inclSession)
    array.set(lvl_enabled, 11, inclSession)

    // Kill unavailable or contextually distant levels. The same relevance
    // corridor is used by the focus engine, so panel and chart stay aligned.
    for i = 0 to 11
        levelP = array.get(lvl_price, i)
        if na(levelP) or atrVal <= 0 or math.abs(close - levelP) / atrVal > maxVisibleATR
            array.set(lvl_enabled, i, false)

    // -- Deduplication: same-price levels -> keep highest priority --
    if dedupLevels
        for i = 0 to 11
            if array.get(lvl_enabled, i)
                priI = array.get(lvl_prio, i)
                prI  = array.get(lvl_price, i)
                for j = 0 to 11
                    if j != i and array.get(lvl_enabled, j)
                        priJ = array.get(lvl_prio, j)
                        prJ  = array.get(lvl_price, j)
                        if not na(prI) and not na(prJ) and math.abs(prI - prJ) <= dedupSpace and priJ < priI
                            array.set(lvl_enabled, j, false)

    // -- Draw levels --
    for i = 0 to 11
        if array.get(lvl_enabled, i)
            levelP = array.get(lvl_price, i)
            duplicatesFocus = focusIdx >= 0 and not na(focusP) and math.abs(levelP - focusP) <= dedupSpace
            f_drawLevel(
                 levelP,
                 array.get(lvl_label,   i),
                 array.get(lvl_color,   i),
                 array.get(lvl_broken,  i),
                 array.get(lvl_touches, i),
                 showLabels and not duplicatesFocus,
                 array.get(lvl_zbar,    i))

    // -- Focus level decision card --
    if showFocusCard and focusIdx >= 0 and not na(distFocusATR) and distFocusATR <= 1.0
        tierCol  = focusT == 4 ? colMonthly : focusT == 3 ? colWeekly : focusT == 2 ? colDaily : colSession
        badgeBg  = focusBroken ? colBroken : tierCol
        holdLine = focusT == 1 ? "Session level" : tierN > 0 ? "Hold " + str.tostring(math.round(tierRate)) + "%  (n=" + str.tostring(tierN) + ")" : "Hold -  (n=0)"
        badgeTxt = focusLbl + "  " + f_priceStr(focusP) + "\nScore " + str.tostring(reactScore) + " / 100\n" + holdLine
        bLbl = label.new(bar_index + math.round(lineLen * 0.45), focusP, badgeTxt,
             style     = close < focusP ? label.style_label_down : label.style_label_up,
             color     = badgeBg,
             textcolor = f_text_on(badgeBg),
             size      = labelTextSize)
        array.push(vLabels, bLbl)

// ==================================================
// PANEL HELPERS
// ==================================================
f_holdText(w, n) =>
    n > 0 ? str.tostring(math.round(100.0 * w / n)) + "%  (n=" + str.tostring(n) + ")" : "-  (n=0)"

f_holdColor(w, n, fb) =>
    // Color follows the same rounded rate shown in the panel text,
    // so an identical displayed percentage always has an identical color.
    r = n > 0 ? math.round(100.0 * w / n) : 0
    n >= 8 ? (r >= 55 ? bullColor : r >= 40 ? neutralColor : bearColor) : fb

// ==================================================
// INFO PANEL
// ==================================================
var table t = table.new(position.top_right, 2, 11,
     bgcolor      = color.new(panelBg, 5),
     border_color = color.new(panelBorder, 10),
     border_width = 1,
     frame_color  = color.new(panelBorder, 10),
     frame_width  = 1)

if barstate.islast and not showPanel
    table.clear(t, 0, 0, 1, 10)

if showPanel and barstate.islast
    table.clear(t, 0, 0, 1, 10)
    bgCol  = panelTheme == "Light" ? color.rgb(255, 255, 255) : panelBg
    lblCol = panelTheme == "Light" ? color.rgb(80,  80,  80)  : panelLabelCol
    valCol = panelTheme == "Light" ? color.rgb(20,  20,  20)  : panelValueCol

    table.set_position(t, f_panelPos(panelLoc))

    table.cell(t, 0, 0, "AG Pro Key Levels",
         bgcolor = headerBg, text_color = headerText, text_size = panelTextSize, text_halign = text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

    table.cell(t, 0, 1, "Session",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 1, sessState,
         text_color = valCol, text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 2, "Near Above",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 2, not na(nearAbove) ? f_priceStr(nearAbove) + "  (" + str.tostring(distAboveATR) + "x)" : "-",
         text_color = valCol, text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 3, "Near Below",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 3, not na(nearBelow) ? f_priceStr(nearBelow) + "  (" + str.tostring(distBelowATR) + "x)" : "-",
         text_color = valCol, text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 4, "Focus Level",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 4, focusIdx >= 0 ? focusLbl + "  " + f_priceStr(focusP) : "-",
         text_color = valCol, text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    scoreCol = focusGated ? (reactScore >= 70 ? bullColor : reactScore >= 45 ? neutralColor : bearColor) : lblCol
    table.cell(t, 0, 5, "Reaction Score",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 5, focusIdx >= 0 ? str.tostring(reactScore) + " / 100" : "-",
         text_color = scoreCol, text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 6, "-- LEVEL HOLD --",
         text_color = accentColor, text_size = panelTextSize, text_halign = text.align_center, bgcolor = bgCol)
    table.merge_cells(t, 0, 6, 1, 6)

    table.cell(t, 0, 7, "Daily",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 7, f_holdText(dHoldW, dHoldN),
         text_color = f_holdColor(dHoldW, dHoldN, lblCol), text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 8, "Weekly",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 8, f_holdText(wHoldW, wHoldN),
         text_color = f_holdColor(wHoldW, wHoldN, lblCol), text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 9, "Monthly",
         text_color = lblCol, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.cell(t, 1, 9, f_holdText(mHoldW, mHoldN),
         text_color = f_holdColor(mHoldW, mHoldN, lblCol), text_size = panelTextSize, text_halign = text.align_right, bgcolor = bgCol)

    table.cell(t, 0, 10, actionTxt,
         text_color = accentColor, text_size = panelTextSize, text_halign = text.align_left, bgcolor = bgCol)
    table.merge_cells(t, 0, 10, 1, 10)
````
