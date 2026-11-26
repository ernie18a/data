# Ultimate BB Reversal Indicator

- url: https://www.tradingview.com/script/3elgvVJg-Ultimate-BB-Reversal-Indicator/
- type: indicator
- pine_id: PUB;a2f80e70ecaf4963a13dfeb92956cb60
- version: 1.0

## Description

Ultimate BB Reversal Indicator
A Bollinger Band reversal signal tool that combines price action, RSI, and volume to identify high-probability turning points at the band extremes.
How it works:

Price must close back inside the band after being outside it, RSI must have reached an extreme (oversold below 30 or overbought above 70) within the lookback window, and volume must be at or above average — all three must align for a signal to fire.
Signals:

🟢 Green ✕ below the candle — bullish reversal at the lower band
🔴 Red ✕ above the candle — bearish reversal at the upper band

Candle coloring:

🔵 Dark blue — candle touched or pierced the upper band
🩷 Dark pink — candle touched or pierced the lower band

Inputs:

BB Length & StdDev Multiplier — controls band width
RSI Length, Overbought & Oversold levels — tune RSI sensitivity
Confirmation Bars — how many closes inside the band are required before signaling
Volume MA Length & Multiplier — sets the volume threshold
Require RSI Momentum Turn — optional stricter filter; when on, RSI must be turning back toward neutral

Notes:

## Source Code

````pine
//@version=6
indicator("Ultimate BB Reversal Indicator", overlay=true)

// ─── Inputs ───────────────────────────────────────────────────────────────────
length          = input.int(20,    "BB Length")
mult            = input.float(2.0, "StdDev Multiplier")
rsiLen          = input.int(14,    "RSI Length")
rsiOB           = input.int(70,    "RSI Overbought")
rsiOS           = input.int(30,    "RSI Oversold")
confirmBars     = input.int(1,     "Confirmation bars (close inside band)", minval=1, maxval=5)
volLen          = input.int(20,    "Volume MA length")
volMult         = input.float(1.0, "Volume multiplier (× MA)", minval=0.5, step=0.1)
requireRsiTurn  = input.bool(false, "Require RSI momentum turn?")

// ─── Core calculations ────────────────────────────────────────────────────────
basis = ta.sma(close, length)
dev   = mult * ta.stdev(close, length)
upper = basis + dev
lower = basis - dev
rsi   = ta.rsi(close, rsiLen)
volMA = ta.sma(volume, volLen)

// ─── Filter 1: Confirmed band re-entry ───────────────────────────────────────
bullConfirmed = true
bearConfirmed = true
for i = 0 to confirmBars - 1
    bullConfirmed := bullConfirmed and close[i] > lower[i]
    bearConfirmed := bearConfirmed and close[i] < upper[i]

bullWasOutside = close[confirmBars] <= lower[confirmBars]
bearWasOutside = close[confirmBars] >= upper[confirmBars]

// ─── Filter 2: RSI was at an extreme (wider lookback) ────────────────────────
bullRsiExtreme = false
bearRsiExtreme = false
for i = 0 to confirmBars + 2
    bullRsiExtreme := bullRsiExtreme or rsi[i] < rsiOS
    bearRsiExtreme := bearRsiExtreme or rsi[i] > rsiOB

// ─── Filter 3: RSI momentum (optional) ───────────────────────────────────────
bullRsiTurning = requireRsiTurn ? rsi > rsi[1] : true
bearRsiTurning = requireRsiTurn ? rsi < rsi[1] : true

// ─── Filter 4: Volume confirmation (relaxed) ─────────────────────────────────
volSpike = volume > volMult * volMA

// ─── Combine all filters ──────────────────────────────────────────────────────
bull_reversal = bullConfirmed and bullWasOutside and bullRsiExtreme and bullRsiTurning and volSpike
bear_reversal = bearConfirmed and bearWasOutside and bearRsiExtreme and bearRsiTurning and volSpike

// ─── Plots ────────────────────────────────────────────────────────────────────
plot(upper, color=color.new(color.blue, 20),   title="Upper Band",  linewidth=1)
plot(lower, color=color.new(color.blue, 20),   title="Lower Band",  linewidth=1)
plot(basis, color=color.new(color.yellow, 20), title="Basis",       linewidth=1)

band_fill = plot(upper, display=display.none)
band_base = plot(lower, display=display.none)
fill(band_fill, band_base, color=color.new(color.blue, 90))

// ─── Band-touch candle coloring ───────────────────────────────────────────────
touchUpper = high >= upper
touchLower = low  <= lower

barcolor(touchUpper ? color.new(#1a3a6b, 0) : touchLower ? color.new(#c2185b, 0) : na)

// ─── Labels (✕ marks, no box) ─────────────────────────────────────────────────
var label last_label = na

if bull_reversal or bear_reversal
    label.delete(last_label)
    last_label := label.new(
         x         = bar_index,
         y         = bull_reversal ? low : high,
         text      = "✕",
         color     = color.new(color.white, 100),
         textcolor = bull_reversal ? color.green : color.red,
         style     = bull_reversal ? label.style_label_up : label.style_label_down,
         yloc      = bull_reversal ? yloc.belowbar : yloc.abovebar,
         size      = size.normal
         )
````
