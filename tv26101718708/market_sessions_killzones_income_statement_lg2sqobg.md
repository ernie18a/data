# Market Sessions + Killzones [Income Statement]

- url: https://www.tradingview.com/script/lG2SqobG-Market-Sessions-Killzones-Income-Statement/
- type: indicator
- pine_id: PUB;83c322eb99ed4abc9daf8435a9bd9a07
- version: 1.0

## Description

A persistent challenge in intraday trading is that price behaviour is not uniform across the 24-hour clock. Volatility, liquidity, and directional bias are heavily concentrated in specific windows tied to the opening and closing of major financial centres. 
[b]Market Sessions + Killzones indicator[/b] maps those windows directly onto the chart, layers in the structural tools that ICT-based traders use to read them, and combines everything into a single cohesive visual so traders do not need to manage multiple overlapping indicators.

[b]WHY THESE FEATURES ARE COMBINED[/b]
Session ranges, killzones, overlap periods, and previous session highs/lows are not independent ideas — they are sequential layers of the same framework. The session range defines the pool of liquidity that formed during a given market period. The previous session high and low represent the edges of that pool (similar to support and resistance) and become magnets for price in the following session. [b]Killzones [/b]are the time windows within which institutional order flow is most likely to be active and capable of driving price through those levels. The overlap periods are where two separate liquidity pools interact simultaneously, producing the conditions most likely to generate sharp directional moves.

Combining all four in one indicator preserves the cause-and-effect relationship between them. Displaying sessions without killzones, or killzones without previous session levels, loses the context that makes each layer meaningful.

[b]HOW THE INDICATOR WORKS[/b]
[b]Session Boundaries[/b][i][/i]
Each session (Tokyo, London, New York, optional Sydney) is tracked using the exchange's native timezone, not a fixed UTC offset. This matters because major sessions observe daylight saving time on different schedules, and a fixed-offset approach will silently drift by an hour during DST transitions. The script uses Pine's time() function with named timezone strings (Asia/Tokyo, Europe/London, etc.) to handle this automatically.

As each session progresses, the script tracks the running high and low bar-by-bar and extends the boundary lines to the current bar. At session close, the lines are locked in place and faded to indicate a completed session — distinguishing live sessions from historical ones at a glance.

[b]Midpoint and Quartile Lines[/b][i][/i]
Within each session, the script calculates the 50% midpoint and the 25%/75% quartile levels of the live range. These levels are drawn not because they are support/resistance in the classical sense, but because they divide the session's range into statistically meaningful zones. In ICT methodology, the midpoint (sometimes called the equilibrium) is a commonly referenced level for entries and targets. The quartiles indicate whether price is in the upper or lower half of the session's distribution.

[b]Previous Session Highs and Lows[/b][i][/i]
When a new session opens, the script saves the completed session's high and low and draws them forward as dashed lines into the new session. These levels represent the most visible liquidity pools from the prior period — stop-losses from traders who traded that session cluster above and below them. Price frequently targets these levels before establishing a new directional move.

[b]ICT Killzones[/b][i][/i]
Killzones are specific time windows identified in ICT methodology as high-probability trading periods:
• London Killzone: 02:00–05:00 New York time — the pre-London and early London open window, a period of frequent liquidity grabs before the main London trend establishes.
• New York Killzone: 07:00–10:00 New York time — encompasses the NY pre-market and the first 30 minutes of the NY open, the most liquid window of the trading day for USD pairs and US indices.

Each killzone is rendered as a box that expands dynamically with price throughout the window and locks when the window closes. The box captures the exact range of price movement during that period, making it easy to measure killzone expansion and compare it to the current session range.

[b]Overlap Periods[/b][i][/i]
Two overlap windows are detected and highlighted:
• Tokyo + London overlap: the brief window where Asian and European institutional flow intersect.
• London + New York overlap (08:30–12:00 ET approximately): historically the highest-volume period of the trading day for most major pairs. This overlap frequently produces the session's largest directional move or the strongest reversal of an earlier London move.

The overlap boxes expand dynamically with price, making it simple to see how much range was generated during the high-liquidity window versus the rest of the session.

[b]Live Statistics Table[/b][i][/i]
The table in the top-right corner displays the live session high, low, range in points, and range as a percentage of the 14-period ATR. The ATR ratio is the key metric here: it tells you not just how far price has moved, but how that move compares to recent volatility. A session range at 120% ATR suggests an unusually expansive session; one at 40% suggests compression that may precede a breakout.

