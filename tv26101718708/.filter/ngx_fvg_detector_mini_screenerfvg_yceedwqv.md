# NGX FVG Detector + Mini ScreenerFVG

- url: https://www.tradingview.com/script/YcEEdWQV-NGX-FVG-Detector-Mini-ScreenerFVG/
- type: indicator
- pine_id: PUB;2c1d3b2960de44fc9eba7faab895ff27
- version: 1.0

## Description

Detects bullish and bearish FVG on the current chart
Creates a mini Pine Screener table for selected NGX stocks

## Source Code

````pine
//@version=5
indicator("NGX FVG Detector + Mini Screener", overlay=true, max_boxes_count=500, max_labels_count=500, dynamic_requests=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// USER SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tfScreen     = input.timeframe("W", "Screener Timeframe")
lookbackBars = input.int(20, "Lookback Bars for Recent FVG", minval=3, maxval=200)
minGapPct    = input.float(2.0, "Minimum FVG Size (%)", minval=0.1, step=0.1)
extendBars   = input.int(30, "Extend FVG Box to the Right", minval=5, maxval=300)

showBullFVG  = input.bool(true, "Show Bullish FVG on Chart")
showBearFVG  = input.bool(true, "Show Bearish FVG on Chart")
showLabels   = input.bool(true, "Show FVG Labels")
showTable    = input.bool(true, "Show Screener Table")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SYMBOL INPUTS
// Change these to your own NGX watchlist
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

sym1  = input.symbol("NSENG:JAIZBANK", "Symbol 1")
sym2  = input.symbol("NSENG:CHAMS", "Symbol 2")
sym3  = input.symbol("NSENG:CAVERTON", "Symbol 3")
sym4  = input.symbol("NSENG:CUTIX", "Symbol 4")
sym5  = input.symbol("NSENG:NEM", "Symbol 5")
sym6  = input.symbol("NSENG:AIICO", "Symbol 6")
sym7  = input.symbol("NSENG:UPDC", "Symbol 7")
sym8  = input.symbol("NSENG:NEIMETH", "Symbol 8")
sym9  = input.symbol("NSENG:CUSTODIAN", "Symbol 9")
sym10 = input.symbol("NSENG:MBENEFIT", "Symbol 10")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FVG LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Bullish FVG:
// Current candle low is above the high from 2 candles ago.
// This means price moved up too fast and left an imbalance.
bullFVG = low > high[2]

// Bearish FVG:
// Current candle high is below the low from 2 candles ago.
// This means price moved down too fast and left an imbalance.
bearFVG = high < low[2]

// Gap size calculation
bullGapPct = bullFVG ? ((low - high[2]) / close) * 100 : 0
bearGapPct = bearFVG ? ((low[2] - high) / close) * 100 : 0

validBullFVG = bullFVG and bullGapPct >= minGapPct
validBearFVG = bearFVG and bearGapPct >= minGapPct

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DRAW FVG ZONES ON CURRENT CHART
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if validBullFVG and showBullFVG
    bullBox = box.new(
         left=bar_index - 2,
         top=low,
         right=bar_index + extendBars,
         bottom=high[2],
         bgcolor=color.new(color.green, 85),
         border_color=color.new(color.green, 20)
     )

    if showLabels
        label.new(
             x=bar_index,
             y=low,
             text="Bullish FVG\n" + str.tostring(high[2], format.mintick) + " - " + str.tostring(low, format.mintick),
             style=label.style_label_down,
             textcolor=color.white,
             color=color.new(color.green, 20),
             size=size.small
         )

if validBearFVG and showBearFVG
    bearBox = box.new(
         left=bar_index - 2,
         top=low[2],
         right=bar_index + extendBars,
         bottom=high,
         bgcolor=color.new(color.red, 85),
         border_color=color.new(color.red, 20)
     )

    if showLabels
        label.new(
             x=bar_index,
             y=high,
             text="Bearish FVG\n" + str.tostring(high, format.mintick) + " - " + str.tostring(low[2], format.mintick),
             style=label.style_label_up,
             textcolor=color.white,
             color=color.new(color.red, 20),
             size=size.small
         )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FUNCTION FOR MINI SCREENER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_lastFVG() =>
    bFVG = low > high[2]
    sFVG = high < low[2]

    bGap = bFVG ? ((low - high[2]) / close) * 100 : 0
    sGap = sFVG ? ((low[2] - high) / close) * 100 : 0

    bValid = bFVG and bGap >= minGapPct
    sValid = sFVG and sGap >= minGapPct

    bAge = ta.barssince(bValid)
    sAge = ta.barssince(sValid)

    bRecent = not na(bAge) and bAge <= lookbackBars
    sRecent = not na(sAge) and sAge <= lookbackBars

    chooseBull = bRecent and (not sRecent or bAge <= sAge)
    chooseBear = sRecent and (not bRecent or sAge < bAge)

    dir = chooseBull ? 1 : chooseBear ? -1 : 0
    age = chooseBull ? bAge : chooseBear ? sAge : na

    bullLower = ta.valuewhen(bValid, high[2], 0)
    bullUpper = ta.valuewhen(bValid, low, 0)

    bearLower = ta.valuewhen(sValid, high, 0)
    bearUpper = ta.valuewhen(sValid, low[2], 0)

    zoneLow  = chooseBull ? bullLower : chooseBear ? bearLower : na
    zoneHigh = chooseBull ? bullUpper : chooseBear ? bearUpper : na

    bLen = math.max(nz(bAge) + 1, 1)
    sLen = math.max(nz(sAge) + 1, 1)

    bullFilled = chooseBull and ta.lowest(low, bLen) <= bullLower
    bearFilled = chooseBear and ta.highest(high, sLen) >= bearUpper

    filled = bullFilled or bearFilled

    bullInZone = chooseBull and not bullFilled and low <= bullUpper and close >= bullLower
    bearInZone = chooseBear and not bearFilled and high >= bearLower and close <= bearUpper

    inZone = bullInZone or bearInZone

    [dir, age, zoneLow, zoneHigh, filled, inZone, close]

// Request security function
f_screen(symbol) =>
    request.security(symbol, tfScreen, f_lastFVG())

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET SCREENER DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[dir1, age1, lo1, hi1, filled1, inZone1, close1] = f_screen(sym1)
[dir2, age2, lo2, hi2, filled2, inZone2, close2] = f_screen(sym2)
[dir3, age3, lo3, hi3, filled3, inZone3, close3] = f_screen(sym3)
[dir4, age4, lo4, hi4, filled4, inZone4, close4] = f_screen(sym4)
[dir5, age5, lo5, hi5, filled5, inZone5, close5] = f_screen(sym5)
[dir6, age6, lo6, hi6, filled6, inZone6, close6] = f_screen(sym6)
[dir7, age7, lo7, hi7, filled7, inZone7, close7] = f_screen(sym7)
[dir8, age8, lo8, hi8, filled8, inZone8, close8] = f_screen(sym8)
[dir9, age9, lo9, hi9, filled9, inZone9, close9] = f_screen(sym9)
[dir10, age10, lo10, hi10, filled10, inZone10, close10] = f_screen(sym10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table fvgTable = table.new(position.top_right, 6, 11, border_width=1)

f_addRow(row, symbol, dir, age, zoneLow, zoneHigh, filled, inZone, lastClose) =>
    cleanSymbol = str.replace(symbol, "NSENG:", "")

    dirText = dir == 1 ? "Bullish" : dir == -1 ? "Bearish" : "None"
    ageText = na(age) ? "-" : str.tostring(age)
    zoneText = dir == 0 ? "-" : str.tostring(zoneLow, format.mintick) + " - " + str.tostring(zoneHigh, format.mintick)

    statusText = dir == 0 ? "-" : filled ? "Filled" : inZone ? "In FVG" : "Open"

    bg = dir == 1 ? color.new(color.green, 80) : dir == -1 ? color.new(color.red, 80) : color.new(color.gray, 85)
    statusBg = filled ? color.new(color.gray, 70) : inZone ? color.new(color.orange, 60) : dir != 0 ? color.new(color.blue, 75) : color.new(color.gray, 85)

    table.cell(fvgTable, 0, row, cleanSymbol, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(fvgTable, 1, row, dirText, text_color=color.white, bgcolor=bg)
    table.cell(fvgTable, 2, row, ageText, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(fvgTable, 3, row, zoneText, text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(fvgTable, 4, row, statusText, text_color=color.white, bgcolor=statusBg)
    table.cell(fvgTable, 5, row, str.tostring(lastClose, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0))

if barstate.islast and showTable
    table.cell(fvgTable, 0, 0, "Symbol", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(fvgTable, 1, 0, "FVG Type", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(fvgTable, 2, 0, "Age", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(fvgTable, 3, 0, "FVG Zone", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(fvgTable, 4, 0, "Status", text_color=color.white, bgcolor=color.new(color.blue, 0))
    table.cell(fvgTable, 5, 0, "Close", text_color=color.white, bgcolor=color.new(color.blue, 0))

    f_addRow(1, sym1, dir1, age1, lo1, hi1, filled1, inZone1, close1)
    f_addRow(2, sym2, dir2, age2, lo2, hi2, filled2, inZone2, close2)
    f_addRow(3, sym3, dir3, age3, lo3, hi3, filled3, inZone3, close3)
    f_addRow(4, sym4, dir4, age4, lo4, hi4, filled4, inZone4, close4)
    f_addRow(5, sym5, dir5, age5, lo5, hi5, filled5, inZone5, close5)
    f_addRow(6, sym6, dir6, age6, lo6, hi6, filled6, inZone6, close6)
    f_addRow(7, sym7, dir7, age7, lo7, hi7, filled7, inZone7, close7)
    f_addRow(8, sym8, dir8, age8, lo8, hi8, filled8, inZone8, close8)
    f_addRow(9, sym9, dir9, age9, lo9, hi9, filled9, inZone9, close9)
    f_addRow(10, sym10, dir10, age10, lo10, hi10, filled10, inZone10, close10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(validBullFVG, title="Bullish FVG Formed", message="A Bullish FVG has formed on this chart.")
alertcondition(validBearFVG, title="Bearish FVG Formed", message="A Bearish FVG has formed on this chart.")
````
