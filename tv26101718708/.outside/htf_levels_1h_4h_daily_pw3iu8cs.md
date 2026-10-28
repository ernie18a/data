# HTF Levels | 1H 4H Daily

- url: https://www.tradingview.com/script/pW3iu8cS-HTF-Levels-1H-4H-Daily/
- type: indicator
- pine_id: PUB;f2868c88b3ea43d8a528e9713c83ce54
- version: 1.0

## Description

HTF Levels | 1H 4H Daily
Plots the current and previous High, Low, and Midpoint for the 1-Hour, 4-Hour, and Daily timeframes directly on your chart — regardless of which timeframe you are trading on.
What makes this original:
Most HTF level tools simply draw static lines from request.security() on every bar, cluttering historical price action. This script draws only on the current bar (barstate.islast), keeping the chart clean. It also includes an automatic level merging algorithm — when levels from different timeframes fall within a configurable percentage threshold of each other, they are averaged into a single line with a combined label (e.g. 4H H | Prv D H), visually identifying high-confluence zones without requiring manual comparison.
Levels plotted:

Current period: High, Midpoint ((H+L)/2), Low — lines extend across the full chart
Previous period: High, Midpoint, Low — lines extend left only for visual separation

Confluence Merging:
When two or more levels are within the merge threshold (default 0.05%), they collapse into one averaged line with a merged label. Adjust the threshold in settings to suit your instrument's tick size.
Alerts:
Every level has its own named alert condition. Use individual alerts (e.g. "4H High", "Prev Daily Low") or the master "Any HTF Level" alert to get notified when price enters proximity of any key zone. The alert buffer % is fully adjustable.
Settings:

Toggle each timeframe independently
Custom color per timeframe
Line width and label size controls
Merge threshold % — how close levels must be to combine
Alert buffer % — how close price must be to trigger

Best used on intraday timeframes (1m–30m) where 1H, 4H, and Daily levels act as key support and resistance.

## Source Code

````pine
//@version=5
indicator("HTF Levels | 1H 4H Daily", overlay=true, max_lines_count=500, max_labels_count=200)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

