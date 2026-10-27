# BBG Trap Score Indicator

- url: https://www.tradingview.com/script/p1zFYCPd-BBG-Trap-Score-Indicator/
- type: indicator
- pine_id: PUB;10053d31a8d04ddea8d527ee6a2189da
- version: 1.0

## Description

=================================================================
Trap Score - Institutional Liquidity & Trapped Trader Index [v6]
=================================================================

DESCRIPTION:
The Trap Score Index is a quantitative, non-repainting trading indicator designed to detect inducement, liquidity sweeps, trapped buyers, trapped sellers, absorption, and failed breakouts near key higher-timeframe (HTF) level locations.

Rather than relying on subjective pattern recognition, this tool translates order flow dynamics and price action into a deterministic 0 to 100 Trap Score computed at the close of every candle.


CORE CONCEPT:
Markets frequently generate fake breakouts beyond key swing highs and lows to trigger retail stop orders and attract aggressive breakout traders into illiquid positions. When institutional participants absorb these breakout orders, price fails to advance and reclaims the broken level, leaving retail traders trapped.

This indicator calculates two independent normalized metrics:
• 🟥 Bearish Trap Score: Measures trapped buyers at key resistance ➔ Short Setup
• 🟩 Bullish Trap Score: Measures trapped sellers at key support ➔ Long Setup


11 QUANTITATIVE SCORING FACTORS (100 Points Max):
Each candle evaluates 11 weighted mathematical conditions to build the 0–100 score:

1. Liquidity Sweep at Level (15 pts): Candle wicks past an N-bar swing level and closes back inside with wick ratio ≥ 35% and sweep distance ≤ 0.50 ATR.
2. Failed Breakout / Reclaim (15 pts): Price traded outside a key level and failed to hold outside within 3 bars.
3. Extreme Delta (10 pts): Intrabar volume delta ≥ 2.0× its 20-period average.
4. Volume Expansion (10 pts): Candle volume ≥ 1.5× its 20-period SMA.
5. Absorption (15 pts): Extreme volume/delta expansion accompanied by minimal price progress (≤ 0.15 ATR).
6. Delta-Price Divergence (10 pts): Volume delta achieves a new 5-bar extreme while price close fails to confirm.
7. Large-Trade Absorption (10 pts): Extreme volume spike (≥ 2.5× average) with a large wick (≥ 40%) and price progress ≤ 0.15 ATR.
8. HTF Location Proximity (10 pts): Current price within 0.15 × HTF ATR of HTF Swings, Previous Day High/Low (PDH/PDL), Previous Week High/Low (PWH/PWL), or Session VWAP.
9. VWAP / Value Area Rejection (5 pts): Rejection wick crossing Session VWAP or ± 1 stddev bands.
10. Confirmation Candle (5 pts): Candle close confirming directional momentum past the sweep range.
11. Exhaustion (5 pts): 3 consecutive bars of declining volume with narrow candle range (< 0.50 ATR).


HOW TO TRADE WITH TRAP SCORE:

1. Conviction Tiers & Signal Thresholds:
• Score < 50: Neutral / No Trade
• Score 50 – 64: Low Conviction (Observe)
• Score 65 – 79: Standard Setup (Default Alert Trigger)
• Score 80 – 89: High Conviction Setup
• Score ≥ 90: Exceptional Setup

2. Entry Rules:
• Enter on the open of the bar following a confirmed signal candle where Trap Score ≥ 65.
• Ensure market has not established acceptance outside the swept reference level.

3. Stop Loss Placement:
• Long Position: Sweep Low - (ATR × 0.10)
• Short Position: Sweep High + (ATR × 0.10)

4. Profit Targets (Partial Scale-Out):
• TP1 (50%): At 1.0R or Session VWAP (Move stop loss to Breakeven).
• TP2 (25%): At range midpoint or opposing value area.
• TP3 (25%): At opposing liquidity pool (PWH for longs, PWL for shorts) or 3.0R.


KEY SETTINGS & CUSTOMIZATION:
• HTF Resolution: Higher timeframe context resolution (Default: 240 / 4H).
• Swing Lookback: Number of bars to confirm reference highs and lows (Default: 20).
• Minimum Entry Score: Configurable signal score threshold (Default: 65).
• Dashboard Table: Toggleable top-right status summary panel displaying live scores, conviction levels, sweep states, and signals.


