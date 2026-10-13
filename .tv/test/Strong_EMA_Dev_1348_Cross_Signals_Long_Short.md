<!-- tradingview-pine-id: PUB;3dd72852b7c840f5a792e3c72213b36d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Strong EMA Dev + 13/48 Cross Signals (Long & Short)

Source: https://www.tradingview.com/script/oTaLh6V6-Strong-EMA-Dev-13-48-Cross-Signals-Long-Short/

## Description

Strong EMA Deviation + 13/48 Cross Signals — Indicator Description
This indicator combines EMA trend structure, mean‑deviation analysis, and momentum‑based crossovers to identify high‑probability turning points in the market. It is designed for traders who want to detect moments when price becomes stretched far from its mean and then confirms direction through a fast/slow EMA cross.

Core Logic
The script calculates three EMAs:

Fast EMA (13) — captures short‑term momentum

Slow EMA (48) — defines the broader trend

Reference EMA (48) — used to measure deviation

Price deviation is expressed as a percentage distance from the reference EMA, allowing the indicator to detect when the market is overbought or oversold relative to its mean.

Deviation Filters
Using a configurable lookback window, the indicator tracks:

Maximum positive deviation → strongest overbought reading

Maximum negative deviation → strongest oversold reading

When deviation exceeds user‑defined thresholds, the indicator flags a strong deviation zone, highlighting areas where price is likely to revert.

Signal Conditions
A trade signal only triggers when deviation extremes align with EMA crossovers:

Long Signal

Market is strongly oversold

Fast EMA crosses above Slow EMA (bullish momentum shift)

Short Signal

Market is strongly overbought

Fast EMA crosses below Slow EMA (bearish momentum shift)

This dual‑filter approach reduces noise and focuses on moments where trend change + mean reversion occur simultaneously.

Visual Features
EMA Plots for trend clarity

Triangle markers for long/short signals

Optional deviation labels showing exact % deviation at each signal

Background shading to highlight strong deviation zones

These visual cues make it easy to spot exhaustion points and trend reversals in real time.

---

## Source Code

````pine
//@version=6
indicator("Strong EMA Dev + 13/48 Cross Signals (Long & Short)", overlay=true, max_labels_count=500)

// ─── Inputs ────────────────────────────────────────────────
emaFastLen        = input.int(13, "Fast EMA", minval=1)
emaSlowLen        = input.int(48, "Slow EMA", minval=1)
devLen            = input.int(20, "Deviation Lookback (candles)")
devThresholdShort = input.float(0.20, "Short Deviation % (Overbought)", step=0.05)
devThresholdLong  = input.float(0.30, "Long Deviation % (Oversold)", step=0.05)
refEmaLen         = input.int(48, "Reference EMA for deviation")

showLabels        = input.bool(true, "Show deviation value on signals")
showBg            = input.bool(true, "Highlight strong deviation zones")

// ─── Calculations ──────────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
refEma  = ta.ema(close, refEmaLen)

// % deviation from reference EMA
devPct = (close - refEma) / refEma * 100

// Directional extreme deviation in the lookback window
maxPosDev = ta.highest(devPct, devLen)   // most overbought
maxNegDev = ta.lowest(devPct, devLen)    // most oversold

strongOverbought = maxPosDev >  devThresholdShort
strongOversold   = maxNegDev < -devThresholdLong

// Crosses
bullCross = ta.crossover(emaFast, emaSlow)
bearCross = ta.crossunder(emaFast, emaSlow)

// Signals
longSignal  = strongOversold   and bullCross
shortSignal = strongOverbought and bearCross

// ─── Plots ─────────────────────────────────────────────────
plot(emaFast, "Fast EMA", color=color.new(color.yellow, 0), linewidth=2)
plot(emaSlow, "Slow EMA", color=color.new(color.purple, 0), linewidth=2)

// Long signal
plotshape(longSignal,
     title="Long Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 0),
     size=size.normal)

// Short signal
plotshape(shortSignal,
     title="Short Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.normal)

// Optional labels
if longSignal and showLabels
    label.new(bar_index, low,
         text="Long\nDev: " + str.tostring(maxNegDev, "#.##") + "%",
         style=label.style_label_up,
         color=color.new(color.green, 15),
         textcolor=color.white,
         size=size.small)

if shortSignal and showLabels
    label.new(bar_index, high,
         text="Short\nDev: " + str.tostring(maxPosDev, "#.##") + "%",
         style=label.style_label_down,
         color=color.new(color.red, 15),
         textcolor=color.white,
         size=size.small)

// Background highlight
bgcolor(showBg and (strongOverbought or strongOversold) ? color.new(color.orange, 92) : na)
````
