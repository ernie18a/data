<!-- tradingview-pine-id: PUB;c803d686b60c4ba29b787f86f86ab88e -->
<!-- tradingviewscripts-format: 1 -->
# Adjusted SuperTrend

Source: https://www.tradingview.com/script/oiAAAHuQ-Adjusted-SuperTrend/

## Description

Adjusted SuperTrend | MisinkoMaster

The Adjusted SuperTrend is a refined, low-lag evolution of the traditional SuperTrend indicator. Standard SuperTrend formulas rely on classic Average True Range (ATR) calculations that treat all price ranges linearly. This often results in delayed trend shifts during explosive volatility spikes or premature whipsaws during choppy consolidation phases.

The Adjusted SuperTrend solves this issue by incorporating a specialized, smoothed True Range filter that balances extreme high-low spreads with close-to-close variations. By anchoring an exponential moving average baseline to this modified volatility metric, the indicator provides a more adaptive, reactive trailing stop line that keeps you aligned with genuine market trends while minimizing false breakout signals.

How It Works (The Core Architecture)

The indicator evaluates trend direction and trailing support/resistance through a three-stage framework:

    Linearized True Range Volatility: Rather than using standard ATR, the engine evaluates the absolute maximum and minimum true range components on each bar and averages them. This balances intra-bar high-low expansion with bar-to-bar gap volatility, creating a smoother measurement of true market variance.

    Exponential Baseline Alignment: The modified range is processed through an Exponential Moving Average (EMA) volatility lookback filter and applied as a multiplier factor around a core price EMA baseline, establishing dynamic upper and lower tracking boundaries.

    Asymmetric Trailing Regime State: When the selected price source closes cleanly above the upper boundary, a bullish trend regime is locked in, plotting the lower band as an active trailing stop. Conversely, when the price drops below the lower boundary, a bearish regime is initiated, using the upper band as trailing overhead resistance.

Key Features

    Low-Lag Volatility Smoothing: Uses a specialized True Range derivation to react faster to sudden breakout expansions while remaining resilient against minor noise.

    Synchronized Candlestick Morphing: Automatically colors on-chart price bars (green for bullish, red for bearish) to give you instant visual feedback on the active trend bias.

    Layered Diamond Breakout Markers: Highlights structural trend flip points with multi-layered diamond markers painted directly on the trailing support/resistance line.

    Status Line Volatility Tracking: Includes an integrated ATR status reading for easy monitoring of real-time market expansion directly from your chart legend.

Input Parameters & Optimization Guide

    Source: Sets the price series used for baseline calculations and band cross checks (Default: Close).

    Baseline Lookback Period: Controls the lookback window for the core EMA trend line. A lower value makes the baseline more sensitive to immediate price action, while a higher value maps macro trend direction (Default: 14).

    Volatility Lookback: Sets the length for the smoothed range calculation. Lowering this value makes the trailing bands expand and contract faster during volatility spikes (Default: 8).

    Factor: The volatility band multiplier. Adjusting this parameter changes the distance between the baseline and the outer bands. Lower values (e.g., 1.5 - 2.0) work well for tight scalping, while higher values (e.g., 2.5 - 3.0) filter out noise for swing trading (Default: 2.5).

Trading Strategies & Execution

    Trailing Trend Continuations
    Use the active line as a dynamic trailing stop-loss or trend direction filter:

    Bullish Alignment: When the green lower line is active, look for long entries on pullbacks toward the line, keeping your stop-loss placed just below the dynamic support.

    Bearish Alignment: When the red upper line is active, look for short setups on rallies toward overhead resistance, trailing your stop along the red line.

    Regime Flip Breakouts
    A structural change in market bias occurs when price invalidates the active outer boundary:

    A candle closing above the red upper band triggers a Bullish Trend Flip, marked by glowing green diamonds on the chart.

    A candle closing below the green lower band triggers a Bearish Trend Flip, marked by glowing red diamonds.

Disclaimer: Trading financial markets involves high risk. This technical script is designed as an informational analytical tool to support your rule-based mechanical execution system and does not constitute financial advice.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MisinkoMaster

//@version=6
indicator("Adjusted SuperTrend", "Adjusted SuperTrend | MisinkoMaster", overlay = true, behind_chart = false)
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Import Libraries
import TradingView/ta/13
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Get User Defined Inputs
src = input.source(close, "Source", group = "Adjusted SuperTrend | MisinkoMaster" ,
     tooltip = "Source used for calculations and crossover/under")
len = input.int(14, "Baseline Lookback Period", minval = 2, 
     group = "Adjusted SuperTrend | MisinkoMaster")
vlen = input.int(8, "Volatility Lookback", minval = 2,
     group = "Adjusted SuperTrend | MisinkoMaster")
fac = input.float(2.5, "Factor", step = 0.05, minval = 0,
     group = "Adjusted SuperTrend | MisinkoMaster",
     tooltip = "The Multiplier of volatility")
/////////////////////////////////////////////////////////////////////////////////////////////////////
//Calculations
hld = high - low
hpc = math.abs(high - close[1])
lpc = math.abs(low - close[1])

ltr = (math.max(hld, hpc, lpc)+math.min(hld, hpc, lpc))/2
atr = ta.ema(ltr, vlen)

base = ta.ema(src, len)

upper = base+atr*fac
lower = base-atr*fac

long = src > upper
short = src < lower
var trend = 0
if long and not short
    trend := 1
if short
    trend := -1
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Plotting
upSeries   = trend == 1  ? lower : na
downSeries = trend == -1 ? upper : na

a = plot(upSeries,   "Upper", color = color.rgb(19, 197, 64), style = plot.style_linebr)
b = plot(downSeries, "Lower", color = color.rgb(184, 21, 21), style = plot.style_linebr)
c = plot(src, display = display.none, editable = false)
v = plot(atr, "Status Line",color = color.yellow, display = display.status_line)
fill(a, c, color.rgb(19, 197, 64, 50))
fill(b, c, color.rgb(184, 21, 21, 50))

plotshape(trend > trend[1] ? upSeries : na, style = shape.diamond, location = location.absolute, size = size.normal, color = color.rgb(19, 197, 64, 50), display = display.pane)
plotshape(trend < trend[1] ? downSeries : na, style = shape.diamond,location = location.absolute, size = size.normal,color = color.rgb(184, 21, 21, 50), display = display.pane)
plotshape(trend > trend[1] ? upSeries : na, style = shape.diamond, location = location.absolute, size = size.small, color = color.rgb(19, 197, 64, 25), display = display.pane)
plotshape(trend < trend[1] ? downSeries : na, style = shape.diamond,location = location.absolute, size = size.small,color = color.rgb(184, 21, 21, 25), display = display.pane)
plotshape(trend > trend[1] ? upSeries : na, style = shape.diamond, location = location.absolute, size = size.tiny, color = color.rgb(19, 197, 64), display = display.pane)
plotshape(trend < trend[1] ? downSeries : na, style = shape.diamond,location = location.absolute, size = size.tiny,color = color.rgb(184, 21, 21), display = display.pane)

col = trend == 1 ? color.rgb(19, 197, 64) : trend == -1 ? color.rgb(184, 21, 21) : color.rgb(42, 42, 42)
plotcandle(open, high, low, close, color = col, wickcolor = col, bordercolor = col, display = display.pane)
````
