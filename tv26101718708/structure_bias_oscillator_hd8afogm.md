# Structure Bias Oscillator

- url: https://www.tradingview.com/script/Hd8afogM-Structure-Bias-Oscillator/
- type: indicator
- pine_id: PUB;c65a6ef4c0df4e0b9ddb8237ffe2cef5
- version: 1.0

## Description

This is a rebranding of the Trend Bias Oscillator in order to add clarity to the logic and intent of this indicator.

**Structure Bias Oscillator (SBO)**

**What It Does**

The Structure Bias Oscillator tells you which side of the market has structural control — and how committed price is to that direction. It watches for moments when price breaks through a recent swing high or swing low. When that happens, it locks in a directional bias and tracks where price sits within that structure's range until the opposite break occurs. It's a bias meter, not a prediction tool. It reflects what the market has already confirmed through price action.

---

**How to Read It**

The oscillator displays as a histogram running from –100 to +100, centered on a zero line.

+50 to +100 means price is deep into bullish structure. +50 and below means bullish bias is confirmed but price hasn't pushed far into the range yet. Zero means no structural break has occurred or the market is at equilibrium. –50 and above means bearish bias is confirmed but price hasn't pressed far into the range yet. –100 to –50 means price is deep into bearish structure.

Color reinforces this — bright lime at bullish extremes fading to softer green in the mild zone, bright red at bearish extremes fading to softer red, and gray when there's no active bias.

A signal line runs over the histogram to smooth out bar-to-bar noise. When the histogram crosses above the signal line, structural bias is building to the upside. When it crosses below, bearish pressure is growing.

---

**Controls**

**Bars Left** — How many bars to the left the indicator looks when identifying a swing high or low. Higher values mean only more significant, widely-spaced pivots are recognized. Lower values make it more reactive to recent swings. Default is 20.

**Bars Right** — How many bars to the right must close before a swing is confirmed. Higher values produce cleaner, more reliable pivots but add lag. Default is 5.

**Non-Repaint Mode** — When on, signals only trigger on fully closed bars. This prevents the indicator from changing its read mid-candle, which is critical for reliable alerts and backreference. Leave this on unless you have a specific reason not to. Default is on.

**Show Signal Line** — Toggles the smoothing line on or off. Turn it off for a clean histogram-only view.

**Signal Type** — How the signal line is calculated. EMA reacts fastest to recent changes. SMA weights all bars equally. WMA gives more weight to recent bars in a linear way. RMA is the smoothest and slowest, best suited for higher timeframes. Default is EMA.

**Signal Length** — How many bars go into the signal line calculation. Shorter values keep it close to the histogram. Longer values produce a smoother, slower line that filters more noise. Default is 5.

**Signal Color and Width** — Visual only. Adjust to match your chart theme and preferred line thickness.

---

**Alerts**

Two alert conditions are built in and available directly from TradingView's alert panel.

Buy Signal fires when price breaks above the most recent confirmed swing high for the first time, shifting structure to bullish. Sell Signal fires when price breaks below the most recent confirmed swing low for the first time, shifting structure to bearish.

---

**What Makes This Indicator Unique**

Most oscillators — RSI, MACD, Stochastic, and their derivatives — are momentum tools. They measure the speed or magnitude of price movement. They don't know or care about market structure. They can read bullish while price is collapsing inside a bearish structure, and bearish while price is grinding higher inside a bullish one. You're constantly having to mentally reconcile the oscillator against the chart context yourself.

The SBO skips momentum entirely. It is built exclusively around structure — specifically, breaks of confirmed swing highs and lows. It doesn't fire until structure actually changes. Once it does, the bias is locked and held until the opposite structural event occurs. This means the oscillator and the chart are always in agreement by design, not by coincidence.

The closest existing tools are the Market Structure Oscillator by LuxAlgo and the Structural Range Oscillator on TradingView. Both incorporate structure in some form. But the LuxAlgo version blends multiple timeframes with weighted period logic, making it more of a composite trend tool than a pure structural read. The Structural Range Oscillator measures price position within a range but doesn't anchor itself to confirmed break events — it adapts continuously rather than locking in on a structural shift.

The SBO does one thing the others don't: it treats a break of structure as a state change, not a score. The bias either flipped or it didn't. And once it has, every subsequent bar is measured against the range that break defined — giving you a normalized, bounded read of how far price has moved into that structural territory. That combination of event-driven bias locking and range-normalized positioning is what separates it from every other structure-adjacent tool currently available.

