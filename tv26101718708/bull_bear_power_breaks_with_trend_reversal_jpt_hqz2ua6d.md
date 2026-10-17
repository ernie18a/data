# Bull Bear Power Breaks with Trend Reversal [JPT]

- url: https://www.tradingview.com/script/hqZ2UA6D-Bull-Bear-Power-Breaks-with-Trend-Reversal-JPT/
- type: indicator
- pine_id: PUB;fa7ac8cfdde743258c748d7ba13d9bd3
- version: 2.0

## Description

🔷 [b]OVERVIEW[/b]

[b]Bull Bear Power Breaks with Trend Reversal [JPT] – Module 1[/b] is an original Pine Script® v6 indicator designed to identify the prevailing market trend using a combination of EMA 50, EMA 200, and Bull/Bear Power analysis. It provides traders with a clear visual representation of trend direction, buying pressure, and selling pressure, making it easier to understand market conditions before looking for breakout or reversal opportunities.

Rather than generating trading signals, Module 1 establishes the core trend framework that future modules will build upon.

🔷 [b]HOW IT WORKS[/b]
The indicator continuously evaluates price relative to two exponential moving averages while calculating Bull Power and Bear Power values.

[b]Bullish Trend[/b]

A bullish trend is identified when:
[list=1][*]EMA 50 is above EMA 200
[*]Bull Power remains positive
[*]Buyers maintain control of market momentum[/list]
During bullish conditions, the chart background changes to a light green color, providing an immediate visual indication of the dominant trend.

[b]Bearish Trend[/b]

A bearish trend is identified when:
[list=1][*]EMA 50 is below EMA 200
[*]Bear Power remains dominant
[*]Sellers control market momentum[/list]
During bearish conditions, the chart background changes to a light red color.

Trend changes are automatically labeled on the chart with BULL and BEAR markers whenever the EMA relationship changes.

🔷 [b]VISUAL FEATURES[/b]
[list][*]EMA 50 Trend Line
[*]EMA 200 Trend Line
[*]Automatic Bullish Trend Detection
[*]Automatic Bearish Trend Detection
[*]Bull Power Calculation
[*]Bear Power Calculation
[*]Smoothed Bull/Bear Power Histogram
[*]Trend Change Labels
[*]Dynamic Trend Background
[*]Professional Dashboard
[*]Customizable Inputs[/list]

🔷 [b]EMA TREND ENGINE[/b]
The built-in EMA Trend Engine uses two exponential moving averages to determine the dominant market direction.

Supported trend states include:
[list][*]Bullish Trend
[*]Bearish Trend
[*]Neutral Transition[/list]
This allows traders to quickly align their analysis with the prevailing market direction.

🔷 [b]BULL & BEAR POWER ENGINE[/b]
Bull Power is calculated from the distance between price highs and the fast EMA, while Bear Power measures the distance between price lows and the same average.

To reduce market noise, both values are smoothed before being displayed as histograms, helping traders visualize changes in buying and selling pressure more clearly.

🔷 [b]DASHBOARD[/b]
The integrated dashboard displays real-time market information, including:
[list][*]Current Trend
[*]Bull Power Value
[*]Bear Power Value
[*]EMA 50
[*]EMA 200[/list]
This provides a quick overview of the current market environment without requiring additional indicators.

🔷 [b]INPUTS[/b]
Available settings include:
[list][*]EMA Fast Length
[*]EMA Slow Length
[*]Bull/Bear Power Smoothing Length
[*]Show EMA Lines
[*]Show Trend Background
[*]Show Bull/Bear Histogram
[*]Show Dashboard[/list]

🔷 [b]COMMON WORKFLOW[/b]
A typical workflow is:
[list][*]Identify whether the market is bullish or bearish using the EMA Trend Engine.
[*]Observe Bull Power and Bear Power to evaluate buying and selling pressure.
[*]Monitor trend changes using the automatic BULL and BEAR labels.
[*]Use this information as a directional filter before considering breakout or reversal setups in [/list] future modules.

🔷 [b]MARKETS[/b]
This indicator can be used on:
[list][*]Forex
[*]Gold (XAUUSD)
[*]Cryptocurrency
[*]Stocks
[*]Indices
[*]Futures
[*]Commodities[/list]
It is compatible with multiple timeframes and different trading styles.

🔷 [b]BEST PRACTICES[/b]
Many traders combine this trend engine with additional forms of technical analysis, such as:
[list][*]Market Structure
[*]Support & Resistance
[*]Break of Structure (BOS)
[*]Change of Character (CHoCH)
[*]Fair Value Gaps (FVG)
[*]Order Blocks
[*]Volume Analysis
[*]Higher Timeframe Confirmation[/list]
These techniques are optional but may provide additional context when evaluating market conditions.

🔷 [b]UPCOMING FEATURES[/b]
Future modules are planned to include:
[list][*]Dynamic Swing High & Swing Low Detection
[*]Automatic Support & Resistance
[*]Bull Power Break Detection
[*]Bear Power Break Detection
[*]Trend Reversal Confirmation
[*]Buy & Sell Signals
[*]Entry Price Calculation
[*]Stop Loss
[*]TP1, TP2 & TP3 Auto Targets
[*]Risk/Reward Visualization
[*]Advanced Dashboard
[*]Smart Alert System[/list]

