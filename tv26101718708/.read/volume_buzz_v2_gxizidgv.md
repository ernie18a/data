# Volume Buzz v2

- url: https://www.tradingview.com/script/GxIZiDGV-Volume-Buzz-v2/
- type: indicator
- pine_id: PUB;1227ed9ed3e64a74bd407cc9801ba0a3
- version: 5.0

## Description

What changed from v1

- Now displays as % instead of multiplier (2.5x → 250%)
- Expanded the early window from 9:44 to 10:30
- Post-10:30 switches to live 5-min slots instead of freezing
- Cleaner and more responsive at the open

## Source Code

````pine
//@version=6
indicator("Time-of-Day Volume Buzz", shorttitle="Vol Buzz", overlay=false)

length      = input.int(14, "Lookback Days", minval=5, maxval=50)
highLine    = input.float(250.0, "High Threshold %", minval=10.0, step=10.0)
lowLine     = input.float(100.0, "Low Threshold %",  minval=10.0, step=10.0)
colHigh     = input.color(color.new(#00ff00, 0),       "Above High Color")
colLow      = input.color(color.new(#ff0015, 0),       "Below Low Color")
colNeutral  = input.color(color.new(#787b86, 0),       "Neutral Color")
bg_col      = input.color(color.new(color.black, 100), "Background", group="Table")
tbl_size    = input.string("Normal", "Table Size", options=["Tiny","Small","Normal","Large"], group="Table")

size_tbl = switch tbl_size
    "Normal" => size.normal
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Large"  => size.large

// ─── VolBuzz on fixed 5-min slots, regardless of chart timeframe ─────────────
f_volbuzz_5min() =>
    dayIdNow  = year * 10000 + month * 100 + dayofmonth
    isMarket5 = (hour > 9 or (hour == 9 and minute >= 30)) and hour < 16

    var int slotIdx        = -1
    var int lastSessionDay = na

    if isMarket5 and (na(lastSessionDay) or dayIdNow != lastSessionDay)
        slotIdx        := 0
        lastSessionDay := dayIdNow
    else if isMarket5
        slotIdx += 1
    else
        slotIdx := -1

    maxSlots5 = 79
    var float[] slotHistory = array.new_float(79 * 51, na)

    // Holds the last COMPLETED 5-min window's reading, so a hot window stays
    // visible while the next one is still forming
    var float lastCompletedBuzz = na

    float liveBuzz = na
    if isMarket5 and slotIdx >= 0 and slotIdx < maxSlots5
        base = slotIdx * (length + 1)
        for i = length - 1 to 1
            array.set(slotHistory, base + i, array.get(slotHistory, base + i - 1))
        array.set(slotHistory, base + 0, volume)
        float s = 0.0
        int   c = 0
        for i = 1 to length
            v = array.get(slotHistory, base + i)
            if not na(v)
                s += v
                c += 1
        float avg = c > 0 ? s / c : na
        liveBuzz := not na(avg) and avg > 0 ? (volume / avg) * 100 : na

        // Only commit the value once this 5-min bar has actually closed
        if barstate.isconfirmed and not na(liveBuzz)
            lastCompletedBuzz := liveBuzz

    lastCompletedBuzz

buzz = request.security(syminfo.tickerid, "5", f_volbuzz_5min(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

dailyUp = request.security(syminfo.tickerid, "D", close >= open, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

f_premarket_buzz() =>
    isPreMarket = (hour >= 4 and hour < 9) or (hour == 9 and minute < 30)
    var float[] pmHistory = array.new_float(51, na)
    var float   pmCumVol  = 0.0
    var int     pmLastDay = na
    if isPreMarket and (na(pmLastDay) or dayofmonth != pmLastDay)
        pmCumVol  := 0.0
        pmLastDay := dayofmonth
        for i = length - 1 to 1
            array.set(pmHistory, i, array.get(pmHistory, i - 1))
        array.set(pmHistory, 0, na)
    if isPreMarket
        pmCumVol += volume
        array.set(pmHistory, 0, pmCumVol)
    float avgPM = na
    float s = 0.0
    int   c = 0
    for i = 1 to length
        v = array.get(pmHistory, i)
        if not na(v)
            s += v
            c += 1
    avgPM := c > 0 ? s / c : na
    not na(avgPM) and avgPM > 0 ? (pmCumVol / avgPM) * 100 : na

f_afterhours_buzz() =>
    isAfterHours = hour >= 16 and hour < 20
    var float[] ahHistory = array.new_float(51, na)
    var float   ahCumVol  = 0.0
    var int     ahLastDay = na
    isFirstAHBar = hour == 16 and minute == 0
    if isFirstAHBar and (na(ahLastDay) or dayofmonth != ahLastDay)
        ahCumVol  := 0.0
        ahLastDay := dayofmonth
        for i = length - 1 to 1
            array.set(ahHistory, i, array.get(ahHistory, i - 1))
        array.set(ahHistory, 0, na)
    if isAfterHours
        ahCumVol += volume
        array.set(ahHistory, 0, ahCumVol)
    float avgAH = na
    float s = 0.0
    int   c = 0
    for i = 1 to length
        v = array.get(ahHistory, i)
        if not na(v)
            s += v
            c += 1
    avgAH := c > 0 ? s / c : na
    not na(avgAH) and avgAH > 0 ? (ahCumVol / avgAH) * 100 : na

pmBuzz    = request.security(syminfo.tickerid, "1", f_premarket_buzz(),  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
ahBuzz    = request.security(syminfo.tickerid, "1", f_afterhours_buzz(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
prevClose = request.security(syminfo.tickerid, "D", close[1],            gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
pmUp = close >= prevClose
ahUp = close >= prevClose

f_buzz_color(val) =>
    if na(val)
        colNeutral
    else if val >= highLine
        dailyUp ? colHigh : colLow
    else
        colNeutral

isMarketOpen = hour >= 9 and not (hour == 9 and minute < 30) and hour < 16
isOpenBar    = hour == 9 and minute == 30

var float curBuzz  = na
var float peakBuzz = na
var int   peakDay  = na

if isOpenBar and (na(peakDay) or dayofmonth != peakDay)
    curBuzz  := na
    peakBuzz := na
    peakDay  := dayofmonth

if isMarketOpen
    if not na(buzz)
        curBuzz := buzz
        if na(peakBuzz) or curBuzz > peakBuzz
            peakBuzz := curBuzz

isPreMarketNow  = (hour < 9) or (hour == 9 and minute < 30)
isAfterHoursNow = hour >= 16 and hour < 20
var table buzz_tbl = table.new(position.top_left, 2, 2, bgcolor=bg_col, border_width=0, frame_width=0)

if barstate.islast
    buzzStr = not na(curBuzz) ? str.tostring(curBuzz, "0") + "%" : "—"
    col_cur = f_buzz_color(curBuzz)
    table.cell(buzz_tbl, 0, 0, "VolBuzz", text_color=color.white, text_size=size_tbl, text_halign=text.align_left)
    table.cell(buzz_tbl, 1, 0, buzzStr,   text_color=col_cur,     text_size=size_tbl, text_halign=text.align_center)
    if isPreMarketNow
        pmBuzzStr = not na(pmBuzz) ? str.tostring(pmBuzz, "0") + "%" : "—"
        col_pm    = pmBuzz >= 300 ? (pmUp ? colHigh : colLow) : colNeutral
        table.cell(buzz_tbl, 0, 1, "PreBuzz",  text_color=color.white, text_size=size_tbl, text_halign=text.align_left)
        table.cell(buzz_tbl, 1, 1, pmBuzzStr,  text_color=col_pm,      text_size=size_tbl, text_halign=text.align_center)
    else if isAfterHoursNow
        ahBuzzStr = not na(ahBuzz) ? str.tostring(ahBuzz, "0") + "%" : "—"
        col_ah    = ahBuzz >= 300 ? (ahUp ? colHigh : colLow) : colNeutral
        table.cell(buzz_tbl, 0, 1, "AH Buzz",  text_color=color.white, text_size=size_tbl, text_halign=text.align_left)
        table.cell(buzz_tbl, 1, 1, ahBuzzStr,  text_color=col_ah,      text_size=size_tbl, text_halign=text.align_center)
    else
        table.cell(buzz_tbl, 0, 1, "", text_color=color.white, text_size=size_tbl)
        table.cell(buzz_tbl, 1, 1, "", text_color=color.white, text_size=size_tbl)

plot(buzz, title="Vol Buzz %", display=display.none)
````
