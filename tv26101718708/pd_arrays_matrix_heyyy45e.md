# PD Arrays Matrix

- url: https://www.tradingview.com/script/heYyY45e-PD-Arrays-Matrix/
- type: indicator
- pine_id: PUB;df60588c919b40b69b0b348c0855a221
- version: 2.0

## Description

This script is arguably the most comprehensive script in this workspace. It acts as an algorithmic footprint scanner, actively mapping the entire spectrum of ICT "Premium/Discount Arrays" on your chart in real-time.

Because charting all these footprint concepts can get incredibly cluttered, it features a built-in memory management system, a Lookback Period optimizer (to only track recent data), and toggle switches for every single array type in the settings menu.

Here is exactly what the script detects, draws, and manages:

1. Fair Value Gaps (FVGs) & Consequent Encroachment (CE)
BISI (Buyside Imbalance Sellside Inefficiency): A Bullish FVG. Drawn as a green box when a massive up-move leaves a 3-candle gap.
SIBI (Sellside Imbalance Buyside Inefficiency): A Bearish FVG. Drawn as a red box during a massive down-move.
CE (Consequent Encroachment): It automatically calculates and draws a dotted midline perfectly through the 50% equilibrium mark of every active FVG, which algos use for precise mitigation.

2. Inversion FVGs (IFVG)
The script actively monitors the life-cycle of every FVG. If a Bullish FVG fails to support price and a candle closes completely below it, the script intelligently flips its polarity.
It turns into a Bearish Resistance zone (colored red/gray) labeled IFVG, extending into the future.

3. Balanced Price Ranges (BPR)
A highly sensitive algorithmic signature. If the script detects that a new Bearish FVG has formed and perfectly overlaps the price range of an older Bullish FVG, it highlights that specific overlapping zone in yellow. This acts as a massive magnet/rejection zone for future price action.

4. Volume Imbalance (VI)
Detects microscopic inefficiencies. If two consecutive candles gap up or down so heavily that their bodies do not overlap at all, but their wicks do touch, the script draws a small purple VI zone between the bodies.

5. Order Blocks (OB)
To filter out low-probability order blocks, the script mathematically enforces the Displacement Rule. It will only flag an institutional down-candle (+OB) or up-candle (-OB) if it immediately precedes a move impulsive enough to leave behind an FVG.

6. Breaker Blocks (+BRK/-BRK) & Mitigation Blocks (MB)
The script monitors the life-cycle of Order Blocks! When an Order Block fails and price breaks aggressively through it, the algorithm checks the previous swing structure:
Did price sweep liquidity (a higher high / lower low) before breaking the OB? If yes, it flips the failed OB into a Breaker Block, turning support into resistance.
Did price fail to sweep liquidity? If yes, it flips it into a Mitigation Block.

7. Rejection Blocks
It scans the chart for unusually long institutional wicks (specifically, wicks that are more than double the size of the candle body and statistically significant relative to the ATR).
When found, it draws a block from the open/close of the candle body out to the extreme tip of the wick, highlighting where institutional accumulation or distribution took place off-screen.

## Source Code

````pine
//@version=6
indicator("PD Arrays Matrix", overlay=true, max_boxes_count=500, max_lines_count=500)

// =====================================================================
// Comprehensive ICT PD Arrays Framework
// Includes: FVGs (BISI/SIBI), Inversions (IFVG), Volume Imbalance (VI),
// Balanced Price Ranges (BPR), Order Blocks (OB), Breakers (+BRK/-BRK),
// Mitigation Blocks (MB), Rejection Blocks, and Consequent Encroachment (CE).
// =====================================================================

// --- Helpers ---
get_size(s) =>
    switch s
        "Auto" => size.auto
        "Tiny" => size.tiny
        "Small" => size.small
        "Normal" => size.normal
        "Large" => size.large
        "Huge" => size.huge
        => size.tiny

