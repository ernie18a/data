# ORB+ - ORB TRADING STRATEGY

- url: https://www.tradingview.com/script/KZ5USnmK-ORB-ORB-TRADING-STRATEGY/
- type: indicator
- pine_id: PUB;adac59d2fa2546219017ec8c46e8f4cb
- version: 1.0

## Description

ORB+ is an Opening Range Breakout indicator built to automatically mark the session opening range for FOREX, GOLD, and STOCKS using completed 5-minute candles only. It is designed for traders who want a clean and consistent way to define the early-session range and use it as a breakout framework.

The indicator lets you choose between FOREX, GOLD, and STOCKS. Based on your selection, ORB+ automatically sets the default opening range start time in New York time. For FOREX and GOLD, the default start is 8:00 AM ET. For STOCKS, the default start is 9:30 AM ET. This allows the indicator to adapt to the market you are trading without needing to manually change the session logic each time.

ORB+ builds the range using M5 data, even if you are viewing the chart on M1 or another lower timeframe. This keeps the opening range fixed and prevents it from changing between timeframes. By default, the indicator uses 3 five-minute candles, which creates a 15-minute opening range. The ORB levels only appear after the full range is complete.

For example, in STOCKS mode, the opening range starts at 9:30 AM ET and uses the first three 5-minute candles. The ORB High and ORB Low will only appear after that 15-minute window is finished. On lower timeframes like M1, the indicator will still wait for the full opening range to complete before plotting the levels.

[b]How To Use:[/b]

Apply ORB+ to an intraday chart and keep the chart timeframe at 5 minutes or lower. Select your market type: FOREX, GOLD, or STOCKS. The indicator will then automatically use the correct default start time for that market. If you want a custom opening range start, enable Manual Start Override and enter your preferred hour and minute.

You can also adjust the Number of M5 Bars input. A value of 3 creates a 15-minute opening range, while a larger value creates a wider range. Once complete, the indicator plots the ORB High and ORB Low on the chart. An optional midline can also be shown, and the range can be highlighted with a shaded box for easier visual reference.

Traders can use the ORB levels as a session framework. A break above the ORB High may indicate bullish expansion, while a break below the ORB Low may indicate bearish expansion. These levels can also be used as key reaction zones for retests, failed breakouts, or momentum continuation setups.

Features:

[list]
[*]Automatic market-based ORB start time
[*]Market selector for FOREX, GOLD, and STOCKS
[*]Uses completed M5 candles only
[*]Consistent ORB levels across lower timeframes
[*]Optional manual start override
[*]Adjustable opening range length
[*]Optional midline
[*]Optional ORB box shading
[*]Breakout alert conditions above ORB High and below ORB Low
[/list]

ORB+ is built for traders who want a simple and structured way to track the most important opening range of the session without manually drawing it every day.

## Source Code

````pine
//@version=6
indicator("ORB+", overlay=true)

// =========================
// Inputs
// =========================
marketType     = input.string("STOCKS", "Market Type", options=["FOREX", "GOLD", "STOCKS"])
orbTz          = input.string("America/New_York", "Timezone")
useManualStart = input.bool(false, "Manual Start Override")
manualHour     = input.int(9, "Manual Start Hour", minval=0, maxval=23)
manualMinute   = input.int(30, "Manual Start Minute", minval=0, maxval=59)

orbBars        = input.int(3, "Number of M5 Bars", minval=1, maxval=12)

showBox        = input.bool(true, "Show ORB Box")
showMid        = input.bool(false, "Show Midline")
highColor      = input.color(color.lime, "ORB High Color")
lowColor       = input.color(color.red, "ORB Low Color")
midColor       = input.color(color.yellow, "Midline Color")
boxColor       = input.color(color.new(color.blue, 88), "Box Fill Color")
lineWidth      = input.int(2, "Line Width", minval=1, maxval=5)

// =========================
// Auto Start Time by Market Type
// FOREX = 8:00 ET
// GOLD  = 8:00 ET
// STOCKS = 9:30 ET
// =========================
int autoHour   = marketType == "STOCKS" ? 9 : 8
int autoMinute = marketType == "STOCKS" ? 30 : 0

int startHour   = useManualStart ? manualHour : autoHour
int startMinute = useManualStart ? manualMinute : autoMinute

