# Futures Rollover Volume Monitor

- url: https://www.tradingview.com/script/p3h0DVrV-Futures-Rollover-Volume-Monitor/
- type: indicator
- pine_id: PUB;48fcf810f71c4f6ca18c5f07fba917fd
- version: 1.0

## Description

[b]Futures Rollover Volume Monitor[/b]
This indicator helps futures traders identify the most actively traded contract months in real time and spot the exact moment when volume begins rotating from the front-month contract to the next one — the rollover window that typically occurs 1–2 weeks before expiry.
How it works
The script automatically detects the root symbol from whatever futures instrument is on your chart (GC, ES, NQ, CL, SI, HG, and any other futures root). It then builds a list of individual contract tickers across all 12-month codes (F G H J K M N Q U V X Z) for the selected start year and number of years to scan, fetches the daily volume for each one via request.security(), filters out expired contracts using their last bar timestamp, and ranks the remaining active contracts by volume. Only the top 3 are displayed.
[b]Key features[/b]

Auto-detects root symbol — works on any futures instrument without manual configuration
Always uses daily volume so numbers match your watchlist regardless of chart timeframe
Filters expired contracts by checking whether the contract's last bar is more than 7 days old
Ranks top 3 active contracts by today's volume, highest at the top
Shows previous day's volume and percentage change vs previous day for each contract
Rollover alert fires when the 2nd contract reaches 80% or more of the front month volume, turning the table frame red and displaying a warning banner
All 12 month codes enabled by default so it works across different futures schedules (quarterly, monthly, or custom)
Fully customisable colours, table position, and text size

[b]How to use[/b]
Add the indicator to any continuous or individual futures chart. The table updates automatically. When you see the 2nd-ranked contract closing the gap on the 1st — especially in the days approaching expiry — that is your signal that the market is beginning to roll. Once rank 1 and rank 2 are very close in volume, most professional traders have already begun rolling their positions to the next contract.
Settings

Start Year — the first year of contracts to scan (set to current year to avoid showing expired contracts from prior years)
Years to scan — how many years forward to include (1 or 2)
Active Month Codes — toggle individual months on or off to match the contract schedule of your instrument
Show Previous Bar Volume — toggle the Prev and vs Prev columns
Highlight Rollover Alert — toggle the red frame and banner when rollover is imminent
Position / Text Size / Colours — visual customisation

[b]Notes[/b]

Requires TradingView Pro or higher due to the number of request.security() calls (24 per chart)
Best used on a daily chart or any intraday chart — volume is always fetched at the daily timeframe
If fewer than 3 active contracts are found the table will show only the contracts available
The footer displays how many active contracts were detected for the current instrument

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © bachetodolniq

