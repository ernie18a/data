# Multi-Timeframe Support & Resistance Indicator

- url: https://www.tradingview.com/script/BAX6htKc-Multi-Timeframe-Support-Resistance-Indicator/
- type: indicator
- pine_id: PUB;cc4c04f4b4dc4fb9b7c0b8adc6a7c4ec
- version: 1.0

## Description

Description:
Trading Price Action is a strategy that depends basically in levels where the price movement is rejected and those levels are called Support and Resistance.

- Support level happens when the price level move below the current price and find a level to prevent a further downward move due buyers step in pushing the price back upward.
 - Resistance level happens when the price move above the current price and find a level that prevents the price move further up due sellers step in pushing the price back downward.

Based on the main market trend those levels can be used to identify possible entries (preferably in the same direction of the main trend) or they can be used for Stoploss and Take profit levels.
So based on those concepts and my decision to trade only Price Action I decided to develop this indicator. On it I can see the main trend for the higher time frames like Monthly, Weekly and Daily.
That information is important to help me understand how the market is behaving on those timeframes widely used by trading companies and improve my chances to be on the right side of the trend.
When I am analyzing the charts I look for the below points:
    • what is the the main trends?
    • then I drop for my entry timeframe;
    • check for a rejection from Support or Resistance(based on the main trend direction);
    • set my entry: pending Limit or Stop or market
    • set your Stoploss and Take profit levels 
    • and, more important, wait for a new bar open.

To identify the Stoploss I use the ATR. The Average True Range measure market volatility meaning how much the market moved in a period of time and it is widely used for professional traders.
This indicator shows me the Daily ATR value as well as the current time frame ATR and to place my SL I use 1.5 * ATR(The current time frame ATR). With that I can avoid the SL chasers during the low volatility.
Also, based on the Daily ATR, I can see what was the total range (in pips and in %) and how many pips the price should move so I can have an idea the remaining pips I can get on a specific trade.
All those values are show in a table on my chart on the bottom right. There is a ”Fuel Gauge” for a more intuitive view about how many pips the price moved and how much “fuel” is still available.
I also added the ATR levels for not only place my SL but for a reference where price may be rejected. They are lines showing the % value for those levels and they work together with the Support and Resistance for Daily and H4. Those levels are some sort of “projections” based on the ATR.
The Main trend value for the 3 timeframes I check and they are located on the top right of my chart making easy to look so I know how the market may behave on my trading time frame(H4). One other thing on that feature is the colors. Uptrend is green and downtrend is red so if any one has a different color of the others I just move on and go to another pair.
Note that all those values and lines are customized and I have a full control to show or not them as well as change values if I think will improve my trade. This is a simple indicator that has been helping me trading Price Action.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cyberFX - 2019 - 2026

//@version=6
indicator("Multi-Timeframe Support & Resistance", overlay=true)

// Input parameters
lookback4h = input.int(40, "Lookback Bars (4H TF)", minval=1)
dailyLookback = input.int(40, "Lookback Daily Bars", minval=1)
weeklylookback = input.int(40, "Look back Weekly Bars", minval = 1)
monthlyLookback =  input.int(40, "Look back Monthly Bars", minval = 1)
thickness = input.int(2, "Line Thickness", minval=1, maxval=5)
sideOffset = input.int(8, "Side Offset", minval=4, maxval=20)
lblsidemove = input.int(20, "Current TF side offset", maxval=40)

// Color inputs
dailySupportColor    = input.color(color.blue,            "Support Color (Daily)")
dailyResistanceColor = input.color(color.rgb(8, 120, 4),  "Resistance Color (Daily)")
h4SupportColor       = input.color(color.blue,            "Support Color (H4)")
h4ResistanceColor    = input.color(color.rgb(8, 120, 4),  "Resistance Color (H4)")

// Style inputs
showDaily     = input.bool(true,    "Show Daily Sup/Res")
show4H        = input.bool(true,    "Show 4H Sup/Res")
showATR       = input.bool(true,    "Show ATR")
showATRLines  = input.bool(true,    "Show Daily ATR Projection Lines")
dailyLineStyle = input.string("Dotted", "Daily Line Style", options=["Solid", "Dashed", "Dotted"])

