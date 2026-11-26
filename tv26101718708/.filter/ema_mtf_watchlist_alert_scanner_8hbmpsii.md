# EMA MTF Watchlist Alert Scanner

- url: https://www.tradingview.com/script/8hbMpsIi-EMA-MTF-Watchlist-Alert-Scanner/
- type: indicator
- pine_id: PUB;492795fa90cc4adea5b4223bdd85ee50
- version: 1.0

## Description

EMA MTF Watchlist Alert Scanner with customizable table and alert creation

[b]Recommended Settings[/b]

EMA Length = 13
Match Mode = All Enabled Timeframes
Scan Direction = Either
Use TF1 = 5
Use TF2 = 15
Use TF3 = 60
Use TF4 = 240
Use TF5 = OFF
Use TF6 = OFF

## Source Code

````pine
// EMA MTF Watchlist Alert Scanner - Overlay Table Only
//@version=6
indicator("EMA MTF Watchlist Alert Scanner", shorttitle="EMA MTF Alerts", overlay=true)

emaLen = input.int(13, "EMA Length", minval=1)
requiredCount = input.int(4, "Required TFs Aligned", minval=1, maxval=6)

matchMode = input.string("All Enabled Timeframes", "Match Mode", options=["All Enabled Timeframes", "At Least Required Count"])
scanDirection = input.string("Either", "Scan Direction", options=["Either", "Above EMA", "Below EMA"])

useTf1 = input.bool(true, "Use TF1", inline="tf1")
tf1 = input.timeframe("5", "", inline="tf1")

useTf2 = input.bool(true, "Use TF2", inline="tf2")
tf2 = input.timeframe("15", "", inline="tf2")

useTf3 = input.bool(true, "Use TF3", inline="tf3")
tf3 = input.timeframe("60", "", inline="tf3")

useTf4 = input.bool(true, "Use TF4", inline="tf4")
tf4 = input.timeframe("240", "", inline="tf4")

useTf5 = input.bool(false, "Use TF5", inline="tf5")
tf5 = input.timeframe("1D", "", inline="tf5")

useTf6 = input.bool(false, "Use TF6", inline="tf6")
tf6 = input.timeframe("1W", "", inline="tf6")

showTable = input.bool(true, "Show Table")

tablePosition = input.string(
     "Lower Center",
     "Table Position",
     options=[
         "Upper Left",
         "Upper Center",
         "Upper Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Lower Left",
         "Lower Center",
         "Lower Right"
     ])

tablePos = switch tablePosition
    "Upper Left" => position.top_left
    "Upper Center" => position.top_center
    "Upper Right" => position.top_right
    "Middle Left" => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right" => position.middle_right
    "Lower Left" => position.bottom_left
    "Lower Center" => position.bottom_center
    "Lower Right" => position.bottom_right

f_dir(_emaLen) =>
    _ema = ta.ema(close, _emaLen)
    close > _ema ? 1 : close < _ema ? -1 : 0

d1 = useTf1 ? request.security(syminfo.tickerid, tf1, f_dir(emaLen)) : 0
d2 = useTf2 ? request.security(syminfo.tickerid, tf2, f_dir(emaLen)) : 0
d3 = useTf3 ? request.security(syminfo.tickerid, tf3, f_dir(emaLen)) : 0
d4 = useTf4 ? request.security(syminfo.tickerid, tf4, f_dir(emaLen)) : 0
d5 = useTf5 ? request.security(syminfo.tickerid, tf5, f_dir(emaLen)) : 0
d6 = useTf6 ? request.security(syminfo.tickerid, tf6, f_dir(emaLen)) : 0

activeCount =
     (useTf1 ? 1 : 0) +
     (useTf2 ? 1 : 0) +
     (useTf3 ? 1 : 0) +
     (useTf4 ? 1 : 0) +
     (useTf5 ? 1 : 0) +
     (useTf6 ? 1 : 0)

bullCount =
     (useTf1 and d1 == 1 ? 1 : 0) +
     (useTf2 and d2 == 1 ? 1 : 0) +
     (useTf3 and d3 == 1 ? 1 : 0) +
     (useTf4 and d4 == 1 ? 1 : 0) +
     (useTf5 and d5 == 1 ? 1 : 0) +
     (useTf6 and d6 == 1 ? 1 : 0)

bearCount =
     (useTf1 and d1 == -1 ? 1 : 0) +
     (useTf2 and d2 == -1 ? 1 : 0) +
     (useTf3 and d3 == -1 ? 1 : 0) +
     (useTf4 and d4 == -1 ? 1 : 0) +
     (useTf5 and d5 == -1 ? 1 : 0) +
     (useTf6 and d6 == -1 ? 1 : 0)

needed = matchMode == "All Enabled Timeframes" ? activeCount : requiredCount

bullAligned = bullCount >= needed
bearAligned = bearCount >= needed

