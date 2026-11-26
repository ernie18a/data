# ORB 15min NY Session

- url: https://www.tradingview.com/script/CfJvcOTN-ORB-15min-NY-Session/
- type: indicator
- pine_id: PUB;5b9b8bb496d5451ebeb239393c5976db
- version: 1.0

## Description

Indicator gives a very clean layout of the 15 min ORB. Can also be used to view all previous sessions.

## Source Code

````pine
//@version=6
indicator("Improved ORB 15min", overlay=true)

// Input options
sOpeningRangeMinutes = input.string("15", title="Period (minutes)", options=["5", "15", "30", "0"], tooltip="Set to 0 for custom session")
openingRangeMinutes = str.tonumber(sOpeningRangeMinutes)
sORBStartTime = input.string("0930-0945", title="Time Override", tooltip="Set Period to 0 to apply. Format: 0930-0945", group="Session")
sTimeZone = input.string("America/New_York", title="Timezone", options=["America/New_York", "Europe/Amsterdam", "Europe/Berlin", "Asia/Kolkata", "Asia/Shanghai", "Asia/Tokyo", "Etc/UTC"], group="Session")

// Define session using switch statement
var string orbSession = ""
switch openingRangeMinutes
    0 => orbSession := sORBStartTime
    5 => orbSession := "0930-0935"
    15 => orbSession := "0930-0945"
    30 => orbSession := "0930-1000"
    => orbSession := "0930-0945"

// Display options
showLabels = input.bool(true, "Show ORB Labels", group="Display")
showPreviousDayORBs = input.bool(true, "Show Previous Days' ORBs", group="Display")
showPriceTargets = input.bool(true, "Show Price Targets (50%, 100%)", group="Display")
showPriceTargetsExtended = input.bool(false, "Show Extended Price Targets (150%, 200%)", group="Display")
showMidPoint = input.bool(true, "Show ORB Mid Point", group="Display")
showShadedBox = input.bool(true, "Shade ORB Range", group="Style")
shadeColor = input.color(color.teal, "Shaded ORB Range Color", group="Style")
orb50Color = input.color(color.purple, "ORB 50% Target", group="Style")
orb100Color = input.color(color.blue, "ORB 100% Target", group="Style")

// Signal options
useEMAFilter = input.bool(true, "Use 50 EMA Filter", group="Signals")
emaLength = input.int(50, "EMA Length", minval=1, group="Signals")
useVolumeConfirmation = input.bool(true, "Require Volume Spike", group="Signals")
volumeSMALength = input.int(20, "Volume SMA Length", minval=1, group="Signals")
riskRewardRatio = input.float(2.0, "Risk:Reward Ratio for TP", minval=1.0, step=0.5, group="Signals")
alertBreakoutsOnly = input.bool(true, "Alert Only on Confirmed Breakouts", group="Signals")

// Session logic
timeinrange(session) => not na(time(timeframe.period, session + ":23456", sTimeZone))
in_session = timeinrange(orbSession)
newDayStart = ta.change(time("D")) != 0 and timeframe.isintraday
isToday = year(timenow) == year(time) and month(timenow) == month(time) and dayofmonth(timenow) == dayofmonth(time) and session.ismarket

// ORB logic
var float orbHighPrice = na
var float orbLowPrice = na
var box dailyBox = na
is_first = in_session and not in_session[1] and session.ismarket

if is_first
    orbHighPrice := high
    orbLowPrice := low
else
    orbHighPrice := orbHighPrice[1]
    orbLowPrice := orbLowPrice[1]
if high > orbHighPrice and in_session
    orbHighPrice := high
if low < orbLowPrice and in_session
    orbLowPrice := low

// Draw ORB box
drawOrbs = showPreviousDayORBs or (not showPreviousDayORBs and isToday)
if drawOrbs and showShadedBox
    if is_first
        dailyBox := box.new(left=bar_index, top=orbHighPrice, right=bar_index + 1, bottom=orbLowPrice, border_width=2)
        box.set_right(dailyBox[1], bar_index[1])
    else
        box.set_top(dailyBox, orbHighPrice)
        box.set_rightbottom(dailyBox, right=bar_index + 1, bottom=orbLowPrice)
    box.set_bgcolor(dailyBox, color.new(shadeColor, 80))
    box.set_border_color(dailyBox, color.teal)

