# RSI Hunter - Watchlist V1

- url: https://www.tradingview.com/script/WiUYS2wl/
- type: indicator
- pine_id: PUB;af59a281efc94fefb48ea4244befd076
- version: 4.0

## Description

RSI Hunter — Multi-Symbol Watchlist

Scans up to 36 user-defined symbols for overbought and oversold RSI conditions and displays the results in a single sorted watchlist.

Function
The indicator calculates the RSI for each symbol and filters against configurable overbought and oversold thresholds. Only symbols breaching these levels are shown. Results are split into two sections, each sorted from most to least extreme, with a trigger count in the header.

Features
Pixel-fixed table, zoom-independent
9 selectable positions on the chart
Configurable RSI length, thresholds, and timeframe
Adjustable max entries per side
Optional grouping tag (B1–B6) for organizing symbols
Optional section for symbols that failed to load
Customizable colors and text size
Runs as overlay, no separate pane required


Use case
For traders monitoring a fixed universe of instruments who want to identify mean-reversion or momentum candidates without manually checking each chart.

Configuration
The 36 symbols are organized into 6 editable blocks of 6 entries. Default data source is Binance Futures perpetuals; symbols can be freely changed in the settings.

## Source Code

````pine
//@version=6
// ============================================================================
//  RSI Hunter - Multi-Symbol Watchlist
//  ---------------------------------------------------------------------------
//  Scans up to 36 user-defined symbols for overbought and oversold RSI
//  conditions on a fixed scan timeframe, optionally flags RSI divergence, and
//  reports the result as a single sorted table.
// ============================================================================
indicator("RSI Hunter - Watchlist V1.2", overlay = true)

// ─── SETTINGS ───
rsiLen     = input.int(14, "RSI Length")
obLevel    = input.int(75, "Overbought Level")
osLevel    = input.int(25, "Oversold Level")
tf         = input.timeframe("240", "Scan Timeframe", tooltip = "The timeframe every symbol is measured on. Independent of the chart you are viewing.")
lblSize    = input.string("small", "Text Size", options = ["tiny", "small", "normal", "large"])
tblPos     = input.string("top_right", "Table Position", options = ["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"])
maxPerSide = input.int(8, "Max Entries per Side (OB/OS)", minval = 1, maxval = 15)
showTag    = input.bool(true, "Show Block Tag (B1-B6)")
showCount  = input.bool(true, "Show Count in Header")
showFails  = input.bool(false, "Show Failed Symbols Section")
showHeader = input.bool(true, "Show Scan Header", tooltip = "Displays the scan timeframe and the chart timeframe. Alerts are evaluated on chart bar closes, so the two matter together.")

// ─── SYMBOL CONSTRUCTION ───
gSym = "Symbol Construction"
symPrefix = input.string("BINANCE:", "Exchange Prefix", group = gSym, tooltip = "Prepended to each ticker below. Example: BINANCE:, BYBIT:, OKX:")
symSuffix = input.string("USDT.P", "Quote Suffix", group = gSym, tooltip = "Appended to each ticker below. Example: USDT.P for perpetuals, USDT for spot, USD for inverse.")

// ─── DIVERGENCE ───
gDiv = "Divergence Detection"
divOn       = input.bool(true, "Enable Divergence Marker", group = gDiv)
divStrict   = input.bool(true, "Strict comparison", group = gDiv, tooltip = "On: the newest pivot is compared with the one immediately before it, which is what divergence normally means and what you will see when you check the chart. Off: the newest pivot is compared with every pivot in the search range, which finds considerably more candidates because a wide enough window almost always contains a qualifying pivot.")
divLookback = input.int(5, "Pivot Lookback", minval = 2, maxval = 15, group = gDiv, tooltip = "Bars on each side a pivot must dominate to qualify. A pivot is only confirmed this many bars after it printed.")
divRange    = input.int(60, "Search Range (Bars)", minval = 10, maxval = 200, group = gDiv, tooltip = "How far back to keep pivots for comparison")
divMaxAge   = input.int(5, "Max Age (Bars)", minval = 1, maxval = 20, group = gDiv, tooltip = "Divergence is shown only if it was confirmed within the last N bars. Counted from confirmation, not from the pivot bar itself.")