[b]SETTINGS GUIDE[/b][i][/i]
[list]
[*]Swing Length: Not applicable to this indicator.
[*]Show Midpoint / Quartile Lines: Toggle to reduce visual noise on lower timeframes where the chart is already dense.
[*]Show Prev Session H/L: Disable if you only want the current session boundaries and killzones without the historical dashed levels.
[*]Show Overlap Zones: Disable for cleaner charts on assets where overlap volatility is less relevant (e.g. Asian equity CFDs).
[*]Show ICT Killzones: Toggle independently of sessions — useful if you want session ranges as context but only want to trade the killzone windows.
[*]Range as % ATR: Enables the ATR normalisation column in the table.
[/list]

[b]TIMEFRAME[/b]
This indicator is intentionally restricted to timeframes below 1 hour. Session structure and killzones are intraday concepts — applying them to daily or weekly charts produces meaningless output. Recommended: 1m, 3m, 5m, 15m, or 30m.

[b]USAGE NOTES[/b]
This indicator provides structural context, not signals. A common workflow is to identify the previous session high or low as a liquidity target, wait for price to enter a killzone, then use a separate entry model (e.g. order block, fair value gap, or market structure shift) to time the trade. The indicator does not generate buy or sell signals on its own.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// @version=6


indicator("Market Sessions + Killzones [Income Statement]",
          shorttitle      = "Sessions+KZ",
          max_lines_count = 500,
          max_labels_count= 500,
          max_boxes_count = 500,
          overlay         = true)

// ─────────────────────────────────────────────
// INPUTS
var grp_gen = "General"
bool showTable     = input.bool(true,  "Show Session Table",        group = grp_gen)
bool showMidpoint  = input.bool(true,  "Show Midpoint Line",        group = grp_gen)
bool showQuartiles = input.bool(false,  "Show Quartile Lines",       group = grp_gen)
bool showLabels    = input.bool(false, "Show Open/Close Labels",    group = grp_gen)
bool showOverlap   = input.bool(true,  "Show Overlap Zones",        group = grp_gen)
bool showPrevHL    = input.bool(false,  "Show Prev Session H/L",     group = grp_gen)
bool showKZ        = input.bool(true,  "Show ICT Killzones",        group = grp_gen)
bool showATR       = input.bool(true,  "Show Range as % ATR in Table", group = grp_gen)

var grp_sess = "Sessions"
bool showTokyo  = input.bool(true,  "Tokyo",    group = grp_sess)
bool showLondon = input.bool(true,  "London",   group = grp_sess)
bool showNY     = input.bool(true,  "New York", group = grp_sess)
bool showSydney = input.bool(false, "Sydney",   group = grp_sess)

if not (timeframe.isintraday and timeframe.multiplier < 60)
    runtime.error("Works only on timeframes below 1 hour.")


color COL_TK      = #FF2D78
color COL_LN      = #00F5FF
color COL_NY      = #39FF14
color COL_SD      = #FF6B00
color COL_OV_LNNY = #FFE600
color COL_OV_TKLN = #BF00FF
color COL_KZ_LN   = #00BFFF   
color COL_KZ_NY   = #ADFF2F  
color COL_PREV    = #888888  

inSydney = not na(time(timeframe.period, "0700-1600", "Australia/Sydney"))
inTokyo  = not na(time(timeframe.period, "0900-1800", "Asia/Tokyo"))
inLondon = not na(time(timeframe.period, "0800-1700", "Europe/London"))
inNY     = not na(time(timeframe.period, "0930-1600", "America/New_York"))


inKZ_LN = not na(time(timeframe.period, "0200-0500", "America/New_York"))
inKZ_NY = not na(time(timeframe.period, "0700-1000", "America/New_York"))

tokyoOpen   = inTokyo  and not inTokyo[1]
tokyoClose  = not inTokyo  and inTokyo[1]
londonOpen  = inLondon and not inLondon[1]
londonClose = not inLondon and inLondon[1]
nyOpen      = inNY     and not inNY[1]
nyClose     = not inNY     and inNY[1]
sydneyOpen  = inSydney and not inSydney[1]
sydneyClose = not inSydney and inSydney[1]

kzLnStart = inKZ_LN and not inKZ_LN[1]
kzLnEnd   = not inKZ_LN and inKZ_LN[1]
kzNyStart = inKZ_NY and not inKZ_NY[1]
kzNyEnd   = not inKZ_NY and inKZ_NY[1]