get_style(s) =>
    switch s
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

// --- Global Calculation ---
grp_calc = "Calculation Settings"
lookback_bars = input.int(1000, "Historical Lookback (Bars)", minval=100, group=grp_calc, tooltip="Only calculate and draw arrays within this recent window to optimize performance.")

// --- CE (Midline) Settings ---
grp_ce = "FVG CE (Midline)"
use_ce  = input.bool(true, "Show FVG CE (Midline)", group=grp_ce)
col_ce = input.color(color.new(color.gray, 0), "CE Line Color", group=grp_ce)
style_ce_str = input.string("Dotted", "CE Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_ce)
style_ce = get_style(style_ce_str)
width_ce = input.int(1, "CE Line Width", minval=1, maxval=5, group=grp_ce)

// --- BISI Settings ---
grp_bisi = "BISI (Bullish FVG)"
use_bisi = input.bool(true, "Enable BISI", group=grp_bisi)
col_bisi = input.color(color.new(color.green, 85), "Background Color", group=grp_bisi)
bcol_bisi = input.color(color.new(color.white, 100), "Border Color", group=grp_bisi)
bstyle_bisi_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_bisi)
bstyle_bisi = get_style(bstyle_bisi_str)
bwidth_bisi = input.int(1, "Border Width", minval=1, group=grp_bisi)
show_lbl_bisi = input.bool(true, "Show Label", group=grp_bisi)
lsize_bisi_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_bisi)
lsize_bisi = get_size(lsize_bisi_str)
tcol_bisi = input.color(color.new(color.green, 0), "Text Color", group=grp_bisi)

// --- SIBI Settings ---
grp_sibi = "SIBI (Bearish FVG)"
use_sibi = input.bool(true, "Enable SIBI", group=grp_sibi)
col_sibi = input.color(color.new(color.red, 85), "Background Color", group=grp_sibi)
bcol_sibi = input.color(color.new(color.white, 100), "Border Color", group=grp_sibi)
bstyle_sibi_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_sibi)
bstyle_sibi = get_style(bstyle_sibi_str)
bwidth_sibi = input.int(1, "Border Width", minval=1, group=grp_sibi)
show_lbl_sibi = input.bool(true, "Show Label", group=grp_sibi)
lsize_sibi_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_sibi)
lsize_sibi = get_size(lsize_sibi_str)
tcol_sibi = input.color(color.new(color.red, 0), "Text Color", group=grp_sibi)

// --- Bullish Inversion FVG ---
grp_inv_bull = "Bullish Inversion FVG"
use_inv_bull = input.bool(true, "Enable Bullish Inversion FVG", group=grp_inv_bull)
col_inv_bull = input.color(color.new(color.green, 70), "Background Color", group=grp_inv_bull)
bcol_inv_bull = input.color(color.new(color.white, 100), "Border Color", group=grp_inv_bull)
bstyle_inv_bull_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_inv_bull)
bstyle_inv_bull = get_style(bstyle_inv_bull_str)
bwidth_inv_bull = input.int(1, "Border Width", minval=1, group=grp_inv_bull)
show_lbl_inv_bull = input.bool(true, "Show Label", group=grp_inv_bull)
lsize_inv_bull_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_inv_bull)
lsize_inv_bull = get_size(lsize_inv_bull_str)
tcol_inv_bull = input.color(color.new(color.green, 0), "Text Color", group=grp_inv_bull)

// --- Bearish Inversion FVG ---
grp_inv_bear = "Bearish Inversion FVG"
use_inv_bear = input.bool(true, "Enable Bearish Inversion FVG", group=grp_inv_bear)
col_inv_bear = input.color(color.new(color.red, 70), "Background Color", group=grp_inv_bear)
bcol_inv_bear = input.color(color.new(color.white, 100), "Border Color", group=grp_inv_bear)
bstyle_inv_bear_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_inv_bear)
bstyle_inv_bear = get_style(bstyle_inv_bear_str)
bwidth_inv_bear = input.int(1, "Border Width", minval=1, group=grp_inv_bear)
show_lbl_inv_bear = input.bool(true, "Show Label", group=grp_inv_bear)
lsize_inv_bear_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_inv_bear)
lsize_inv_bear = get_size(lsize_inv_bear_str)
tcol_inv_bear = input.color(color.new(color.red, 0), "Text Color", group=grp_inv_bear)

