# MoveProof Volume Filter v3.0

- url: https://www.tradingview.com/script/NanVUOPH-MoveProof-Volume-Filter-v3-0/
- type: indicator
- pine_id: PUB;c4bb3e1977e941ea85d235e6f0b265f2
- version: 2.0

## Description

MoveProof v3.0 is working around MA Trend Pullback System more fluidly. It tries to separate healthy pullbacks from dangerous pullbacks and give useful volume information without too much clutter.

## Source Code

````pine
//@version=6
indicator("MoveProof Volume Filter v3.0", shorttitle="MoveProof v3.0", overlay=false, max_labels_count=500)
//
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volMaLen          = input.int(12, "Volume Average Length", minval=1)
breakoutLookback  = input.int(20, "Breakout Lookback", minval=2)

strongVolMult     = input.float(1.20, "Strong Volume Multiplier", minval=0.1, step=0.05)
weakVolMult       = input.float(0.65, "Weak Volume Multiplier", minval=0.1, step=0.05)

closeStrengthReq  = input.float(0.60, "Close Strength Required", minval=0.1, maxval=1.0, step=0.05)

useAdaptiveVolAvg = input.bool(true, "Use Adaptive Volume Average")
volAvgType        = input.string("EMA", "Volume Average Type", options=["SMA", "EMA", "RMA"])
outlierCapMult    = input.float(2.50, "Volume Spike Cap Multiplier", minval=1.0, step=0.25)

showVolAvg        = input.bool(true, "Show Volume Average")
showStrongLine    = input.bool(true, "Show Strong Volume Threshold")
showDashboard     = input.bool(true, "Show Dashboard")
highlightSignals  = input.bool(true, "Highlight MoveProof / Fakeout Bars")

// MA strategy context
useMAContext       = input.bool(true, "Use MA Pullback Context")
fastLen            = input.int(20, "Context Fast EMA", minval=1)
midLen             = input.int(50, "Context Value EMA", minval=1)
slowLen            = input.int(200, "Context Trend EMA", minval=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive Volume Baseline
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Raw volume bars still display normally.
// Only the RVOL baseline is cleaned up so huge opening candles do not distort the whole morning.

rawVolAvg = ta.ema(volume, volMaLen)
capBase = nz(rawVolAvg[1], volume)

cappedVolume = useAdaptiveVolAvg ? math.min(volume, capBase * outlierCapMult) : volume

volAvg =
     volAvgType == "EMA" ? ta.ema(cappedVolume, volMaLen) :
     volAvgType == "RMA" ? ta.rma(cappedVolume, volMaLen) :
     ta.sma(cappedVolume, volMaLen)

rvol = volAvg > 0 ? volume / volAvg : na

strongVolume = rvol >= strongVolMult
weakVolume   = rvol <= weakVolMult
normalVolume = not strongVolume and not weakVolume

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bullCandle = close > open
bearCandle = close < open

barRange = high - low

bullCloseStrength = barRange > 0 ? (close - low) / barRange : 0.5
bearCloseStrength = barRange > 0 ? (high - close) / barRange : 0.5

strongBullClose = bullCloseStrength >= closeStrengthReq
strongBearClose = bearCloseStrength >= closeStrengthReq

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA Context Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, fastLen)
emaMid  = ta.ema(close, midLen)
emaSlow = ta.ema(close, slowLen)

midRising  = emaMid > emaMid[1]
midFalling = emaMid < emaMid[1]

bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow

bullBias = close > emaSlow and bullStack and midRising
bearBias = close < emaSlow and bearStack and midFalling

// Pullback context for long side.
longPullbackIntoMA =
     useMAContext and
     bullBias and
     low <= emaFast and
     close >= emaMid

shortPullbackIntoMA =
     useMAContext and
     bearBias and
     high >= emaFast and
     close <= emaMid

// Healthy pullback means volume is cooling against the trend.
// For longs: bearish/red pullback into MA zone with weak/normal volume.
// For shorts: bullish/green pullback into MA zone with weak/normal volume.
healthyLongPullback =
     longPullbackIntoMA and
     bearCandle and
     not strongVolume and
     close >= emaMid

healthyShortPullback =
     shortPullbackIntoMA and
     bullCandle and
     not strongVolume and
     close <= emaMid

// Danger pullback means opposing pressure is expanding into the MA zone.
dangerLongPullback =
     longPullbackIntoMA and
     bearCandle and
     strongBearClose and
     strongVolume

dangerShortPullback =
     shortPullbackIntoMA and
     bullCandle and
     strongBullClose and
     strongVolume