// ─────────────────────────────────────────────
// OVERLAP FLAGS
// ─────────────────────────────────────────────
bool overlapLN_NY = inLondon and inNY
bool overlapTK_LN = inTokyo  and inLondon

overlapLN_NY_Start = overlapLN_NY and not (inLondon[1] and inNY[1])
overlapLN_NY_End   = not overlapLN_NY and (inLondon[1] and inNY[1])
overlapTK_LN_Start = overlapTK_LN and not (inTokyo[1] and inLondon[1])
overlapTK_LN_End   = not overlapTK_LN and (inTokyo[1] and inLondon[1])

// ─────────────────────────────────────────────
// ATR
// ─────────────────────────────────────────────
atr14 = ta.atr(14)

// ─────────────────────────────────────────────
// SESSION STATE
// ─────────────────────────────────────────────
var float tkHigh = na, var float tkLow = na, var int tkStart = na
var float lnHigh = na, var float lnLow = na, var int lnStart = na
var float nyHigh = na, var float nyLow = na, var int nyStart = na
var float sdHigh = na, var float sdLow = na, var int sdStart = na

// Previous session H/L
var float tkPrevH = na, var float tkPrevL = na
var float lnPrevH = na, var float lnPrevL = na
var float nyPrevH = na, var float nyPrevL = na
var float sdPrevH = na, var float sdPrevL = na

// Previous H/L lines (dashed, extend right)
var line tkPrevHLine = na, var line tkPrevLLine = na
var line lnPrevHLine = na, var line lnPrevLLine = na
var line nyPrevHLine = na, var line nyPrevLLine = na
var line sdPrevHLine = na, var line sdPrevLLine = na

// Overlap boxes
var int   lnnyStart = na, var float lnnyHigh = na, var float lnnyLow = na, var box lnnyBox = na
var int   tklnStart = na, var float tklnHigh = na, var float tklnLow = na, var box tklnBox = na

// Killzone boxes
var int   kzLnStartIdx = na, var float kzLnHigh = na, var float kzLnLow = na, var box kzLnBox = na
var int   kzNyStartIdx = na, var float kzNyHigh = na, var float kzNyLow = na, var box kzNyBox = na

// Session lines
var line tkTop = na, var line tkBot = na, var line tkGlowT = na, var line tkGlowB = na
var line lnTop = na, var line lnBot = na, var line lnGlowT = na, var line lnGlowB = na
var line nyTop = na, var line nyBot = na, var line nyGlowT = na, var line nyGlowB = na
var line sdTop = na, var line sdBot = na, var line sdGlowT = na, var line sdGlowB = na

var line tkMid = na, var line tkQ1 = na, var line tkQ3 = na
var line lnMid = na, var line lnQ1 = na, var line lnQ3 = na
var line nyMid = na, var line nyQ1 = na, var line nyQ3 = na
var line sdMid = na, var line sdQ1 = na, var line sdQ3 = na

var label tkLbl = na
var label lnLbl = na
var label nyLbl = na
var label sdLbl = na

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
hline_new(int x, float y, color col, int w, string sty) =>
    line.new(x, y, x, y, color = col, width = w, style = sty, force_overlay = true)

updateLines(line top, line bot, line glowT, line glowB,
            line mid, line q1,  line q3,
            int startX, float hi, float lo, color col, bool dispMid, bool dispQ) =>
    _range = hi - lo
    midY   = lo + _range * 0.50
    q1Y    = lo + _range * 0.25
    q3Y    = lo + _range * 0.75
    line.set_x2(top,   bar_index), line.set_x2(bot,   bar_index)
    line.set_x2(glowT, bar_index), line.set_x2(glowB, bar_index)
    line.set_y1(top,   hi),  line.set_y2(top,   hi)
    line.set_y1(bot,   lo),  line.set_y2(bot,   lo)
    line.set_y1(glowT, hi),  line.set_y2(glowT, hi)
    line.set_y1(glowB, lo),  line.set_y2(glowB, lo)
    line.set_x2(mid, bar_index), line.set_x2(q1, bar_index), line.set_x2(q3, bar_index)
    line.set_y1(mid, midY), line.set_y2(mid, midY)
    line.set_y1(q1,   q1Y), line.set_y2(q1,   q1Y)
    line.set_y1(q3,   q3Y), line.set_y2(q3,   q3Y)
    line.set_color(mid, dispMid ? color.new(col, 40) : color.new(col, 100))
    line.set_color(q1,  dispQ   ? color.new(col, 65) : color.new(col, 100))
    line.set_color(q3,  dispQ   ? color.new(col, 65) : color.new(col, 100))

