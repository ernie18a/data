# Trend Analyzer by erdensedat

- url: https://www.tradingview.com/script/rPLa3BC9-Trend-Analyzer-by-erdensedat/
- type: indicator
- pine_id: PUB;0ae71c4503ec435e91119d1bd156cfac
- version: 3.0

## Description

Trend Analyzer by erdensedat is a comprehensive "all-in-one" technical analysis engine built for smart money concepts (SMC) and kinetic trend following. It helps traders by visually presenting the most crucial price action features on the chart, reducing clutter while providing deep market insights.

Key Features & How It Helps:

Liquidity Imbalances (FVG): It automatically draws Fair Value Gaps on your chart. When price fills them, they can act as support/resistance.
Institutional Blocks (OB & RB): It spots Order Blocks and Rejection Blocks (wicks). When price returns to these zones, it often signals a high-probability reversal.
Kinetic Core & Early Impulse: It calculates momentum shifts in the market. The "Impulse" triangles tell you exactly when sudden momentum enters the market.
Market Structure (BOS / CHoCH): It automatically labels Break of Structure and Change of Character, helping you stay on the right side of the market trend.
Liquidity Sweeps & MTF Levels: It grabs Higher Timeframe (Daily/Weekly/Monthly) highs and lows. If price grabs liquidity from these levels, it highlights the "Liquidity Sweep" area.
Terminal Dashboard: It features a data-rich UI panel displaying the live status of RSI, MFI, Momentum, Volatility, and live Trade Risk/Reward.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
// © erdensedat
//@version=6
indicator("Trend Analyzer by erdensedat", shorttitle="Trend Analyzer", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, max_polylines_count=100)

// ==============================================================================
// Constants & Colors
// ==============================================================================
var color bull_c = #089981
var color bear_c = #f23645
var color neut_c = #9598a1
var string POS_TR = "Top Right"
var string SIZE_S = "Small"

// ==============================================================================
// 1. INPUTS
// ==============================================================================

// --- Swing Points (Foundation) ---
string GRP_SWINGS = "Foundation"
int pivotLength   = input.int(5, "Pivot Length for RB", tooltip="Number of bars used to confirm a swing high/low for Rejection Blocks", group=GRP_SWINGS)