// --- Balanced Price Range (BPR) ---
grp_bpr = "Balanced Price Range (BPR)"
use_bpr = input.bool(true, "Enable Balanced Price Range (BPR)", group=grp_bpr)
col_bpr = input.color(color.new(color.yellow, 60), "Background Color", group=grp_bpr)
bcol_bpr = input.color(color.new(color.white, 100), "Border Color", group=grp_bpr)
bstyle_bpr_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_bpr)
bstyle_bpr = get_style(bstyle_bpr_str)
bwidth_bpr = input.int(1, "Border Width", minval=1, group=grp_bpr)
show_lbl_bpr = input.bool(true, "Show Label", group=grp_bpr)
lsize_bpr_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_bpr)
lsize_bpr = get_size(lsize_bpr_str)
tcol_bpr = input.color(color.new(color.yellow, 0), "Text Color", group=grp_bpr)

// --- Volume Imbalance (VI) ---
grp_vi = "Volume Imbalance (VI)"
use_vi = input.bool(true, "Enable Volume Imbalance (VI)", group=grp_vi)
col_vi = input.color(color.new(color.purple, 70), "Background Color", group=grp_vi)
bcol_vi = input.color(color.new(color.white, 100), "Border Color", group=grp_vi)
bstyle_vi_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_vi)
bstyle_vi = get_style(bstyle_vi_str)
bwidth_vi = input.int(1, "Border Width", minval=1, group=grp_vi)
show_lbl_vi = input.bool(true, "Show Label", group=grp_vi)
lsize_vi_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_vi)
lsize_vi = get_size(lsize_vi_str)
tcol_vi = input.color(color.new(color.purple, 0), "Text Color", group=grp_vi)

// --- +OB (Bullish Order Block) ---
grp_ob_bull = "+OB (Bullish Order Block)"
use_ob_bull = input.bool(true, "Enable +OB (Bullish Order Block)", group=grp_ob_bull)
col_ob_bull = input.color(color.new(color.blue, 80), "Background Color", group=grp_ob_bull)
bcol_ob_bull = input.color(color.new(color.white, 100), "Border Color", group=grp_ob_bull)
bstyle_ob_bull_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_ob_bull)
bstyle_ob_bull = get_style(bstyle_ob_bull_str)
bwidth_ob_bull = input.int(1, "Border Width", minval=1, group=grp_ob_bull)
show_lbl_ob_bull = input.bool(true, "Show Label", group=grp_ob_bull)
lsize_ob_bull_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_ob_bull)
lsize_ob_bull = get_size(lsize_ob_bull_str)
tcol_ob_bull = input.color(color.new(color.blue, 0), "Text Color", group=grp_ob_bull)

// --- -OB (Bearish Order Block) ---
grp_ob_bear = "-OB (Bearish Order Block)"
use_ob_bear = input.bool(true, "Enable -OB (Bearish Order Block)", group=grp_ob_bear)
col_ob_bear = input.color(color.new(color.fuchsia, 80), "Background Color", group=grp_ob_bear)
bcol_ob_bear = input.color(color.new(color.white, 100), "Border Color", group=grp_ob_bear)
bstyle_ob_bear_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_ob_bear)
bstyle_ob_bear = get_style(bstyle_ob_bear_str)
bwidth_ob_bear = input.int(1, "Border Width", minval=1, group=grp_ob_bear)
show_lbl_ob_bear = input.bool(true, "Show Label", group=grp_ob_bear)
lsize_ob_bear_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_ob_bear)
lsize_ob_bear = get_size(lsize_ob_bear_str)
tcol_ob_bear = input.color(color.new(color.fuchsia, 0), "Text Color", group=grp_ob_bear)

