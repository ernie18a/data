# Trendsetter : The Hourly Footprint (MTF)

- url: https://www.tradingview.com/script/9Q2nEGnk-Trendsetter-The-Hourly-Footprint-MTF/
- type: indicator
- pine_id: PUB;2ed6c866fc0d403a932255740290583d
- version: 1.0

## Description

Title: Trendsetter : The Hourly Footprint

The Concept:
Successful trading focuses on identifying high-probability market structure. The Trendsetter : Hourly Footprint is built on the core truth that the previous hour's close provides the best "map" for the next hour's opportunity.

Key Features:

The 50% Entry Rule: Automatically calculates the exact middle of the previous 1-hour candle as a high-value retracement entry zone.

Fibonacci Profit Targets: Uses mathematical extensions (TP1 at 161.8% and TP2 at 222%) to find likely market exhaustion points.

MTF Stability: Locked to the H1 timeframe to ensure consistent levels across any chart (1m, 5m, 15m).

⚠️ Strategy Limitations & Caution:
This tool is a visual structure aid, not an automated signal service. Traders must use discretion based on the following logic:

Pure Continuation Bias: The indicator's bias is 100% dependent on the previous candle's close.


Reversal Risk: If a bearish candle is merely a deep retracement before a move higher, the script will show a "Sell" setup even if the larger trend remains bullish.

Market Chop: In ranging markets where H1 candles alternate between bullish and bearish (chop), the indicator will flip its bias accordingly. Always use this in conjunction with a broader trading plan and strict risk management.

## Source Code

````pine
//@version=5
indicator("Trendsetter : The Hourly Footprint (MTF)", overlay=true, max_lines_count=100, max_labels_count=100)

// ==========================================
// INPUTS
// ==========================================
grpGeneral = "Trade Settings"
sl_points = input.float(5.0, title="Stop Loss Buffer (Points)", group=grpGeneral, tooltip="Distance in points from the High/Low. E.g., 5.0 for Micro Gold.")
showExtraEntries = input.bool(false, title="Enable 3-Tier Entries", group=grpGeneral, tooltip="Adds the High/Low entry lines alongside the 50% entry.")
showPrevSetup = input.bool(true, title="Show Previous H1 Setup", group=grpGeneral, tooltip="Toggles the visibility of the setup from the prior H1 candle.")
tp2_ratio = input.float(2.40, title="TP2 Fibonacci Ratio", group=grpGeneral, tooltip="Defaults to 2.40 (240%).")

// ==========================================
// COLOR PALETTE (The "Elite" Aesthetic)
// ==========================================
color c_line_entry  = color.gray
color c_line_target = color.new(color.gray, 30) 
color c_txt_entry   = color.gray
color c_txt_sl      = color.red
color c_txt_tp      = color.lime

color p_line_entry  = color.new(color.gray, 60)
color p_line_target = color.new(color.gray, 70) 
color p_txt_entry   = color.new(color.gray, 60)
color p_txt_sl      = color.new(color.red, 60)
color p_txt_tp      = color.new(color.lime, 60)

// ==========================================
// DATA FETCHING (H1 MTF Logic)
// ==========================================
// Fetch the last two completed H1 candles to ensure data is "fixed"
[h1_o, h1_h, h1_l, h1_c, h1_t] = request.security(syminfo.tickerid, "60", [open[1], high[1], low[1], close[1], time[1]], lookahead=barmerge.lookahead_on)
[ph1_o, ph1_h, ph1_l, ph1_c, ph1_t] = request.security(syminfo.tickerid, "60", [open[2], high[2], low[2], close[2], time[2]], lookahead=barmerge.lookahead_on)

// ==========================================
// CALCULATIONS (Function for Reusability)
// ==========================================
calc_levels(o, h, l, c) =>
    dir = c > o ? 1 : c < o ? -1 : 0
    rng = h - l
    mid = math.avg(h, l)
    risky = dir == 1 ? h : l
    safe  = dir == 1 ? l : h
    sl    = dir == 1 ? l - sl_points : h + sl_points
    tp1   = dir == 1 ? l + (rng * 1.618) : h - (rng * 1.618)
    tp2   = dir == 1 ? l + (rng * tp2_ratio) : h - (rng * tp2_ratio)
    [dir, mid, risky, safe, sl, tp1, tp2]

[aDir, aMid, aRisky, aSafe, aSL, aTP1, aTP2] = calc_levels(h1_o, h1_h, h1_l, h1_c)
[pDir, pMid, pRisky, pSafe, pSL, pTP1, pTP2] = calc_levels(ph1_o, ph1_h, ph1_l, ph1_c)

// ==========================================
// DRAWING OBJECTS (Time-Based for MTF)
// ==========================================
var line l_e1 = na, var line l_e2 = na, var line l_e3 = na
var line l_sl = na, var line l_tp1 = na, var line l_tp2 = na
var label lb_e1 = na, var label lb_e2 = na, var label lb_e3 = na
var label lb_sl = na, var label lb_tp1 = na, var label lb_tp2 = na
var label lb_aTri = na

