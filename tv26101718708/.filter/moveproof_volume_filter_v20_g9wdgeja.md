# MoveProof Volume Filter v2.0

- url: https://www.tradingview.com/script/G9wDGeJa-MoveProof-Volume-Filter-v2-0/
- type: indicator
- pine_id: PUB;68458240d7334085a337563017ba6353
- version: 1.0

## Description

MoveProof v2.0 is a clean volume-quality filter built to help traders judge whether a breakout, breakdown, or continuation move is actually being supported by participation.

This version adds an adaptive volume baseline designed to reduce the impact of unusually large opening-volume spikes. The raw volume bars still display normally, but the RVOL reading and volume threshold logic are calculated from a cleaner baseline, making the indicator more useful after the market open.

Bright green/red bars mark confirmed bullish or bearish MoveProof conditions. Orange bars warn of possible fakeout risk. Gray bars show weak participation. The white line shows the adaptive volume average, and the yellow line marks the strong-volume threshold.

The goal:

Don’t trust the move until it proves itself.

Designed to work alongside trend-following systems, moving-average pullback strategies, and intraday futures trading, especially on NQ/MNQ. Use it as a confirmation and caution filter, not a standalone buy/sell system.

## Source Code

````pine
//@version=6
indicator("MoveProof Volume Filter v2.0", shorttitle="MoveProof v2.0", overlay=false, max_labels_count=500)

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

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive Volume Baseline
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// The actual volume bars still show real raw volume.
// Only the RVOL baseline is cleaned up so giant open candles do not distort the whole morning.

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
// Volume Bar Coloring
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
moveProofBullColor = color.new(color.lime, 0)
moveProofBearColor = color.new(color.red, 0)
fakeoutColor       = color.new(color.orange, 0)

strongBullColor = color.new(color.lime, 20)
strongBearColor = color.new(color.red, 20)

normalBullColor = color.new(color.lime, 55)
normalBearColor = color.new(color.red, 55)

weakColor    = color.new(color.gray, 60)
neutralColor = color.new(color.gray, 40)

// Color priority:
// 1. Fakeout risk = orange
// 2. Bull/Bear MoveProof = bright green/red
// 3. Strong directional volume = semi-bright green/red
// 4. Normal directional volume = muted green/red
// 5. Weak volume = gray
volColor =
     highlightSignals and fakeoutRisk ? fakeoutColor :
     highlightSignals and bullMoveProof ? moveProofBullColor :
     highlightSignals and bearMoveProof ? moveProofBearColor :
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
alertcondition(
     bullMoveProof,
     title="Bullish MoveProof",
     message="Bullish MoveProof: breakout confirmed by strong volume."
)

alertcondition(
     bearMoveProof,
     title="Bearish MoveProof",
     message="Bearish MoveProof: breakdown confirmed by strong volume."
)

alertcondition(
     bullFakeoutRisk,
     title="Bullish Fakeout Risk",
     message="Bullish fakeout risk: price broke/poked higher without strong confirmation."
)

alertcondition(
     bearFakeoutRisk,
     title="Bearish Fakeout Risk",
     message="Bearish fakeout risk: price broke/poked lower without strong confirmation."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(
     position.top_right,
     2,
     6,
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
     "WAIT"

moveStateColor =
     bullMoveProof ? color.new(color.lime, 0) :
     bearMoveProof ? color.new(color.red, 0) :
     fakeoutRisk ? color.new(color.orange, 0) :
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

labelBg = color.new(color.black, 15)
valueBg = color.new(color.black, 5)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "MoveProof", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 0, moveState, text_color=moveStateColor, bgcolor=valueBg)

    table.cell(dash, 0, 1, "RVOL", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 1, rvolText, text_color=volumeStateColor, bgcolor=valueBg)

    table.cell(dash, 0, 2, "Volume", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 2, volumeState, text_color=volumeStateColor, bgcolor=valueBg)

    table.cell(dash, 0, 3, "Structure", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 3, breakText, text_color=color.white, bgcolor=valueBg)

    table.cell(dash, 0, 4, "Close", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 4, closeText, text_color=color.white, bgcolor=valueBg)

    table.cell(dash, 0, 5, "Baseline", text_color=color.white, bgcolor=labelBg)
    table.cell(dash, 1, 5, baselineText, text_color=color.white, bgcolor=valueBg)
````
