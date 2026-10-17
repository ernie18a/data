# Market Condition Oscillator [HexaTrades]

- url: https://www.tradingview.com/script/Eh9hOHSd-Market-Condition-Oscillator-HexaTrades/
- type: indicator
- pine_id: PUB;12a7aa5d9fc8473abc715a2c7276c750
- version: 1.0

## Description

Market Condition Oscillator classifies price action into three simple states: Bullish Trend, Bearish Trend, and Consolidation, and paints them as a color-coded histogram below your chart. It is built to answer one question at a glance: should I be trend-trading right now, or is the market just chopping sideways?


[b]What it shows[/b]

🟢 Green histogram above zero → confirmed bullish trend. Taller bars = stronger trend.
🔴 Red histogram below zero → confirmed bearish trend. Deeper bars = stronger trend.
⚪ Gray histogram near zero → consolidation/range (no clear trend).


[b]How it works[/b]

The indicator combines four classic, well-understood concepts so that no single signal can produce a false trend on its own:

[b]1. ADX (trend strength):[/b] measures how strongly the market is trending. Below the threshold, the market is treated as consolidation regardless of direction.

[b]2. DI+ / DI− (direction) :[/b] the Directional Movement pair decides whether strength is to the upside or downside.

[b]3. EMA position + slope (confirmation) : [/b] price must be on the correct side of the EMA and the EMA must be sloping the right way. This filters out counter-trend spikes.

[b]4. ATR & EMA-distance (range detection) :[/b] consolidation is flagged when volatility compresses or price hugs the EMA, even if ADX hasn't fully dropped yet.

A phase only changes after the condition holds for a configurable number of candles (Confirmation Bars). This is the key to removing the constant flip-flopping that plagues most trend indicators.


[b]Trend rules[/b]

✏️ Bullish = ADX above threshold and DI+ > DI− and price above EMA and EMA rising — held for N bars.

✏️Bearish = ADX above threshold and DI− > DI+ and price below EMA and EMA falling — held for N bars.

✏️Consolidation = weak ADX, or compressed ATR, or price hugging the EMA — anything that is not a confirmed trend.


[b]Features[/b]

- Bullish, bearish, and consolidation market phase detection.
- Separate oscillator panel for clean chart reading.
- Color-coded histogram.
- Optional histogram smoothing.
- Confirmation bars to reduce false flips.
- Phase label on the latest candle.
- Legend table for easy interpretation.
- Alert conditions for bullish, bearish, consolidation, and trend-flip events.
- Uses confirmed candle data only and does not use future references.


[b]How to use it[/b]

- Trend traders: only take longs while the histogram is green, shorts while it is red. Stand aside on gray.
- Mean-reversion traders: the gray phase highlights range conditions where fade/scalp setups work best.
- Filter: combine with your existing entry system and ignore signals that fight the MCO color.
- Works on any market and any timeframe. For higher timeframes, consider raising the ADX threshold and Confirmation Bars.

[b]Alerts[/b]

Five ready-to-use alert conditions:
Bullish Trend Started
Bearish Trend Started
Consolidation Started
Bullish → Bearish Shift
Bearish → Bullish Shift


This indicator is designed to help identify market conditions. It should be combined with price action, support and resistance, volume, and proper risk management. No indicator can guarantee profitable trades.

We would love to hear your suggestions. If you have ideas for new features, indicators, analytics, or improvements, please share your feedback. Your input helps guide future updates and improve the indicator for all traders.


[i]This indicator is for educational and analytical purposes only. It should not be considered financial advice. Always use proper risk management and make trading decisions based on your own analysis[/i]

## Source Code

````pine
//@version=6
indicator("HexaTrades Market Condition Oscillator", shorttitle="HexaTrades Market Condition Oscillator", overlay=false)

// ── Inputs: Trend Detection ──────────────────────────────────────────────────
diLen      = input.int(14,  "DI Length",            minval=1, group="Trend Detection")
adxSmooth  = input.int(14,  "ADX Smoothing",        minval=1, group="Trend Detection")
adxThresh  = input.float(20, "ADX Trend Threshold",  minval=0, step=0.5, group="Trend Detection",
     tooltip="ADX above this = trending. Below = consolidation. 20–25 is typical.")
emaLen     = input.int(50,  "EMA Length",           minval=1, group="Trend Detection")

// ── Inputs: Consolidation ────────────────────────────────────────────────────
atrLen     = input.int(14,  "ATR Length",           minval=1, group="Consolidation")
consolSens = input.float(0.5, "Consolidation Sensitivity", minval=0.0, maxval=2.0, step=0.1, group="Consolidation",
     tooltip="Higher = flags consolidation more easily (wider EMA-distance band + earlier ATR compression).")

// ── Inputs: Filtering ────────────────────────────────────────────────────────
confirmBars = input.int(2, "Confirmation Bars",     minval=1, group="Filtering",
     tooltip="A phase only switches after the condition is true for this many candles in a row.")
useSmooth   = input.bool(false, "Smooth Histogram",  group="Filtering")
smoothLen   = input.int(3, "Smoothing Length",       minval=1, group="Filtering")