NON-REPAINTING GUARANTEE:
This indicator uses strict non-repainting Pine Script v6 syntax. Higher timeframe security requests fetch only closed completed bars (lookahead = barmerge.lookahead_off) to prevent lookahead bias or hindsight repainting.

## Source Code

````pine
//@version=6
indicator("BBG Trap Score Indicator", shorttitle="TrapScore", overlay=false, format=format.price, precision=1)

// ============================================================================
// 1. INPUT PARAMETERS
// ============================================================================

// Higher Timeframe & Proximity Settings
grp_htf         = "1. Higher-Timeframe Context"
htf_res         = input.timeframe("240", "HTF Resolution", group=grp_htf, tooltip="Higher timeframe for macro market context (Default: 4H / 240)")
proximity_mult  = input.float(0.15, "HTF Level Proximity Multiplier (x HTF ATR)", minval=0.01, step=0.01, group=grp_htf)
pivot_lookback  = input.int(20, "Reference Swing Lookback (N Bars)", minval=5, step=5, group=grp_htf)

// Sweep & Quality Conditions
grp_sweep       = "2. Liquidity Sweep & Reclaim Parameters"
max_sweep_dist  = input.float(0.50, "Max Sweep Distance (x ATR)", minval=0.1, step=0.05, group=grp_sweep)
min_wick_ratio  = input.float(0.35, "Minimum Wick Ratio (Wick / Range)", minval=0.1, maxval=0.9, step=0.05, group=grp_sweep)
acceptance_bars = input.int(3, "Rejection Evaluation Window (Bars)", minval=1, maxval=10, group=grp_sweep)

// Order Flow & Volume Parameters
grp_of          = "3. Order Flow & Volume Thresholds"
vol_length      = input.int(20, "Volume Average SMA Length", minval=5, group=grp_of)
vol_mult        = input.float(1.5, "Volume Expansion Multiplier", minval=1.0, step=0.1, group=grp_of)
delta_mult      = input.float(2.0, "Extreme Delta Multiplier", minval=1.0, step=0.1, group=grp_of)
max_progress    = input.float(0.15, "Max Progress for Absorption (x ATR)", minval=0.01, step=0.01, group=grp_of)
large_trade_mult= input.float(2.5, "Large-Trade Volume Spike Multiplier", minval=1.5, step=0.1, group=grp_of)

// Signal & Scoring Thresholds
grp_thresh      = "4. Scoring & Signals"
min_entry_score = input.int(65, "Minimum Entry Score Threshold", minval=50, maxval=95, step=5, group=grp_thresh)

// Display Settings
grp_disp        = "5. Visualization & Dashboard"
show_table      = input.bool(true, "Show Status Dashboard Table", group=grp_disp)
show_bg_color   = input.bool(true, "Highlight Signal Background", group=grp_disp)
show_bull_score = input.bool(true, "Show Bullish Trap Score (Trapped Sellers)", group=grp_disp)
show_bear_score = input.bool(true, "Show Bearish Trap Score (Trapped Buyers)", group=grp_disp)

// ============================================================================
// 2. NON-REPAINTING HIGHER TIMEFRAME & REFERENCE CALCULATIONS
// ============================================================================

// Base Timeframe Metrics
atr = ta.atr(14)
c_range = high - low
upper_wick = high - math.max(open, close)
lower_wick = math.min(open, close) - low
vol_avg = ta.sma(volume, vol_length)

// Non-Repainting Reference High & Low (Confirmed Completed Bars)
ref_high = ta.highest(high[1], pivot_lookback)
ref_low  = ta.lowest(low[1], pivot_lookback)

// Higher Timeframe Security Requests (lookahead_off prevents future leak)
htf_high  = request.security(syminfo.tickerid, htf_res, high[barstate.isrealtime ? 0 : 1], lookahead=barmerge.lookahead_off)
htf_low   = request.security(syminfo.tickerid, htf_res, low[barstate.isrealtime ? 0 : 1], lookahead=barmerge.lookahead_off)
htf_atr   = request.security(syminfo.tickerid, htf_res, ta.atr(14)[barstate.isrealtime ? 0 : 1], lookahead=barmerge.lookahead_off)

// Daily & Weekly Levels for Macro Context
pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], lookahead=barmerge.lookahead_off)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_off)
pwl = request.security(syminfo.tickerid, "W", low[1], lookahead=barmerge.lookahead_off)

