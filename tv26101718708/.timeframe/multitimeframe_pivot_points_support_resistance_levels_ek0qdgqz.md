# Multi-Timeframe Pivot Points: Support & Resistance Levels

- url: https://www.tradingview.com/script/eK0QdgQZ-multi-timeframe-pivot-points-support-resistance-levels/
- type: indicator
- pine_id: PUB;1312124c20f64b57a1c562761533353c
- version: 1.0

## Description

Multi-Timeframe Pivot Points draws the classic pivot levels (PP, R1-R3, S1-S3) on your chart for up to five timeframes at the same time. Use it for weekly pivot points, daily, monthly, hourly or any custom timeframe such as 4h, 8h or 15m, and see the support and resistance levels of each one on a single chart.

How it works
Each slot in the settings has an on/off switch, a timeframe and a colour. The levels are calculated from the previous completed bar of the selected timeframe (for example, the previous week for W, or the previous 4-hour bar for 4h). The lines are drawn across the whole period from its first bar, so the levels are visible in advance.

Formulas
P = (H + L + C) / 3
R1 = 2P - L; R2 = P + (H - L); R3 = H + 2(P - L)
S1 = 2P - H; S2 = P - (H - L); S3 = L - 2(H - P)

Features
- Up to 5 timeframes at once, each with its own colour
- Any timeframe from the dropdown, including custom values
- Each of the 7 levels can be switched on or off
- Option to show only the current period or keep previous periods
- Optional price and timeframe in every label, with adjustable decimals
- Bold labels

Notes
The selected timeframe cannot be smaller than the chart timeframe. Such a slot is hidden and a warning appears in the bottom-right corner. TradingView limits a script to 500 lines, so the more timeframes you enable, the fewer previous periods are shown.

This script is for educational purposes and is not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © dentist313nail

