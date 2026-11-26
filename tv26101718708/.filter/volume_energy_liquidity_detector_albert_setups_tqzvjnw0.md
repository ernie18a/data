# Volume Energy + Liquidity Detector | Albert Setups

- url: https://www.tradingview.com/script/tQZvJNW0-Volume-Energy-Liquidity-Detector-Albert-Setups/
- type: indicator
- pine_id: PUB;4f44c4636abc416d809069eed4f28b88
- version: 1.0

## Description

[b]# Volume Energy + Liquidity Detector | Albert Setups[/b]

[b]**Trade Smarter. Read Liquidity. Identify Market Momentum.**[/b]

The **Volume Energy + Liquidity Detector** is a technical analysis indicator designed to help traders identify potential liquidity sweeps, key swing levels, and periods of increased volume activity directly on the chart.

[b] Key Features[/b]

- **Liquidity Levels:** Highlights recent swing highs and swing lows as potential liquidity reference levels.
- **Bullish Liquidity Sweep:** Detects when price moves below a previous swing low and closes back above it, potentially indicating a bullish reversal opportunity.
- **Bearish Liquidity Sweep:** Detects when price moves above a previous swing high and closes back below it, potentially indicating a bearish reversal opportunity.
- **Volume Energy Detection:** Highlights candles with volume significantly above the average, helping traders identify periods of increased market activity.
- **Visual Buy/Sell Context:** Uses clear chart labels and colors to make potential bullish and bearish setups easier to recognize.
- **Alert Conditions:** Supports alerts for bullish sweeps, bearish sweeps, and high-volume activity.

 
[b]How to Use It[/b]

Look for liquidity sweep signals near important swing levels, then confirm the setup with market structure, support and resistance, candle patterns, and the overall trend. High-volume candles can provide additional context about market participation.

**Best suited for:** Smart Money Concepts (SMC), liquidity-based trading, price action analysis, and intraday trading.

**Important Note:** This indicator identifies potential trading setups, not guaranteed reversals or profitable trades. Forex and XAUUSD feeds may use tick volume rather than centralized traded volume. Always use proper risk management and independent confirmation.

**Developed by Albert Setups | Trade with Logic, Not Emotion.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AlbertSetups


 //@version=6
indicator("Volume Energy + Liquidity Detector | Albert Setups", overlay=true, max_labels_count=200, max_lines_count=100)

// ───── SETTINGS ─────
swingLen = input.int(5, "Liquidity Swing Length", minval=2, maxval=20)
volLen = input.int(20, "Volume Average Length", minval=1)
energyMultiplier = input.float(1.5, "High Volume Multiplier", minval=1.0, step=0.1)
showLevels = input.bool(true, "Show Liquidity Levels")
showSweeps = input.bool(true, "Show Sweep Signals")
showEnergy = input.bool(true, "Highlight High Volume Candles")

// ───── VOLUME ENERGY ─────
volAverage = ta.sma(volume, volLen)
highVolume = not na(volAverage) and volume > volAverage * energyMultiplier

// Approximate candle activity, NOT true buy/sell volume
bullEnergy = highVolume and close > open
bearEnergy = highVolume and close < open

barcolor(showEnergy and bullEnergy ? color.lime : showEnergy and bearEnergy ? color.fuchsia : na)

// ───── LIQUIDITY SWING LEVELS ─────
pivotHigh = ta.pivothigh(high, swingLen, swingLen)
pivotLow = ta.pivotlow(low, swingLen, swingLen)

var float liquidityHigh = na
var float liquidityLow = na
var bool highSwept = false
var bool lowSwept = false

if not na(pivotHigh)
    liquidityHigh := pivotHigh
    highSwept := false

if not na(pivotLow)
    liquidityLow := pivotLow
    lowSwept := false

plot(showLevels ? liquidityHigh : na, "Swing High Liquidity", color=color.new(color.red, 10), linewidth=2, style=plot.style_stepline)
plot(showLevels ? liquidityLow : na, "Swing Low Liquidity", color=color.new(color.green, 10), linewidth=2, style=plot.style_stepline)

// ───── LIQUIDITY SWEEPS ─────
// Price trades beyond a level and closes back inside it
sweepHigh = not na(liquidityHigh) and high > liquidityHigh and close < liquidityHigh and not highSwept
sweepLow = not na(liquidityLow) and low < liquidityLow and close > liquidityLow and not lowSwept

if sweepHigh
    highSwept := true

if sweepLow
    lowSwept := true

// ───── SIGNALS ─────
bearSweepSignal = showSweeps and sweepHigh and close < open
bullSweepSignal = showSweeps and sweepLow and close > open

plotshape(bearSweepSignal, title="High Liquidity Sweep", text="SWEEP ↓", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.tiny)
plotshape(bullSweepSignal, title="Low Liquidity Sweep", text="SWEEP ↑", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)

// ───── HIGH VOLUME MARKERS ─────
plotshape(showEnergy and highVolume, title="High Volume", text="VOL+", style=shape.circle, location=location.bottom, color=color.orange, size=size.tiny)

// ───── ALERTS ─────
alertcondition(bullSweepSignal, title="Bullish Liquidity Sweep", message="Potential bullish liquidity sweep on {{ticker}} at {{close}}")
alertcondition(bearSweepSignal, title="Bearish Liquidity Sweep", message="Potential bearish liquidity sweep on {{ticker}} at {{close}}")
alertcondition(highVolume, title="High Volume Activity", message="Volume is above its average threshold on {{ticker}}")
````