lockLines(line top, line bot, line glowT, line glowB,
          line mid, line q1, line q3) =>
    line.set_x2(top,   bar_index), line.set_x2(bot,   bar_index)
    line.set_x2(glowT, bar_index), line.set_x2(glowB, bar_index)
    line.set_x2(mid,   bar_index), line.set_x2(q1,    bar_index), line.set_x2(q3, bar_index)

buildLabel(int x, float hi, float lo, string name, color col) =>
    label.new(x, lo + (hi - lo) * 0.98,
              text          = name,
              style         = label.style_label_lower_right,
              size          = size.small,
              color         = color.new(col, 80),
              textcolor     = col,
              force_overlay = true)

updateLabel(label lbl, int x, float hi, float lo, string name, string rangeStr) =>
    label.set_x(lbl, x)
    label.set_y(lbl, lo + (hi - lo) * 0.98)
    label.set_text(lbl, name + "\n" + rangeStr)

spawnSession(int x, float hi, float lo, color col) =>
    glow = color.new(col, 78)
    top  = hline_new(x, hi, col,  2, line.style_solid)
    bot  = hline_new(x, lo, col,  2, line.style_solid)
    glT  = hline_new(x, hi, glow, 6, line.style_solid)
    glB  = hline_new(x, lo, glow, 6, line.style_solid)
    mid  = hline_new(x, (hi+lo)/2,       color.new(col, 40), 1, line.style_dotted)
    q1   = hline_new(x, lo+(hi-lo)*0.25, color.new(col, 65), 1, line.style_dashed)
    q3   = hline_new(x, lo+(hi-lo)*0.75, color.new(col, 65), 1, line.style_dashed)
    [top, bot, glT, glB, mid, q1, q3]

// Spawn or refresh a pair of dashed previous-H/L lines
spawnPrevHL(float pH, float pL, color col) =>
    lH = line.new(bar_index, pH, bar_index, pH,
                  color = color.new(col, 45), width = 1,
                  style = line.style_dashed, force_overlay = true)
    lL = line.new(bar_index, pL, bar_index, pL,
                  color = color.new(col, 45), width = 1,
                  style = line.style_dashed, force_overlay = true)
    [lH, lL]

extendPrevHL(line lH, line lL, float pH, float pL) =>
    line.set_x2(lH, bar_index), line.set_y1(lH, pH), line.set_y2(lH, pH)
    line.set_x2(lL, bar_index), line.set_y1(lL, pL), line.set_y2(lL, pL)

// ─────────────────────────────────────────────
// TOKYO
// ─────────────────────────────────────────────
if tokyoOpen and showTokyo
    // save previous before resetting
    tkPrevH := tkHigh
    tkPrevL := tkLow
    tkHigh  := high
    tkLow   := low
    tkStart := bar_index
    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_TK)
    tkTop := a, tkBot := b, tkGlowT := c, tkGlowB := d
    tkMid := e, tkQ1  := f, tkQ3    := g
    tkLbl := buildLabel(bar_index, high, low, "TK", COL_TK)
    if showPrevHL and not na(tkPrevH)
        [lH, lL] = spawnPrevHL(tkPrevH, tkPrevL, COL_TK)
        tkPrevHLine := lH
        tkPrevLLine := lL

if inTokyo and showTokyo
    tkHigh := math.max(tkHigh, high)
    tkLow  := math.min(tkLow,  low)
    rangeStr = str.tostring(math.round((tkHigh - tkLow) / syminfo.mintick)) + " pts"
    updateLines(tkTop, tkBot, tkGlowT, tkGlowB, tkMid, tkQ1, tkQ3, tkStart, tkHigh, tkLow, COL_TK, showMidpoint, showQuartiles)
    updateLabel(tkLbl, tkStart, tkHigh, tkLow, "TK", rangeStr)
    if showPrevHL and not na(tkPrevHLine)
        extendPrevHL(tkPrevHLine, tkPrevLLine, tkPrevH, tkPrevL)

if tokyoClose and showTokyo
    lockLines(tkTop, tkBot, tkGlowT, tkGlowB, tkMid, tkQ1, tkQ3)
    line.set_color(tkGlowT, color.new(COL_TK, 92))
    line.set_color(tkGlowB, color.new(COL_TK, 92))
    line.set_color(tkTop,   color.new(COL_TK, 55))
    line.set_color(tkBot,   color.new(COL_TK, 55))

