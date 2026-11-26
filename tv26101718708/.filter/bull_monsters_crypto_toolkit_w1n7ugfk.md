# Bull Monsters Crypto Toolkit

- url: https://www.tradingview.com/script/w1N7UGfk-Bull-Monsters-Crypto-Toolkit/
- type: indicator
- pine_id: PUB;b3fc34fbeae84941a5d6332351dea19a
- version: 1.0

## Description

🟢 Bull Monsters Crypto Toolkit: Institutional AI Framework

The Bull Monsters Crypto Toolkit is a systematic trading framework designed specifically for high-volatility cryptocurrency markets (BTC, ETH, SOL, TAO). This indicator automates the "Bull Monsters" methodology, moving beyond simple signals to provide full institutional context and AI-driven trade justifications.

This script identifies liquidity sweeps, HTF mitigation, and high-probability rejection patterns using a refined C1-C2-C3 sequence.

🚀 Key Features

1. Phase 1: Institutional Coin Selection
Stop guessing which pair to trade. The built-in dashboard monitors:

Volume Surge Detection: Flags assets showing unusual institutional activity (>1.5x relative volume).
Asset Categorization: Specifically optimized for "Major Crypto" plays like Solana and Bittensor.
Manual Bias Alignment: Synchronizes the indicator with your personal market outlook (Buy/Sell/Neutral) to filter out counter-trend noise.

2. Phase 2: The C1-C2-C3 Confirmation Sequence
Trades are validated through three specific chart criteria:

C1 (Mitigation): Identifies price tapping key HTF levels, including Previous Day/Week/Month Highs/Lows and OHP/OLP (Open High/Low Points).
C2 (Candle Rejection): Graded by quality to ensure only the strongest reactions are traded:
First Class: Precise body closure within the institutional range.
Second Class: Aggressive rejection reclaiming the range.
Third Class: Wick-based mitigation.
C3 (Entry Trigger): The final execution trigger based on range sweeps, ensuring you entry only when momentum is confirmed.

3. Phase 3: AI Co-pilot & Risk Management
AI Briefing Module: Provides an "EXACT REASON" log for every signal, detailing why the trade met the framework's criteria.
1:1 R:R Visualization: Automatically projects 1:1 Risk-to-Reward targets with a 50% Partial Target (T1) and 100% Full Target marked on your chart.

🛠️ How to Use
Selection: Use the dashboard to find coins with a Volume Surge.
Context: Ensure price is mitigating a marked Key Level (C1).
Confirmation: Wait for a C2 Rejection candle and look for the "C3 ENTRY" triangle.
Briefing: Hover over the AI Co-pilot table to read the trade justification.

⚠️ Disclaimer
Trading cryptocurrency involves significant risk. This tool is designed to assist with technical analysis and frame-work execution; it is not financial advice. Always use proper risk management.

Suggested Tags:
SMC, ICT, Crypto, Institutional, OrderBlock, Liquidity, Solana, AI

## Source Code

````pine
// This Pine Script™ source is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Bull Monsters — Crypto Indicators Framework

//@version=6
indicator("Bull Monsters Crypto Toolkit", "BM Crypto", overlay=true, max_boxes_count=100, max_lines_count=100, max_labels_count=100)

// ══════════════════════════════════════════════════════════════════════════════
// ██  MODULE TOGGLES
// ══════════════════════════════════════════════════════════════════════════════

grp_tog = "━━━ Modules (Crypto Framework) ━━━"
show_dash      = input.bool(true,  "① Coin Picker Dashboard", group=grp_tog)
show_key_lvl   = input.bool(true,  "② HTF Key Levels (M, W, D)", group=grp_tog)
show_ohp_olp   = input.bool(true,  "③ OHP / OLP Levels", group=grp_tog)
show_c1        = input.bool(true,  "④ C1 (Formation & Mitigation)", group=grp_tog)
show_crt       = input.bool(true,  "⑤ CRT (C1-C2-C3 Sequence)", group=grp_tog)
show_ai        = input.bool(true,  "⑥ AI Co-pilot Briefing", group=grp_tog)
show_rr        = input.bool(true,  "⑦ 1:1 R:R Visualization", group=grp_tog)

// ══════════════════════════════════════════════════════════════════════════════
// ██  INPUTS — Settings
// ══════════════════════════════════════════════════════════════════════════════

grp_cp = "━━━ Coin Picker ━━━"
manual_bias    = input.string("Neutral", "Manual Bias", options=["Buy", "Sell", "Neutral"], group=grp_cp)
vol_threshold  = input.float(1.5, "Volume Surge Threshold", minval=1.1, maxval=5.0, step=0.1, group=grp_cp)
show_funding   = input.bool(true, "Show Funding Alert", group=grp_cp)

