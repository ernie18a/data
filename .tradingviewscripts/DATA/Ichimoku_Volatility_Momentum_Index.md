<!-- tradingview-pine-id: PUB;1850fc07451f459fa760a6856ec9b35c -->
<!-- tradingviewscripts-format: 1 -->
# Ichimoku Volatility & Momentum Index

Source: https://www.tradingview.com/script/LM6MFgIe-Ichimoku-Volatility-Momentum-Index/

## Description

Overview
The Ichimoku Volatility & Momentum Index (Kumo VMI) translates the structural breadth and internal dynamics of the classic Ichimoku Kinko Hyo system into a focused oscillator.

While traditional Ichimoku charts function as all-in-one indicators for trend, momentum, support, and resistance—where market volatility is typically gauged visually by the physical thickness (width) of the Kumo cloud—this indicator isolates and quantifies that exact relationship into an oscillator layout.

Core Mechanics
1. Cloud Width Index (Volatility)
On a standard chart, the thickness between Senkou Span A and Senkou Span B reveals how volatile or consolidated a market is. The Kumo VMI calculates this absolute distance between Span A and Span B as the Cloud Width Index (CWI):

Thin Cloud Width: Points to low volatility, tight consolidation, or market compression.

Expanding Cloud Width: Highlights building volatility, structural expansion, and potential breakout environments.

Smoothing MA: Includes a customizable moving average overlay (SMA, EMA, WMA, or RMA) to track the baseline trajectory of volatility changes over time.

2. TK Distance (Momentum Confluence)
To help confirm whether an expanding cloud width is backed by underlying directional strength, the indicator incorporates a TK Distance line measuring the separation between the Tenkan-sen and Kijun-sen. When cloud volatility increases alongside a rising TK momentum line, it provides powerful confluence that a significant directional move or breakout is underway.

3. Supplementary ATR Line
An optional Average True Range (ATR) line can be toggled on or off. This serves as a helpful secondary tool for assessing general market volatility context or assisting with practical stop-loss planning, without interfering with the primary Ichimoku volatility focus.

Key Features
Dedicated Volatility Oscillator: Converts visual cloud expansion and contraction into objective line data.

Momentum Integration: Combines cloud width with Tenkan/Kijun separation to spot high-confluence expansion phases.

Flexible Customization: Offers adjustable moving average types/lengths for smoothing, alongside an optional ATR reference line for risk management

---

## Source Code

````pine
//@version=6
indicator("Ichimoku Volatility & Momentum Index", shorttitle="Kumo VMI", overlay=false, precision=2)

// --- Inputs ---
maLength = input.int(9, "Moving Average Length", minval=1)
maType   = input.string("SMA", "Moving Average Type", options=["SMA", "EMA", "WMA", "RMA"])

// --- ATR Inputs ---
useAtr    = input.bool(true, "Enable ATR Indicator")
atrLength = input.int(14, "ATR Length", minval=1)

// --- Ichimoku Calculations ---
tenkanSen = (ta.highest(high, 9) + ta.lowest(low, 9)) / 2
kijunSen  = (ta.highest(high, 26) + ta.lowest(low, 26)) / 2
spanA     = (tenkanSen + kijunSen) / 2
spanB     = (ta.highest(high, 52) + ta.lowest(low, 52)) / 2

// CWI calculation (Cloud Volatility)
cwi = math.abs(spanA - spanB)
// TK Distance (Momentum/Divergence)
tkDist = math.abs(tenkanSen - kijunSen)

// --- Fixed ATR Calculation ---
rawAtr = ta.rma(ta.tr, atrLength)

// --- Dynamic MA Calculation for CWI ---
var float ma = na
switch maType
    "SMA" => ma := ta.sma(cwi, maLength)
    "EMA" => ma := ta.ema(cwi, maLength)
    "WMA" => ma := ta.wma(cwi, maLength)
    "RMA" => ma := ta.rma(cwi, maLength)

// --- Plotting ---
// Plot CWI and its MA
plot(cwi, color=color.new(#FF00FF, 50), linewidth=2, title="Cloudwidth Index")
plot(ma, color=color.yellow, linewidth=1, title="CWI Moving Average")

// Plot TK Distance
plot(tkDist, color=color.white, linewidth=2, title="TK Distance (Momentum)")

// Plot ATR (Conditional)
plot(useAtr ? rawAtr : na, color=color.new(#00FFFF, 30), linewidth=2, title="ATR")
````
