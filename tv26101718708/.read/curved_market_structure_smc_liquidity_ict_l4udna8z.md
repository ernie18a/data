# Curved Market Structure & SMC Liquidity [ ICT ]

- url: https://www.tradingview.com/script/l4UDNa8z-Curved-Market-Structure-SMC-Liquidity-ICT/
- type: indicator
- pine_id: PUB;464ef8642de64f8586be90ed08d31ab1
- version: 1.0

## Description

================================================================================
          CURVED MARKET STRUCTURE & SMC LIQUIDITY [ ICT ]
================================================================================

Curved Market Structure and SMC Liquidity ICT is an all-in-one institutional trading suite designed for precision analysis across Crypto, Forex, Commodities, and Stocks. It merges smooth mathematical volatility curves with automated Smart Money Concepts (SMC) structure, body glow momentum candles, dynamic equilibrium range tracking, and a visible right-side volume profile.

--------------------------------------------------------------------------------
1. CORE FEATURES & MECHANICS
--------------------------------------------------------------------------------

• Dynamic Smooth Curve Bands
  Uses double-exponential smoothing and standard deviation to generate adaptive high-probability trend curves. The lower curve marks an institutional demand/liquidity sweep zone, while the upper curve identifies overextended supply areas.

• Institutional Structure Mapping (BOS & CHoCH)
  Automatically tracks key swing highs and lows. Upon structure breakout, it draws precise Break of Structure (BOS) or Change of Character (CHoCH) lines starting exactly from the broken swing level to the breakout candle.

• Filtered Sweep Signals & Cooldown Engine
  Liquidity sweep signals require candle close confirmation and directional momentum alignment. An internal cooldown counter suppresses repetitive signals during tight consolidation phases.

• Body Glow Candle Dynamics
  Recolors candle bodies based on directional strength and candle range. Active expansion bars highlight bright green or red, while low-volatility range candles render in neutral gray.

• Dynamic 0.5 Equilibrium & Confluence Zones
  Continuously projects the 0.5 discount/premium equilibrium midpoint of the active swing range, alongside borderless demand and supply confluence zones.

• High Visibility Volume Profile
  Renders a clean volume profile histogram on the right side of the chart to reveal High Volume Nodes (HVN) and Low Volume Nodes (LVN) over the selected lookback range.

--------------------------------------------------------------------------------
2. HOW TO USE FOR TRADING
--------------------------------------------------------------------------------

1. Determining Market Bias
   Check whether current price action is trading above or below the 0.5 Equilibrium level and observe the direction of the latest BOS or CHoCH structural break.

2. Bullish Entry Rules
   Wait for price to sweep or touch the lower green curve band. Enter long upon receiving a confirmed Buy Sweep signal accompanied by a green Body Glow candle near the demand zone.

3. Bearish Entry Rules
   Wait for price to sweep or touch the upper red curve band. Enter short upon receiving a confirmed Sell Sweep signal accompanied by a red Body Glow candle near the supply zone.

4. Profit Targets & Risk Management
   Set primary take-profit targets at the 0.5 Equilibrium line and secondary targets at the opposite curve band or major structural swing levels.

--------------------------------------------------------------------------------
3. SCALPING & TIMEFRAME GUIDANCE
--------------------------------------------------------------------------------

• Lower Timeframe Scalping (1m, 5m, 15m)
  Lower the Swing Sensitivity setting to 3 or 5 for rapid structural tracking. Use right-side volume profile peaks to trade reversals back toward low-volume gaps.

• Higher Timeframe Bias (1H, 4H, Daily)
  Use the 0.5 Equilibrium line to divide the market into Premium (favorable for shorts) and Discount (favorable for longs) zones before taking trades.

--------------------------------------------------------------------------------
4. SETTINGS BREAKDOWN
--------------------------------------------------------------------------------

• Curve Smoothing Factor: Controls band smoothness and responsiveness to price.
• Curve Multiplier: Adjusts upper/lower curve expansion based on market volatility.
• Signal Cooldown: Sets the required bar gap between signals to filter noise.
• Consolidation Threshold: Sets the body-to-range ratio for identifying neutral gray range candles.
• Swing Sensitivity: Sets pivot lookback length for validating swing highs and lows.
• Text Placement Settings: Customizes horizontal and vertical label alignments.
• Profile Lookback Range: Defines historical bar depth for the volume profile histogram.

--------------------------------------------------------------------------------
5. THINGS TO AVOID
--------------------------------------------------------------------------------