//@version=6
indicator("Multi-Timeframe Pivot Points", shorttitle="MTF Pivots", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== Settings: timeframe slots =====
en1 = input.bool(true,  "Slot 1", inline="s1", group="Timeframes")
tf1 = input.timeframe("W",   "", inline="s1", group="Timeframes")
col1 = input.color(color.orange, "", inline="s1", group="Timeframes")

en2 = input.bool(false, "Slot 2", inline="s2", group="Timeframes")
tf2 = input.timeframe("D",   "", inline="s2", group="Timeframes")
col2 = input.color(color.blue, "", inline="s2", group="Timeframes")

en3 = input.bool(false, "Slot 3", inline="s3", group="Timeframes")
tf3 = input.timeframe("240", "", inline="s3", group="Timeframes")
col3 = input.color(color.purple, "", inline="s3", group="Timeframes")

en4 = input.bool(false, "Slot 4", inline="s4", group="Timeframes")
tf4 = input.timeframe("60",  "", inline="s4", group="Timeframes")
col4 = input.color(color.teal, "", inline="s4", group="Timeframes")

en5 = input.bool(false, "Slot 5", inline="s5", group="Timeframes")
tf5 = input.timeframe("M",   "", inline="s5", group="Timeframes")
col5 = input.color(color.fuchsia, "", inline="s5", group="Timeframes")

// ===== Settings: general =====
showOld   = input.bool(true, "Show previous periods", group="General", tooltip="When off, only the current period's levels are shown.")
showPrice = input.bool(true, "Show price in label", group="General", tooltip="Adds the level's price in brackets, e.g. PP (4791.36).")
showTf    = input.bool(true, "Show timeframe in label", group="General", tooltip="Adds the timeframe in front of the level name, e.g. W PP.")
decimals  = input.int(2, "Price decimals", minval=0, maxval=8, group="General")

// ===== Settings: visible levels (apply to all slots) =====
showPP = input.bool(true, "PP", group="Visible levels")
showR1 = input.bool(true, "R1", group="Visible levels")
showR2 = input.bool(true, "R2", group="Visible levels")
showR3 = input.bool(true, "R3", group="Visible levels")
showS1 = input.bool(true, "S1", group="Visible levels")
showS2 = input.bool(true, "S2", group="Visible levels")
showS3 = input.bool(true, "S3", group="Visible levels")

// ===== Helpers =====
// Readable timeframe name: "240" -> "4h", "60" -> "1h", "15" -> "15m", "1D" -> "D"
fmtTf(string tf) =>
    string out = tf
    if tf == "1D" or tf == "1W" or tf == "1M"
        out := str.substring(tf, 1)
    else if not na(str.tonumber(tf))
        float m = str.tonumber(tf)
        out := (m >= 60 and m % 60 == 0) ? str.tostring(m / 60, "#") + "h" : str.tostring(m, "#") + "m"
    out

// Price format: "0.00" for 2 decimals, "0" for none
priceFmt = decimals == 0 ? "0" : "0." + str.repeat("0", decimals)

names = array.from("PP", "R1", "R2", "R3", "S1", "S2", "S3")

// Draws the pivot levels of one slot. Returns true if the slot's timeframe is smaller than the chart's.
drawPivots(bool enabled, string tf, color col, array<line> lns, array<label> lbs) =>
    bool tooSmall = timeframe.in_seconds(tf) < timeframe.in_seconds(timeframe.period)

    // Previous completed bar of the selected timeframe
    [h, l, c] = request.security(syminfo.tickerid, tf, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

    // Classic pivot point formulas
    p  = (h + l + c) / 3
    r1 = 2 * p - l
    r2 = p + h - l
    r3 = h + 2 * (p - l)
    s1 = 2 * p - h
    s2 = p - h + l
    s3 = l - 2 * (h - p)

    levels = array.from(p, r1, r2, r3, s1, s2, s3)
    shows  = array.from(showPP, showR1, showR2, showR3, showS1, showS2, showS3)

    bool newPeriod = timeframe.change(tf)
    // Closing time of the current period (fallback: open + timeframe length)
    int closeT = time_close(tf)
    int endT = na(closeT) ? time + timeframe.in_seconds(tf) * 1000 : closeT
    string prefix = showTf ? fmtTf(tf) + " " : ""

    if enabled and not tooSmall and newPeriod and not na(p)
        // If previous periods are hidden, delete the last period's lines and labels
        if not showOld
            for ln in lns
                line.delete(ln)
            for lb in lbs
                label.delete(lb)
        lns.clear()
        lbs.clear()
        for i = 0 to 6
            if shows.get(i)
                lv = levels.get(i)
                txt = prefix + names.get(i) + (showPrice ? " (" + str.tostring(lv, priceFmt) + ")" : "")
                lns.push(line.new(time, lv, endT, lv, xloc=xloc.bar_time, color=col, width=2))
                lbs.push(label.new(endT, lv, txt, xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.white, 100), textcolor=col, size=size.small, text_formatting=text.format_bold))
    tooSmall

// ===== Storage per slot =====
var lines1  = array.new<line>()
var labels1 = array.new<label>()
var lines2  = array.new<line>()
var labels2 = array.new<label>()
var lines3  = array.new<line>()
var labels3 = array.new<label>()
var lines4  = array.new<line>()
var labels4 = array.new<label>()
var lines5  = array.new<line>()
var labels5 = array.new<label>()

// ===== Draw all slots =====
small1 = drawPivots(en1, tf1, col1, lines1, labels1)
small2 = drawPivots(en2, tf2, col2, lines2, labels2)
small3 = drawPivots(en3, tf3, col3, lines3, labels3)
small4 = drawPivots(en4, tf4, col4, lines4, labels4)
small5 = drawPivots(en5, tf5, col5, lines5, labels5)

// ===== Warning if a slot's timeframe is smaller than the chart timeframe =====
var table warn = table.new(position.bottom_right, 1, 1)
if barstate.islast
    string msg = ""
    if en1 and small1
        msg += "Slot 1 (" + fmtTf(tf1) + ") is smaller than the chart timeframe - hidden\n"
    if en2 and small2
        msg += "Slot 2 (" + fmtTf(tf2) + ") is smaller than the chart timeframe - hidden\n"
    if en3 and small3
        msg += "Slot 3 (" + fmtTf(tf3) + ") is smaller than the chart timeframe - hidden\n"
    if en4 and small4
        msg += "Slot 4 (" + fmtTf(tf4) + ") is smaller than the chart timeframe - hidden\n"
    if en5 and small5
        msg += "Slot 5 (" + fmtTf(tf5) + ") is smaller than the chart timeframe - hidden\n"
    table.cell(warn, 0, 0, msg, text_color=color.orange, text_size=size.small)
````
