<!-- tradingview-pine-id: PUB;bd8c8577ce7645e7861fe7678d0e9014 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Liquidity Sweep Follow-Through Guard

Source: https://www.tradingview.com/script/amsooCqF/

## Description

A wick through an obvious high or low is often called a liquidity sweep. The useful question is what price does after the level is reclaimed.

**Liquidity Sweep Follow-Through Guard** identifies a sweep of a prior lookback extreme, requires a close back inside that reference, and then evaluates the reversal through holding, extension and path efficiency. The swept level, extreme and ATR reference are frozen when the episode begins.

## Visual guide

- **S+** — a prior low was swept and reclaimed, opening a bullish observation.
- **S−** — a prior high was swept and reclaimed, opening a bearish observation.
- **Shaded zone** — the area between the reclaimed level and the sweep extreme.
- **Orange line** — the frozen reference that must remain reclaimed.
- **Blue line** — the minimum reversal extension.
- **F+ / F−** — efficient bullish or bearish follow-through was confirmed.
- **R** — a confirmed close lost the reclaimed reference.
- **X** — a confirmed close crossed the sweep extreme and fully failed the setup.
- **T** — the observation window expired without a terminal result.

The display is intentionally compact. It has no table and requires no companion indicator.

## Sweep detection

The reference is the highest high or lowest low of the previous 20 completed bars. The current candle must exceed that level by at least 0.10 previous-bar ATR, close back inside it, and devote at least 35% of its range to the rejection wick. References exclude the current bar and are never backdated.

If one exceptional candle sweeps both sides, the candle’s closing direction resolves which episode is tracked. Only one episode can be active at a time.

## Follow-through test

The default confirmation requires:

1. Two consecutive closes remain on the reclaimed side of the frozen reference.
2. Price travels at least 0.30 frozen ATR from the sweep candle close in the reversal direction.
3. Directional progress represents at least 45% of the cumulative close-to-close path after the sweep.

Path efficiency distinguishes direct follow-through from an equally large but noisy move. Repeated back-and-forth closes add traveled path without adding the same directional progress.

## Example

Suppose the lowest low of the prior 20 bars is 100 and frozen ATR is 4. Price trades down to 99.4, then closes at 101 with a qualifying lower wick. The orange reference remains 100 and the default extension target is 102.2. If two closes hold above 100, price reaches 102.2 and efficiency is at least 45%, **F+** is printed. A later close below 100 prints **R**. A close below 99.4 prints **X** and takes priority.

## Behavior and limitations

All state changes and markers occur on confirmed bars. The script uses no future bars, pivot backdating or lookahead requests. Wicks detect the initial sweep, while failure outcomes require confirmed closes.

A sweep is a price pattern, not proof of orders, stop placement or participant intent. Thresholds behave differently across symbols and timeframes. The indicator does not predict outcomes, place trades, size positions or model fees, slippage, liquidity and execution. Standard candles are recommended for interpreting its price-based rules.

BotTradeLab — Human judgment, AI-assisted analysis.

---

## Source Code

````pine
//@version=6
indicator("Liquidity Sweep Follow-Through Guard", "Sweep Follow-Through Guard", overlay = true, max_labels_count = 300, max_lines_count = 20)

// ── Inputs
lookback        = input.int(20, "Reference lookback", minval = 5, maxval = 200)
atrLen          = input.int(14, "ATR length", minval = 2)
minSweepAtr     = input.float(0.10, "Minimum sweep depth (ATR)", minval = 0, step = 0.05)
minWickPct      = input.float(35.0, "Minimum rejection wick (%)", minval = 0, maxval = 95, step = 5)
holdBars        = input.int(2, "Required reclaimed closes", minval = 1, maxval = 5)
extensionAtr    = input.float(0.30, "Required reversal extension (ATR)", minval = 0, step = 0.05)
minEfficiency   = input.float(45.0, "Minimum path efficiency (%)", minval = 0, maxval = 100, step = 5)
maxBars         = input.int(6, "Observation bars", minval = 2, maxval = 30)
showZone        = input.bool(true, "Show active sweep zone")
showHistory     = input.bool(true, "Show completed markers")

atr = ta.atr(atrLen)
priorHigh = ta.highest(high[1], lookback)
priorLow = ta.lowest(low[1], lookback)
barRange = high - low
upperWickPct = barRange > 0 ? (high - math.max(open, close)) / barRange * 100 : 0.0
lowerWickPct = barRange > 0 ? (math.min(open, close) - low) / barRange * 100 : 0.0
ready = bar_index > math.max(lookback, atrLen) and not na(atr[1]) and atr[1] > 0

