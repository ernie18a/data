# Three & Four Bar Reversal Pattern

- url: https://www.tradingview.com/script/9V2LrLQu-Three-Four-Bar-Reversal-Pattern/
- type: indicator
- pine_id: PUB;a21fa887e26f4e36b5405dae66988c37
- version: 3.0

## Description

Three & Four Bar Reversal Pattern identifies short-term reversal candlestick setups directly on your chart, based on a strict closing-price confirmation rather than just wick penetration — making signals more reliable for intraday and swing trading decisions.

[b]WHAT IT DETECTS[/b]

[i]3-Bar Reversal[/i]
A classic three-candle reversal:
[list]
[*]Bullish: two consecutive bearish candles followed by a bullish candle that closes above the high of the first bearish candle.
[*]Bearish: two consecutive bullish candles followed by a bearish candle that closes below the low of the first bullish candle.
[/list]
Requiring the close (not just the wick) to break the reference level filters out weaker, unconfirmed reversal attempts.

[i]4-Bar Reversal (optional)[/i]
An extended version of the pattern for setups where the reversal takes one extra candle to confirm:
[list]
[*]Two small same-direction candles, followed by a transition candle in the opposite direction, followed by a large breakout candle whose body exceeds the combined body size of the previous three candles, and whose close breaks through the high/low of the first candle.
[*]Built-in logic prevents a 4-bar signal from overlapping with an already-completed 3-bar signal on the same candles, so you don't get redundant markers on the chart.
[/list]

[b]FEATURES[/b]
[list]
[*]Independent toggles for bullish and bearish signals
[*]Customizable colors for bullish/bearish markers
[*]Optional 4-bar pattern detection, clearly distinguished from 3-bar signals with on-chart labels ("3" / "4")
[*]Configurable reference line (style: solid/dashed/dotted, adjustable width) marking the breakout level
[*]Built-in alert conditions for all four signal types (bullish/bearish, 3-bar/4-bar)
[/list]

[b]HOW TO USE[/b]
[list=1]
[*]Add the indicator to your chart.
[*]Watch for triangle markers below/above candles — these mark confirmed reversal closes.
[*]Enable "4-Bar Pattern Detection" in settings if you also want the extended 4-candle version.
[*]Set alerts on any of the four conditions to get notified in real time.
[/list]

[b]NOTES[/b]
This tool is designed to highlight potential reversal setups, not to generate standalone buy/sell signals. Always combine it with your own risk management, trend context, and confluence factors (support/resistance, volume, higher-timeframe structure, etc.). Past patterns do not guarantee future results.

## Source Code

````pine
//@version=6
indicator("Three & Four Bar Reversal Pattern", overlay=true, max_labels_count=500)

// ============================================================
// CHANGELOG
// ============================================================
// v1.0 (initial release)
//   - 3-Bar Reversal pattern detection (bullish & bearish)
//   - Reference line marking the breakout level
//
// v1.1 (current)
//   - Reference line split into breakout segment + extended
//     segment (default 24 bars, adjustable), each with its own
//     style/width; extended segment auto-stops when price
//     touches the level again or max length is reached
// ============================================================

// ============================================================
// GROUP: GENERAL
// ============================================================
grpGeneral    = "General"
showBullish   = input.bool(true, "Show Bullish Reversal", group=grpGeneral)
showBearish   = input.bool(true, "Show Bearish Reversal", group=grpGeneral)
colorBullish  = input.color(color.new(color.lime, 0), "Bullish Signal Color", group=grpGeneral)
colorBearish  = input.color(color.new(color.red, 0), "Bearish Signal Color", group=grpGeneral)

// ============================================================
// GROUP: 4-BAR PATTERN
// ============================================================
grp4Bar     = "4-Bar Pattern"
show4Bar    = input.bool(false, "Enable 4-Bar Pattern Detection", group=grp4Bar,
     tooltip="When enabled, the indicator also detects the 4-candle reversal pattern (2 small same-direction candles + 1 transition candle + 1 large breakout candle).")

// ============================================================
// GROUP: REFERENCE LINE
// ============================================================
grpLine       = "Reference Line"
showRefLine   = input.bool(true, "Show Reference Line", group=grpLine)
breakoutLineStyleInput = input.string("Solid", "Breakout Line Style", options=["Solid", "Dashed", "Dotted"], group=grpLine)
breakoutLineWidth = input.int(2, "Breakout Line Width", minval=1, maxval=5, group=grpLine)

extendRefLine = input.bool(true, "Extend Reference Line", group=grpLine,
     tooltip="Projects the breakout level forward as a line you can use for placing limit orders. The line stops extending once price touches the level again, or once it reaches the Extend Length.")
extendLength  = input.int(24, "Extend Length (bars)", minval=1, maxval=500, group=grpLine)
extendLineStyleInput = input.string("Dashed", "Extended Line Style", options=["Solid", "Dashed", "Dotted"], group=grpLine)
extendLineWidth = input.int(1, "Extended Line Width", minval=1, maxval=5, group=grpLine)

breakoutLineStyle = breakoutLineStyleInput == "Solid" ? line.style_solid : breakoutLineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted
extendLineStyle = extendLineStyleInput == "Solid" ? line.style_solid : extendLineStyleInput == "Dashed" ? line.style_dashed : line.style_dotted

