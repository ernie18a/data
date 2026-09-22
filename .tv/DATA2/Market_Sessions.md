<!-- tradingview-pine-id: PUB;8934635037ea4c6989d041ef67f8a81c -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Market Sessions

Source: https://www.tradingview.com/script/orldqxtw/

## Description

Market Sessions (Up to 4, Fully Customizable)

Overview

This indicator plots up to four fully independent session boxes on your chart, so you can see exactly how price behaved during any market session, like Asia, London, New York, your own local exchange hours, or any other custom time window you define. Each session is a separate, self-contained module with its own time range, timezone, color, and set of optional overlays, so you're not locked into a fixed template.

Key Features

[*]Up to 4 sessions, each turned on/off independently
[*]Manually enter and edit the start/end time and timezone of every session — no fixed presets, define any window you trade
[*]Choose the box range per session: High/Low (full wick range) or Open/Close (candle body range)
[*]Optional mid-line, open-close line, and volume-weighted average price (VWAP) line per session
[*]Custom name and color for each session, shown in the on-chart label together with the weekday
[*]Global style controls: border style, line style, label size, box opacity, box background on/off, labels on/off
[*]Lookback control limits how many days of session history are drawn, keeping the chart responsive
[*]Optional "Hide Weekends" toggle for symbols that trade around the clock (crypto, FX)

How to Use

[*]Add the indicator to your chart.
[*]Open Settings and pick which of the 4 sessions you want (e.g. Asia, London, New York, plus a custom one).
[*]Set each session's start/end time and timezone under "Session Time" / "Timezone".
[*]Toggle Mid, Open-Close, or VWAP if you want those extra reference lines inside the box.
[*]Adjust the global style (border, opacity, labels) to match your chart theme.

Notes

Session boxes are built bar-by-bar from the chart's own timeframe, so their precision depends on your chart's resolution and data feed. This script is fully open-source — feel free to study or build on the code.

Disclaimer

This tool is for informational and analytical purposes only. It does not constitute financial advice, and past price behavior within a session is not indicative of future results. Always do your own research before making trading decisions.

---

## Source Code