// --- Imbalance (FVG) ---
string GRP_FVG    = "Liquidity: Imbalance (FVG)"
bool fvg_enable   = input.bool(true, "Display FVG", inline="1", group=GRP_FVG, tooltip="Display fair value gap")
string what_fvg   = input.string("FVG", "", inline="1", group=GRP_FVG, options=["FVG", "Breakers"])
int fvg_num       = input.int(2, "Show Last", inline="1a", group=GRP_FVG, tooltip="Number of fvg to show", minval=0)
color fvg_upcss   = input.color(color.new(#089981, 80), "", inline="1", group=GRP_FVG)
color fvg_dncss   = input.color(color.new(#f23645, 80), "", inline="1", group=GRP_FVG)
string fvg_src    = input.string("Close", "Mitigation", inline="3", group=GRP_FVG, tooltip="[Close] Use the close of the body as trigger\n[Wick] Use the extreme point of the body as trigger", options=["Close", "Wick", "Avg"])
float fvgthresh   = input.float(0, "Threshold", tooltip="Filter out non significative FVG", group=GRP_FVG, inline="asd", minval=0, maxval=2, step=0.1)
bool fvgoverlap   = input.bool(true, "Hide Overlap", tooltip="Hide overlapping FVG", group=GRP_FVG)
bool fvgline      = input.bool(true, "Show Mid-Line", group=GRP_FVG)
bool fvgextend    = input.bool(false, "Extend FVG", group=GRP_FVG)
bool dispraid     = input.bool(true, "Display Raids", inline="raid", group=GRP_FVG)

// --- Premium / Discount Zones ---
string GRP_PD     = "Premium & Discount Range"
bool show_pd      = input.bool(false, "Enable Premium/Eq/Discount Zones", group=GRP_PD)
int pd_len        = input.int(50, "Lookback Length", group=GRP_PD, minval=10)
color col_prem    = input.color(color.new(#f23645, 80), "Premium Box Color", group=GRP_PD)
color col_eq      = input.color(color.new(#9598a1, 80), "Equilibrium Box Color", group=GRP_PD)
color col_disc    = input.color(color.new(#089981, 80), "Discount Box Color", group=GRP_PD)
bool show_pd_bg   = input.bool(false, "Show Range Background Box", group=GRP_PD)
color col_pd_bg   = input.color(color.new(color.white, 95), "Full Range BG Color", group=GRP_PD)

// --- Institutional Blocks ---
string GRP_OB     = "Institutional: Blocks (OB/MB/RB)"
bool showOB       = input.bool(true, "Show Order Blocks (OB -> BB)", group=GRP_OB)
color colBullOB   = input.color(color.new(#089981, 80), "Bullish OB", group=GRP_OB)
color colBearOB   = input.color(color.new(#f23645, 80), "Bearish OB", group=GRP_OB)
color colBrokenBB = input.color(color.new(color.gray, 80), "Broken BB Color", group=GRP_OB)
bool showRB       = input.bool(true, "Show Rejection Blocks (RB)", group=GRP_OB)
color colBullRB   = input.color(color.new(#089981, 80), "Bullish RB", group=GRP_OB)
color colBearRB   = input.color(color.new(#f23645, 80), "Bearish RB", group=GRP_OB)
int maxBoxesBlock = input.int(3, "Max Boxes", minval=1, maxval=50, group=GRP_OB)
int boxExtend     = input.int(1, "Box Extend Right (Bars)", minval=0, maxval=20, group=GRP_OB)

string lblSizeInp = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=GRP_OB)

// --- Kinetic Core ---
string group_eng   = "Kinetic Core"
bool show_trail   = input.bool(false, "Enable Kinetic Trail & Signals", group=group_eng)
float sens        = input.float(2.0, "Sensitivity", minval=0.5, step=0.1, group=group_eng)
int atrL        = input.int(10, "ATR Window", minval=1, group=group_eng)
bool show_active = input.bool(true, "Show Only Active Segment", tooltip="Strictly displays only the current trail segment and the latest signal. Removes all history.", group=group_eng)

// --- Early Impulse Mode ---
string group_imp   = "Early Impulse Mode"
bool show_imp    = input.bool(true, "Enable Early Impulse Detection", group=group_imp)
float imp_sens    = input.float(1.3, "Impulse Sensitivity", minval=0.5, step=0.1, group=group_imp)
int imp_atr     = input.int(7, "Impulse ATR Window", minval=1, group=group_imp)

// --- Kinetic MA Trail (Macro) ---
string group_macro = "Kinetic MA Trail (Macro)"
bool show_ma     = input.bool(true, "Enable Kinetic MA Trail & Cloud", group=group_macro)
string ma_type     = input.string("WMA", "MA Type", options=["SMA", "EMA", "WMA", "HMA", "VWMA", "RMA"], group=group_macro)
int ma_len      = input.int(20, "Macro Length", minval=1, group=group_macro)

// --- Dynamic Target Engine ---
string group_fibo  = "Dynamic Target Engine"
bool show_tps    = input.bool(true, "Enable Recursive TP Lines", group=group_fibo)
string label_size  = input.string(SIZE_S, "Label Size", options=["Tiny", "Small", "Normal"], group=group_fibo)

// --- Candidate BOS/CHoCH Motor ---
string group_bos     = "Candidate BOS/CHoCH Motor"
bool show_bos      = input.bool(true, "Enable BOS Engine", group=group_bos)
int bos_len       = input.int(6, "Fractal Length", minval=3, maxval=51, group=group_bos)
int bos_ext       = input.int(10, "Candidate Extension", minval=1, maxval=300, group=group_bos)
bool bos_require   = input.bool(true, "Break = Close Beyond Level", group=group_bos)
string bos_lb_size   = input.string("Normal", "BOS Label Size", options=["Small", "Normal", "Big"], group=group_bos)
string bos_style     = input.string("Dashed", "Candidate Style", options=["Solid", "Dashed", "Dotted"], group=group_bos)
int bos_width     = input.int(2, "Candidate Width", minval=1, maxval=5, group=group_bos)
int bos_show_n    = input.int(5, "Show Last X Structures", minval=1, maxval=100, group=group_bos)

// --- Higher Timeframe Highs/Lows ---
string group_mtf_hl = "Higher Timeframe Highs/Lows"
bool show_pdhl = input.bool(true, "Show Daily (PDH/PDL)", group=group_mtf_hl)
bool show_pwhl = input.bool(false, "Show Weekly (PWH/PWL)", group=group_mtf_hl)
bool show_pmhl = input.bool(false, "Show Monthly (PMH/PML)", group=group_mtf_hl)
string mtf_ls_inp = input.string("Solid", "MTF Line Style", options=["Solid", "Dashed", "Dotted"], group=group_mtf_hl)
string mtf_sz_inp = input.string("Normal", "MTF Label Size", options=["Small", "Normal", "Big"], group=group_mtf_hl)

// --- Liquidity Sweep Motor ---
string group_sweep  = "Liquidity Sweep Motor"
bool show_sweep   = input.bool(true, "Enable Liquidity Sweep", group=group_sweep)
int sweep_n      = input.int(1, "Show Last X Zones", minval=1, group=group_sweep)

// --- Signal Visualization ---
string group_vis    = "Signal Visualization"
bool show_sig_lb = input.bool(true, "Show Buy/Sell Labels", group=group_vis)

// --- UI / Dashboard ---
string group_ui     = "Interface & Dashboard"
string panel_pos    = input.string(POS_TR, "Panel Position", options=["Top Right", "Bottom Right", "Bottom Left", "Top Left"], group=group_ui)
string panel_size   = input.string("Small", "Panel Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=group_ui)

// ==============================================================================
// Watermark
// ==============================================================================
var table wm = table.new(position.bottom_right, 1, 1)
if barstate.isfirst
    table.cell(wm, 0, 0, "Trend Analyzer\nby erdensedat", text_color=color.new(color.gray, 50), text_size=size.large, text_halign=text.align_right)

// ==============================================================================
// Helper Functions
// ==============================================================================
f_get_lbl_size(string str) =>
    str == "Tiny" ? size.tiny : str == "Small" ? size.small : str == "Normal" ? size.normal : size.large
string lblSize = f_get_lbl_size(lblSizeInp)

f_opaque(color c) => color.new(c, 0)

f_sz(string s) => 
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        "Big"    => size.large
        "Auto"   => size.auto
        => size.normal

f_ls(string s) => s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

f_ma(string type, series float src, int len) =>
    switch type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "HMA"  => ta.hma(src, len)
        "VWMA" => ta.vwma(src, len)
        "RMA"  => ta.rma(src, len)
        => ta.ema(src, len)

// ==============================================================================
// 2. FVG ENGINE
// ==============================================================================
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

method dispFVG(FVG fvg, int i, bool bull) =>
    ext = fvgextend ? extend.right : extend.none
    if not fvg.isbb
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = time, border_color = na, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time, extend = ext, text="FVG", text_size=size.small, text_color=color.new(color.white, 20), text_halign=text.align_center, text_valign=text.align_center))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), xloc = xloc.bar_time, color = color.new(bull ? fvg_upcss : fvg_dncss, 0), extend = ext))
        if dispraid
            bin.ln.unshift(line.new(x1 = fvg.raidloc, x2 = fvg.raidx2, y1 = fvg.raidy, y2 = fvg.raidy, xloc = xloc.bar_time, color = fvg.raidcs))
            bin.lb.unshift(label.new(x = int(math.avg(fvg.raidloc, fvg.raidx2)), y = fvg.raidy, text = "x", xloc = xloc.bar_time, textcolor = fvg.raidcs, style = bull ? label.style_label_up : label.style_label_down, size = size.small, color = #ffffff00))
    else
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.loc, right = fvg.bbloc, border_color = na, bgcolor = bull ? fvg_upcss : fvg_dncss, xloc = xloc.bar_time, text="FVG", text_size=size.small, text_color=color.new(color.white, 20), text_halign=text.align_center, text_valign=text.align_center))
        bin.bx.unshift(box.new(top = fvg.top, bottom = fvg.btm, left = fvg.bbloc, right = time, border_color = bull ? fvg_dncss : fvg_upcss, bgcolor = bull ? fvg_dncss : fvg_upcss, xloc = xloc.bar_time, extend = ext))
        if fvgline
            bin.ln.unshift(line.new(x1 = fvg.loc, x2 = fvg.bbloc, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_upcss : fvg_dncss, 0), xloc = xloc.bar_time))
            bin.ln.unshift(line.new(x1 = fvg.bbloc, x2 = time, y1 = math.avg(fvg.top, fvg.btm), y2 = math.avg(fvg.top, fvg.btm), color = color.new(bull ? fvg_dncss : fvg_upcss, 0), xloc = xloc.bar_time, extend = ext, style = line.style_dashed))

dFVG() =>
    [h2, l2, c1, o1, c, o, h, l, h1, l1, fvatr] = ghl()
    var FVG[] blFVG = array.new<FVG>()
    var FVG[] brFVG = array.new<FVG>()
    bool upfvg = false
    bool dnfvg = false
    float blth = l1 + (fvatr[1] * fvgthresh)
    float brth = h1 - (fvatr[1] * fvgthresh)

    cc = ta.change(time) != 0

    switch
        what_fvg == "FVG" or what_fvg == "Breakers" =>
            if l > h2 and cc and c1 > blth
                upfvg := true
                
            if l2 > h and cc and c1 < brth
                dnfvg := true

    if upfvg[1]
        if blFVG.size() > 0
            fvg = blFVG.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        blFVG.unshift(FVG.new(top = l[1], btm = h2[1], loc = time[3]))

    if dnfvg[1]
        if brFVG.size() > 0
            fvg = brFVG.get(0)
            if fvg.israid == true and fvg.active == false
                fvg.active  := true
                fvg.raidloc := na
                fvg.raidx2  := na
                fvg.raidy   := na
                fvg.raidcs  := #ffffff00

        brFVG.unshift(FVG.new(top = l2[1], btm = h[1], loc = time[3]))

    if blFVG.size() > 0
        for [i, fvg] in blFVG
            if not fvg.isbb
                if fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        blFVG.remove(i)
            else
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    blFVG.remove(i)
                    
    if brFVG.size() > 0
        for [i, fvg] in brFVG
            if not fvg.isbb
                if (fvg_src == "Close" ? math.max(c, o) > fvg.top : fvg_src == "Wick" ? h > fvg.top : fvg_src == "Avg" ? h > math.avg(fvg.top, fvg.btm) : false)
                    fvg.isbb := true
                    fvg.bbloc := time
                    if what_fvg == "FVG"
                        brFVG.remove(i)
            else
                if (fvg_src == "Close" ? math.min(c, o) < fvg.btm : fvg_src == "Wick" ? l < fvg.btm : fvg_src == "Avg" ? l < math.avg(fvg.top, fvg.btm) : false) and what_fvg == "Breakers"
                    brFVG.remove(i)
                    
    if fvgoverlap
        overlapFVG(blFVG, brFVG)

    if dispraid
        for [i, fvg] in blFVG
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

        for [i, fvg] in brFVG
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
        if blFVG.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, blFVG.size() - 1)
                fvg = blFVG.get(i)
                dispFVG(fvg, i, true)

        if brFVG.size() > 0 and fvg_num > 0
            for i = 0 to math.min(fvg_num - 1, brFVG.size() - 1)
                fvg = brFVG.get(i)
                dispFVG(fvg, i, false)

if fvg_enable
    dFVG()

// ==============================================================================
// 3. ORDER BLOCKS & REJECTION BLOCKS
// ==============================================================================
float ph = ta.pivothigh(high, pivotLength, pivotLength)
float pl = ta.pivotlow(low, pivotLength, pivotLength)

type Block
    box bx
    label lbl
    bool isBull
    bool isMitigated
    string bType
    bool retested

var Block[] blockArray = array.new<Block>()

bool isBullFVG_basic = low[0] > high[2] and close[1] > high[2]
bool isBearFVG_basic = high[0] < low[2] and close[1] < low[2]

bool bullOB_Cond = isBullFVG_basic and close[2] < open[2]
bool bearOB_Cond = isBearFVG_basic and close[2] > open[2]

float bodyTop = math.max(open, close)
float bodyBot = math.min(open, close)
float upperWick = high - bodyTop
float lowerWick = bodyBot - low
float candleRange = high - low

bool isBullRB = not na(pl) and (lowerWick > candleRange * 0.5)
bool isBearRB = not na(ph) and (upperWick > candleRange * 0.5)

var int last_ob_dir = 0
var bool ob_alert_fired = true

if showOB
    if bullOB_Cond
        array.push(blockArray, Block.new(box.new(bar_index[2], high[2], bar_index, low[2], bgcolor=color.new(colBullOB, 80), border_color=color.new(colBullOB, 50)), label.new(bar_index, (high[2] + low[2]) / 2, "Order Block", color=color.new(color.white, 100), textcolor=f_opaque(colBullOB), style=label.style_label_left, size=lblSize), true, false, "OB", false))
        last_ob_dir := 1
        ob_alert_fired := false
    if bearOB_Cond
        array.push(blockArray, Block.new(box.new(bar_index[2], high[2], bar_index, low[2], bgcolor=color.new(colBearOB, 80), border_color=color.new(colBearOB, 50)), label.new(bar_index, (high[2] + low[2]) / 2, "Order Block", color=color.new(color.white, 100), textcolor=f_opaque(colBearOB), style=label.style_label_left, size=lblSize), false, false, "OB", false))
        last_ob_dir := -1
        ob_alert_fired := false

if showRB
    if isBullRB
        array.push(blockArray, Block.new(box.new(bar_index[pivotLength], bodyBot[pivotLength], bar_index, low[pivotLength], bgcolor=color.new(colBullRB, 80), border_color=color.new(colBullRB, 50)), label.new(bar_index, (bodyBot[pivotLength] + low[pivotLength]) / 2, "Rejection Block", color=color.new(color.white, 100), textcolor=f_opaque(colBullRB), style=label.style_label_left, size=lblSize), true, false, "RB", false))
    if isBearRB
        array.push(blockArray, Block.new(box.new(bar_index[pivotLength], high[pivotLength], bar_index, bodyTop[pivotLength], bgcolor=color.new(colBearRB, 80), border_color=color.new(colBearRB, 50)), label.new(bar_index, (high[pivotLength] + bodyTop[pivotLength]) / 2, "Rejection Block", color=color.new(color.white, 100), textcolor=f_opaque(colBearRB), style=label.style_label_left, size=lblSize), false, false, "RB", false))

if showOB or showRB
    if array.size(blockArray) > maxBoxesBlock * 2
        removed = array.shift(blockArray)
        box.delete(removed.bx), label.delete(removed.lbl)
        
    for i = 0 to (array.size(blockArray) == 0 ? na : array.size(blockArray) - 1)
        if array.size(blockArray) > 0
            blk = array.get(blockArray, i)
            if not blk.isMitigated
                top_bx = box.get_top(blk.bx)
                bot_bx = box.get_bottom(blk.bx)
                
                if not blk.retested and bar_index > box.get_left(blk.bx)
                    if blk.isBull and low <= top_bx and high >= bot_bx
                        blk.retested := true
                    if not blk.isBull and high >= bot_bx and low <= top_bx
                        blk.retested := true
                
                isMitigated = (blk.isBull and close < bot_bx) or (not blk.isBull and close > top_bx)
                if isMitigated
                    blk.isMitigated := true
                    if blk.bType == "OB"
                        label.set_text(blk.lbl, "Breaker Block")
                    else if blk.bType == "RB"
                        label.set_text(blk.lbl, "Mitigation Block")
                    box.set_bgcolor(blk.bx, colBrokenBB)
                    box.set_border_color(blk.bx, color.new(colBrokenBB, 50))
                    label.set_textcolor(blk.lbl, f_opaque(colBrokenBB))
                else
                    box.set_right(blk.bx, bar_index + boxExtend)
                    label.set_x(blk.lbl, bar_index + boxExtend + 1)

// ==============================================================================
// 4. KINETIC CORE & EARLY IMPULSE & ALERTS
// ==============================================================================
[st_at, d_at] = ta.supertrend(sens, atrL)       
[st_im, d_im] = ta.supertrend(imp_sens, imp_atr) 
atr_v         = ta.atr(14)
is_up         = d_at < 0

buy_sig  = ta.change(d_at) < 0
sell_sig = ta.change(d_at) > 0

var int active_start_idx = 0
if buy_sig or sell_sig
    active_start_idx := bar_index

imp_buy  = show_imp and d_im < 0 and d_im[1] > 0
imp_sell = show_imp and d_im > 0 and d_im[1] < 0

// Alert Motor Logic: Impulse matching last OB direction
if imp_buy and last_ob_dir == 1 and not ob_alert_fired
    ob_alert_fired := true
    alert("Bullish Impulse formed matching the last Bullish Order Block direction!", alert.freq_once_per_bar_close)

if imp_sell and last_ob_dir == -1 and not ob_alert_fired
    ob_alert_fired := true
    alert("Bearish Impulse formed matching the last Bearish Order Block direction!", alert.freq_once_per_bar_close)

var line[] trail_lines = array.new_line()
if (buy_sig or sell_sig) and show_active and show_trail
    if array.size(trail_lines) > 0
        for ln in trail_lines
            line.delete(ln)
        array.clear(trail_lines)
if show_active and show_trail and not na(st_at) and not na(st_at[1]) and bar_index > active_start_idx
    ln = line.new(bar_index-1, st_at[1], bar_index, st_at, color=is_up ? bull_c : bear_c, width=2)
    array.push(trail_lines, ln)

plot(show_trail and not show_active ? st_at : na, "Kinetic Trail", color=is_up ? bull_c : bear_c, linewidth=2, style=plot.style_linebr)

// Early Impulse Signals
plotshape(imp_buy, "Impulse Buy", shape.triangleup, location.belowbar, bull_c, size=size.tiny)
plotshape(imp_sell, "Impulse Sell", shape.triangledown, location.abovebar, bear_c, size=size.tiny)

var label last_signal = na
if (buy_sig or sell_sig) and show_sig_lb and show_trail
    if show_active
        label.delete(last_signal)
    last_signal := label.new(bar_index, st_at, buy_sig ? "BUY" : "SELL", color=buy_sig ? bull_c : bear_c, textcolor=color.white, style=buy_sig ? label.style_label_up : label.style_label_down, size=size.small)

// ==============================================================================
// 5. KINETIC MA TRAIL (MACRO) & CLOUD
// ==============================================================================
macro_ma_base = f_ma(ma_type, close, ma_len)
var float ma_trail = na
if is_up
    ma_trail := na(ma_trail[1]) ? macro_ma_base : math.max(macro_ma_base, nz(ma_trail[1]))
else
    ma_trail := na(ma_trail[1]) ? macro_ma_base : math.min(macro_ma_base, nz(ma_trail[1]))
ma_is_bull = close > ma_trail

p_ma  = plot(show_ma ? ma_trail : na, "Kinetic MA", color=ma_is_bull ? color.new(bull_c, 30) : color.new(bear_c, 30), linewidth=1)
p_mao = plot(show_ma ? ma_trail + (ma_is_bull ? -atr_v*0.5 : atr_v*0.5) : na, "MA Offset", display=display.none)
fill(p_ma, p_mao, ma_is_bull ? color.new(bull_c, 90) : color.new(bear_c, 90))

// ==============================================================================
// 6. DYNAMIC TARGET ENGINE
// ==============================================================================
var float[] tp_levels = array.new_float(0)
var line[]  tp_lines  = array.new_line(0)
var label[] tp_labels = array.new_label(0)
var int     stage     = 0
var float   e_diff    = 0.0

f_clear_tp() =>
    if array.size(tp_lines) > 0
        for i = 0 to array.size(tp_lines) - 1
            line.delete(array.get(tp_lines, i))
            label.delete(array.get(tp_labels, i))
    array.clear(tp_lines)
    array.clear(tp_labels)

f_add_tp(float base, float diff, bool up) =>
    float m1 = stage * 1.5 + 1.618
    float m2 = stage * 1.5 + 2.618
    t1 = up ? base + diff * m1 : base - diff * m1
    t2 = up ? base + diff * m2 : base - diff * m2
    c = up ? bull_c : bear_c
    array.push(tp_levels, t1)
    array.push(tp_levels, t2)
    l1 = line.new(bar_index, t1, bar_index + 15, t1, color=color.new(c, 50), style=line.style_dashed)
    l2 = line.new(bar_index, t2, bar_index + 15, t2, color=color.new(c, 50), style=line.style_dashed)
    array.push(tp_lines, l1)
    array.push(tp_lines, l2)
    lb1 = label.new(bar_index + 15, t1, "TP " + str.tostring(array.size(tp_levels)-1) + " [" + str.format("{0,number,#.##}", t1) + "]", color=#00000000, textcolor=c, style=label.style_label_left, size=f_sz(label_size))
    lb2 = label.new(bar_index + 15, t2, "TP " + str.tostring(array.size(tp_levels)) + " [" + str.format("{0,number,#.##}", t2) + "]", color=#00000000, textcolor=c, style=label.style_label_left, size=f_sz(label_size))
    array.push(tp_labels, lb1)
    array.push(tp_labels, lb2)

var float entry_p = 0.0
var float entry_s = 0.0
if buy_sig or sell_sig
    entry_p := close
    entry_s := st_at
    f_clear_tp()
    array.clear(tp_levels)
    stage := 0
    e_diff := math.abs(close - st_at)
    if show_tps
        f_add_tp(close, e_diff, buy_sig)

if show_tps and array.size(tp_lines) > 0
    for i = 0 to array.size(tp_lines) - 1
        line.set_x2(array.get(tp_lines, i), bar_index + 15)
        label.set_x(array.get(tp_labels, i), bar_index + 15)
    l_tp = array.get(tp_levels, array.size(tp_levels) - 1)
    if (is_up and high >= l_tp) or (not is_up and low <= l_tp)
        f_clear_tp()
        stage += 1
        f_add_tp(entry_p, e_diff, is_up)

// ==============================================================================
// 7. BOS ENGINE
// ==============================================================================
var line[] bos_lines = array.new_line()
var label[] bos_labels = array.new_label()

f_trimBOS() =>
    limit = bos_show_n
    while array.size(bos_lines) > limit
        line.delete(array.shift(bos_lines))
        label.delete(array.shift(bos_labels))

var float upLvl = na, var int upT = na, var bool upBroken = false, var line upLine = na, var label upCandLb = na
var float dnLvl = na, var int dnT = na, var bool dnBroken = false, var line dnlvlLine = na, var label dnCandLb = na
var int bos_os = 0

if show_bos
    p_len = (bos_len % 2 == 0) ? int((bos_len + 1) / 2) : int(bos_len / 2)
    phHit = not na(ta.pivothigh(high, p_len, p_len))
    plHit = not na(ta.pivotlow(low, p_len, p_len))
    
    extMs = timeframe.in_seconds(timeframe.period) * 1000 * bos_ext
    c_up = bull_c
    c_dn = bear_c

    if phHit
        if not na(upLine) and not upBroken
            line.delete(upLine), label.delete(upCandLb)
        upLvl := high[p_len], upT := time[p_len], upBroken := false
        upLine := line.new(upT, upLvl, time + extMs, upLvl, xloc=xloc.bar_time, color=color.new(c_up, 50), style=f_ls(bos_style), width=bos_width)
        upCandLb := label.new(time + extMs, upLvl, "BOS ↑", xloc=xloc.bar_time, style=label.style_label_down, textcolor=c_up, color=#00000000, size=f_sz(bos_lb_size))

    if plHit
        if not na(dnlvlLine) and not dnBroken
            line.delete(dnlvlLine), label.delete(dnCandLb)
        dnLvl := low[p_len], dnT := time[p_len], dnBroken := false
        dnlvlLine := line.new(dnT, dnLvl, time + extMs, dnLvl, xloc=xloc.bar_time, color=color.new(c_dn, 50), style=f_ls(bos_style), width=bos_width)
        dnCandLb := label.new(time + extMs, dnLvl, "BOS ↓", xloc=xloc.bar_time, style=label.style_label_up, textcolor=c_dn, color=#00000000, size=f_sz(bos_lb_size))

    brkUp = not na(upLvl) and not upBroken and (bos_require ? close > upLvl : high > upLvl)
    brkDn = not na(dnLvl) and not dnBroken and (bos_require ? close < dnLvl : low < dnLvl)

    if brkUp
        upBroken := true
        line.set_color(upLine, c_up), line.set_style(upLine, line.style_solid), line.set_x2(upLine, time)
        label.delete(upCandLb), upCandLb := na
        txt = bos_os == -1 ? "CHoCH" : "BOS"
        lb = label.new(int(math.avg(time, upT)), upLvl, txt, xloc=xloc.bar_time, style=label.style_label_down, textcolor=c_up, color=#00000000, size=f_sz(bos_lb_size))
        array.push(bos_labels, lb), array.push(bos_lines, upLine)
        upLine := na, bos_os := 1, f_trimBOS()

    if brkDn
        dnBroken := true
        line.set_color(dnlvlLine, c_dn), line.set_style(dnlvlLine, line.style_solid), line.set_x2(dnlvlLine, time)
        label.delete(dnCandLb), dnCandLb := na
        txt = bos_os == 1 ? "CHoCH" : "BOS"
        lb = label.new(int(math.avg(time, dnT)), dnLvl, txt, xloc=xloc.bar_time, style=label.style_label_up, textcolor=c_dn, color=#00000000, size=f_sz(bos_lb_size))
        array.push(bos_labels, lb), array.push(bos_lines, dnlvlLine)
        dnlvlLine := na, bos_os := -1, f_trimBOS()

// ==============================================================================
// 8. MTF HIGHS/LOWS ENGINE
// ==============================================================================
f_get_mtf_data(string tf) =>
    request.security(syminfo.tickerid, tf, [high[1], low[1], ta.valuewhen(high == ta.highest(high, 1), time, 0)[1], ta.valuewhen(low == ta.lowest(low, 1), time, 0)[1]], lookahead=barmerge.lookahead_on)

[pdh_v, pdl_v, pdh_t, pdl_t] = f_get_mtf_data("D")
[pwh_v, pwl_v, pwh_t, pwl_t] = f_get_mtf_data("W")
[pmh_v, pml_v, pmh_t, pml_t] = f_get_mtf_data("M")

f_render_mtf(float val, int t_start, string txt, bool show, color col) =>
    var line ln = na
    var label lb = na
    if show and not na(val) and not na(t_start)
        if not na(ln)
            line.delete(ln), label.delete(lb)
        ln := line.new(t_start, val, time, val, color=color.new(col, 50), width=1, xloc=xloc.bar_time, style=f_ls(mtf_ls_inp))
        lb := label.new(time, val, txt, textcolor=col, color=#00000000, style=label.style_label_left, size=f_sz(mtf_sz_inp), xloc=xloc.bar_time)

if barstate.islast
    f_render_mtf(pdh_v, pdh_t, "PDH", show_pdhl, bull_c)
    f_render_mtf(pdl_v, pdl_t, "PDL", show_pdhl, bear_c)
    f_render_mtf(pwh_v, pwh_t, "PWH", show_pwhl, bull_c)
    f_render_mtf(pwl_v, pwl_t, "PWL", show_pwhl, bear_c)
    f_render_mtf(pmh_v, pmh_t, "PMH", show_pmhl, bull_c)
    f_render_mtf(pml_v, pml_t, "PML", show_pmhl, bear_c)

// ==============================================================================
// 9. LIQUIDITY SWEEP MOTOR
// ==============================================================================
var label[] sweep_objs = array.new_label()

f_add_sweep(float y, bool bull) =>
    c_col = bull ? bull_c : bear_c
    t_col = bull ? bull_c : bear_c
    
    c_lb = label.new(bar_index, y, "", color=color.new(c_col, 20), style=label.style_circle, size=size.tiny)
    t_lb = label.new(bar_index, y, "Liquidity Sweep", color=#00000000, textcolor=t_col, style=bull ? label.style_label_up : label.style_label_down, size=size.small)
    
    array.push(sweep_objs, c_lb), array.push(sweep_objs, t_lb)
    if array.size(sweep_objs) > sweep_n * 2
        label.delete(array.shift(sweep_objs))
        label.delete(array.shift(sweep_objs))

if show_sweep
    bool pdl_sw = show_pdhl and low < pdl_v and close > pdl_v
    bool pdh_sw = show_pdhl and high > pdh_v and close < pdh_v
    bool pwl_sw = show_pwhl and low < pwl_v and close > pwl_v
    bool pwh_sw = show_pwhl and high > pwh_v and close < pwh_v
    bool pml_sw = show_pmhl and low < pml_v and close > pml_v
    bool pmh_sw = show_pmhl and high > pmh_v and close < pmh_v
    
    if pdl_sw or pwl_sw or pml_sw
        f_add_sweep(low, true)
    else if pdh_sw or pwh_sw or pmh_sw
        f_add_sweep(high, false)

// ==============================================================================
// 10. PREMIUM / DISCOUNT ZONES
// ==============================================================================
var box bg_box = na
var box prem_box = na
var box eq_box = na
var box disc_box = na

if show_pd
    float pd_hh = ta.highest(high, pd_len)
    float pd_ll = ta.lowest(low, pd_len)
    
    float prem_bot = 0.95 * pd_hh + 0.05 * pd_ll
    float eq_top   = 0.525 * pd_hh + 0.475 * pd_ll
    float eq_bot   = 0.475 * pd_hh + 0.525 * pd_ll
    float disc_top = 0.95 * pd_ll + 0.05 * pd_hh
    
    if barstate.islast
        if na(bg_box)
            bg_box := box.new(bar_index - pd_len, pd_hh, bar_index + 5, pd_ll, bgcolor=show_pd_bg ? col_pd_bg : na, border_color=na)
            prem_box := box.new(bar_index - pd_len, pd_hh, bar_index + 5, prem_bot, bgcolor=col_prem, border_color=na, text="Premium", text_color=color.new(color.red, 50), text_size=size.small, text_halign=text.align_right)
            eq_box := box.new(bar_index - pd_len, eq_top, bar_index + 5, eq_bot, bgcolor=col_eq, border_color=na, text="Equilibrium", text_color=color.new(color.gray, 50), text_size=size.small, text_halign=text.align_right)
            disc_box := box.new(bar_index - pd_len, disc_top, bar_index + 5, pd_ll, bgcolor=col_disc, border_color=na, text="Discount", text_color=color.new(color.green, 50), text_size=size.small, text_halign=text.align_right)
        else
            box.set_bgcolor(bg_box, show_pd_bg ? col_pd_bg : na)
            box.set_lefttop(bg_box, bar_index - pd_len, pd_hh)
            box.set_rightbottom(bg_box, bar_index + 5, pd_ll)
            
            box.set_lefttop(prem_box, bar_index - pd_len, pd_hh)
            box.set_rightbottom(prem_box, bar_index + 5, prem_bot)
            
            box.set_lefttop(eq_box, bar_index - pd_len, eq_top)
            box.set_rightbottom(eq_box, bar_index + 5, eq_bot)
            
            box.set_lefttop(disc_box, bar_index - pd_len, disc_top)
            box.set_rightbottom(disc_box, bar_index + 5, pd_ll)

// ==============================================================================
// 11. FULL PANEL MOTOR
// ==============================================================================
rsi_v      = ta.rsi(close, 14)
mfi_v      = ta.mfi(close, 14)
tsi_v      = ta.correlation(close, bar_index, 14)
mom_v      = (close - close[10]) / close[10] * 100
vol_v      = (ta.atr(14) / close) * 100
[p, m, adx] = ta.dmi(14, 14)
vol_status = volume > ta.sma(volume, 20) ? "High" : "Normal"
efi_v      = ta.ema((close - close[1]) * volume, 13)
f_arrow(float v, float pv) => v > pv ? " ↑" : v < pv ? " ↓" : ""

price_chg = not na(entry_p) ? ((close - entry_p) / entry_p) * 100 : 0.0
live_rr   = not na(entry_p) and math.abs(entry_p - entry_s) != 0 ? math.abs(close - entry_p) / math.abs(entry_p - entry_s) : 0.0

var string real_pos = panel_pos == "Top Right" ? position.top_right : panel_pos == "Bottom Right" ? position.bottom_right : panel_pos == "Top Left" ? position.top_left : position.bottom_left

if barstate.islast
    ui = table.new(real_pos, 2, 12, bgcolor=color.new(color.black, 40), border_width=1, border_color=neut_c)
    t_s = f_sz(panel_size)
    c_up = bull_c
    c_dn = bear_c
    
    table.cell(ui, 0, 0, "TERMINAL PANEL", text_color=color.white, text_size=t_s)
    table.cell(ui, 1, 0, is_up ? "BULLISH" : "BEARISH", text_color=is_up ? c_up : c_dn, text_size=t_s)
    table.cell(ui, 0, 1, "Price Change", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 1, str.format("{0,number,#.##}%", price_chg), text_color=price_chg >= 0 ? c_up : c_dn, text_size=t_s)
    table.cell(ui, 0, 2, "Live RR", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 2, str.format("{0,number,#.##} RR", live_rr), text_color=color.white, text_size=t_s)
    
    rsi_col = rsi_v > rsi_v[1] ? c_up : rsi_v < rsi_v[1] ? c_dn : color.white
    table.cell(ui, 0, 3, "RSI (14)", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 3, str.format("{0,number,#.##}", rsi_v) + f_arrow(rsi_v, rsi_v[1]), text_color=rsi_col, text_size=t_s)
    mfi_col = mfi_v > mfi_v[1] ? c_up : mfi_v < mfi_v[1] ? c_dn : color.white
    table.cell(ui, 0, 4, "MFI (14)", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 4, str.format("{0,number,#.##}", mfi_v) + f_arrow(mfi_v, mfi_v[1]), text_color=mfi_col, text_size=t_s)
    table.cell(ui, 0, 5, "EFI (Force Index)", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 5, (efi_v >= 0 ? "Inflow" : "Outflow") + f_arrow(efi_v, efi_v[1]), text_color=efi_v >= 0 ? c_up : c_dn, text_size=t_s)
    table.cell(ui, 0, 6, "Momentum (10)", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 6, str.format("{0,number,#.##}%", mom_v) + f_arrow(mom_v, mom_v[1]), text_color=mom_v >= 0 ? c_up : c_dn, text_size=t_s)
    table.cell(ui, 0, 7, "Volatility", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 7, str.format("{0,number,#.##}%", vol_v), text_color=color.white, text_size=t_s)
    table.cell(ui, 0, 8, "ADX", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 8, str.format("{0,number,#.##}", adx) + f_arrow(adx, adx[1]), text_color=adx > 25 ? c_up : neut_c, text_size=t_s)
    table.cell(ui, 0, 9, "Trend Strength (TSI)", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 9, str.format("{0,number,#.##}", tsi_v) + f_arrow(tsi_v, tsi_v[1]), text_color=tsi_v > 0 ? c_up : c_dn, text_size=t_s)
    table.cell(ui, 0, 10, "Volume", text_color=neut_c, text_size=t_s), table.cell(ui, 1, 10, vol_status, text_color=vol_status == "High" ? c_up : neut_c, text_size=t_s)
````