// Plot ORB levels and targets
plot(drawOrbs ? orbHighPrice : na, "ORB High", color.green, 2, plot.style_linebr)
plot(drawOrbs ? orbLowPrice : na, "ORB Low", color.red, 2, plot.style_linebr)
plot(showMidPoint and drawOrbs ? orbLowPrice + (orbHighPrice - orbLowPrice) * 0.5 : na, "ORB Mid Point", color.gray, 1, plot.style_linebr)
plot(showPriceTargets and drawOrbs ? orbHighPrice + (orbHighPrice - orbLowPrice) * 0.5 : na, "ORB High PT 50%", orb50Color, 2, plot.style_linebr)
plot(showPriceTargets and drawOrbs ? orbHighPrice + (orbHighPrice - orbLowPrice) * 1.0 : na, "ORB High PT 100%", orb100Color, 2, plot.style_linebr)
plot(showPriceTargetsExtended and drawOrbs ? orbHighPrice + (orbHighPrice - orbLowPrice) * 2.0 : na, "ORB High PT 200%", orb100Color, 2, plot.style_linebr)
plot(showPriceTargets and drawOrbs ? orbLowPrice - (orbHighPrice - orbLowPrice) * 0.5 : na, "ORB Low PT 50%", orb50Color, 2, plot.style_linebr)
plot(showPriceTargets and drawOrbs ? orbLowPrice - (orbHighPrice - orbLowPrice) * 1.0 : na, "ORB Low PT 100%", orb100Color, 2, plot.style_linebr)
plot(showPriceTargetsExtended and drawOrbs ? orbLowPrice - (orbHighPrice - orbLowPrice) * 2.0 : na, "ORB Low PT 200%", orb100Color, 2, plot.style_linebr)

// EMA filter
ema = ta.ema(close, emaLength)
bullishTrend = close > ema
bearishTrend = close < ema
plot(useEMAFilter ? ema : na, "50 EMA", color.yellow, 2)

// Volume confirmation
volumeSMA = ta.sma(volume, volumeSMALength)
volumeSpike = volume > volumeSMA

// Breakout and signal logic
var inBreakout = false
highCrossBO = low[2] < orbHighPrice and close[2] > orbHighPrice and low[1] > orbHighPrice and close[1] > orbHighPrice and close > low[1] and low > orbHighPrice and session.ismarket
lowCrossBO = high[2] > orbLowPrice and close[2] < orbLowPrice and high[1] < orbLowPrice and close[1] < orbLowPrice and close < high[1] and high < orbLowPrice and session.ismarket
isRetestOrbHigh = close[1] > orbHighPrice and low <= orbHighPrice and close >= orbHighPrice
isRetestOrbLow = close[1] < orbLowPrice and high >= orbLowPrice and close <= orbLowPrice
failedRetest = inBreakout and ((close[1] > orbHighPrice and close < orbHighPrice) or (close[1] < orbLowPrice and close > orbLowPrice))

buySignal = alertBreakoutsOnly ? highCrossBO and (not useEMAFilter or bullishTrend) and (not useVolumeConfirmation or volumeSpike) : ta.crossover(close, orbHighPrice) and (not useEMAFilter or bullishTrend) and (not useVolumeConfirmation or volumeSpike)
sellSignal = alertBreakoutsOnly ? lowCrossBO and (not useEMAFilter or bearishTrend) and (not useVolumeConfirmation or volumeSpike) : ta.crossunder(close, orbLowPrice) and (not useEMAFilter or bearishTrend) and (not useVolumeConfirmation or volumeSpike)

// Stop-loss and take-profit
orbRange = orbHighPrice - orbLowPrice
buyStopLoss = orbLowPrice
buyTakeProfit = orbHighPrice + orbRange * riskRewardRatio
sellStopLoss = orbHighPrice
sellTakeProfit = orbLowPrice - orbRange * riskRewardRatio

// Plot signals and stop-loss/take-profit
if buySignal
    inBreakout := true
    label.new(bar_index, high, "BUY", color=color.green, style=label.style_label_down, textcolor=color.white, size=size.small)
    label.new(bar_index, buyStopLoss, "SL", color=color.red, style=label.style_label_up, textcolor=color.white, size=size.tiny)
    label.new(bar_index, buyTakeProfit, "TP", color=color.blue, style=label.style_label_down, textcolor=color.white, size=size.tiny)

if sellSignal
    inBreakout := true
    label.new(bar_index, low, "SELL", color=color.red, style=label.style_label_up, textcolor=color.white, size=size.small)
    label.new(bar_index, sellStopLoss, "SL", color=color.green, style=label.style_label_down, textcolor=color.white, size=size.tiny)
    label.new(bar_index, sellTakeProfit, "TP", color=color.blue, style=label.style_label_up, textcolor=color.white, size=size.tiny)

if inBreakout and (isRetestOrbHigh or isRetestOrbLow)
    label.new(bar_index, close, "Retest", color=color.green, style=label.style_label_down, textcolor=color.white, size=size.tiny)
    inBreakout := false

if inBreakout and failedRetest
    label.new(bar_index, close, "Failed Retest", color=color.red, style=label.style_label_down, textcolor=color.white, size=size.tiny)
    inBreakout := false

// Alerts
alertcondition(buySignal, title="ORB Buy Signal", message="ORB Buy Signal at Price={{close}}")
alertcondition(sellSignal, title="ORB Sell Signal", message="ORB Sell Signal at Price={{close}}")
alertcondition(not in_session and session.ismarket and (highCrossBO or lowCrossBO), title="ORB Breakout", message="Price Breaking out of ORB Level")

// Plot ORB labels
if showLabels and drawOrbs
    label.new(bar_index, orbHighPrice, "ORB HIGH", color=color.green, style=label.style_label_lower_left, textcolor=color.white, size=size.tiny)
    label.new(bar_index, orbLowPrice, "ORB LOW", color=color.red, style=label.style_label_upper_left, textcolor=color.white, size=size.tiny)
````
