# MTF Bar Close Timer

- url: https://www.tradingview.com/script/ipJYNDFR-MTF-Bar-Close-Timer/
- type: indicator
- pine_id: PUB;29ce335f9a2943d5850a1296ba1b0852
- version: 1.0

## Description

MTF Bar Close Timer — Multi-Timeframe Countdown with Adjustable Font Size
OVERVIEW
A clean, customizable countdown table showing exactly how much time is left until the candle closes on up to 6 timeframes at once — without switching charts. Built for futures and intraday traders who time entries around bar closes (1M scalps, 5M/15M confirmations, 1H/4H structure).
FEATURES

Up to 6 configurable timeframes, each with its own on/off toggle (default: 1M, 5M, 15M, 1H, 4H)
Adjustable font size: Tiny, Small, Normal, Large, Huge
Dual clock display: your local time + exchange time (NYSE, CME, London, Tokyo, Sydney, UTC)
Highlight row for your key timeframe (default 4H)
Warning color when a candle is about to close (configurable threshold in seconds)
12h or 24h time format
Full color customization: background, text, header, highlight, border, warning
9 table positions on the chart
4H anchor offset (UTC hour) to align higher-timeframe countdowns with your chart's candle open

SETTINGS

Timeframe Settings: pick your 6 timeframes and the highlight timeframe
Time Settings: exchange clock, local clock, 4H anchor
Table Settings: font size and position
Visibility: show/hide local time column, current times row, seconds
Colors: match the table to your chart theme

NOTES

Countdown updates when the chart receives a new tick. On slow or closed markets the timer pauses until the next tick arrives — this is a Pine Script limitation, not a bug.
If your 4H countdown looks offset from your chart's 4H candles, adjust the "4H Anchor Start (UTC Hour)" setting.

Works on any symbol and any chart timeframe. No repainting, no data requests — lightweight and instant.

## Source Code

````pine
//@version=6
// MTF Bar Close Countdown Timer with adjustable font size
indicator("MTF Bar Close Timer", overlay = true)

// ===== Timeframe Settings =====
grpTF = "Timeframe Settings"
show1 = input.bool(true,  "Timeframe 1", group = grpTF, inline = "t1")
tf1   = input.timeframe("1",   "", group = grpTF, inline = "t1")
show2 = input.bool(true,  "Timeframe 2", group = grpTF, inline = "t2")
tf2   = input.timeframe("5",   "", group = grpTF, inline = "t2")
show3 = input.bool(true,  "Timeframe 3", group = grpTF, inline = "t3")
tf3   = input.timeframe("15",  "", group = grpTF, inline = "t3")
show4 = input.bool(true,  "Timeframe 4", group = grpTF, inline = "t4")
tf4   = input.timeframe("60",  "", group = grpTF, inline = "t4")
show5 = input.bool(true,  "Timeframe 5", group = grpTF, inline = "t5")
tf5   = input.timeframe("240", "", group = grpTF, inline = "t5")
show6 = input.bool(false, "Timeframe 6", group = grpTF, inline = "t6")
tf6   = input.timeframe("30S", "", group = grpTF, inline = "t6")
tfHi  = input.timeframe("240", "Timeframe Highlight", group = grpTF)

// ===== Time Settings =====
grpTime    = "Time Settings"
exName     = input.string("New York (NYSE)", "Exchange Time", options = ["New York (NYSE)", "Chicago (CME)", "London", "Tokyo", "Sydney", "UTC"], group = grpTime)
locName    = input.string("London", "Local Timezone", options = ["New York (NYSE)", "Chicago (CME)", "London", "Tokyo", "Sydney", "UTC"], group = grpTime)
anchorHour = input.int(0, "4H Anchor Start (UTC Hour)", minval = 0, maxval = 23, group = grpTime, tooltip = "Aligns countdowns for 1H+ timeframes. Adjust if your 4H countdown is offset from your chart candles")