// ATR line colors
atrUpColor   = input.color(color.new(color.aqua,   0), "ATR Upper Line Color")
atrDownColor = input.color(color.new(color.orange, 0), "ATR Lower Line Color")
atrMidColor  = input.color(color.new(color.gray,  40), "ATR 50% Line Color")

// Convert string line style
getLineStyle(style) =>
    style == "Solid" ? line.style_solid : style == "Dashed" ? line.style_dashed : line.style_dotted

// ─── ATR Calculations ─────────────────────────────────────────────────────
atrLength   = input.int(14, title="ATR Length")
stoplossAtr = input.float(1.5, "S.L. ATR")

rawAtr     = ta.atr(atrLength)
atrInPips  = rawAtr / syminfo.mintick
dailyAtr   = request.security(syminfo.tickerid, "D", ta.atr(atrLength))
datrPips   = dailyAtr / syminfo.mintick

formatrpips = math.round(atrInPips)
AtrDPips    = math.round(datrPips)

slok       = stoplossAtr * atrInPips
formatslok = math.round(slok)

// ─── Daily range consumed ─────────────────────────────────────────────────
dailyHighNow  = request.security(syminfo.tickerid, "D", high)
dailyLowNow   = request.security(syminfo.tickerid, "D", low)
dailyOpenNow  = request.security(syminfo.tickerid, "D", open)

rangeUsedRaw  = dailyHighNow - dailyLowNow
rangeUsedPips = math.round(rangeUsedRaw / syminfo.mintick)
rangeUsedPct  = math.round(rangeUsedRaw / dailyAtr * 100)
remainingPips = math.max(0, AtrDPips - rangeUsedPips)

// ─── ATR Projection Levels (from today's open) ────────────────────────────
atrUpper100 = dailyOpenNow + dailyAtr
atrLower100 = dailyOpenNow - dailyAtr
atrUpper50  = dailyOpenNow + dailyAtr * 0.5
atrLower50  = dailyOpenNow - dailyAtr * 0.5

// ─── Draw ATR projection lines ────────────────────────────────────────────
var line lineU100 = na
var line lineL100 = na
var line lineU50  = na
var line lineL50  = na
var label lblU100 = na
var label lblL100 = na
var label lblU50  = na
var label lblL50  = na

if barstate.islast and showATRLines
    // Delete old lines/labels
    line.delete(lineU100)
    line.delete(lineL100)
    line.delete(lineU50)
    line.delete(lineL50)
    label.delete(lblU100)
    label.delete(lblL100)
    label.delete(lblU50)
    label.delete(lblL50)

    lineU100 := line.new(bar_index - 10, atrUpper100, bar_index + 30, atrUpper100,
         color=atrUpColor, width=1, style=line.style_dashed)
    lineL100 := line.new(bar_index - 10, atrLower100, bar_index + 30, atrLower100,
         color=atrDownColor, width=1, style=line.style_dashed)
    lineU50  := line.new(bar_index - 10, atrUpper50,  bar_index + 30, atrUpper50,
         color=atrMidColor, width=1, style=line.style_dotted)
    lineL50  := line.new(bar_index - 10, atrLower50,  bar_index + 30, atrLower50,
         color=atrMidColor, width=1, style=line.style_dotted)

    lblU100 := label.new(bar_index + 12, atrUpper100,
         text="ATR +100% " + str.tostring(math.round(atrUpper100, 5)),
         color=atrUpColor, textcolor=color.black, style=label.style_label_left, size=size.small)
    lblL100 := label.new(bar_index + 12, atrLower100,
         text="ATR -100% " + str.tostring(math.round(atrLower100, 5)),
         color=atrDownColor, textcolor=color.black, style=label.style_label_left, size=size.small)
    lblU50  := label.new(bar_index + 12, atrUpper50,
         text="ATR +50% " + str.tostring(math.round(atrUpper50, 5)),
         color=atrMidColor, textcolor=color.white, style=label.style_label_left, size=size.small)
    lblL50  := label.new(bar_index + 12, atrLower50,
         text="ATR -50% " + str.tostring(math.round(atrLower50, 5)),
         color=atrMidColor, textcolor=color.white, style=label.style_label_left, size=size.small)