// Reclaim support means price tested the MA area and closed back in trend direction.
longReclaimSupport =
     useMAContext and
     bullBias and
     low <= emaFast and
     close > emaFast and
     close > emaMid and
     bullCandle and
     strongBullClose and
     not weakVolume

shortReclaimSupport =
     useMAContext and
     bearBias and
     high >= emaFast and
     close < emaFast and
     close < emaMid and
     bearCandle and
     strongBearClose and
     not weakVolume

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Breakout / Breakdown Structure Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priorHigh = ta.highest(high[1], breakoutLookback)
priorLow  = ta.lowest(low[1], breakoutLookback)

bullBreakout = close > priorHigh
bearBreakdown = close < priorLow

bullPoke = high > priorHigh and close <= priorHigh
bearPoke = low < priorLow and close >= priorLow

bullMoveProof = bullBreakout and bullCandle and strongBullClose and strongVolume
bearMoveProof = bearBreakdown and bearCandle and strongBearClose and strongVolume

bullFakeoutRisk = (bullPoke or bullBreakout) and (weakVolume or not strongBullClose)
bearFakeoutRisk = (bearPoke or bearBreakdown) and (weakVolume or not strongBearClose)

fakeoutRisk = bullFakeoutRisk or bearFakeoutRisk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Context State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
contextState =
     bullMoveProof ? "Bull Impulse" :
     bearMoveProof ? "Bear Impulse" :
     fakeoutRisk ? "Fakeout Risk" :
     dangerLongPullback ? "Danger Pullback" :
     dangerShortPullback ? "Danger Pullback" :
     longReclaimSupport ? "Reclaim Support" :
     shortReclaimSupport ? "Reclaim Support" :
     healthyLongPullback ? "Healthy Pullback" :
     healthyShortPullback ? "Healthy Pullback" :
     strongVolume and bullCandle ? "Bull Volume" :
     strongVolume and bearCandle ? "Bear Volume" :
     weakVolume ? "Quiet / Weak" :
     "Normal"