// ─── ALERTS / BUFFER ───
gAlerts = "Alerts & Buffer"
alertOBOS    = input.bool(true,  "Enable OB/OS Alert", group = gAlerts, tooltip = "Fires when a symbol enters the overbought or oversold zone")
alertDiv     = input.bool(true,  "Enable Divergence Alert", group = gAlerts, tooltip = "Fires when a divergence is detected (regardless of RSI zone)")
alertCombo   = input.bool(true,  "Enable Combined Alert (OB/OS + Divergence)", group = gAlerts, tooltip = "Fires only when a symbol is in OB/OS AND has an active divergence")
hysteresis   = input.float(2.0, "Hysteresis Buffer (RSI points)", minval = 0.0, maxval = 10.0, step = 0.5, group = gAlerts, tooltip = "Symbol must exit the zone by this many RSI points before it can re-trigger. Prevents flicker around the threshold.")
cooldownBars = input.int(10, "Cooldown (Bars)", minval = 0, maxval = 200, group = gAlerts, tooltip = "Minimum chart bars between two alerts for the same symbol")

// ─── COLORS ───
gColors = "Colors"
colOB  = input.color(#f23645, "Overbought Color", group = gColors)
colOS  = input.color(#239b87, "Oversold Color", group = gColors)
colDiv = input.color(#ffeb3b, "Divergence Marker Color", group = gColors)

// ─── COIN INPUTS ───
g1 = "Block 1"
b1c1 = input.string("BTC", "1.1", group=g1)
b1c2 = input.string("SOL", "1.2", group=g1)
b1c3 = input.string("ETH", "1.3", group=g1)
b1c4 = input.string("ZEC", "1.4", group=g1)
b1c5 = input.string("XRP", "1.5", group=g1)
b1c6 = input.string("XMR", "1.6", group=g1)

g2 = "Block 2"
b2c1 = input.string("VIRTUAL", "2.1", group=g2)
b2c2 = input.string("VET", "2.2", group=g2)
b2c3 = input.string("TRX", "2.3", group=g2)
b2c4 = input.string("PIPPIN", "2.4", group=g2)
b2c5 = input.string("TAO", "2.5", group=g2)
b2c6 = input.string("SUI", "2.6", group=g2)

g3 = "Block 3"
b3c1 = input.string("SEI", "3.1", group=g3)
b3c2 = input.string("RENDER", "3.2", group=g3)
b3c3 = input.string("POL", "3.3", group=g3)
b3c4 = input.string("ONDO", "3.4", group=g3)
b3c5 = input.string("NEAR", "3.5", group=g3)
b3c6 = input.string("LTC", "3.6", group=g3)

g4 = "Block 4"
b4c1 = input.string("LINK", "4.1", group=g4)
b4c2 = input.string("KAS", "4.2", group=g4)
b4c3 = input.string("INJ", "4.3", group=g4)
b4c4 = input.string("HYPE", "4.4", group=g4)
b4c5 = input.string("HBAR", "4.5", group=g4)
b4c6 = input.string("FET", "4.6", group=g4)

g5 = "Block 5"
b5c1 = input.string("ENA", "5.1", group=g5)
b5c2 = input.string("DOT", "5.2", group=g5)
b5c3 = input.string("DOGE", "5.3", group=g5)
b5c4 = input.string("JUP", "5.4", group=g5)
b5c5 = input.string("BNB", "5.5", group=g5)
b5c6 = input.string("AVAX", "5.6", group=g5)

g6 = "Block 6"
b6c1 = input.string("ATOM", "6.1", group=g6)
b6c2 = input.string("ARB", "6.2", group=g6)
b6c3 = input.string("APT", "6.3", group=g6)
b6c4 = input.string("ADA", "6.4", group=g6)
b6c5 = input.string("AAVE", "6.5", group=g6)
b6c6 = input.string("1000PEPE", "6.6", group=g6)

// ─── DIVERGENCE DETECTION ───
// A pivot is only confirmed lb bars after it printed. Age is therefore counted
// from confirmation, not from the pivot bar. Counting from the pivot bar means
// lb of the maxAge budget is already spent the moment the pivot appears, and
// any maxAge below lb makes divergences structurally impossible to display.
f_calc(rsiL, lb, srch, maxAge, strict) =>
    rsi = ta.rsi(close, rsiL)
    pH = ta.pivothigh(rsi, lb, lb)
    pL = ta.pivotlow(rsi, lb, lb)

    var array<float> plRsiHist = array.new<float>()
    var array<float> plPrcHist = array.new<float>()
    var array<int>   plBarHist = array.new<int>()
    var array<float> phRsiHist = array.new<float>()
    var array<float> phPrcHist = array.new<float>()
    var array<int>   phBarHist = array.new<int>()

    if not na(pL)
        array.push(plRsiHist, pL)
        array.push(plPrcHist, low[lb])
        array.push(plBarHist, bar_index - lb)
        while array.size(plBarHist) > 0 and bar_index - array.get(plBarHist, 0) > srch
            array.shift(plRsiHist)
            array.shift(plPrcHist)
            array.shift(plBarHist)

    if not na(pH)
        array.push(phRsiHist, pH)
        array.push(phPrcHist, high[lb])
        array.push(phBarHist, bar_index - lb)
        while array.size(phBarHist) > 0 and bar_index - array.get(phBarHist, 0) > srch
            array.shift(phRsiHist)
            array.shift(phPrcHist)
            array.shift(phBarHist)

    bullDiv = false
    nPL = array.size(plBarHist)
    if nPL >= 2
        lastIdx = nPL - 1
        age = bar_index - array.get(plBarHist, lastIdx) - lb
        if age >= 0 and age <= maxAge
            lastRsi = array.get(plRsiHist, lastIdx)
            lastPrc = array.get(plPrcHist, lastIdx)
            startK = strict ? lastIdx - 1 : 0
            for k = startK to lastIdx - 1
                if lastPrc < array.get(plPrcHist, k) and lastRsi > array.get(plRsiHist, k)
                    bullDiv := true
                    break

    bearDiv = false
    nPH = array.size(phBarHist)
    if nPH >= 2
        lastIdx = nPH - 1
        age = bar_index - array.get(phBarHist, lastIdx) - lb
        if age >= 0 and age <= maxAge
            lastRsi = array.get(phRsiHist, lastIdx)
            lastPrc = array.get(phPrcHist, lastIdx)
            startK = strict ? lastIdx - 1 : 0
            for k = startK to lastIdx - 1
                if lastPrc > array.get(phPrcHist, k) and lastRsi < array.get(phRsiHist, k)
                    bearDiv := true
                    break

    divFlag = (bullDiv or bearDiv) ? 1 : 0
    [rsi, divFlag]

f_fetch(s) =>
    request.security(symPrefix + s + symSuffix, tf,
         f_calc(rsiLen, divLookback, divRange, divMaxAge, divStrict), ignore_invalid_symbol = true)

[r1_1, d1_1] = f_fetch(b1c1)
[r1_2, d1_2] = f_fetch(b1c2)
[r1_3, d1_3] = f_fetch(b1c3)
[r1_4, d1_4] = f_fetch(b1c4)
[r1_5, d1_5] = f_fetch(b1c5)
[r1_6, d1_6] = f_fetch(b1c6)
[r2_1, d2_1] = f_fetch(b2c1)
[r2_2, d2_2] = f_fetch(b2c2)
[r2_3, d2_3] = f_fetch(b2c3)
[r2_4, d2_4] = f_fetch(b2c4)
[r2_5, d2_5] = f_fetch(b2c5)
[r2_6, d2_6] = f_fetch(b2c6)
[r3_1, d3_1] = f_fetch(b3c1)
[r3_2, d3_2] = f_fetch(b3c2)
[r3_3, d3_3] = f_fetch(b3c3)
[r3_4, d3_4] = f_fetch(b3c4)
[r3_5, d3_5] = f_fetch(b3c5)
[r3_6, d3_6] = f_fetch(b3c6)
[r4_1, d4_1] = f_fetch(b4c1)
[r4_2, d4_2] = f_fetch(b4c2)
[r4_3, d4_3] = f_fetch(b4c3)
[r4_4, d4_4] = f_fetch(b4c4)
[r4_5, d4_5] = f_fetch(b4c5)
[r4_6, d4_6] = f_fetch(b4c6)
[r5_1, d5_1] = f_fetch(b5c1)
[r5_2, d5_2] = f_fetch(b5c2)
[r5_3, d5_3] = f_fetch(b5c3)
[r5_4, d5_4] = f_fetch(b5c4)
[r5_5, d5_5] = f_fetch(b5c5)
[r5_6, d5_6] = f_fetch(b5c6)
[r6_1, d6_1] = f_fetch(b6c1)
[r6_2, d6_2] = f_fetch(b6c2)
[r6_3, d6_3] = f_fetch(b6c3)
[r6_4, d6_4] = f_fetch(b6c4)
[r6_5, d6_5] = f_fetch(b6c5)
[r6_6, d6_6] = f_fetch(b6c6)

f_pos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"   ? position.top_center    :
     s == "top_right"    ? position.top_right     :
     s == "middle_left"  ? position.middle_left   :
     s == "middle_center"? position.middle_center :
     s == "middle_right" ? position.middle_right  :
     s == "bottom_left"  ? position.bottom_left   :
     s == "bottom_center"? position.bottom_center :
     position.bottom_right

// ─── TIMEFRAME LABEL ───
f_tfLabel(t) =>
    t == "1"   ? "1m"  :
     t == "3"  ? "3m"  :
     t == "5"  ? "5m"  :
     t == "15" ? "15m" :
     t == "30" ? "30m" :
     t == "45" ? "45m" :
     t == "60" ? "1h"  :
     t == "120"? "2h"  :
     t == "180"? "3h"  :
     t == "240"? "4h"  :
     t == "360"? "6h"  :
     t == "480"? "8h"  :
     t == "720"? "12h" :
     t == "D" or t == "1D" ? "1D" :
     t == "W" or t == "1W" ? "1W" :
     t == "M" or t == "1M" ? "1M" :
     t

lSize = lblSize == "tiny" ? size.tiny : lblSize == "small" ? size.small : lblSize == "normal" ? size.normal : size.large

// ─── SCAN VS CHART CADENCE ───
// The table reads the scan timeframe, but alerts are evaluated on chart bar
// closes. A chart coarser than the scan means the scanner sees changes the
// alerts never report; a much finer chart re-evaluates the same state
// repeatedly. Neither is wrong, both surprise people.
scanSec  = timeframe.in_seconds(tf)
chartSec = timeframe.in_seconds(timeframe.period)
chartCoarser = chartSec > scanSec

// ─── ALERT BUFFER STATE ───
var array<int>  lastObosBar  = array.new<int>(36, -10000)
var array<int>  lastDivBar   = array.new<int>(36, -10000)
var array<int>  lastComboBar = array.new<int>(36, -10000)
var array<bool> obosArmed    = array.new<bool>(36, true)
var array<bool> divArmed     = array.new<bool>(36, true)
var array<bool> comboArmed   = array.new<bool>(36, true)

var bool fireObos  = false
var bool fireDiv   = false
var bool fireCombo = false
var string fireMsgObos  = ""
var string fireMsgDiv   = ""
var string fireMsgCombo = ""

maxFailRows = 10

// 80 rows: header 1 + OB header 1 + 15 + divider 1 + OS header 1 + 15
// + divider 1 + fail header 1 + 10 + overflow 1 = 47 worst case, with headroom.
var watchTbl = table.new(f_pos(tblPos), 2, 80, border_width = 0,
     frame_color = color.new(color.gray, 70), bgcolor = color.new(#0a0a14, 20))

if barstate.islast or barstate.isconfirmed
    nArr = array.from(b1c1,b1c2,b1c3,b1c4,b1c5,b1c6, b2c1,b2c2,b2c3,b2c4,b2c5,b2c6, b3c1,b3c2,b3c3,b3c4,b3c5,b3c6, b4c1,b4c2,b4c3,b4c4,b4c5,b4c6, b5c1,b5c2,b5c3,b5c4,b5c5,b5c6, b6c1,b6c2,b6c3,b6c4,b6c5,b6c6)
    vArr = array.from(r1_1,r1_2,r1_3,r1_4,r1_5,r1_6, r2_1,r2_2,r2_3,r2_4,r2_5,r2_6, r3_1,r3_2,r3_3,r3_4,r3_5,r3_6, r4_1,r4_2,r4_3,r4_4,r4_5,r4_6, r5_1,r5_2,r5_3,r5_4,r5_5,r5_6, r6_1,r6_2,r6_3,r6_4,r6_5,r6_6)
    bArr = array.from(1,1,1,1,1,1, 2,2,2,2,2,2, 3,3,3,3,3,3, 4,4,4,4,4,4, 5,5,5,5,5,5, 6,6,6,6,6,6)
    dArr = array.from(d1_1,d1_2,d1_3,d1_4,d1_5,d1_6, d2_1,d2_2,d2_3,d2_4,d2_5,d2_6, d3_1,d3_2,d3_3,d3_4,d3_5,d3_6, d4_1,d4_2,d4_3,d4_4,d4_5,d4_6, d5_1,d5_2,d5_3,d5_4,d5_5,d5_6, d6_1,d6_2,d6_3,d6_4,d6_5,d6_6)

    fireObos  := false
    fireDiv   := false
    fireCombo := false
    obosCoinList  = ""
    divCoinList   = ""
    comboCoinList = ""
    tfTxt = f_tfLabel(tf)

    if barstate.isconfirmed
        for i = 0 to 35
            n = array.get(nArr, i)
            v = array.get(vArr, i)
            dFlag = array.get(dArr, i)
            if n == "" or na(v)
                continue

            isOB = v >= obLevel
            isOS = v <= osLevel
            isExtreme = isOB or isOS
            hasDiv = dFlag == 1

            if alertOBOS
                armed = array.get(obosArmed, i)
                lastBar = array.get(lastObosBar, i)
                cooldownOK = bar_index - lastBar >= cooldownBars

                if isExtreme and armed and cooldownOK
                    fireObos := true
                    statusTxt = isOB ? "overbought" : "oversold"
                    msgTxt = tfTxt + " " + n + " " + str.tostring(math.round(v, 1)) + " " + statusTxt
                    obosCoinList := obosCoinList + (obosCoinList == "" ? "" : "\n") + msgTxt
                    array.set(lastObosBar, i, bar_index)
                    array.set(obosArmed, i, false)

                if not armed
                    if v < obLevel - hysteresis and v > osLevel + hysteresis
                        array.set(obosArmed, i, true)

            if alertDiv
                armed = array.get(divArmed, i)
                lastBar = array.get(lastDivBar, i)
                cooldownOK = bar_index - lastBar >= cooldownBars

                if hasDiv and armed and cooldownOK
                    fireDiv := true
                    msgTxt = tfTxt + " " + n + " " + str.tostring(math.round(v, 1)) + " divergence"
                    divCoinList := divCoinList + (divCoinList == "" ? "" : "\n") + msgTxt
                    array.set(lastDivBar, i, bar_index)
                    array.set(divArmed, i, false)

                if not hasDiv
                    array.set(divArmed, i, true)

            if alertCombo
                armed = array.get(comboArmed, i)
                lastBar = array.get(lastComboBar, i)
                cooldownOK = bar_index - lastBar >= cooldownBars

                if isExtreme and hasDiv and armed and cooldownOK
                    fireCombo := true
                    statusTxt = isOB ? "overbought" : "oversold"
                    msgTxt = tfTxt + " " + n + " " + str.tostring(math.round(v, 1)) + " " + statusTxt + " + divergence"
                    comboCoinList := comboCoinList + (comboCoinList == "" ? "" : "\n") + msgTxt
                    array.set(lastComboBar, i, bar_index)
                    array.set(comboArmed, i, false)

                if not isExtreme and not hasDiv
                    if v < obLevel - hysteresis and v > osLevel + hysteresis
                        array.set(comboArmed, i, true)

        fireMsgObos  := "RSI Hunter OB/OS:\n" + obosCoinList
        fireMsgDiv   := "RSI Hunter Divergence:\n" + divCoinList
        fireMsgCombo := "RSI Hunter OB/OS + Divergence:\n" + comboCoinList

    obIdx = array.new_int(0)
    obVal = array.new_float(0)
    osIdx = array.new_int(0)
    osVal = array.new_float(0)
    failArr = array.new_int(0)

    for i = 0 to 35
        n = array.get(nArr, i)
        v = array.get(vArr, i)
        if n != "" and na(v)
            array.push(failArr, i)
        else if n != "" and not na(v)
            if v >= obLevel
                array.push(obIdx, i)
                array.push(obVal, v)
            else if v <= osLevel
                array.push(osIdx, i)
                array.push(osVal, v)

    nOB = array.size(obIdx)
    if nOB > 1
        for i = 0 to nOB - 2
            for j = i + 1 to nOB - 1
                if array.get(obVal, i) < array.get(obVal, j)
                    tmpV = array.get(obVal, i)
                    tmpI = array.get(obIdx, i)
                    array.set(obVal, i, array.get(obVal, j))
                    array.set(obIdx, i, array.get(obIdx, j))
                    array.set(obVal, j, tmpV)
                    array.set(obIdx, j, tmpI)

    nOS = array.size(osIdx)
    if nOS > 1
        for i = 0 to nOS - 2
            for j = i + 1 to nOS - 1
                if array.get(osVal, i) < array.get(osVal, j)
                    tmpV = array.get(osVal, i)
                    tmpI = array.get(osIdx, i)
                    array.set(osVal, i, array.get(osVal, j))
                    array.set(osIdx, i, array.get(osIdx, j))
                    array.set(osVal, j, tmpV)
                    array.set(osIdx, j, tmpI)

    table.clear(watchTbl, 0, 0, 1, 79)
    int row = 0

    // ─── SCAN HEADER ───
    if showHeader
        chartTxt = f_tfLabel(timeframe.period)
        headTip = chartCoarser
             ? "The chart timeframe is coarser than the scan timeframe. The table stays current, but alerts are only evaluated when a chart bar closes, so state changes between chart bars are never reported. Match the chart to the scan timeframe, or use a finer one."
             : "Table reads the scan timeframe. Alerts are evaluated on chart bar closes."
        table.cell(watchTbl, 0, row, "RSI HUNTER  " + tfTxt,
             bgcolor = color.new(#1a1a2e, 10), text_color = color.new(color.white, 20),
             text_size = lSize, text_halign = text.align_left, tooltip = headTip)
        table.cell(watchTbl, 1, row, (chartCoarser ? "⚠ " : "") + "chart " + chartTxt,
             bgcolor = color.new(#1a1a2e, 10),
             text_color = chartCoarser ? #ffb74d : color.new(color.gray, 20),
             text_size = lSize, text_halign = text.align_right, tooltip = headTip)
        row += 1

    // ─── OVERBOUGHT ───
    table.cell(watchTbl, 0, row, "▲ OVERBOUGHT", bgcolor=color.new(colOB, 30), text_color=color.white, text_size=lSize, text_halign=text.align_left)
    table.cell(watchTbl, 1, row, showCount ? str.tostring(nOB) : "RSI", bgcolor=color.new(colOB, 30), text_color=color.white, text_size=lSize, text_halign=text.align_right)
    row += 1

    if nOB == 0
        table.cell(watchTbl, 0, row, "—", bgcolor=color.new(#1a1a1a, 50), text_color=color.new(color.gray, 30), text_size=lSize)
        table.cell(watchTbl, 1, row, "", bgcolor=color.new(#1a1a1a, 50), text_size=lSize)
        row += 1
    else
        limOB = math.min(nOB, maxPerSide)
        for k = 0 to limOB - 1
            i = array.get(obIdx, k)
            v = array.get(obVal, k)
            n = array.get(nArr, i)
            bIdx = array.get(bArr, i)
            dFlag = array.get(dArr, i)
            tag = showTag ? "B" + str.tostring(bIdx) + " " : ""
            divMark = (divOn and dFlag == 1) ? " ●" : ""
            txt = "▲ " + tag + n + divMark
            cellBg = (divOn and dFlag == 1) ? color.new(colDiv, 80) : color.new(#1a1a1a, 30)
            table.cell(watchTbl, 0, row, txt, bgcolor=cellBg, text_color=colOB, text_size=lSize, text_halign=text.align_left)
            table.cell(watchTbl, 1, row, str.tostring(math.round(v, 1)), bgcolor=cellBg, text_color=colOB, text_size=lSize, text_halign=text.align_right)
            row += 1

    table.cell(watchTbl, 0, row, "", bgcolor=color.new(color.gray, 70), text_size=size.tiny)
    table.cell(watchTbl, 1, row, "", bgcolor=color.new(color.gray, 70), text_size=size.tiny)
    row += 1

    // ─── OVERSOLD ───
    table.cell(watchTbl, 0, row, "▼ OVERSOLD", bgcolor=color.new(colOS, 30), text_color=color.white, text_size=lSize, text_halign=text.align_left)
    table.cell(watchTbl, 1, row, showCount ? str.tostring(nOS) : "RSI", bgcolor=color.new(colOS, 30), text_color=color.white, text_size=lSize, text_halign=text.align_right)
    row += 1

    if nOS == 0
        table.cell(watchTbl, 0, row, "—", bgcolor=color.new(#1a1a1a, 50), text_color=color.new(color.gray, 30), text_size=lSize)
        table.cell(watchTbl, 1, row, "", bgcolor=color.new(#1a1a1a, 50), text_size=lSize)
        row += 1
    else
        limOS = math.min(nOS, maxPerSide)
        for k = 0 to limOS - 1
            i = array.get(osIdx, k)
            v = array.get(osVal, k)
            n = array.get(nArr, i)
            bIdx = array.get(bArr, i)
            dFlag = array.get(dArr, i)
            tag = showTag ? "B" + str.tostring(bIdx) + " " : ""
            divMark = (divOn and dFlag == 1) ? " ●" : ""
            txt = "▼ " + tag + n + divMark
            cellBg = (divOn and dFlag == 1) ? color.new(colDiv, 80) : color.new(#1a1a1a, 30)
            table.cell(watchTbl, 0, row, txt, bgcolor=cellBg, text_color=colOS, text_size=lSize, text_halign=text.align_left)
            table.cell(watchTbl, 1, row, str.tostring(math.round(v, 1)), bgcolor=cellBg, text_color=colOS, text_size=lSize, text_halign=text.align_right)
            row += 1

    // ─── FAILED SYMBOLS ───
    if showFails
        nFails = array.size(failArr)

        table.cell(watchTbl, 0, row, "", bgcolor=color.new(color.gray, 70), text_size=size.tiny)
        table.cell(watchTbl, 1, row, "", bgcolor=color.new(color.gray, 70), text_size=size.tiny)
        row += 1

        table.cell(watchTbl, 0, row, "⚠ FAILED SYMBOLS", bgcolor=color.new(color.red, 50), text_color=color.white, text_size=lSize, text_halign=text.align_left)
        table.cell(watchTbl, 1, row, showCount ? str.tostring(nFails) : "", bgcolor=color.new(color.red, 50), text_color=color.white, text_size=lSize, text_halign=text.align_right)
        row += 1

        if nFails == 0
            table.cell(watchTbl, 0, row, "all OK ✓", bgcolor=#0a1a0a, text_color=#66bb6a, text_size=lSize, text_halign=text.align_left)
            table.cell(watchTbl, 1, row, "", bgcolor=#0a1a0a, text_size=lSize)
            row += 1
        else
            limFail = math.min(nFails, maxFailRows)
            for k = 0 to limFail - 1
                i = array.get(failArr, k)
                n = array.get(nArr, i)
                bIdx = array.get(bArr, i)
                tag = "B" + str.tostring(bIdx) + " "
                table.cell(watchTbl, 0, row, "⚠ " + tag + n, bgcolor=#1a1a2e, text_color=#ff8a80, text_size=lSize, text_halign=text.align_left)
                table.cell(watchTbl, 1, row, "n/a", bgcolor=#1a1a2e, text_color=#ff8a80, text_size=lSize, text_halign=text.align_right)
                row += 1

            if nFails > maxFailRows
                table.cell(watchTbl, 0, row, "+ " + str.tostring(nFails - maxFailRows) + " more",
                     bgcolor=#1a1a2e, text_color=color.new(color.gray, 20), text_size=lSize, text_halign=text.align_left)
                table.cell(watchTbl, 1, row, "", bgcolor=#1a1a2e, text_size=lSize)
                row += 1

// ─── ALERTS ───
alertcondition(fireObos,  title="OB/OS Alert",            message="RSI Hunter: One or more symbols entered OB/OS zone")
alertcondition(fireDiv,   title="Divergence Alert",       message="RSI Hunter: Divergence detected")
alertcondition(fireCombo, title="Combined (OB/OS + Div)", message="RSI Hunter: OB/OS + Divergence detected")

if fireObos
    alert(fireMsgObos, alert.freq_once_per_bar)
if fireDiv
    alert(fireMsgDiv, alert.freq_once_per_bar)
if fireCombo
    alert(fireMsgCombo, alert.freq_once_per_bar)
````
