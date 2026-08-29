<!-- tradingview-pine-id: PUB;0cd7f72f23714951b55ce59e484fd911 -->
<!-- tradingviewscripts-format: 1 -->
# [SkuldX] ADR — Average Daily Range

Source: https://www.tradingview.com/script/6cNFRrM0-SkuldX-Average-Daily-Range/

## Description

SkuldX Average Daily Range
by SkuldX Trading Systems

What is it?
SkuldX ADR calculates the Average Daily Range across three independent periods and projects statistical price targets directly on the chart. Instead of just showing a raw number, it tells you exactly where today's statistically likely high and low are — and how much of that range has already been consumed. This transforms a simple volatility measure into a practical decision-making tool for every session.

The core concept
Every instrument has a characteristic daily range — how far it typically moves from low to high in a single day. ADR measures this by averaging the daily High minus Low over a chosen number of past sessions. When today's price approaches the ADR High or Low level projected from the daily open, the market is statistically reaching its expected limit for the day. This is where momentum tends to slow, consolidate, or reverse.
The key insight: if the market has already consumed 90%+ of its average daily range, the probability of further directional movement drops significantly. Conversely, if only 20% of the range has been used, there is substantial room left to move.

Three periods — three perspectives
🟡 ADR 5 — 5-day average (one trading week). Most reactive to recent conditions. Best for identifying short-term volatility shifts and current week behavior.
🔵 ADR 10 — 10-day average (two weeks). Balanced view of recent momentum without excessive noise.
🟠 ADR 20 — 20-day average (one month). The standard institutional reference. Most stable and reliable for setting daily targets and stops.
All three periods are independent and can be toggled on or off. When all three are active simultaneously, the spacing between their levels gives a visual read on volatility expansion or contraction — tight clustering means stable conditions, wide separation means the market is in a transitional phase.

What you see on the chart
Each enabled period draws two horizontal lines per day — an ADR High and an ADR Low — projected symmetrically above and below the daily open (00:00 NY time). A dotted midline marks the daily open itself.
Each label shows three pieces of information simultaneously:
ADR20 H  2415.50  [87.30]  72% used

The projected level price
The ADR value in brackets — how many points the average daily range is
The percentage of today's range already consumed
Lines are drawn fresh at the start of each day and historical days remain visible on the chart for reference and backtesting.

Daily Range Used %
This is the most actionable metric in the indicator. It answers the question: how much room does the market have left today?
Below 50% — significant range remaining, directional moves are still viable
50–80% — range is being consumed, momentum may slow near ADR levels
Above 90% — statistically exhausted, high probability of slowdown, consolidation or reversal at ADR levels
Above 100% — unusual day, range has exceeded the historical average, often signals a news-driven or institutional event

Alerts
A configurable alert fires when the daily range consumed exceeds your threshold (default 90%). This allows you to catch exhaustion points in real time without watching the chart constantly. The alert specifies which ADR period triggered and the exact percentage consumed.

Settings
ADR 5 / 10 / 20 — enable or disable each period independently with custom colors
Show ADR High / Low levels — toggle the projected level lines
Show Daily Open — toggle the dotted midline at 00:00 NY open
Show Daily Range Used % — toggle the consumption percentage in labels
Show Labels — toggle all right-edge labels
Label Size — tiny, small, or normal
Line Width / Style — visual customization
Alert threshold % — percentage of ADR consumed that triggers the exhaustion alert

How to use it in practice
As a take-profit guide — when price approaches ADR High or Low with 80%+ range consumed, consider taking partial or full profit rather than holding for further extension.
As a reversal filter — avoid entering new directional trades when the ADR Used % is above 85–90%. The statistical edge has diminished significantly.
As a stop-loss reference — place stops beyond the ADR High or Low to avoid being caught by normal daily volatility.
Combined with session analysis — ADR levels are most powerful when they align with session structures. An ADR High that coincides with London High or Asian High becomes a confluence zone with significantly higher reversal probability.
Combined with OI data — if price reaches ADR High while the OI Delta shows Short Squeeze conditions, the move is likely unsustained and a reversal is probable. If it reaches ADR High with Bullish Trend OI, the day may extend beyond the average range.

Why 00:00 NY as the daily open
Crypto trades 24/7 without a traditional open. The New York midnight open (00:00 NY) is used as the reference point because it aligns with institutional risk resets, matches the TDO used across the SkuldX suite, and provides a consistent reference across all instruments and timezones with automatic DST adjustment.

Built for SkuldX ecosystem
SkuldX ADR is designed to work alongside the full SkuldX suite. ADR levels combined with TDO/TWO session opens, OI Delta signals, and Level Patterns reactions give a complete picture of where price is likely to pause, reverse, or accelerate on any given day.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] ADR — Average Daily Range", overlay = true, max_lines_count = 500, max_labels_count = 500)


// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

adr5Enable  = input.bool(true,  "ADR 5 days",  inline = "adr5",  group = "ADR Periods")
adr5Color   = input.color(color.new(color.yellow, 20), "",        inline = "adr5",  group = "ADR Periods")

adr10Enable = input.bool(true,  "ADR 10 days", inline = "adr10", group = "ADR Periods")
adr10Color  = input.color(color.new(color.aqua,   20), "",        inline = "adr10", group = "ADR Periods")

adr20Enable = input.bool(true,  "ADR 20 days", inline = "adr20", group = "ADR Periods")
adr20Color  = input.color(color.new(color.orange, 20), "",        inline = "adr20", group = "ADR Periods")

showHighLow     = input.bool(true,  "Show ADR High / Low levels",      group = "Display")
showMidline     = input.bool(true,  "Show Daily Open (midline)",        group = "Display")
showUsagePct    = input.bool(true,  "Show Daily Range Used %",          group = "Display")
showLabels      = input.bool(true,  "Show Labels",                      group = "Display")
labelSize       = input.string("small", "Label Size",                   group = "Display", options = ["tiny", "small", "normal"])
lineWidth       = input.int(1,      "Line Width",                       group = "Display", minval = 1, maxval = 4)
lineStyleInput  = input.string("dashed", "Line Style",                  group = "Display", options = ["solid", "dashed", "dotted"])

alertThreshold  = input.float(90.0, "Alert: Range Used % threshold",    group = "Alerts",  minval = 50.0, maxval = 100.0, step = 5.0)


// ══════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════

// NY time — DST-aware
nyHour()   => hour(time,   "America/New_York")
nyMinute() => minute(time, "America/New_York")

// Line style converter
lineStyleVal() =>
    switch lineStyleInput
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted
        =>          line.style_solid

// Label size converter
labelSizeVal() =>
    switch labelSize
        "tiny"   => size.tiny
        "normal" => size.normal
        =>          size.small


// ══════════════════════════════════════════════════════
// ADR CALCULATION
// Requests daily High and Low via request.security
// Calculates DR (High - Low) for each past day
// Returns simple arithmetic mean over N days
// Uses NY timezone so crypto "day" aligns with 00:00 NY
// ══════════════════════════════════════════════════════

// Fetch daily high and low in NY timezone
dailyHigh = request.security(syminfo.tickerid, "D", high,  lookahead = barmerge.lookahead_off)
dailyLow  = request.security(syminfo.tickerid, "D", low,   lookahead = barmerge.lookahead_off)
dailyOpen = request.security(syminfo.tickerid, "D", open,  lookahead = barmerge.lookahead_off)

// Daily Range for each bar
dailyRange = dailyHigh - dailyLow

// ADR = simple mean of daily ranges over N periods
calcADR(int period) =>
    ta.sma(dailyRange, period)

adr5  = calcADR(5)
adr10 = calcADR(10)
adr20 = calcADR(20)


// ══════════════════════════════════════════════════════
// DAILY OPEN TRACKING
// Captures the open price at 00:00 NY each day
// Used as the midline from which ADR levels are projected
// ══════════════════════════════════════════════════════

var float todayOpen    = na
var int   dayStartBar  = na

bool isNewDay = nyHour() == 0 and nyMinute() == 0

if isNewDay
    todayOpen   := open
    dayStartBar := bar_index


// ══════════════════════════════════════════════════════
// ADR LEVELS
// Projected symmetrically above and below the daily open
// ADR High = Daily Open + ADR value
// ADR Low  = Daily Open - ADR value
// ══════════════════════════════════════════════════════

adr5High  = not na(todayOpen) ? todayOpen + adr5  : na
adr5Low   = not na(todayOpen) ? todayOpen - adr5  : na
adr10High = not na(todayOpen) ? todayOpen + adr10 : na
adr10Low  = not na(todayOpen) ? todayOpen - adr10 : na
adr20High = not na(todayOpen) ? todayOpen + adr20 : na
adr20Low  = not na(todayOpen) ? todayOpen - adr20 : na


// ══════════════════════════════════════════════════════
// DAILY RANGE USED %
// Measures how much of today's ADR has already been consumed
// Calculated as: current day range / ADR value * 100
// High % = day is statistically exhausted → reversal risk increases
// ══════════════════════════════════════════════════════

// Today's actual range so far (from daily open to current high/low extreme)
todayHigh = request.security(syminfo.tickerid, "D", high,  lookahead = barmerge.lookahead_on)
todayLow  = request.security(syminfo.tickerid, "D", low,   lookahead = barmerge.lookahead_on)
todayRange = todayHigh - todayLow

