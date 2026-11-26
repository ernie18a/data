# Time and Price by erdensedat

- url: https://www.tradingview.com/script/MYrC5cy4-Time-and-Price-by-erdensedat/
- type: indicator
- pine_id: PUB;8550412df9004c36bea3be423373702d
- version: 1.0

## Description

Time & Price Institutional Toolkit [erdensedat]

Overview
The Time & Price Institutional Toolkit is an advanced framework designed to bridge the concepts of time cycles and price action liquidity. By blending multi-timeframe structural analysis, mathematical models (Fibonacci, Gann, Quarterly), and fair value gaps (FVG), it provides a complete top-down perspective on institutional order flow.

The "Blue Skeleton" & Liquidity Sweeps
At the core of the script is the dynamic "Blue Skeleton" matrix. It draws the calculation period's highest, lowest, and equilibrium points.

Liquidity Sweep Filter: The skeleton essentially maps the "playing field" for the current session.
Time Element: As time passes the 0.5 (midpoint) of the skeleton box—often aligning with the overlap of the London and New York sessions—the indicator is highly sensitive to manipulation sweeps. If the price spikes out of the skeleton boundaries after this midpoint, it frequently marks a "Turtle Soup" manipulation reversal right before a heavy volume trend kicks in.
Key Features:

1. Time & Price Matrix (Skeleton Framework)

Dynamically maps premium/discount zones and equilibrium based on your chosen higher timeframe (e.g., Daily, Weekly).
Multiple mathematical schemas available: Mixed, Fibonacci, Quarterly, and Gann/Harmonic ratios.
Clearly plots Overbought/Oversold extremes.
2. Turtle Soup (TS) Entry Model

Identifies liquidity sweeps below previous period lows (Bullish Sweep) or above previous period highs (Bearish Sweep) that occur in the critical second half of the time window.
Visualized with custom dashed lines and circular markers indicating high-probability reversal zones.
3. Fair Value Gap (FVG) & Breaker Engine

Automatic detection of Fair Value Gaps and Breaker Blocks with overlapping gap filters.
Raid Displays: Shows when an FVG has been raided (swept and closed through), creating dynamic support/resistance lines marked with an 'x'.
Adjustable mitigation thresholds (Close, Wick, or Average).
4. Rejection Blocks

Highlights extreme wicks (where the wick is greater than 50% of the candle range) that signify rejection.
These act as institutional pivot points. Once mitigated, they visually transform into Mitigated Blocks (MB).
5. VWAP (Volume Weighted Average Price)

Built-in, optional VWAP line for intraday mean-reversion and dynamic trend confirmation (Disabled by default, can be toggled in settings).
6. Candle Structure & Reversal Formations

(Optional feature in settings) Highlights 2-bar immediate reversals, 3-bar standard reversals, and continuation structures specifically when they form inside the Premium/Discount extremes.
Alert System
The script includes a ready-to-use alert system focused on the highest probability setups:

Turtle Soup Buy: Triggers when a bullish liquidity sweep is detected, dropping below the HTF low and rejecting back inside during the optimal time window.
Turtle Soup Sell: Triggers when a bearish liquidity sweep is detected, pushing above the HTF high and rejecting.
Note: To set these up, create an alert on TradingView, select this indicator, and choose "Any alert() function call".
How to Use:

Let the skeleton form during the early parts of the session (Asia/London).
Wait for the time to cross the 0.5 midline of the box.
Look for the price to sweep the outer boundaries of the skeleton (Turtle Soup trigger).
Enter on the rejection, targeting the 0 (Balance) line or the opposing Premium/Discount extreme, using FVGs and VWAP as dynamic targets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © erdensedat

//@version=6
indicator("Time and Price by erdensedat", shorttitle="T&P erdensedat", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_polylines_count=100)

// --- WATERMARK ---
var table watermark = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(watermark, 0, 0, "erdensedat", text_color=color.new(color.gray, 60), text_size=size.large)

// =====================================================================
// GLOBAL VARIABLES
// =====================================================================
var int lastSweepTopBar = na
var int lastSweepBottomBar = na

// =====================================================================
// 1. PPTS SETTINGS
// =====================================================================
htfInput     = input.timeframe("D", "Calculation Period", group="Time Settings")
schemaType   = input.string("Gann/Harmonic", "Schema Type", options=["Mixed (Default)", "Fibonacci", "Quarterly", "Gann/Harmonic"], group="Mathematical Model")