// --- +Breaker / +MB ---
grp_brk_bull = "+Breaker / +MB"
use_brk_bull = input.bool(true, "Enable +Breaker / +MB", group=grp_brk_bull)
col_brk_bull = input.color(color.new(color.teal, 70), "Background Color", group=grp_brk_bull)
bcol_brk_bull = input.color(color.new(color.white, 100), "Border Color", group=grp_brk_bull)
bstyle_brk_bull_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_brk_bull)
bstyle_brk_bull = get_style(bstyle_brk_bull_str)
bwidth_brk_bull = input.int(1, "Border Width", minval=1, group=grp_brk_bull)
show_lbl_brk_bull = input.bool(true, "Show Label", group=grp_brk_bull)
lsize_brk_bull_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_brk_bull)
lsize_brk_bull = get_size(lsize_brk_bull_str)
tcol_brk_bull = input.color(color.new(color.teal, 0), "Text Color", group=grp_brk_bull)

// --- -Breaker / -MB ---
grp_brk_bear = "-Breaker / -MB"
use_brk_bear = input.bool(true, "Enable -Breaker / -MB", group=grp_brk_bear)
col_brk_bear = input.color(color.new(color.maroon, 70), "Background Color", group=grp_brk_bear)
bcol_brk_bear = input.color(color.new(color.white, 100), "Border Color", group=grp_brk_bear)
bstyle_brk_bear_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_brk_bear)
bstyle_brk_bear = get_style(bstyle_brk_bear_str)
bwidth_brk_bear = input.int(1, "Border Width", minval=1, group=grp_brk_bear)
show_lbl_brk_bear = input.bool(true, "Show Label", group=grp_brk_bear)
lsize_brk_bear_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_brk_bear)
lsize_brk_bear = get_size(lsize_brk_bear_str)
tcol_brk_bear = input.color(color.new(color.maroon, 0), "Text Color", group=grp_brk_bear)

