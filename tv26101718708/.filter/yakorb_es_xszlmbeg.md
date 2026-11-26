# Yakorb ES

- url: https://www.tradingview.com/script/XSZlMBeG-Yakorb-ES/
- type: indicator
- pine_id: PUB;5035a2999355420191ef60cd528700d4
- version: 1.0

## Description

sh...............................................................................................

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yakup22

//@version=6
//@version=6
indicator("07:00 15m Candle Zone + Midpoint + Long/Short Tools (ES ONLY)", overlay = true)

// --- ONLY RUN ON ES / MES ---
isES = str.contains(syminfo.tickerid, "ES1!") or str.contains(syminfo.tickerid, "MES1!")

if isES
    // Pull 15‑minute data
    fHigh = request.security(syminfo.tickerid, "15", high)
    fLow  = request.security(syminfo.tickerid, "15", low)
    fTime = request.security(syminfo.tickerid, "15", time)

    // Detect the 15m candle that OPENS at 07:00
    is0700 = hour(fTime) == 7 and minute(fTime) == 0

    // Arrays to store all drawings
    var box[] zoneBoxes = array.new_box()
    var line[] midLines = array.new_line()
    var line[] longSL   = array.new_line()
    var line[] shortSL  = array.new_line()
    var line[] longEntry = array.new_line()
    var line[] shortEntry = array.new_line()

    if is0700
        // How many bars until 11:00 on the current timeframe
        barsTo1100 = int((11 - 7) * 60 / timeframe.multiplier)

        // Zone box
        newBox = box.new(
            left = bar_index,
            right = bar_index + barsTo1100,
            top = fHigh,
            bottom = fLow,
           bgcolor = color.new(color.purple, 80),
border_color = color.new(color.purple, 0)

        )
        array.push(zoneBoxes, newBox)

        // Midpoint
        mid = (fHigh + fLow) / 2
        midLine = line.new(
            x1 = bar_index,
            y1 = mid,
            x2 = bar_index + barsTo1100,
            y2 = mid,
            color = color.new(color.blue, 70),
            width = 1
        )
        array.push(midLines, midLine)

        // --- LONG POSITION TOOL ---
        longEntryLine = line.new(
            x1 = bar_index,
            y1 = mid,
            x2 = bar_index + 5,
            y2 = mid,
            color = color.new(color.green, 0),
            width = 2
        )
        array.push(longEntry, longEntryLine)

        longStop = fLow - 5
        longSLline = line.new(
            x1 = bar_index,
            y1 = longStop,
            x2 = bar_index + 5,
            y2 = longStop,
            color = color.new(color.red, 0),
            width = 2
        )
        array.push(longSL, longSLline)

        // --- SHORT POSITION TOOL ---
        shortEntryLine = line.new(
            x1 = bar_index,
            y1 = mid,
            x2 = bar_index + 5,
            y2 = mid,
            color = color.new(color.red, 0),
            width = 2
        )
        array.push(shortEntry, shortEntryLine)

        shortStop = fHigh + 5
        shortSLline = line.new(
            x1 = bar_index,
            y1 = shortStop,
            x2 = bar_index + 5,
            y2 = shortStop,
            color = color.new(color.green, 0),
            width = 2
        )
        array.push(shortSL, shortSLline)
````