// % of ADR consumed today
usedPct5  = adr5  > 0 ? todayRange / adr5  * 100 : na
usedPct10 = adr10 > 0 ? todayRange / adr10 * 100 : na
usedPct20 = adr20 > 0 ? todayRange / adr20 * 100 : na


// ══════════════════════════════════════════════════════
// DRAWING — ADR LEVELS PER DAY
// Lines are created fresh each day and extended to end of day
// Historical days remain visible on chart
// ══════════════════════════════════════════════════════

// Current day active lines
var line lineOpen   = na
var line line5H     = na
var line line5L     = na
var line line10H    = na
var line line10L    = na
var line line20H    = na
var line line20L    = na

// Labels
var label lblOpen   = na
var label lbl5H     = na
var label lbl5L     = na
var label lbl10H    = na
var label lbl10L    = na
var label lbl20H    = na
var label lbl20L    = na
var label lblUsage  = na

// On new day: create fresh lines and labels
if isNewDay and not na(todayOpen)
    // Daily open midline
    if showMidline
        lineOpen := line.new(
             x1    = bar_index,
             y1    = todayOpen,
             x2    = bar_index + 1,
             y2    = todayOpen,
             color = color.new(color.white, 50),
             width = 1,
             style = line.style_dotted)

    // ADR 5
    if showHighLow and adr5Enable
        line5H := line.new(bar_index, adr5High, bar_index + 1, adr5High, color = adr5Color, width = lineWidth, style = lineStyleVal())
        line5L := line.new(bar_index, adr5Low,  bar_index + 1, adr5Low,  color = adr5Color, width = lineWidth, style = lineStyleVal())

    // ADR 10
    if showHighLow and adr10Enable
        line10H := line.new(bar_index, adr10High, bar_index + 1, adr10High, color = adr10Color, width = lineWidth, style = lineStyleVal())
        line10L := line.new(bar_index, adr10Low,  bar_index + 1, adr10Low,  color = adr10Color, width = lineWidth, style = lineStyleVal())

    // ADR 20
    if showHighLow and adr20Enable
        line20H := line.new(bar_index, adr20High, bar_index + 1, adr20High, color = adr20Color, width = lineWidth, style = lineStyleVal())
        line20L := line.new(bar_index, adr20Low,  bar_index + 1, adr20Low,  color = adr20Color, width = lineWidth, style = lineStyleVal())


// Extend all active lines rightward on every bar
if not na(lineOpen) and showMidline
    line.set_x2(lineOpen, bar_index + 1)

if showHighLow
    if adr5Enable
        if not na(line5H)
            line.set_x2(line5H, bar_index + 1)
            line.set_x2(line5L, bar_index + 1)
    if adr10Enable
        if not na(line10H)
            line.set_x2(line10H, bar_index + 1)
            line.set_x2(line10L, bar_index + 1)
    if adr20Enable
        if not na(line20H)
            line.set_x2(line20H, bar_index + 1)
            line.set_x2(line20L, bar_index + 1)


// ══════════════════════════════════════════════════════
// LABELS — updated on last bar only
// Show ADR value and % used for each period
// ══════════════════════════════════════════════════════