zoneMode       = input.string("Extremes Only", "Colored Zones Display", options=["All Zones", "Extremes Only", "None"], group="Visual Settings")
showLevels     = input.bool(true, "Show Fibo Levels & Grids", group="Visual Settings")
drawLevels     = showLevels and zoneMode != "None"
skeletonColor  = input.color(color.blue, "Skeleton Color", group="Visual Settings")
skeletonWidth  = input.int(1, "Skeleton Line Width", minval=1, maxval=5, group="Visual Settings")
skeletonStyleStr = input.string("Dashed", "Skeleton Line Style", options=["Solid", "Dashed", "Dotted"], group="Visual Settings")

skeletonLblSzStr = input.string("Normal", "Skeleton Label Size", options=["Tiny", "Small", "Normal", "Large"], group="Visual Settings")
skeletonLblSz = skeletonLblSzStr == "Tiny" ? size.tiny : skeletonLblSzStr == "Small" ? size.small : skeletonLblSzStr == "Normal" ? size.normal : size.large

skeletonNum    = input.int(1, "Show Last N Skeletons", minval=1, maxval=50, group="Visual Settings")

skeletonLineStyle = switch skeletonStyleStr
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    => line.style_dashed

// =====================================================================
// 2. ENTRY MODELS SETTINGS
// =====================================================================
grpModels = "Entry Model"
useTSModel   = input.bool(true, "Use Turtle Soup Model", group=grpModels)