bullAllowed = scanDirection == "Either" or scanDirection == "Above EMA"
bearAllowed = scanDirection == "Either" or scanDirection == "Below EMA"

bullSignal = bullAllowed and bullAligned
bearSignal = bearAllowed and bearAligned

newBullSignal = bullSignal and not bullSignal[1]
newBearSignal = bearSignal and not bearSignal[1]

signalCode = bullSignal ? 1 : bearSignal ? -1 : 0

plot(signalCode, "Signal Code", display=display.none)
plot(bullCount, "Bull Count", display=display.none)
plot(bearCount, "Bear Count", display=display.none)
plot(activeCount, "Active TF Count", display=display.none)

alertcondition(newBullSignal, title="Bullish EMA MTF Alignment", message="{{ticker}} Bullish EMA alignment detected")
alertcondition(newBearSignal, title="Bearish EMA MTF Alignment", message="{{ticker}} Bearish EMA alignment detected")

if newBullSignal
    alert("BULLISH EMA ALIGNMENT: " + syminfo.ticker + " | " + str.tostring(bullCount) + "/" + str.tostring(activeCount) + " TFs above EMA" + str.tostring(emaLen), alert.freq_once_per_bar_close)

if newBearSignal
    alert("BEARISH EMA ALIGNMENT: " + syminfo.ticker + " | " + str.tostring(bearCount) + "/" + str.tostring(activeCount) + " TFs below EMA" + str.tostring(emaLen), alert.freq_once_per_bar_close)

var table t = table.new(tablePos, 3, 8, border_width=1)

f_txt(_d) =>
    _d == 1 ? "Above" : _d == -1 ? "Below" : "Flat"

f_bg(_d) =>
    _d == 1 ? color.new(color.green, 25) : _d == -1 ? color.new(color.red, 25) : color.gray

if barstate.islast and showTable
    table.cell(t, 0, 0, "TF", bgcolor=color.black, text_color=color.white, text_size=size.tiny)
    table.cell(t, 1, 0, "EMA", bgcolor=color.black, text_color=color.white, text_size=size.tiny)
    table.cell(t, 2, 0, "Status", bgcolor=color.black, text_color=color.white, text_size=size.tiny)

    table.cell(t, 0, 1, tf1, text_size=size.tiny)
    table.cell(t, 1, 1, str.tostring(emaLen), text_size=size.tiny)
    table.cell(t, 2, 1, useTf1 ? f_txt(d1) : "Off", bgcolor=useTf1 ? f_bg(d1) : color.gray, text_size=size.tiny)

    table.cell(t, 0, 2, tf2, text_size=size.tiny)
    table.cell(t, 1, 2, str.tostring(emaLen), text_size=size.tiny)
    table.cell(t, 2, 2, useTf2 ? f_txt(d2) : "Off", bgcolor=useTf2 ? f_bg(d2) : color.gray, text_size=size.tiny)

    table.cell(t, 0, 3, tf3, text_size=size.tiny)
    table.cell(t, 1, 3, str.tostring(emaLen), text_size=size.tiny)
    table.cell(t, 2, 3, useTf3 ? f_txt(d3) : "Off", bgcolor=useTf3 ? f_bg(d3) : color.gray, text_size=size.tiny)

    table.cell(t, 0, 4, tf4, text_size=size.tiny)
    table.cell(t, 1, 4, str.tostring(emaLen), text_size=size.tiny)
    table.cell(t, 2, 4, useTf4 ? f_txt(d4) : "Off", bgcolor=useTf4 ? f_bg(d4) : color.gray, text_size=size.tiny)

    table.cell(t, 0, 5, tf5, text_size=size.tiny)
    table.cell(t, 1, 5, str.tostring(emaLen), text_size=size.tiny)
    table.cell(t, 2, 5, useTf5 ? f_txt(d5) : "Off", bgcolor=useTf5 ? f_bg(d5) : color.gray, text_size=size.tiny)

    table.cell(t, 0, 6, tf6, text_size=size.tiny)
    table.cell(t, 1, 6, str.tostring(emaLen), text_size=size.tiny)
    table.cell(t, 2, 6, useTf6 ? f_txt(d6) : "Off", bgcolor=useTf6 ? f_bg(d6) : color.gray, text_size=size.tiny)

    finalText = bullSignal ? "BULLISH" : bearSignal ? "BEARISH" : "MIXED"
    finalBg = bullSignal ? color.green : bearSignal ? color.red : color.gray

    table.cell(t, 0, 7, "Signal", bgcolor=color.black, text_color=color.white, text_size=size.tiny)
    table.cell(t, 1, 7, str.tostring(needed) + "/" + str.tostring(activeCount), bgcolor=color.black, text_color=color.white, text_size=size.tiny)
    table.cell(t, 2, 7, finalText, bgcolor=finalBg, text_color=color.white, text_size=size.tiny)
````
