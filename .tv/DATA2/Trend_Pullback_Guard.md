<!-- tradingview-pine-id: PUB;d94c64e0e67c44b988f42db5c007f41a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Pullback Guard

Source: https://www.tradingview.com/script/He2uIkkj/

## Description

Trend Pullback Guard

A trend has started. Does its next pullback stabilize — or lose its structure?

Trend Pullback Guard follows pullbacks through a defined sequence: detection, stabilization, continuation confirmation, or invalidation. It combines an EMA trend regime with frozen structure levels, volatility-normalized pullback depth and candle-overlap measurements.

The same rules work in both directions. Everything is included in one overlay indicator.

QUICK VISUAL GUIDE

• Blue line: Fast EMA; gray line: Slow EMA.
• Small blue dot: A pullback has been detected.
• Subtle green/red zone: The developing long/short pullback range.
• Red level: Frozen structure boundary.
• Amber level: Confirmation threshold after stabilization.
• Green upward/red downward triangle: Long/short continuation conditions confirmed.
• Red cross: A close broke the frozen structure boundary.
• Gray square: The trend regime was lost or the observation window ended.

The dashboard distinguishes an active episode's LAST CLOSE from frozen LAST EPISODE values. The structure and confirmation levels describe the rules; they are not suggested order prices.

1 — ESTABLISH THE TREND

Default settings use a 21-period EMA and a 55-period EMA.

For a long regime, the fast EMA must be above the slow EMA and the slow EMA must be above its value three bars earlier. Short conditions are reversed.

Before a pullback can begin, a confirmed impulse bar must lie entirely beyond the fast EMA's 0.25 ATR touch band and close in the trend direction relative to the previous close. This arms the monitor. A new episode requires a new qualifying impulse after the previous episode ends.

2 — DETECT AND FREEZE THE REFERENCE

A long pullback begins when a later bar reaches the fast EMA's upper touch band and closes below the previous close. Short detection uses the lower band and a higher close.

At detection, the script freezes:

• ATR from the previous bar, using a 14-period ATR by default.
• The lowest low of the preceding 10 bars minus 0.1 frozen ATR for long structure; the highest high plus that buffer for short structure.
• The preceding 10-bar high for long pullback depth, or low for short depth.

The detection bar is excluded from these historical reference windows. No pivot that needs future bars is used. The structure boundary remains fixed throughout the episode.

3 — WAIT FOR STABILIZATION

By default, two consecutive bars must avoid lowering the previous bar's low for a long setup, or raising its high for a short setup.

The confirmation level is then frozen at the highest high of those two stabilization bars plus 0.1 frozen ATR for longs. Shorts use their lowest low minus the buffer.

A new adverse extreme of the monitored pullback resets stabilization and removes the old trigger. The script must establish a new one. A bar that makes a new adverse extreme cannot also confirm continuation.

4 — APPLY THE GUARD

Confirmation requires a LATER bar to close strictly beyond the frozen trigger and on the trend side of the fast EMA. The original trend regime must still hold, and both guard limits must pass:

• Maximum pullback depth: 3.0 frozen ATR by default. Depth measures the move from the pre-detection reference extreme to the worst pullback extreme observed so far.
• Maximum mean candle overlap: 70% by default. Each sample is the intersection of two consecutive high-low ranges divided by the smaller range. Samples are averaged from detection through the current bar; a zero-range candle counts as 100% overlap.

TOO DEEP and HIGH OVERLAP explain why confirmation is blocked. These are rule thresholds, not estimated probabilities. High overlap can later decline; the maximum observed depth cannot shrink within an episode.

HOW AN EPISODE ENDS

• STRUCTURE BROKEN: The close moves strictly beyond the frozen structure boundary against the setup. A wick alone is insufficient.
• TREND LOST: The EMA regime no longer supports the monitored direction.
• CONTINUATION CONFIRMED: A later close passes the trigger, trend and guard requirements.
• WINDOW ENDED: No confirmation within 12 bars after detection by default.

Structure failure takes priority over other outcomes, followed by loss of the trend regime. An otherwise valid confirmation on the final allowed bar takes priority over timeout. Only one episode is active at a time.

ILLUSTRATIVE LONG EXAMPLE

Suppose the pre-pullback high is 104 and the frozen ATR is 2. A pullback low at 100 represents a depth of 2 ATR.

After two qualifying stabilization bars, their highest high is 102.50. With the default buffer, the confirmation level is 102.70.

A later close above 102.70 confirms only if the EMA regime remains bullish, the close is above the fast EMA, and the depth and overlap limits still pass. A wick above 102.70 does not confirm. A new pullback low on that bar resets the trigger instead.

