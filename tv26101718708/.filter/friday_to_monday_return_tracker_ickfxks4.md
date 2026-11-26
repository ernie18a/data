# Friday to Monday Return Tracker

- url: https://www.tradingview.com/script/ICKFXks4-Friday-to-Monday-Return-Tracker/
- type: indicator
- pine_id: PUB;f200c6838f954db9bbb97a25d6f9a87b
- version: 1.0

## Description

Mystic Friday → Monday Return Tracker

This indicator studies how a symbol behaves after unusually weak Friday sessions. It detects Fridays where the daily close-to-close return is less than or equal to a user-defined threshold, then records the return of the next completed trading session after that Friday.

The default threshold is -4.75%, but it can be adjusted in the settings. When a qualifying Friday occurs, the script displays the Friday return and the following Monday/next-session return in a table. If the next session has not occurred yet, the result is shown as TBD. If the market is closed on Monday, the script uses the next available completed trading day, such as Tuesday.

How it works:
The script uses daily price data so the calculation remains consistent across chart timeframes. Friday return is calculated as the percentage change from the prior daily close to the Friday close. The following session return is calculated from the Friday close to the next completed trading session’s close.

What it shows:
• Date of the qualifying Friday
• Friday close-to-close return
• Monday or next-session return
• Optional chart labels for qualifying Fridays and next-session outcomes
• Optional bar highlighting

This tool is intended for historical research and market-behavior review. It does not generate trade signals, does not provide buy or sell recommendations, and does not predict future returns. Results vary by symbol, market regime, liquidity, and available historical data.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © MysticMads

//@version=6
indicator("Friday → Monday Return Tracker", shorttitle="FriMon", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
thresholdPct = input.float(-4.75, "Friday Return Threshold %", step=0.05)
maxRows      = input.int(15, "Table Rows", minval=5, maxval=50)

showLabels   = input.bool(true, "Show Friday / Monday Labels")
showTable    = input.bool(true, "Show Table")
showBg       = input.bool(false, "Highlight Bars")

tablePosOpt  = input.string("Top Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Helpers
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_pos(_p) =>
    switch _p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left

f_pct(_x) =>
    na(_x) ? "TBD" : (_x > 0 ? "+" : "") + str.tostring(_x, "#.##") + "%"

f_retColor(_x) =>
    na(_x) ? color.black : _x >= 0 ? color.new(color.green, 0) : color.new(color.red, 0)

f_cellBg(_x) =>
    na(_x) ? color.yellow : _x >= 0 ? color.new(color.lime, 85) : color.new(color.red, 88)

f_date(_t) =>
    str.format_time(_t, "EEE, MMM d yyyy", syminfo.timezone)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Daily Data
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dTime = request.security(syminfo.tickerid, "D", time, barmerge.gaps_off, barmerge.lookahead_off)
dHigh = request.security(syminfo.tickerid, "D", high, barmerge.gaps_off, barmerge.lookahead_off)
dLow  = request.security(syminfo.tickerid, "D", low, barmerge.gaps_off, barmerge.lookahead_off)

dClose     = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_off)
dClosePrev = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)
dDow       = request.security(syminfo.tickerid, "D", dayofweek, barmerge.gaps_off, barmerge.lookahead_off)

pTime = request.security(syminfo.tickerid, "D", time[1], barmerge.gaps_off, barmerge.lookahead_off)
pHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pLow  = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)

pClose     = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)
pClosePrev = request.security(syminfo.tickerid, "D", close[2], barmerge.gaps_off, barmerge.lookahead_off)
pDow       = request.security(syminfo.tickerid, "D", dayofweek[1], barmerge.gaps_off, barmerge.lookahead_off)

newDailyBar = ta.change(dTime) != 0

dReturnPct = not na(dClosePrev) and dClosePrev != 0 ? ((dClose / dClosePrev) - 1.0) * 100.0 : na
pReturnPct = not na(pClosePrev) and pClosePrev != 0 ? ((pClose / pClosePrev) - 1.0) * 100.0 : na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Storage
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var bool  waitingForMonday = false
var float eventFriClose    = na
var int   eventFriTime     = na
var int   pendingIndex     = na

var array<int>   dateArr = array.new_int()
var array<float> friArr  = array.new_float()
var array<float> monArr  = array.new_float()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Friday Detection
// Fires after a completed Friday candle.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isFridayShock = newDailyBar and pDow == dayofweek.friday and not na(pReturnPct) and pReturnPct <= thresholdPct