// ─────────────────────────────────────────────
// LONDON
// ─────────────────────────────────────────────
if londonOpen and showLondon
    lnPrevH := lnHigh
    lnPrevL := lnLow
    lnHigh  := high
    lnLow   := low
    lnStart := bar_index
    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_LN)
    lnTop := a, lnBot := b, lnGlowT := c, lnGlowB := d
    lnMid := e, lnQ1  := f, lnQ3    := g
    lnLbl := buildLabel(bar_index, high, low, "LN", COL_LN)
    if showPrevHL and not na(lnPrevH)
        [lH, lL] = spawnPrevHL(lnPrevH, lnPrevL, COL_LN)
        lnPrevHLine := lH
        lnPrevLLine := lL

if inLondon and showLondon
    lnHigh := math.max(lnHigh, high)
    lnLow  := math.min(lnLow,  low)
    rangeStr = str.tostring(math.round((lnHigh - lnLow) / syminfo.mintick)) + " pts"
    updateLines(lnTop, lnBot, lnGlowT, lnGlowB, lnMid, lnQ1, lnQ3, lnStart, lnHigh, lnLow, COL_LN, showMidpoint, showQuartiles)
    updateLabel(lnLbl, lnStart, lnHigh, lnLow, "LN", rangeStr)
    if showPrevHL and not na(lnPrevHLine)
        extendPrevHL(lnPrevHLine, lnPrevLLine, lnPrevH, lnPrevL)

if londonClose and showLondon
    lockLines(lnTop, lnBot, lnGlowT, lnGlowB, lnMid, lnQ1, lnQ3)
    line.set_color(lnGlowT, color.new(COL_LN, 92))
    line.set_color(lnGlowB, color.new(COL_LN, 92))
    line.set_color(lnTop,   color.new(COL_LN, 55))
    line.set_color(lnBot,   color.new(COL_LN, 55))

// ─────────────────────────────────────────────
// NEW YORK
// ─────────────────────────────────────────────
if nyOpen and showNY
    nyPrevH := nyHigh
    nyPrevL := nyLow
    nyHigh  := high
    nyLow   := low
    nyStart := bar_index
    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_NY)
    nyTop := a, nyBot := b, nyGlowT := c, nyGlowB := d
    nyMid := e, nyQ1  := f, nyQ3    := g
    nyLbl := buildLabel(bar_index, high, low, "NY", COL_NY)
    if showPrevHL and not na(nyPrevH)
        [lH, lL] = spawnPrevHL(nyPrevH, nyPrevL, COL_NY)
        nyPrevHLine := lH
        nyPrevLLine := lL

if inNY and showNY
    nyHigh := math.max(nyHigh, high)
    nyLow  := math.min(nyLow,  low)
    rangeStr = str.tostring(math.round((nyHigh - nyLow) / syminfo.mintick)) + " pts"
    updateLines(nyTop, nyBot, nyGlowT, nyGlowB, nyMid, nyQ1, nyQ3, nyStart, nyHigh, nyLow, COL_NY, showMidpoint, showQuartiles)
    updateLabel(nyLbl, nyStart, nyHigh, nyLow, "NY", rangeStr)
    if showPrevHL and not na(nyPrevHLine)
        extendPrevHL(nyPrevHLine, nyPrevLLine, nyPrevH, nyPrevL)

if nyClose and showNY
    lockLines(nyTop, nyBot, nyGlowT, nyGlowB, nyMid, nyQ1, nyQ3)
    line.set_color(nyGlowT, color.new(COL_NY, 92))
    line.set_color(nyGlowB, color.new(COL_NY, 92))
    line.set_color(nyTop,   color.new(COL_NY, 55))
    line.set_color(nyBot,   color.new(COL_NY, 55))

// ─────────────────────────────────────────────
// SYDNEY
// ─────────────────────────────────────────────
if sydneyOpen and showSydney
    sdPrevH := sdHigh
    sdPrevL := sdLow
    sdHigh  := high
    sdLow   := low
    sdStart := bar_index
    [a, b, c, d, e, f, g] = spawnSession(bar_index, high, low, COL_SD)
    sdTop := a, sdBot := b, sdGlowT := c, sdGlowB := d
    sdMid := e, sdQ1  := f, sdQ3    := g
    sdLbl := buildLabel(bar_index, high, low, "SD", COL_SD)
    if showPrevHL and not na(sdPrevH)
        [lH, lL] = spawnPrevHL(sdPrevH, sdPrevL, COL_SD)
        sdPrevHLine := lH
        sdPrevLLine := lL

