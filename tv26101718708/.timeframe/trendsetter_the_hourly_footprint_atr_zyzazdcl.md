# Trendsetter : The Hourly Footprint (ATR)

- url: https://www.tradingview.com/script/ZyZAzDCL-Trendsetter-The-Hourly-Footprint-ATR/
- type: indicator
- pine_id: PUB;e5ad539080d44e3ea93ece9e235d410e
- version: 1.0

## Description

Title: Trendsetter : The Hourly Footprint (ATR)

The Concept:
Successful trading requires a plan that adapts to shifting market conditions. The Trendsetter : Hourly Footprint (ATR) is a professional-grade structure tool designed to identify high-probability entries while providing a mathematically sound framework for setup invalidation. It focuses on the "Hourly Footprint"—using the previous hour's close to map out market momentum and technical exits.

Key Features:


The 50% Entry Rule: Automatically identifies the exact middle (retracement) of the previous 1-hour candle as a high-value entry zone.


Volatility-Based Invalidation (ATR): Rather than using arbitrary points, this tool uses a dynamic ATR (Average True Range) calculation to determine where a setup is no longer valid. This ensures your invalidation levels are always in sync with the market's current "breath".


Adjustable Multipliers: Choose between 0.5 (Aggressive), 1.0 (Standard), or 1.5 (Conservative) to match your personal strategy and risk tolerance.


Fibonacci Profit Targets: Precision exit levels calculated mathematically from the previous H1 range:


TP1 (161.8%): Initial target for locking in gains.


TP2 (222.0%): Optimized "runner" target for high-momentum extensions.


MTF Stability: The logic is locked to the H1 timeframe, providing a consistent anchor whether you are viewing a 1-minute, 5-minute, or 15-minute chart.

How to Use:


Spot the Signal: Identify the bias via the Green (▲) or Red (▼) triangle signals.


Define Invalidation: Set your ATR Multiplier to define where the market structure is technically broken for that hour.


Execute & Exit: Place entries at the 50% "Entry Point" and use the automated Fibonacci lines for objective profit-taking.

⚠️ Strategy Limitations & Caution:
This tool is a visual structure aid, not an automated signal service. The bias is dependent on pure continuation—if the market is in a "chop" phase and H1 candles are alternating directions, the indicator will flip its bias accordingly. Always use this in conjunction with a broader trading plan and strict risk management.

## Source Code

````pine
//@version=5
indicator("Trendsetter : The Hourly Footprint (ATR)", overlay=true, max_lines_count=100, max_labels_count=100)

// ==========================================
// INPUTS
// ==========================================
grpGeneral = "Trade Settings"
// Removed sl_points and added ATR Multiplier options
atr_mult = input.float(1.0, title="ATR Multiplier", options=[0.5, 1.0, 1.5], group=grpGeneral, tooltip="Sets SL based on H1 Volatility. 1.0 is standard.")
atr_len  = input.int(14, title="ATR Length", group=grpGeneral)

showExtraEntries = input.bool(false, title="Enable 3-Tier Entries", group=grpGeneral)
showPrevSetup    = input.bool(true, title="Show Previous H1 Setup", group=grpGeneral)
tp2_ratio        = input.float(2.22, title="TP2 Fibonacci Ratio", group=grpGeneral) // Updated to your 222% preference

// ==========================================
// DATA FETCHING (H1 MTF Logic)
// ==========================================
// Fetch H1 OHLCV and ATR
[h1_o, h1_h, h1_l, h1_c, h1_t, h1_atr] = request.security(syminfo.tickerid, "60", [open[1], high[1], low[1], close[1], time[1], ta.atr(atr_len)[1]], lookahead=barmerge.lookahead_on)
[ph1_o, ph1_h, ph1_l, ph1_c, ph1_t, ph1_atr] = request.security(syminfo.tickerid, "60", [open[2], high[2], low[2], close[2], time[2], ta.atr(atr_len)[2]], lookahead=barmerge.lookahead_on)

// ==========================================
// CALCULATIONS (ATR-Based Stop Loss)
// ==========================================
// SL is calculated as: Low - (ATR * Mult) for Longs, or High + (ATR * Mult) for Shorts
calc_levels(o, h, l, c, atr) =>
    dir = c > o ? 1 : c < o ? -1 : 0
    rng = h - l
    mid = math.avg(h, l)
    risky = dir == 1 ? h : l
    safe  = dir == 1 ? l : h
    sl    = dir == 1 ? l - (atr * atr_mult) : h + (atr * atr_mult)
    tp1   = dir == 1 ? l + (rng * 1.618) : h - (rng * 1.618)
    tp2   = dir == 1 ? l + (rng * tp2_ratio) : h - (rng * tp2_ratio)
    [dir, mid, risky, safe, sl, tp1, tp2]

[aDir, aMid, aRisky, aSafe, aSL, aTP1, aTP2] = calc_levels(h1_o, h1_h, h1_l, h1_c, h1_atr)
[pDir, pMid, pRisky, pSafe, pSL, pTP1, pTP2] = calc_levels(ph1_o, ph1_h, ph1_l, ph1_c, ph1_atr)

// ==========================================
// STYLING & DRAWING (Time-Based MTF)
// ==========================================
color c_line_entry = color.gray
color c_line_target = color.new(color.gray, 30) 
color c_txt_entry = color.gray
color c_txt_sl = color.red
color c_txt_tp = color.lime

var line l_e1 = na, var line l_sl = na, var line l_tp1 = na, var line l_tp2 = na
var label lb_e1 = na, var label lb_sl = na, var label lb_tp1 = na, var label lb_tp2 = na
var label lb_aTri = na

if barstate.islast
    line.delete(l_e1), line.delete(l_sl), line.delete(l_tp1), line.delete(l_tp2)
    label.delete(lb_e1), label.delete(lb_sl), label.delete(lb_tp1), label.delete(lb_tp2)
    label.delete(lb_aTri)

    end_t = time + (time - time[1]) * 10

    if aDir != 0
        l_e1 := line.new(h1_t, aMid, end_t, aMid, xloc=xloc.bar_time, color=c_line_entry, width=2)
        lb_e1 := label.new(end_t, aMid, "Entry (50%)", xloc=xloc.bar_time, textcolor=c_txt_entry, style=label.style_none, size=size.tiny)
        
        l_sl := line.new(h1_t, aSL, end_t, aSL, xloc=xloc.bar_time, color=c_line_target, style=line.style_dotted)
        lb_sl := label.new(end_t, aSL, "SL (ATR)", xloc=xloc.bar_time, textcolor=c_txt_sl, style=label.style_none, size=size.tiny)
        
        l_tp1 := line.new(h1_t, aTP1, end_t, aTP1, xloc=xloc.bar_time, color=c_line_target, style=line.style_dotted)
        lb_tp1 := label.new(end_t, aTP1, "TP1 (161.8)", xloc=xloc.bar_time, textcolor=c_txt_tp, style=label.style_none, size=size.tiny)
        
        l_tp2 := line.new(h1_t, aTP2, end_t, aTP2, xloc=xloc.bar_time, color=c_line_target, style=line.style_dotted)
        lb_tp2 := label.new(end_t, aTP2, "TP2 (222.0)", xloc=xloc.bar_time, textcolor=c_txt_tp, style=label.style_none, size=size.tiny)
        
        lb_aTri := label.new(h1_t, na, aDir == 1 ? "▲" : "▼", xloc=xloc.bar_time, yloc=aDir == 1 ? yloc.belowbar : yloc.abovebar, textcolor=aDir == 1 ? color.lime : color.red, style=label.style_none, size=size.small)
````
