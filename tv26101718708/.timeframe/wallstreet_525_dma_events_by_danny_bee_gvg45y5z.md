# WallStreet 5/25 DMA Events by Danny Bee

- url: https://www.tradingview.com/script/GVg45Y5Z-wallstreet-5-25-dma-events-by-danny-bee/
- type: indicator
- pine_id: PUB;036112945d3044cbae7488cf6ff6ba33
- version: 1.0

## Description

A fast momentum regime tool based on confirmed daily 5 DMA and 25 DMA cross events.

WallStreet 5/25 DMA Events — FROM DANNY BEE

This indicator is a fast momentum regime visualization tool based on the 5-day and 25-day moving averages.

It detects confirmed daily Bull Cross and Bear Cross events, plots the 5 DMA and 25 DMA on the chart, stores historical cross events, and tracks how price has performed since each event.

Main Features:

• Confirmed daily 5 DMA and 25 DMA
• Bull Cross and Bear Cross detection
• Momentum-On / Momentum-Off regime summary
• Historical event labels
• Event performance tracking from the cross price to the current price
• Current Close vs 25D distance label
• Event table with previous signals
• Customizable label detail: Minimal, Balanced, Detailed
• Customizable table position and text size
• Background highlight on new cross events
• Alerts for Bullish and Bearish 5/25 DMA cross events

How to Read It:

Bull Cross = 5 DMA crosses above 25 DMA  
This usually represents short-term / swing momentum turning positive.

Bear Cross = 5 DMA crosses below 25 DMA  
This usually represents short-term / swing momentum turning negative.

Momentum-On = 5 DMA is above or equal to 25 DMA  
Momentum-Off = 5 DMA is below 25 DMA

The event table shows previous cross events, their date, event price, 5D value, 25D value, distance from 25D, return since the event, number of days passed, and the regime type.

Purpose:

This script is designed as a market context tool, not as an automatic trading system.

The 5/25 DMA structure is faster and more sensitive than classic long-term moving average systems such as 50/200 DMA. It may provide earlier momentum shifts, but it can also generate more noise and more frequent signals.

Use this indicator to observe short-term and swing momentum regimes, not to blindly buy or sell.

Alerts:

The script includes alert conditions for confirmed Bullish and Bearish 5/25 DMA cross events.

Suggested alert setting:

Condition: WallStreet 5/25 DMA Events — FROM DANNY BEE  
Trigger: Once Per Bar Close

If dynamic alert messages are enabled in the script settings, alerts may include signal type, ticker, date, close, 5D, 25D, and distance from 25D.

Non-Repaint Design:

The indicator is designed to use confirmed daily data for its moving average values and cross events. This helps avoid signals based on unfinished daily candles.

TradingView may still show a general warning because the script uses higher timeframe data through request.security. This is normal for scripts that request daily data on lower timeframes.

Disclaimer:

This script is for educational and analytical purposes only. It is not financial advice. Markets involve risk, and past behavior after 5/25 DMA cross events does not guarantee future results.

Initial release.

Added confirmed daily 5/25 DMA momentum regime logic, Bull/Bear Cross events, historical labels, event table, Close vs 25D label, background highlights, and alert support.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mortalkid2
//@version=6
indicator("WallStreet 5/25 DMA Events — FROM DANNY BEE", overlay=true, max_labels_count=300)

//====================================================================
// Constants
//====================================================================
const int MS_IN_DAY = 86400000
const int MAX_STORED_EVENTS = 250
const int TABLE_COLS = 9
const int TABLE_MAX_ROWS = 30

//====================================================================
// Inputs
//====================================================================

//-------------------------
// GENERAL
//-------------------------
fastLen = input.int(5, "Fast DMA length", minval=1, group="GENERAL")
slowLen = input.int(25, "Slow DMA length", minval=1, group="GENERAL")

showFast = input.bool(true, "Show 5 DMA", group="GENERAL")
showSlow = input.bool(true, "Show 25 DMA", group="GENERAL")

//-------------------------
// EVENTS
//-------------------------
showEventLabels = input.bool(true, "Show historical event labels", group="EVENTS")

eventLabelMode = input.string(
     "Balanced",
     "Event label mode",
     options=["Minimal", "Balanced", "Detailed"],
     group="EVENTS"
)