// ============================================================
// HELPER
// ============================================================
isBearish(idx) => close[idx] < open[idx]
isBullish(idx) => close[idx] > open[idx]
body(idx) => math.abs(close[idx] - open[idx])

// ============================================================
// RULE: 3-BAR PATTERN
// Bar2 (2 bars ago) & Bar1 (1 bar ago) same color, Bar0 (current)
// opposite color and closing breaks through Bar2's high/low
// ============================================================
bullish3Bar = showBullish and isBearish(2) and isBearish(1) and isBullish(0) and close > high[2]
bearish3Bar = showBearish and isBullish(2) and isBullish(1) and isBearish(0) and close < low[2]

// ============================================================
// RULE: 4-BAR PATTERN
// Bar3 (3 bars ago) & Bar2 (2 bars ago) same color (small candles),
// Bar1 (1 bar ago) starts opposite color (transition candle),
// Bar0 (current) same color as Bar1, its body > total body of
// (Bar3+Bar2+Bar1), and closing breaks through Bar3's high/low.
//
// Extra guard: the transition candle (Bar1) must NOT already have
// broken through Bar3's high/low on its own — if it did, that
// candle is already a valid, independent 3-bar signal, and Bar0
// would just be an extension of it rather than a genuine, separate
// 4-bar formation. This keeps 3-bar and 4-bar signals from
// overlapping on the same small candles.
// ============================================================
bullish4Bar = show4Bar and showBullish and isBearish(3) and isBearish(2) and isBullish(1) and isBullish(0) and
     close[1] <= high[3] and
     body(0) > (body(3) + body(2) + body(1)) and close > high[3]

bearish4Bar = show4Bar and showBearish and isBullish(3) and isBullish(2) and isBearish(1) and isBearish(0) and
     close[1] >= low[3] and
     body(0) > (body(3) + body(2) + body(1)) and close < low[3]

// ============================================================
// PLOT SIGNAL: 3-BAR
// Label "3" is now always shown, regardless of the 4-Bar toggle.
// ============================================================
plotshape(bullish3Bar, title="Bullish 3-Bar Reversal",
     style=shape.triangleup, location=location.belowbar, color=colorBullish, size=size.small,
     text="3", textcolor=colorBullish)

plotshape(bearish3Bar, title="Bearish 3-Bar Reversal",
     style=shape.triangledown, location=location.abovebar, color=colorBearish, size=size.small,
     text="3", textcolor=colorBearish)

// ============================================================
// PLOT SIGNAL: 4-BAR
// ============================================================
plotshape(bullish4Bar, title="Bullish 4-Bar Reversal",
     style=shape.triangleup, location=location.belowbar, color=colorBullish, size=size.small,
     text="4", textcolor=colorBullish)

plotshape(bearish4Bar, title="Bearish 4-Bar Reversal",
     style=shape.triangledown, location=location.abovebar, color=colorBearish, size=size.small,
     text="4", textcolor=colorBearish)

// ============================================================
// REFERENCE LINE STATE (persists across bars)
// Tracks active extended lines so they can keep growing bar by
// bar until price touches the level again, or Extend Length is
// reached — whichever comes first.
// ============================================================
var array<line>  extLines    = array.new<line>()
var array<float> extLevels   = array.new<float>()
var array<int>   extStartBar = array.new<int>()

// ============================================================
// REFERENCE LINE — creation on new signals
// ============================================================
drawRefLine(startBar, level, sigColor) =>
    if showRefLine
        line.new(startBar, level, bar_index, level,
             color=color.new(sigColor, 40), style=breakoutLineStyle, width=breakoutLineWidth)
    if extendRefLine
        newLine = line.new(bar_index, level, bar_index, level,
             color=color.new(sigColor, 40), style=extendLineStyle, width=extendLineWidth)
        array.push(extLines, newLine)
        array.push(extLevels, level)
        array.push(extStartBar, bar_index)

if bullish3Bar
    drawRefLine(bar_index[2], high[2], colorBullish)

if bearish3Bar
    drawRefLine(bar_index[2], low[2], colorBearish)

if bullish4Bar
    drawRefLine(bar_index[3], high[3], colorBullish)

if bearish4Bar
    drawRefLine(bar_index[3], low[3], colorBearish)

// ============================================================
// REFERENCE LINE — grow / invalidate extended lines every bar
// ============================================================
if array.size(extLines) > 0
    for i = array.size(extLines) - 1 to 0
        ln       = array.get(extLines, i)
        lvl      = array.get(extLevels, i)
        startB   = array.get(extStartBar, i)
        touched  = bar_index > startB and low <= lvl and high >= lvl
        maxLenHit = (bar_index - startB) >= extendLength
        line.set_x2(ln, bar_index)
        if touched or maxLenHit
            array.remove(extLines, i)
            array.remove(extLevels, i)
            array.remove(extStartBar, i)

// ============================================================
// ALERT
// ============================================================
alertcondition(bullish3Bar, title="Bullish 3-Bar Reversal", message="Bullish Three Bar Reversal detected")
alertcondition(bearish3Bar, title="Bearish 3-Bar Reversal", message="Bearish Three Bar Reversal detected")
alertcondition(bullish4Bar, title="Bullish 4-Bar Reversal", message="Bullish Four Bar Reversal detected")
alertcondition(bearish4Bar, title="Bearish 4-Bar Reversal", message="Bearish Four Bar Reversal detected")
````
