# MA Trend Pullback System - V1.2

- url: https://www.tradingview.com/script/YnkW1sPR-MA-Trend-Pullback-System-V1-2/
- type: indicator
- pine_id: PUB;fba75635712a454aa93fa3597974ce43
- version: 2.0

## Description

MA v1.2 now helps with entry timing better. It tells you when price is extended, when to wait, when a 20 EMA reclaim has actually happened, and what setup environment you’re in.

Works great with MoveProof v3.0

## Source Code

````pine
//@version=6
indicator("MA Trend Pullback System - V1.2", shorttitle="MA Pullback v1.2", overlay=true, max_labels_count=500, max_lines_count=500)
//
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastLen      = input.int(20,  "Fast EMA", minval=1)
midLen       = input.int(50,  "Value EMA", minval=1)
slowLen      = input.int(200, "Trend EMA", minval=1)

showBg       = input.bool(true,  "Show Trend Background / Cloud")
showSignals  = input.bool(true,  "Show Pullback Signals")
showTable    = input.bool(true,  "Show Trend Dashboard")
useCloseConf = input.bool(true,  "Require Close Confirmation")
showOpenLine = input.bool(true,  "Show 9:30 ET Market Open Line")

// Trend cloud settings
cloudMode = input.string(
     "MA Zone",
     "Trend Background Style",
     options=["Full Background", "MA Zone", "Off"]
)

cloudAtrLen  = input.int(14, "Trend Cloud ATR Length", minval=1)
cloudAtrMult = input.float(4.0, "Trend Cloud Height", minval=0.25, step=0.25)

// Extension / wait settings
showExtendedState = input.bool(true, "Show Extended / Wait State")
extendedAtrLen    = input.int(14, "Extension ATR Length", minval=1)
extendedAtrMult   = input.float(1.50, "Extended Distance From 20 EMA", minval=0.25, step=0.25)

// Reclaim signal settings
showReclaimSignals = input.bool(true, "Show 20 EMA Reclaim Signals")
reclaimLookback    = input.int(3, "20 EMA Reclaim Lookback", minval=1, maxval=10)
reclaimCloseReq    = input.float(0.55, "Reclaim Candle Close Strength", minval=0.10, maxval=1.0, step=0.05)

// 20 EMA approach alert settings
showApproachAlerts = input.bool(true, "Enable 20 EMA Approach Alerts")
approachPoints     = input.float(20.0, "20 EMA Approach Distance - Points", minval=0.25, step=0.25)

// Colors
bgBull = color.new(color.lime, 88)
bgBear = color.new(color.red, 88)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Moving Averages
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, fastLen)
emaMid  = ta.ema(close, midLen)
emaSlow = ta.ema(close, slowLen)

// Slope logic
midRising  = emaMid > emaMid[1]
midFalling = emaMid < emaMid[1]

// Trend structure
bullStack = emaFast > emaMid and emaMid > emaSlow
bearStack = emaFast < emaMid and emaMid < emaSlow

bullBias = close > emaSlow and bullStack and midRising
bearBias = close < emaSlow and bearStack and midFalling

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Extension Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
extAtr = ta.atr(extendedAtrLen)

bullExtended = showExtendedState and bullBias and close > emaFast and (close - emaFast) > extAtr * extendedAtrMult
bearExtended = showExtendedState and bearBias and close < emaFast and (emaFast - close) > extAtr * extendedAtrMult

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle Close Strength
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
barRange = high - low

bullCloseStrength = barRange > 0 ? (close - low) / barRange : 0.5
bearCloseStrength = barRange > 0 ? (high - close) / barRange : 0.5

strongBullClose = bullCloseStrength >= reclaimCloseReq
strongBearClose = bearCloseStrength >= reclaimCloseReq

bullCandle = close > open
bearCandle = close < open

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Pullback Zone Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Classic 20/50 pullback continuation.
// These are now smaller, cleaner arrows.
inLongPullbackZone = bullBias and low <= emaFast and low >= emaMid * 0.995
longConfirmation = useCloseConf ? close > emaFast and close > open : close > open
longSignal = inLongPullbackZone and longConfirmation and not bullExtended

inShortPullbackZone = bearBias and high >= emaFast and high <= emaMid * 1.005
shortConfirmation = useCloseConf ? close < emaFast and close < open : close < open
shortSignal = inShortPullbackZone and shortConfirmation and not bearExtended

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20 EMA Reclaim Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// This is the big Day 1 lesson:
// the 20 EMA is the location, but the reclaim is the trigger.