if inSydney and showSydney
    sdHigh := math.max(sdHigh, high)
    sdLow  := math.min(sdLow,  low)
    rangeStr = str.tostring(math.round((sdHigh - sdLow) / syminfo.mintick)) + " pts"
    updateLines(sdTop, sdBot, sdGlowT, sdGlowB, sdMid, sdQ1, sdQ3, sdStart, sdHigh, sdLow, COL_SD, showMidpoint, showQuartiles)
    updateLabel(sdLbl, sdStart, sdHigh, sdLow, "SD", rangeStr)
    if showPrevHL and not na(sdPrevHLine)
        extendPrevHL(sdPrevHLine, sdPrevLLine, sdPrevH, sdPrevL)

if sydneyClose and showSydney
    lockLines(sdTop, sdBot, sdGlowT, sdGlowB, sdMid, sdQ1, sdQ3)
    line.set_color(sdGlowT, color.new(COL_SD, 92))
    line.set_color(sdGlowB, color.new(COL_SD, 92))
    line.set_color(sdTop,   color.new(COL_SD, 55))
    line.set_color(sdBot,   color.new(COL_SD, 55))

// ─────────────────────────────────────────────
// OVERLAP ZONES
// ─────────────────────────────────────────────
if showOverlap
    if overlapLN_NY_Start
        lnnyStart := bar_index
        lnnyHigh  := high
        lnnyLow   := low
        lnnyBox   := box.new(lnnyStart, lnnyHigh, bar_index, lnnyLow,
                             border_color = COL_OV_LNNY, border_width = 1,
                             border_style = line.style_solid,
                             bgcolor      = color.new(COL_OV_LNNY, 93),
                             text = "⚡ LN+NY", text_color = COL_OV_LNNY,
                             text_size = size.small,
                             text_font_family = font.family_monospace,
                             text_valign = text.align_top, text_halign = text.align_left,
                             force_overlay = true)
    if overlapLN_NY and not na(lnnyBox)
        lnnyHigh := math.max(lnnyHigh, high)
        lnnyLow  := math.min(lnnyLow,  low)
        box.set_top(lnnyBox, lnnyHigh)
        box.set_bottom(lnnyBox, lnnyLow)
        box.set_right(lnnyBox, bar_index)
    if overlapLN_NY_End and not na(lnnyBox)
        box.set_right(lnnyBox, bar_index)

    if overlapTK_LN_Start
        tklnStart := bar_index
        tklnHigh  := high
        tklnLow   := low
        tklnBox   := box.new(tklnStart, tklnHigh, bar_index, tklnLow,
                             border_color = COL_OV_TKLN, border_width = 1,
                             border_style = line.style_solid,
                             bgcolor      = color.new(COL_OV_TKLN, 93),
                             text = "⚡ TK+LN", text_color = COL_OV_TKLN,
                             text_size = size.small,
                             text_font_family = font.family_monospace,
                             text_valign = text.align_top, text_halign = text.align_left,
                             force_overlay = true)
    if overlapTK_LN and not na(tklnBox)
        tklnHigh := math.max(tklnHigh, high)
        tklnLow  := math.min(tklnLow,  low)
        box.set_top(tklnBox, tklnHigh)
        box.set_bottom(tklnBox, tklnLow)
        box.set_right(tklnBox, bar_index)
    if overlapTK_LN_End and not na(tklnBox)
        box.set_right(tklnBox, bar_index)

