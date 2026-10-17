# Candlist FX - Candle Time & Countdown

- url: https://www.tradingview.com/script/VNX8p1Y8-Candlist-FX-Candle-Time-Countdown/
- type: indicator
- pine_id: PUB;cb70cb0a42c04ee78ed8cdbe06c758a2
- version: 1.0

## Description

Displays the current candle's open time and a live countdown to candle close, with the timeframe label formatted MT4-style (M1, M5, M15, H1, H4, D1, W1, M1).


This indicator displays a compact info table showing:
- Timeframe – formatted in a broker-style convention (M for minutes, H for hours, D for daily, W for weekly, M for monthly)
- Candle Open – the opening time of the current candle, in your selected timezone
- Closing In – a live countdown showing how much time remains until the current candle closes

HOW IT WORKS
The script first detects the chart's active timeframe (seconds, minutes, hours, daily, weekly, or monthly) and uses that to choose the most readable countdown format:
- Daily/Weekly/Monthly → shown as days/hours/minutes
- Hourly timeframes (60min multiples, e.g. H1–H4) → shown as H:MM:SS
- Minute/second timeframes → shown as M:SS

The countdown is calculated using TradingView's built-in `time_close` and `timenow` variables, so it stays accurate across any symbol or timeframe without manual calculation.

NOTE ON BACKTESTING
The countdown only reflects real elapsed time, so it's only meaningful on the live, currently forming candle. On historical bars (backtesting, Bar Replay, or scrolled-back charts) the countdown cell will show "—" instead of a number, since there's no real-time clock ticking on closed historical candles. The candle open time, however, is always accurate on every bar.

SETTINGS
- Table position (Top/Bottom, Left/Right)
- Text size
- Timezone for candle open time
- Custom colors for background, accent, and countdown text

This is a simple utility tool intended to help traders quickly see how much time is left before the current candle closes, useful for scalping, session timing, and price action entries near candle close.

## Source Code

````pine
//@version=6
indicator("Candlist FX - Candle Time & Countdown", overlay=true, max_labels_count=50)