This example illustrates the rules; it is not a historical trade or a return claim.

DASHBOARD AND ALERTS

The compact dashboard shows status, direction, bars since detection, depth in frozen ATR units, mean overlap, guard status, structure and confirmation levels.

The Confirmed / broken / other counters describe events in the loaded chart history. Other combines trend loss and timeout. These counts are not trading win rates; confirmed events are not followed to a profit target or stop.

Seven alert conditions are provided: pullback detected, stabilization, long confirmation, short confirmation, structure broken, trend lost and observation window ended. Stabilization can alert again if a new adverse extreme resets the setup. Create the desired alerts separately in TradingView.

USAGE AND LIMITATIONS

Use standard candles with a fast EMA length smaller than the slow EMA length. Long-only, short-only and both-direction modes are available. All calculations use the chart's symbol and timeframe; there is no external indicator dependency or higher-timeframe data request.

Event states and markers update only at confirmed bar closes and are never shifted backward. EMA lines can move while a live bar is forming. Changes to settings, available history or historical prices can change the resulting events.

This is a descriptive technical-analysis tool, not an automated trading strategy. Confirmation describes the specified conditions at that close; it does not guarantee that the trend will continue. No profitability or superior performance has been established.

---

## Source Code

````pine
//@version=6
// Original implementation for BotTradeLab. Rule-based context, not an execution strategy.
indicator("Trend Pullback Guard", "Pullback Guard", overlay = true, precision = 2)

int fastLen = input.int(21, "Fast EMA", minval = 2, group = "Trend", display = display.none)
int slowLen = input.int(55, "Slow EMA", minval = 3, group = "Trend", display = display.none)
int slopeLen = input.int(3, "Slow EMA slope bars", minval = 1, maxval = 20, group = "Trend", display = display.none)
string side = input.string("Both", "Direction", options = ["Both", "Long", "Short"], group = "Trend", display = display.none)
int atrLen = input.int(14, "ATR length", minval = 2, group = "Pullback", display = display.none)
float bandATR = input.float(0.25, "EMA touch band (ATR)", minval = 0, step = 0.05, group = "Pullback", display = display.none)
int structureLen = input.int(10, "Pre-pullback structure lookback", minval = 2, maxval = 100, group = "Pullback", display = display.none)
float bufferATR = input.float(0.1, "Structure / confirmation buffer (ATR)", minval = 0, step = 0.05, group = "Pullback", display = display.none)
int stableBars = input.int(2, "Stabilization bars", minval = 1, maxval = 5, group = "Guard", display = display.none)
int maxBars = input.int(12, "Maximum bars after detection", minval = 2, maxval = 100, group = "Guard", display = display.none)
float maxDepth = input.float(3.0, "Maximum depth for confirmation (ATR)", minval = 0.25, step = 0.25, group = "Guard", display = display.none)
float maxOverlap = input.float(70, "Maximum mean candle overlap (%)", minval = 0, maxval = 100, step = 5, group = "Guard", display = display.none, tooltip = "Intersection of consecutive candle ranges divided by their smaller range. Mean since detection; high values suggest congestion. Zero-range candles count as 100% overlap.")
bool showEMA = input.bool(true, "Show trend EMAs", group = "Display", display = display.none)
bool showZone = input.bool(true, "Show monitored pullback zone", group = "Display", display = display.none)
bool showMarks = input.bool(true, "Show event markers", group = "Display", display = display.none)
bool showPanel = input.bool(true, "Show compact dashboard", group = "Display", display = display.none)
string corner = input.string("Bottom right", "Dashboard position", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = "Display", display = display.none)

if barstate.isfirst and (not chart.is_standard or fastLen >= slowLen)
    runtime.error("Use standard candles and a fast EMA length smaller than the slow EMA length.")
float fast = ta.ema(close, fastLen)
float slow = ta.ema(close, slowLen)
float atr = ta.atr(atrLen)
float priorLow = ta.lowest(low, structureLen)[1]
float priorHigh = ta.highest(high, structureLen)[1]
float stableHigh = ta.highest(high, stableBars)
float stableLow = ta.lowest(low, stableBars)
bool ready = bar_index >= math.max(slowLen + slopeLen, math.max(structureLen, atrLen)) and not na(atr[1]) and atr[1] > 0
int trend = ready ? (fast > slow and slow > slow[slopeLen] ? 1 : fast < slow and slow < slow[slopeLen] ? -1 : 0) : 0
float smallerRange = math.min(high - low, high[1] - low[1])
float overlap = smallerRange > 0 ? 100 * math.max(0, math.min(high, high[1]) - math.max(low, low[1])) / smallerRange : 100