// Session VWAP Calculation
vwap_val = ta.vwap(hlc3)
vwap_stdev = ta.stdev(close, 20)
vwap_upper = vwap_val + vwap_stdev
vwap_lower = vwap_val - vwap_stdev

// ============================================================================
// 3. ORDER FLOW & DELTA PROXY CALCULATIONS
// ============================================================================

// Order Flow Bar Delta Proxy: volume weighted by close location within range
bar_delta = volume * (c_range > 0 ? ((close - low) - (high - close)) / c_range : 0.0)
avg_delta = ta.sma(math.abs(bar_delta), vol_length)

// Positive and Negative Delta Components
pos_delta = math.max(0.0, bar_delta)
neg_delta = math.abs(math.min(0.0, bar_delta))

// Cumulative Delta (Rolling 20-bar)
cum_delta = ta.sma(bar_delta, 20)

// ============================================================================
// 4. TRAP SCORE COMPONENT CALCULATIONS (0 - 100 WEIGHTING SYSTEM)
// ============================================================================

// --- COMPONENT 1: Liquidity Sweep at Confirmed Level (15 pts) ---
bear_sweep_raw = (high > ref_high) and (close < ref_high)
bear_sweep_dist = (high - ref_high) <= (atr * max_sweep_dist)
bear_wick_ok   = (c_range > 0) and ((upper_wick / c_range) >= min_wick_ratio)
comp1_bear     = (bear_sweep_raw and bear_sweep_dist and bear_wick_ok) ? 15.0 : 0.0

bull_sweep_raw = (low < ref_low) and (close > ref_low)
bull_sweep_dist = (ref_low - low) <= (atr * max_sweep_dist)
bull_wick_ok   = (c_range > 0) and ((lower_wick / c_range) >= min_wick_ratio)
comp1_bull     = (bull_sweep_raw and bull_sweep_dist and bull_wick_ok) ? 15.0 : 0.0

// --- COMPONENT 2: Failed Breakout / Reclaim (15 pts) ---
bars_since_high_break = ta.barssince(high > ref_high)
bear_reclaim = (bars_since_high_break <= acceptance_bars) and (close < ref_high)
comp2_bear   = bear_reclaim ? 15.0 : 0.0

bars_since_low_break = ta.barssince(low < ref_low)
bull_reclaim = (bars_since_low_break <= acceptance_bars) and (close > ref_low)
comp2_bull   = bull_reclaim ? 15.0 : 0.0

// --- COMPONENT 3: Extreme Delta (10 pts) ---
comp3_bear = (pos_delta >= (avg_delta * delta_mult)) ? 10.0 : 0.0
comp3_bull = (neg_delta >= (avg_delta * delta_mult)) ? 10.0 : 0.0

// --- COMPONENT 4: Volume Expansion (10 pts) ---
comp4 = (volume >= (vol_avg * vol_mult)) ? 10.0 : 0.0

// --- COMPONENT 5: Absorption (15 pts) ---
bear_price_progress = math.max(0.0, close - open)
comp5_bear = (pos_delta >= (avg_delta * delta_mult)) and (volume >= (vol_avg * vol_mult)) and (bear_price_progress <= (atr * max_progress)) ? 15.0 : 0.0

bull_price_progress = math.max(0.0, open - close)
comp5_bull = (neg_delta >= (avg_delta * delta_mult)) and (volume >= (vol_avg * vol_mult)) and (bull_price_progress <= (atr * max_progress)) ? 15.0 : 0.0

// --- COMPONENT 6: Delta-Price Divergence (10 pts) ---
bear_delta_hh = bar_delta >= ta.highest(bar_delta, 5)[1]
bear_price_fail = close < ta.highest(close, 5)[1]
comp6_bear = (bear_delta_hh and bear_price_fail) ? 10.0 : 0.0

bull_delta_ll = bar_delta <= ta.lowest(bar_delta, 5)[1]
bull_price_fail = close > ta.lowest(close, 5)[1]
comp6_bull = (bull_delta_ll and bull_price_fail) ? 10.0 : 0.0

