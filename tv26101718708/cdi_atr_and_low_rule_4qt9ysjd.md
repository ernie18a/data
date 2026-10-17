# CDI ATR and LOW rule

- url: https://www.tradingview.com/script/4QT9ysJd/
- type: indicator
- pine_id: PUB;ac17344054564486a22c4171a546cae4
- version: 1.0

## Description

ATR DIARIA , sirve para ver si entrar o no en un movimiento diario

## Source Code

````pine

//© El Club de Inversionistas CDI

//@version=6

indicator('CDI ATR and LOW rule', 'CDI ATR/LOW rule', overlay = true)



toolTip1 = 'The ATR calculates the average of the true range over a number of candles (default 14).'

toolTip2 = 'Volatility measured through the Average True Range (ATR).'

toolTip3 = '% of the distance between ATR and LOW of the day.'



viewATR       = input.bool(true, tooltip = toolTip1, title = 'View daily ATR', group = 'El Club de Inversionistas', inline = 'a')

tablePosition = input.string("bottom_right", "Table Position",

     options = ["top_left", "top_right", "bottom_left", "bottom_right"], 

     group = 'El Club de Inversionistas', inline = 'b')

lengthAtr     = input.int(14, title = 'ATR Length', group = 'El Club de Inversionistas', inline = 'c')



AtrPct() => ta.atr(lengthAtr) / close * 100

AtrUsd    = ta.atr(lengthAtr)



CumpleRegla() =>

    rangeToday = close - low

    rangeToday != 0 ? ((AtrUsd / rangeToday - 1) * 100) : na



_ATR = CumpleRegla()



_ColorBg = _ATR > 60 ? color.rgb(239,83,80) :       // rojo

           _ATR >= 50 ? color.rgb(38,166,154) :     // verde

           color.rgb(233, 245, 3)                   // amarillo



_tooltipDynamic = 

     _ATR > 60 ? "⚠ Caution: Very high movement" :

     _ATR >= 50 ? "✔ Ideal movement" :

     "👁 Ideal for tracking"



var table T_atr = table.new(tablePosition, columns = 1, rows = 2, border_width = 1, frame_color = color.black)



cellAtrInfo(_table, _column, _row, atrUsd) =>

    _text = 

      'Low:     ' + str.tostring(low, '#,###.00') + ' \n' +

      'Current: ' + str.tostring(close, '#,###.00') + ' \n' +

      'ATR:     ' + str.tostring(atrUsd, '0.00') + ' '

    table.cell(_table, _column, _row, _text, bgcolor = color.rgb(0,0,0), text_color = color.white, tooltip = toolTip2)



cellRegla(_table, _column, _row, value) =>

    _text = 'Low Distance: ' + str.tostring(value, '#,###.00') + '%'

    table.cell(_table, _column, _row, _text, bgcolor = _ColorBg, text_color = color.rgb(0, 0, 0), tooltip = _tooltipDynamic)



cellMensaje(_table, _column, _row, msg) =>

    table.cell(_table, _column, _row, msg, bgcolor = _ColorBg, text_color = color.rgb(0, 0, 0))



if viewATR and timeframe.isdaily

    cellAtrInfo(T_atr, 0, 0, AtrUsd)

    cellRegla(T_atr, 0, 1, CumpleRegla())
````