maxEventLabels = input.int(
     50,
     "Max event labels",
     minval=1,
     maxval=250,
     group="EVENTS"
)

eventLabelSizeInput = input.string(
     "Small",
     "Label size",
     options=["Tiny", "Small", "Normal"],
     group="EVENTS"
)

labelTransparency = input.int(
     18,
     "Label transparency",
     minval=0,
     maxval=95,
     group="EVENTS"
)

labelOffsetMult = input.float(
     0.65,
     "Label vertical offset multiplier",
     minval=0.0,
     step=0.05,
     group="EVENTS"
)

//-------------------------
// TABLE
//-------------------------
showEventTable = input.bool(true, "Show event table", group="TABLE")

tableRows = input.int(
     8,
     "Table rows",
     minval=1,
     maxval=20,
     group="TABLE"
)

tableTextSizeInput = input.string(
     "Small",
     "Table text size",
     options=["Tiny", "Small", "Normal"],
     group="TABLE"
)

tablePositionInput = input.string(
     "Top Right",
     "Table position",
     options=["Top Right", "Middle Right", "Bottom Right"],
     group="TABLE"
)

//-------------------------
// CURRENT LABEL
//-------------------------
showCurrentLabel = input.bool(true, "Show current Close vs 25D label", group="CURRENT LABEL")

currentLabelRightOffset = input.int(
     5,
     "Current label right offset",
     minval=1,
     maxval=100,
     group="CURRENT LABEL"
)

//-------------------------
// BACKGROUND
//-------------------------
showCrossBg = input.bool(true, "Show cross background", group="BACKGROUND")

bgTransparency = input.int(
     92,
     "Background transparency",
     minval=70,
     maxval=100,
     group="BACKGROUND"
)

//-------------------------
// PRICE MODE
//-------------------------
currentPriceMode = input.string(
     "Current chart close",
     "Price mode",
     options=["Current chart close", "Confirmed daily close"],
     group="PRICE MODE"
)

//-------------------------
// ALERTS
//-------------------------
enableBullAlerts = input.bool(true, "Enable Bull Cross alerts", group="ALERTS")
enableBearAlerts = input.bool(true, "Enable Bear Cross alerts", group="ALERTS")

useDynamicAlerts = input.bool(
     true,
     "Use dynamic alert() messages",
     group="ALERTS"
)

//====================================================================
// Helper Functions
//====================================================================
f_labelSize() =>
    switch eventLabelSizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        => size.normal

f_tableTextSize() =>
    switch tableTextSizeInput
        "Tiny" => size.tiny
        "Small" => size.small
        => size.normal

f_tablePosition() =>
    switch tablePositionInput
        "Top Right" => position.top_right
        "Middle Right" => position.middle_right
        => position.bottom_right

f_price(float x) =>
    na(x) ? "n/a" : str.tostring(x, format.mintick)

f_pct(float x) =>
    na(x) ? "n/a" : (x > 0 ? "+" : "") + str.tostring(x, "#.##") + "%"

f_retPct(float nowValue, float baseValue) =>
    not na(nowValue) and not na(baseValue) and baseValue != 0.0 ? ((nowValue - baseValue) / baseValue) * 100.0 : na

f_daysSince(int eventTime) =>
    not na(eventTime) ? int(math.max(0, math.round((time - eventTime) / float(MS_IN_DAY)))) : na

f_labelText(int dir, int eventTime, float ret, int days) =>
    string shortName = dir == 1 ? "BULL" : "BEAR"
    string fullName = dir == 1 ? "Bull Cross" : "Bear Cross"
    string eventDate = str.format_time(eventTime, "yyyy-MM-dd")

    switch eventLabelMode
        "Minimal" =>
            shortName + "\n" + f_pct(ret)
        "Balanced" =>
            fullName + "\n" + f_pct(ret) + "\n" + str.tostring(days) + "d"
        =>
            fullName + "\n" + eventDate + "\n" + f_pct(ret) + "\n" + str.tostring(days) + "d"

f_eventBg(int dir, int transp) =>
    dir == 1 ? color.new(color.rgb(35, 135, 90), transp) : color.new(color.rgb(165, 55, 65), transp)

f_eventTextColor() =>
    color.rgb(245, 247, 250)