// ===== Table Settings =====
grpTbl  = "Table Settings"
fontStr = input.string("Normal", "Font Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpTbl)
posStr  = input.string("Top Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = grpTbl)

// ===== Visibility Settings =====
grpVis    = "Visibility Settings"
showLocal = input.bool(true,  "Show Local Time Column", group = grpVis)
showTimes = input.bool(true,  "Show Current Times Row", group = grpVis)
use24h    = input.bool(false, "24 Hour Format", group = grpVis)
showSecT  = input.bool(false, "Show Seconds on Current Times", group = grpVis)

// ===== Color Settings =====
grpCol  = "Color Settings"
cBg     = input.color(color.new(#000000, 0), "Background", group = grpCol)
cText   = input.color(color.white, "Table Text", group = grpCol)
cTime   = input.color(color.lime,  "Time Text", group = grpCol)
cHead   = input.color(#0b1f5e,     "Header", group = grpCol)
cHiLite = input.color(#3b6fd1,     "Highlight", group = grpCol)
cBorder = input.color(color.black, "Border", group = grpCol)
cWarn   = input.color(color.red,   "Warning", group = grpCol)

// ===== Warning Settings =====
grpAl   = "Warning Settings"
warnSec = input.int(10, "Warning Threshold (seconds)", minval = 1, group = grpAl)

// ===== Helpers (all global scope) =====
tzOf(name) =>
    switch name
        "New York (NYSE)" => "America/New_York"
        "Chicago (CME)"   => "America/Chicago"
        "London"          => "Europe/London"
        "Tokyo"           => "Asia/Tokyo"
        "Sydney"          => "Australia/Sydney"
        => "UTC"

fontOf(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

posOf(s) =>
    switch s
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

shortName(name) =>
    switch name
        "New York (NYSE)" => "NYSE"
        "Chicago (CME)"   => "CME"
        => name

tfLabel(tf) =>
    s = timeframe.in_seconds(tf)
    s < 60 ? "S" + str.tostring(s) : s < 3600 ? "M" + str.tostring(s / 60) : s < 86400 ? "H" + str.tostring(s / 3600) : "D" + str.tostring(s / 86400)

secLeft(tf, anchor) =>
    tfs  = timeframe.in_seconds(tf)
    nowS = timenow / 1000
    tfs - ((nowS - anchor * 3600) % tfs)

fmtCount(secsIn) =>
    s  = int(secsIn)
    h  = math.floor(s / 3600)
    m  = math.floor((s % 3600) / 60)
    ss = s % 60
    h > 0 ? str.tostring(h, "00") + ":" + str.tostring(m, "00") + ":" + str.tostring(ss, "00") : str.tostring(m, "00") + ":" + str.tostring(ss, "00")

// addRow at global scope - takes the table as a parameter, returns the next row index
addRow(table tbl, bool en, string tf, int r, string hiTf, int wSec, int anchor, color colText, color colBg, color colHi, color colWarn, string fsz) =>
    rr = r
    if en
        rem   = secLeft(tf, anchor)
        isHi  = timeframe.in_seconds(tf) == timeframe.in_seconds(hiTf)
        rowBg = isHi ? colHi : colBg
        cdCol = rem <= wSec ? colWarn : colText
        table.cell(tbl, 0, rr, tfLabel(tf), text_color = colText, bgcolor = rowBg, text_size = fsz)
        table.cell(tbl, 1, rr, fmtCount(rem), text_color = cdCol, bgcolor = rowBg, text_size = fsz)
        rr += 1
    rr

fSize   = fontOf(fontStr)
tblPos  = posOf(posStr)
exTZ    = tzOf(exName)
locTZ   = tzOf(locName)
timeFmt = use24h ? (showSecT ? "HH:mm:ss" : "HH:mm") : (showSecT ? "hh:mm:ss a" : "hh:mm a")

// ===== Table =====
var table t = na

if barstate.islast or barstate.isrealtime
    if not na(t)
        table.delete(t)
    t := table.new(tblPos, 2, 8, bgcolor = cBg, border_color = cBorder, border_width = 1)

    row = 0
    table.cell(t, 0, row, showLocal ? shortName(locName) : "TF", text_color = cText, bgcolor = cHead, text_size = fSize)
    table.cell(t, 1, row, shortName(exName), text_color = cText, bgcolor = cHead, text_size = fSize)
    row += 1

    if showTimes
        table.cell(t, 0, row, showLocal ? str.format_time(timenow, timeFmt, locTZ) : "", text_color = cTime, bgcolor = cBg, text_size = fSize)
        table.cell(t, 1, row, str.format_time(timenow, timeFmt, exTZ), text_color = cTime, bgcolor = cBg, text_size = fSize)
        row += 1

    row := addRow(t, show1, tf1, row, tfHi, warnSec, anchorHour, cText, cBg, cHiLite, cWarn, fSize)
    row := addRow(t, show2, tf2, row, tfHi, warnSec, anchorHour, cText, cBg, cHiLite, cWarn, fSize)
    row := addRow(t, show3, tf3, row, tfHi, warnSec, anchorHour, cText, cBg, cHiLite, cWarn, fSize)
    row := addRow(t, show4, tf4, row, tfHi, warnSec, anchorHour, cText, cBg, cHiLite, cWarn, fSize)
    row := addRow(t, show5, tf5, row, tfHi, warnSec, anchorHour, cText, cBg, cHiLite, cWarn, fSize)
    row := addRow(t, show6, tf6, row, tfHi, warnSec, anchorHour, cText, cBg, cHiLite, cWarn, fSize)
````
