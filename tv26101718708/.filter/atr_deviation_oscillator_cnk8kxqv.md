# ATR Deviation Oscillator

- url: https://www.tradingview.com/script/cNk8Kxqv-ATR-Deviation-Oscillator/
- type: indicator
- pine_id: PUB;a9038a07ec8e4e6596925007bf4f7c3b
- version: 1.0

## Description

ATR Deviation Oscillator

The ATR Deviation Oscillator is a simple ATR-based volatility, price deviation, and market momentum indicator that measures how far price has moved away from its moving average, normalized by Average True Range (ATR).

Instead of using raw price distance, it shows the deviation in ATR units, making it easier to identify price expansion, volatility, trend strength, momentum, overextension, and potential mean-reversion areas across different market conditions.

How It Works

The core calculation is:

(Price - Moving Average) / ATR

This produces a normalized oscillator centered around zero.

0 — Price is at the moving average.
Positive values — Price is above the baseline.
Negative values — Price is below the baseline.
+1 / -1 ATR — Price is approximately 1 ATR from the baseline.
+2 / -2 ATR — Price is approximately 2 ATR from the baseline.
+3 / -3 ATR — Price is approximately 3 ATR from the baseline.
ATR Deviation Levels

The 1, 2, and 3 ATR levels help visualize how extended price is relative to its current volatility.

Higher readings can indicate strong price momentum, trend expansion, volatility expansion, or overextension.

Lower readings can indicate downside momentum, trend weakness, volatility expansion, or potential oversold/mean-reversion conditions.

These levels are not fixed percentage thresholds. They automatically adapt to current market volatility through ATR.

Moving Average Options

Choose from:

SMA — Simple Moving Average
EMA — Exponential Moving Average
RMA — Relative Moving Average
WMA — Weighted Moving Average
VWMA — Volume Weighted Moving Average

This allows the oscillator to be adapted to different trading strategies, market conditions, timeframes, and instruments.

What You Can Use It For

The ATR Deviation Oscillator can help with:

ATR volatility analysis
Price deviation analysis
Trend strength
Momentum analysis
Market overextension
Mean reversion
Volatility expansion
Breakout analysis
Pullback analysis
Moving average distance
Price momentum
Trend continuation
Potential reversal zones
Overbought and oversold conditions
Market regime analysis

The indicator can be useful for Forex, Gold, Crypto, Stocks, Indices, Futures, and other liquid markets.

Important

The ATR Deviation Oscillator is a market analysis tool, not a standalone buy or sell signal. Extreme deviation does not automatically mean price will reverse. Strong trends can remain extended for long periods.

Use the oscillator together with price action, market structure, trend analysis, support and resistance, volatility, and your existing trading strategy.

## Source Code

````pine
//@version=6
indicator("ATR Deviation Oscillator", shorttitle = "ATR Dev", overlay = false, timeframe = "")

// ==========================================
// 1. INPUTS
// ==========================================
series float src  = input.source(close, "Source", group = "Baseline Settings")
string maType     = input.string("EMA", "MA Type", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = "Baseline Settings")
int maLen         = input.int(20, "MA Length", minval = 1, group = "Baseline Settings")
int atrLen        = input.int(14, "ATR Length", minval = 1, group = "ATR Settings")

// Threshold Levels
groupLevels = "ATR Threshold Levels"
float level1 = input.float(1.0, "Level 1 (ATRs)", minval = 0.1, step = 0.5, group = groupLevels)
float level2 = input.float(2.0, "Level 2 (ATRs)", minval = 0.1, step = 0.5, group = groupLevels)
float level3 = input.float(3.0, "Level 3 (ATRs)", minval = 0.1, step = 0.5, group = groupLevels)

// Color Aesthetics
groupColors  = "Style Settings"
color colorPos    = input.color(color.rgb(38, 166, 154), "Positive Deviation", group = groupColors)
color colorNeg    = input.color(color.rgb(239, 83, 80), "Negative Deviation", group = groupColors)
color colorLevels = input.color(color.rgb(120, 123, 134), "Level Lines", group = groupColors)
int fillTransp    = input.int(90, "Fill Transparency", minval = 0, maxval = 100, group = groupColors)

// ==========================================
// 2. CALCULATIONS
// ==========================================
// User-selectable Moving Average function
calcMa(series float source, int len, string type) =>
    switch type
        "SMA"  => ta.sma(source, len)
        "EMA"  => ta.ema(source, len)
        "RMA"  => ta.rma(source, len)
        "WMA"  => ta.wma(source, len)
        "VWMA" => ta.vwma(source, len)
        => ta.ema(source, len)

float maVal  = calcMa(src, maLen, maType)
float atrVal = ta.atr(atrLen)

// ATR Deviation = (Price - Baseline) / ATR
float atrDev = (atrVal != 0) ? (src - maVal) / atrVal : 0.0

// Dynamic Color
color devColor = atrDev >= 0 ? colorPos : colorNeg

// ==========================================
// 3. PLOTTING & VISUALS
// ==========================================
// Zero Reference Line
hline(0, "Zero Line", color = color.new(color.gray, 50), linestyle = hline.style_dashed)

// Histogram & Oscillator Line
plot(atrDev, "ATR Deviation Histogram", color = color.new(devColor, 30), style = plot.style_histogram, linewidth = 2)
plot(atrDev, "ATR Deviation Line", color = devColor, linewidth = 1)

// Threshold Lines (hline supports dotted/dashed styles)
hUpper1 = hline(level1, "Upper Level 1", color = color.new(colorLevels, 50), linestyle = hline.style_dotted)
hLower1 = hline(-level1, "Lower Level 1", color = color.new(colorLevels, 50), linestyle = hline.style_dotted)

hUpper2 = hline(level2, "Upper Level 2", color = colorLevels, linestyle = hline.style_solid)
hLower2 = hline(-level2, "Lower Level 2", color = colorLevels, linestyle = hline.style_solid)

hUpper3 = hline(level3, "Upper Level 3", color = color.new(colorLevels, 50), linestyle = hline.style_dashed)
hLower3 = hline(-level3, "Lower Level 3", color = color.new(colorLevels, 50), linestyle = hline.style_dashed)

// Fills between ATR Threshold Zones
fill(hUpper1, hUpper2, title = "Upper 1-2 ATR Zone", color = color.new(colorPos, fillTransp))
fill(hLower1, hLower2, title = "Lower 1-2 ATR Zone", color = color.new(colorNeg, fillTransp))
fill(hUpper2, hUpper3, title = "Upper 2-3 ATR Zone", color = color.new(colorPos, math.max(0, fillTransp - 15)))
fill(hLower2, hLower3, title = "Lower 2-3 ATR Zone", color = color.new(colorNeg, math.max(0, fillTransp - 15)))
````
