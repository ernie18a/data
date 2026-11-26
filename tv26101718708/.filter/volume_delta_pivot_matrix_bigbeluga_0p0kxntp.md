# Volume Delta Pivot Matrix [BigBeluga]

- url: https://www.tradingview.com/script/0p0kXntP-Volume-Delta-Pivot-Matrix-BigBeluga/
- type: indicator
- pine_id: PUB;db818e46648c4386ae5592ccd5fccf64
- version: 3.0

## Description

[b]🔵 OVERVIEW[/b]
[quote][b]Volume Delta Pivot Matrix [BigBeluga][/b] is an indicator that maps pivot highs and lows together with the volume delta accumulated around them, then plots each level as a color-coded support or resistance line. 

It solves the problem of flat, unweighted pivot lines by filtering out pivots backed by weak volume delta, so only levels with meaningful buying or selling pressure stay on the chart.[/quote]


[b]🔵 HOW IT WORKS[/b]
[quote]The indicator runs a pivot detection and volume-delta scoring pipeline, then renders the surviving levels visually:

[b]1 — Pivot Detection & Delta Collection[/b]
[list]
[*] [b]Swing Lookback:[/b] Uses [i]Pivot Swing Length[/i] bars on both sides to detect pivot highs and pivot lows.
[*] [b]Volume Delta Calculation:[/b] Sums volume across the pivot window, adding volume on up-closes and subtracting it on down-closes to produce a net delta value for each pivot.
[pine]
if not na(ph)
    float wdlta = 0.0
    for i = 0 to (lbars + rbars)
        wdlta += (close[i] >= open[i] ? volume[i] : -volume[i])
[/pine]
[image]https://www.tradingview.com/x/FywPzJx9/[/image]
[/list]

[b]2 — Breakout & Level Management[/b]
[list]
[*] [b]Breakout Removal:[/b] A support level is removed when price trades at or below it, and a resistance level is removed when price trades at or above it.
[*] [b]Capacity Cap:[/b] Only the most recent [i]Max Active Levels to Plot[/i] levels are kept, with older ones dropped automatically.
[image]https://www.tradingview.com/x/s2xjjQKA/[/image]
[*] [b]Delta Filter:[/b] Levels whose absolute delta falls below [i]Minimum Delta % Filter[/i] relative to the strongest level are permanently discarded.
[image]https://www.tradingview.com/x/HMr2k2lj/[/image]
[/list]

[b]3 — Visual Encoding[/b]
[list]
[*] [b]Gradient Circles:[/b] Each level is marked with 1 to 4 circles whose size and gradient color scale with delta strength, from yellow to the bullish or bearish theme color.
[*] [b]Percentage Label:[/b] The largest circle displays the level's delta as a percentage of the strongest active level.
[*] [b]Price Tag:[/b] A left-facing label at the current bar shows the exact level price.
[image]https://www.tradingview.com/x/ydb4xQYF/[/image]
[/list][/quote]


[b]🔵 HOW TO USE[/b]
[quote]Beyond simply marking pivots, the indicator can be applied in several ways:

[list=1]
[*] [b]Identify High-Conviction Levels:[/b] Treat levels with more and larger circles as stronger support or resistance, since they carry greater volume delta.
[*] [b]Filter Noise Automatically:[/b] Raise the [i]Minimum Delta % Filter[/i] to strip out weak pivots and keep only the most significant levels.
[*] [b]Trade Reactions near Levels:[/b] Watch for price approaching a green support or red resistance line and use the displayed price tag for precise entries.
[image]https://www.tradingview.com/x/YQvhRki7/[/image]
[image]https://www.tradingview.com/x/7jugvQi1/[/image]
[*] [b]Confirm Breakouts:[/b] When a level disappears, it signals price has broken through, which can be used as a breakout confirmation.
[*] [b]Customize the Look:[/b] Adjust [i]Line Style[/i] and the bullish/bearish colors to match your chart theme.
[/list][/quote]