f_labelY(int dir, float eventPrice, float eventAtr) =>
    float safeAtr = na(eventAtr) or eventAtr == 0.0 ? eventPrice * 0.01 : eventAtr
    float offset = safeAtr * labelOffsetMult
    dir == 1 ? eventPrice - offset : eventPrice + offset

//====================================================================
// Daily Data — Confirmed Non-Repaint
//====================================================================
[dFast, dSlow, dClose, dTime, dAtr, dBullSignal, dBearSignal] = request.security(
     syminfo.tickerid,
     "D",
     [
         ta.sma(close, fastLen)[1],
         ta.sma(close, slowLen)[1],
         close[1],
         time[1],
         ta.atr(14)[1],
         ta.crossover(ta.sma(close, fastLen), ta.sma(close, slowLen))[1],
         ta.crossunder(ta.sma(close, fastLen), ta.sma(close, slowLen))[1]
     ],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

nowPrice = currentPriceMode == "Confirmed daily close" ? dClose : close

//====================================================================
// Base Visuals
//====================================================================
plot(
     showFast ? dFast : na,
     title="5 DMA Daily Confirmed",
     color=color.rgb(40, 120, 255),
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showSlow ? dSlow : na,
     title="25 DMA Daily Confirmed",
     color=color.rgb(245, 190, 45),
     linewidth=3,
     style=plot.style_linebr
)

//====================================================================
// Cross Logic
//====================================================================
isBullSignal = dBullSignal == true
isBearSignal = dBearSignal == true

eventSignal = (
     isBullSignal or isBearSignal
) and not na(dClose) and not na(dFast) and not na(dSlow) and not na(dTime)

var int lastStoredEventTime = na

newEvent = eventSignal and (na(lastStoredEventTime) or dTime != lastStoredEventTime)
newBullEvent = newEvent and isBullSignal
newBearEvent = newEvent and isBearSignal

//====================================================================
// Event Storage
//====================================================================
var label[] eventLabels = array.new_label()
var float[] eventPrices = array.new_float()
var int[] eventTimes = array.new_int()
var int[] eventDirs = array.new_int()
var float[] eventFastValues = array.new_float()
var float[] eventSlowValues = array.new_float()
var float[] eventVsSlowValues = array.new_float()
var float[] eventAtrValues = array.new_float()

if newEvent
    lastStoredEventTime := dTime

    int dir = isBullSignal ? 1 : -1
    float eventVsSlow = f_retPct(dClose, dSlow)
    float eventLabelY = f_labelY(dir, dClose, dAtr)

    label newLbl = na

    if showEventLabels
        newLbl := label.new(
             bar_index,
             eventLabelY,
             "",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=dir == 1 ? label.style_label_up : label.style_label_down,
             color=f_eventBg(dir, labelTransparency),
             textcolor=f_eventTextColor(),
             size=f_labelSize()
        )

    array.push(eventLabels, newLbl)
    array.push(eventPrices, dClose)
    array.push(eventTimes, dTime)
    array.push(eventDirs, dir)
    array.push(eventFastValues, dFast)
    array.push(eventSlowValues, dSlow)
    array.push(eventVsSlowValues, eventVsSlow)
    array.push(eventAtrValues, dAtr)

    if array.size(eventPrices) > MAX_STORED_EVENTS
        label oldLbl = array.shift(eventLabels)
        if not na(oldLbl)
            label.delete(oldLbl)

        array.shift(eventPrices)
        array.shift(eventTimes)
        array.shift(eventDirs)
        array.shift(eventFastValues)
        array.shift(eventSlowValues)
        array.shift(eventVsSlowValues)
        array.shift(eventAtrValues)

//====================================================================
// Label Limit Management
//====================================================================
if array.size(eventLabels) > 0
    int totalLabels = array.size(eventLabels)

    for i = 0 to totalLabels - 1
        label lbl = array.get(eventLabels, i)

        if i < totalLabels - maxEventLabels and not na(lbl)
            label.delete(lbl)
            array.set(eventLabels, i, na)

//====================================================================
// Background Signals
//====================================================================
bgcolor(
     showCrossBg and newBullEvent ? color.new(color.green, bgTransparency) :
     showCrossBg and newBearEvent ? color.new(color.red, bgTransparency) :
     na
)

//====================================================================
// Historical Event Labels
//====================================================================
if barstate.islast and array.size(eventPrices) > 0
    int eventCount = array.size(eventPrices)

    for i = 0 to eventCount - 1
        label lbl = array.get(eventLabels, i)

        if showEventLabels and not na(lbl)
            float ePrice = array.get(eventPrices, i)
            int eTime = array.get(eventTimes, i)
            int eDir = array.get(eventDirs, i)
            float eAtr = array.get(eventAtrValues, i)

            float sincePct = f_retPct(nowPrice, ePrice)
            int daysSince = f_daysSince(eTime)
            float y = f_labelY(eDir, ePrice, eAtr)

            label.set_text(lbl, f_labelText(eDir, eTime, sincePct, daysSince))
            label.set_y(lbl, y)
            label.set_color(lbl, f_eventBg(eDir, labelTransparency))
            label.set_textcolor(lbl, f_eventTextColor())
            label.set_size(lbl, f_labelSize())

        if not showEventLabels and not na(lbl)
            label.delete(lbl)
            array.set(eventLabels, i, na)

//====================================================================
// Current Close vs 25D Label
//====================================================================
closeVsSlow = f_retPct(nowPrice, dSlow)
isAboveSlow = not na(nowPrice) and not na(dSlow) and nowPrice >= dSlow

var label currentDistLabel = na

if showCurrentLabel and barstate.islast and not na(closeVsSlow)
    string currentTxt = (isAboveSlow ? "Above 25D" : "Below 25D") + "\n" + f_pct(closeVsSlow)
    color currentTextColor = isAboveSlow ? color.rgb(60, 205, 135) : color.rgb(240, 95, 105)

    if na(currentDistLabel)
        currentDistLabel := label.new(
             bar_index + currentLabelRightOffset,
             nowPrice,
             currentTxt,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=color.new(color.black, 82),
             textcolor=currentTextColor,
             size=size.small
        )
    else
        label.set_x(currentDistLabel, bar_index + currentLabelRightOffset)
        label.set_y(currentDistLabel, nowPrice)
        label.set_text(currentDistLabel, currentTxt)
        label.set_color(currentDistLabel, color.new(color.black, 82))
        label.set_textcolor(currentDistLabel, currentTextColor)
        label.set_size(currentDistLabel, size.small)

if not showCurrentLabel and not na(currentDistLabel)
    label.delete(currentDistLabel)
    currentDistLabel := na

//====================================================================
// Event Table
//====================================================================
var table evTable = table.new(
     f_tablePosition(),
     TABLE_COLS,
     TABLE_MAX_ROWS,
     border_width=1,
     frame_color=color.new(color.gray, 85),
     border_color=color.new(color.gray, 88)
)

if barstate.islast
    for c = 0 to TABLE_COLS - 1
        for r = 0 to TABLE_MAX_ROWS - 1
            table.cell(
                 evTable,
                 c,
                 r,
                 "",
                 text_color=color.rgb(235, 238, 245),
                 bgcolor=color.new(color.black, 100),
                 text_size=f_tableTextSize()
            )

    if showEventTable
        int totalEvents = array.size(eventPrices)

        bool regimeOn = not na(dFast) and not na(dSlow) and dFast >= dSlow
        string currentRegime = regimeOn ? "Momentum-On" : "Momentum-Off"
        color regimeBg = regimeOn ? color.new(color.rgb(35, 135, 90), 84) : color.new(color.rgb(165, 55, 65), 84)

        string lastSignal = "n/a"
        string lastRetTxt = "n/a"
        string lastDaysTxt = "n/a"

        if totalEvents > 0
            int lastIdx = totalEvents - 1
            int lastDir = array.get(eventDirs, lastIdx)
            float lastPrice = array.get(eventPrices, lastIdx)
            int lastTime = array.get(eventTimes, lastIdx)

            float lastRet = f_retPct(nowPrice, lastPrice)
            int lastDays = f_daysSince(lastTime)

            lastSignal := lastDir == 1 ? "Bull" : "Bear"
            lastRetTxt := f_pct(lastRet)
            lastDaysTxt := str.tostring(lastDays) + "d"

        color headBg = color.new(color.rgb(35, 38, 45), 15)
        color softBg = color.new(color.rgb(20, 22, 28), 20)
        color txt = color.rgb(235, 238, 245)

        // Summary row
        table.cell(evTable, 0, 0, "Regime", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 1, 0, currentRegime, text_color=txt, bgcolor=regimeBg, text_size=f_tableTextSize())

        table.cell(evTable, 2, 0, "vs25", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 3, 0, f_pct(closeVsSlow), text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        table.cell(evTable, 4, 0, "Last", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 5, 0, lastSignal, text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        table.cell(evTable, 6, 0, "Ret", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 7, 0, lastRetTxt, text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        table.cell(evTable, 8, 0, lastDaysTxt, text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        // Header row
        table.cell(evTable, 0, 2, "Event", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 1, 2, "Date", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 2, 2, "Price", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 3, 2, "5D", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 4, 2, "25D", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 5, 2, "vs25", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 6, 2, "Now%", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 7, 2, "Days", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 8, 2, "Regime", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())

        int rowsToShow = math.min(tableRows, math.min(totalEvents, TABLE_MAX_ROWS - 3))

        if rowsToShow > 0
            for r = 0 to rowsToShow - 1
                int idx = totalEvents - 1 - r

                float ePrice = array.get(eventPrices, idx)
                int eTime = array.get(eventTimes, idx)
                int eDir = array.get(eventDirs, idx)
                float eFast = array.get(eventFastValues, idx)
                float eSlow = array.get(eventSlowValues, idx)
                float eVsSlow = array.get(eventVsSlowValues, idx)

                float sincePct = f_retPct(nowPrice, ePrice)
                int daysSince = f_daysSince(eTime)

                bool isBull = eDir == 1
                string eventName = isBull ? "Bull" : "Bear"
                string regimeText = isBull ? "Momentum-On" : "Momentum-Off"
                string eDate = str.format_time(eTime, "yyyy-MM-dd")

                color rowBg = isBull ? color.new(color.rgb(35, 135, 90), 88) : color.new(color.rgb(165, 55, 65), 88)

                int row = r + 3

                table.cell(evTable, 0, row, eventName, text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 1, row, eDate, text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 2, row, f_price(ePrice), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 3, row, f_price(eFast), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 4, row, f_price(eSlow), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 5, row, f_pct(eVsSlow), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 6, row, f_pct(sincePct), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 7, row, str.tostring(daysSince), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 8, row, regimeText, text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())

//====================================================================
// Alerts — Confirmed One-Shot Logic
//====================================================================
bullAlertCondition = enableBullAlerts and newBullEvent and barstate.isconfirmed
bearAlertCondition = enableBearAlerts and newBearEvent and barstate.isconfirmed

eventVsSlowAlert = f_retPct(dClose, dSlow)

// Static TradingView alert conditions
alertcondition(
     bullAlertCondition,
     title="Bullish 5/25 DMA Cross — Confirmed",
     message="Bullish 5/25 DMA Cross confirmed: 5 DMA crossed above 25 DMA on confirmed daily data."
)

alertcondition(
     bearAlertCondition,
     title="Bearish 5/25 DMA Cross — Confirmed",
     message="Bearish 5/25 DMA Cross confirmed: 5 DMA crossed below 25 DMA on confirmed daily data."
)

// Dynamic alert() messages
if useDynamicAlerts and bullAlertCondition
    alert(
         "WallStreet 5/25 DMA Events — FROM DANNY BEE\n" +
         "Signal: Bullish 5/25 DMA Cross CONFIRMED\n" +
         "Ticker: " + syminfo.tickerid + "\n" +
         "Date: " + str.format_time(dTime, "yyyy-MM-dd") + "\n" +
         "Close: " + f_price(dClose) + "\n" +
         "5D: " + f_price(dFast) + "\n" +
         "25D: " + f_price(dSlow) + "\n" +
         "Close vs 25D: " + f_pct(eventVsSlowAlert),
         alert.freq_once_per_bar_close
    )

if useDynamicAlerts and bearAlertCondition
    alert(
         "WallStreet 5/25 DMA Events — FROM DANNY BEE\n" +
         "Signal: Bearish 5/25 DMA Cross CONFIRMED\n" +
         "Ticker: " + syminfo.tickerid + "\n" +
         "Date: " + str.format_time(dTime, "yyyy-MM-dd") + "\n" +
         "Close: " + f_price(dClose) + "\n" +
         "5D: " + f_price(dFast) + "\n" +
         "25D: " + f_price(dSlow) + "\n" +
         "Close vs 25D: " + f_pct(eventVsSlowAlert),
         alert.freq_once_per_bar_close
    )
````
