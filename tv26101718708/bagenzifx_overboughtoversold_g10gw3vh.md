# BagenziFX Overbought/Oversold

- url: https://www.tradingview.com/script/G10Gw3VH-BagenziFX-Overbought-Oversold/
- type: indicator
- pine_id: PUB;9753fe24b2714a1f9b99c5fdc59ff02c
- version: 1.0

## Description

BagenziFX Overbought/Oversold

BagenziFX Overbought/Oversold is a visual signal indicator that displays manually defined OVERBOUGHT and OVERSOLD levels directly on TradingView charts.

Features
Displays OVERBOUGHT signals with red vertical lines and labels.
Displays OVERSOLD signals with lime vertical lines and labels.
Works on all TradingView timeframes.
Automatically aligns signals to the correct candle regardless of chart timeframe.
Adjustable broker/server time offset.
Optional signal labels.
Optional vertical signal lines.
Supports separate signal input groups for:
Monday Signals
Tuesday Signals
Wednesday Signals
Thursday Signals
Friday Signals
Gold (XAUUSD) Signals
Signal Format

Each signal is entered using the following format:

SYMBOL,YYYY,MM,DD,HH,MM,SIGNALTYPE

Example:

EURUSD,2026,6,1,15,45,OVERSOLD

GBPUSD,2026,6,1,16,00,OVERBOUGHT

Intended Use

This indicator is designed for traders who maintain their own signal database and want to visualize historical or upcoming overbought/oversold events directly on TradingView charts.

Author

BagenziFX

## Source Code

````pine
//@version=6
indicator("BagenziFX Overbought/Oversold", overlay=true, max_labels_count=500)

//====================================================
// SETTINGS
//====================================================

OffsetHours       = input.int(-7, "OANDA Offset Hours")
ShowVerticalLines = input.bool(true, "Show Vertical Lines")
ShowLabels        = input.bool(true, "Show Labels")

//====================================================
// SIGNAL INPUTS
//====================================================

MondaySignals    = input.string("", "Monday Signals")
TuesdaySignals   = input.string("", "Tuesday Signals")
WednesdaySignals = input.string("", "Wednesday Signals")
ThursdaySignals  = input.string("", "Thursday Signals")
FridaySignals    = input.string("", "Friday Signals")
GoldSignals      = input.string("", "Gold Signals")

//====================================================
// SHOW SIGNAL
//====================================================

showSignal(sigSymbol, y, m, d, h, min, signalType) =>

    if str.contains(syminfo.ticker, sigSymbol)

        sigTime = timestamp(y, m, d, h + OffsetHours, min)

        signalBar = time <= sigTime and time_close > sigTime

        if signalBar

            isOversold = signalType == "OVERSOLD"

            signalColor = isOversold ? color.lime : color.red

            labelText =
                 signalType + "\n" +
                 str.tostring(m) + "/" +
                 str.tostring(d) + "\n" +
                 str.format("{0,number,00}:{1,number,00}", h, min)

            if ShowVerticalLines

                line.new(
                     bar_index,
                     low * 0.50,
                     bar_index,
                     high * 1.50,
                     extend = extend.both,
                     color = signalColor,
                     style = line.style_solid,
                     width = 2)

            if ShowLabels

                labelY =
                     isOversold ?
                     low * 0.98 :
                     high * 1.02

                label.new(
                     bar_index,
                     labelY,
                     labelText,
                     style =
                     isOversold ?
                     label.style_label_up :
                     label.style_label_down,
                     color = signalColor,
                     textcolor = color.white,
                     size = size.normal)

//====================================================
// PROCESS SIGNAL LIST
//====================================================

processSignalList(signalList) =>

    rows = str.split(signalList, ";")

    for i = 0 to array.size(rows) - 1

        row = str.trim(array.get(rows, i))

        if str.length(row) > 0

            fields = str.split(row, ",")

            if array.size(fields) >= 7

                pair =
                     str.trim(array.get(fields, 0))

                yy =
                     int(str.tonumber(
                     str.trim(array.get(fields, 1))))

                mm =
                     int(str.tonumber(
                     str.trim(array.get(fields, 2))))

                dd =
                     int(str.tonumber(
                     str.trim(array.get(fields, 3))))

                hh =
                     int(str.tonumber(
                     str.trim(array.get(fields, 4))))

                mn =
                     int(str.tonumber(
                     str.trim(array.get(fields, 5))))

                sig =
                     str.trim(array.get(fields, 6))

                showSignal(
                     pair,
                     yy,
                     mm,
                     dd,
                     hh,
                     mn,
                     sig)

//====================================================
// PROCESS ALL INPUT BOXES
//====================================================

processSignalList(MondaySignals)
processSignalList(TuesdaySignals)
processSignalList(WednesdaySignals)
processSignalList(ThursdaySignals)
processSignalList(FridaySignals)
processSignalList(GoldSignals)
````
