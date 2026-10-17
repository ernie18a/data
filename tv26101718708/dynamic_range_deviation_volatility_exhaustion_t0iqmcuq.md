# Dynamic Range Deviation & Volatility Exhaustion

- url: https://www.tradingview.com/script/T0iQMcuQ-Dynamic-Range-Deviation-Volatility-Exhaustion/
- type: indicator
- pine_id: PUB;43959c6957e249c6a7a3b7a1247621c7
- version: 1.0

## Description

The Dynamic Range Deviation indicator is a high-visibility technical analysis tool designed to identify periods of extreme market expansion and potential exhaustion. Using a Standard Deviation-based framework, it highlights candles that move significantly beyond the established mean, signaling "Overbought" or "Oversold" conditions through color-coded vertical overlays.

[b]How It Works[/b]
The script calculates a central Basis line (Mean) and applies a Standard Deviation Multiplier to create a dynamic range.

Calculation: It measures the current price against its historical volatility over a user-defined lookback period.

Red Columns: Triggered when the price closes above the upper deviation band. This indicates a bullish extension where the price is statistically "expensive," often preceding a pullback or consolidation.

Blue Columns: Triggered when the price closes below the lower deviation band. This indicates a bearish extension where the price is statistically "cheap," often signaling a potential bounce or reversal.

[b]Key Features[/b]
Modern UI: High-contrast, transparent overlays with distinct vertical borders for easy candle counting and trend duration analysis.

Adaptive Settings: Fully customizable lookback periods and multipliers to fit both Scalping (1m-15m) and Swing Trading (4h-1W) styles.

Clarity: Includes a "Range Fill" to help traders visualize the "Value Area" vs. the "Deviation Zones."

## Source Code

````pine
//@version=6
indicator("Range Deviation Bars + Vertical Border", overlay=true)

// --- Inputs ---
length      = input.int(20, "Lookback Period", minval=1)
mult        = input.float(2.0, "Multiplier", step=0.1)

// --- Calculations ---
basis = ta.sma(close, length)
dev   = ta.stdev(close, length)
upper = basis + mult * dev
lower = basis - mult * dev

isUpperDev = close > upper
isLowerDev = close < lower

// --- Visuals: Pionowe Słupki z Obramowaniem ---
// Definiujemy kolory
colorRed   = #ff5252
colorBlue  = #2195f3
borderColor = #000000 // Kolor pionowej kreski (czarny dla kontrastu)

// Używamy plotcandle, aby narysować tło o pełnej wysokości okna, 
// ale z obramowaniem (wick). To stworzy efekt pionowych sekcji.
plotcandle(isUpperDev ? 10e10 : na, isUpperDev ? 10e10 : na, isUpperDev ? -10e10 : na, isUpperDev ? -10e10 : na, 
     title="Red Deviation", color=color.new(colorRed, 60), wickcolor=color.new(borderColor, 40), bordercolor=color.new(borderColor, 40))

plotcandle(isLowerDev ? 10e10 : na, isLowerDev ? 10e10 : na, isLowerDev ? -10e10 : na, isLowerDev ? -10e10 : na, 
     title="Blue Deviation", color=color.new(colorBlue, 60), wickcolor=color.new(borderColor, 40), bordercolor=color.new(borderColor, 40))

// --- Visuals: Range Lines ---
p1 = plot(upper, "Upper Band", color=color.new(colorRed, 60))
p2 = plot(lower, "Lower Band", color=color.new(colorBlue, 60))
fill(p1, p2, color=color.new(#353535, 90))
````