// ─── Support & Resistance ─────────────────────────────────────────────────
h4High = timeframe.period == "240" ? ta.highest(high, lookback4h) : request.security(syminfo.tickerid, "240", ta.highest(high, lookback4h))
h4Low  = timeframe.period == "240" ? ta.lowest(low,  lookback4h)  : request.security(syminfo.tickerid, "240", ta.lowest(low,  lookback4h))

if barstate.islastconfirmedhistory and show4H
    lineStyle = getLineStyle(dailyLineStyle)
    line.new(bar_index - lookback4h + 1, h4High, bar_index + 50, h4High,
         color=h4ResistanceColor, width=thickness, style=lineStyle)
    line.new(bar_index - lookback4h + 1, h4Low,  bar_index + 50, h4Low,
         color=h4SupportColor,    width=thickness, style=lineStyle)
    label.new(bar_index + sideOffset, h4High,
         text=str.format("H4 Resistance: {0}", str.tostring(h4High, format.mintick)),
         color=h4ResistanceColor, textcolor=color.white, style=label.style_label_down, yloc=yloc.price)
    label.new(bar_index + sideOffset, h4Low,
         text=str.format("H4 Support: {0}", str.tostring(h4Low, format.mintick)),
         color=h4SupportColor, textcolor=color.white, style=label.style_label_up, yloc=yloc.price)

dailyHigh = timeframe.period == "D" ? ta.highest(high, dailyLookback) : request.security(syminfo.tickerid, "D", ta.highest(high, dailyLookback))
dailyLow  = timeframe.period == "D" ? ta.lowest(low,  dailyLookback)  : request.security(syminfo.tickerid, "D", ta.lowest(low,  dailyLookback))

if barstate.islastconfirmedhistory and showDaily and (timeframe.period != "D")
    lineStyle = getLineStyle(dailyLineStyle)
    line.new(bar_index - dailyLookback + 1, dailyHigh, bar_index + 50, dailyHigh,
         color=dailyResistanceColor, width=thickness, style=lineStyle)
    line.new(bar_index - dailyLookback + 1, dailyLow,  bar_index + 50, dailyLow,
         color=dailySupportColor,    width=thickness, style=lineStyle)
    label.new(bar_index + sideOffset, dailyHigh,
         text=str.format("Daily Resistance: {0}", str.tostring(dailyHigh, format.mintick)),
         color=dailyResistanceColor, textcolor=color.white, style=label.style_label_down, yloc=yloc.price)
    label.new(bar_index + sideOffset, dailyLow,
         text=str.format("Daily Support: {0}", str.tostring(dailyLow, format.mintick)),
         color=dailySupportColor, textcolor=color.white, style=label.style_label_up, yloc=yloc.price)

// ─── Info Table (expanded) ────────────────────────────────────────────────
// Fuel gauge bar: filled blocks out of 10
fuelPct      = math.min(rangeUsedPct, 100)
filledBlocks = math.round(fuelPct / 10)
gauge        = ""
for i = 1 to 10
    gauge += i <= filledBlocks ? "█" : "░"

gaugeColor = fuelPct < 50 ? color.new(color.lime, 0) : fuelPct < 80 ? color.new(color.yellow, 0) : color.new(color.red, 0)

var table info = table.new(position.bottom_right, 2, 8,
     bgcolor=color.new(color.black, 55),
     border_color=color.new(color.white, 75), border_width=1,
     frame_color=color.new(color.white, 55),  frame_width=1)