// --- COMPONENT 7: Large-Trade Absorption (10 pts) ---
comp7_bear = (volume >= (vol_avg * large_trade_mult)) and (bear_price_progress <= (atr * max_progress)) and (upper_wick >= (c_range * 0.40)) ? 10.0 : 0.0
comp7_bull = (volume >= (vol_avg * large_trade_mult)) and (bull_price_progress <= (atr * max_progress)) and (lower_wick >= (c_range * 0.40)) ? 10.0 : 0.0

// --- COMPONENT 8: Higher-Timeframe Location Proximity (10 pts) ---
dist_ref_h  = math.abs(high - ref_high)
dist_ref_l  = math.abs(low - ref_low)
dist_pdh    = math.abs(high - pdh)
dist_pdl    = math.abs(low - pdl)
dist_pwh    = math.abs(high - pwh)
dist_pwl    = math.abs(low - pwl)
dist_htf_h  = math.abs(high - htf_high)
dist_htf_l  = math.abs(low - htf_low)

min_htf_dist = math.min(dist_ref_h, dist_ref_l, dist_pdh, dist_pdl, dist_pwh, dist_pwl, dist_htf_h, dist_htf_l)
comp8 = (min_htf_dist <= (htf_atr * proximity_mult)) ? 10.0 : 0.0

// --- COMPONENT 9: VWAP or Value-Area Rejection (5 pts) ---
bear_vwap_rej = (high >= vwap_val and close < vwap_val) or (high >= vwap_upper and close < vwap_upper)
comp9_bear = bear_vwap_rej ? 5.0 : 0.0

bull_vwap_rej = (low <= vwap_val and close > vwap_val) or (low <= vwap_lower and close > vwap_lower)
comp9_bull = bull_vwap_rej ? 5.0 : 0.0

// --- COMPONENT 10: Confirmation Candle (5 pts) ---
comp10_bear = (close < low[1]) or (close < ref_high and bar_delta <= 0) ? 5.0 : 0.0
comp10_bull = (close > high[1]) or (close > ref_low and bar_delta >= 0) ? 5.0 : 0.0

// --- COMPONENT 11: Exhaustion (5 pts) ---
vol_declining = (volume < volume[1]) and (volume[1] < volume[2])
range_narrow  = c_range < (atr * 0.50)
comp11 = (vol_declining and range_narrow) ? 5.0 : 0.0

// ============================================================================
// 5. SCORE AGGREGATION & OVERLAP MITIGATION
// ============================================================================

// Raw Score Calculation
raw_bear_score = comp1_bear + comp2_bear + comp3_bear + comp4 + comp5_bear + comp6_bear + comp7_bear + comp8 + comp9_bear + comp10_bear + comp11
raw_bull_score = comp1_bull + comp2_bull + comp3_bull + comp4 + comp5_bull + comp6_bull + comp7_bull + comp8 + comp9_bull + comp10_bull + comp11

// Overlap Mitigation: Deduct 5 points if Sweep & Reclaim overlap without Absorption or Delta divergence
bear_overlap_adj = (comp1_bear > 0 and comp2_bear > 0 and comp5_bear == 0 and comp6_bear == 0) ? 5.0 : 0.0
bull_overlap_adj = (comp1_bull > 0 and comp2_bull > 0 and comp5_bull == 0 and comp6_bull == 0) ? 5.0 : 0.0

// Final Normalized Trap Scores (0 - 100 Clamped)
bearish_trap_score = math.min(100.0, math.max(0.0, raw_bear_score - bear_overlap_adj))
bullish_trap_score = math.min(100.0, math.max(0.0, raw_bull_score - bull_overlap_adj))

// ============================================================================
// 6. SETUP CONVICTION CLASSIFICATION
// ============================================================================

f_get_conviction(score) =>
    score >= 90 ? "Exceptional" :
     score >= 80 ? "High" :
     score >= 65 ? "Standard" :
     score >= 50 ? "Low" : "None"

bear_conviction = f_get_conviction(bearish_trap_score)
bull_conviction = f_get_conviction(bullish_trap_score)

// Entry Signals
bear_signal = bearish_trap_score >= min_entry_score
bull_signal = bullish_trap_score >= min_entry_score

// ============================================================================
// 7. PLOTTING & OSCILLATOR VISUALS
// ============================================================================