recentLongDipInto20 =
     ta.lowest(low, reclaimLookback) <= emaFast

recentShortPopInto20 =
     ta.highest(high, reclaimLookback) >= emaFast

longReclaim20 =
     showReclaimSignals and
     bullBias and
     not bullExtended and
     recentLongDipInto20 and
     close > emaFast and
     close > emaMid and
     bullCandle and
     strongBullClose

shortReclaim20 =
     showReclaimSignals and
     bearBias and
     not bearExtended and
     recentShortPopInto20 and
     close < emaFast and
     close < emaMid and
     bearCandle and
     strongBearClose

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Setup State Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
near20Long = bullBias and close >= emaFast and math.abs(close - emaFast) <= extAtr * 0.75
near20Short = bearBias and close <= emaFast and math.abs(close - emaFast) <= extAtr * 0.75

in2050LongZone = bullBias and low <= emaFast and low >= emaMid * 0.99
in2050ShortZone = bearBias and high >= emaFast and high <= emaMid * 1.01

setupState =
     bullExtended ? "Extended / Wait" :
     bearExtended ? "Extended / Wait" :
     longReclaim20 ? "20 EMA Reclaim" :
     shortReclaim20 ? "20 EMA Reclaim" :
     in2050LongZone ? "20/50 Pullback Watch" :
     in2050ShortZone ? "20/50 Pullback Watch" :
     near20Long ? "20 EMA Ride Watch" :
     near20Short ? "20 EMA Ride Watch" :
     bullBias ? "Long Pullback Only" :
     bearBias ? "Short Pullback Only" :
     "No Clean Setup"