var line p_e1 = na, var line p_e2 = na, var line p_e3 = na
var line p_sl = na, var line p_tp1 = na, var line p_tp2 = na
var label pb_e1 = na, var label pb_e2 = na, var label pb_e3 = na
var label pb_sl = na, var label pb_tp1 = na, var label pb_tp2 = na
var label lb_pTri = na

// Update logic - Run every bar to keep lines extended to the right
if barstate.islast
    // Clear previous drawings
    line.delete(l_e1), line.delete(l_e2), line.delete(l_e3), line.delete(l_sl), line.delete(l_tp1), line.delete(l_tp2)
    label.delete(lb_e1), label.delete(lb_e2), label.delete(lb_e3), label.delete(lb_sl), label.delete(lb_tp1), label.delete(lb_tp2)
    label.delete(lb_aTri)
    
    line.delete(p_e1), line.delete(p_e2), line.delete(p_e3), line.delete(p_sl), line.delete(p_tp1), line.delete(p_tp2)
    label.delete(pb_e1), label.delete(pb_e2), label.delete(pb_e3), label.delete(pb_sl), label.delete(pb_tp1), label.delete(pb_tp2)
    label.delete(lb_pTri)

    // X-Coordinates (End 5 bars in the future of current timeframe)
    end_t = time + (time - time[1]) * 10

    // Draw Active
    if aDir != 0
        l_e1 := line.new(h1_t, aMid, end_t, aMid, xloc=xloc.bar_time, color=c_line_entry, width=2)
        lb_e1 := label.new(end_t, aMid, "Entry Point", xloc=xloc.bar_time, textcolor=c_txt_entry, style=label.style_none, size=size.tiny)
        
        if showExtraEntries
            l_e2 := line.new(h1_t, aRisky, end_t, aRisky, xloc=xloc.bar_time, color=c_line_entry, width=2)
            lb_e2 := label.new(end_t, aRisky, "Entry Point", xloc=xloc.bar_time, textcolor=c_txt_entry, style=label.style_none, size=size.tiny)
            l_e3 := line.new(h1_t, aSafe, end_t, aSafe, xloc=xloc.bar_time, color=c_line_entry, width=2)
            lb_e3 := label.new(end_t, aSafe, "Entry Point", xloc=xloc.bar_time, textcolor=c_txt_entry, style=label.style_none, size=size.tiny)

        l_sl := line.new(h1_t, aSL, end_t, aSL, xloc=xloc.bar_time, color=c_line_target, style=line.style_dotted)
        lb_sl := label.new(end_t, aSL, "SL", xloc=xloc.bar_time, textcolor=c_txt_sl, style=label.style_none, size=size.tiny)
        l_tp1 := line.new(h1_t, aTP1, end_t, aTP1, xloc=xloc.bar_time, color=c_line_target, style=line.style_dotted)
        lb_tp1 := label.new(end_t, aTP1, "TP1", xloc=xloc.bar_time, textcolor=c_txt_tp, style=label.style_none, size=size.tiny)
        l_tp2 := line.new(h1_t, aTP2, end_t, aTP2, xloc=xloc.bar_time, color=c_line_target, style=line.style_dotted)
        lb_tp2 := label.new(end_t, aTP2, "TP2", xloc=xloc.bar_time, textcolor=c_txt_tp, style=label.style_none, size=size.tiny)
        
        lb_aTri := label.new(h1_t, na, aDir == 1 ? "▲" : "▼", xloc=xloc.bar_time, yloc=aDir == 1 ? yloc.belowbar : yloc.abovebar, textcolor=aDir == 1 ? color.lime : color.red, style=label.style_none, size=size.small)

    // Draw Previous
    if showPrevSetup and pDir != 0
        p_e1 := line.new(ph1_t, pMid, h1_t, pMid, xloc=xloc.bar_time, color=p_line_entry, width=1)
        pb_e1 := label.new(h1_t, pMid, "Prev Entry", xloc=xloc.bar_time, textcolor=p_txt_entry, style=label.style_none, size=size.tiny)
        
        if showExtraEntries
            p_e2 := line.new(ph1_t, pRisky, h1_t, pRisky, xloc=xloc.bar_time, color=p_line_entry, width=1)
            p_e3 := line.new(ph1_t, pSafe, h1_t, pSafe, xloc=xloc.bar_time, color=p_line_entry, width=1)

        p_sl := line.new(ph1_t, pSL, h1_t, pSL, xloc=xloc.bar_time, color=p_line_target, style=line.style_dotted)
        p_tp1 := line.new(ph1_t, pTP1, h1_t, pTP1, xloc=xloc.bar_time, color=p_line_target, style=line.style_dotted)
        p_tp2 := line.new(ph1_t, pTP2, h1_t, pTP2, xloc=xloc.bar_time, color=p_line_target, style=line.style_dotted)
        
        lb_pTri := label.new(ph1_t, na, pDir == 1 ? "▲" : "▼", xloc=xloc.bar_time, yloc=pDir == 1 ? yloc.belowbar : yloc.abovebar, textcolor=pDir == 1 ? color.new(color.lime, 50) : color.new(color.red, 50), style=label.style_none, size=size.small)
````
