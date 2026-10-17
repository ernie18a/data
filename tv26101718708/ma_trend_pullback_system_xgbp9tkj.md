# MA Trend Pullback System

- url: https://www.tradingview.com/script/xGbp9TKJ-MA-Trend-Pullback-System/
- type: indicator
- pine_id: PUB;e59c71ee77264fcda58d58b39eb71b7b
- version: 2.0

## Description

MA Trend Pullback System

This indicator is built around a simple but powerful trading idea: use moving averages to define trend, avoid chop, and focus only on high-quality pullback continuation setups.

The system uses the 20 EMA, 50 EMA, and 200 EMA to identify bullish, bearish, or neutral market conditions. When the moving averages are stacked and sloping with clear direction, the indicator highlights the active trend bias and marks potential pullback zones where price may be setting up for continuation.

The goal is not to create blind buy/sell signals. Instead, this tool is designed to act as a disciplined visual framework for trend-following traders who want to filter out low-quality trades, avoid sideways markets, and focus on clean setups with strong risk/reward potential.

Core concept:

Trade with the trend.
Wait for the pullback.
Look for confirmation.
Avoid chop.
Protect capital first.

This is intended as a decision-support tool for developing a consistent moving-average-based trading process.

## Source Code

````pine
//@version=6
indicator("MA Trend Pullback System - V1.2.1 Visual Polish", shorttitle="MA Pullback v1.2.1", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Input Groups
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore      = "Core Moving Averages"
groupCloud     = "Trend Cloud Visuals"
groupSignals   = "Signal Visuals"
groupOpen      = "Market Open Line"
groupExt       = "Extended / Wait Logic"
groupReclaim   = "20 EMA Reclaim Logic"
groupAlerts    = "Alerts"
groupDash      = "Dashboard Visuals"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Core Moving Average Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastLen = input.int(20,  "Fast EMA",  minval=1, group=groupCore)
midLen  = input.int(50,  "Value EMA", minval=1, group=groupCore)
slowLen = input.int(200, "Trend EMA", minval=1, group=groupCore)

emaFastColor = input.color(color.rgb(70, 210, 255), "20 EMA Color", group=groupCore)
emaMidColor  = input.color(color.rgb(255, 176, 66), "50 EMA Color", group=groupCore)
emaSlowColor = input.color(color.rgb(235, 235, 235), "200 EMA Color", group=groupCore)

emaFastWidth = input.int(2, "20 EMA Width", minval=1, maxval=5, group=groupCore)
emaMidWidth  = input.int(2, "50 EMA Width", minval=1, maxval=5, group=groupCore)
emaSlowWidth = input.int(3, "200 EMA Width", minval=1, maxval=5, group=groupCore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cloud / Background Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBg = input.bool(true, "Show Trend Background / Cloud", group=groupCloud)

cloudMode = input.string(
     "MA Zone",
     "Trend Background Style",
     options=["Full Background", "MA Zone", "Off"],
     group=groupCloud
)

cloudAtrLen  = input.int(14, "Trend Cloud ATR Length", minval=1, group=groupCloud)
cloudAtrMult = input.float(4.0, "Trend Cloud Height", minval=0.25, step=0.25, group=groupCloud)

bullCloudColor = input.color(color.rgb(60, 220, 120), "Bull Cloud Color", group=groupCloud)
bearCloudColor = input.color(color.rgb(230, 70, 90), "Bear Cloud Color", group=groupCloud)

cloudTransparency = input.int(88, "Cloud Transparency", minval=70, maxval=98, group=groupCloud)
fullBgTransparency = input.int(90, "Full Background Transparency", minval=70, maxval=98, group=groupCloud)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showSignals  = input.bool(true,  "Show Pullback Signals", group=groupSignals)
useCloseConf = input.bool(true,  "Require Close Confirmation", group=groupSignals)

pullbackBullColor = input.color(color.rgb(80, 230, 130), "Bull Pullback Marker", group=groupSignals)
pullbackBearColor = input.color(color.rgb(240, 85, 95), "Bear Pullback Marker", group=groupSignals)
pullbackMarkerTransparency = input.int(25, "Pullback Marker Transparency", minval=0, maxval=90, group=groupSignals)

reclaimBullColor = input.color(color.rgb(55, 210, 255), "Bull Reclaim Marker", group=groupSignals)
reclaimBearColor = input.color(color.rgb(230, 80, 255), "Bear Reclaim Marker", group=groupSignals)
reclaimMarkerTransparency = input.int(0, "Reclaim Marker Transparency", minval=0, maxval=90, group=groupSignals)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Market Open Line Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showOpenLine = input.bool(true, "Show 9:30 ET Market Open Line", group=groupOpen)
openLineColor = input.color(color.rgb(80, 235, 120), "Open Line Color", group=groupOpen)
openLineTransparency = input.int(0, "Open Line Transparency", minval=0, maxval=90, group=groupOpen)
openLineWidth = input.int(2, "Open Line Width", minval=1, maxval=5, group=groupOpen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Extension / Wait Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showExtendedState = input.bool(true, "Show Extended / Wait State", group=groupExt)
extendedAtrLen    = input.int(14, "Extension ATR Length", minval=1, group=groupExt)
extendedAtrMult   = input.float(1.50, "Extended Distance From 20 EMA", minval=0.25, step=0.25, group=groupExt)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Reclaim Signal Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showReclaimSignals = input.bool(true, "Show 20 EMA Reclaim Signals", group=groupReclaim)
reclaimLookback    = input.int(3, "20 EMA Reclaim Lookback", minval=1, maxval=10, group=groupReclaim)
reclaimCloseReq    = input.float(0.55, "Reclaim Candle Close Strength", minval=0.10, maxval=1.0, step=0.05, group=groupReclaim)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Settings
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showApproachAlerts = input.bool(true, "Enable 20 EMA Approach Alerts", group=groupAlerts)
approachPoints     = input.float(20.0, "20 EMA Approach Distance - Points", minval=0.25, step=0.25, group=groupAlerts)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showTable = input.bool(true, "Show Trend Dashboard", group=groupDash)

dashboardPosInput = input.string(
     "Top Right",
     "Dashboard Position",
     options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     group=groupDash
)

dashLabelBgAlpha = input.int(12, "Label Cell Transparency", minval=0, maxval=90, group=groupDash)
dashValueBgAlpha = input.int(4, "Value Cell Transparency", minval=0, maxval=90, group=groupDash)
dashBorderAlpha  = input.int(55, "Border Transparency", minval=0, maxval=95, group=groupDash)

dashBullColor    = input.color(color.rgb(90, 235, 145), "Dashboard Bull Color", group=groupDash)
dashBearColor    = input.color(color.rgb(245, 100, 110), "Dashboard Bear Color", group=groupDash)
dashWaitColor    = input.color(color.rgb(255, 190, 70), "Dashboard Wait Color", group=groupDash)
dashReclaimColor = input.color(color.rgb(80, 220, 255), "Dashboard Reclaim Color", group=groupDash)
dashNeutralColor = input.color(color.rgb(170, 170, 170), "Dashboard Neutral Color", group=groupDash)

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
// Logic preserved from v1.2.
inLongPullbackZone = bullBias and low <= emaFast and low >= emaMid * 0.995
longConfirmation = useCloseConf ? close > emaFast and close > open : close > open
longSignal = inLongPullbackZone and longConfirmation and not bullExtended

inShortPullbackZone = bearBias and high >= emaFast and high <= emaMid * 1.005
shortConfirmation = useCloseConf ? close < emaFast and close < open : close < open
shortSignal = inShortPullbackZone and shortConfirmation and not bearExtended

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20 EMA Reclaim Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Logic preserved from v1.2.
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
// Logic preserved from v1.2.
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
     bullExtended or bearExtended ? dashWaitColor :
     longReclaim20 or shortReclaim20 ? dashReclaimColor :
     in2050LongZone or in2050ShortZone ? dashBullColor :
     near20Long or near20Short ? color.new(dashBullColor, 10) :
     bullBias ? dashBullColor :
     bearBias ? dashBearColor :
     dashNeutralColor

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
plot(emaFast, "20 EMA", color=emaFastColor, linewidth=emaFastWidth)
plot(emaMid,  "50 EMA", color=emaMidColor, linewidth=emaMidWidth)
plot(emaSlow, "200 EMA", color=emaSlowColor, linewidth=emaSlowWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trimmed Trend Cloud / Background
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cloudAtr = ta.atr(cloudAtrLen)

cloudCenter = (emaFast + emaMid) / 2.0
cloudTop    = cloudCenter + cloudAtr * cloudAtrMult
cloudBottom = cloudCenter - cloudAtr * cloudAtrMult

bgBull = color.new(bullCloudColor, cloudTransparency)
bgBear = color.new(bearCloudColor, cloudTransparency)

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
     bullBias ? color.new(bullCloudColor, fullBgTransparency) :
     bearBias ? color.new(bearCloudColor, fullBgTransparency) :
     na : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Markers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Classic pullback markers: intentionally subtle.
plotshape(
     showSignals and longSignal,
     title="Long Pullback Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(pullbackBullColor, pullbackMarkerTransparency),
     size=size.tiny
)

plotshape(
     showSignals and shortSignal,
     title="Short Pullback Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(pullbackBearColor, pullbackMarkerTransparency),
     size=size.tiny
)

// 20 EMA reclaim markers: slightly more prominent than pullback markers.
plotshape(
     longReclaim20,
     title="Long 20 EMA Reclaim",
     style=shape.diamond,
     location=location.belowbar,
     color=color.new(reclaimBullColor, reclaimMarkerTransparency),
     size=size.tiny
)

plotshape(
     shortReclaim20,
     title="Short 20 EMA Reclaim",
     style=shape.diamond,
     location=location.abovebar,
     color=color.new(reclaimBearColor, reclaimMarkerTransparency),
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
         color=color.new(openLineColor, openLineTransparency),
         style=line.style_dashed,
         width=openLineWidth
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
dashboardPos =
     dashboardPosInput == "Top Left" ? position.top_left :
     dashboardPosInput == "Bottom Right" ? position.bottom_right :
     dashboardPosInput == "Bottom Left" ? position.bottom_left :
     position.top_right

var table trendTable = table.new(
     dashboardPos,
     2,
     6,
     border_width=1,
     border_color=color.new(color.gray, dashBorderAlpha),
     frame_width=1,
     frame_color=color.new(color.gray, dashBorderAlpha)
)

trendText = bullBias ? "BULLISH" : bearBias ? "BEARISH" : "NEUTRAL / CHOP"
trendColor = bullBias ? dashBullColor : bearBias ? dashBearColor : dashNeutralColor

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
     bullExtended or bearExtended ? dashWaitColor :
     bullBias ? dashBullColor :
     bearBias ? dashBearColor :
     dashNeutralColor

labelBg = color.new(color.black, dashLabelBgAlpha)
valueBg = color.new(color.black, dashValueBgAlpha)

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
