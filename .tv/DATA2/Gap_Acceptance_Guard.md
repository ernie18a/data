<!-- tradingview-pine-id: PUB;7d7a951b4d5b4133b66860e461283028 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Gap Acceptance Guard

Source: https://www.tradingview.com/script/fywgv2jk/

## Description

A gap is visible immediately. Whether the market accepts the new price area is only revealed by what happens next.

**Gap Acceptance Guard** tracks qualifying opening gaps through a fixed observation sequence. It separates continued acceptance from loss of the gap midpoint, a confirmed close through the previous close, and an unresolved timeout. The original gap, ATR reference, event extreme and decision levels are frozen when the episode begins.

## Visual guide

- **G+ / G−** — a bullish or bearish qualifying gap entered observation.
- **Shaded zone** — the active gap between the previous close and the new open.
- **Orange line** — the acceptance boundary inside the frozen gap.
- **Gray line** — the previous close and full-fill reference.
- **Blue line** — the minimum extension required beyond the event bar.
- **A+ / A−** — acceptance was confirmed.
- **R** — price closed back through the acceptance boundary.
- **X** — price closed beyond the previous close and invalidated the gap thesis.
- **T** — the observation window ended without a terminal decision.
- **Yellow diamond** — the gap-fill line was touched intrabar while the episode remained active.

The display is intentionally chart-first. It uses no table and requires no other indicator.

## Detection

By default, the absolute difference between the current open and previous close must be at least 0.50 times ATR measured on the previous completed bar. On intraday charts, detection is limited to the first bar of each exchange day. On daily and higher charts, each completed bar can be evaluated. An optional setting can require the open to clear the entire previous candle range.

## Acceptance test

Acceptance requires all three default conditions:

1. Two consecutive closes remain beyond the midpoint of the gap in its direction.
2. Price extends at least 0.25 frozen ATR beyond the event bar’s high or low.
3. Directional progress represents at least 45% of the cumulative close-to-close path after the event.

Path efficiency penalizes back-and-forth movement. A direct continuation scores higher than a noisy move that covers the same net distance.

## Example

Assume the previous close is 100, the new open is 104, the event high is 106 and frozen ATR is 4. With a 50% acceptance boundary, the orange line is 102. With a 0.25 ATR extension requirement, price must reach 107. If two closes hold above 102, price reaches 107 and path efficiency is at least 45%, **A+** is printed. A confirmed close below 102 prints **R**; a confirmed close below 100 prints **X** and takes priority.

## Behavior and limitations

State changes and markers occur only on confirmed bars. The script uses no future bars, pivot backdating or lookahead requests. One episode is tracked at a time.

Session structure depends on the exchange and chart timeframe. Extended-hours bars, synthetic candles and markets that trade continuously can change the meaning or frequency of gaps. The indicator describes observed conditions; it does not estimate probabilities, place trades, size positions or model fees, slippage, liquidity and execution.

BotTradeLab — Human judgment, AI-assisted analysis.

---

## Source Code

````pine
//@version=6
indicator("Gap Acceptance Guard", "Gap Acceptance Guard", overlay = true, max_labels_count = 300, max_lines_count = 20, max_boxes_count = 10)

// ── Inputs
atrLen          = input.int(14, "ATR length", minval = 2)
minGapAtr       = input.float(0.50, "Minimum gap (previous ATR)", minval = 0.05, step = 0.05)
fullGapOnly     = input.bool(false, "Require gap beyond previous range")
acceptDepthPct  = input.float(50.0, "Acceptance boundary inside gap (%)", minval = 10, maxval = 90, step = 5)
holdBars        = input.int(2, "Required closes", minval = 1, maxval = 5)
extensionAtr    = input.float(0.25, "Required extension (ATR)", minval = 0, step = 0.05)
minEfficiency   = input.float(45.0, "Minimum path efficiency (%)", minval = 0, maxval = 100, step = 5)
maxBars         = input.int(8, "Observation bars", minval = 2, maxval = 30)
showZones       = input.bool(true, "Show active gap zone")
showHistory     = input.bool(true, "Show completed markers")

atr = ta.atr(atrLen)
ready = bar_index > atrLen and not na(atr[1]) and atr[1] > 0
isPeriodOpen = timeframe.isintraday ? timeframe.change("D") : true
gap = open - close[1]
gapUpRaw = ready and isPeriodOpen and gap >= atr[1] * minGapAtr
gapDnRaw = ready and isPeriodOpen and gap <= -atr[1] * minGapAtr
eventBoundary = close[1] + gap * acceptDepthPct / 100
gapUp = gapUpRaw and (not fullGapOnly or open > high[1]) and close > eventBoundary
gapDn = gapDnRaw and (not fullGapOnly or open < low[1]) and close < eventBoundary

// ── Episode state
var bool active = false
var int dir = 0
var int age = 0
var int held = 0
var float gapOpen = na
var float fillLine = na
var float acceptLine = na
var float eventExtreme = na
var float frozenAtr = na
var float originClose = na
var float path = 0.0
var bool fillTouched = false

