#  Break & Retest ORB- (JayHabbit BOB System)

- url: https://www.tradingview.com/script/WoOHoXiI-Break-Retest-ORB-JayHabbit-BOB-System/
- type: indicator
- pine_id: PUB;79f9ac98c0a14a06bf50321ee7cdd5d1
- version: 1.0

## Description

Here's a description you can use when you publish it on TradingView:

---

**JayHabbit BOB System**

The JayHabbit BOB System is a complete intraday trading indicator built around the Opening Range Breakout with a fakeout filter. Instead of chasing the first breakout, this system waits for price to break the opening range, retest it, get rejected, and confirm the trend — giving you higher probability entries with defined risk.

**What's included:**

**Opening Range** — Plots the 15-minute opening range high and low as full-session horizontal lines so you always know your key levels for the day.

**Fakeout Filter** — Automatically detects the full breakout → retest → rejection sequence before signaling an entry. No more getting trapped on the first move.

**Entry Signals** — A green triangle below the bar for longs, red triangle above for shorts. Only fires after the full sequence is confirmed.

**Retest Marker** — An orange triangle marks the exact bar where the retest begins so you can follow the setup in real time.

**Trailing Stop System** — Initial stop plots at the structural level (retest low for longs, retest high for shorts). Once price hits 1R, the stop automatically trails the 20 SMA to lock in gains while keeping you in the trend.

**Moving Averages** — 9 EMA, 10 EMA, 20 SMA, 200 SMA, and 400 SMA. All fully toggleable with customizable colors, widths, and styles.

**Full Customization** — Every element has its own toggle, color picker, and width control so you can build your chart exactly how you want it.

**Built for:** SPY, QQQ, AMZN, META, NFLX, NVDA, AAPL, TSLA, MSFT on the 2 or 5 minute chart.

---

Want me to tighten it up or make it more hype for the BOB brand?

## Source Code

````pine
//@version=5
indicator("JayHabbit BOB System", overlay=true, max_lines_count=100, max_labels_count=500)

// ─────────────────────────────────────────────
// SECTION 1: MOVING AVERAGES
// ─────────────────────────────────────────────

