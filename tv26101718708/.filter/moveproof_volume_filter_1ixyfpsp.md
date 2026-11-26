# MoveProof Volume Filter

- url: https://www.tradingview.com/script/1IXyfPSp-MoveProof-Volume-Filter/
- type: indicator
- pine_id: PUB;11280da23dec4a61a9c4e507a092a4e1
- version: 3.0

## Description

MoveProof is a clean volume-quality indicator built to help traders judge whether a breakout, breakdown, or continuation move actually has participation behind it.

Instead of only showing raw volume, this tool compares current volume against a moving average to create a simple relative-volume read. Strong volume bars stand out visually, while weaker bars stay muted so the chart is easier to read. The dashboard shows relative volume, volume strength, structure breaks, candle close quality, and whether the current move is showing confirmation or fakeout risk.

The main idea is simple:

Don’t trust the move until it proves itself.

A strong breakout should usually come with expanded volume and a solid candle close. A weak breakout, wick, or low-volume push can be a warning that the move may not have real follow-through.

This indicator is designed to work well alongside trend-following systems, moving-average pullback strategies, and intraday futures trading, especially on NQ/MNQ. It is not meant to be a standalone buy/sell system. Use it as a confirmation and caution filter alongside your own market structure, risk management, and trade plan.

(Built to pair with 'MA Trend Pullback System')

## Source Code

````pine
//@version=6
indicator("MoveProof Volume Filter", overlay=false, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volMaLen          = input.int(20, "Volume Average Length", minval=1)
breakoutLookback  = input.int(20, "Breakout Lookback", minval=2)

strongVolMult     = input.float(1.50, "Strong Volume Multiplier", minval=0.1, step=0.05)
weakVolMult       = input.float(0.80, "Weak Volume Multiplier", minval=0.1, step=0.05)

closeStrengthReq  = input.float(0.60, "Close Strength Required", minval=0.1, maxval=1.0, step=0.05)

showVolAvg        = input.bool(true, "Show Volume Average")
showStrongLine    = input.bool(true, "Show Strong Volume Threshold")
showSignals       = input.bool(true, "Show MoveProof Signals")
showDashboard     = input.bool(true, "Show Dashboard")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Volume Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volAvg = ta.sma(volume, volMaLen)
rvol   = volAvg > 0 ? volume / volAvg : na

strongVolume = rvol >= strongVolMult
weakVolume   = rvol <= weakVolMult

bullCandle = close > open
bearCandle = close < open
neutralCandle = close == open

barRange = high - low

// Close strength measures where the candle closed inside its own range.
// Bullish close strength: close near high.
// Bearish close strength: close near low.
bullCloseStrength = barRange > 0 ? (close - low) / barRange : 0.5
bearCloseStrength = barRange > 0 ? (high - close) / barRange : 0.5

strongBullClose = bullCloseStrength >= closeStrengthReq
strongBearClose = bearCloseStrength >= closeStrengthReq

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Breakout / Breakdown Structure Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
priorHigh = ta.highest(high[1], breakoutLookback)
priorLow  = ta.lowest(low[1], breakoutLookback)

// Confirmed structure breaks
bullBreakout = close > priorHigh
bearBreakdown = close < priorLow

// Weak pokes through structure
bullPoke = high > priorHigh and close <= priorHigh
bearPoke = low < priorLow and close >= priorLow

// MoveProof confirmation
bullMoveProof = bullBreakout and bullCandle and strongBullClose and strongVolume
bearMoveProof = bearBreakdown and bearCandle and strongBearClose and strongVolume

// Fakeout warnings
bullFakeoutRisk = (bullPoke or bullBreakout) and (weakVolume or not strongBullClose)
bearFakeoutRisk = (bearPoke or bearBreakdown) and (weakVolume or not strongBearClose)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Volume Bar Coloring
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
strongBullColor = color.new(color.lime, 0)
strongBearColor = color.new(color.red, 0)

normalBullColor = color.new(color.lime, 45)
normalBearColor = color.new(color.red, 45)

weakColor = color.new(color.gray, 55)
neutralColor = color.new(color.gray, 35)

volColor =
     weakVolume ? weakColor :
     bullCandle and strongVolume ? strongBullColor :
     bearCandle and strongVolume ? strongBearColor :
     bullCandle ? normalBullColor :
     bearCandle ? normalBearColor :
     neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(volume, title="Volume", style=plot.style_columns, color=volColor)

plot(
     showVolAvg ? volAvg : na,
     title="Volume Average",
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
// MoveProof Signal Markers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Marker spacing logic
// Confirmation dots float slightly above the triggering volume bar.
// Fakeout diamonds sit in a small warning lane below the volume baseline.
dotPadding = math.max(volAvg * 0.08, volume * 0.04)

bullDotY = bullMoveProof ? volume + dotPadding : na
bearDotY = bearMoveProof ? volume + dotPadding : na

fakeoutLaneY = -volAvg * 0.12

bullFakeoutY = bullFakeoutRisk ? fakeoutLaneY : na
bearFakeoutY = bearFakeoutRisk ? fakeoutLaneY : na

// Invisible scale helper.
// This creates a little breathing room below zero so the orange diamonds
// have their own clean lane instead of sitting on top of the volume bars.
plot(
     showSignals ? fakeoutLaneY : na,
     title="Fakeout Marker Lane",
     color=color.new(color.orange, 100),
     linewidth=1
)

plotshape(
     showSignals ? bullDotY : na,
     title="Bullish MoveProof",
     style=shape.circle,
     location=location.absolute,
     color=color.new(color.lime, 0),
     size=size.tiny
)

plotshape(
     showSignals ? bearDotY : na,
     title="Bearish MoveProof",
     style=shape.circle,
     location=location.absolute,
     color=color.new(color.red, 0),
     size=size.tiny
)

plotshape(
     showSignals ? bullFakeoutY : na,
     title="Bullish Fakeout Risk",
     style=shape.diamond,
     location=location.absolute,
     color=color.new(color.orange, 0),
     size=size.tiny
)

plotshape(
     showSignals ? bearFakeoutY : na,
     title="Bearish Fakeout Risk",
     style=shape.diamond,
     location=location.absolute,
     color=color.new(color.orange, 0),
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullMoveProof, title="Bullish MoveProof", message="Bullish MoveProof: breakout confirmed by strong volume.")
alertcondition(bearMoveProof, title="Bearish MoveProof", message="Bearish MoveProof: breakdown confirmed by strong volume.")
alertcondition(bullFakeoutRisk, title="Bullish Fakeout Risk", message="Bullish fakeout risk: price broke/poked higher without strong confirmation.")
alertcondition(bearFakeoutRisk, title="Bearish Fakeout Risk", message="Bearish fakeout risk: price broke/poked lower without strong confirmation.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table dash = table.new(
     position.top_right,
     2,
     5,
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
     bullFakeoutRisk or bearFakeoutRisk ? "FAKEOUT RISK" :
     "WAIT"

moveStateColor =
     bullMoveProof ? color.new(color.lime, 0) :
     bearMoveProof ? color.new(color.red, 0) :
     bullFakeoutRisk or bearFakeoutRisk ? color.new(color.orange, 0) :
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
````