// ── Inputs: Visuals ──────────────────────────────────────────────────────────
showLabel  = input.bool(true, "Show Phase Label",   group="Visuals")
showTable  = input.bool(true, "Show Legend Table",  group="Visuals")
tablePos   = input.string("Top Right", "Legend Position", group="Visuals",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
bullCol    = input.color(color.new(#00e676, 0), "Bullish",       group="Visuals")
bearCol    = input.color(color.new(#ff1744, 0), "Bearish",       group="Visuals")
neutCol    = input.color(color.new(#787b86, 0), "Consolidation", group="Visuals")

// ── Indicators ───────────────────────────────────────────────────────────────
[diPlus, diMinus, adx] = ta.dmi(diLen, adxSmooth)
ema  = ta.ema(close, emaLen)
atr  = ta.atr(atrLen)
atrAvg = ta.sma(atr, atrLen)

emaRising  = ema > ema[1]
emaFalling = ema < ema[1]

// ── Consolidation detection ──────────────────────────────────────────────────
emaDistSmall  = math.abs(close - ema) < atr * consolSens
atrCompressed = atr < atrAvg * (0.5 + consolSens * 0.5)
isRangeRaw    = adx < adxThresh or emaDistSmall or atrCompressed

// ── Trend detection (all confirmations required) ─────────────────────────────
isBullRaw = not isRangeRaw and diPlus > diMinus and close > ema and emaRising
isBearRaw = not isRangeRaw and diMinus > diPlus and close < ema and emaFalling
isRange   = not isBullRaw and not isBearRaw

// ── Confirmation: require the condition to persist for N candles ─────────────
var int bullStreak  = 0
var int bearStreak  = 0
var int rangeStreak = 0
bullStreak  := isBullRaw ? bullStreak[1]  + 1 : 0
bearStreak  := isBearRaw ? bearStreak[1]  + 1 : 0
rangeStreak := isRange   ? rangeStreak[1] + 1 : 0

// Phase: 1 = bullish, -1 = bearish, 0 = consolidation.
var int phase = 0
if bullStreak >= confirmBars
    phase := 1
else if bearStreak >= confirmBars
    phase := -1
else if rangeStreak >= confirmBars
    phase := 0

// ── Histogram value ──────────────────────────────────────────────────────────
histRaw      = phase == 1 ? adx : phase == -1 ? -adx : diPlus - diMinus
histSmoothed = ta.ema(histRaw, smoothLen)   // computed every bar to keep state correct
histVal      = useSmooth ? histSmoothed : histRaw
histCol      = phase == 1 ? bullCol : phase == -1 ? bearCol : neutCol

// ── Plots ────────────────────────────────────────────────────────────────────
plot(histVal, "Condition", color=histCol, style=plot.style_columns, histbase=0)
hline(0, "Zero", color=color.new(color.gray, 0), linestyle=hline.style_solid)
hline(adxThresh,  "Bull Threshold", color=color.new(#00e676, 40), linestyle=hline.style_dashed)
hline(-adxThresh, "Bear Threshold", color=color.new(#ff1744, 40), linestyle=hline.style_dashed)

// ── Phase label (drawn only on the latest candle to avoid chart lag) ─────────
phaseTxt = phase == 1 ? "BULLISH ▲" : phase == -1 ? "BEARISH ▼" : "CONSOLIDATION ─"
var label lbl = na
if barstate.islast and showLabel
    label.delete(lbl)
    lbl := label.new(bar_index, histVal, phaseTxt,
         style=label.style_label_left, color=color.new(histCol, 20),
         textcolor=color.white, size=size.small)

// ── Legend table (green = bull, red = bear, gray = consolidation) ────────────
tPos = tablePos == "Top Right" ? position.top_right : tablePos == "Top Left" ? position.top_left : tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left
var table legend = table.new(tPos, 2, 3, border_width=1, border_color=color.new(color.gray, 60))
if barstate.islast and showTable
    table.cell(legend, 0, 0, " ", bgcolor=bullCol)
    table.cell(legend, 1, 0, "Bull",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.black, 20))
    table.cell(legend, 0, 1, " ", bgcolor=bearCol)
    table.cell(legend, 1, 1, "Bear",  text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.black, 20))
    table.cell(legend, 0, 2, " ", bgcolor=neutCol)
    table.cell(legend, 1, 2, "Range", text_color=color.white, text_size=size.tiny, bgcolor=color.new(color.black, 20))

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(phase == 1  and phase[1] != 1,  "Bullish Trend Started",    "Market turned BULLISH")
alertcondition(phase == -1 and phase[1] != -1, "Bearish Trend Started",    "Market turned BEARISH")
alertcondition(phase == 0  and phase[1] != 0,  "Consolidation Started",    "Market entered CONSOLIDATION")
alertcondition(phase == -1 and phase[1] == 1,  "Bullish to Bearish Shift", "Trend flipped BULLISH → BEARISH")
alertcondition(phase == 1  and phase[1] == -1, "Bearish to Bullish Shift", "Trend flipped BEARISH → BULLISH")
````