🔷 [b]DISCLAIMER[/b]
This indicator is provided as a technical analysis tool for educational and informational purposes only. It evaluates historical price data using moving averages and Bull/Bear Power calculations to help visualize market trends. It does not predict future price movements or guarantee trading performance. Always perform your own analysis, use appropriate risk management, and seek additional confirmation before making trading decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator("Bull Bear Power Breaks with Trend Reversal [JPT] - Module 1", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFastLen = input.int(50, "EMA Fast", minval=1)
emaSlowLen = input.int(200, "EMA Slow", minval=1)

bullPowerLen = input.int(5, "Bull/Bear Power EMA", minval=1)

showBG         = input.bool(true, "Trend Background")
showEMA        = input.bool(true, "Show EMA")
showHistogram  = input.bool(true, "Show Bull/Bear Histogram")
showDashboard  = input.bool(true, "Show Dashboard")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ema50 = ta.ema(close, emaFastLen)
ema200 = ta.ema(close, emaSlowLen)

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

plot(showEMA ? ema50 : na, color=color.lime, linewidth=2, title="EMA 50")
plot(showEMA ? ema200 : na, color=color.red, linewidth=2, title="EMA 200")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND BACKGROUND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgcolor(showBG ? bullTrend ? color.new(color.green,90) :
       bearTrend ? color.new(color.red,90) : na : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BULL BEAR POWER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullPower = high - ema50
bearPower = low - ema50

bullSmooth = ta.ema(bullPower, bullPowerLen)
bearSmooth = ta.ema(bearPower, bullPowerLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTOGRAM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(showHistogram ? bullSmooth : na,
     title="Bull Power",
     color=color.lime,
     style=plot.style_columns)

plot(showHistogram ? bearSmooth : na,
     title="Bear Power",
     color=color.red,
     style=plot.style_columns)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND LABEL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(bullTrend and not bullTrend[1],
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     size=size.normal,
     text="BULL")

plotshape(bearTrend and not bearTrend[1],
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     size=size.normal,
     text="BEAR")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(position.top_right,2,5)

if barstate.islast and showDashboard

    table.cell(dash,0,0,"Trend",text_color=color.white,bgcolor=color.gray)

    table.cell(dash,1,0,
         bullTrend ? "Bullish" :
         bearTrend ? "Bearish" : "Neutral",
         bgcolor=bullTrend ? color.green :
         bearTrend ? color.red : color.gray,
         text_color=color.white)

    table.cell(dash,0,1,"Bull Power")
    table.cell(dash,1,1,str.tostring(bullSmooth,format.mintick))

    table.cell(dash,0,2,"Bear Power")
    table.cell(dash,1,2,str.tostring(bearSmooth,format.mintick))

    table.cell(dash,0,3,"EMA50")
    table.cell(dash,1,3,str.tostring(ema50,format.mintick))

    table.cell(dash,0,4,"EMA200")
    table.cell(dash,1,4,str.tostring(ema200,format.mintick))
    
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MODULE 2 — TREND CONFIRMATION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Inputs
confirmBars = input.int(3, "Trend Confirmation Bars", minval=1, group="Trend Confirmation")
showTrendSignals = input.bool(true, "Show Trend Signals", group="Trend Confirmation")

// EMA Slope
ema50Slope = ema50 - ema50[1]
ema200Slope = ema200 - ema200[1]

// Price Position
priceAboveEMA50 = close > ema50
priceBelowEMA50 = close < ema50

// EMA Alignment
bullAlignment = ema50 > ema200
bearAlignment = ema50 < ema200

// EMA Slope Confirmation
bullSlope = ema50Slope > 0 and ema200Slope >= 0
bearSlope = ema50Slope < 0 and ema200Slope <= 0

// Confirmed Trend
bullTrendConfirmed =
     bullAlignment and
     bullSlope and
     ta.barssince(close < ema50) >= confirmBars

bearTrendConfirmed =
     bearAlignment and
     bearSlope and
     ta.barssince(close > ema50) >= confirmBars

// Trend Strength
trendStrength =
     bullTrendConfirmed ? "Strong Bull" :
     bearTrendConfirmed ? "Strong Bear" :
     bullAlignment ? "Bullish" :
     bearAlignment ? "Bearish" :
     "Neutral"

// Trend Labels
plotshape(
     showTrendSignals and bullTrendConfirmed and not bullTrendConfirmed[1],
     title="Bull Trend Confirmed",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BULL\nCONFIRMED",
     textcolor=color.white,
     size=size.small)

plotshape(
     showTrendSignals and bearTrendConfirmed and not bearTrendConfirmed[1],
     title="Bear Trend Confirmed",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="BEAR\nCONFIRMED",
     textcolor=color.white,
     size=size.small)

// Background Highlight
bgcolor(
     bullTrendConfirmed ? color.new(color.green, 88) :
     bearTrendConfirmed ? color.new(color.red, 88) :
     na)
````