if barstate.islast and showLabels and not na(todayOpen)
    szVal = labelSizeVal()

    // Daily Open label
    if showMidline
        label.delete(lblOpen)
        lblOpen := label.new(
             x         = bar_index + 2,
             y         = todayOpen,
             text      = "TDO  " + str.tostring(todayOpen, format.mintick),
             style     = label.style_label_left,
             color     = color.new(color.white, 70),
             textcolor = color.white,
             size      = szVal)

    // ADR 5 labels
    if showHighLow and adr5Enable and not na(adr5High)
        label.delete(lbl5H)
        label.delete(lbl5L)

        string usedStr5 = showUsagePct and not na(usedPct5) ?
             "  " + str.tostring(math.min(usedPct5, 999), "#") + "% used" : ""

        lbl5H := label.new(
             x         = bar_index + 2,
             y         = adr5High,
             text      = "ADR5 H  " + str.tostring(adr5High, format.mintick) +
                         "  [" + str.tostring(adr5, format.mintick) + "]" + usedStr5,
             style     = label.style_label_left,
             color     = color.new(adr5Color, 60),
             textcolor = adr5Color,
             size      = szVal)

        lbl5L := label.new(
             x         = bar_index + 2,
             y         = adr5Low,
             text      = "ADR5 L  " + str.tostring(adr5Low, format.mintick) +
                         "  [" + str.tostring(adr5, format.mintick) + "]" + usedStr5,
             style     = label.style_label_left,
             color     = color.new(adr5Color, 60),
             textcolor = adr5Color,
             size      = szVal)

    // ADR 10 labels
    if showHighLow and adr10Enable and not na(adr10High)
        label.delete(lbl10H)
        label.delete(lbl10L)

        string usedStr10 = showUsagePct and not na(usedPct10) ?
             "  " + str.tostring(math.min(usedPct10, 999), "#") + "% used" : ""

        lbl10H := label.new(
             x         = bar_index + 2,
             y         = adr10High,
             text      = "ADR10 H  " + str.tostring(adr10High, format.mintick) +
                         "  [" + str.tostring(adr10, format.mintick) + "]" + usedStr10,
             style     = label.style_label_left,
             color     = color.new(adr10Color, 60),
             textcolor = adr10Color,
             size      = szVal)

        lbl10L := label.new(
             x         = bar_index + 2,
             y         = adr10Low,
             text      = "ADR10 L  " + str.tostring(adr10Low, format.mintick) +
                         "  [" + str.tostring(adr10, format.mintick) + "]" + usedStr10,
             style     = label.style_label_left,
             color     = color.new(adr10Color, 60),
             textcolor = adr10Color,
             size      = szVal)

    // ADR 20 labels
    if showHighLow and adr20Enable and not na(adr20High)
        label.delete(lbl20H)
        label.delete(lbl20L)

        string usedStr20 = showUsagePct and not na(usedPct20) ?
             "  " + str.tostring(math.min(usedPct20, 999), "#") + "% used" : ""

        lbl20H := label.new(
             x         = bar_index + 2,
             y         = adr20High,
             text      = "ADR20 H  " + str.tostring(adr20High, format.mintick) +
                         "  [" + str.tostring(adr20, format.mintick) + "]" + usedStr20,
             style     = label.style_label_left,
             color     = color.new(adr20Color, 60),
             textcolor = adr20Color,
             size      = szVal)

        lbl20L := label.new(
             x         = bar_index + 2,
             y         = adr20Low,
             text      = "ADR20 L  " + str.tostring(adr20Low, format.mintick) +
                         "  [" + str.tostring(adr20, format.mintick) + "]" + usedStr20,
             style     = label.style_label_left,
             color     = color.new(adr20Color, 60),
             textcolor = adr20Color,
             size      = szVal)


// ══════════════════════════════════════════════════════
// ALERTS
// Fires when daily range consumed exceeds threshold
// Useful for catching exhaustion points in real time
// ══════════════════════════════════════════════════════

if adr20Enable and not na(usedPct20) and usedPct20 >= alertThreshold
    alert("ADR20 range " + str.tostring(usedPct20, "#") + "% consumed — reversal risk increasing", alert.freq_once_per_bar)

if adr10Enable and not na(usedPct10) and usedPct10 >= alertThreshold
    alert("ADR10 range " + str.tostring(usedPct10, "#") + "% consumed — reversal risk increasing", alert.freq_once_per_bar)

if adr5Enable and not na(usedPct5) and usedPct5 >= alertThreshold
    alert("ADR5 range " + str.tostring(usedPct5, "#") + "% consumed — reversal risk increasing", alert.freq_once_per_bar)


// ══════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════

plot(adr5,      "ADR 5 value",      color = color.new(color.yellow, 100), display = display.data_window)
plot(adr10,     "ADR 10 value",     color = color.new(color.aqua,   100), display = display.data_window)
plot(adr20,     "ADR 20 value",     color = color.new(color.orange, 100), display = display.data_window)

plot(adr5High,  "ADR5 High",        color = color.new(color.yellow, 100), display = display.data_window)
plot(adr5Low,   "ADR5 Low",         color = color.new(color.yellow, 100), display = display.data_window)
plot(adr10High, "ADR10 High",       color = color.new(color.aqua,   100), display = display.data_window)
plot(adr10Low,  "ADR10 Low",        color = color.new(color.aqua,   100), display = display.data_window)
plot(adr20High, "ADR20 High",       color = color.new(color.orange, 100), display = display.data_window)
plot(adr20Low,  "ADR20 Low",        color = color.new(color.orange, 100), display = display.data_window)

plot(usedPct5,  "ADR5 Used %",      color = color.new(color.yellow, 100), display = display.data_window)
plot(usedPct10, "ADR10 Used %",     color = color.new(color.aqua,   100), display = display.data_window)
plot(usedPct20, "ADR20 Used %",     color = color.new(color.orange, 100), display = display.data_window)
plot(todayOpen, "Today Open (TDO)", color = color.new(color.white,  100), display = display.data_window)
````
