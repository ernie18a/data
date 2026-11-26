# WallStreet 50/200 DMA Events

- url: https://www.tradingview.com/script/ygUiCoAY-wallstreet-50-200-dma-events/
- type: indicator
- pine_id: PUB;ebbf456f964e40fcaa0ab49d1091dd6d
- version: 1.0

## Description

WallStreet 50/200 DMA Events — FROM DANNY BEE

This indicator is a long-term market regime visualization tool based on the classic 50-day and 200-day moving averages.

It detects confirmed daily Golden Cross and Death Cross events, plots the 50 DMA and 200 DMA on the chart, stores historical cross events, and tracks how price has performed since each event.

Main Features:

• Confirmed daily 50 DMA and 200 DMA
• Golden Cross and Death Cross detection
• Historical event labels
• Event performance tracking from the cross price to the current price
• Current Close vs 200D distance label
• Risk-On / Risk-Off regime table
• Customizable label detail: Minimal, Balanced, Detailed
• Customizable table position and text size
• Background highlight on new cross events
• Alerts for Golden Cross and Death Cross events

How to Read It:

Golden Cross = 50 DMA crosses above 200 DMA
This usually represents a long-term Risk-On regime.

Death Cross = 50 DMA crosses below 200 DMA
This usually represents a long-term Risk-Off regime.

The event table shows previous cross events, their date, event price, 50D value, 200D value, distance from 200D, return since the event, number of days passed, and the regime type.

Non-Repaint Logic:

The indicator uses confirmed daily data. The moving averages and cross signals are based on completed daily candles, not unfinished intraday movement. This makes the tool cleaner for long-term regime analysis.

Purpose:

This script is not designed to predict every market move or generate automatic buy/sell signals. It is designed to help traders and investors understand the broader market structure, identify major regime shifts, and study how price behaved after previous 50/200 DMA events.

This is a context tool, not a trading system by itself.

Use it together with risk management, market structure, macro context, and your own trading or investing plan.

Disclaimer:

This script is for educational and analytical purposes only. It is not financial advice. Markets involve risk, and past performance after Golden Cross or Death Cross events does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("WallStreet 50/200 DMA Events — FROM DANNY BEE", overlay=true, max_labels_count=300)

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
fastLen = input.int(50, "Fast DMA length", minval=1, group="GENERAL")
slowLen = input.int(200, "Slow DMA length", minval=1, group="GENERAL")

showFast = input.bool(true, "Show 50 DMA", group="GENERAL")
showSlow = input.bool(true, "Show 200 DMA", group="GENERAL")

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
showCurrentLabel = input.bool(true, "Show current Close vs 200D label", group="CURRENT LABEL")

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
    string shortName = dir == 1 ? "G" : "D"
    string fullName = dir == 1 ? "Golden" : "Death"
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
[dFast, dSlow, dClose, dTime, dAtr, dGoldenSignal, dDeathSignal] = request.security(
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
     title="50 DMA Daily Confirmed",
     color=color.rgb(40, 120, 255),
     linewidth=2,
     style=plot.style_linebr
)

plot(
     showSlow ? dSlow : na,
     title="200 DMA Daily Confirmed",
     color=color.rgb(245, 190, 45),
     linewidth=3,
     style=plot.style_linebr
)

//====================================================================
// Cross Logic
//====================================================================
isGoldenSignal = dGoldenSignal == true
isDeathSignal = dDeathSignal == true

eventSignal = (
     isGoldenSignal or isDeathSignal
) and not na(dClose) and not na(dFast) and not na(dSlow) and not na(dTime)

var int lastStoredEventTime = na

newEvent = eventSignal and (na(lastStoredEventTime) or dTime != lastStoredEventTime)
newGoldenEvent = newEvent and isGoldenSignal
newDeathEvent = newEvent and isDeathSignal

