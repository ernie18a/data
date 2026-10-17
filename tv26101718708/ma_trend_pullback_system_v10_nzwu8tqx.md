# MA Trend Pullback System - V1.0

- url: https://www.tradingview.com/script/Nzwu8tQx-MA-Trend-Pullback-System-V1-0/
- type: indicator
- pine_id: PUB;fe2c39027e4b4099a95dc9fc6e5f8684
- version: 3.0

## Description

This indicator was built for traders who like using moving averages as a simple way to read trend, direction, and pullback areas.

It uses the 20 EMA, 50 EMA, and 200 EMA to help separate cleaner trending conditions from choppy, low-quality price action. When the market is showing a strong bullish or bearish structure, the background will lightly shade green or red so the current bias is easy to see at a glance. When there is no background, that usually means conditions are mixed or choppy, and I personally treat that as a warning to slow down or stay out.

The arrows are designed to mark possible pullback-continuation areas. They are not meant to be automatic buy or sell signals. They are more of a heads-up that price has pulled back toward the moving-average zone and may be worth watching for confirmation.

I also added a dashed vertical line at the regular U.S. market open, 9:30 AM Eastern, because that is an important reference point for intraday trading and helps visually separate the premarket from the main session.

The basic idea is simple:

Trade with the trend.
Wait for price to pull back.
Look for confirmation.
Avoid chop.
Manage risk first.

This is meant to be a clean visual framework for building discipline around moving-average pullback trades, not a magic signal system. Use it alongside your own market structure, risk management, and trade plan. NOT FINANCIAL ADVICE

## Source Code

````pine
//@version=6
indicator("MA Trend Pullback System - V1.1 Trimmed Cloud", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
fastLen      = input.int(20,  "Fast EMA", minval=1)
midLen       = input.int(50,  "Value EMA", minval=1)
slowLen      = input.int(200, "Trend EMA", minval=1)

showBg       = input.bool(true,  "Show Trend Background / Cloud")
showSignals  = input.bool(true,  "Show Pullback Arrows")
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
// Pullback Zone Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Long pullback: trend bullish, price pulls into 20/50 EMA zone,
// then confirms back upward.
inLongPullbackZone = bullBias and low <= emaFast and low >= emaMid * 0.995
longConfirmation = useCloseConf ? close > emaFast and close > open : close > open
longSignal = inLongPullbackZone and longConfirmation

// Short pullback: trend bearish, price pulls into 20/50 EMA zone,
// then confirms back downward.
inShortPullbackZone = bearBias and high >= emaFast and high <= emaMid * 1.005
shortConfirmation = useCloseConf ? close < emaFast and close < open : close < open
shortSignal = inShortPullbackZone and shortConfirmation

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 20 EMA Approach Alert Logic
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Long warning: bullish mode, price is above 20 EMA, and close is near enough to the 20 EMA.
longApproaching20 =
     showApproachAlerts and
     bullBias and
     close > emaFast and
     math.abs(close - emaFast) <= approachPoints

// Short warning: bearish mode, price is below 20 EMA, and close is near enough to the 20 EMA.
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
// Full Background = old style.
// MA Zone = trimmed cloud around the 20/50 EMA value area.
// Off = no background/cloud.

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

// Optional old full-screen background mode
bgcolor(
     cloudMode == "Full Background" and showBg ?
     bullBias ? bgBull :
     bearBias ? bgBear :
     na : na
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Arrows
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     showSignals and longSignal,
     title="Long Pullback Signal",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(color.lime, 0),
     size=size.small
)

plotshape(
     showSignals and shortSignal,
     title="Short Pullback Signal",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     size=size.small
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

alertcondition(
     longApproaching20,
     title="Price Approaching 20 EMA - Long Watch",
     message="Price is approaching the 20 EMA during bullish trend mode. Watch for a controlled long retest setup."
)

alertcondition(
     shortApproaching20,
     title="Price Approaching 20 EMA - Short Watch",
     message="Price is approaching the 20 EMA during bearish trend mode. Watch for a controlled short retest setup."
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Trend Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table trendTable = table.new(
     position.top_right,
     2,
     5,
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

tradeMode = bullBias ? "Longs Only" : bearBias ? "Shorts Only" : "No Trade"

// Dark, readable table styling
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
    table.cell(trendTable, 1, 4, tradeMode, text_color=trendColor, bgcolor=valueBg)
````
