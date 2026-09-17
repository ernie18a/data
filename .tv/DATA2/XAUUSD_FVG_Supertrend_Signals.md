<!-- tradingview-pine-id: PUB;fc8ca1288f5c432eabcc6fd70631500a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# XAUUSD FVG Supertrend Signals

Source: https://www.tradingview.com/script/T5YZXW7p-XAUUSD-FVG-Supertrend-Signals/

## Description

XAUUSD FVG Supertrend Signals

XAUUSD FVG Supertrend Signals is a clean technical analysis indicator designed for Gold (XAUUSD), combining Supertrend, EMA 200, and Fair Value Gap (FVG) concepts to identify potential BUY and SELL opportunities.

How It Works

The indicator looks for alignment between three key market concepts:

Supertrend — identifies the current market direction and helps filter bullish and bearish conditions.
EMA 200 — provides a broader trend filter. BUY setups are favored above the EMA, while SELL setups are favored below it.
Fair Value Gap (FVG) — identifies areas of potential imbalance that may act as important reaction zones.

When the trend, price position, and FVG conditions align, the indicator generates a visual BUY or SELL signal.

Target & Stop Levels

The indicator also displays projected target and stop levels for each signal.

Default settings:

Target: $40
Stop: $15
Risk/Reward: approximately 2.67:1

These values are adjustable and should be adapted to the trader's preferred risk management and market conditions.

Best Use

The indicator is designed primarily for XAUUSD and can be used on multiple timeframes.

It is recommended to combine the signals with:

Market structure
Support and resistance
Session timing
Higher-timeframe analysis
Proper risk management

The indicator should be treated as a technical analysis and decision-support tool, not as a guarantee of future market movement.

Important Disclaimer

No indicator can predict the market with certainty. BUY and SELL signals are based on historical price calculations and technical conditions and may produce false signals, especially during sideways markets, high-impact news, and unusual volatility.

Always perform your own analysis and use appropriate risk management. Past performance does not guarantee future results.

Key Features

✓ Supertrend trend detection
✓ EMA 200 trend filter
✓ Bullish & bearish FVG detection
✓ BUY / SELL signals
✓ Projected targets
✓ Stop levels
✓ TradingView alerts
✓ Designed for XAUUSD
✓ Fully adjustable settings
✓ No automatic trade execution

---

## Source Code

````pine
//@version=6
indicator("XAUUSD FVG Supertrend Signals", overlay=true, max_boxes_count=50, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupTrend = "Trend Settings"
stFactor   = input.float(3.0, "Supertrend Factor", step=0.1, group=groupTrend)
stATR      = input.int(10, "Supertrend ATR", minval=1, group=groupTrend)
emaLength  = input.int(200, "EMA Length", minval=1, group=groupTrend)

groupFVG = "Fair Value Gap"
showFVG = input.bool(true, "Show FVG Zones", group=groupFVG)
extendFVG = input.int(15, "FVG Extension", minval=1, maxval=100, group=groupFVG)

groupSignal = "Signal Settings"
showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupSignal)
requireFVG = input.bool(true, "Require FVG Confirmation", group=groupSignal)

groupTarget = "Target Settings"
showTarget = input.bool(true, "Show Target", group=groupTarget)
targetDistance = input.float(40.0, "Target Distance ($)", minval=0.1, step=0.1, group=groupTarget)

showStop = input.bool(true, "Show Stop Level", group=groupTarget)
stopDistance = input.float(15.0, "Stop Distance ($)", minval=0.1, step=0.1, group=groupTarget)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[supertrend, direction] = ta.supertrend(stFactor, stATR)

bullTrend = direction < 0
bearTrend = direction > 0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA 200
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ema200 = ta.ema(close, emaLength)

emaBull = close > ema200
emaBear = close < ema200

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FAIR VALUE GAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bullish FVG:
// Current low is above high from 2 candles ago

bullFVG = low > high[2]

// Bearish FVG:
// Current high is below low from 2 candles ago

bearFVG = high < low[2]

// FVG levels
bullFVGTop = low
bullFVGBottom = high[2]

bearFVGTop = low[2]
bearFVGBottom = high

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG MEMORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool bullishFVGExists = false
var bool bearishFVGExists = false

if bullFVG
    bullishFVGExists := true

if bearFVG
    bearishFVGExists := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW FVG ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showFVG and bullFVG
    box.new(
         left=bar_index - 2,
         top=bullFVGTop,
         right=bar_index + extendFVG,
         bottom=bullFVGBottom,
         bgcolor=color.new(color.green, 88),
         border_color=color.new(color.green, 55))

if showFVG and bearFVG
    box.new(
         left=bar_index - 2,
         top=bearFVGTop,
         right=bar_index + extendFVG,
         bottom=bearFVGBottom,
         bgcolor=color.new(color.red, 88),
         border_color=color.new(color.red, 55))

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Fresh FVG confirmation
fvgBullConfirmation = bullFVG or bullishFVGExists
fvgBearConfirmation = bearFVG or bearishFVGExists

// BUY
buySetup =
     bullTrend and
     emaBull and
     fvgBullConfirmation and
     close > open

// SELL
sellSetup =
     bearTrend and
     emaBear and
     fvgBearConfirmation and
     close < open

// If FVG requirement is disabled
buySignal =
     buySetup and
     (requireFVG ? fvgBullConfirmation : true)

sellSignal =
     sellSetup and
     (requireFVG ? fvgBearConfirmation : true)

// Only signal on the first bar of the setup
buyTrigger = buySignal and not buySignal[1]
sellTrigger = sellSignal and not sellSignal[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     bullTrend ? supertrend : na,
     title="Bullish Supertrend",
     color=color.lime,
     linewidth=2,
     style=plot.style_linebr)

plot(
     bearTrend ? supertrend : na,
     title="Bearish Supertrend",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EMA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     ema200,
     title="EMA 200",
     color=color.orange,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY SIGNAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showSignals and buyTrigger,
     title="BUY Signal",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.black,
     text="BUY",
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL SIGNAL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showSignals and sellTrigger,
     title="SELL Signal",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     text="SELL",
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET / STOP VARIABLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float buyTarget = na
var float buyStop = na

var float sellTarget = na
var float sellStop = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY TARGET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buyTrigger
    buyTarget := close + targetDistance
    buyStop := close - stopDistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL TARGET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if sellTrigger
    sellTarget := close - targetDistance
    sellStop := close + stopDistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     showTarget ? buyTarget : na,
     title="BUY TARGET",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr)

plot(
     showTarget ? sellTarget : na,
     title="SELL TARGET",
     color=color.green,
     linewidth=2,
     style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STOP PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     showStop ? buyStop : na,
     title="BUY STOP",
     color=color.red,
     linewidth=1,
     style=plot.style_linebr)

plot(
     showStop ? sellStop : na,
     title="SELL STOP",
     color=color.red,
     linewidth=1,
     style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TARGET LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buyTrigger and showTarget
    label.new(
         bar_index,
         buyTarget,
         "BUY TARGET\n" + str.tostring(buyTarget, format.mintick),
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white)

if sellTrigger and showTarget
    label.new(
         bar_index,
         sellTarget,
         "SELL TARGET\n" + str.tostring(sellTarget, format.mintick),
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buyTrigger,
     title="XAUUSD BUY",
     message="XAUUSD BUY signal: Supertrend + EMA200 + Bullish FVG.")

alertcondition(
     sellTrigger,
     title="XAUUSD SELL",
     message="XAUUSD SELL signal: Supertrend + EMA200 + Bearish FVG.")
````
