<!-- tradingview-pine-id: PUB;21f0e903bf834bb6bba1afd8add4e8b7 -->
<!-- tradingviewscripts-format: 1 -->
# RSIM

Source: https://www.tradingview.com/script/njRU27EB-RSIM/

## Description

[image]https://www.tradingview.com/x/zYxp9RPq/[/image]
Table showing RSI 14 values for 1h, 4h, 1D, 1W, 1M (independently from chart interval). It's transparent and placed in the top right corner, so doesn't make your chart flat, like the basic RSI indicator chart does.

---

## Source Code

````pine
//@version=6
indicator("RSIM", overlay=true)

LIGHTTRANSP = 90
AVGTRANSP   = 80
HEAVYTRANSP = 70

i_posColor      = input.color(color.rgb(38, 166, 154), title="Positive Color")
i_neutralColor  = input.color(color.orange, title="Neutral Color")
i_negColor      = input.color(color.rgb(240, 83, 80), title="Negative Color")
i_showTTC       = input.bool(true, title="Show time to close")
i_positionRight = input.bool(true, title="Position on right")

len = input.int(14, minval=1, title="Length")
src = input.source(close, "Source")

position = i_positionRight ? position.top_right : position.top_left

var table perfTable = table.new(position, 6, 2, border_width = 3)

// TIME CALCULATIONS
TTC() =>
    timeLeft = barstate.isrealtime ? (time_close - timenow) / 1000 : -1
    timeLeft
    
f_ttc(resolution) =>
    _ttc = request.security(syminfo.tickerid, resolution, TTC())
    _ttc
    
TTCMS(timeLeft) =>
    min = math.floor(timeLeft / 60)
    sec = timeLeft % 60
    minSecString = timeLeft == -1 ? "-" : str.tostring(min) + "m " + str.tostring(int(sec)) + "s"
    
TTCHM(timeLeft) =>
    hours = math.floor(timeLeft / 3600)
    min = math.floor((timeLeft % 3600) / 60)
    hoursMinutesString = timeLeft == -1 ? "-" : str.tostring(hours) + "h " + str.tostring(min) + "m"

TTCDH(timeLeft) =>
    days = math.floor(timeLeft / 86400) // Poprawiono 88640 na 86400 sekund (równowartość 24 godzin)
    hours = math.floor((timeLeft % 86400) / 3600)
    daysHoursString = timeLeft == -1 ? "-" : str.tostring(days) + "d " + str.tostring(hours) + "h"

// RSI - Zoptymalizowano używając wbudowanej funkcji ta.rsi
Rsi() => 
    ta.rsi(src, len)

f_rsi(resolution) =>
    _rsi = request.security(syminfo.tickerid, resolution, Rsi())
    _rsi
   
f_fillCell(_table, _column, _row, _value, _timeframe, _timeToClose) =>
    _c_color = _value <= 30 ? i_posColor : (_value >= 70 ? i_negColor : i_neutralColor)
    _transp = _value <= 30 or _value >= 70 ? AVGTRANSP : LIGHTTRANSP
    _timeToCloseString = i_showTTC ? _timeToClose + "\n\n" : ""
    _cellText = _timeframe + "\n" + _timeToCloseString + str.tostring(_value, "#.#")
    table.cell(_table, _column, _row, _cellText, bgcolor = color.new(_c_color, _transp), text_color = _c_color, width = 4)

// DEFINE VALUES
rsi1 = f_rsi("60")
rsi2 = f_rsi("240")
rsi3 = f_rsi("D")
rsi4 = f_rsi("W")
rsi5 = f_rsi("M")

ttc1 = TTCHM(f_ttc("60"))
ttc2 = TTCHM(f_ttc("240"))
ttc3 = TTCHM(f_ttc("D"))
ttc4 = TTCDH(f_ttc("W"))
ttc5 = TTCDH(f_ttc("M"))

// FILL CELLS (Wyświetlane na stałe, niezależnie od bieżącego interwału na wykresie)
row = i_positionRight ? 0 : 1

f_fillCell(perfTable, 0, row, rsi1, "1h", ttc1)
f_fillCell(perfTable, 1, row, rsi2, "4h", ttc2)
f_fillCell(perfTable, 2, row, rsi3, "1D", ttc3)
f_fillCell(perfTable, 3, row, rsi4, "1W", ttc4)
f_fillCell(perfTable, 4, row, rsi5, "1M", ttc5)

table.cell(perfTable, 5, 0, "", bgcolor = color.rgb(0,0,0,100), text_color = color.white, width = 3)
````