grp1 = "1-Hour"
show1H    = input.bool(true, "Show 1H",        group=grp1)
col1H     = input.color(color.new(#00E5FF, 0), "1H Color",  group=grp1)

grp2 = "4-Hour"
show4H    = input.bool(true, "Show 4H",        group=grp2)
col4H     = input.color(color.new(#FF9800, 0), "4H Color",  group=grp2)

grp3 = "Daily"
showD     = input.bool(true, "Show Daily",     group=grp3)
colD      = input.color(color.new(#FF4444, 0), "Daily Color", group=grp3)

grp4 = "Style"
lineWidth  = input.int(1, "Line Width", minval=1, maxval=4, group=grp4)
showLabels = input.bool(true, "Show Labels", group=grp4)
labelSize  = input.string("Large", "Label Size", options=["Normal","Large","Huge"], group=grp4)

grp5 = "Merge & Alerts"
mergeThresh = input.float(0.05, "Merge Threshold (%)", minval=0.01, maxval=1.0, step=0.01, group=grp5,
     tooltip="Levels within this % of each other will be merged into one zone label")
alertBuffer = input.float(0.05, "Alert Buffer (%)", minval=0.01, maxval=1.0, step=0.01, group=grp5,
     tooltip="How close price needs to be to a level to trigger an alert")

// ─── HELPERS ──────────────────────────────────────────────────────────────────

f_sz() =>
    switch labelSize
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.large

f_line(price, col, isCurrent) =>
    line.new(bar_index, price, bar_index + 1, price,
         color=col, width=lineWidth, style=line.style_dashed,
         extend=isCurrent ? extend.both : extend.left)

f_label(price, col, txt) =>
    if showLabels
        label.new(bar_index + 2, price, txt,
             color=color.new(col, 80), textcolor=col,
             style=label.style_label_left, size=f_sz(),
             xloc=xloc.bar_index, yloc=yloc.price)

f_close(a, b) =>
    math.abs(a - b) / b * 100 <= mergeThresh

// ─── DATA ─────────────────────────────────────────────────────────────────────

[cur1H_h, cur1H_l, cur1H_mid, prv1H_h, prv1H_l, prv1H_mid] =
     request.security("", "60",
     [high[0], low[0], (high[0]+low[0])/2, high[1], low[1], (high[1]+low[1])/2],
     lookahead=barmerge.lookahead_on)

[cur4H_h, cur4H_l, cur4H_mid, prv4H_h, prv4H_l, prv4H_mid] =
     request.security("", "240",
     [high[0], low[0], (high[0]+low[0])/2, high[1], low[1], (high[1]+low[1])/2],
     lookahead=barmerge.lookahead_on)

[curD_h, curD_l, curD_mid, prvD_h, prvD_l, prvD_mid] =
     request.security("", "D",
     [high[0], low[0], (high[0]+low[0])/2, high[1], low[1], (high[1]+low[1])/2],
     lookahead=barmerge.lookahead_on)

// ─── PERSISTENT ARRAYS (declared outside barstate.islast) ─────────────────────

var float[] lvl_prices  = array.new_float(0)
var color[] lvl_colors  = array.new_color(0)
var string[] lvl_labels = array.new_string(0)
var bool[]  lvl_current = array.new_bool(0)

// ─── DRAW ON LAST BAR ─────────────────────────────────────────────────────────

if barstate.islast

    // Rebuild level arrays fresh each time
    array.clear(lvl_prices)
    array.clear(lvl_colors)
    array.clear(lvl_labels)
    array.clear(lvl_current)

    if show1H
        array.push(lvl_prices, cur1H_h),  array.push(lvl_colors, col1H), array.push(lvl_labels, "1H H"),       array.push(lvl_current, true)
        array.push(lvl_prices, cur1H_mid), array.push(lvl_colors, col1H), array.push(lvl_labels, "1H Mid"),     array.push(lvl_current, true)
        array.push(lvl_prices, cur1H_l),  array.push(lvl_colors, col1H), array.push(lvl_labels, "1H L"),       array.push(lvl_current, true)
        array.push(lvl_prices, prv1H_h),  array.push(lvl_colors, col1H), array.push(lvl_labels, "Prv 1H H"),   array.push(lvl_current, false)
        array.push(lvl_prices, prv1H_mid), array.push(lvl_colors, col1H), array.push(lvl_labels, "Prv 1H Mid"), array.push(lvl_current, false)
        array.push(lvl_prices, prv1H_l),  array.push(lvl_colors, col1H), array.push(lvl_labels, "Prv 1H L"),   array.push(lvl_current, false)

    if show4H
        array.push(lvl_prices, cur4H_h),  array.push(lvl_colors, col4H), array.push(lvl_labels, "4H H"),       array.push(lvl_current, true)
        array.push(lvl_prices, cur4H_mid), array.push(lvl_colors, col4H), array.push(lvl_labels, "4H Mid"),     array.push(lvl_current, true)
        array.push(lvl_prices, cur4H_l),  array.push(lvl_colors, col4H), array.push(lvl_labels, "4H L"),       array.push(lvl_current, true)
        array.push(lvl_prices, prv4H_h),  array.push(lvl_colors, col4H), array.push(lvl_labels, "Prv 4H H"),   array.push(lvl_current, false)
        array.push(lvl_prices, prv4H_mid), array.push(lvl_colors, col4H), array.push(lvl_labels, "Prv 4H Mid"), array.push(lvl_current, false)
        array.push(lvl_prices, prv4H_l),  array.push(lvl_colors, col4H), array.push(lvl_labels, "Prv 4H L"),   array.push(lvl_current, false)

    if showD
        array.push(lvl_prices, curD_h),   array.push(lvl_colors, colD),  array.push(lvl_labels, "D H"),        array.push(lvl_current, true)
        array.push(lvl_prices, curD_mid),  array.push(lvl_colors, colD),  array.push(lvl_labels, "D Mid"),      array.push(lvl_current, true)
        array.push(lvl_prices, curD_l),   array.push(lvl_colors, colD),  array.push(lvl_labels, "D L"),        array.push(lvl_current, true)
        array.push(lvl_prices, prvD_h),   array.push(lvl_colors, colD),  array.push(lvl_labels, "Prv D H"),    array.push(lvl_current, false)
        array.push(lvl_prices, prvD_mid),  array.push(lvl_colors, colD),  array.push(lvl_labels, "Prv D Mid"),  array.push(lvl_current, false)
        array.push(lvl_prices, prvD_l),   array.push(lvl_colors, colD),  array.push(lvl_labels, "Prv D L"),    array.push(lvl_current, false)

    int n = array.size(lvl_prices)

    // Build used array fresh with exactly n elements
    bool[] used = array.new_bool(n, false)

    for i = 0 to n - 1
        if not array.get(used, i)
            float p_i   = array.get(lvl_prices,  i)
            color c_i   = array.get(lvl_colors,  i)
            string lbl  = array.get(lvl_labels,  i)
            bool cur    = array.get(lvl_current, i)

            float sumP  = p_i
            int   cnt   = 1

            if i < n - 1
                for j = i + 1 to n - 1
                    if not array.get(used, j)
                        float p_j = array.get(lvl_prices, j)
                        if f_close(p_i, p_j)
                            array.set(used, j, true)
                            sumP += p_j
                            cnt  += 1
                            lbl  := lbl + " | " + array.get(lvl_labels, j)
                            if array.get(lvl_current, j)
                                cur := true

            float avgP = sumP / cnt
            f_line(avgP, c_i, cur)
            f_label(avgP, c_i, lbl)

// ─── ALERTS ───────────────────────────────────────────────────────────────────

f_near(lvl) =>
    math.abs(close - lvl) / lvl * 100 <= alertBuffer

near1H_h      = show1H and f_near(cur1H_h)
near1H_mid    = show1H and f_near(cur1H_mid)
near1H_l      = show1H and f_near(cur1H_l)
nearPrv1H_h   = show1H and f_near(prv1H_h)
nearPrv1H_mid = show1H and f_near(prv1H_mid)
nearPrv1H_l   = show1H and f_near(prv1H_l)

near4H_h      = show4H and f_near(cur4H_h)
near4H_mid    = show4H and f_near(cur4H_mid)
near4H_l      = show4H and f_near(cur4H_l)
nearPrv4H_h   = show4H and f_near(prv4H_h)
nearPrv4H_mid = show4H and f_near(prv4H_mid)
nearPrv4H_l   = show4H and f_near(prv4H_l)

nearD_h       = showD and f_near(curD_h)
nearD_mid     = showD and f_near(curD_mid)
nearD_l       = showD and f_near(curD_l)
nearPrvD_h    = showD and f_near(prvD_h)
nearPrvD_mid  = showD and f_near(prvD_mid)
nearPrvD_l    = showD and f_near(prvD_l)

anyLevel = near1H_h or near1H_mid or near1H_l or
           nearPrv1H_h or nearPrv1H_mid or nearPrv1H_l or
           near4H_h or near4H_mid or near4H_l or
           nearPrv4H_h or nearPrv4H_mid or nearPrv4H_l or
           nearD_h or nearD_mid or nearD_l or
           nearPrvD_h or nearPrvD_mid or nearPrvD_l

alertcondition(near1H_h,      title="1H High",         message="Price near 1H High")
alertcondition(near1H_mid,    title="1H Mid",           message="Price near 1H Mid")
alertcondition(near1H_l,      title="1H Low",           message="Price near 1H Low")
alertcondition(nearPrv1H_h,   title="Prev 1H High",     message="Price near Previous 1H High")
alertcondition(nearPrv1H_mid, title="Prev 1H Mid",      message="Price near Previous 1H Mid")
alertcondition(nearPrv1H_l,   title="Prev 1H Low",      message="Price near Previous 1H Low")

alertcondition(near4H_h,      title="4H High",          message="Price near 4H High")
alertcondition(near4H_mid,    title="4H Mid",            message="Price near 4H Mid")
alertcondition(near4H_l,      title="4H Low",            message="Price near 4H Low")
alertcondition(nearPrv4H_h,   title="Prev 4H High",      message="Price near Previous 4H High")
alertcondition(nearPrv4H_mid, title="Prev 4H Mid",       message="Price near Previous 4H Mid")
alertcondition(nearPrv4H_l,   title="Prev 4H Low",       message="Price near Previous 4H Low")

alertcondition(nearD_h,       title="Daily High",        message="Price near Daily High")
alertcondition(nearD_mid,     title="Daily Mid",         message="Price near Daily Mid")
alertcondition(nearD_l,       title="Daily Low",         message="Price near Daily Low")
alertcondition(nearPrvD_h,    title="Prev Daily High",   message="Price near Previous Daily High")
alertcondition(nearPrvD_mid,  title="Prev Daily Mid",    message="Price near Previous Daily Mid")
alertcondition(nearPrvD_l,    title="Prev Daily Low",    message="Price near Previous Daily Low")

alertcondition(anyLevel,      title="Any HTF Level",     message="Price near an HTF Level")
````