// Low sweep anticipates bullish reversal; high sweep anticipates bearish reversal.
bullSweep = ready and low <= priorLow - atr[1] * minSweepAtr and close > priorLow and lowerWickPct >= minWickPct
bearSweep = ready and high >= priorHigh + atr[1] * minSweepAtr and close < priorHigh and upperWickPct >= minWickPct

// ── Episode state
var bool active = false
var int dir = 0
var int age = 0
var int held = 0
var float reference = na
var float sweepExtreme = na
var float frozenAtr = na
var float originClose = na
var float path = 0.0

bool startBull = false
bool startBear = false
bool confirmedBull = false
bool confirmedBear = false
bool reclaimLost = false
bool sweepFailed = false
bool timedOut = false

if barstate.isconfirmed
    if active
        age += 1
        path += math.abs(close - close[1])
        reclaimed = dir == 1 ? close > reference : close < reference
        held := reclaimed ? held + 1 : 0
        fullFailure = dir == 1 ? close < sweepExtreme : close > sweepExtreme
        lost = dir == 1 ? close < reference : close > reference
        extensionReached = dir == 1 ? high >= originClose + frozenAtr * extensionAtr : low <= originClose - frozenAtr * extensionAtr
        progress = dir * (close - originClose)
        efficiency = path > 0 ? math.max(progress, 0) / path * 100 : 0.0
        qualifies = held >= holdBars and extensionReached and efficiency >= minEfficiency
        if fullFailure
            sweepFailed := true
            active := false
        else if lost
            reclaimLost := true
            active := false
        else if qualifies
            confirmedBull := dir == 1
            confirmedBear := dir == -1
            active := false
        else if age >= maxBars
            timedOut := true
            active := false
    else if bullSweep or bearSweep
        // If both sides sweep on the same unusually wide bar, prefer its closing direction.
        chooseBull = bullSweep and (not bearSweep or close >= open)
        dir := chooseBull ? 1 : -1
        active := true
        age := 0
        held := 1
        reference := dir == 1 ? priorLow : priorHigh
        sweepExtreme := dir == 1 ? low : high
        frozenAtr := atr[1]
        originClose := close
        path := 0.0
        startBull := dir == 1
        startBear := dir == -1

// ── Clean chart-first visuals
zoneA = active ? reference : na
zoneB = active ? sweepExtreme : na
pRef = plot(showZone ? zoneA : na, "Reclaimed reference", color = color.orange, linewidth = 2, style = plot.style_linebr)
pSweep = plot(showZone ? zoneB : na, "Sweep extreme", color = color.new(dir == 1 ? color.teal : color.red, 25), style = plot.style_linebr)
fill(pRef, pSweep, color = showZone ? color.new(dir == 1 ? color.teal : color.red, 90) : na, title = "Active sweep zone")
plot(active ? (dir == 1 ? originClose + frozenAtr * extensionAtr : originClose - frozenAtr * extensionAtr) : na, "Required follow-through", color = color.new(color.blue, 20), style = plot.style_linebr)

plotshape(startBull, "Bullish low sweep", shape.labelup, location.belowbar, color.new(color.teal, 0), text = "S+", textcolor = color.white, size = size.tiny)
plotshape(startBear, "Bearish high sweep", shape.labeldown, location.abovebar, color.new(color.red, 0), text = "S−", textcolor = color.white, size = size.tiny)
plotshape(showHistory and confirmedBull, "Bullish follow-through", shape.labelup, location.belowbar, color.new(color.green, 0), text = "F+", textcolor = color.white, size = size.tiny)
plotshape(showHistory and confirmedBear, "Bearish follow-through", shape.labeldown, location.abovebar, color.new(color.maroon, 0), text = "F−", textcolor = color.white, size = size.tiny)
plotshape(showHistory and reclaimLost, "Reclaim lost", shape.xcross, location.abovebar, color.orange, text = "R", textcolor = color.orange, size = size.tiny)
plotshape(showHistory and sweepFailed, "Sweep failed", shape.labeldown, location.abovebar, color.new(color.purple, 0), text = "X", textcolor = color.white, size = size.tiny)
plotshape(showHistory and timedOut, "Sweep timed out", shape.circle, location.abovebar, color.new(color.gray, 10), text = "T", textcolor = color.white, size = size.tiny)

alertcondition(startBull or startBear, "New liquidity sweep", "Sweep Follow-Through Guard: a new qualifying sweep entered observation.")
alertcondition(confirmedBull or confirmedBear, "Sweep follow-through confirmed", "Sweep Follow-Through Guard: reversal follow-through confirmed.")
alertcondition(reclaimLost or sweepFailed, "Sweep reclaim failed", "Sweep Follow-Through Guard: the reclaimed level failed.")
````