[b]🔵 NOTES[/b]
[quote][b]Why this implementation is unique:[/b]
[list]
[*] Combines classic pivot detection with a real-time volume delta weighting system instead of treating all pivots equally.
[*] Uses a dynamic gradient circle system so level strength is readable at a glance without extra panels.
[*] Automatically manages level lifecycle through breakout detection, capacity limits, and delta filtering.
[*] Fully customizable colors, line styles, and filter thresholds to match any chart setup.
[/list][/quote]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © BigBeluga

//@version=6
indicator("Volume Delta Pivot Matrix [BigBeluga]", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000, calc_bars_count = 5000)

// ＩＮＰＵＴＳ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
g_piv    = "Pivot Settings"
lbars    = input.int(5, "Pivot Swing Length", minval=1, group=g_piv)
rbars    = lbars
mxlvl    = input.int(10, "Max Active Levels to Plot", minval=1, maxval=50, group=g_piv)
mdpct    = input.float(20.0, "Minimum Delta % Filter", minval=0.0, maxval=100.0, step=5.0, group=g_piv)
lopt     = input.string("Solid", "Line Style", options=["Solid", "Dotted", "Dashed"], group=g_piv)
lwidth   = input.int(3, "Level Width", group=g_piv)

g_sty    = "Visual Styling"
cbull    = input.color(color.rgb(24, 206, 33), "Bullish Delta / Support Color", group=g_sty)
cbear    = input.color(#FF3D00, "Bearish Delta / Resistance Color", group=g_sty)
// }

// ＣＡＬＣＵＬＡＴＩＯＮＳ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
//  USER DEFINED TYPE 
type Plvl
    float lvl
    float dlta
    bool  supp
    int   bidx
    line  ln

//  PERSISTENT STORAGE ARRAYS 
var parr          = array.new<Plvl>()
var label[] clabs = array.new<label>()
var label[] alabs = array.new<label>()

//  LINE STYLE HELPER 
gstln(string styl) =>
    switch styl
        "Solid"  => line.style_solid
        "Dotted" => line.style_dotted
        "Dashed" => line.style_dashed
        => line.style_dotted

//  DETECT PIVOTS IN REAL-TIME & COLLECT 
float ph = ta.pivothigh(high, lbars, rbars)
float pl = ta.pivotlow(low, lbars, rbars)

int pbidx = bar_index - rbars

if not na(ph)
    float wdlta = 0.0
    for i = 0 to (lbars + rbars)
        // Delta based on close position within the bar's range
        float barRange = high[i] - low[i]
        if barRange > 0
            // Close position ratio: 0 = at low, 1 = at high
            float closeRatio = (close[i] - low[i]) / barRange
            // Weight volume by close position: positive if close in upper half, negative if lower half
            wdlta += volume[i] * (closeRatio * 2 - 1)
        else
            // Fallback when range is zero (e.g., doji with no movement)
            wdlta += (close[i] >= open[i] ? volume[i] : -volume[i])
    array.push(parr, Plvl.new(ph, wdlta, false, pbidx, na))

if not na(pl)
    float wdlta = 0.0
    for i = 0 to (lbars + rbars)
        // Delta based on close position within the bar's range
        float barRange = high[i] - low[i]
        if barRange > 0
            float closeRatio = (close[i] - low[i]) / barRange
            wdlta += volume[i] * (closeRatio * 2 - 1)
        else
            wdlta += (close[i] >= open[i] ? volume[i] : -volume[i])
    array.push(parr, Plvl.new(pl, wdlta, true, pbidx, na))

//  MANAGEMENT: CHECK BREAKOUTS (iterate safely forward, remove from the end)
if array.size(parr) > 0
    for i = array.size(parr) - 1 to 0
        Plvl clvl = array.get(parr, i)

        bool csupp = clvl.supp and close <= clvl.lvl and barstate.isconfirmed
        bool cres  = not clvl.supp and close >= clvl.lvl and barstate.isconfirmed

        if csupp or cres
            if not na(clvl.ln)
                line.delete(clvl.ln)
            array.remove(parr, i)
// }

// ＰＬＯＴ ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――{
if barstate.islast

    //  ENFORCE MAX LEVELS CAPACITY (trim oldest, keep newest mxlvl)
    if array.size(parr) > mxlvl
        int excs = array.size(parr) - mxlvl
        for i = 0 to excs - 1
            Plvl olvl = array.shift(parr)
            if not na(olvl.ln)
                line.delete(olvl.ln)

    // clear previous labels
    if array.size(alabs) > 0
        for i = 0 to array.size(alabs) - 1
            label.delete(array.get(alabs, i))
        array.clear(alabs)

    if array.size(clabs) > 0
        for i = 0 to array.size(clabs) - 1
            label.delete(array.get(clabs, i))
        array.clear(clabs)

    int titem = array.size(parr)
    lsten = gstln(lopt)

    if titem > 0
        // find max delta for percentage scaling
        float mdelt = 0.0001
        for i = 0 to titem - 1
            mdelt := math.max(mdelt, math.abs(array.get(parr, i).dlta))

        // plot only valid levels (pct >= mdpct), newest first, up to mxlvl
        int plotted = 0
        for i = titem - 1 to 0
            if plotted >= mxlvl
                break

            Plvl lvl = array.get(parr, i)
            float rato = math.abs(lvl.dlta) / mdelt
            float pct  = rato * 100.0

            // skip low-delta levels: hide any existing line, do not plot
            if pct < mdpct
                if not na(lvl.ln)
                    line.delete(lvl.ln)
                    lvl.ln := na
                continue

            color mcol = lvl.supp ? cbull : cbear

            if na(lvl.ln)
                lvl.ln := line.new(lvl.bidx, lvl.lvl, bar_index, lvl.lvl, color=color.new(mcol, 40), width=lwidth, style=lsten)
            else
                line.set_xy2(lvl.ln, bar_index, lvl.lvl)
                line.set_color(lvl.ln, color.new(mcol, 40))

            int ncirc = math.min(4, math.max(1, math.ceil(pct / 25.0)))

            for c = ncirc to 1
                string bsize = c == 1 ? size.tiny : c == 2 ? size.small : c == 3 ? size.normal : size.large
                color gcol = lvl.supp ?
                     color.from_gradient(c, 1, 4, color.new(#FFD600, 50), color.new(cbull, 50)) :
                     color.from_gradient(c, 1, 4, color.new(#FFD600, 50), color.new(cbear, 50))

                label clbl = label.new(
                    x             = lvl.bidx,
                    y             = lvl.lvl,
                    xloc          = xloc.bar_index,
                    yloc          = yloc.price,
                    color         = gcol,
                    style         = label.style_circle,
                    size          = bsize,
                    text          = c == ncirc ? str.tostring(pct, format.percent) : "",
                    force_overlay = true, tooltip = "Delta Size"
                 )
                array.push(clabs, clbl)

            label lbl = label.new(
                 x         = bar_index,
                 y         = lvl.lvl,
                 text      = str.tostring(lvl.lvl, "#.##  /  ∆") + str.tostring(lvl.dlta, format.volume),
                 xloc      = xloc.bar_index,
                 yloc      = yloc.price,
                 color     = color.new(mcol, 100),
                 style     = label.style_label_left,
                 textcolor = mcol,
                 size      = size.normal, tooltip = "Price Level / Delta Volume"
             )
            array.push(alabs, lbl)

            label ecirc = label.new(
                x         = bar_index,
                y         = lvl.lvl,
                xloc      = xloc.bar_index,
                yloc      = yloc.price,
                color     = color.new(mcol, 100),
                style     = label.style_label_center,
                size      = size.normal,
                text      = "●",
                textcolor = color.new(mcol, 0)
            )
            array.push(clabs, ecirc)

            plotted += 1
// }
````