// ─────────────────────────────────────────────
// ICT KILLZONES
// ─────────────────────────────────────────────
if showKZ
    // London Open Killzone
    if kzLnStart
        kzLnStartIdx := bar_index
        kzLnHigh     := high
        kzLnLow      := low
        kzLnBox      := box.new(kzLnStartIdx, kzLnHigh, bar_index, kzLnLow,
                                border_color = COL_KZ_LN, border_width = 1,
                                border_style = line.style_dotted,
                                bgcolor      = color.new(COL_KZ_LN, 88),
                                text = "🔵 LN KZ", text_color = COL_KZ_LN,
                                text_size = size.small,
                                text_font_family = font.family_monospace,
                                text_valign = text.align_top, text_halign = text.align_right,
                                force_overlay = true)

    if inKZ_LN and not na(kzLnBox)
        kzLnHigh := math.max(kzLnHigh, high)
        kzLnLow  := math.min(kzLnLow,  low)
        box.set_top(kzLnBox,    kzLnHigh)
        box.set_bottom(kzLnBox, kzLnLow)
        box.set_right(kzLnBox,  bar_index)

    if kzLnEnd and not na(kzLnBox)
        box.set_right(kzLnBox, bar_index)

    // New York Open Killzone
    if kzNyStart
        kzNyStartIdx := bar_index
        kzNyHigh     := high
        kzNyLow      := low
        kzNyBox      := box.new(kzNyStartIdx, kzNyHigh, bar_index, kzNyLow,
                                border_color = COL_KZ_NY, border_width = 1,
                                border_style = line.style_dotted,
                                bgcolor      = color.new(COL_KZ_NY, 88),
                                text = "🟢 NY KZ", text_color = COL_KZ_NY,
                                text_size = size.small,
                                text_font_family = font.family_monospace,
                                text_valign = text.align_top, text_halign = text.align_right,
                                force_overlay = true)

    if inKZ_NY and not na(kzNyBox)
        kzNyHigh := math.max(kzNyHigh, high)
        kzNyLow  := math.min(kzNyLow,  low)
        box.set_top(kzNyBox,    kzNyHigh)
        box.set_bottom(kzNyBox, kzNyLow)
        box.set_right(kzNyBox,  bar_index)

    if kzNyEnd and not na(kzNyBox)
        box.set_right(kzNyBox, bar_index)


plotshape(showLabels and showTokyo  and tokyoOpen,   title="TK Open",   text="▶ TK", style=shape.labeldown, location=location.top, color=color.new(COL_TK,20), textcolor=color.white, size=size.small, force_overlay=true)
plotshape(showLabels and showTokyo  and tokyoClose,  title="TK Close",  text="■ TK", style=shape.labeldown, location=location.top, color=color.new(COL_TK,55), textcolor=color.white, size=size.small, force_overlay=true)
plotshape(showLabels and showLondon and londonOpen,  title="LN Open",   text="▶ LN", style=shape.labeldown, location=location.top, color=color.new(COL_LN,20), textcolor=color.black, size=size.small, force_overlay=true)
plotshape(showLabels and showLondon and londonClose, title="LN Close",  text="■ LN", style=shape.labeldown, location=location.top, color=color.new(COL_LN,55), textcolor=color.black, size=size.small, force_overlay=true)
plotshape(showLabels and showNY     and nyOpen,      title="NY Open",   text="▶ NY", style=shape.labeldown, location=location.top, color=color.new(COL_NY,20), textcolor=color.black, size=size.small, force_overlay=true)
plotshape(showLabels and showNY     and nyClose,     title="NY Close",  text="■ NY", style=shape.labeldown, location=location.top, color=color.new(COL_NY,55), textcolor=color.black, size=size.small, force_overlay=true)
plotshape(showLabels and showSydney and sydneyOpen,  title="SD Open",   text="▶ SD", style=shape.labeldown, location=location.top, color=color.new(COL_SD,20), textcolor=color.black, size=size.small, force_overlay=true)
plotshape(showLabels and showSydney and sydneyClose, title="SD Close",  text="■ SD", style=shape.labeldown, location=location.top, color=color.new(COL_SD,55), textcolor=color.black, size=size.small, force_overlay=true)

// ─────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────
alertcondition(tokyoOpen,   title="Tokyo Open",           message="🔴 Tokyo session opened")
alertcondition(tokyoClose,  title="Tokyo Close",          message="🔴 Tokyo session closed")
alertcondition(londonOpen,  title="London Open",          message="🔵 London session opened")
alertcondition(londonClose, title="London Close",         message="🔵 London session closed")
alertcondition(nyOpen,      title="New York Open",        message="🟢 New York session opened")
alertcondition(nyClose,     title="New York Close",       message="🟢 New York session closed")
alertcondition(kzLnStart,   title="London KZ Start",      message="🔵 London killzone started (02:00 NY)")
alertcondition(kzNyStart,   title="NY KZ Start",          message="🟢 New York killzone started (07:00 NY)")
alertcondition(overlapLN_NY_Start, title="LN+NY Overlap Start", message="⚡ London + New York overlap started")
alertcondition(overlapTK_LN_Start, title="TK+LN Overlap Start", message="⚡ Tokyo + London overlap started")