It also ships with a non-repaint mode on by default, which is not a given on TradingView. Most public indicators that claim non-repainting behavior bury the logic or leave it optional and off. Here it's the default — because a structural bias tool that repaints on you mid-candle is useless for anything other than chart decoration.

---

**What This Indicator Is — and Isn't**

The SBO is a structural state indicator, not a momentum oscillator. It doesn't measure how fast price is moving — it measures what structure has committed to. Once a structural break occurs, the bias holds until the opposite break happens. With non-repaint mode on, it won't change its read mid-candle.

Use it as a bias filter alongside your existing entries and exits. Confirm you're trading in the direction of active structural bias before taking a position.

## Source Code

````pine
//@version=5
indicator("Structure Bias Oscillator", overlay=false)

// ── Inputs ────────────────────────────────────────────────────────
leftBars   = input.int(20,  "Bars Left",       minval=5,  maxval=200)
rightBars  = input.int(5,   "Bars Right",      minval=1,  maxval=100)
nonRepaint = input.bool(true, "Non-Repaint Mode")

// Signal line controls
showSignalLine = input.bool(true,    "Show Signal Line")
signalType     = input.string("EMA", "Signal Type", options=["EMA", "SMA", "WMA", "RMA"])
signalLength   = input.int(5,        "Signal Length", minval=1, maxval=50)
signalColor    = input.color(color.new(color.blue, 0), "Signal Color")
signalWidth    = input.int(1,        "Signal Line Width", minval=1, maxval=4)

// ── Pivots ────────────────────────────────────────────────────────
swingHigh = ta.pivothigh(high, leftBars, rightBars)
swingLow  = ta.pivotlow(low,  leftBars, rightBars)

var float lastHigh = na
var float lastLow  = na
var int   structure = 0

if not na(swingHigh)
    lastHigh := swingHigh
if not na(swingLow)
    lastLow := swingLow

// ── Break logic (gap-safe) ────────────────────────────────────────
confirmedBar = nonRepaint ? barstate.isconfirmed : true

bullishBreak = confirmedBar and not na(lastHigh) and close > lastHigh and close[1] <= lastHigh
bearishBreak = confirmedBar and not na(lastLow)  and close < lastLow  and close[1] >= lastLow

buySignal  = bullishBreak and structure != 1
sellSignal = bearishBreak and structure != -1

if buySignal
    structure := 1
if sellSignal
    structure := -1

// ── Normalized oscillator ─────────────────────────────────────────
range_ = lastHigh - lastLow

osc = if structure == 1 and range_ > 0
    math.min((close - lastLow)  / range_ * 100,  100)
else if structure == -1 and range_ > 0
    math.max((close - lastHigh) / range_ * 100, -100)
else
    0.0

// ── Signal line ───────────────────────────────────────────────────
signal = switch signalType
    "EMA" => ta.ema(osc, signalLength)
    "SMA" => ta.sma(osc, signalLength)
    "WMA" => ta.wma(osc, signalLength)
    "RMA" => ta.rma(osc, signalLength)

// ── Colors ────────────────────────────────────────────────────────
bullColor = osc > 50 ? color.new(color.lime,  20) : color.new(color.green, 50)
bearColor = osc < -50 ? color.new(color.red,  20) : color.new(color.red,   55)
histColor = structure == 1 ? bullColor : structure == -1 ? bearColor : color.new(color.gray, 70)

// ── Plots ─────────────────────────────────────────────────────────
plot(osc,                          title="MS Oscillator", style=plot.style_histogram, color=histColor,   linewidth=4)
plot(showSignalLine ? signal : na, title="Signal Line",                               color=signalColor, linewidth=signalWidth)

hline(   0, "Zero",     color=color.new(color.gray,  40), linestyle=hline.style_solid)
hline(  50, "+50",      color=color.new(color.green, 60), linestyle=hline.style_dashed)
hline( -50, "-50",      color=color.new(color.red,   60), linestyle=hline.style_dashed)
hline( 100, "Bull max", color=color.new(color.green, 30), linestyle=hline.style_dotted)
hline(-100, "Bear max", color=color.new(color.red,   30), linestyle=hline.style_dotted)

// ── Alerts ────────────────────────────────────────────────────────
alertcondition(buySignal,  title="BUY Signal",  message="SBO BUY signal")
alertcondition(sellSignal, title="SELL Signal", message="SBO SELL signal")
````