// --- Rejection Block ---
grp_rej = "Rejection Block"
use_rej = input.bool(true, "Enable Rejection Block", group=grp_rej)
col_rej = input.color(color.new(color.gray, 80), "Background Color", group=grp_rej)
bcol_rej = input.color(color.new(color.white, 100), "Border Color", group=grp_rej)
bstyle_rej_str = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group=grp_rej)
bstyle_rej = get_style(bstyle_rej_str)
bwidth_rej = input.int(1, "Border Width", minval=1, group=grp_rej)
show_lbl_rej = input.bool(true, "Show Label", group=grp_rej)
lsize_rej_str = input.string("Tiny", "Label Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_rej)
lsize_rej = get_size(lsize_rej_str)
tcol_rej = input.color(color.new(color.gray, 0), "Text Color", group=grp_rej)



// --- User Defined Types (UDTs) ---
type FVG_Data
    box b
    line ce
    bool is_bull
    bool is_inv
    float top
    float bot

type OB_Data
    box b
    bool is_bull
    bool is_breaker
    float top
    float bot
    bool swept_liq

var fvgs = array.new<FVG_Data>()
var obs  = array.new<OB_Data>()

// --- Pivot Tracking (For Breaker Sweep Detection) ---
pl = ta.pivotlow(low, 5, 5)
ph = ta.pivothigh(high, 5, 5)
var float last_pl = na
var float last_ph = na
if not na(pl)
    last_pl := pl
if not na(ph)
    last_ph := ph

// =====================================================================
in_lookback = (last_bar_index - bar_index) <= lookback_bars

// =====================================================================
// 1. Volume Imbalance (VI)
// =====================================================================
if use_vi and in_lookback
    body_max = math.max(open, close)
    body_min = math.min(open, close)
    prev_max = math.max(open[1], close[1])
    prev_min = math.min(open[1], close[1])

    if body_min > prev_max and low < high[1] // Bullish VI (Gap in bodies, wicks overlap)
        box.new(bar_index[1], body_min, bar_index, prev_max, bgcolor=col_vi, border_color=bcol_vi, border_style=bstyle_vi, border_width=bwidth_vi, text=show_lbl_vi ? "VI" : "", text_size=lsize_vi, text_color=tcol_vi)
    if body_max < prev_min and high > low[1] // Bearish VI
        box.new(bar_index[1], prev_min, bar_index, body_max, bgcolor=col_vi, border_color=bcol_vi, border_style=bstyle_vi, border_width=bwidth_vi, text=show_lbl_vi ? "VI" : "", text_size=lsize_vi, text_color=tcol_vi)

// =====================================================================
// 2. Rejection Blocks
// =====================================================================
atr = ta.atr(14)
if use_rej and in_lookback
    body_max = math.max(open, close)
    body_min = math.min(open, close)
    body = body_max - body_min
    wick_up = high - body_max
    wick_dn = body_min - low
    
    // Unusually long wick (2x body and significant compared to ATR)
    if wick_dn > body * 2 and wick_dn > atr * 0.5
        box.new(bar_index, body_min, bar_index+5, low, bgcolor=col_rej, border_color=bcol_rej, border_style=bstyle_rej, border_width=bwidth_rej, text=show_lbl_rej ? "Rej" : "", text_size=lsize_rej, text_color=tcol_rej)
    if wick_up > body * 2 and wick_up > atr * 0.5
        box.new(bar_index, high, bar_index+5, body_max, bgcolor=col_rej, border_color=bcol_rej, border_style=bstyle_rej, border_width=bwidth_rej, text=show_lbl_rej ? "Rej" : "", text_size=lsize_rej, text_color=tcol_rej)

// =====================================================================
// 3. FVGs, BPRs, and Order Blocks
// =====================================================================
is_bull_fvg = in_lookback and low > high[2]
is_bear_fvg = in_lookback and high < low[2]

if is_bull_fvg
    top = low
    bot = high[2]
    
    // Balanced Price Range (BPR) Check
    if use_bpr
        for f in fvgs
            if not f.is_bull and not f.is_inv
                o_top = math.min(top, f.top)
                o_bot = math.max(bot, f.bot)
                if o_top > o_bot // Overlap found
                    box.new(bar_index[2], o_top, bar_index+5, o_bot, bgcolor=col_bpr, border_color=bcol_bpr, border_style=bstyle_bpr, border_width=bwidth_bpr, text=show_lbl_bpr ? "BPR" : "", text_size=lsize_bpr, text_color=tcol_bpr)
                    
    // Create BISI
    if use_bisi
        b = box.new(bar_index[2], top, bar_index, bot, bgcolor=col_bisi, border_color=bcol_bisi, border_style=bstyle_bisi, border_width=bwidth_bisi, text=show_lbl_bisi ? "BISI" : "", text_color=tcol_bisi, text_size=lsize_bisi, text_halign=text.align_right)
        line l = na
        if use_ce
            l := line.new(bar_index[2], (top+bot)/2, bar_index, (top+bot)/2, color=col_ce, style=style_ce, width=width_ce)
        array.push(fvgs, FVG_Data.new(b, l, true, false, top, bot))
        
    // Generate Bullish OB (Displacement validated)
    if use_ob_bull
        int ob_idx = na
        for j = 2 to 10
            if close[j] < open[j] // Last down candle
                ob_idx := j
                break
        if not na(ob_idx)
            swept = not na(last_pl) and low[ob_idx] <= last_pl // Swept liquidity?
            b2 = box.new(bar_index[ob_idx], high[ob_idx], bar_index, low[ob_idx], bgcolor=col_ob_bull, border_color=bcol_ob_bull, border_style=bstyle_ob_bull, border_width=bwidth_ob_bull, text=show_lbl_ob_bull ? "+OB" : "", text_color=tcol_ob_bull, text_size=lsize_ob_bull, text_halign=text.align_right)
            array.push(obs, OB_Data.new(b2, true, false, high[ob_idx], low[ob_idx], swept))

if is_bear_fvg
    top = low[2]
    bot = high
    
    // Balanced Price Range (BPR) Check
    if use_bpr
        for f in fvgs
            if f.is_bull and not f.is_inv
                o_top = math.min(top, f.top)
                o_bot = math.max(bot, f.bot)
                if o_top > o_bot
                    box.new(bar_index[2], o_top, bar_index+5, o_bot, bgcolor=col_bpr, border_color=bcol_bpr, border_style=bstyle_bpr, border_width=bwidth_bpr, text=show_lbl_bpr ? "BPR" : "", text_size=lsize_bpr, text_color=tcol_bpr)
                    
    // Create SIBI
    if use_sibi
        b = box.new(bar_index[2], top, bar_index, bot, bgcolor=col_sibi, border_color=bcol_sibi, border_style=bstyle_sibi, border_width=bwidth_sibi, text=show_lbl_sibi ? "SIBI" : "", text_color=tcol_sibi, text_size=lsize_sibi, text_halign=text.align_right)
        line l = na
        if use_ce
            l := line.new(bar_index[2], (top+bot)/2, bar_index, (top+bot)/2, color=col_ce, style=style_ce, width=width_ce)
        array.push(fvgs, FVG_Data.new(b, l, false, false, top, bot))
        
    // Generate Bearish OB (Displacement validated)
    if use_ob_bear
        int ob_idx = na
        for j = 2 to 10
            if close[j] > open[j] // Last up candle
                ob_idx := j
                break
        if not na(ob_idx)
            swept = not na(last_ph) and high[ob_idx] >= last_ph // Swept liquidity?
            b2 = box.new(bar_index[ob_idx], high[ob_idx], bar_index, low[ob_idx], bgcolor=col_ob_bear, border_color=bcol_ob_bear, border_style=bstyle_ob_bear, border_width=bwidth_ob_bear, text=show_lbl_ob_bear ? "-OB" : "", text_color=tcol_ob_bear, text_size=lsize_ob_bear, text_halign=text.align_right)
            array.push(obs, OB_Data.new(b2, false, false, high[ob_idx], low[ob_idx], swept))

// =====================================================================
// 4. Array Management (Inversions & Mitigations)
// =====================================================================
if barstate.isconfirmed
    // Manage FVGs
    if array.size(fvgs) > 0
        for i = array.size(fvgs) - 1 to 0
            f = array.get(fvgs, i)
            box.set_right(f.b, bar_index)
            if use_ce and not na(f.ce)
                line.set_x2(f.ce, bar_index)
                
            if not f.is_inv
                if f.is_bull
                    if close < f.bot
                        // BISI broken -> Becomes Bearish IFVG
                        if use_inv_bear
                            f.is_inv := true
                            box.set_bgcolor(f.b, col_inv_bear)
                            box.set_border_color(f.b, bcol_inv_bear)
                            box.set_border_style(f.b, bstyle_inv_bear)
                            box.set_border_width(f.b, bwidth_inv_bear)
                            box.set_text(f.b, show_lbl_inv_bear ? "IFVG" : "")
                            box.set_text_color(f.b, tcol_inv_bear)
                            box.set_text_size(f.b, lsize_inv_bear)
                            if not na(f.ce)
                                line.set_color(f.ce, col_ce)
                        else
                            box.delete(f.b)
                            if not na(f.ce)
                                line.delete(f.ce)
                            array.remove(fvgs, i)
                else
                    if close > f.top
                        // SIBI broken -> Becomes Bullish IFVG
                        if use_inv_bull
                            f.is_inv := true
                            box.set_bgcolor(f.b, col_inv_bull)
                            box.set_border_color(f.b, bcol_inv_bull)
                            box.set_border_style(f.b, bstyle_inv_bull)
                            box.set_border_width(f.b, bwidth_inv_bull)
                            box.set_text(f.b, show_lbl_inv_bull ? "IFVG" : "")
                            box.set_text_color(f.b, tcol_inv_bull)
                            box.set_text_size(f.b, lsize_inv_bull)
                            if not na(f.ce)
                                line.set_color(f.ce, col_ce)
                        else
                            box.delete(f.b)
                            if not na(f.ce)
                                line.delete(f.ce)
                            array.remove(fvgs, i)
            else
                // It IS an Inversion. Has it been invalidated?
                if f.is_bull // Originally bullish, now Bearish IFVG. Invalidated if broken UP.
                    if close > f.top
                        box.delete(f.b)
                        if not na(f.ce)
                            line.delete(f.ce)
                        array.remove(fvgs, i)
                else // Originally bearish, now Bullish IFVG. Invalidated if broken DOWN.
                    if close < f.bot
                        box.delete(f.b)
                        if not na(f.ce)
                            line.delete(f.ce)
                        array.remove(fvgs, i)

    // Manage Order Blocks (Breakers / Mitigation)
    if array.size(obs) > 0
        for i = array.size(obs) - 1 to 0
            o = array.get(obs, i)
            box.set_right(o.b, bar_index)
            
            if not o.is_breaker
                if o.is_bull
                    if close < o.bot
                        // Bullish OB broken -> Becomes Bearish Breaker/MB
                        if use_brk_bear
                            o.is_breaker := true
                            txt = o.swept_liq ? "-BRK" : "-MB"
                            box.set_bgcolor(o.b, col_brk_bear)
                            box.set_border_color(o.b, bcol_brk_bear)
                            box.set_border_style(o.b, bstyle_brk_bear)
                            box.set_border_width(o.b, bwidth_brk_bear)
                            box.set_text(o.b, show_lbl_brk_bear ? txt : "")
                            box.set_text_color(o.b, tcol_brk_bear)
                            box.set_text_size(o.b, lsize_brk_bear)
                        else
                            box.delete(o.b)
                            array.remove(obs, i)
                else
                    if close > o.top
                        // Bearish OB broken -> Becomes Bullish Breaker/MB
                        if use_brk_bull
                            o.is_breaker := true
                            txt = o.swept_liq ? "+BRK" : "+MB"
                            box.set_bgcolor(o.b, col_brk_bull)
                            box.set_border_color(o.b, bcol_brk_bull)
                            box.set_border_style(o.b, bstyle_brk_bull)
                            box.set_border_width(o.b, bwidth_brk_bull)
                            box.set_text(o.b, show_lbl_brk_bull ? txt : "")
                            box.set_text_color(o.b, tcol_brk_bull)
                            box.set_text_size(o.b, lsize_brk_bull)
                        else
                            box.delete(o.b)
                            array.remove(obs, i)
            else
                // It IS a Breaker/MB. Has it been invalidated?
                if o.is_bull // Failed +OB = Bearish Resistance. Invalidated if broken UP.
                    if close > o.top
                        box.delete(o.b)
                        array.remove(obs, i)
                else // Failed -OB = Bullish Support. Invalidated if broken DOWN.
                    if close < o.bot
                        box.delete(o.b)
                        array.remove(obs, i)

// Garbage Collection (Keep chart lightweight)
if array.size(fvgs) > 100
    f = array.shift(fvgs)
    box.delete(f.b)
    if not na(f.ce)
        line.delete(f.ce)
if array.size(obs) > 100
    o = array.shift(obs)
    box.delete(o.b)
````