````pine
//@version=6
indicator("Market Sessions", shorttitle = "Sessions", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// =============================================================================================
// GLOBAL / ADDITIONAL SETTINGS
// =============================================================================================
grpGeneral = "Additional Tools And Settings"

lookbackDays   = input.int(50, "Lookback (Days)", minval = 1, maxval = 365, group = grpGeneral, tooltip = "Sessions older than this many days are not drawn.")
boxOpacity     = input.int(85, "Box Opacity (%)", minval = 0, maxval = 100, group = grpGeneral)
borderStyleTxt = input.string("Dashed", "Border Style", options = ["Solid", "Dashed", "Dotted"], group = grpGeneral)
lineStyleTxt   = input.string("Dashed", "Line Style",   options = ["Solid", "Dashed", "Dotted"], group = grpGeneral)
labelSizeTxt   = input.string("Normal", "Label Size",   options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = grpGeneral)
showLabelsG    = input.bool(true,  "Session Labels", inline = "vis1", group = grpGeneral)
showBoxBgG     = input.bool(true,  "Box Background", inline = "vis1", group = grpGeneral)
showWeekdayG   = input.bool(true,  "Show Weekday",   inline = "vis2", group = grpGeneral)
hideWeekendsG  = input.bool(false, "Hide Weekends",  inline = "vis2", group = grpGeneral)

f_style(txt) =>
    txt == "Solid" ? line.style_solid : txt == "Dotted" ? line.style_dotted : line.style_dashed

f_size(txt) =>
    switch txt
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        "Huge"  => size.huge
        =>         size.normal

f_weekday(d) =>
    switch d
        dayofweek.sunday    => "Sunday"
        dayofweek.monday    => "Monday"
        dayofweek.tuesday   => "Tuesday"
        dayofweek.wednesday => "Wednesday"
        dayofweek.thursday  => "Thursday"
        dayofweek.friday    => "Friday"
        dayofweek.saturday  => "Saturday"
        =>                     ""

boxBorderStyle = f_style(borderStyleTxt)
lineStyleVal   = f_style(lineStyleTxt)
labelSizeVal   = f_size(labelSizeTxt)

// =============================================================================================
// SESSION 1  (default: Asia)
// =============================================================================================
grpS1  = "Session 1"
en1    = input.bool(false, "", inline = "s1a", group = grpS1)
nm1    = input.string("Asia", "", inline = "s1a", group = grpS1)
mid1   = input.bool(false, "Mid", inline = "s1b", group = grpS1)
oc1    = input.bool(false, "Open-Close", inline = "s1b", group = grpS1)
rng1   = input.string("High + Low", "Box Range", options = ["High + Low", "Open + Close"], inline = "s1c", group = grpS1)
vwap1  = input.bool(false, "VWAP", inline = "s1c", group = grpS1)
col1   = input.color(color.new(#7E57C2, 0), "Color", group = grpS1)
sess1  = input.session("0900-1800:1234567", "Session Time", group = grpS1)
tz1    = input.string("Asia/Tokyo", "Timezone", options = ["Chart Timezone", "Etc/UTC", "Europe/Berlin", "Europe/London", "Europe/Paris", "Europe/Zurich", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Singapore", "Asia/Dubai", "Asia/Kolkata", "Australia/Sydney"], group = grpS1)

// =============================================================================================
// SESSION 2  (default: London)
// =============================================================================================
grpS2  = "Session 2"
en2    = input.bool(false, "", inline = "s2a", group = grpS2)
nm2    = input.string("London", "", inline = "s2a", group = grpS2)
mid2   = input.bool(false, "Mid", inline = "s2b", group = grpS2)
oc2    = input.bool(false, "Open-Close", inline = "s2b", group = grpS2)
rng2   = input.string("High + Low", "Box Range", options = ["High + Low", "Open + Close"], inline = "s2c", group = grpS2)
vwap2  = input.bool(false, "VWAP", inline = "s2c", group = grpS2)
col2   = input.color(color.new(#26A69A, 0), "Color", group = grpS2)
sess2  = input.session("0800-1600:1234567", "Session Time", group = grpS2)
tz2    = input.string("Europe/London", "Timezone", options = ["Chart Timezone", "Etc/UTC", "Europe/Berlin", "Europe/London", "Europe/Paris", "Europe/Zurich", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Singapore", "Asia/Dubai", "Asia/Kolkata", "Australia/Sydney"], group = grpS2)

// =============================================================================================
// SESSION 3  (default: New York)
// =============================================================================================
grpS3  = "Session 3"
en3    = input.bool(false, "", inline = "s3a", group = grpS3)
nm3    = input.string("New York", "", inline = "s3a", group = grpS3)
mid3   = input.bool(false, "Mid", inline = "s3b", group = grpS3)
oc3    = input.bool(false, "Open-Close", inline = "s3b", group = grpS3)
rng3   = input.string("High + Low", "Box Range", options = ["High + Low", "Open + Close"], inline = "s3c", group = grpS3)
vwap3  = input.bool(false, "VWAP", inline = "s3c", group = grpS3)
col3   = input.color(color.new(#FF9800, 0), "Color", group = grpS3)
sess3  = input.session("0930-1600:1234567", "Session Time", group = grpS3)
tz3    = input.string("America/New_York", "Timezone", options = ["Chart Timezone", "Etc/UTC", "Europe/Berlin", "Europe/London", "Europe/Paris", "Europe/Zurich", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Singapore", "Asia/Dubai", "Asia/Kolkata", "Australia/Sydney"], group = grpS3)

// =============================================================================================
// SESSION 4  (default: DE / Frankfurt cash session, matches the example chart)
// =============================================================================================
grpS4  = "Session 4"
en4    = input.bool(true, "", inline = "s4a", group = grpS4)
nm4    = input.string("DE", "", inline = "s4a", group = grpS4)
mid4   = input.bool(false, "Mid", inline = "s4b", group = grpS4)
oc4    = input.bool(false, "Open-Close", inline = "s4b", group = grpS4)
rng4   = input.string("High + Low", "Box Range", options = ["High + Low", "Open + Close"], inline = "s4c", group = grpS4)
vwap4  = input.bool(false, "VWAP", inline = "s4c", group = grpS4)
col4   = input.color(color.new(#AB47BC, 0), "Color", group = grpS4)
sess4  = input.session("0900-1730:1234567", "Session Time", group = grpS4)
tz4    = input.string("Europe/Berlin", "Timezone", options = ["Chart Timezone", "Etc/UTC", "Europe/Berlin", "Europe/London", "Europe/Paris", "Europe/Zurich", "America/New_York", "America/Chicago", "America/Los_Angeles", "Asia/Tokyo", "Asia/Shanghai", "Asia/Hong_Kong", "Asia/Singapore", "Asia/Dubai", "Asia/Kolkata", "Australia/Sydney"], group = grpS4)

// =============================================================================================
// CORE DRAWING LOGIC
// One call site per session -> each gets its own persistent `var` state.
// =============================================================================================
f_drawSession(enable, sess, tzTxt, nm, col, showMid, showOC, boxRange, showVwap, lookback, opacity, boxStyle, lnStyle, lblSize, showLabels, showBg, showWeekday, hideWeekends) =>
    var box   sBox      = na
    var label sLbl      = na
    var line  sMidLine  = na
    var line  sOCLine   = na
    var line  sVwapLine = na
    var float sTop      = na
    var float sBot      = na
    var float sOpen     = na
    var int   sStartBar = na
    var float vwapPV    = 0.0
    var float vwapV     = 0.0

    tzResolved = tzTxt == "Chart Timezone" ? syminfo.timezone : tzTxt
    sessTime   = time(timeframe.period, sess, tzResolved)
    inSess     = not na(sessTime)
    isNewSess  = inSess and not inSess[1]

    barDow         = dayofweek(time, tzResolved)
    isWeekend      = barDow == dayofweek.saturday or barDow == dayofweek.sunday
    withinLookback = time >= last_bar_time - lookback * 86400000
    skip           = (hideWeekends and isWeekend) or not withinLookback

    if enable and not skip and isNewSess
        sTop      := boxRange == "Open + Close" ? math.max(open, close) : high
        sBot      := boxRange == "Open + Close" ? math.min(open, close) : low
        sOpen     := open
        sStartBar := bar_index
        vwapPV    := hlc3 * volume
        vwapV     := volume

        sBox := box.new(left = bar_index, top = sTop, right = bar_index + 1, bottom = sBot, border_color = col, border_width = 1, border_style = boxStyle, extend = extend.none, bgcolor = showBg ? color.new(col, opacity) : na)

        if showLabels
            wd = showWeekday ? " · " + f_weekday(barDow) : ""
            sLbl := label.new(x = bar_index, y = sTop, text = nm + wd, xloc = xloc.bar_index, yloc = yloc.price, color = na, style = label.style_none, textcolor = col, size = lblSize)
        else
            sLbl := na

        if showMid
            sMidLine := line.new(x1 = bar_index, y1 = (sTop + sBot) / 2, x2 = bar_index, y2 = (sTop + sBot) / 2, xloc = xloc.bar_index, color = col, style = lnStyle, width = 1)
        else
            sMidLine := na

        if showOC
            sOCLine := line.new(x1 = bar_index, y1 = sOpen, x2 = bar_index, y2 = sOpen, xloc = xloc.bar_index, color = col, style = lnStyle, width = 1)
        else
            sOCLine := na

        if showVwap
            sVwapLine := line.new(x1 = bar_index, y1 = hlc3, x2 = bar_index, y2 = hlc3, xloc = xloc.bar_index, color = col, style = line.style_solid, width = 1)
        else
            sVwapLine := na

        true

    else if enable and not skip and inSess and not na(sBox)
        sTop := boxRange == "Open + Close" ? math.max(sTop, close) : math.max(sTop, high)
        sBot := boxRange == "Open + Close" ? math.min(sBot, close) : math.min(sBot, low)
        vwapPV += hlc3 * volume
        vwapV  += volume

        box.set_top(sBox, sTop)
        box.set_bottom(sBox, sBot)
        box.set_right(sBox, bar_index + 1)

        if showLabels and not na(sLbl)
            label.set_y(sLbl, sTop)

        if showMid and not na(sMidLine)
            line.set_xy1(sMidLine, sStartBar, (sTop + sBot) / 2)
            line.set_xy2(sMidLine, bar_index + 1, (sTop + sBot) / 2)

        if showOC and not na(sOCLine)
            line.set_xy2(sOCLine, bar_index + 1, sOpen)

        if showVwap and not na(sVwapLine) and vwapV > 0
            line.set_xy2(sVwapLine, bar_index + 1, vwapPV / vwapV)

        true

// =============================================================================================
// DRAW ALL 4 SESSIONS
// =============================================================================================
f_drawSession(en1, sess1, tz1, nm1, col1, mid1, oc1, rng1, vwap1, lookbackDays, boxOpacity, boxBorderStyle, lineStyleVal, labelSizeVal, showLabelsG, showBoxBgG, showWeekdayG, hideWeekendsG)
f_drawSession(en2, sess2, tz2, nm2, col2, mid2, oc2, rng2, vwap2, lookbackDays, boxOpacity, boxBorderStyle, lineStyleVal, labelSizeVal, showLabelsG, showBoxBgG, showWeekdayG, hideWeekendsG)
f_drawSession(en3, sess3, tz3, nm3, col3, mid3, oc3, rng3, vwap3, lookbackDays, boxOpacity, boxBorderStyle, lineStyleVal, labelSizeVal, showLabelsG, showBoxBgG, showWeekdayG, hideWeekendsG)
f_drawSession(en4, sess4, tz4, nm4, col4, mid4, oc4, rng4, vwap4, lookbackDays, boxOpacity, boxBorderStyle, lineStyleVal, labelSizeVal, showLabelsG, showBoxBgG, showWeekdayG, hideWeekendsG)
````
