# HTF Candles (Anchored) CS

- url: https://www.tradingview.com/script/9FzN5e0A-HTF-Candles-Anchored-CS/
- type: indicator
- pine_id: PUB;7ceffbadfdd04d86b74e75a800724286
- version: 1.0

## Description

[symbol="TVC:GOLD"]TVC:GOLD[/symbol] Draws higher-timeframe candles whose "day" starts at an hour you choose. By default the candle opens at 12:00 London time and runs until the next 12:00. The exchange's own daily boundary is ignored.

How it works

Each candle is built from the bars on your chart (open of the first bar, highest high, lowest low, latest close). It does not use request.security.
The anchor is set in a time zone of your choice, so it stays at the same local time when clocks change.
A new candle also starts after a market gap of more than 12 hours, for example at the weekend reopen. The first candle of the week is therefore partial. This can be turned off.
The current candle updates live. The previous candle is final.
Optional line at the current candle's open price, off by default.

Settings

Anchor hour and minute, time zone
New candle after a market gap
Show open line of the current candle
Bull and bear colors, body and wick transparency, thick wicks

Notes

Works on intraday chart timeframes only (best on 1 to 15 minutes). Daily and higher timeframes show an error.
History depends on how many bars TradingView loads for your chart, so a 1-minute chart shows fewer days than a 15-minute one.
Candles come from your chart's data feed. Other feeds and brokers can differ slightly.
Not a signal indicator. It does not give buy or sell advice.

## Source Code

````pine
//@version=6
// Modificat dupa "HTF Candles" (c) informanerd.
// Difera prin faptul ca "ziua" incepe la o ora aleasa de tine (implicit 12:00, ora Londrei),
// iar candelele se construiesc din lumanarile graficului, fara request.security.

maxBoxes = 500
indicator("HTF Candles (Anchored)", "", true, max_boxes_count = maxBoxes)

anchorGroup = "===============[ Anchor ]==============="
anchorHour = input.int(12, "Anchor hour", 0, 23, group = anchorGroup)
anchorMinute = input.int(0, "Anchor minute", 0, 59, group = anchorGroup)
tz = input.string("Europe/London", "Time zone", options = ["Europe/London", "UTC", "America/New_York", "Europe/Bucharest", "Europe/Berlin"], group = anchorGroup)
splitOnGap = input.bool(true, "New candle after a market gap (weekend)", group = anchorGroup)
showOpen = input.bool(false, "Show open line of the current candle", group = anchorGroup)

appearGroup = "===============[ Candles Appearance ]==============="
thickWick = input.bool(false, "Thick Candle Wicks", group = appearGroup)
ascColor = input.color(color.green, "Colors →   Bull:", inline = "color", group = appearGroup)
descColor = input.color(color.red, "  Bear:", inline = "color", group = appearGroup)
bodyTrans = input.int(60, "Transparency →   Body:", 0, 100, 10, inline = "trans", group = appearGroup)
wickTrans = input.int(80, "  Wicks:", 0, 100, 10, inline = "trans", group = appearGroup)

if timeframe.isdwm
    runtime.error("Use an intraday chart timeframe (for example 1m to 1h).")

barMs = timeframe.in_seconds() * 1000

// Ora locala (in fusul ales) si data locala pentru fiecare lumanare
anchorTotal = anchorHour * 60 + anchorMinute
minOfDay = hour(time, tz) * 60 + minute(time, tz)
ymd = year(time, tz) * 10000 + month(time, tz) * 100 + dayofmonth(time, tz)
pastAnchor = minOfDay >= anchorTotal

// O candela noua incepe cand ora ancora este depasita, sau dupa un gol de piata
crossedToday = bar_index > 0 and ymd == ymd[1] and pastAnchor and minOfDay[1] < anchorTotal
newDayPast = bar_index > 0 and ymd != ymd[1] and pastAnchor
gapBreak = splitOnGap and bar_index > 0 and (time - time[1]) > 12 * 60 * 60 * 1000
newSess = bar_index == 0 or crossedToday or newDayPast or gapBreak

var float sO = na
var float sH = na
var float sL = na
var int sStart = na
var color candleCol = na

if newSess
    sO := open
    sH := high
    sL := low
    sStart := time
else
    sH := math.max(sH, high)
    sL := math.min(sL, low)

candleCol := close > sO ? ascColor : close < sO ? descColor : na(candleCol) ? ascColor : candleCol

var bodies = array.new_box()
var wicks = array.new_box()

// Redesenam candela curenta la fiecare lumanare (sterge si recreeaza), ca in scriptul original
// Verificarea de dimensiune este separata de last(), ca last() sa nu fie apelat niciodata pe array gol
if bodies.size() > 0
    if box.get_left(bodies.last()) == sStart
        bodies.pop().delete()
        wicks.pop().delete()
if bodies.size() >= maxBoxes / 2
    bodies.shift().delete()
    wicks.shift().delete()

boxRight = time + barMs
bodyTop = math.max(sO, close)
bodyBottom = math.min(sO, close)
center = int((sStart + boxRight) / 2)
wickLeft = thickWick ? sStart : int(center - barMs / 2)
wickRight = thickWick ? boxRight : int(center + barMs / 2)
bodyFill = color.new(candleCol, bodyTrans)
wickFill = color.new(candleCol, wickTrans)

bodies.push(box.new(sStart, bodyTop, boxRight, bodyBottom, sO == close ? bodyFill : na, xloc = xloc.bar_time, bgcolor = bodyFill))
wicks.push(box.new(wickLeft, sH, wickRight, sL, na, xloc = xloc.bar_time, bgcolor = wickFill))

plot(showOpen and not newSess ? sO : na, "Candle open", color.new(color.gray, 10), 1, plot.style_linebr)
````