setupColor =
     bullExtended or bearExtended ? color.new(color.orange, 0) :
     longReclaim20 or shortReclaim20 ? color.new(color.aqua, 0) :
     in2050LongZone or in2050ShortZone ? color.new(color.lime, 0) :
     near20Long or near20Short ? color.new(color.lime, 10) :
     bullBias ? color.new(color.lime, 0) :
     bearBias ? color.new(color.red, 0) :
     color.new(color.gray, 10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20 EMA Approach Alert Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
longApproaching20 =
     showApproachAlerts and
     bullBias and
     close > emaFast and
     math.abs(close - emaFast) <= approachPoints

shortApproaching20 =
     showApproachAlerts and
     bearBias and
     close < emaFast and
     math.abs(close - emaFast) <= approachPoints

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Plots: Moving Averages
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(emaFast, "20 EMA", color=color.new(color.aqua, 0), linewidth=2)
plot(emaMid,  "50 EMA", color=color.new(color.orange, 0), linewidth=2)
plot(emaSlow, "200 EMA", color=color.new(color.white, 0), linewidth=3)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trimmed Trend Cloud / Background
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cloudAtr = ta.atr(cloudAtrLen)

cloudCenter = (emaFast + emaMid) / 2.0
cloudTop    = cloudCenter + cloudAtr * cloudAtrMult
cloudBottom = cloudCenter - cloudAtr * cloudAtrMult

cloudColor =
     bullBias ? bgBull :
     bearBias ? bgBear :
     na

cloudTopPlot = plot(
     cloudMode == "MA Zone" and showBg ? cloudTop : na,
     title="Trend Cloud Top",
     color=color.new(color.white, 100),
     display=display.none
)

cloudBottomPlot = plot(
     cloudMode == "MA Zone" and showBg ? cloudBottom : na,
     title="Trend Cloud Bottom",
     color=color.new(color.white, 100),
     display=display.none
)

fill(
     cloudTopPlot,
     cloudBottomPlot,
     color=cloudMode == "MA Zone" and showBg ? cloudColor : na,
     title="Trimmed Trend Cloud"
)

bgcolor(
     cloudMode == "Full Background" and showBg ?
     bullBias ? bgBull :
     bearBias ? bgBear :
     na : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Markers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Smaller classic pullback arrows.
plotshape(
     showSignals and longSignal,
     title="Long Pullback Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 15),
     size=size.tiny
)

plotshape(
     showSignals and shortSignal,
     title="Short Pullback Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 15),
     size=size.tiny
)

// 20 EMA reclaim signal.
// Aqua diamond = price tested/reclaimed the 20 EMA.
plotshape(
     longReclaim20,
     title="Long 20 EMA Reclaim",
     style=shape.diamond,
     location=location.belowbar,
     color=color.new(color.aqua, 0),
     size=size.tiny
)

plotshape(
     shortReclaim20,
     title="Short 20 EMA Reclaim",
     style=shape.diamond,
     location=location.abovebar,
     color=color.new(color.fuchsia, 0),
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9:30 AM New York Market Open Line
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isMarketOpenBar = hour(time, "America/New_York") == 9 and minute(time, "America/New_York") == 30

if showOpenLine and isMarketOpenBar
    line.new(
         x1=bar_index,
         y1=high,
         x2=bar_index,
         y2=low,
         xloc=xloc.bar_index,
         extend=extend.both,
         color=color.new(color.lime, 0),
         style=line.style_dashed,
         width=2
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alerts
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(longSignal, title="MA Long Pullback", message="MA Long Pullback setup detected.")
alertcondition(shortSignal, title="MA Short Pullback", message="MA Short Pullback setup detected.")

alertcondition(longReclaim20, title="Long 20 EMA Reclaim", message="Bullish 20 EMA reclaim detected. Price tested the 20 EMA and closed back above it during bullish trend mode.")
alertcondition(shortReclaim20, title="Short 20 EMA Reclaim", message="Bearish 20 EMA reclaim detected. Price tested the 20 EMA and closed back below it during bearish trend mode.")

alertcondition(longApproaching20, title="Price Approaching 20 EMA - Long Watch", message="Price is approaching the 20 EMA during bullish trend mode. Watch for a controlled long retest setup.")
alertcondition(shortApproaching20, title="Price Approaching 20 EMA - Short Watch", message="Price is approaching the 20 EMA during bearish trend mode. Watch for a controlled short retest setup.")

alertcondition(bullExtended, title="Bullish Trend Extended - Wait", message="Bullish trend is active, but price is extended from the 20 EMA. Wait for a pullback.")
alertcondition(bearExtended, title="Bearish Trend Extended - Wait", message="Bearish trend is active, but price is extended from the 20 EMA. Wait for a pullback.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table trendTable = table.new(
     position.top_right,
     2,
     6,
     border_width=1,
     border_color=color.new(color.gray, 55),
     frame_width=1,
     frame_color=color.new(color.gray, 40)
)

trendText = bullBias ? "BULLISH" : bearBias ? "BEARISH" : "NEUTRAL / CHOP"
trendColor = bullBias ? color.new(color.lime, 0) : bearBias ? color.new(color.red, 0) : color.new(color.gray, 10)

stackText = bullStack ? "Bull Stack" : bearStack ? "Bear Stack" : "Mixed"
slopeText = midRising ? "50 EMA Rising" : midFalling ? "50 EMA Falling" : "50 EMA Flat"
priceText = close > emaSlow ? "Above 200 EMA" : close < emaSlow ? "Below 200 EMA" : "At 200 EMA"

tradeMode =
     bullExtended ? "Longs Only - Wait" :
     bearExtended ? "Shorts Only - Wait" :
     bullBias ? "Longs Only" :
     bearBias ? "Shorts Only" :
     "No Trade"

modeColor =
     bullExtended or bearExtended ? color.new(color.orange, 0) :
     bullBias ? color.new(color.lime, 0) :
     bearBias ? color.new(color.red, 0) :
     color.new(color.gray, 10)

labelBg = color.new(color.black, 15)
valueBg = color.new(color.black, 5)

if showTable and barstate.islast
    table.cell(trendTable, 0, 0, "Trend Bias", text_color=color.white, bgcolor=labelBg)
    table.cell(trendTable, 1, 0, trendText, text_color=trendColor, bgcolor=valueBg)

    table.cell(trendTable, 0, 1, "MA Stack", text_color=color.white, bgcolor=labelBg)
    table.cell(trendTable, 1, 1, stackText, text_color=trendColor, bgcolor=valueBg)

    table.cell(trendTable, 0, 2, "Slope", text_color=color.white, bgcolor=labelBg)
    table.cell(trendTable, 1, 2, slopeText, text_color=trendColor, bgcolor=valueBg)

    table.cell(trendTable, 0, 3, "Price", text_color=color.white, bgcolor=labelBg)
    table.cell(trendTable, 1, 3, priceText, text_color=trendColor, bgcolor=valueBg)

    table.cell(trendTable, 0, 4, "Mode", text_color=color.white, bgcolor=labelBg)
    table.cell(trendTable, 1, 4, tradeMode, text_color=modeColor, bgcolor=valueBg)

    table.cell(trendTable, 0, 5, "Setup", text_color=color.white, bgcolor=labelBg)
    table.cell(trendTable, 1, 5, setupState, text_color=setupColor, bgcolor=valueBg)
````