// ─────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────
var table sess_tbl = table.new(
  position.top_right, 6, 6,
  bgcolor      = color.new(#0A0A0F, 20),
  frame_color  = color.new(#00F5FF, 50),
  frame_width  = 1,
  border_color = color.new(#00F5FF, 70),
  border_width = 1,
  force_overlay = true)

color HDR_BG  = color.new(#0A0A0F, 10)
color HDR_TXT = color.new(#00F5FF, 0)

sessCell(int row, string name, color col, bool isIn, float hi, float lo) =>
    statusTxt  = isIn ? "● LIVE" : "○ CLOSED"
    statusBg   = isIn ? color.new(col, 20) : color.new(#0A0A0F, 40)
    statusTCol = isIn ? color.black        : color.new(col, 20)
    rangePts   = not na(hi) and not na(lo) ? str.tostring(math.round((hi - lo) / syminfo.mintick)) + " pts" : "—"
    // ATR % column
    atrPct     = (not na(hi) and not na(lo) and not na(atr14) and atr14 > 0)
                 ? str.tostring(math.round((hi - lo) / atr14 * 100)) + "%"
                 : "—"
    table.cell(sess_tbl, 0, row, name,       text_color=color.new(col,0),   bgcolor=color.new(#0A0A0F,20), text_size=size.small)
    table.cell(sess_tbl, 1, row, statusTxt,  text_color=statusTCol,         bgcolor=statusBg,              text_size=size.small)
    table.cell(sess_tbl, 2, row, not na(hi) ? str.tostring(math.round(hi,5)) : "—",
               text_color=color.new(col,10), bgcolor=color.new(#0A0A0F,30), text_size=size.small)
    table.cell(sess_tbl, 3, row, not na(lo) ? str.tostring(math.round(lo,5)) : "—",
               text_color=color.new(col,10), bgcolor=color.new(#0A0A0F,30), text_size=size.small)
    table.cell(sess_tbl, 4, row, rangePts,   text_color=color.new(col,10),  bgcolor=color.new(#0A0A0F,30), text_size=size.small)
    table.cell(sess_tbl, 5, row, showATR ? atrPct : "",
               text_color=color.new(col,10),  bgcolor=color.new(#0A0A0F,30), text_size=size.small)

fillTable() =>
    table.cell(sess_tbl, 0, 0, "SESSION", text_color=HDR_TXT, bgcolor=HDR_BG, text_size=size.small)
    table.cell(sess_tbl, 1, 0, "STATUS",  text_color=HDR_TXT, bgcolor=HDR_BG, text_size=size.small)
    table.cell(sess_tbl, 2, 0, "HIGH",    text_color=HDR_TXT, bgcolor=HDR_BG, text_size=size.small)
    table.cell(sess_tbl, 3, 0, "LOW",     text_color=HDR_TXT, bgcolor=HDR_BG, text_size=size.small)
    table.cell(sess_tbl, 4, 0, "RANGE",   text_color=HDR_TXT, bgcolor=HDR_BG, text_size=size.small)
    table.cell(sess_tbl, 5, 0, showATR ? "% ATR" : "", text_color=HDR_TXT, bgcolor=HDR_BG, text_size=size.small)
    sessCell(1, "TOKYO",    COL_TK, inTokyo,  tkHigh, tkLow)
    sessCell(2, "LONDON",   COL_LN, inLondon, lnHigh, lnLow)
    sessCell(3, "NEW YORK", COL_NY, inNY,     nyHigh, nyLow)
    sessCell(4, "SYDNEY",   COL_SD, inSydney, sdHigh, sdLow)
    ovTxt    = overlapLN_NY ? "⚡ LN+NY" : overlapTK_LN ? "⚡ TK+LN" : "  —"
    ovBg     = overlapLN_NY ? color.new(COL_OV_LNNY,30) : overlapTK_LN ? color.new(COL_OV_TKLN,30) : color.new(#0A0A0F,50)
    ovTxtCol = overlapLN_NY ? color.black : overlapTK_LN ? color.white : color.new(#555577,0)
    table.cell(sess_tbl, 0, 5, "OVERLAP", text_color=HDR_TXT, bgcolor=HDR_BG,  text_size=size.small)
    table.cell(sess_tbl, 1, 5, ovTxt,     text_color=ovTxtCol, bgcolor=ovBg,   text_size=size.small)
    table.merge_cells(sess_tbl, 1, 5, 5, 5)

if showTable
    fillTable()
````
