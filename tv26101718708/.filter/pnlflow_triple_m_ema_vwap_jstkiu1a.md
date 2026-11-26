# PnLFlow Triple M (EMA + VWAP)

- url: https://www.tradingview.com/script/jSTKiu1a-PnLFlow-Triple-M-EMA-VWAP/
- type: indicator
- pine_id: PUB;03e19382ecf64571b082bb5fc11073d5
- version: 5.0

## Description

[b]PnLFlow Triple M (EMA + VWAP) [/b]is a precision-based price action indicator designed to highlight liquidity wicks alongside key dynamic levels for high-probability trading decisions.

This tool identifies high and low wick rejections, helping traders spot potential liquidity sweeps and reversal zones in real time. It is combined with three essential moving averages [b](EMA 14, EMA 200, EMA 400) [/b]to provide short-term momentum, mid-term trend, and long-term directional bias.

Additionally, the [b]built-in session VWAP offers a reliable institutional reference point for fair value,[/b] enhancing confluence in entries and exits.

[b]Key Features:
Automatic detection of liquidity wicks (high/low sweeps)
EMA 14 (momentum), EMA 200 & 400 (trend structure)
Session VWAP for institutional price alignment
Clean and minimal visual design for clarity
Suitable for scalping, intraday, and swing trading[/b]

This indicator is ideal for traders who follow smart money concepts, liquidity-based trading, and structured market analysis, and want a simplified yet powerful visual tool.

## Source Code

````pine
//@version=6
indicator("PnLFlow Quad M (EMA + VWAP)", overlay=true, max_lines_count=500)

// =====================================================
// INPUTS
// =====================================================

// Wick Settings
showHigh   = input.bool(true, "Show High Wick")
showLow    = input.bool(true, "Show Low Wick")

lineWidthH = input.int(3, "High Wick Width", minval=1)
lineWidthL = input.int(3, "Low Wick Width", minval=1)

colorHigh  = input.color(color.red, "High Wick Color")
colorLow   = input.color(color.lime, "Low Wick Color")

// EMA Lengths
ema14_len  = input.int(14,  "EMA 14 Length", minval=1)
ema50_len  = input.int(50,  "EMA 50 Length", minval=1)
ema100_len = input.int(100, "EMA 100 Length", minval=1)
ema200_len = input.int(200, "EMA 200 Length", minval=1)
ema400_len = input.int(400, "EMA 400 Length", minval=1)

// =====================================================
// WICK CONDITIONS
// =====================================================

highWick = high > high[1] and close < high[1]
lowWick  = low < low[1] and close > low[1]

// =====================================================
// DRAW WICK LINES
// =====================================================

if showHigh and highWick
    line.new(
         x1 = bar_index,
         y1 = high,
         x2 = bar_index,
         y2 = math.max(open, close),
         xloc = xloc.bar_index,
         color = colorHigh,
         width = lineWidthH)

if showLow and lowWick
    line.new(
         x1 = bar_index,
         y1 = low,
         x2 = bar_index,
         y2 = math.min(open, close),
         xloc = xloc.bar_index,
         color = colorLow,
         width = lineWidthL)

// =====================================================
// EMA CALCULATIONS
// =====================================================

ema14  = ta.ema(close, ema14_len)
ema50  = ta.ema(close, ema50_len)
ema100 = ta.ema(close, ema100_len)
ema200 = ta.ema(close, ema200_len)
ema400 = ta.ema(close, ema400_len)

// =====================================================
// VWAP
// =====================================================

vwapValue = ta.vwap(hlc3)

// =====================================================
// PLOTS
// =====================================================

plot(ema14,  title="EMA 14",  color=color.green,  linewidth=2)
plot(ema50,  title="EMA 50",  color=color.orange, linewidth=2)
plot(ema100, title="EMA 100", color=color.purple, linewidth=2)
plot(ema200, title="EMA 200", color=color.red,    linewidth=2)
plot(ema400, title="EMA 400", color=color.black,  linewidth=2)
plot(vwapValue, title="VWAP", color=color.blue, linewidth=2)
````
