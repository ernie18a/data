# Volume Divergence Scanner

- url: https://www.tradingview.com/script/PM4Iopoz-Volume-Divergence-Scanner/
- type: indicator
- pine_id: PUB;bb6abf5b8a014dd2aa2a3d73c34ff319
- version: 2.0

## Description

[b]Overview[/b]
The indicator combines two independent signal types: Volume Spike (abnormal volume with RSI confirmation) and Divergence (RSI divergence near price extremes). Both must align within a time window to produce a BUY or SELL signal.

[b]Settings[/b]
[i]General[/i]

Min Bars Between BUY - Minimum bars between any two BUY signals
Min Bars Between SELL - Minimum bars between any two SELL signals

[i]Volume Spike[/i]

Enable Volume Spike Signals - Toggle the volume spike component on/off
RSI Length - Period for RSI calculation
Volume MA Length - Short-term volume moving average period
Volume MA Long Length - Long-term volume moving average period (baseline for spike detection)
Buy Multiplier - Volume must exceed long MA by this factor to trigger a buy spike
Sell Multiplier - Volume must exceed long MA by this factor to trigger a sell spike
RSI Buy Level - RSI must be below this level for a buy spike to fire
RSI Sell Level - RSI must be above this level for a sell spike to fire
Min Bars Between BUY - Minimum bars between volume spike buy signals
Min Bars Between SELL - Minimum bars between volume spike sell signals

[i]Divergence[/i]

Enable Divergence - Toggle the divergence component on/off
Lookback Bars - Window for detecting local price and RSI extremes
RSI Buy Level - RSI must be below this level for a divergence buy
RSI Sell Level - RSI must be above this level for a divergence sell
Buy Proximity to Low - Price must be within this multiplier of the local low (e.g. 1.02 = within 2%)
Sell Proximity to High - Price must be within this multiplier of the local high (e.g. 0.98 = within 2%)
Min Bars Between BUY - Minimum bars between divergence buy signals
Min Bars Between SELL - Minimum bars between divergence sell signals
VOL+D Confirmation Window - Maximum bars allowed between a Volume Spike and Divergence signal for them to confirm each other

[i]Alerts[/i]

Alert: BUY - Enable Trading View alert on BUY signal
Alert: SELL - Enable TradingView alert on SELL signal

[b]Signal Logic[/b]
When both components are enabled a BUY fires when either:
[list]
[*]Volume Spike BUY occurred and a Divergence BUY happened within the last confirmWindow bars
[*]Divergence BUY occurred and a Volume Spike BUY happened within the last confirmWindow bars
[/list]

A SELL fires by the same logic in reverse.
[list]
[*]When only Volume Spike is enabled, signals fire on volume spikes alone, without divergence confirmation.
[*]When only Divergence is enabled, signals fire on RSI divergence alone, without volume confirmation.
[/list]

[b]Tuning Tips[/b]
Too few signals:
[list]
[*]Increase VOL+D Confirmation Window
[*]Lower Buy Multiplier / Sell Multiplier
[*]Widen Buy Proximity to Low (e.g. 1.05) and Sell Proximity to High (e.g. 0.95)
[*]Disable one component to see which fires more frequently
[/list]

Too many signals:
[list]
[*]Increase Min Bars Between BUY/SELL
[*]Raise Buy Multiplier / Sell Multiplier
[*]Tighten Buy Proximity to Low (e.g. 1.01) and Sell Proximity to High (e.g. 0.99)
[*]Decrease VOL+D Confirmation Window
[/list]

Adapting to different assets or timeframes:
[list]
[*]Higher timeframes (4h, 1D) generally need higher multipliers and longer MA periods
[*]More volatile assets may need looser RSI levels and proximity values
[*]Start with default settings and adjust one parameter at a time
[/list]

## Source Code

````pine
//@version=6
indicator("Volume Divergence Scanner", overlay=true)

// === VOLUME SPIKE ===
enableVol           = input.bool(true,  "Enable Volume Spike Signals", group="Volume Spike")
volMultBuy          = input.float(6.0,  "Buy Spike Threshold",         group="Volume Spike", minval=0.1, step=0.1)
volMultSell         = input.float(6.0,  "Sell Spike Threshold",        group="Volume Spike", minval=0.1, step=0.1)
volRsiBuy           = input.int(32,     "RSI Buy Level",               group="Volume Spike")
volRsiSell          = input.int(63,     "RSI Sell Level",              group="Volume Spike")
volumeSignalSpacing = input.int(3,      "Volume Signal Spacing",       group="Volume Spike", minval=0)

// === DIVERGENCE ===
enableDiv               = input.bool(true,  "Enable Divergence",          group="Divergence")
divergenceLookback      = input.int(5,      "Lookback Bars",               group="Divergence", minval=1)
divergenceRsiBuy        = input.int(30,     "RSI Buy Level",               group="Divergence")
divergenceRsiSell       = input.int(65,     "RSI Sell Level",              group="Divergence")
buyLowDistance          = input.float(2.0,  "Buy Low Distance",            group="Divergence", minval=0, step=0.1)
sellHighDistance        = input.float(2.0,  "Sell High Distance",          group="Divergence", minval=0, step=0.1)
divergenceSignalSpacing = input.int(3,      "Divergence Signal Spacing",   group="Divergence", minval=0)