show9    = input.bool(true,  "Show 9 EMA",   group="Moving Averages")
color9   = input.color(color.new(#00E5FF, 0), "9 EMA Color",   group="Moving Averages")
width9   = input.int(1, "9 EMA Width", minval=1, maxval=4, group="Moving Averages")

show10   = input.bool(true,  "Show 10 EMA",  group="Moving Averages")
color10  = input.color(color.new(#FF6D00, 0), "10 EMA Color",  group="Moving Averages")
width10  = input.int(1, "10 EMA Width", minval=1, maxval=4, group="Moving Averages")

show20   = input.bool(true,  "Show 20 SMA",  group="Moving Averages")
color20  = input.color(color.new(#2196F3, 0), "20 SMA Color",  group="Moving Averages")
width20  = input.int(2, "20 SMA Width", minval=1, maxval=4, group="Moving Averages")

show200  = input.bool(true,  "Show 200 SMA", group="Moving Averages")
color200 = input.color(color.new(#000000, 0), "200 SMA Color", group="Moving Averages")
width200 = input.int(4, "200 SMA Width", minval=1, maxval=4, group="Moving Averages")

show400  = input.bool(true,  "Show 400 SMA", group="Moving Averages")
color400 = input.color(color.new(#F44336, 0), "400 SMA Color", group="Moving Averages")
width400 = input.int(2, "400 SMA Width", minval=1, maxval=4, group="Moving Averages")

sma20_val  = ta.sma(close, 20)

plot(show9   ? ta.ema(close, 9)   : na, "9 EMA",   color=color9,   linewidth=width9)
plot(show10  ? ta.ema(close, 10)  : na, "10 EMA",  color=color10,  linewidth=width10)
plot(show20  ? sma20_val          : na, "20 SMA",  color=color20,  linewidth=width20)
plot(show200 ? ta.sma(close, 200) : na, "200 SMA", color=color200, linewidth=width200)
plot(show400 ? ta.sma(close, 400) : na, "400 SMA", color=color400, linewidth=width400)

// ─────────────────────────────────────────────
// SECTION 2: ORB
// ─────────────────────────────────────────────

orbMins      = input.int(15, "ORB Duration (minutes)", minval=1, maxval=60, group="ORB Settings")
showORB      = input.bool(true, "Show ORB Levels",  group="ORB Settings")
orbHighColor = input.color(color.new(#00C853, 0),   "ORB High Color", group="ORB Settings")
orbLowColor  = input.color(color.new(#FF1744, 0),   "ORB Low Color",  group="ORB Settings")
orbLineWidth = input.int(4, "ORB Line Width", minval=1, maxval=4, group="ORB Settings")
showORBFill  = input.bool(true, "Fill ORB Zone", group="ORB Settings")

isNewDay         = ta.change(time("D")) != 0
isRegularSession = not na(time("2", "0930-1600:23456"))
h_et             = hour(time, "America/New_York")
m_et             = minute(time, "America/New_York")
minOfDay         = h_et * 60 + m_et

orbStartMin = 9 * 60 + 30
orbEndMin   = orbStartMin + orbMins
isInORB     = isRegularSession and (minOfDay >= orbStartMin) and (minOfDay < orbEndMin)

var float orbHigh = na
var float orbLow  = na
var bool  orbSet  = false

if isNewDay
    orbHigh := na
    orbLow  := na
    orbSet  := false

if isInORB
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

if not isInORB and not na(orbHigh) and not orbSet
    orbSet := true

// ORB full session lines
var line orbHighLine = na
var line orbLowLine  = na
var bool orbLabeled  = false

if isNewDay
    orbLabeled := false

if orbSet and not orbLabeled and isRegularSession
    if showORB
        if not na(orbHighLine)
            line.delete(orbHighLine)
        if not na(orbLowLine)
            line.delete(orbLowLine)
        orbHighLine := line.new(bar_index, orbHigh, bar_index + 300, orbHigh, color=orbHighColor, width=orbLineWidth, style=line.style_solid)
        orbLowLine  := line.new(bar_index, orbLow,  bar_index + 300, orbLow,  color=orbLowColor,  width=orbLineWidth, style=line.style_solid)
        label.new(bar_index, orbHigh, "ORB High", color=color.new(orbHighColor, 70), textcolor=orbHighColor, style=label.style_label_right, size=size.small)
        label.new(bar_index, orbLow,  "ORB Low",  color=color.new(orbLowColor,  70), textcolor=orbLowColor,  style=label.style_label_right, size=size.small)
    orbLabeled := true

// Dummy plots for fill
orbHighPlot = plot(isRegularSession and not na(orbHigh) ? orbHigh : na, display=display.none)
orbLowPlot  = plot(isRegularSession and not na(orbLow)  ? orbLow  : na, display=display.none)
fill(orbHighPlot, orbLowPlot, color=showORBFill ? color.new(#787B86, 90) : na, title="ORB Fill")

// ─────────────────────────────────────────────
// SECTION 3: RETEST LOGIC
// ─────────────────────────────────────────────

showSignals    = input.bool(true, "Show Entry Triangles",          group="ORB Retest Signals")
showRetestMark = input.bool(true, "Show Retest Triangle (orange)", group="ORB Retest Signals")
showSwingLevel = input.bool(true, "Show Swing Confirmation Line",  group="ORB Retest Signals")
showStopLoss   = input.bool(true, "Show Stop Loss Level",          group="ORB Retest Signals")
stopColor      = input.color(color.new(#FF9800, 0), "Stop Loss Color", group="ORB Retest Signals")

var int   bullStage       = 0
var float bullRetestLow   = na
var bool  bullRetestShown = false
var int   bullEntryBar    = na
var float bullEntryPrice  = na
var float bull1RTarget    = na
var bool  bullTrailing    = false

var int   bearStage       = 0
var float bearRetestHigh  = na
var bool  bearRetestShown = false
var int   bearEntryBar    = na
var float bearEntryPrice  = na
var float bear1RTarget    = na
var bool  bearTrailing    = false

if isNewDay
    bullStage       := 0
    bullRetestLow   := na
    bullRetestShown := false
    bullEntryBar    := na
    bullEntryPrice  := na
    bull1RTarget    := na
    bullTrailing    := false
    bearStage       := 0
    bearRetestHigh  := na
    bearRetestShown := false
    bearEntryBar    := na
    bearEntryPrice  := na
    bear1RTarget    := na
    bearTrailing    := false

if orbSet and not na(orbHigh) and not na(orbLow)

    // BULL
    if bullStage == 0
        if close > orbHigh
            bullStage       := 1
            bullRetestLow   := low
            bullRetestShown := false
    else if bullStage == 1
        bullRetestLow := math.min(nz(bullRetestLow, low), low)
        if close < orbHigh
            bullStage := 2
        if close < orbLow
            bullStage := 0
    else if bullStage == 2
        if close > orbHigh
            bullStage := 3
        if close < orbLow
            bullStage := 0

    // BEAR
    if bearStage == 0
        if close < orbLow
            bearStage       := 1
            bearRetestHigh  := high
            bearRetestShown := false
    else if bearStage == 1
        bearRetestHigh := math.max(nz(bearRetestHigh, high), high)
        if close > orbLow
            bearStage := 2
        if close > orbHigh
            bearStage := 0
    else if bearStage == 2
        if close < orbLow
            bearStage := 3
        if close > orbHigh
            bearStage := 0

bullConfirmed = orbSet and bullStage == 3 and bullStage[1] == 2
bearConfirmed = orbSet and bearStage == 3 and bearStage[1] == 2

if bullConfirmed
    bullStage      := 0
    bullEntryBar   := bar_index
    bullEntryPrice := close
    bull1RTarget   := close + (close - bullRetestLow)  // 1R = entry - stop distance
    bullTrailing   := false

if bearConfirmed
    bearStage      := 0
    bearEntryBar   := bar_index
    bearEntryPrice := close
    bear1RTarget   := close - (bearRetestHigh - close)
    bearTrailing   := false

// Entry triangles
plotshape(showSignals and bullConfirmed, title="LONG",  style=shape.triangleup,   location=location.belowbar, color=color.new(#00E676, 0), size=size.small)
plotshape(showSignals and bearConfirmed, title="SHORT", style=shape.triangledown, location=location.abovebar, color=color.new(#FF1744, 0), size=size.small)

// Retest orange triangles
bullRetestTrigger = orbSet and bullStage == 2 and bullStage[1] == 1
bearRetestTrigger = orbSet and bearStage == 2 and bearStage[1] == 1

plotshape(showRetestMark and bullRetestTrigger, title="Bull Retest", style=shape.triangledown, location=location.abovebar, color=color.new(#FF9800, 0), size=size.tiny)
plotshape(showRetestMark and bearRetestTrigger, title="Bear Retest", style=shape.triangleup,   location=location.belowbar, color=color.new(#FF9800, 0), size=size.tiny)

// ─────────────────────────────────────────────
// SECTION 4: STOP LOSS — INITIAL + TRAILING
// ─────────────────────────────────────────────

var line stopLine  = na
var label stopLbl  = na
var float currentStop = na
var bool  isLong   = false
var bool  isShort  = false

// Draw initial stop when signal fires — full session width, label on left
if showStopLoss and bullConfirmed and not na(bullRetestLow)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(stopLbl)
        label.delete(stopLbl)
    currentStop := bullRetestLow
    isLong      := true
    isShort     := false
    bullTrailing := false
    stopLine := line.new(bar_index, currentStop, bar_index + 300, currentStop, color=stopColor, width=2, style=line.style_solid)
    stopLbl  := label.new(bar_index, currentStop, "STOP", color=color.new(stopColor, 60), textcolor=stopColor, style=label.style_label_right, size=size.small)

if showStopLoss and bearConfirmed and not na(bearRetestHigh)
    if not na(stopLine)
        line.delete(stopLine)
    if not na(stopLbl)
        label.delete(stopLbl)
    currentStop := bearRetestHigh
    isShort     := true
    isLong      := false
    bearTrailing := false
    stopLine := line.new(bar_index, currentStop, bar_index + 300, currentStop, color=stopColor, width=2, style=line.style_solid)
    stopLbl  := label.new(bar_index, currentStop, "STOP", color=color.new(stopColor, 60), textcolor=stopColor, style=label.style_label_right, size=size.small)

// Trail the stop along 20 SMA after 1R is reached
if showStopLoss and isLong and not na(currentStop) and not na(bull1RTarget)
    // Activate trailing once price closes above 1R target
    if close >= bull1RTarget
        bullTrailing := true
    // Once trailing, move stop up with 20 SMA (never down)
    if bullTrailing and not na(sma20_val)
        newStop = sma20_val
        if newStop > currentStop
            currentStop := newStop
            if not na(stopLine)
                line.delete(stopLine)
            if not na(stopLbl)
                label.delete(stopLbl)
            stopLine := line.new(bar_index, currentStop, bar_index + 300, currentStop, color=color.new(#00E676, 0), width=2, style=line.style_dashed)
            stopLbl  := label.new(bar_index, currentStop, "STOP (trailing)", color=color.new(#00E676, 60), textcolor=color.new(#00E676, 0), style=label.style_label_right, size=size.small)
    // Stop hit — reset
    if close < currentStop
        isLong      := false
        bullTrailing := false
        currentStop := na

if showStopLoss and isShort and not na(currentStop) and not na(bear1RTarget)
    if close <= bear1RTarget
        bearTrailing := true
    if bearTrailing and not na(sma20_val)
        newStop = sma20_val
        if newStop < currentStop
            currentStop := newStop
            if not na(stopLine)
                line.delete(stopLine)
            if not na(stopLbl)
                label.delete(stopLbl)
            stopLine := line.new(bar_index, currentStop, bar_index + 300, currentStop, color=color.new(#FF1744, 0), width=2, style=line.style_dashed)
            stopLbl  := label.new(bar_index, currentStop, "STOP (trailing)", color=color.new(#FF1744, 60), textcolor=color.new(#FF1744, 0), style=label.style_label_right, size=size.small)
    if close > currentStop
        isShort      := false
        bearTrailing := false
        currentStop  := na

// Swing confirmation line
var line swingLine = na

if showSwingLevel and bullConfirmed and not na(bullRetestLow)
    if not na(swingLine)
        line.delete(swingLine)
    swingLine := line.new(bar_index - 3, bullRetestLow, bar_index + 30, bullRetestLow, color=color.new(#00E676, 40), style=line.style_dashed, width=1)

if showSwingLevel and bearConfirmed and not na(bearRetestHigh)
    if not na(swingLine)
        line.delete(swingLine)
    swingLine := line.new(bar_index - 3, bearRetestHigh, bar_index + 30, bearRetestHigh, color=color.new(#FF1744, 40), style=line.style_dashed, width=1)

// ─────────────────────────────────────────────
// SECTION 5: ALERTS
// ─────────────────────────────────────────────

alertcondition(bullConfirmed, title="LONG - ORB Retest Confirmed",  message="JayHabbit BOB: LONG confirmed. ORB retest rejected. {{ticker}} @ {{close}}")
alertcondition(bearConfirmed, title="SHORT - ORB Retest Confirmed", message="JayHabbit BOB: SHORT confirmed. ORB retest rejected. {{ticker}} @ {{close}}")
````