contextColor =
     bullMoveProof or longReclaimSupport ? color.new(color.lime, 0) :
     bearMoveProof or shortReclaimSupport ? color.new(color.red, 0) :
     fakeoutRisk or dangerLongPullback or dangerShortPullback ? color.new(color.orange, 0) :
     healthyLongPullback or healthyShortPullback ? color.new(color.aqua, 0) :
     strongVolume and bullCandle ? color.new(color.lime, 0) :
     strongVolume and bearCandle ? color.new(color.red, 0) :
     weakVolume ? color.new(color.orange, 0) :
     color.new(color.white, 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Bar Coloring
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
moveProofBullColor = color.new(color.lime, 0)
moveProofBearColor = color.new(color.red, 0)
fakeoutColor       = color.new(color.orange, 0)

reclaimColor       = color.new(color.aqua, 0)
healthyColor       = color.new(color.teal, 35)
dangerColor        = color.new(color.orange, 0)

strongBullColor = color.new(color.lime, 20)
strongBearColor = color.new(color.red, 20)

normalBullColor = color.new(color.lime, 55)
normalBearColor = color.new(color.red, 55)

weakColor    = color.new(color.gray, 60)
neutralColor = color.new(color.gray, 40)

// Color priority:
// 1. Fakeout / danger pullback
// 2. Bull/Bear MoveProof impulse
// 3. MA reclaim support
// 4. Healthy pullback
// 5. Strong directional volume
// 6. Normal directional volume
// 7. Weak/neutral
volColor =
     highlightSignals and (fakeoutRisk or dangerLongPullback or dangerShortPullback) ? dangerColor :
     highlightSignals and bullMoveProof ? moveProofBullColor :
     highlightSignals and bearMoveProof ? moveProofBearColor :
     highlightSignals and (longReclaimSupport or shortReclaimSupport) ? reclaimColor :
     highlightSignals and (healthyLongPullback or healthyShortPullback) ? healthyColor :
     weakVolume ? weakColor :
     bullCandle and strongVolume ? strongBullColor :
     bearCandle and strongVolume ? strongBearColor :
     bullCandle ? normalBullColor :
     bearCandle ? normalBearColor :
     neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(
     volume,
     title="Raw Volume",
     style=plot.style_columns,
     color=volColor
)

plot(
     showVolAvg ? volAvg : na,
     title="Adaptive Volume Average",
     color=color.new(color.white, 0),
     linewidth=2
)

plot(
     showStrongLine ? volAvg * strongVolMult : na,
     title="Strong Volume Threshold",
     color=color.new(color.yellow, 20),
     linewidth=1,
     style=plot.style_line
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullMoveProof, title="Bullish MoveProof", message="Bullish MoveProof: breakout confirmed by strong volume.")
alertcondition(bearMoveProof, title="Bearish MoveProof", message="Bearish MoveProof: breakdown confirmed by strong volume.")
alertcondition(bullFakeoutRisk, title="Bullish Fakeout Risk", message="Bullish fakeout risk: price broke/poked higher without strong confirmation.")
alertcondition(bearFakeoutRisk, title="Bearish Fakeout Risk", message="Bearish fakeout risk: price broke/poked lower without strong confirmation.")

alertcondition(longReclaimSupport, title="Long Reclaim Support", message="Long reclaim support: price tested the MA zone and reclaimed with normal-or-better volume.")
alertcondition(shortReclaimSupport, title="Short Reclaim Support", message="Short reclaim support: price tested the MA zone and reclaimed with normal-or-better volume.")

alertcondition(dangerLongPullback, title="Danger Pullback Long", message="Danger pullback: bearish volume expanded into the long MA pullback zone.")
alertcondition(dangerShortPullback, title="Danger Pullback Short", message="Danger pullback: bullish volume expanded into the short MA pullback zone.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(
     position.top_right,
     2,
     7,
     border_width=1,
     border_color=color.new(color.gray, 55),
     frame_width=1,
     frame_color=color.new(color.gray, 45)
)

rvolText = na(rvol) ? "n/a" : str.tostring(rvol, "#.##") + "x"

volumeState =
     strongVolume ? "STRONG" :
     weakVolume ? "WEAK" :
     "NORMAL"

volumeStateColor =
     strongVolume ? color.new(color.lime, 0) :
     weakVolume ? color.new(color.orange, 0) :
     color.new(color.white, 0)

moveState =
     bullMoveProof ? "BULL PROOF" :
     bearMoveProof ? "BEAR PROOF" :
     fakeoutRisk ? "FAKEOUT RISK" :
     longReclaimSupport or shortReclaimSupport ? "RECLAIM" :
     healthyLongPullback or healthyShortPullback ? "HEALTHY PB" :
     dangerLongPullback or dangerShortPullback ? "DANGER PB" :
     "WAIT"

moveStateColor =
     bullMoveProof or longReclaimSupport ? color.new(color.lime, 0) :
     bearMoveProof or shortReclaimSupport ? color.new(color.red, 0) :
     fakeoutRisk or dangerLongPullback or dangerShortPullback ? color.new(color.orange, 0) :
     healthyLongPullback or healthyShortPullback ? color.new(color.aqua, 0) :
     color.new(color.gray, 0)

breakText =
     bullBreakout ? "Breaking High" :
     bearBreakdown ? "Breaking Low" :
     bullPoke ? "High Poke" :
     bearPoke ? "Low Poke" :
     "No Break"

closeText =
     strongBullClose and bullCandle ? "Strong Bull" :
     strongBearClose and bearCandle ? "Strong Bear" :
     "Weak / Mixed"

baselineText = useAdaptiveVolAvg ? "Adaptive " + volAvgType : "Raw " + volAvgType

maContextText =
     not useMAContext ? "Off" :
     bullBias ? "Bull MA Context" :
     bearBias ? "Bear MA Context" :
     "Mixed / Chop"

maContextColor =
     not useMAContext ? color.new(color.gray, 0) :
     bullBias ? color.new(color.lime, 0) :
     bearBias ? color.new(color.red, 0) :
     color.new(color.gray, 0)

labelBg = color.new(color.black, 15)
valueBg = color.new(color.black, 5)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "MoveProof", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 0, moveState, text_color=moveStateColor, bgcolor=valueBg)

    table.cell(dash, 0, 1, "Context", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 1, contextState, text_color=contextColor, bgcolor=valueBg)

    table.cell(dash, 0, 2, "RVOL", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 2, rvolText, text_color=volumeStateColor, bgcolor=valueBg)

    table.cell(dash, 0, 3, "Volume", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 3, volumeState, text_color=volumeStateColor, bgcolor=valueBg)

    table.cell(dash, 0, 4, "Structure", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 4, breakText, text_color=color.white, bgcolor=valueBg)

    table.cell(dash, 0, 5, "Close", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 5, closeText, text_color=color.white, bgcolor=valueBg)

    table.cell(dash, 0, 6, "MA Mode", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 6, maContextText, text_color=maContextColor, bgcolor=valueBg)
````