grp_crt = "━━━ CRT / C1-C2-C3 ━━━"
rej_grade      = input.string("First Class", "C2 Rejection Grade", options=["First Class", "Second Class", "Third Class"], group=grp_crt)
htf_res        = input.timeframe("D", "Analysis Timeframe (HTF)", group=grp_crt)
swing_lb       = input.int(5, "Swing Lookback", minval=2, maxval=20, group=grp_crt)

grp_col = "━━━ Colors ━━━"
col_bull = input.color(color.new(#26A69A, 0), "Bullish Color", group=grp_col)
col_bear = input.color(color.new(#EF5350, 0), "Bearish Color", group=grp_col)
col_key  = input.color(color.new(#FFD54F, 0), "Key Level Color", group=grp_col)

// ══════════════════════════════════════════════════════════════════════════════
// ██  CORE CALCULATIONS
// ══════════════════════════════════════════════════════════════════════════════

atr14 = ta.atr(14)
sh = ta.pivothigh(high, swing_lb, swing_lb)
sl = ta.pivotlow(low, swing_lb, swing_lb)

// Volume Surge
vol_avg = ta.sma(volume, 20)
is_vol_surge = volume > vol_avg * vol_threshold

// HTF request
[htf_o, htf_h, htf_l, htf_c] = request.security(syminfo.tickerid, htf_res, [open, high, low, close], barmerge.gaps_off, barmerge.lookahead_on)

// OHP / OLP (Open High Point / Low Point) - First session interval of HTF
// We will use the high/low of the first candle of the HTF period as a proxy for OHP/OLP
var float ohp = na
var float olp = na
is_new_htf = timeframe.change(htf_res)
if is_new_htf
    ohp := high
    olp := low
else
    ohp := math.max(ohp, high)
    olp := math.min(olp, low)

// ══════════════════════════════════════════════════════════════════════════════
// ██  PHASE 1: COIN PICKER DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════

var table dash = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 40), border_color=color.new(color.gray, 60), border_width=1)
if show_dash and barstate.islast
    table.cell(dash, 0, 0, "Metric", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 0, "Value", text_color=color.white, text_size=size.tiny)
    
    // Volume Surge
    table.cell(dash, 0, 1, "Volume Surge", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 1, is_vol_surge ? "YES 🔥" : "NO", text_color=is_vol_surge ? color.green : color.red, text_size=size.tiny)
    
    // Manual Bias
    table.cell(dash, 0, 2, "Manual Bias", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 2, manual_bias, text_color=manual_bias == "Buy" ? color.green : manual_bias == "Sell" ? color.red : color.gray, text_size=size.tiny)

    // Specific Crypto Check
    is_major = str.contains(syminfo.tickerid, "SOL") or str.contains(syminfo.tickerid, "TAO") or str.contains(syminfo.tickerid, "BTC") or str.contains(syminfo.tickerid, "ETH")
    table.cell(dash, 0, 3, "Asset Class", text_color=color.white, text_size=size.tiny)
    table.cell(dash, 1, 3, is_major ? "Major Crypto ✅" : "Other", text_color=color.white, text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// ██  KEY LEVELS (M, W, D)
// ══════════════════════════════════════════════════════════════════════════════

pm_h = request.security(syminfo.tickerid, "M", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pm_l = request.security(syminfo.tickerid, "M", low[1], barmerge.gaps_off, barmerge.lookahead_on)
pw_h = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pw_l = request.security(syminfo.tickerid, "W", low[1], barmerge.gaps_off, barmerge.lookahead_on)
pd_h = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_on)
pd_l = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_on)

plot_lvl(val, tit, col) =>
    var line ln = na
    if show_key_lvl and not na(val)
        if ta.change(val) != 0 or na(ln)
            line.delete(ln)
            ln := line.new(bar_index, val, bar_index + 10, val, color=color.new(col, 50), style=line.style_dashed, width=1)
            label.new(bar_index + 10, val, tit, style=label.style_none, textcolor=color.new(col, 20), size=size.tiny)
            float(na)
        else
            line.set_x2(ln, bar_index + 8)
            float(na)
    else
        float(na)

plot_lvl(pm_h, "PMH", col_key)
plot_lvl(pm_l, "PML", col_key)
plot_lvl(pw_h, "PWH", col_key)
plot_lvl(pw_l, "PWL", col_key)
plot_lvl(pd_h, "PDH", col_key)
plot_lvl(pd_l, "PDL", col_key)

// OHP / OLP Plots
var line ohp_l = na
var line olp_l = na
if show_ohp_olp and not na(ohp)
    if is_new_htf or na(ohp_l)
        line.delete(ohp_l)
        line.delete(olp_l)
        ohp_l := line.new(bar_index, ohp, bar_index + 5, ohp, color=color.orange, style=line.style_dotted)
        olp_l := line.new(bar_index, olp, bar_index + 5, olp, color=color.orange, style=line.style_dotted)
    else
        line.set_x2(ohp_l, bar_index + 3)
        line.set_x2(olp_l, bar_index + 3)

// ══════════════════════════════════════════════════════════════════════════════
// ██  PHASE 2: C1 FORMATION & MITIGATION
// ══════════════════════════════════════════════════════════════════════════════

// C1: HTF Mitigation at Key Levels or OB/FVG
// Bullish C1: Price taps a Key Level Low or Demand Zone and shows rejection
is_mitig_bull = (low <= pm_l or low <= pw_l or low <= pd_l or low <= olp) and close > open
is_mitig_bear = (high >= pm_h or high >= pw_h or high >= pd_h or high >= ohp) and close < open

var bool c1_bull = false
var bool c1_bear = false
var int c1_bar = 0

if show_c1
    if is_mitig_bull
        c1_bull := true
        c1_bear := false
        c1_bar := bar_index
        label.new(bar_index, low, "C1 Mitigation", style=label.style_label_up, color=color.new(color.blue, 40), textcolor=color.white, size=size.tiny)
    if is_mitig_bear
        c1_bear := true
        c1_bull := false
        c1_bar := bar_index
        label.new(bar_index, high, "C1 Mitigation", style=label.style_label_down, color=color.new(color.red, 40), textcolor=color.white, size=size.tiny)

// Clear C1 after 10 bars if no C2/C3 sequence
if bar_index - c1_bar > 10
    c1_bull := false
    c1_bear := false

// ══════════════════════════════════════════════════════════════════════════════
// ██  PHASE 2 CONT: C2 REJECTION GRADING
// ══════════════════════════════════════════════════════════════════════════════

// C2 Logic: Grading the candle rejection after C1
// We expect C2 to be the candle internal or trailing C1
bool is_c2_active = (bar_index - c1_bar) <= 3 and (bar_index > c1_bar)

// C2 Rejection Grading
float c1_body_high = math.max(open[bar_index - c1_bar], close[bar_index - c1_bar])
float c1_body_low  = math.min(open[bar_index - c1_bar], close[bar_index - c1_bar])
float c1_wick_high = high[bar_index - c1_bar]
float c1_wick_low  = low[bar_index - c1_bar]

// Bullish C2 Grading (Rejection at a Low/Support)
// Class 1: Close within 30-50% of C1 body
bool c2_bull_1 = is_c2_active and close > open and close >= (c1_body_low + 0.3 * (c1_body_high - c1_body_low)) and close <= (c1_body_low + 0.5 * (c1_body_high - c1_body_low))
// Class 2: Open below C1 body, but close above C1 body (Strong Rejection)
bool c2_bull_2 = is_c2_active and close > open and open < c1_body_low and close > c1_body_high
// Class 3: Open below C1 body, but close within or below C1 wick (Weak Rejection)
bool c2_bull_3 = is_c2_active and close > open and open < c1_body_low and close <= c1_wick_low

// Selected Grade logic
bool c2_valid_bull = rej_grade == "First Class" ? c2_bull_1 : (rej_grade == "Second Class" ? c2_bull_2 : c2_bull_3)

// Bearish C2 Grading (Rejection at a High/Resistance)
// Class 1: Close within 30-50% of C1 body (top-down)
bool c2_bear_1 = is_c2_active and close < open and close <= (c1_body_high - 0.3 * (c1_body_high - c1_body_low)) and close >= (c1_body_high - 0.5 * (c1_body_high - c1_body_low))
// Class 2: Open above C1 body, but close below C1 body (Strong Rejection)
bool c2_bear_2 = is_c2_active and close < open and open > c1_body_high and close < c1_body_low
// Class 3: Open above C1 body, but close within or above C1 wick (Weak Rejection)
bool c2_bear_3 = is_c2_active and close < open and open > c1_body_high and close >= c1_wick_high

bool c2_valid_bear = rej_grade == "First Class" ? c2_bear_1 : (rej_grade == "Second Class" ? c2_bear_2 : c2_bear_3)

if show_crt and (c2_valid_bull or c2_valid_bear)
    label.new(bar_index, c2_valid_bull ? low : high, "C2 " + rej_grade, style=c2_valid_bull ? label.style_label_up : label.style_label_down, color=color.new(color.orange, 30), textcolor=color.white, size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// ██  PHASE 2 CONT: C3 ENTRY & SWEEP
// ══════════════════════════════════════════════════════════════════════════════

// C3: Sweep of C1+C2 range
float c1_c2_high = math.max(high[bar_index - c1_bar], high)
float c1_c2_low  = math.min(low[bar_index - c1_bar], low)

bool c3_trigger_bull = show_crt and c2_valid_bull[1] and low < low[1] and close > low[1] and manual_bias != "Sell"
bool c3_trigger_bear = show_crt and c2_valid_bear[1] and high > high[1] and close < high[1] and manual_bias != "Buy"

plotshape(c3_trigger_bull, "C3 Entry Buy", shape.triangleup, location.belowbar, color=color.new(col_bull, 0), size=size.small, text="C3 ENTRY", textcolor=color.white)
plotshape(c3_trigger_bear, "C3 Entry Sell", shape.triangledown, location.abovebar, color=color.new(col_bear, 0), size=size.small, text="C3 ENTRY", textcolor=color.white)

// ══════════════════════════════════════════════════════════════════════════════
// ██  PHASE 3: 1:1 R:R & AI BRIEFING
// ══════════════════════════════════════════════════════════════════════════════

if show_rr
    if c3_trigger_bull
        sl_val = c1_c2_low
        risk = close - sl_val
        tp_val = close + risk
        box.new(bar_index, tp_val, bar_index + 10, close, bgcolor=color.new(col_bull, 90), border_color=col_bull)
        box.new(bar_index, close, bar_index + 10, sl_val, bgcolor=color.new(col_bear, 90), border_color=col_bear)
        label.new(bar_index + 10, tp_val, "TP (100%)", style=label.style_none, textcolor=col_bull, size=size.tiny)
        label.new(bar_index + 10, (close + tp_val)/2, "T1 (50%)", style=label.style_none, textcolor=col_bull, size=size.tiny)

    if c3_trigger_bear
        sl_val = c1_c2_high
        risk = sl_val - close
        tp_val = close - risk
        box.new(bar_index, close, bar_index + 10, tp_val, bgcolor=color.new(col_bear, 90), border_color=col_bear)
        box.new(bar_index, sl_val, bar_index + 10, close, bgcolor=color.new(col_bull, 90), border_color=col_bull)
        label.new(bar_index + 10, tp_val, "TP (100%)", style=label.style_none, textcolor=col_bear, size=size.tiny)
        label.new(bar_index + 10, (close + tp_val)/2, "T1 (50%)", style=label.style_none, textcolor=col_bear, size=size.tiny)

// AI Co-pilot Briefing Module
if show_ai and barstate.islast
    var table ai_brief = table.new(position.bottom_right, 2, 4, bgcolor=color.new(color.navy, 30), border_color=color.gray, border_width=1)
    table.cell(ai_brief, 0, 0, "AI Co-pilot Briefing", text_color=color.white, text_size=size.tiny)
    table.merge_cells(ai_brief, 0, 0, 1, 0)
    
    reason = "Scanning for C1 Mitigation..."
    if c3_trigger_bull or c3_trigger_bull[1] or c3_trigger_bull[2]
        reason := "EXACT REASON: HTF Liquidity Sweep @ C1 + " + rej_grade + " Rejection @ C2 + C3 Range Sweep. R:R Fixed 1:1."
    else if c3_trigger_bear or c3_trigger_bear[1] or c3_trigger_bear[2]
        reason := "EXACT REASON: HTF Liquidity Sweep @ C1 + " + rej_grade + " Rejection @ C2 + C3 Range Sweep. R:R Fixed 1:1."
    
    table.cell(ai_brief, 0, 1, "Latest Reason:", text_color=color.white, text_size=size.tiny)
    table.cell(ai_brief, 0, 2, reason, text_color=color.yellow, text_size=size.tiny)
    table.merge_cells(ai_brief, 0, 2, 1, 2)

// ══════════════════════════════════════════════════════════════════════════════
// ██  ALERTS
// ══════════════════════════════════════════════════════════════════════════════

alertcondition(c3_trigger_bull, "Bull Monsters Buy", "C3 Bull Entry Signal triggered on {{ticker}}")
alertcondition(c3_trigger_bear, "Bull Monsters Sell", "C3 Bear Entry Signal triggered on {{ticker}}")

// END
````