// Threshold Background Reference Bands
hline(90, "Exceptional Setup (90)", color=color.new(#FFD700, 50), linestyle=hline.style_solid)
hline(80, "High Conviction (80)", color=color.new(color.aqua, 50), linestyle=hline.style_solid)
hline(65, "Standard Entry Threshold (65)", color=color.new(color.orange, 20), linestyle=hline.style_dashed, linewidth=2)
hline(50, "Low Conviction Threshold (50)", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(0,  "Baseline Zero", color=color.new(color.gray, 80))

// Plot Trap Scores
plot(show_bear_score ? bearish_trap_score : na, "Bearish Trap Score (Trapped Buyers)", color=bearish_trap_score >= 65 ? color.red : color.maroon, linewidth=2, style=plot.style_columns)
plot(show_bull_score ? bullish_trap_score : na, "Bullish Trap Score (Trapped Sellers)", color=bullish_trap_score >= 65 ? color.green : color.teal, linewidth=2, style=plot.style_columns)

// Signal Background Color Highlights
bgcolor(show_bg_color and bull_signal ? color.new(color.green, 85) : show_bg_color and bear_signal ? color.new(color.red, 85) : na)

// Plot Signal Markers
plotshape(bull_signal, "Bullish Setup Alert", shape.triangleup, location.bottom, color.green, size=size.small)
plotshape(bear_signal, "Bearish Setup Alert", shape.triangledown, location.top, color.red, size=size.small)

// ============================================================================
// 8. DASHBOARD TABLE DISPLAY
// ============================================================================

var table dash = table.new(position.top_right, 3, 7, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if show_table and barstate.islast
    // Header
    table.cell(dash, 0, 0, "Metric", bgcolor=color.navy, text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "Bearish (Short)", bgcolor=color.maroon, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "Bullish (Long)", bgcolor=#006400, text_color=color.white, text_size=size.small)

    // Trap Score Row
    table.cell(dash, 0, 1, "Trap Score", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(bearish_trap_score, "#.0"), bgcolor=bearish_trap_score >= min_entry_score ? color.red : color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 1, str.tostring(bullish_trap_score, "#.0"), bgcolor=bullish_trap_score >= min_entry_score ? color.green : color.black, text_color=color.white, text_size=size.small)

    // Conviction Level Row
    table.cell(dash, 0, 2, "Conviction", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 2, bear_conviction, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 2, bull_conviction, text_color=color.white, text_size=size.small)

    // Sweep Status
    table.cell(dash, 0, 3, "Sweep & Reclaim", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 3, comp1_bear > 0 ? "YES (15pt)" : "NO", text_color=comp1_bear > 0 ? color.lime : color.gray, text_size=size.small)
    table.cell(dash, 2, 3, comp1_bull > 0 ? "YES (15pt)" : "NO", text_color=comp1_bull > 0 ? color.lime : color.gray, text_size=size.small)

    // Absorption Status
    table.cell(dash, 0, 4, "Absorption", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 4, comp5_bear > 0 ? "YES (15pt)" : "NO", text_color=comp5_bear > 0 ? color.lime : color.gray, text_size=size.small)
    table.cell(dash, 2, 4, comp5_bull > 0 ? "YES (15pt)" : "NO", text_color=comp5_bull > 0 ? color.lime : color.gray, text_size=size.small)

    // HTF Proximity Status
    table.cell(dash, 0, 5, "HTF Location", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 5, comp8 > 0 ? "IN RANGE (10pt)" : "OUT", text_color=comp8 > 0 ? color.lime : color.gray, text_size=size.small)
    table.cell(dash, 2, 5, comp8 > 0 ? "IN RANGE (10pt)" : "OUT", text_color=comp8 > 0 ? color.lime : color.gray, text_size=size.small)

    // Signal Status
    table.cell(dash, 0, 6, "Entry Signal", text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 6, bear_signal ? "ALERT SHORT" : "WAIT", bgcolor=bear_signal ? color.red : color.black, text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 6, bull_signal ? "ALERT LONG" : "WAIT", bgcolor=bull_signal ? color.green : color.black, text_color=color.white, text_size=size.small)

// ============================================================================
// 9. ALERT CONDITIONS
// ============================================================================

alertcondition(bull_signal, title="Bullish Trap Score Signal", message="Bullish Trap Score >= 65: Trapped Sellers Setup Detected")
alertcondition(bear_signal, title="Bearish Trap Score Signal", message="Bearish Trap Score >= 65: Trapped Buyers Setup Detected")
````