var bool active = false
var int armed = 0
var int direction = 0
var int startBar = na
var int age = 0
var int stableCount = 0
var int triggerBar = na
var float frozenATR = na
var float structure = na
var float peak = na
var float pbLow = na
var float pbHigh = na
var float trigger = na
var float depth = na
var float overlapSum = 0
var int samples = 0
var float meanOverlap = na
var string state = "WAITING FOR IMPULSE"
var string quality = "—"
var int confirmedCount = 0
var int brokenCount = 0
var int expiredCount = 0
var int cancelledCount = 0
bool started = false
bool stabilized = false
bool confirmed = false
bool broken = false
bool expired = false
bool cancelled = false

if barstate.isconfirmed
    if not active
        if armed != trend
            armed := 0
        bool permitted = trend == 1 ? side != "Short" : trend == -1 ? side != "Long" : false
        bool touch = trend == 1 ? low <= fast + bandATR * atr[1] and close < close[1] : trend == -1 ? high >= fast - bandATR * atr[1] and close > close[1] : false
        if ready and permitted and armed == trend and armed != 0 and touch
            active := true
            started := true
            direction := trend
            armed := 0
            startBar := bar_index
            age := 0
            frozenATR := atr[1]
            structure := direction == 1 ? priorLow - bufferATR * frozenATR : priorHigh + bufferATR * frozenATR
            peak := direction == 1 ? priorHigh : priorLow
            pbLow := low
            pbHigh := high
            stableCount := 0
            trigger := na
            triggerBar := na
            overlapSum := 0
            samples := 0
            state := "PULLBACK"
        else
            bool impulse = trend == 1 ? low > fast + bandATR * atr[1] and close > close[1] : trend == -1 ? high < fast - bandATR * atr[1] and close < close[1] : false
            if ready and permitted and impulse
                armed := trend
    if active
        age := bar_index - startBar
        bool newExtreme = not started and (direction == 1 ? low < pbLow : high > pbHigh)
        pbLow := math.min(pbLow, low)
        pbHigh := math.max(pbHigh, high)
        depth := math.max(0, direction == 1 ? peak - pbLow : pbHigh - peak) / frozenATR
        overlapSum += overlap
        samples += 1
        meanOverlap := overlapSum / samples
        quality := depth > maxDepth ? "TOO DEEP" : meanOverlap > maxOverlap ? "HIGH OVERLAP" : "WITHIN LIMITS"
        if newExtreme
            stableCount := 0
            trigger := na
            triggerBar := na
            state := "PULLBACK"
        // Structure first. A bar that makes a new adverse extreme cannot also confirm.
        if direction == 1 ? close < structure : close > structure
            broken := true
            active := false
            brokenCount += 1
            state := "STRUCTURE BROKEN"
        else if trend != direction
            cancelled := true
            active := false
            cancelledCount += 1
            state := "TREND LOST"
        else if not na(trigger) and bar_index > triggerBar and (direction == 1 ? close > trigger and close > fast : close < trigger and close < fast) and quality == "WITHIN LIMITS"
            confirmed := true
            active := false
            confirmedCount += 1
            state := "CONTINUATION CONFIRMED"
        else if age >= maxBars
            expired := true
            active := false
            expiredCount += 1
            state := "WINDOW ENDED"
        else if not started and not newExtreme and na(trigger)
            bool holds = direction == 1 ? low >= low[1] : high <= high[1]
            stableCount := holds ? stableCount + 1 : 0
            if stableCount >= stableBars
                trigger := direction == 1 ? stableHigh + bufferATR * frozenATR : stableLow - bufferATR * frozenATR
                triggerBar := bar_index
                stabilized := true
                state := "STABILIZED"

