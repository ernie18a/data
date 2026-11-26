# MoveProof Volume Filter - v1.0

- url: https://www.tradingview.com/script/cMUBUEIJ-MoveProof-Volume-Filter-v1-0/
- type: indicator
- pine_id: PUB;f3bf69dba14640349080832c171c7a51
- version: 1.0

## Description

Volume Bars
Shows trading volume for each candle. Taller bars mean more participation.

Bright Green Bar
Bullish MoveProof confirmation. Price is breaking higher with strong volume and a solid bullish close.

Bright Red Bar
Bearish MoveProof confirmation. Price is breaking lower with strong volume and a solid bearish close.

Orange Bar
Fakeout risk. Price is poking or breaking a recent high/low, but volume or candle close quality is weak.

Muted Green Bar
Bullish candle with normal volume.

Muted Red Bar
Bearish candle with normal volume.

Gray Bar
Weak volume. Be careful trusting breakouts or continuation moves.

White Line
Average volume. Shows what normal volume looks like over the selected lookback.

Yellow Line
Strong-volume threshold. Volume above this line means participation is meaningfully above average.

RVOL
Relative volume. Example: 1.50x means current volume is 50% higher than average.

Structure
Shows whether price is breaking, poking, or not interacting with recent highs/lows.

Close
Shows whether the current candle closed strongly in its direction or looks weak/mixed.

Main idea
Bright green/red bars mean the move has proof.
Orange bars mean be careful.
Gray bars mean volume is weak.
Use it as a confirmation filter, not a standalone buy/sell system.

Indicator pairs well with my other one 'MA Trend Pullback System - v1.0'
NOT FINANCIAL ADVICE

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
showDashboard     = input.bool(true, "Show Dashboard")
highlightSignals  = input.bool(true, "Highlight MoveProof / Fakeout Bars")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Volume Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
volAvg = ta.sma(volume, volMaLen)
rvol   = volAvg > 0 ? volume / volAvg : na

strongVolume = rvol >= strongVolMult
weakVolume   = rvol <= weakVolMult

bullCandle = close > open
bearCandle = close < open

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

// Priority:
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
     title="Volume",
     style=plot.style_columns,
     color=volColor
)

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