grpTS = "Turtle Soup Settings"
tsBullColor = input.color(#089981, "TS Bull Color", group=grpTS)
tsBearColor = input.color(#f23645, "TS Bear Color", group=grpTS)

// --- VWAP SETTINGS ---
grpVWAP = "VWAP Settings"
showVWAP = input.bool(false, "Show VWAP", group=grpVWAP)
vwapColor = input.color(color.new(#ff9800, 0), "VWAP Color", group=grpVWAP)

// --- FVG SETTINGS ---
fvg_enable   = input.bool(true, "", inline="1", group="FAIR VALUE GAP", tooltip="Display fair value gap")
what_fvg     = input.string("FVG", "", inline="1", group="FAIR VALUE GAP", tooltip="Display fair value gap", options=["FVG", "Breakers"])
fvg_num      = input.int(3, "Show Last", inline="1a", group="FAIR VALUE GAP", tooltip="Number of fvg to show", minval=0)
fvg_upcss    = input.color(color.new(#089981, 80), "", inline="1", group="FAIR VALUE GAP")
fvg_dncss    = input.color(color.new(#f23645, 80), "", inline="1", group="FAIR VALUE GAP")
fvg_src      = input.string("Close", "Mitigation", inline="3", group="FAIR VALUE GAP", tooltip="[Close] Use the close of the body as trigger\n\n[Wick] Use the extreme point of the body as trigger", options=["Close", "Wick", "Avg"])
fvgthresh    = input.float(0, "Threshold", tooltip="Filter out non significative FVG", group="FAIR VALUE GAP", inline="asd", minval=0, maxval=2, step=0.1)
fvgoverlap   = input.bool(true, "Hide Overlap", tooltip="Hide overlapping FVG", group="FAIR VALUE GAP")
fvgline      = input.bool(true, "Show Mid-Line", group="FAIR VALUE GAP")
fvgextend    = input.bool(false, "Extend FVG", group="FAIR VALUE GAP")

dispraid     = input.bool(true, "Display Raids", inline="raid", group="FAIR VALUE GAP")
raid_num     = input.int(5, "Show Last Raids", inline="raid_opts", group="FAIR VALUE GAP", minval=0)
raid_width   = input.int(2, "Raid Line Width", inline="raid_opts", group="FAIR VALUE GAP", minval=1)
raid_lbl_sz_str = input.string("Small", "Raid Label Size", options=["Tiny", "Small", "Normal", "Large"], group="FAIR VALUE GAP")
raid_lbl_size = raid_lbl_sz_str == "Tiny" ? size.tiny : raid_lbl_sz_str == "Small" ? size.small : raid_lbl_sz_str == "Normal" ? size.normal : size.large

// --- REJECTION BLOCK SETTINGS (Imported from SICK MODE) ---
grpRB = "Rejection Block"
rb_enable    = input.bool(true, "Enable Rejection Blocks", group=grpRB)
rb_pivot     = input.int(5, "Internal Pivot Length", minval=1, group=grpRB)
rb_num       = input.int(3, "Max Boxes Block", minval=1, maxval=50, group=grpRB)
rb_bull_css  = input.color(color.new(#00BCD4, 80), "Bullish RB Color", group=grpRB)
rb_bear_css  = input.color(color.new(#FF9800, 80), "Bearish RB Color", group=grpRB)
rb_extend    = input.int(1, "Box Extend Right (Bars)", minval=0, maxval=20, group=grpRB)
rb_broken_css= input.color(color.new(color.gray, 80), "Broken BB Color", group=grpRB)

// --- Hardcoded Colors (PPTS) ---
COLOR_PREMIUM  = #f23645 // Top (Red)
COLOR_DISCOUNT = #089981 // Bottom (Green)
COLOR_BALANCE  = color.gray

// --- Level Ratios (PPTS) ---
getLevels(type) =>
    switch type
        "Mixed (Default)"   => array.from(0.25, 0.382, 0.5, 0.618, 0.75, 1.0)
        "Fibonacci"         => array.from(0.236, 0.382, 0.5, 0.618, 0.786, 1.0)
        "Quarterly"         => array.from(0.25, 0.5, 0.75, 1.0)
        => array.from(0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1.0)

levels = getLevels(schemaType)

f_opaque(color c) => color.new(c, 0)

// =====================================================================
// VWAP LOGIC
// =====================================================================
var float vwapValue = na
if showVWAP
    vwapValue := ta.vwap(hlc3)
plot(showVWAP ? vwapValue : na, title="VWAP", color=vwapColor, linewidth=2)

// =====================================================================
// REJECTION BLOCK LOGIC (Imported from SICK MODE)
// =====================================================================

float ph = ta.pivothigh(high, rb_pivot, rb_pivot)
float pl = ta.pivotlow(low, rb_pivot, rb_pivot)

float bodyTop = math.max(open, close)
float bodyBot = math.min(open, close)
float upperWick = high - bodyTop
float lowerWick = bodyBot - low
float candleRange = high - low

bool isBullRB = not na(pl) and (lowerWick > candleRange * 0.5)
bool isBearRB = not na(ph) and (upperWick > candleRange * 0.5)

type Block
    box bx
    label lbl
    bool isBull
    bool isMitigated
    string bType
    bool retested

var Block[] blockArray = array.new<Block>()

if rb_enable
    if isBullRB
        array.push(blockArray, Block.new(box.new(bar_index[rb_pivot], bodyBot[rb_pivot], bar_index, low[rb_pivot], bgcolor=rb_bull_css, border_color=color.new(rb_bull_css, 50)), label.new(bar_index, (bodyBot[rb_pivot] + low[rb_pivot]) / 2, "RB", color=color.new(color.white, 100), textcolor=f_opaque(rb_bull_css), style=label.style_label_left, size=skeletonLblSz), true, false, "RB", false))
    if isBearRB
        array.push(blockArray, Block.new(box.new(bar_index[rb_pivot], high[rb_pivot], bar_index, bodyTop[rb_pivot], bgcolor=rb_bear_css, border_color=color.new(rb_bear_css, 50)), label.new(bar_index, (high[rb_pivot] + bodyTop[rb_pivot]) / 2, "RB", color=color.new(color.white, 100), textcolor=f_opaque(rb_bear_css), style=label.style_label_left, size=skeletonLblSz), false, false, "RB", false))

if rb_enable
    if array.size(blockArray) > rb_num * 2
        removed = array.shift(blockArray)
        box.delete(removed.bx), label.delete(removed.lbl)
        
    for i = 0 to (array.size(blockArray) == 0 ? na : array.size(blockArray) - 1)
        if array.size(blockArray) > 0
            blk = array.get(blockArray, i)
            if not blk.isMitigated
                top = box.get_top(blk.bx)
                bot = box.get_bottom(blk.bx)
                
                if not blk.retested and bar_index > box.get_left(blk.bx)
                    if blk.isBull and low <= top and high >= bot
                        blk.retested := true
                    if not blk.isBull and high >= bot and low <= top
                        blk.retested := true
                
                isMitigated = (blk.isBull and close < bot) or (not blk.isBull and close > top)
                if isMitigated
                    blk.isMitigated := true
                    if blk.bType == "RB"
                        label.set_text(blk.lbl, "MB")
                    box.set_bgcolor(blk.bx, rb_broken_css)
                    box.set_border_color(blk.bx, color.new(rb_broken_css, 50))
                    label.set_textcolor(blk.lbl, f_opaque(rb_broken_css))
                else
                    box.set_right(blk.bx, bar_index + rb_extend)
                    label.set_x(blk.lbl, bar_index + rb_extend + 1)


// =====================================================================
// 3. FVG ENGINE TYPES & SETUP
// =====================================================================
type FVG
    float top     = na
    float btm     = na
    int   loc     = bar_index
    bool  isbb    = false
    int   bbloc   = na
    bool  israid  = false
    float raidy   = na
    int   raidloc = na
    int   raidx2  = na
    bool  active  = false
    color raidcs  = na

type store
    line    [] ln
    label   [] lb
    box     [] bx
    linefill[] lf

var store bin = store.new(array.new<line>(), array.new<label>(), array.new<box>(), array.new<linefill>())

if barstate.islast
    for obj in bin.ln
        obj.delete()
    for obj in bin.lb
        obj.delete()
    for obj in bin.bx
        obj.delete()
    
    bin.ln.clear()
    bin.lb.clear()
    bin.bx.clear()

ghl() => [high[2], low[2], close[1], open[1], close, open, high, low, high[1], low[1], ta.atr(200)]

overlapFVG(FVG[] blFVG, FVG[] brFVG) =>
    if blFVG.size() > 1
        for i = blFVG.size() - 1 to 1
            stuff = blFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)

    if brFVG.size() > 1
        for i = brFVG.size() - 1 to 1
            stuff = brFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

    if blFVG.size() > 0 and brFVG.size() > 0
        for i = blFVG.size() - 1 to 0
            stuff = blFVG.get(i)
            current = brFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => blFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => blFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => blFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => blFVG.remove(i)

    if blFVG.size() > 0 and brFVG.size() > 0
        for i = brFVG.size() - 1 to 0
            stuff = brFVG.get(i)
            current = blFVG.get(0)
            switch
                stuff.btm > current.btm and stuff.btm < current.top => brFVG.remove(i)
                stuff.top < current.top and stuff.btm > current.btm => brFVG.remove(i)
                stuff.top > current.top and stuff.btm < current.btm => brFVG.remove(i)
                stuff.top < current.top and stuff.top > current.btm => brFVG.remove(i)

method dispFVGBox(FVG fvg, int i, bool bull) =>
    ext = fvgextend ? extend.right : extend.none
    if not fvg.isbb
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = time, border_color = color.new(bull ? fvg_upcss : fvg_dncss, 10), border_style = line.style_solid, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), xloc = xloc.bar_time, color = color.new(bull ? fvg_upcss : fvg_dncss, 0), style = line.style_dashed, extend = ext))

    else
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = fvg.bbloc, border_color = color.new(bull ? fvg_upcss : fvg_dncss, 10), border_style = line.style_solid, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time))
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.bbloc, right = time, border_color = bull ? fvg_dncss : fvg_upcss, border_style = line.style_solid, bgcolor = bull ? fvg_dncss : fvg_upcss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = fvg.bbloc, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_upcss : fvg_dncss, 0), xloc = xloc.bar_time, style = line.style_dashed))
            bin.ln.unshift(line.new(x1 = fvg.bbloc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_dncss : fvg_upcss, 0), xloc = xloc.bar_time, extend = ext, style = line.style_dashed))

method dispFVGRaid(FVG fvg, bool bull) =>
    if dispraid and fvg.israid
        bin.ln.unshift(line.new(x1 = fvg.raidloc, x2 = fvg.raidx2, y1 = fvg.raidy, y2 = fvg.raidy, xloc = xloc.bar_time, color = fvg.raidcs, width = raid_width))
        bin.lb.unshift(label.new(x = int(math.avg(fvg.raidloc, fvg.raidx2)), y = fvg.raidy, text = "x", xloc = xloc.bar_time, textcolor = fvg.raidcs, style = bull ? label.style_label_up : label.style_label_down, size = raid_lbl_size, color = #ffffff00))

var FVG[] blFVG_global = array.new<FVG>()
var FVG[] brFVG_global = array.new<FVG>()

dFVG() =>
    [h2, l2, c1, o1, c, o, h, l, h1, l1, fvatr] = ghl()
    bool upfvg = false
    bool dnfvg = false
    float blth = l1 + (fvatr[1] * fvgthresh)
    float brth = h1 - (fvatr[1] * fvgthresh)

    cc = timeframe.change()

    switch
        what_fvg == "FVG" or what_fvg == "Breakers" =>
            if l > h2 and cc and c1 > blth
                upfvg := true
                
            if l2 > h and cc and c1 < brth
                dnfvg := true

    if upfvg[1]
        if blFVG_global.size() > 0
            fvg = blFVG_global.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        blFVG_global.unshift(FVG.new(top = l[1], btm = h2[1], loc = time[3]))

    if dnfvg[1]
        if brFVG_global.size() > 0
            fvg = brFVG_global.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        brFVG_global.unshift(FVG.new(top = l2[1], btm = h[1], loc = time[3]))

    if blFVG_global.size() > 0
        for [i, fvg] in blFVG_global
            if not fvg.isbb
                if fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        blFVG_global.remove(i)
            else
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    blFVG_global.remove(i)
                    
    if brFVG_global.size() > 0
        for [i, fvg] in brFVG_global
            if not fvg.isbb
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false)
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        brFVG_global.remove(i)
            else
                if (fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    brFVG_global.remove(i)
                    
    if fvgoverlap
        overlapFVG(blFVG_global, brFVG_global)

    if dispraid
        for [i, fvg] in blFVG_global
            if not fvg.israid and not fvg.isbb
                if low < fvg.top and close > fvg.top
                    fvg.israid  := true
                    fvg.raidloc := time
                    fvg.raidx2  := time
                    fvg.raidy   := low
                    fvg.raidcs  := chart.fg_color
            else
                if low <= fvg.raidy and fvg.active == false and not fvg.isbb
                    fvg.active := true
                    fvg.raidx2 := time
                else
                    if fvg.active == false and not fvg.isbb
                        fvg.raidx2 := time

        for [i, fvg] in brFVG_global
            if not fvg.israid and not fvg.isbb
                if high > fvg.btm and close < fvg.btm and not fvg.isbb
                    fvg.israid  := true
                    fvg.raidloc := time
                    fvg.raidy   := high
                    fvg.raidx2  := time
                    fvg.raidcs  := chart.fg_color
            else
                if high >= fvg.raidy and fvg.active == false and not fvg.isbb
                    fvg.active := true
                    fvg.raidx2 := time
                else
                    if fvg.active == false and not fvg.isbb
                        fvg.raidx2 := time

    if barstate.islast
        // Draw FVG Boxes
        if blFVG_global.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, blFVG_global.size() - 1)
                fvg = blFVG_global.get(i)
                dispFVGBox(fvg, i, true)

        if brFVG_global.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, brFVG_global.size() - 1)
                fvg = brFVG_global.get(i)
                dispFVGBox(fvg, i, false)

        // Draw Raids independently based on raid_num
        int drawn_bull_raids = 0
        if blFVG_global.size() > 0 and raid_num > 0
            for i = 0 to blFVG_global.size() - 1
                fvg = blFVG_global.get(i)
                if fvg.israid
                    dispFVGRaid(fvg, true)
                    drawn_bull_raids += 1
                    if drawn_bull_raids >= raid_num
                        break

        int drawn_bear_raids = 0
        if brFVG_global.size() > 0 and raid_num > 0
            for i = 0 to brFVG_global.size() - 1
                fvg = brFVG_global.get(i)
                if fvg.israid
                    dispFVGRaid(fvg, false)
                    drawn_bear_raids += 1
                    if drawn_bear_raids >= raid_num
                        break

// =====================================================================
// 4. PPTS DATA FETCHING & LOGIC
// =====================================================================
[htfHigh, htfLow, htfClose] = request.security(syminfo.tickerid, htfInput, [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

pivotVal = (htfHigh + htfLow + htfClose) / 3
dRange   = htfHigh - htfLow

type Skeleton
    int startBar
    int endBar
    float highVal
    float lowVal
    float pivotVal
    float dRange
    line[] hLines
    line[] vLines
    line[] boxLines
    linefill[] fills
    label[] labels

var Skeleton[] skeletons = array.new<Skeleton>()

isNewPeriod = ta.change(time(htfInput)) != 0

bodyMax = math.max(open, close)
bodyMin = math.min(open, close)

var int currentStartBar = na
var float currentHTFHigh = na
var float currentHTFLow  = na

if isNewPeriod
    if not na(currentStartBar)
        // Save previous skeleton parameters for historical rendering if needed
        pass = 1
        
    currentStartBar := bar_index
    currentHTFHigh := bodyMax
    currentHTFLow  := bodyMin
else
    if bodyMax > currentHTFHigh
        currentHTFHigh := bodyMax
    if bodyMin < currentHTFLow
        currentHTFLow := bodyMin

var int barsInPeriod = 10 
if isNewPeriod and not na(currentStartBar[1])
    barsInPeriod := math.max(1, bar_index - currentStartBar[1])

if isNewPeriod
    // Add new skeleton
    skeletons.unshift(Skeleton.new(bar_index, bar_index + barsInPeriod, currentHTFHigh, currentHTFLow, pivotVal, dRange, array.new_line(), array.new_line(), array.new_line(), array.new_linefill(), array.new_label()))
    if skeletons.size() > skeletonNum
        skelToDel = skeletons.pop()
        for l in skelToDel.hLines
            line.delete(l)
        for l in skelToDel.vLines
            line.delete(l)
        for l in skelToDel.boxLines
            line.delete(l)
        for f in skelToDel.fills
            linefill.delete(f)
        for lbl in skelToDel.labels
            label.delete(lbl)

// Update current active skeleton (index 0)
if skeletons.size() > 0
    curSkel = skeletons.get(0)
    curSkel.highVal := currentHTFHigh
    curSkel.lowVal := currentHTFLow
    curSkel.endBar := curSkel.startBar + barsInPeriod

// Rendering all skeletons
if barstate.islast
    // Clear all visuals first to redraw fresh
    for skel in skeletons
        for l in skel.hLines
            line.delete(l)
        for l in skel.vLines
            line.delete(l)
        for l in skel.boxLines
            line.delete(l)
        for f in skel.fills
            linefill.delete(f)
        for lbl in skel.labels
            label.delete(lbl)
        array.clear(skel.hLines)
        array.clear(skel.vLines)
        array.clear(skel.boxLines)
        array.clear(skel.fills)
        array.clear(skel.labels)

    for s_idx = 0 to skeletons.size() - 1
        skel = skeletons.get(s_idx)
        isCurrentActive = (s_idx == 0)

        s_pivot = line.new(skel.startBar, skel.pivotVal, skel.endBar, skel.pivotVal, color=COLOR_BALANCE, width=2)
        array.push(skel.hLines, s_pivot)
        if isCurrentActive
            array.push(skel.labels, label.new(skel.endBar, skel.pivotVal, "0 BALANCE", color=#00000000, textcolor=COLOR_BALANCE, style=label.style_label_left, size=skeletonLblSz))

        line prevU = s_pivot
        line prevL = s_pivot
        float prevValU = skel.pivotVal
        float prevValL = skel.pivotVal

        for i = 0 to array.size(levels) - 1
            lv = array.get(levels, i)
            valU = skel.pivotVal + skel.dRange * lv
            valL = skel.pivotVal - skel.dRange * lv
            
            isExtreme = (i == array.size(levels) - 1)
            
            color colU = na
            color colL = na
            color lblColU = na
            color lblColL = na
            color fillColU = na
            color fillColL = na
            string lineStyle = line.style_solid

            if zoneMode == "All Zones"
                colU := color.new(COLOR_PREMIUM, 80)
                colL := color.new(COLOR_DISCOUNT, 80)
                lblColU := COLOR_PREMIUM
                lblColL := COLOR_DISCOUNT
                fillColU := color.new(COLOR_PREMIUM, 92 - i * 4)
                fillColL := color.new(COLOR_DISCOUNT, 92 - i * 4)
                lineStyle := line.style_solid
            else if zoneMode == "Extremes Only"
                if isExtreme
                    colU := color.new(COLOR_PREMIUM, 60)
                    colL := color.new(COLOR_DISCOUNT, 60)
                    lblColU := COLOR_PREMIUM
                    lblColL := COLOR_DISCOUNT
                    fillColU := color.new(COLOR_PREMIUM, 80)
                    fillColL := color.new(COLOR_DISCOUNT, 80)
                    lineStyle := line.style_solid
                else
                    colU := color.new(COLOR_PREMIUM, 50)
                    colL := color.new(COLOR_DISCOUNT, 50)
                    lblColU := COLOR_PREMIUM
                    lblColL := COLOR_DISCOUNT
                    fillColU := na
                    fillColL := na
                    lineStyle := line.style_dotted
            else 
                colU := color.new(COLOR_PREMIUM, 50)
                colL := color.new(COLOR_DISCOUNT, 50)
                lblColU := COLOR_PREMIUM
                lblColL := COLOR_DISCOUNT
                fillColU := na
                fillColL := na
                lineStyle := line.style_dotted

            if not drawLevels
                colU := na
                colL := na
                lblColU := na
                lblColL := na
                fillColU := na
                fillColL := na

            lU = line.new(skel.startBar, valU, skel.endBar, valU, color=colU, style=lineStyle)
            lL = line.new(skel.startBar, valL, skel.endBar, valL, color=colL, style=lineStyle)
            array.push(skel.hLines, lU)
            array.push(skel.hLines, lL)
            
            if drawLevels and isCurrentActive
                string txtU = isExtreme ? str.tostring(lv) + " OVERBOUGHT" : str.tostring(lv)
                string txtL = isExtreme ? str.tostring(lv) + " OVERSOLD"   : str.tostring(lv)
                // Position labels exactly at the end of the line, to the right. 
                array.push(skel.labels, label.new(skel.endBar, valU, txtU, color=#00000000, textcolor=lblColU, style=label.style_label_left, size=skeletonLblSz))
                array.push(skel.labels, label.new(skel.endBar, valL, txtL, color=#00000000, textcolor=lblColL, style=label.style_label_left, size=skeletonLblSz))
            
            if not na(fillColU) and drawLevels
                array.push(skel.fills, linefill.new(prevU, lU, fillColU))
            if not na(fillColL) and drawLevels
                array.push(skel.fills, linefill.new(prevL, lL, fillColL))
            
            prevU := lU, prevL := lL
            prevValU := valU, prevValL := valL

        lTop = line.new(skel.startBar, skel.highVal, skel.endBar, skel.highVal, color=skeletonColor, width=skeletonWidth, style=skeletonLineStyle)
        lBot = line.new(skel.startBar, skel.lowVal, skel.endBar, skel.lowVal, color=skeletonColor, width=skeletonWidth, style=skeletonLineStyle)
        lLeft = line.new(skel.startBar, skel.highVal, skel.startBar, skel.lowVal, color=skeletonColor, width=skeletonWidth, style=skeletonLineStyle)
        lRight = line.new(skel.endBar, skel.highVal, skel.endBar, skel.lowVal, color=skeletonColor, width=skeletonWidth, style=skeletonLineStyle)
        
        array.push(skel.boxLines, lTop)   
        array.push(skel.boxLines, lBot)   
        array.push(skel.boxLines, lLeft)  
        array.push(skel.boxLines, lRight) 

        for i = 0 to array.size(levels) - 1
            lv = array.get(levels, i)
            vPos = skel.startBar + math.round(barsInPeriod * lv)
            
            lVTop = line.new(vPos, skel.highVal, vPos, skel.pivotVal, color=showLevels ? color.new(skeletonColor, 50) : na, width=skeletonWidth, style=line.style_dotted)
            lVBot = line.new(vPos, skel.pivotVal, vPos, skel.lowVal, color=showLevels ? color.new(skeletonColor, 50) : na, width=skeletonWidth, style=line.style_dotted)
            
            array.push(skel.vLines, lVTop)
            array.push(skel.vLines, lVBot)
            
            if showLevels
                array.push(skel.labels, label.new(vPos, skel.highVal, str.tostring(lv), color=#00000000, textcolor=skeletonColor, style=label.style_label_down, size=skeletonLblSz))

// =====================================================================
// 5. TS ENTRY MODELS & FVG EXECUTION
// =====================================================================

if isNewPeriod
    lastSweepTopBar := na
    lastSweepBottomBar := na

bool isBullSweep = false
bool isBearSweep = false

barsSinceStart = bar_index - currentStartBar
timeWindowStart = math.round(barsInPeriod * 0.5)
bool inTimeWindow = (barsSinceStart >= timeWindowStart)

if not isNewPeriod
    isBullSweep := (low < currentHTFLow[1]) and (bodyMin >= currentHTFLow[1]) and inTimeWindow
    isBearSweep := (high > currentHTFHigh[1]) and (bodyMax <= currentHTFHigh[1]) and inTimeWindow

if isBullSweep
    lastSweepBottomBar := bar_index

if isBearSweep
    lastSweepTopBar := bar_index

// --- TS Visuals ---
var line[] tsSweepLines = array.new_line()
if useTSModel and isBullSweep and not na(currentHTFLow)
    l = line.new(currentStartBar, currentHTFLow, bar_index, currentHTFLow, color=tsBullColor, width=1, style=line.style_dashed)
    array.push(tsSweepLines, l)
    if array.size(tsSweepLines) > 5
        line.delete(array.shift(tsSweepLines))

if useTSModel and isBearSweep and not na(currentHTFHigh)
    l = line.new(currentStartBar, currentHTFHigh, bar_index, currentHTFHigh, color=tsBearColor, width=1, style=line.style_dashed)
    array.push(tsSweepLines, l)
    if array.size(tsSweepLines) > 5
        line.delete(array.shift(tsSweepLines))

plotshape(useTSModel and isBullSweep ? low : na, title="TS Bull Circle", style=shape.circle, location=location.absolute, color=tsBullColor, size=size.tiny)
plotshape(useTSModel and isBearSweep ? high : na, title="TS Bear Circle", style=shape.circle, location=location.absolute, color=tsBearColor, size=size.tiny)

// --- FVG EXECUTION ---
if fvg_enable
    dFVG()

// =====================================================================
// 6. CANDLE STRUCTURE ENGINE
// =====================================================================
grpCS = "Candle Structure"
enableCS = input.bool(false, "Enable Candle Structure", group=grpCS)

bool inBullZone = false
bool inBearZone = false

if not na(currentHTFLow[1]) and low <= currentHTFLow[1]
    inBullZone := true

if not na(currentHTFHigh[1]) and high >= currentHTFHigh[1]
    inBearZone := true

// Bullish Reversal (3-bar)
bool c1_bull_rev = close[2] < open[2] and inBullZone[2]
bool c2_bull_rev = low[1] < low[2] and close[1] > low[2]
bool c3_bull_rev = close > open and close > high[1]
bool isBullRev = enableCS and c1_bull_rev and c2_bull_rev and c3_bull_rev

// Bearish Reversal (3-bar)
bool c1_bear_rev = close[2] > open[2] and inBearZone[2]
bool c2_bear_rev = high[1] > high[2] and close[1] < high[2]
bool c3_bear_rev = close < open and close < low[1]
bool isBearRev = enableCS and c1_bear_rev and c2_bear_rev and c3_bear_rev

// Downward Continuation (Red / Bearish Continuation)
bool c1_down_cont = close[1] < open[1] and inBullZone[1]
bool c2_down_cont = close < low[1]
bool isDownCont = enableCS and c1_down_cont and c2_down_cont

// Upward Continuation (Green / Bullish Continuation)
bool c1_up_cont = close[1] > open[1] and inBearZone[1]
bool c2_up_cont = close > high[1]
bool isUpCont = enableCS and c1_up_cont and c2_up_cont

// Immediate Bullish Reversal (2-bar)
bool c1_imm_bull = close[1] < open[1] and inBullZone[1]
bool c2_imm_bull = low >= low[1] and close > open and close > high[1]
bool isImmBull = enableCS and c1_imm_bull and c2_imm_bull

// Immediate Bearish Reversal (2-bar)
bool c1_imm_bear = close[1] > open[1] and inBearZone[1]
bool c2_imm_bear = high <= high[1] and close < open and close < low[1]
bool isImmBear = enableCS and c1_imm_bear and c2_imm_bear

var line[] revLines = array.new_line()

if isBullRev
    label.new(bar_index, low, "Bull", style=label.style_label_up, color=#00000000, textcolor=color.green, size=size.small)
    l = line.new(bar_index[2], low[2], bar_index + 10, low[2], color=color.green, style=line.style_solid, width=1)
    array.push(revLines, l)
    if array.size(revLines) > 50
        line.delete(array.shift(revLines))

if isBearRev
    label.new(bar_index, high, "Bear", style=label.style_label_down, color=#00000000, textcolor=color.red, size=size.small)
    l = line.new(bar_index[2], high[2], bar_index + 10, high[2], color=color.red, style=line.style_solid, width=1)
    array.push(revLines, l)
    if array.size(revLines) > 50
        line.delete(array.shift(revLines))

if isDownCont
    label.new(bar_index, low, "Cont.", style=label.style_label_up, color=#00000000, textcolor=color.red, size=size.small)

if isUpCont
    label.new(bar_index, high, "Cont.", style=label.style_label_down, color=#00000000, textcolor=color.green, size=size.small)

plotshape(isImmBull, title="Immediate Bull", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(isImmBear, title="Immediate Bear", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// --- Alerts ---
if useTSModel and isBullSweep
    alert("Turtle Soup Buy: Sweep detected", alert.freq_once_per_bar_close)
if useTSModel and isBearSweep
    alert("Turtle Soup Sell: Sweep detected", alert.freq_once_per_bar_close)
````