// ============================================================
//                        INPUTS / SETTINGS
// ============================================================
displayGroup = "Display"
tablePosition = input.string("Bottom Right", "Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=displayGroup)
textSize      = input.string("Normal", "Text Size", options=["Tiny", "Small", "Normal", "Large"], group=displayGroup)
timezoneInput = input.string("Asia/Jakarta", "Timezone (e.g. Asia/Jakarta, UTC, America/New_York)", group=displayGroup)

backgroundColor = input.color(color.new(#0C0A33, 0), "Background Color", group=displayGroup)
accentColor     = input.color(#C9A962, "Accent Color (Gold)", group=displayGroup)
countdownColor  = input.color(#FF6B6B, "Countdown Color", group=displayGroup)

// ============================================================
//              STEP 1: CHECK THE CHART TIMEFRAME FIRST
// ============================================================
// We detect the active chart timeframe first, since the most
// readable countdown format differs depending on the timeframe
// (seconds/minutes/hours vs daily/weekly/monthly).
//
// NOTE: Pine Script has no standalone timeframe.ishours.
// "Hourly" timeframes like 1H/4H are actually registered as
// timeframe.isminutes with timeframe.multiplier 60/240/etc, so
// we detect them via a combination of isintraday + multiplier.
isIntraday = timeframe.isintraday          // covers seconds & minutes (including "hourly" TFs)
isDaily    = timeframe.isdaily
isWeekly   = timeframe.isweekly
isMonthly  = timeframe.ismonthly

// A timeframe is treated as "hourly" when it's intraday and the multiplier is >= 60 minutes
isHourly = isIntraday and timeframe.isminutes and timeframe.multiplier >= 60

// ------------------------------------------------------------
// Broker-style timeframe label (M1, M5, M15, M30, H1, H4, D1, W1, M1)
// Rules:
//  - Monthly -> "M" + number   (e.g. M1, M3)
//  - Weekly  -> "W" + number   (e.g. W1)
//  - Daily   -> "D" + number   (e.g. D1)
//  - Hourly (multiples of 60 minutes) -> "H" + hour count (e.g. H1, H4)
//  - Seconds -> "S" + number   (e.g. S30)
//  - Regular minutes (not an exact hour) -> "M" + minute count (e.g. M5, M15)
getTimeframeLabel() =>
    string label = na
    if isMonthly
        label := "M" + str.tostring(timeframe.multiplier)
    else if isWeekly
        label := "W" + str.tostring(timeframe.multiplier)
    else if isDaily
        label := "D" + str.tostring(timeframe.multiplier)
    else if isHourly
        label := "H" + str.tostring(math.round(timeframe.multiplier / 60))
    else if timeframe.isseconds
        label := "S" + str.tostring(timeframe.multiplier)
    else
        label := "M" + str.tostring(timeframe.multiplier)  // regular minutes, not a full hour
    label

timeframeLabel = getTimeframeLabel()

// ============================================================
//              STEP 2: GET CANDLE OPEN & CLOSE TIME
// ============================================================
// time and time_close automatically adjust to the chart's
// timeframe, so there's no need to calculate them manually.
candleOpenTime  = time
candleCloseTime = time_close

// ============================================================
//              STEP 3: CALCULATE THE COUNTDOWN
// ============================================================
remainingMs  = candleCloseTime - timenow
remainingSec = math.max(math.floor(remainingMs / 1000), 0)

// Helper: pad a number to 2 digits (e.g. 5 -> "05")
pad2(n) =>
    n < 10 ? "0" + str.tostring(n) : str.tostring(n)

// Format the countdown; the display shape depends on the timeframe checked in STEP 1
formatCountdown(sec) =>
    string result = na
    if isDaily or isWeekly or isMonthly
        d = math.floor(sec / 86400)
        h = math.floor((sec % 86400) / 3600)
        m = math.floor((sec % 3600) / 60)
        result := d > 0 ? str.format("{0}d {1}:{2}", d, pad2(h), pad2(m)) : str.format("{0}:{1}:{2}", h, pad2(m), pad2(sec % 60))
    else if isHourly
        h = math.floor(sec / 3600)
        m = math.floor((sec % 3600) / 60)
        s = sec % 60
        result := str.format("{0}:{1}:{2}", h, pad2(m), pad2(s))
    else
        m = math.floor(sec / 60)
        s = sec % 60
        result := str.format("{0}:{1}", m, pad2(s))
    result

countdownText = barstate.isrealtime ? formatCountdown(remainingSec) : "—"

// Format the candle open time (HH:mm:ss) in the selected timezone
openTimeText = str.format("{0}:{1}:{2}", pad2(hour(candleOpenTime, timezoneInput)), pad2(minute(candleOpenTime, timezoneInput)), pad2(second(candleOpenTime, timezoneInput)))

// ============================================================
//                     STEP 4: DRAW THE TABLE
// ============================================================
tablePositionMap = tablePosition == "Top Right" ? position.top_right : tablePosition == "Top Left" ? position.top_left : tablePosition == "Bottom Right" ? position.bottom_right : position.bottom_left
textSizeOption   = textSize == "Tiny" ? size.tiny : textSize == "Small" ? size.small : textSize == "Large" ? size.large : size.normal

var table infoTable = table.new(tablePositionMap, 2, 3, border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Timeframe", text_color=accentColor, bgcolor=backgroundColor, text_size=textSizeOption)
    table.cell(infoTable, 1, 0, timeframeLabel, text_color=color.white, bgcolor=backgroundColor, text_size=textSizeOption)

    table.cell(infoTable, 0, 1, "Candle Open", text_color=accentColor, bgcolor=backgroundColor, text_size=textSizeOption)
    table.cell(infoTable, 1, 1, openTimeText, text_color=color.white, bgcolor=backgroundColor, text_size=textSizeOption)

    table.cell(infoTable, 0, 2, "Closing In", text_color=accentColor, bgcolor=backgroundColor, text_size=textSizeOption)
    table.cell(infoTable, 1, 2, countdownText, text_color=barstate.isrealtime ? countdownColor : color.gray, text_size=textSizeOption)
````
