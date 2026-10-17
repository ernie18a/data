# GXG Trend Engine

- url: https://www.tradingview.com/script/VOFjU544-GXG-Trend-Engine/
- type: strategy
- pine_id: PUB;7798784c63214972bbcbf3ef4438e397
- version: 2.0

## Description

GXG Trend Engine is a price-action-based strategy designed to identify short-term trend shifts using a dynamic volatility-adjusted trailing level. Built around an adaptive ATR framework, it reacts quickly to market movements while maintaining structure during trending conditions.

The system continuously calculates a real-time trailing line that follows price using a configurable sensitivity factor and volatility window. Trade signals are generated when price crosses this adaptive level with momentum confirmation, allowing for precise entries during emerging trends.

Unlike traditional indicators, GXG focuses on market structure and volatility alignment, making it effective across multiple asset classes includi

[b]Key Features[/b]
[list]
[*]Adaptive Volatility Engine | Uses ATR-based calculations to dynamically adjust to market conditions.
[*]Real-Time Trend Detection | Identifies directional bias through price interaction with the trailing level.
[*]Momentum-Based Entries | Signals are triggered only when a crossover confirms strength.
[*]Optional Heikin Ashi Source | Smooths price data for cleaner signals in volatile markets.
[*]Visual Bias Coloring | Bars and signals reflect current bullish or bearish conditions.
[*]Strategy-Ready | Includes built-in long/short execution logic for backtesting and optimization.
[/list]

[b]Inputs[/b]
Reaction Factor – Controls sensitivity to price movement
Volatility Window – ATR period used for dynamic calculation
Use Heikin Ashi Source – Toggle alternative price smoothing

[b]How It Works[/b]

The GXG engine builds a trailing threshold based on market volatility. When price moves above or below this level and confirms with a momentum crossover, the system generates a corresponding long or short signal.

This approach helps filter noise while staying responsive to genuine directional moves.

[b]⚠️ Notes[/b]
Best suited for trending markets
May produce false signals in sideways conditions
Can be combined with higher timeframe filters for improved accuracyng crypto, forex, and indices.

## Source Code

````pine
//@version=6
strategy(
     title="GXG Trend Engine",
     shorttitle="GXG Strategy",
     overlay=true,
     pyramiding=0,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100
)

// Default set up is for 1D

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Config
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
sensFactor = input.float(3.0, title="Reaction Factor")
atrWindow  = input.int(1, title="Volatility Window", minval=1)
useHAFeed  = input.bool(false, title="Use Heikin Ashi Source")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Price source
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
haClose = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close, lookahead=barmerge.lookahead_off)
priceFeed = useHAFeed ? haClose : close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dynamic volatility band
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volatilityMeasure = ta.atr(atrWindow)
bufferDistance    = sensFactor * volatilityMeasure

var float trailLine = 0.0
prevTrail = nz(trailLine[1], 0.0)

trailLine := priceFeed > prevTrail and priceFeed[1] > prevTrail ? math.max(prevTrail, priceFeed - bufferDistance) :
             priceFeed < prevTrail and priceFeed[1] < prevTrail ? math.min(prevTrail, priceFeed + bufferDistance) :
             priceFeed > prevTrail ? priceFeed - bufferDistance : priceFeed + bufferDistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bias state
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var int marketBias = 0
marketBias := priceFeed[1] < prevTrail and priceFeed > prevTrail ? 1 :
              priceFeed[1] > prevTrail and priceFeed < prevTrail ? -1 :
              nz(marketBias[1], 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trigger logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastTrigger = ta.ema(priceFeed, 1)

bullCross = ta.crossover(fastTrigger, trailLine)
bearCross = ta.crossover(trailLine, fastTrigger)

longSignal  = priceFeed > trailLine and bullCross
shortSignal = priceFeed < trailLine and bearCross

isBullZone = priceFeed > trailLine
isBearZone = priceFeed < trailLine

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Visual identity
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
trendTint = marketBias == 1 ? color.lime : marketBias == -1 ? color.maroon : color.navy

plot(trailLine, title="GXG Adaptive Line", color=trendTint, linewidth=2, display=display.none)

plotshape(longSignal,  title="GXG Long",  text="GXG LONG",  style=shape.labelup,   location=location.belowbar, color=color.lime,   textcolor=color.white, size=size.tiny)
plotshape(shortSignal, title="GXG Exit",  text="GXG EXIT",  style=shape.labeldown, location=location.abovebar, color=color.maroon, textcolor=color.white, size=size.tiny)

barcolor(isBullZone ? color.lime : na)
barcolor(isBearZone ? color.maroon : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Strategy execution
// Long only
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if longSignal
    strategy.entry("GXG Long", strategy.long)

if shortSignal
    strategy.close("GXG Long")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longSignal, title="GXG Long", message="GXG Long")
alertcondition(shortSignal, title="GXG Exit Long", message="GXG Exit Long")
````