if isFridayShock
    alreadyStored = array.size(dateArr) > 0 and array.get(dateArr, array.size(dateArr) - 1) == pTime

    if not alreadyStored
        waitingForMonday := true
        eventFriClose    := pClose
        eventFriTime     := pTime

        array.push(dateArr, pTime)
        array.push(friArr, pReturnPct)
        array.push(monArr, na)

        pendingIndex := array.size(dateArr) - 1

        if showLabels
            label.new(
                 x=pTime,
                 y=pHigh,
                 text="F " + f_pct(pReturnPct),
                 xloc=xloc.bar_time,
                 style=label.style_label_down,
                 color=color.new(color.red, 0),
                 textcolor=color.white,
                 size=size.tiny
            )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Monday / Next Trading Day Capture
// Normal case: captures Monday close.
// Holiday case: if Monday was closed, captures Tuesday close.
// Logic: once the next completed trading candle AFTER the Friday exists,
// use that candle as the Monday/next-session return.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
isNextTradingDayAfterFriday =
     newDailyBar and
     waitingForMonday and
     not na(eventFriClose) and
     not na(eventFriTime) and
     pTime > eventFriTime and
     pDow != dayofweek.friday

if isNextTradingDayAfterFriday
    nextReturnPct = ((pClose / eventFriClose) - 1.0) * 100.0

    if not na(pendingIndex) and pendingIndex >= 0 and pendingIndex < array.size(monArr)
        array.set(monArr, pendingIndex, nextReturnPct)

    if showLabels
        labelText = pDow == dayofweek.monday ? "M " : "T+1 "
        label.new(
             x=pTime,
             y=nextReturnPct >= 0 ? pLow : pHigh,
             text=labelText + f_pct(nextReturnPct),
             xloc=xloc.bar_time,
             style=nextReturnPct >= 0 ? label.style_label_up : label.style_label_down,
             color=nextReturnPct >= 0 ? color.new(color.green, 0) : color.new(color.red, 0),
             textcolor=color.white,
             size=size.tiny
        )

    waitingForMonday := false
    eventFriClose    := na
    eventFriTime     := na
    pendingIndex     := na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Live / Most Recent Friday Row
// Shows latest qualifying Friday immediately with TBD.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
liveFridayQualifies =
     dDow == dayofweek.friday and
     not na(dReturnPct) and
     dReturnPct <= thresholdPct

storedLastDate = array.size(dateArr) > 0 ? array.get(dateArr, array.size(dateArr) - 1) : na
showLiveFridayRow = liveFridayQualifies and dTime != storedLastDate

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Optional Background Highlight
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgcolor(showBg and isFridayShock ? color.new(color.red, 86) : na)
bgcolor(showBg and isNextTradingDayAfterFriday ? color.new(color.yellow, 88) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Table
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table t = table.new(f_pos(tablePosOpt), 3, maxRows + 1, border_width=1)

if barstate.islast
    table.clear(t, 0, 0, 2, maxRows)

    if showTable
        table.cell(t, 0, 0, "Date", bgcolor=color.new(color.aqua, 75), text_color=color.black)
        table.cell(t, 1, 0, "Friday Return", bgcolor=color.new(color.aqua, 75), text_color=color.black)
        table.cell(t, 2, 0, "Mon/Next Return", bgcolor=color.new(color.aqua, 75), text_color=color.black)

        row = 1

        if showLiveFridayRow and row <= maxRows
            table.cell(
                 t,
                 0,
                 row,
                 f_date(dTime),
                 bgcolor=color.new(color.yellow, 0),
                 text_color=color.black
            )

            table.cell(
                 t,
                 1,
                 row,
                 f_pct(dReturnPct),
                 bgcolor=color.new(color.red, 88),
                 text_color=color.red
            )

            table.cell(
                 t,
                 2,
                 row,
                 "TBD",
                 bgcolor=color.yellow,
                 text_color=color.black
            )

            row += 1

        total = array.size(dateArr)

        if total > 0
            for r = 0 to total - 1
                if row <= maxRows
                    idx = total - 1 - r

                    dt = array.get(dateArr, idx)
                    fr = array.get(friArr, idx)
                    mr = array.get(monArr, idx)

                    table.cell(
                         t,
                         0,
                         row,
                         f_date(dt),
                         bgcolor=color.new(color.yellow, 25),
                         text_color=color.black
                    )

                    table.cell(
                         t,
                         1,
                         row,
                         f_pct(fr),
                         bgcolor=color.new(color.red, 88),
                         text_color=color.red
                    )

                    table.cell(
                         t,
                         2,
                         row,
                         f_pct(mr),
                         bgcolor=f_cellBg(mr),
                         text_color=f_retColor(mr)
                    )

                    row += 1
````
