<!-- tradingview-pine-id: PUB;4953f981e3d443949bc6365b671e20b8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Deviation Oscillator

Source: https://www.tradingview.com/script/M3eSGraj/

## Description

Description:

Overview
The EMA Deviation Oscillator is a powerful momentum and mean-reversion tool designed to measure the true "thrust" or kinetic energy of price movements. Instead of relying on traditional bounded formulas like the RSI, or lagging two-average systems like the MACD, this indicator calculates the exact percentage distance between the current price and its Exponential Moving Average (EMA).

By treating the EMA as a "center of gravity" (equilibrium), this oscillator helps traders visualize when the price is perfectly balanced, when it is accelerating with explosive momentum, and when the "rubber band" is stretched too far and is due for a pullback.

Why is it different from RSI or MACD?

Zero-Lag Calculation: Unlike MACD, which measures the difference between two historical moving averages, this oscillator measures the Live Price against a single EMA. This means it reacts instantly to price breakouts.

Unbounded Framework: RSI is trapped between 0 and 100, often staying "overbought" while the price continues to rally. The EMA Deviation Oscillator is unbounded. If a crypto asset or stock goes on a massive run, the oscillator will freely stretch to +10%, +20%, accurately showing the magnitude of the move.

Shifting Baseline: The zero line is dynamic—it is the EMA itself. This allows traders to capture profits as the baseline moves up with the trend, rather than returning to a static number.

How to Read the Oscillator:

1. The Zero Line (Equilibrium)
The "0" line represents the exact value of the EMA.

When the oscillator crosses above 0, the price has broken above the EMA (Bullish).

When it crosses below 0, the price has fallen below the EMA (Bearish).

2. Histogram Colors (Momentum)
The histogram intuitively shows the acceleration and deceleration of the trend:

Dark Green: Positive deviation is growing. The uptrend has strong thrust/momentum.

Light Green: Price is still above the EMA, but momentum is fading (early warning for a pullback).

Dark Red: Negative deviation is growing. Sellers are in control with strong downward momentum.

Light Red: Price is below the EMA, but the selling pressure is exhausting.

3. The Signal Line (Orange Line)
A smoothed Simple Moving Average (SMA) of the deviation itself. It acts as a trigger line. When the histogram crosses below the orange line in overbought territory, it’s a strong signal that momentum is shifting.

4. Overbought / Oversold Levels (Mean Reversion)
The dashed red (+3.0%) and green (-3.0%) lines represent extreme deviation zones. (Note: These are fully customizable. For Crypto, you might want to use 5% or 10%. For Forex, 0.5% or 1%). When the oscillator hits these extremes, the price is heavily stretched from its average, and a "snap-back" to the zero line is highly probable.

5. Divergences
This is one of the most effective ways to use the tool. If the price makes a Higher High, but the oscillator makes a Lower High, it indicates that the upward thrust is exhausting, often preceding a sharp reversal.

Settings:

EMA Length (13 by default): Defines your center of gravity. (Lower = more sensitive, Higher = macro trend).

Signal Line Smoothing (5 by default): Adjusts the speed of the orange trigger line.

Overbought/Oversold Levels: Customize the % threshold based on the volatility of the asset you are trading.

---

## Source Code

````pine
//@version=6
indicator("EMA Deviation Oscillator", shorttitle="EMA Dev OSC", overlay=false)

// --- Inputs ---
ema_len = input.int(13, title="EMA Length")
smooth_len = input.int(5, title="Signal Line (Smoothing)")
ob_level = input.float(3.0, title="Overbought Level (%)", step=0.5)
os_level = input.float(-3.0, title="Oversold Level (%)", step=0.5)

// --- Calculations ---
// Calculate price position relative to EMA as a percentage
ema_val = ta.ema(close, ema_len)
dev = ((close - ema_val) / ema_val) * 100

// Simple moving average of deviation to track crossovers (Signal Line)
signal = ta.sma(dev, smooth_len)

// --- Coloring Logic (Momentum) ---
// Growing positive deviation = Dark Green, Shrinking positive deviation = Light Green
// Growing negative deviation = Dark Red, Shrinking negative deviation = Light Red
hist_color = dev > 0 ? (dev > dev[1] ? color.new(#26A69A, 30) : color.new(#B2DFDB, 50)) : 
                     (dev < dev[1] ? color.new(#EF5350, 30) : color.new(#FFCDD2, 50))

// --- Plots & Lines ---
// Equilibrium Point and Levels
hline(0, title="Equilibrium (Zero Line)", color=color.new(color.gray, 50), linestyle=hline.style_solid)
hline(ob_level, title="Overbought", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(os_level, title="Oversold", color=color.new(color.green, 50), linestyle=hline.style_dashed)

// Histogram and Signal Line
plot(dev, title="Deviation Histogram", style=plot.style_histogram, color=hist_color, linewidth=3)
plot(signal, title="Signal Line", color=color.new(color.orange, 0), linewidth=2)
````