if barstate.islast
    // Header
    table.cell(info, 0, 0, "ATR Analysis",        text_color=color.white,  text_size=size.small, bgcolor=color.new(color.gray, 60))
    table.cell(info, 1, 0, "",                     text_color=color.white,  text_size=size.small, bgcolor=color.new(color.gray, 60))

    // ATR rows
    table.cell(info, 0, 1, "TF ATR (pips)",        text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 1, str.tostring(formatrpips / 10), text_color=color.red, text_size=size.small)

    table.cell(info, 0, 2, "Daily ATR (pips)",     text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 2, str.tostring(AtrDPips / 10),    text_color=color.red, text_size=size.small)

    table.cell(info, 0, 3, "Best S/L (pips)",      text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 3, str.tostring(formatslok / 10),  text_color=color.lime, text_size=size.small)

    // Separator
    table.cell(info, 0, 4, "── Daily Range ──",    text_color=color.new(color.gray, 20), text_size=size.small)
    table.cell(info, 1, 4, "",                      text_color=color.white, text_size=size.small)

    // Range consumed
    table.cell(info, 0, 5, "Range Used",            text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 5, str.tostring(rangeUsedPips / 10) + " pips  (" + str.tostring(rangeUsedPct) + "%)", text_color=gaugeColor, text_size=size.small)

    // Fuel gauge
    table.cell(info, 0, 6, "Fuel Gauge",            text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 6, gauge,                   text_color=gaugeColor,   text_size=size.small)

    // Remaining
    table.cell(info, 0, 7, "Remaining",             text_color=color.white,  text_size=size.small)
    table.cell(info, 1, 7, str.tostring(remainingPips / 10) + " pips", text_color=gaugeColor, text_size=size.small)

// ─── Daily & Weekly Trend ─────────────────────────────────────────────────
emaLen     = input.int(200, "Daily EMA Length", minval=1)
showEMA    = input.bool(false, "Show Daily EMA line")
showLabel  = input.bool(true,  "Show Trend Labels")

dailyClose = request.security(syminfo.tickerid, "D", close)
dailyEma   = request.security(syminfo.tickerid, "D", ta.ema(close, emaLen))

weeklyClose = request.security(syminfo.tickerid, "W", close)
weeklyEma   = request.security(syminfo.tickerid, "W", ta.ema(close, emaLen))

monthlyClose = request.security(syminfo.tickerid, "M",close)
monthlyEma = request.security(syminfo.tickerid, "M", ta.ema(close, emaLen))

dailyTrendUp   = dailyClose > dailyEma
dailyTrendDown = dailyClose < dailyEma

weeklyTrendUp   = weeklyClose > weeklyEma
weeklyTrendDown = weeklyClose < weeklyEma

monthTrendUp   = monthlyClose > monthlyEma
monthTrendDown = monthlyClose < monthlyEma

plot(showEMA ? dailyEma : na, title="Daily EMA", color=color.new(color.orange, 0), linewidth=1)

// ─── Combined Trend Table (Weekly on top, Daily below) ────────────────────
var table trendTable = table.new(position.top_right, 1, 3)

if showLabel and barstate.islast
    weeklyTrendText  = weeklyTrendUp ? "🟢 WEEKLY TREND: UP" : weeklyTrendDown ? "🔴 WEEKLY TREND: DOWN" : "⚪ WEEKLY TREND: FLAT"
    weeklyTrendColor = weeklyTrendUp ? color.new(color.green, 0) : weeklyTrendDown ? color.new(color.red, 0) : color.new(color.gray, 0)

    dailyTrendText  = dailyTrendUp ? "🟢 DAILY TREND: UP" : dailyTrendDown ? "🔴 DAILY TREND: DOWN" : "⚪ DAILY TREND: FLAT"
    dailyTrendColor = dailyTrendUp ? color.new(color.green, 0) : dailyTrendDown ? color.new(color.red, 0) : color.new(color.gray, 0)

    monthTrendText  = monthTrendUp ? "🟢 MONTHLY TREND: UP" : monthTrendDown ? "🔴 MONTHLY TREND: DOWN" : "⚪ MONTHLY TREND: FLAT"
    monthTrendColor = monthTrendUp ? color.new(color.green, 0) : monthTrendDown ? color.new(color.red, 0) : color.new(color.gray, 0)

    table.cell(trendTable, 0, 0, text=weeklyTrendText, text_color=color.white, bgcolor=weeklyTrendColor, text_size=size.normal)
    table.cell(trendTable, 0, 1, text=dailyTrendText,  text_color=color.white, bgcolor=dailyTrendColor,  text_size=size.normal)
    table.cell(trendTable, 0, 2, text=monthTrendText,  text_color=color.white, bgcolor=monthTrendColor,  text_size=size.normal)
````