//====================================================================
// Event Storage
//====================================================================
var label[] eventLabels = array.new_label()
var float[] eventPrices = array.new_float()
var int[] eventTimes = array.new_int()
var int[] eventDirs = array.new_int()
var float[] eventFastValues = array.new_float()
var float[] eventSlowValues = array.new_float()
var float[] eventVs200Values = array.new_float()
var float[] eventAtrValues = array.new_float()

if newEvent
    lastStoredEventTime := dTime

    int dir = isGoldenSignal ? 1 : -1
    float eventVs200 = f_retPct(dClose, dSlow)
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
    array.push(eventVs200Values, eventVs200)
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
        array.shift(eventVs200Values)
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
     showCrossBg and newGoldenEvent ? color.new(color.green, bgTransparency) :
     showCrossBg and newDeathEvent ? color.new(color.red, bgTransparency) :
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
// Current Close vs 200D Label
//====================================================================
closeVs200 = f_retPct(nowPrice, dSlow)
isAbove200 = not na(nowPrice) and not na(dSlow) and nowPrice >= dSlow

var label currentDistLabel = na

if showCurrentLabel and barstate.islast and not na(closeVs200)
    string currentTxt = (isAbove200 ? "Above 200D" : "Below 200D") + "\n" + f_pct(closeVs200)
    color currentTextColor = isAbove200 ? color.rgb(60, 205, 135) : color.rgb(240, 95, 105)

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
        string currentRegime = regimeOn ? "Risk-On" : "Risk-Off"
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

            lastSignal := lastDir == 1 ? "Golden" : "Death"
            lastRetTxt := f_pct(lastRet)
            lastDaysTxt := str.tostring(lastDays) + "d"

        color headBg = color.new(color.rgb(35, 38, 45), 15)
        color softBg = color.new(color.rgb(20, 22, 28), 20)
        color txt = color.rgb(235, 238, 245)

        // Summary row
        table.cell(evTable, 0, 0, "Regime", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 1, 0, currentRegime, text_color=txt, bgcolor=regimeBg, text_size=f_tableTextSize())

        table.cell(evTable, 2, 0, "vs200", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 3, 0, f_pct(closeVs200), text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        table.cell(evTable, 4, 0, "Last", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 5, 0, lastSignal, text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        table.cell(evTable, 6, 0, "Ret", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 7, 0, lastRetTxt, text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        table.cell(evTable, 8, 0, lastDaysTxt, text_color=txt, bgcolor=softBg, text_size=f_tableTextSize())

        // Header row
        table.cell(evTable, 0, 2, "Event", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 1, 2, "Date", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 2, 2, "Price", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 3, 2, "50D", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 4, 2, "200D", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
        table.cell(evTable, 5, 2, "vs200", text_color=txt, bgcolor=headBg, text_size=f_tableTextSize())
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
                float eVs200 = array.get(eventVs200Values, idx)

                float sincePct = f_retPct(nowPrice, ePrice)
                int daysSince = f_daysSince(eTime)

                bool isGolden = eDir == 1
                string eventName = isGolden ? "Golden" : "Death"
                string regimeText = isGolden ? "Risk-On" : "Risk-Off"
                string eDate = str.format_time(eTime, "yyyy-MM-dd")

                color rowBg = isGolden ? color.new(color.rgb(35, 135, 90), 88) : color.new(color.rgb(165, 55, 65), 88)

                int row = r + 3

                table.cell(evTable, 0, row, eventName, text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 1, row, eDate, text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 2, row, f_price(ePrice), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 3, row, f_price(eFast), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 4, row, f_price(eSlow), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 5, row, f_pct(eVs200), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 6, row, f_pct(sincePct), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 7, row, str.tostring(daysSince), text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())
                table.cell(evTable, 8, row, regimeText, text_color=txt, bgcolor=rowBg, text_size=f_tableTextSize())

//====================================================================
// Alerts
//====================================================================
alertcondition(newGoldenEvent, title="Golden Cross", message="50 DMA crossed above 200 DMA on confirmed daily data")
alertcondition(newDeathEvent, title="Death Cross", message="50 DMA crossed below 200 DMA on confirmed daily data")
````