// Best use: M5 or lower
if not timeframe.isintraday
    runtime.error("ORB+ works on intraday charts only.")

if timeframe.in_seconds() > timeframe.in_seconds("5")
    runtime.error("Use ORB+ on 5-minute or lower timeframes.")

// =========================
// ORB logic in 5-minute context
// =========================
f_orbHigh(_startHour, _startMinute, _orbBars, _tz) =>
    var float orbHigh = na
    var int count = 0

    d  = dayofmonth(time, _tz)
    mo = month(time, _tz)
    y  = year(time, _tz)
    h  = hour(time, _tz)
    m  = minute(time, _tz)

    newDay = (ta.change(d) != 0) or (ta.change(mo) != 0) or (ta.change(y) != 0)

    if newDay
        orbHigh := na
        count := 0

    totalStart = _startHour * 60 + _startMinute
    totalNow   = h * 60 + m
    inWindow   = totalNow >= totalStart and totalNow < totalStart + (_orbBars * 5)

    if inWindow and count < _orbBars
        count += 1
        orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)

    count >= _orbBars ? orbHigh : na

f_orbLow(_startHour, _startMinute, _orbBars, _tz) =>
    var float orbLow = na
    var int count = 0

    d  = dayofmonth(time, _tz)
    mo = month(time, _tz)
    y  = year(time, _tz)
    h  = hour(time, _tz)
    m  = minute(time, _tz)

    newDay = (ta.change(d) != 0) or (ta.change(mo) != 0) or (ta.change(y) != 0)

    if newDay
        orbLow := na
        count := 0

    totalStart = _startHour * 60 + _startMinute
    totalNow   = h * 60 + m
    inWindow   = totalNow >= totalStart and totalNow < totalStart + (_orbBars * 5)

    if inWindow and count < _orbBars
        count += 1
        orbLow := na(orbLow) ? low : math.min(orbLow, low)

    count >= _orbBars ? orbLow : na

f_orbReady(_startHour, _startMinute, _orbBars, _tz) =>
    var int count = 0

    d  = dayofmonth(time, _tz)
    mo = month(time, _tz)
    y  = year(time, _tz)
    h  = hour(time, _tz)
    m  = minute(time, _tz)

    newDay = (ta.change(d) != 0) or (ta.change(mo) != 0) or (ta.change(y) != 0)

    if newDay
        count := 0

    totalStart = _startHour * 60 + _startMinute
    totalNow   = h * 60 + m
    inWindow   = totalNow >= totalStart and totalNow < totalStart + (_orbBars * 5)

    if inWindow and count < _orbBars
        count += 1

    count >= _orbBars

// =========================
// Pull M5 ORB values so it stays identical on M1/M3/M5
// =========================
orbHigh = request.security(
     syminfo.tickerid,
     "5",
     f_orbHigh(startHour, startMinute, orbBars, orbTz),
     barmerge.gaps_off,
     barmerge.lookahead_off)

orbLow = request.security(
     syminfo.tickerid,
     "5",
     f_orbLow(startHour, startMinute, orbBars, orbTz),
     barmerge.gaps_off,
     barmerge.lookahead_off)

orbReady = request.security(
     syminfo.tickerid,
     "5",
     f_orbReady(startHour, startMinute, orbBars, orbTz),
     barmerge.gaps_off,
     barmerge.lookahead_off)

orbMid = orbReady ? (orbHigh + orbLow) / 2.0 : na

// =========================
// Plot levels
// =========================
pHigh = plot(orbReady ? orbHigh : na, "ORB High", color=highColor, linewidth=lineWidth, style=plot.style_linebr)
pLow  = plot(orbReady ? orbLow  : na, "ORB Low",  color=lowColor,  linewidth=lineWidth, style=plot.style_linebr)
pMid  = plot(showMid and orbReady ? orbMid : na, "ORB Mid", color=midColor, linewidth=1, style=plot.style_linebr)

fill(pHigh, pLow, color=showBox and orbReady ? boxColor : na)

// =========================
// Alerts
// =========================
bullBreak = orbReady and ta.crossover(close, orbHigh)
bearBreak = orbReady and ta.crossunder(close, orbLow)

alertcondition(bullBreak, "ORB Break Above", "Price broke above ORB High")
alertcondition(bearBreak, "ORB Break Below", "Price broke below ORB Low")
````