color mint = color.rgb(51, 194, 153)
color red = color.rgb(238, 97, 111)
color amber = color.rgb(239, 182, 73)
color blue = color.rgb(105, 158, 239)
bool drawing = active or started or confirmed or broken or expired or cancelled
color directionColor = direction == 1 ? mint : red
plot(showEMA ? fast : na, "Fast EMA", color.new(blue, 10), 2)
plot(showEMA ? slow : na, "Slow EMA", color.new(color.silver, 40), 1)
zoneTop = plot(showZone and drawing ? pbHigh : na, "Pullback high", color.new(directionColor, 85), 1, plot.style_linebr, display = display.pane)
zoneBottom = plot(showZone and drawing ? pbLow : na, "Pullback low", color.new(directionColor, 85), 1, plot.style_linebr, display = display.pane)
fill(zoneTop, zoneBottom, color.new(directionColor, 93), title = "Monitored pullback", fillgaps = false)
plot(drawing ? structure : na, "Frozen structure", color.new(red, 20), 1, plot.style_linebr, display = display.pane + display.data_window)
plot(drawing ? trigger : na, "Confirmation level", amber, 2, plot.style_linebr, display = display.pane + display.data_window)
plotshape(showMarks and started and direction == 1, "Long pullback detected", shape.circle, location.belowbar, blue, size = size.tiny, display = display.pane)
plotshape(showMarks and started and direction == -1, "Short pullback detected", shape.circle, location.abovebar, blue, size = size.tiny, display = display.pane)
plotshape(showMarks and confirmed and direction == 1, "Long continuation", shape.triangleup, location.belowbar, mint, size = size.small, display = display.pane)
plotshape(showMarks and confirmed and direction == -1, "Short continuation", shape.triangledown, location.abovebar, red, size = size.small, display = display.pane)
plotshape(showMarks and broken and direction == 1, "Long structure broken", shape.xcross, location.belowbar, red, size = size.tiny, display = display.pane)
plotshape(showMarks and broken and direction == -1, "Short structure broken", shape.xcross, location.abovebar, red, size = size.tiny, display = display.pane)
plotshape(showMarks and (expired or cancelled), "Expired / trend lost", shape.square, location.abovebar, color.gray, size = size.tiny, display = display.pane)
plot(drawing ? depth : na, "Pullback depth (frozen ATR)", display = display.data_window)
plot(drawing ? meanOverlap : na, "Mean candle overlap (%)", display = display.data_window)

f_num(float value) =>
    na(value) ? "—" : str.tostring(value, "0.00")
string panelPosition = corner == "Top left" ? position.top_left : corner == "Bottom left" ? position.bottom_left : corner == "Bottom right" ? position.bottom_right : position.top_right
var table panel = table.new(panelPosition, 2, 7, bgcolor = color.new(color.rgb(20, 27, 40), 10), border_width = 0)
f_cell(int col, int row, string txt, color ink = color.silver) =>
    table.cell(panel, col, row, txt, text_color = ink, text_size = size.small)
if barstate.islast and showPanel
    f_cell(0, 0, "PULLBACK GUARD", color.white)
    f_cell(1, 0, active ? "LAST CLOSE" : na(startBar) ? "READY" : "LAST EPISODE", color.white)
    f_cell(0, 1, "Status")
    f_cell(1, 1, state, state == "CONTINUATION CONFIRMED" ? mint : state == "STRUCTURE BROKEN" ? red : amber)
    f_cell(0, 2, "Side / age")
    f_cell(1, 2, na(startBar) ? "—" : (direction == 1 ? "LONG" : "SHORT") + " · " + str.tostring(age) + "/" + str.tostring(maxBars))
    f_cell(0, 3, "Depth / overlap")
    f_cell(1, 3, f_num(depth) + " ATR · " + f_num(meanOverlap) + "%")
    f_cell(0, 4, "Guard")
    f_cell(1, 4, quality, quality == "WITHIN LIMITS" ? mint : amber)
    f_cell(0, 5, "Structure / trigger")
    f_cell(1, 5, (na(structure) ? "—" : str.tostring(structure, format.mintick)) + " / " + (na(trigger) ? "—" : str.tostring(trigger, format.mintick)))
    f_cell(0, 6, "Confirmed / broken / other")
    f_cell(1, 6, str.tostring(confirmedCount) + " / " + str.tostring(brokenCount) + " / " + str.tostring(expiredCount + cancelledCount))

alertcondition(started, "Pullback detected", "Trend Pullback Guard: pullback detected on {{ticker}} ({{interval}}). Close confirmed.")
alertcondition(stabilized, "Pullback stabilized", "Trend Pullback Guard: stabilization established on {{ticker}}. Await a later confirmation close.")
alertcondition(confirmed and direction == 1, "Long continuation confirmed", "Trend Pullback Guard: long continuation conditions confirmed on {{ticker}} ({{interval}}).")
alertcondition(confirmed and direction == -1, "Short continuation confirmed", "Trend Pullback Guard: short continuation conditions confirmed on {{ticker}} ({{interval}}).")
alertcondition(broken, "Structure broken", "Trend Pullback Guard: frozen pullback structure broken by the close on {{ticker}}.")
alertcondition(cancelled, "Trend lost", "Trend Pullback Guard: trend filter no longer supports the monitored pullback on {{ticker}}.")
alertcondition(expired, "Observation window ended", "Trend Pullback Guard: pullback observation window ended without confirmation on {{ticker}}.")
````
