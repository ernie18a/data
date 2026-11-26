# Regime Based SuperTrend+RAM RAM

- url: https://www.tradingview.com/script/aGO7VzRO-Regime-Based-SuperTrend-RAM-RAM/
- type: indicator
- pine_id: PUB;cca2b4d43cb04575bbf10170d6ce7e71
- version: 2.0

## Description

Now system checks:

SuperTrend bullish,
AND bullish directional strength stronger.

This reduces:

fake reversals,
weak breakouts,
sideways noise.

A meaningful upgrade.

## Source Code

````pine
//@version=5
indicator("Regime SuperTrend V2", overlay=true)

//=====================================================
// INPUTS
//=====================================================

// SuperTrend
atrPeriod = input.int(50, "ATR Period")
atrMultiplier = input.float(3.0, "ATR Multiplier", step=0.5)

// EMA
emaLength = input.int(50, "EMA Length")

// RSI
rsiLength = input.int(14, "RSI Length")
rsiThreshold = input.int(50, "RSI Threshold")

// Volume
volLength = input.int(22, "Volume Average Length")

// Mean Reversion
maxStretch = input.float(20.0, "Max Stretch %")

// Higher Timeframe
htf = input.timeframe("W", "Higher Timeframe")

// Signals
showSignals = input.bool(false, "Show Buy/Sell Labels")

//=====================================================
// CALCULATIONS
//=====================================================

// EMA
ema50 = ta.ema(close, emaLength)

// RSI
rsi = ta.rsi(close, rsiLength)

// Volume
volAvg = ta.sma(volume, volLength)

// SuperTrend
[supertrend, direction] = ta.supertrend(atrMultiplier, atrPeriod)

bullTrend = direction < 0
bearTrend = direction > 0

// Higher Timeframe SuperTrend
[htfST, htfDir] = request.security(
     syminfo.tickerid,
     htf,
     ta.supertrend(atrMultiplier, atrPeriod))

htfBull = htfDir < 0
htfBear = htfDir > 0

//=====================================================
// REGIME CONDITIONS
//=====================================================

// RSI
rsiPass = rsi > rsiThreshold

// EMA
emaPass = close > ema50

// SuperTrend
stPass = bullTrend

// Volume
volPass = volume > volAvg

// HTF Trend
htfPass = htfBull

//=====================================================
// REGIME SCORE
//=====================================================

regimeScore = 0

regimeScore := regimeScore + (rsiPass ? 1 : 0)
regimeScore := regimeScore + (emaPass ? 1 : 0)
regimeScore := regimeScore + (stPass ? 1 : 0)
regimeScore := regimeScore + (volPass ? 1 : 0)
regimeScore := regimeScore + (htfPass ? 1 : 0)

//=====================================================
// STRETCH ANALYSIS
//=====================================================

stretchPct =
     ((close - ema50) / ema50) * 100

overExtended =
     math.abs(stretchPct) > maxStretch

//=====================================================
// MEAN REVERSION WARNINGS
//=====================================================

rsiExhausted = rsi > 85

weakVolume =
     close > close[1] and
     volume < volume[1]

warningSignal =
     rsiExhausted or
     weakVolume or
     overExtended

//=====================================================
// LONG / SHORT CONDITIONS
//=====================================================

longCondition =
     regimeScore >= 4 and
     not overExtended

shortCondition =
     bearTrend and
     close < ema50 and
     rsi < 50

buySignal =
     longCondition and
     not longCondition[1]

sellSignal =
     shortCondition and
     not shortCondition[1]

//=====================================================
// PLOTS
//=====================================================

plot(
     supertrend,
     color=bullTrend ? color.green : color.red,
     linewidth=2,
     title="SuperTrend")

plot(
     ema50,
     color=color.orange,
     linewidth=2,
     title="EMA50")

//=====================================================
// OPTIONAL SIGNALS
//=====================================================

plotshape(
     showSignals and buySignal,
     title="BUY",
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BUY",
     textcolor=color.white)

plotshape(
     showSignals and sellSignal,
     title="SELL",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="SELL",
     textcolor=color.white)

// Warning
plotshape(
     warningSignal,
     title="Warning",
     location=location.top,
     style=shape.triangledown,
     color=color.yellow,
     size=size.tiny)

//=====================================================
// BACKGROUND
//=====================================================

bgcolor(
     regimeScore >= 4 ?
     color.new(color.green, 94) :
     regimeScore <= 2 ?
     color.new(color.red, 94) :
     color.new(color.gray, 95))

//=====================================================
// ALERTS
//=====================================================

alertcondition(
     buySignal,
     title="Regime Long",
     message="Regime Score >=4 and Trend Healthy")

alertcondition(
     sellSignal,
     title="Regime Short",
     message="Bearish Regime Detected")

alertcondition(
     warningSignal,
     title="Mean Reversion Warning",
     message="RSI Exhaustion / Weak Volume / Overextension")

//=====================================================
// DASHBOARD
//=====================================================

var table t = table.new(position.top_right, 2, 8)

if barstate.islast

    table.cell(t, 0, 0, "Score")
    table.cell(t, 1, 0, str.tostring(regimeScore) + "/5")

    table.cell(t, 0, 1, "RSI")
    table.cell(t, 1, 1, rsiPass ? "✓" : "✗")

    table.cell(t, 0, 2, "EMA50")
    table.cell(t, 1, 2, emaPass ? "✓" : "✗")

    table.cell(t, 0, 3, "ST")
    table.cell(t, 1, 3, stPass ? "✓" : "✗")

    table.cell(t, 0, 4, "Volume")
    table.cell(t, 1, 4, volPass ? "✓" : "✗")

    table.cell(t, 0, 5, "HTF")
    table.cell(t, 1, 5, htfPass ? "✓" : "✗")

    table.cell(t, 0, 6, "Stretch")
    table.cell(t, 1, 6, str.tostring(stretchPct, "#.0") + "%")

    table.cell(t, 0, 7, "Risk")
    table.cell(
         t,
         1,
         7,
         warningSignal ? "High" : "Normal")
````