// === FINE TUNING ===
rsiLength        = input.int(18,  "RSI Length",                group="Fine Tuning", minval=1)
volLength        = input.int(50,  "Volume MA Length",          group="Fine Tuning", minval=1)
volLengthLong    = input.int(200, "Volume MA Long Length",     group="Fine Tuning", minval=1)
confirmWindow    = input.int(3,   "Confirmation Window",       group="Fine Tuning", minval=0)
overallSpacing   = input.int(12,  "Overall Signal Spacing",    group="Fine Tuning", minval=0)

// === ALERTS ===
alertBuy  = input.bool(true, "Alert: BUY",  group="Alerts")
alertSell = input.bool(true, "Alert: SELL", group="Alerts")

// === INDICATORS ===
rsi = ta.ema(ta.rsi(close, rsiLength), 3)

volMA     = ta.sma(volume, volLength)
volMALong = ta.sma(volume, volLengthLong)

// === VOLUME SPIKE CONDITIONS ===
volBuyCondition =
     enableVol and
     volume > volMALong * volMultBuy and
     rsi < volRsiBuy and
     (volume[1] > volMA or volume[2] > volMA)

volSellCondition =
     enableVol and
     volume > volMALong * volMultSell and
     rsi > volRsiSell

// === DIVERGENCE CONDITIONS ===
// User enters distance as percentage.
// Example: 2.0 = price can be up to 2% away from the local extreme.
buyLowMultiplier   = 1 + buyLowDistance / 100
sellHighMultiplier = 1 - sellHighDistance / 100

divergenceBuyCondition =
     enableDiv and
     rsi < divergenceRsiBuy and
     close > ta.lowest(close, divergenceLookback) and
     close < ta.lowest(close, divergenceLookback) * buyLowMultiplier and
     rsi > ta.lowest(rsi, divergenceLookback) and
     rsi > rsi[1]

divergenceSellCondition =
     enableDiv and
     rsi > divergenceRsiSell and
     close < ta.highest(close, divergenceLookback) and
     close > ta.highest(close, divergenceLookback) * sellHighMultiplier and
     rsi < ta.highest(rsi, divergenceLookback)

// === DIVERGENCE SIGNAL SPACING ===
var int lastDivBuy  = na
var int lastDivSell = na

divBuySignal =
     divergenceBuyCondition and
     (na(lastDivBuy) or bar_index - lastDivBuy >= divergenceSignalSpacing)

divSellSignal =
     divergenceSellCondition and
     (na(lastDivSell) or bar_index - lastDivSell >= divergenceSignalSpacing)

if divBuySignal
    lastDivBuy := bar_index

if divSellSignal
    lastDivSell := bar_index

// === VOLUME SIGNAL SPACING ===
var int lastVolBuy  = na
var int lastVolSell = na

volBuySignal =
     volBuyCondition and
     (na(lastVolBuy) or bar_index - lastVolBuy >= volumeSignalSpacing)

volSellSignal =
     volSellCondition and
     (na(lastVolSell) or bar_index - lastVolSell >= volumeSignalSpacing)

if volBuySignal
    lastVolBuy := bar_index

if volSellSignal
    lastVolSell := bar_index

// === VOLUME + DIVERGENCE CONFIRMATION ===

// Divergence happened before Volume
divBeforeVolBuy =
     not na(lastDivBuy) and
     bar_index - lastDivBuy <= confirmWindow

divBeforeVolSell =
     not na(lastDivSell) and
     bar_index - lastDivSell <= confirmWindow

// Volume happened before Divergence
divAfterVolBuy =
     divBuySignal and
     not na(lastVolBuy) and
     bar_index - lastVolBuy <= confirmWindow

divAfterVolSell =
     divSellSignal and
     not na(lastVolSell) and
     bar_index - lastVolSell <= confirmWindow

// === RAW FINAL SIGNALS ===
buyRaw =
     enableVol and enableDiv
         ? (volBuySignal and divBeforeVolBuy) or divAfterVolBuy
         : enableVol
             ? volBuySignal
             : enableDiv
                 ? divBuySignal
                 : false

sellRaw =
     enableVol and enableDiv
         ? (volSellSignal and divBeforeVolSell) or divAfterVolSell
         : enableVol
             ? volSellSignal
             : enableDiv
                 ? divSellSignal
                 : false

// === OVERALL SIGNAL SPACING ===
var int lastBuy  = na
var int lastSell = na

buySignal =
     buyRaw and
     (na(lastBuy) or bar_index - lastBuy >= overallSpacing)

sellSignal =
     sellRaw and
     (na(lastSell) or bar_index - lastSell >= overallSpacing)

if buySignal
    lastBuy := bar_index

if sellSignal
    lastSell := bar_index

// === DISPLAY ===
plotshape(
     buySignal,
     title="BUY",
     location=location.belowbar,
     color=color.new(color.green, 0),
     style=shape.triangleup,
     size=size.small,
     text="BUY"
)

plotshape(
     sellSignal,
     title="SELL",
     location=location.abovebar,
     color=color.new(color.red, 0),
     style=shape.triangledown,
     size=size.small,
     text="SELL"
)

// === ALERTS ===
alertcondition(
     buySignal and alertBuy,
     title="BUY",
     message="BUY — {{ticker}} / {{interval}}"
)

alertcondition(
     sellSignal and alertSell,
     title="SELL",
     message="SELL — {{ticker}} / {{interval}}"
)
````