• Do not trade signals against the higher-timeframe trend direction.
• Avoid taking Buy signals during an active bearish BOS sequence without a fresh CHoCH confirmation.
• Avoid entering trades during major economic news releases or low-liquidity market sessions.
• Do not rely on printed shapes in isolation. Always combine signals with SMC structure, 0.5 Equilibrium levels, and volume confluences.

--------------------------------------------------------------------------------
DISCLAIMER
--------------------------------------------------------------------------------

This script is built exclusively for educational and chart visualization purposes. Past performance of visual signals does not guarantee future market results. Always manage risk responsibly.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NOVA_STRATIGY

//@version=6
indicator("Curved Market Structure & SMC Liquidity [ ICT ]", "Curved SMC Liquidity [ICT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ----------------------------------------------------------------------------------------------
// 1. INPUTS & CONFIGURATION PANEL
// ----------------------------------------------------------------------------------------------
g_curve  = "===== REAL CURVED SMOOTH BANDS ====="
show_crv = input.bool(true, "Show Smooth Curved Bands", group=g_curve)
crv_len  = input.int(34, "Curve Smoothing Factor", minval=10, maxval=200, group=g_curve)
crv_mult = input.float(2.5, "Curve Multiplier", minval=0.5, step=0.1, group=g_curve)
c_crv_u  = input.color(#ff1744, "Upper Curve Color", group=g_curve)
c_crv_l  = input.color(#00e676, "Lower Curve Color", group=g_curve)
crv_w    = input.int(2, "Curve Line Width", minval=1, maxval=4, group=g_curve)

g_sig    = "===== HIGH WIN-RATE SIGNAL ENGINE ====="
show_sig = input.bool(true, "Show Signals (Filtered)", group=g_sig)
sig_type = input.string("Triangle", "Signal Shape", options=["Triangle", "Dot"], group=g_sig)
sig_cd   = input.int(10, "Signal Cooldown (Candles)", minval=1, maxval=50, group=g_sig)
c_buy_s  = input.color(#00e676, "Buy Signal Color", group=g_sig)
c_sell_s = input.color(#ff1744, "Sell Signal Color", group=g_sig)

g_glow   = "===== BODY GLOW CANDLE ENGINE ====="
show_glow= input.bool(true, "Enable Body Glow Candles", group=g_glow)
glow_sens= input.float(0.35, "Consolidation Threshold (0.1 - 0.9)", minval=0.05, maxval=0.9, step=0.05, group=g_glow)
c_bull_g = input.color(#00e676, "Bullish Body Color", group=g_glow)
c_bear_g = input.color(#ff1744, "Bearish Body Color", group=g_glow)
c_cons_g = input.color(#9e9e9e, "Consolidation Body Color", group=g_glow)

g_smc    = "===== SMC STRUCTURE (BOS & CHOCH) ====="
show_smc = input.bool(true, "Show BOS / CHoCH", group=g_smc)
smc_sens = input.int(7, "Swing Sensitivity", minval=2, maxval=50, group=g_smc)
st_style = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=g_smc)
st_align = input.string("Right", "Text Horizontal Alignment", options=["Left", "Right"], group=g_smc)
st_vpos  = input.string("Top", "Text Vertical Position", options=["Top", "Middle", "Bottom"], group=g_smc)
st_sz    = input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=g_smc)
c_bos    = input.color(#00e676, "BOS Color", group=g_smc)
c_choch  = input.color(#ff1744, "CHoCH Color", group=g_smc)

g_eq     = "===== DYNAMIC EQUILIBRIUM LEVEL (0.5) ====="
show_eq  = input.bool(true, "Show 0.5 Equilibrium Line", group=g_eq)
eq_len   = input.int(30, "Equilibrium Swing Range", minval=10, maxval=200, group=g_eq)
eq_w     = input.int(2, "Line Width", minval=1, maxval=4, group=g_eq)
c_eq     = input.color(#ffd700, "Equilibrium Color", group=g_eq)

g_zone   = "===== CONFLUENCE ZONES (BORDERLESS) ====="
show_z   = input.bool(true, "Display Support / Resistance Zones", group=g_zone)
z_trans  = input.int(85, "Zone Transparency", minval=10, maxval=95, group=g_zone)
txt_z_sup= input.string("Demand / Support Zone", "Support Label", group=g_zone)
txt_z_res= input.string("Supply / Resistance Zone", "Resistance Label", group=g_zone)
c_z_sup  = input.color(#00e676, "Support Color", group=g_zone)
c_z_res  = input.color(#ff1744, "Resistance Color", group=g_zone)
z_txt_sz = input.string("Small", "Zone Text Size", options=["Tiny", "Small", "Normal"], group=g_zone)

g_vp     = "===== HIGH VISIBILITY VOLUME PROFILE ====="
show_vp  = input.bool(true, "Show Visible Right-Side Volume Profile", group=g_vp)
vp_len   = input.int(80, "Profile Lookback Range", minval=20, maxval=300, group=g_vp)
c_vp     = input.color(#00b0ff, "Profile Color (Bright Blue)", group=g_vp)
vp_trans = input.int(60, "Profile Bar Transparency", minval=10, maxval=90, group=g_vp)

// ----------------------------------------------------------------------------------------------
// 2. REAL CURVED SMOOTH BANDS GENERATOR
// ----------------------------------------------------------------------------------------------
smooth_base = ta.ema(ta.ema(close, crv_len), math.round(crv_len / 2))
smooth_dev  = ta.ema(ta.stdev(close, crv_len), crv_len) * crv_mult

u_curve = smooth_base + smooth_dev
l_curve = smooth_base - smooth_dev

plot(show_crv ? u_curve : na, "Upper Smooth Curve", color=c_crv_u, linewidth=crv_w)
plot(show_crv ? l_curve : na, "Lower Smooth Curve", color=c_crv_l, linewidth=crv_w)

// ----------------------------------------------------------------------------------------------
// 3. CANDLE BODY GLOW LOGIC
// ----------------------------------------------------------------------------------------------
float range_total = high - low
float body_pct = range_total > 0 ? math.abs(close - open) / range_total : 0.0
bool is_consolidation = body_pct < glow_sens

color body_col = is_consolidation ? c_cons_g : (close > open ? c_bull_g : c_bear_g)
plotcandle(open, high, low, close, "Glow Body Candle", color=show_glow ? body_col : na, wickcolor=na, bordercolor=na)

// ----------------------------------------------------------------------------------------------
// 4. ACCURATE FILTERED SIGNALS WITH COOLDOWN
// ----------------------------------------------------------------------------------------------
var int last_buy_bar = -999
var int last_sell_bar = -999

rsi = ta.rsi(close, 14)
bool buy_momentum = rsi > 45 and close > open
bool sell_momentum = rsi < 55 and close < open

bool raw_buy  = (low[1] <= l_curve[1] or low <= l_curve) and buy_momentum
bool raw_sell = (high[1] >= u_curve[1] or high >= u_curve) and sell_momentum

bool confirmed_buy  = raw_buy and (bar_index - last_buy_bar >= sig_cd)
bool confirmed_sell = raw_sell and (bar_index - last_sell_bar >= sig_cd)

if confirmed_buy
    last_buy_bar := bar_index

if confirmed_sell
    last_sell_bar := bar_index

plotshape(show_sig and confirmed_buy, title="Confirmed Buy Signal", style=sig_type == "Triangle" ? shape.triangleup : shape.circle, location=location.belowbar, color=c_buy_s, size=size.small)
plotshape(show_sig and confirmed_sell, title="Confirmed Sell Signal", style=sig_type == "Triangle" ? shape.triangledown : shape.circle, location=location.abovebar, color=c_sell_s, size=size.small)

// ----------------------------------------------------------------------------------------------
// 5. EQUILIBRIUM & ZONES
// ----------------------------------------------------------------------------------------------
float h_eq = ta.highest(high, eq_len)
float l_eq = ta.lowest(low, eq_len)
float eq_val = (h_eq + l_eq) / 2.0

var line line_eq = na
var label lbl_eq = na

if show_eq and barstate.islast
    line.delete(line_eq)
    label.delete(lbl_eq)
    line_eq := line.new(bar_index - eq_len, eq_val, bar_index + 15, eq_val, color=c_eq, width=eq_w, style=line.style_dashed)
    lbl_eq  := label.new(bar_index + 15, eq_val, "0.5 EQUILIBRIUM", color=color.new(#ffffff, 100), textcolor=c_eq, style=label.style_label_left, size=size.small)

var box box_res = na
var box box_sup = na

string z_sz = z_txt_sz == "Tiny" ? size.tiny : z_txt_sz == "Small" ? size.small : size.normal

if show_z and barstate.islast
    box.delete(box_res)
    box.delete(box_sup)
    
    float res_top = h_eq
    float res_bot = h_eq - ((h_eq - eq_val) * 0.20)
    
    float sup_bot = l_eq
    float sup_top = l_eq + ((eq_val - l_eq) * 0.20)
    
    box_res := box.new(bar_index - math.round(eq_len * 0.5), res_top, bar_index + 12, res_bot, border_color=na, bgcolor=color.new(c_z_res, z_trans), text=txt_z_res, text_color=c_z_res, text_size=z_sz, text_halign=text.align_right)
    box_sup := box.new(bar_index - math.round(eq_len * 0.5), sup_top, bar_index + 12, sup_bot, border_color=na, bgcolor=color.new(c_z_sup, z_trans), text=txt_z_sup, text_color=c_z_sup, text_size=z_sz, text_halign=text.align_right)

// ----------------------------------------------------------------------------------------------
// 6. ACCURATE SMC STRUCTURE (WITH VERTICAL POSITIONING)
// ----------------------------------------------------------------------------------------------
ph = ta.pivothigh(high, smc_sens, smc_sens)
pl = ta.pivotlow(low, smc_sens, smc_sens)

var float last_ph_val = na
var int   last_ph_idx = na
var float last_pl_val = na
var int   last_pl_idx = na
var int   trend_dir   = 0

if not na(ph)
    last_ph_val := ph
    last_ph_idx := bar_index - smc_sens

if not na(pl)
    last_pl_val := pl
    last_pl_idx := bar_index - smc_sens

string l_style_val = st_style == "Dashed" ? line.style_dashed : st_style == "Dotted" ? line.style_dotted : line.style_solid
string sz_val      = st_sz == "Tiny" ? size.tiny : st_sz == "Small" ? size.small : size.normal

string v_lbl_style = label.style_label_left
if st_align == "Left"
    v_lbl_style := st_vpos == "Top" ? label.style_label_down : st_vpos == "Bottom" ? label.style_label_up : label.style_label_right
else
    v_lbl_style := st_vpos == "Top" ? label.style_label_down : st_vpos == "Bottom" ? label.style_label_up : label.style_label_left

if show_smc and not na(last_ph_val) and ta.crossover(close, last_ph_val)
    string st_type = trend_dir == -1 ? "CHoCH" : "BOS"
    color col_st   = trend_dir == -1 ? c_choch : c_bos
    trend_dir     := 1
    
    line.new(last_ph_idx, last_ph_val, bar_index, last_ph_val, color=col_st, width=1, style=l_style_val)
    label.new(st_align == "Left" ? last_ph_idx : bar_index, last_ph_val, st_type, color=color.new(#ffffff, 100), textcolor=col_st, style=v_lbl_style, size=sz_val)
    last_ph_val := na

if show_smc and not na(last_pl_val) and ta.crossunder(close, last_pl_val)
    string st_type = trend_dir == 1 ? "CHoCH" : "BOS"
    color col_st   = trend_dir == 1 ? c_choch : c_bos
    trend_dir     := -1
    
    line.new(last_pl_idx, last_pl_val, bar_index, last_pl_val, color=col_st, width=1, style=l_style_val)
    label.new(st_align == "Left" ? last_pl_idx : bar_index, last_pl_val, st_type, color=color.new(#ffffff, 100), textcolor=col_st, style=v_lbl_style, size=sz_val)
    last_pl_val := na

// ----------------------------------------------------------------------------------------------
// 7. BRIGHT RIGHT-SIDE VOLUME PROFILE
// ----------------------------------------------------------------------------------------------
var box[] vp_bars = array.new_box()

if show_vp and barstate.islast
    if array.size(vp_bars) > 0
        for i = 0 to array.size(vp_bars) - 1
            box.delete(array.get(vp_bars, i))
        array.clear(vp_bars)
        
    float vp_h = ta.highest(high, vp_len)
    float vp_l = ta.lowest(low, vp_len)
    int   bins = 20
    float step = (vp_h - vp_l) / bins
    
    float[] vols = array.new_float(bins, 0.0)
    for i = 0 to vp_len - 1
        for b = 0 to bins - 1
            float b_l = vp_l + (b * step)
            float b_h = b_l + step
            if close[i] >= b_l and close[i] <= b_h
                array.set(vols, b, array.get(vols, b) + volume[i])
                
    float max_v = array.max(vols)
    if max_v > 0
        for b = 0 to bins - 1
            float b_l = vp_l + (b * step)
            float b_h = b_l + step
            float val = array.get(vols, b)
            int w     = math.round((val / max_v) * 30)
            if w > 0
                box bx = box.new(bar_index + 3, b_h, bar_index + 3 + w, b_l, border_color=color.new(c_vp, 40), bgcolor=color.new(c_vp, vp_trans))
                array.push(vp_bars, bx)
````