//@version=6
indicator("Futures Rollover Volume Monitor", shorttitle="FutRoll", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
var string GP1 = "Contract Settings"
startYear = input.int(2025, "Start Year",  minval=2020, maxval=2035, group=GP1)
numYears  = input.int(2,    "Years to scan", minval=1, maxval=2, group=GP1)

useF = input.bool(true, "Jan (F)", group="Active Month Codes", inline="m1")
useG = input.bool(true, "Feb (G)", group="Active Month Codes", inline="m1")
useH = input.bool(true, "Mar (H)", group="Active Month Codes", inline="m1")
useJ = input.bool(true, "Apr (J)", group="Active Month Codes", inline="m2")
useK = input.bool(true, "May (K)", group="Active Month Codes", inline="m2")
useM = input.bool(true, "Jun (M)", group="Active Month Codes", inline="m2")
useN = input.bool(true, "Jul (N)", group="Active Month Codes", inline="m3")
useQ = input.bool(true, "Aug (Q)", group="Active Month Codes", inline="m3")
useU = input.bool(true, "Sep (U)", group="Active Month Codes", inline="m3")
useV = input.bool(true, "Oct (V)", group="Active Month Codes", inline="m4")
useX = input.bool(true, "Nov (X)", group="Active Month Codes", inline="m4")
useZ = input.bool(true, "Dec (Z)", group="Active Month Codes", inline="m4")

var string GP3 = "Display"
tablePosition = input.string("Bottom Right", "Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GP3)
tableTextSize = input.string("Small",     "Text Size", options=["Tiny","Small","Normal","Large"], group=GP3)
showPrevVol   = input.bool(true, "Show Previous Bar Volume", group=GP3)
highlightRoll = input.bool(true, "Highlight Rollover Alert", group=GP3)

var string GP4 = "Colours"
colHeader     = input.color(color.new(#1B2A3B, 0),  "Header BG",      group=GP4)
col1st        = input.color(color.new(#00C896, 0),  "Front Month",    group=GP4)
col2nd        = input.color(color.new(#F5A623, 0),  "2nd",            group=GP4)
col3rd        = input.color(color.new(#E05C5C, 0),  "3rd",            group=GP4)
colAlert      = input.color(color.new(#FF4976, 0),  "Rollover Alert", group=GP4)
colText       = input.color(color.new(#E8EDF2, 0),  "Text",           group=GP4)
colHeaderText = input.color(color.new(#7EC8E3, 0),  "Header Text",    group=GP4)

// ─────────────────────────────────────────────────────────────────────────────
// DERIVE ROOT SYMBOL FROM CHART
// ─────────────────────────────────────────────────────────────────────────────
_rootOf(string sym) =>
    s0  = str.contains(sym, ":") ? str.substring(sym, str.pos(sym, ":") + 1, str.length(sym)) : sym
    s1  = str.replace(s0,  "1!", "", 0)
    s2  = str.replace(s1,  "!",  "", 0)
    s3  = str.replace_all(s2,  "2020", "")
    s4  = str.replace_all(s3,  "2021", "")
    s5  = str.replace_all(s4,  "2022", "")
    s6  = str.replace_all(s5,  "2023", "")
    s7  = str.replace_all(s6,  "2024", "")
    s8  = str.replace_all(s7,  "2025", "")
    s9  = str.replace_all(s8,  "2026", "")
    s10 = str.replace_all(s9,  "2027", "")
    s11 = str.replace_all(s10, "2028", "")
    last = str.substring(s11, str.length(s11) - 1, str.length(s11))
    isMonthCode = last == "F" or last == "G" or last == "H" or last == "J" or last == "K" or last == "M" or last == "N" or last == "Q" or last == "U" or last == "V" or last == "X" or last == "Z"
    isMonthCode ? str.substring(s11, 0, str.length(s11) - 1) : s11

rootSymbol = _rootOf(syminfo.ticker)

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
_tablePos(string p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>               position.bottom_left

_textSize(string s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        =>        size.normal

_fmt(float v) =>
    v >= 1e9 ? str.tostring(math.round(v / 1e9, 2)) + "B" :
     v >= 1e6 ? str.tostring(math.round(v / 1e6, 2)) + "M" :
     v >= 1e3 ? str.tostring(math.round(v / 1e3, 1)) + "K" :
     v <= 0   ? "-" :
     str.tostring(math.round(v, 0))

// ─────────────────────────────────────────────────────────────────────────────
// BUILD TICKER LIST
// ─────────────────────────────────────────────────────────────────────────────
var string[] allTickers = array.new_string(24, "")

if barstate.isfirst
    array.clear(allTickers)
    for yi = 0 to numYears - 1
        yr = startYear + yi
        if useF
            array.push(allTickers, rootSymbol + "F" + str.tostring(yr))
        if useG
            array.push(allTickers, rootSymbol + "G" + str.tostring(yr))
        if useH
            array.push(allTickers, rootSymbol + "H" + str.tostring(yr))
        if useJ
            array.push(allTickers, rootSymbol + "J" + str.tostring(yr))
        if useK
            array.push(allTickers, rootSymbol + "K" + str.tostring(yr))
        if useM
            array.push(allTickers, rootSymbol + "M" + str.tostring(yr))
        if useN
            array.push(allTickers, rootSymbol + "N" + str.tostring(yr))
        if useQ
            array.push(allTickers, rootSymbol + "Q" + str.tostring(yr))
        if useU
            array.push(allTickers, rootSymbol + "U" + str.tostring(yr))
        if useV
            array.push(allTickers, rootSymbol + "V" + str.tostring(yr))
        if useX
            array.push(allTickers, rootSymbol + "X" + str.tostring(yr))
        if useZ
            array.push(allTickers, rootSymbol + "Z" + str.tostring(yr))
    while array.size(allTickers) < 24
        array.push(allTickers, "")

// ─────────────────────────────────────────────────────────────────────────────
// FETCH VOLUME + TIME IN A SINGLE TUPLE CALL PER CONTRACT = 24 calls total
// Pine counts a tuple request.security() as ONE call regardless of how many
// expressions are in the tuple. This keeps us well under the 40-call limit.
// The `time` value tells us the timestamp of the most recent bar for that
// contract. If it is more than 7 days behind the current chart bar, the
// contract has expired and we exclude it from rankings.
// ─────────────────────────────────────────────────────────────────────────────
_fetch(string tk) =>
    request.security(tk, "D", [volume, volume[1], time], ignore_invalid_symbol=true)

[rv0,  rp0,  rt0 ] = _fetch(array.get(allTickers,  0))
[rv1,  rp1,  rt1 ] = _fetch(array.get(allTickers,  1))
[rv2,  rp2,  rt2 ] = _fetch(array.get(allTickers,  2))
[rv3,  rp3,  rt3 ] = _fetch(array.get(allTickers,  3))
[rv4,  rp4,  rt4 ] = _fetch(array.get(allTickers,  4))
[rv5,  rp5,  rt5 ] = _fetch(array.get(allTickers,  5))
[rv6,  rp6,  rt6 ] = _fetch(array.get(allTickers,  6))
[rv7,  rp7,  rt7 ] = _fetch(array.get(allTickers,  7))
[rv8,  rp8,  rt8 ] = _fetch(array.get(allTickers,  8))
[rv9,  rp9,  rt9 ] = _fetch(array.get(allTickers,  9))
[rv10, rp10, rt10] = _fetch(array.get(allTickers, 10))
[rv11, rp11, rt11] = _fetch(array.get(allTickers, 11))
[rv12, rp12, rt12] = _fetch(array.get(allTickers, 12))
[rv13, rp13, rt13] = _fetch(array.get(allTickers, 13))
[rv14, rp14, rt14] = _fetch(array.get(allTickers, 14))
[rv15, rp15, rt15] = _fetch(array.get(allTickers, 15))
[rv16, rp16, rt16] = _fetch(array.get(allTickers, 16))
[rv17, rp17, rt17] = _fetch(array.get(allTickers, 17))
[rv18, rp18, rt18] = _fetch(array.get(allTickers, 18))
[rv19, rp19, rt19] = _fetch(array.get(allTickers, 19))
[rv20, rp20, rt20] = _fetch(array.get(allTickers, 20))
[rv21, rp21, rt21] = _fetch(array.get(allTickers, 21))
[rv22, rp22, rt22] = _fetch(array.get(allTickers, 22))
[rv23, rp23, rt23] = _fetch(array.get(allTickers, 23))

v0  = na(rv0)  ? 0.0 : rv0
p0  = na(rp0)  ? 0.0 : rp0
ct0  = na(rt0)  ? 0 : rt0
v1  = na(rv1)  ? 0.0 : rv1
p1  = na(rp1)  ? 0.0 : rp1
ct1  = na(rt1)  ? 0 : rt1
v2  = na(rv2)  ? 0.0 : rv2
p2  = na(rp2)  ? 0.0 : rp2
ct2  = na(rt2)  ? 0 : rt2
v3  = na(rv3)  ? 0.0 : rv3
p3  = na(rp3)  ? 0.0 : rp3
ct3  = na(rt3)  ? 0 : rt3
v4  = na(rv4)  ? 0.0 : rv4
p4  = na(rp4)  ? 0.0 : rp4
ct4  = na(rt4)  ? 0 : rt4
v5  = na(rv5)  ? 0.0 : rv5
p5  = na(rp5)  ? 0.0 : rp5
ct5  = na(rt5)  ? 0 : rt5
v6  = na(rv6)  ? 0.0 : rv6
p6  = na(rp6)  ? 0.0 : rp6
ct6  = na(rt6)  ? 0 : rt6
v7  = na(rv7)  ? 0.0 : rv7
p7  = na(rp7)  ? 0.0 : rp7
ct7  = na(rt7)  ? 0 : rt7
v8  = na(rv8)  ? 0.0 : rv8
p8  = na(rp8)  ? 0.0 : rp8
ct8  = na(rt8)  ? 0 : rt8
v9  = na(rv9)  ? 0.0 : rv9
p9  = na(rp9)  ? 0.0 : rp9
ct9  = na(rt9)  ? 0 : rt9
v10 = na(rv10) ? 0.0 : rv10
p10 = na(rp10) ? 0.0 : rp10
ct10 = na(rt10) ? 0 : rt10
v11 = na(rv11) ? 0.0 : rv11
p11 = na(rp11) ? 0.0 : rp11
ct11 = na(rt11) ? 0 : rt11
v12 = na(rv12) ? 0.0 : rv12
p12 = na(rp12) ? 0.0 : rp12
ct12 = na(rt12) ? 0 : rt12
v13 = na(rv13) ? 0.0 : rv13
p13 = na(rp13) ? 0.0 : rp13
ct13 = na(rt13) ? 0 : rt13
v14 = na(rv14) ? 0.0 : rv14
p14 = na(rp14) ? 0.0 : rp14
ct14 = na(rt14) ? 0 : rt14
v15 = na(rv15) ? 0.0 : rv15
p15 = na(rp15) ? 0.0 : rp15
ct15 = na(rt15) ? 0 : rt15
v16 = na(rv16) ? 0.0 : rv16
p16 = na(rp16) ? 0.0 : rp16
ct16 = na(rt16) ? 0 : rt16
v17 = na(rv17) ? 0.0 : rv17
p17 = na(rp17) ? 0.0 : rp17
ct17 = na(rt17) ? 0 : rt17
v18 = na(rv18) ? 0.0 : rv18
p18 = na(rp18) ? 0.0 : rp18
ct18 = na(rt18) ? 0 : rt18
v19 = na(rv19) ? 0.0 : rv19
p19 = na(rp19) ? 0.0 : rp19
ct19 = na(rt19) ? 0 : rt19
v20 = na(rv20) ? 0.0 : rv20
p20 = na(rp20) ? 0.0 : rp20
ct20 = na(rt20) ? 0 : rt20
v21 = na(rv21) ? 0.0 : rv21
p21 = na(rp21) ? 0.0 : rp21
ct21 = na(rt21) ? 0 : rt21
v22 = na(rv22) ? 0.0 : rv22
p22 = na(rp22) ? 0.0 : rp22
ct22 = na(rt22) ? 0 : rt22
v23 = na(rv23) ? 0.0 : rv23
p23 = na(rp23) ? 0.0 : rp23
ct23 = na(rt23) ? 0 : rt23

// ─────────────────────────────────────────────────────────────────────────────
// BUILD TABLE
// ─────────────────────────────────────────────────────────────────────────────
if barstate.islast
    allVols  = array.from(v0,v1,v2,v3,v4,v5,v6,v7,v8,v9,v10,v11,v12,v13,v14,v15,v16,v17,v18,v19,v20,v21,v22,v23)
    allPVols = array.from(p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23)
    allTimes = array.from(ct0,ct1,ct2,ct3,ct4,ct5,ct6,ct7,ct8,ct9,ct10,ct11,ct12,ct13,ct14,ct15,ct16,ct17,ct18,ct19,ct20,ct21,ct22,ct23)

    sevenDaysMs = 7 * 24 * 60 * 60 * 1000

    // Only rank contracts whose last bar time is within 7 days of now
    sortedIdx = array.new_int(0)
    for i = 0 to 23
        ct = array.get(allTimes, i)
        isActive = ct > 0 and (time - ct) < sevenDaysMs
        if isActive and array.get(allVols, i) > 0
            array.push(sortedIdx, i)

    // Bubble sort descending by volume
    sz2 = array.size(sortedIdx)
    if sz2 > 1
        for i = 0 to sz2 - 2
            for j = 0 to sz2 - 2 - i
                ia = array.get(sortedIdx, j)
                ib = array.get(sortedIdx, j + 1)
                if array.get(allVols, ia) < array.get(allVols, ib)
                    array.set(sortedIdx, j,     ib)
                    array.set(sortedIdx, j + 1, ia)

    activeCount = array.size(sortedIdx)
    topVol      = activeCount > 0 ? array.get(allVols, array.get(sortedIdx, 0)) : 0.0
    secondVol   = activeCount > 1 ? array.get(allVols, array.get(sortedIdx, 1)) : 0.0
    rollingOver = topVol > 0 and secondVol > 0 and (secondVol / topVol) >= 0.80

    showRows  = math.min(activeCount, 3)
    cols      = showPrevVol ? 5 : 4
    totalRows = 2 + showRows + 1

    var table tbl = na
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(
         _tablePos(tablePosition), cols, totalRows,
         bgcolor      = color.new(#0A1520, 10),
         border_width = 1,
         border_color = color.new(#2A3F55, 80),
         frame_width  = 1,
         frame_color  = rollingOver and highlightRoll ? colAlert : color.new(#7EC8E3, 60))

    sz = _textSize(tableTextSize)

    // Title
    titleLabel = rollingOver and highlightRoll ? "!! ROLLOVER IMMINENT !!" : "Rollover Monitor | " + rootSymbol
    hdrColor   = rollingOver and highlightRoll ? colAlert : colHeaderText
    table.cell(tbl, 0, 0, titleLabel, text_color=hdrColor, bgcolor=colHeader, text_size=sz, text_halign=text.align_center)
    table.merge_cells(tbl, 0, 0, cols - 1, 0)

    // Sub-header
    table.cell(tbl, 0, 1, "#",        text_color=colHeaderText, bgcolor=colHeader, text_size=size.tiny, text_halign=text.align_center)
    table.cell(tbl, 1, 1, "Contract", text_color=colHeaderText, bgcolor=colHeader, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 2, 1, "Volume",   text_color=colHeaderText, bgcolor=colHeader, text_size=size.tiny, text_halign=text.align_right)
    if showPrevVol
        table.cell(tbl, 3, 1, "Prev",    text_color=colHeaderText, bgcolor=colHeader, text_size=size.tiny, text_halign=text.align_right)
        table.cell(tbl, 4, 1, "vs Prev", text_color=colHeaderText, bgcolor=colHeader, text_size=size.tiny, text_halign=text.align_center)
    else
        table.cell(tbl, 3, 1, "vs Prev", text_color=colHeaderText, bgcolor=colHeader, text_size=size.tiny, text_halign=text.align_center)

    // Data rows
    rankColors = array.from(col1st, col2nd, col3rd)
    for rank = 0 to showRows - 1
        si       = array.get(sortedIdx, rank)
        tk       = array.get(allTickers, si)
        v        = array.get(allVols,  si)
        pv       = array.get(allPVols, si)
        row      = rank + 2
        txtColor = array.get(rankColors, rank)
        rowBg    = color.new(txtColor, 82)

        trend    = pv > 0 and v > 0 ? (v - pv) / pv * 100 : 0.0
        trendStr = pv <= 0 or v <= 0 ? "-" : trend >= 0 ? "+" + str.tostring(math.round(trend, 1)) + "%" : str.tostring(math.round(trend, 1)) + "%"
        trendCol = pv <= 0 or v <= 0 ? colText : trend >= 0 ? color.new(#00C896, 0) : color.new(#E05C5C, 0)

        table.cell(tbl, 0, row, str.tostring(rank + 1), text_color=txtColor, bgcolor=rowBg, text_size=sz, text_halign=text.align_center)
        table.cell(tbl, 1, row, tk,      text_color=txtColor, bgcolor=rowBg, text_size=sz, text_halign=text.align_left)
        table.cell(tbl, 2, row, _fmt(v), text_color=txtColor, bgcolor=rowBg, text_size=sz, text_halign=text.align_right)
        if showPrevVol
            table.cell(tbl, 3, row, _fmt(pv), text_color=color.new(colText, 40), bgcolor=rowBg, text_size=sz, text_halign=text.align_right)
            table.cell(tbl, 4, row, trendStr,  text_color=trendCol,              bgcolor=rowBg, text_size=sz, text_halign=text.align_center)
        else
            table.cell(tbl, 3, row, trendStr, text_color=trendCol, bgcolor=rowBg, text_size=sz, text_halign=text.align_center)

    // Footer
    footRow   = 2 + showRows
    footMsg   = rollingOver ? "2nd contract >= 80% of front month - roll soon!" : str.tostring(activeCount) + " active contracts | " + rootSymbol
    footColor = rollingOver and highlightRoll ? colAlert : color.new(colHeaderText, 40)
    table.cell(tbl, 0, footRow, footMsg, text_color=footColor, bgcolor=color.new(colHeader, 20), text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(tbl, 0, footRow, cols - 1, footRow)
````