bool startUp = false
bool startDn = false
bool acceptedUp = false
bool acceptedDn = false
bool rejected = false
bool invalidated = false
bool timedOut = false
bool fillNow = false

if barstate.isconfirmed
    if active
        age += 1
        path += math.abs(close - close[1])
        beyondAcceptance = dir == 1 ? close > acceptLine : close < acceptLine
        held := beyondAcceptance ? held + 1 : 0
        touched = dir == 1 ? low <= fillLine : high >= fillLine
        fillNow := touched and not fillTouched
        fillTouched := fillTouched or touched
        fullFailure = dir == 1 ? close < fillLine : close > fillLine
        acceptanceLost = dir == 1 ? close < acceptLine : close > acceptLine
        extensionReached = dir == 1 ? high >= eventExtreme + frozenAtr * extensionAtr : low <= eventExtreme - frozenAtr * extensionAtr
        progress = dir * (close - originClose)
        efficiency = path > 0 ? math.max(progress, 0) / path * 100 : 0.0
        qualifies = held >= holdBars and extensionReached and efficiency >= minEfficiency
        if fullFailure
            invalidated := true
            active := false
        else if acceptanceLost
            rejected := true
            active := false
        else if qualifies
            acceptedUp := dir == 1
            acceptedDn := dir == -1
            active := false
        else if age >= maxBars
            timedOut := true
            active := false
    else if gapUp or gapDn
        dir := gapUp ? 1 : -1
        active := true
        age := 0
        held := 1
        gapOpen := open
        fillLine := close[1]
        acceptLine := close[1] + gap * acceptDepthPct / 100
        eventExtreme := dir == 1 ? high : low
        frozenAtr := atr[1]
        originClose := close
        path := 0.0
        fillTouched := dir == 1 ? low <= fillLine : high >= fillLine
        startUp := dir == 1
        startDn := dir == -1

// ── Clean chart-first visuals
zoneTop = active ? math.max(gapOpen, fillLine) : na
zoneBottom = active ? math.min(gapOpen, fillLine) : na
pTop = plot(showZones ? zoneTop : na, "Active gap top", color = color.new(dir == 1 ? color.teal : color.red, 45), style = plot.style_linebr)
pBottom = plot(showZones ? zoneBottom : na, "Active gap bottom", color = color.new(dir == 1 ? color.teal : color.red, 45), style = plot.style_linebr)
fill(pTop, pBottom, color = showZones ? color.new(dir == 1 ? color.teal : color.red, 90) : na, title = "Active gap zone")
plot(active ? acceptLine : na, "Acceptance boundary", color = color.orange, linewidth = 2, style = plot.style_linebr)
plot(active ? fillLine : na, "Previous close / fill line", color = color.new(color.gray, 20), linewidth = 1, style = plot.style_linebr)
plot(active ? (dir == 1 ? eventExtreme + frozenAtr * extensionAtr : eventExtreme - frozenAtr * extensionAtr) : na, "Required extension", color = color.new(color.blue, 20), style = plot.style_linebr)

plotshape(startUp, "Bullish gap", shape.labelup, location.belowbar, color.new(color.teal, 0), text = "G+", textcolor = color.white, size = size.tiny)
plotshape(startDn, "Bearish gap", shape.labeldown, location.abovebar, color.new(color.red, 0), text = "G−", textcolor = color.white, size = size.tiny)
plotshape(showHistory and acceptedUp, "Bullish gap accepted", shape.labelup, location.belowbar, color.new(color.green, 0), text = "A+", textcolor = color.white, size = size.tiny)
plotshape(showHistory and acceptedDn, "Bearish gap accepted", shape.labeldown, location.abovebar, color.new(color.maroon, 0), text = "A−", textcolor = color.white, size = size.tiny)
plotshape(showHistory and rejected, "Acceptance lost", shape.xcross, location.abovebar, color.orange, text = "R", textcolor = color.orange, size = size.tiny)
plotshape(showHistory and invalidated, "Gap invalidated", shape.labeldown, location.abovebar, color.new(color.purple, 0), text = "X", textcolor = color.white, size = size.tiny)
plotshape(showHistory and timedOut, "Gap timed out", shape.circle, location.abovebar, color.new(color.gray, 10), text = "T", textcolor = color.white, size = size.tiny)
plotshape(showHistory and fillNow ? fillLine : na, "Gap fill touched", shape.diamond, location.absolute, color.new(color.yellow, 0), size = size.tiny)

alertcondition(startUp or startDn, "New qualifying gap", "Gap Acceptance Guard: a new qualifying gap entered observation.")
alertcondition(acceptedUp or acceptedDn, "Gap accepted", "Gap Acceptance Guard: gap acceptance confirmed.")
alertcondition(rejected or invalidated, "Gap failed", "Gap Acceptance Guard: gap acceptance failed.")
````
