# R2D2 Quantum Ribbon Pro [v2.1]

- url: https://www.tradingview.com/script/3cysVq0a-R2D2-Quantum-Ribbon-Pro-v2-1/
- type: indicator
- pine_id: PUB;3cfb7c4f5f6f4d33b5848360ac415e8d
- version: 1.0

## Description

[b]Quantum Ribbon Pro v2.1: Advanced Trend & Risk Management Ecosystem[/b]

verview
Most indicators on TradingView provide entries. Few provide a complete operational framework.
[b]
R2D2 Quantum Ribbon Pro v2.1[/b] is not just a signal generator; it is a systematic execution layer built for professional traders. It combines a dynamic multi-layer momentum ribbon with institutional-grade risk management, multi-timeframe confluence, and automated market structure detection.

Designed to filter out noise and protect capital during ranging markets, this system enforces discipline by managing the entire lifecycle of a trade—from high-probability entries to scaled, risk-free exits.

[b]Core Engine: The 5-Layer Adaptive Ribbon[/b]
At the heart of the system is the Quantum Ribbon—a complex array of five distinct Exponential Moving Average (EMA) pairs.

[b]Momentum Gradients[/b]: The ribbon is visualized through deep color gradients, representing trend intensity. A fully aligned 5-layer ribbon (Bright Cyan/Bright Red) indicates overwhelming momentum. A mixed ribbon (Gray) signals transition or indecision.
[b]
Trend Candles[/b]: Chart candles dynamically change color based on the ribbon's internal state, providing instant visual feedback on trend strength without needing to over-analyze the EMAs.

[b]Customizable Core:[/b] By default, the system runs on highly optimized 21-period (fast) to 60-period (slow) EMA bounds, but the engine is fully unlocked for traders who wish to adapt the frequencies to highly volatile crypto assets or slower traditional equities.
[b]
Tactical Filtering:[/b] The Confluence Gatekeepers
To execute a trade, the system requires alignment across multiple independent dimensions. These filters act as gatekeepers to keep you out of low-probability setups:

[b]Higher Timeframe (HTF) Filter:[/b] Ensures you are trading with the macro trend. If you are executing on the 15m chart, the script dynamically queries the 1H or 4H trend state. Signals counter to the macro trend are systematically blocked.

[b]Quantum Range Filter (Chop Protection):[/b] Choppy, sideways markets destroy capital. This filter analyzes ATR vs. average ribbon compression. If the market is squeezing with low volatility, the filter identifies it as "Ranging" and suppresses all signals until explosive directional volume returns.

[b]S/R Auto-Detection:[/b] Automatically maps major support and resistance pivots. When enabled, it strictly prohibits buying into overhead resistance or shorting into structural support floors.

[b]TP RSI Momentum Alignment[/b]: Requires underlying RSI momentum to confirm the price action before a signal is authorized.

[b]Execution & Risk Management[/b]
Professional trading is defined by how you manage risk, not just how you enter. This script automates trade management to remove emotional interference.
[b]
Adaptive Stop Losses (ATR & Swing):[/b] Choose between volatility-based ATR stops or structural Swing stops that tuck your invalidation level safely behind the most recent market pivot.

[b]Partial Scaling (TP1, TP2, Final):[/b] Scale out of positions systematically. The default configuration banks 50% of your position at 1.5R, 30% at 2.0R, and lets the final 20% run to a 2.5R target. Lock in profits while keeping upside exposure.

[b]Automated Break-Even Trail:[/b] Once your initial target (TP1) is struck, the system instantly moves your stop loss to your exact entry price. You are now in a risk-free "free ride."
[b]
Ribbon Flip Exit:[/b] A dynamic parachute. If the macro trend violently reverses against your position before your stop loss is hit, the system triggers an early exit to salvage capital.

[b]The "Market DNA" Command Dashboard[/b]
Stay fully informed without cluttering your workspace. The real-time HUD (Heads-Up Display) tracks the vital statistics of your current market and active positions:

[b]Current State:[/b] Real-time identification of Trending vs. Ranging conditions (with % intensity).
[b]
Active Trade Metrics:[/b] Tracks your exact Entry, Stop, and Target levels.

[b]Live P&L & Performance[/b]: Monitors open trade profitability and logs a running Win/Loss ratio based on your current settings.

[b]HTF Alignment: [/b]A quick-glance status indicator for your macro timeframe.

[b]How to Use This System[/b]
1. Breakout vs. Bounce Entries:

Standard Mode: Fires signals when all confluences align and the trend breaks out.

Bounce Mode: For established trends. It waits for price to pull back deeply into the ribbon (mean reversion) and signals an entry only when price violently rejects the ribbon and resumes the trend.

2. Best Practices:

Start with the HTF Filter: Always align your trades with the larger timeframe.

Respect the Range Filter: If the dashboard says the market is "Ranging," protect your capital and stand aside.

Use the Backtester Mindset: This indicator provides the execution logic, but every market behaves differently. Test your settings (ATR distances, R:R targets, EMA lengths) to find what works best for your specific asset before deploying live capital.

[i]Disclaimer: This script is a powerful technical analysis tool designed to assist in systematic trade execution, but it is not a guarantee of profitability. Past performance is not indicative of future results. Always practice strict risk management and never risk more capital than you can afford to lose.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © R2D2_4Life

//@version=6
indicator("R2D2 Quantum Ribbon Pro [v2.1]", overlay=true, max_labels_count=500, max_lines_count=500)

// ========================================================================= //
// 1. MENU CONFIGURATIONS & INPUTS
// ========================================================================= //

// --- SIGNAL SETTINGS ---
grp_sig = "SIGNAL SETTINGS"
sig_sens   = input.int(5, "Signal Sensitivity", minval=1, maxval=5, group=grp_sig)
bounce_sig = input.bool(false, "Enable Ribbon Bounce Signals", group=grp_sig)
tprsi_conf = input.bool(false, "TP RSI Confirmation", group=grp_sig)
tprsi_over = input.bool(false, "TP RSI Ribbon State Overlay", group=grp_sig)
c_tp_bull  = input.color(color.new(#00BCD4, 90), "Bullish Overlay Color", group=grp_sig)
c_tp_bear  = input.color(color.new(#FF5252, 90), "Bearish Overlay Color", group=grp_sig)
htf_filter = input.timeframe("", "Higher Timeframe Filter", group=grp_sig)

// --- S/R AUTO-DETECTION ---
grp_sr = "S/R AUTO-DETECTION"
en_sr      = input.bool(false, "Enable S/R Auto-Detection", group=grp_sr, tooltip="Keep off by default. Highly restrictive.")
sr_str     = input.string("Normal", "S/R Strength", options=["Weak", "Normal", "Strong"], group=grp_sr)
sr_zone    = input.float(1.0, "Touch Zone (%)", step=0.1, group=grp_sr)
show_sr    = input.bool(true, "Show S/R Zones", group=grp_sr)

// --- QUANTUM RANGE FILTER ---
grp_qrf = "QUANTUM RANGE FILTER"
en_qrf     = input.bool(false, "Enable Quantum Range Filter", group=grp_qrf)
qrf_sens   = input.string("Normal", "Filter Sensitivity", options=["Low", "Normal", "High"], group=grp_qrf)

// --- RISK MANAGEMENT ---
grp_rm = "RISK MANAGEMENT"
sl_method  = input.string("ATR", "Stop Loss Method", options=["ATR", "Swing", "Percentage"], group=grp_rm)
sl_dist    = input.string("Normal", "Stop Loss Distance", options=["Tight", "Normal", "Wide"], group=grp_rm)
sl_pct     = input.float(2.0, "Stop Loss %", group=grp_rm)
swing_per  = input.int(5, "Swing Detection Period", group=grp_rm)
swing_buf  = input.float(1.0, "Swing Buffer (ATR)", group=grp_rm)
exit_flip  = input.bool(true, "Exit on Ribbon Flip", group=grp_rm)
flip_sens  = input.int(5, "Flip Sensitivity (1-5)", minval=1, maxval=5, group=grp_rm)

// --- PARTIAL TAKE-PROFITS (Dynamic Table Trigger) ---
grp_ptp = "PARTIAL TAKE-PROFITS"
en_ptp     = input.bool(false, "Enable Partial Take-Profits", group=grp_ptp, tooltip="If false, uses a single target. Table will adjust automatically.")
single_trg = input.float(2.0, "Single Target R:R (if partials off)", step=0.1, group=grp_ptp)
tp1_pos    = input.float(50, "TP1 Position %", group=grp_ptp)
tp1_rr     = input.float(1.5, "TP1 Risk:Reward", step=0.1, group=grp_ptp)
tp2_pos    = input.float(30, "TP2 Position %", group=grp_ptp)
tp2_rr     = input.float(2.0, "TP2 Risk:Reward", step=0.1, group=grp_ptp)
fin_rr     = input.float(2.5, "Final Risk:Reward", step=0.1, group=grp_ptp)

// --- BREAK-EVEN STOP ---
grp_be = "BREAK-EVEN STOP"
en_be      = input.bool(false, "Enable Break-Even Stop", group=grp_be)
be_trigger = input.string("TP1", "Break-Even Trigger", options=["TP1", "TP2", "Custom R:R"], group=grp_be)

// --- DISPLAY & STYLES ---
grp_disp = "DISPLAY OPTIONS"
show_table = input.bool(true, "Show Stats Table", group=grp_disp)
tbl_size   = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_disp)

grp_can = "CANDLE COLORS"
c_bull_s   = input.color(#00FF00, "Strong Bull (4-5 pairs)", group=grp_can)
c_bull     = input.color(color.new(#00FF00, 30), "Bull (3 pairs)", group=grp_can)
c_neut     = input.color(color.new(color.gray, 40), "Neutral (2 pairs)", group=grp_can)
c_bear     = input.color(color.new(#FF5252, 30), "Bear (1 pair)", group=grp_can)
c_bear_s   = input.color(#FF5252, "Strong Bear (0 pairs)", group=grp_can)

// ========================================================================= //
// 2. RIBBON ENGINE
// ========================================================================= //
e1_f = ta.ema(close, 21), e1_s = ta.ema(close, 28)
e2_f = ta.ema(close, 30), e2_s = ta.ema(close, 37)
e3_f = ta.ema(close, 40), e3_s = ta.ema(close, 47)
e4_f = ta.ema(close, 50), e4_s = ta.ema(close, 57)
e5_f = ta.ema(close, 60), e5_s = ta.ema(close, 67)

bull_count = (e1_f > e1_s ? 1 : 0) + (e2_f > e2_s ? 1 : 0) + (e3_f > e3_s ? 1 : 0) + (e4_f > e4_s ? 1 : 0) + (e5_f > e5_s ? 1 : 0)
bear_count = 5 - bull_count

c_r1 = bull_count == 5 ? color.new(#00BCD4, 50) : bear_count == 5 ? color.new(#FF5252, 50) : color.new(color.gray, 80)
c_r2 = bull_count >= 4 ? color.new(#00ACC1, 60) : bear_count >= 4 ? color.new(#E53935, 60) : color.new(color.gray, 85)
c_r3 = bull_count >= 3 ? color.new(#0097A7, 70) : bear_count >= 3 ? color.new(#D32F2F, 70) : color.new(color.gray, 90)
c_r4 = bull_count >= 2 ? color.new(#00838F, 80) : bear_count >= 2 ? color.new(#C62828, 80) : color.new(color.gray, 90)
c_r5 = bull_count >= 1 ? color.new(#006064, 85) : bear_count >= 1 ? color.new(#B71C1C, 85) : color.new(color.gray, 95)

fill(plot(e1_f, display=display.none), plot(e1_s, display=display.none), color=c_r1)
fill(plot(e2_f, display=display.none), plot(e2_s, display=display.none), color=c_r2)
fill(plot(e3_f, display=display.none), plot(e3_s, display=display.none), color=c_r3)
fill(plot(e4_f, display=display.none), plot(e4_s, display=display.none), color=c_r4)
fill(plot(e5_f, display=display.none), plot(e5_s, display=display.none), color=c_r5)

barcolor(bull_count >= 4 ? c_bull_s : bull_count == 3 ? c_bull : bull_count == 2 ? c_neut : bear_count >= 4 ? c_bear_s : c_bear)

// ========================================================================= //
// 3. INTERNAL ALGORITHMS
// ========================================================================= //
atr = ta.atr(14)
ph = ta.pivothigh(high, 15, 15)
pl = ta.pivotlow(low, 15, 15)
var float res_lvl = na, var float sup_lvl = na
if not na(ph)
    res_lvl := ph
if not na(pl)
    sup_lvl := pl

ok_sr_l = en_sr ? (close <= (sup_lvl * (1 + sr_zone/100)) and close >= sup_lvl) : true
ok_sr_s = en_sr ? (close >= (res_lvl * (1 - sr_zone/100)) and close <= res_lvl) : true

r_width = math.abs(e1_f - e5_s)
is_chop = en_qrf and (r_width < ta.sma(r_width, 60))

rsi = ta.rsi(close, 14)
rsi_bull = rsi > 50 and ta.ema(rsi,9) > ta.ema(rsi,21)
rsi_bear = rsi < 50 and ta.ema(rsi,9) < ta.ema(rsi,21)
bgcolor(tprsi_over and rsi_bull ? c_tp_bull : tprsi_over and rsi_bear ? c_tp_bear : na)

htf_state = request.security(syminfo.tickerid, htf_filter == "" ? timeframe.period : htf_filter, bull_count >= sig_sens ? 1 : bear_count >= sig_sens ? -1 : 0)

// Pre-calculate swing levels globally to avoid scope errors
swing_low_5 = ta.lowest(low, 5)
swing_high_5 = ta.highest(high, 5)

// ========================================================================= //
// 4. SIGNAL FIRE & TRADE MANAGEMENT 
// ========================================================================= //
is_long_start  = bounce_sig ? (bull_count == 5 and ta.crossover(close, e1_f)) : (bull_count >= sig_sens and bull_count[1] < sig_sens)
is_short_start = bounce_sig ? (bear_count == 5 and ta.crossunder(close, e1_f)) : (bear_count >= sig_sens and bear_count[1] < sig_sens)

long_cond  = is_long_start and not is_chop and (htf_state == 1 or htf_filter == "") and (tprsi_conf ? rsi_bull : true) and ok_sr_l
short_cond = is_short_start and not is_chop and (htf_state == -1 or htf_filter == "") and (tprsi_conf ? rsi_bear : true) and ok_sr_s

var float ep = na, var float sl = na, var float tp1 = na, var float tp2 = na, var float tp3 = na
var float sin_tp = na 
var int state = 0 
var int wins = 0, var int losses = 0 

if long_cond and state == 0
    state := 1
    ep := close
    sl := sl_method == "ATR" ? ep - (atr * 1.5) : sl_method == "Percentage" ? ep * (1 - sl_pct/100) : swing_low_5 - atr
    risk = ep - sl
    tp1 := ep + (risk * tp1_rr)
    tp2 := ep + (risk * tp2_rr)
    tp3 := ep + (risk * fin_rr)
    sin_tp := ep + (risk * single_trg)
    label.new(bar_index, low, "BUY", color=color.new(#00BCD4,0), textcolor=color.white, style=label.style_label_up, size=size.small)

if short_cond and state == 0
    state := -1
    ep := close
    sl := sl_method == "ATR" ? ep + (atr * 1.5) : sl_method == "Percentage" ? ep * (1 + sl_pct/100) : swing_high_5 + atr
    risk = sl - ep
    tp1 := ep - (risk * tp1_rr)
    tp2 := ep - (risk * tp2_rr)
    tp3 := ep - (risk * fin_rr)
    sin_tp := ep - (risk * single_trg)
    label.new(bar_index, high, "SELL", color=color.new(#FF5252,0), textcolor=color.white, style=label.style_label_down, size=size.small)

// Exit Logic
if state == 1
    if low <= sl
        state := 0
        label.new(bar_index, sl, "STOP X", color=color.red, style=label.style_label_up, size=size.tiny)
        if sl >= ep
            wins += 1 
        else 
            losses += 1
    else if high >= tp3 and en_ptp
        state := 0
        label.new(bar_index, tp3, "FINAL TP ✓\n20%", color=color.teal, style=label.style_label_down, size=size.tiny)
        wins += 1
    else if high >= sin_tp and not en_ptp
        state := 0
        label.new(bar_index, sin_tp, "TARGET HIT ✓", color=color.teal, style=label.style_label_down, size=size.tiny)
        wins += 1
    else if high >= tp1 and en_be
        sl := ep
    else if exit_flip and bear_count >= flip_sens
        state := 0
        label.new(bar_index, close, "FLIP EXIT", color=color.orange, style=label.style_label_down, size=size.tiny)
        if close > ep 
            wins += 1 
        else 
            losses += 1

if state == -1
    if high >= sl
        state := 0
        label.new(bar_index, sl, "STOP X", color=color.red, style=label.style_label_down, size=size.tiny)
        if sl <= ep 
            wins += 1 
        else 
            losses += 1
    else if low <= tp3 and en_ptp
        state := 0
        label.new(bar_index, tp3, "FINAL TP ✓\n20%", color=color.teal, style=label.style_label_up, size=size.tiny)
        wins += 1
    else if low <= sin_tp and not en_ptp
        state := 0
        label.new(bar_index, sin_tp, "TARGET HIT ✓", color=color.teal, style=label.style_label_up, size=size.tiny)
        wins += 1
    else if low <= tp1 and en_be
        sl := ep
    else if exit_flip and bull_count >= flip_sens
        state := 0
        label.new(bar_index, close, "FLIP EXIT", color=color.orange, style=label.style_label_up, size=size.tiny)
        if close < ep 
            wins += 1 
        else 
            losses += 1

// ========================================================================= //
// 5. "MARKET DNA" DASHBOARD
// ========================================================================= //
if show_table
    t_sz = tbl_size == "Tiny" ? size.tiny : tbl_size == "Small" ? size.small : tbl_size == "Normal" ? size.normal : size.large
    
    trend_pct = math.round((math.max(bull_count, bear_count) / 5) * 100)
    pnl = state == 1 ? ((close - ep)/ep)*100 : state == -1 ? ((ep - close)/ep)*100 : 0.0
    total_trades = wins + losses
    win_rate = total_trades > 0 ? math.round((wins / total_trades) * 100) : 0
    
    var tb = table.new(position.top_right, 2, en_ptp ? 11 : 9, bgcolor=color.new(#131722, 10), border_color=color.new(#363a45, 0), border_width=1)
    
    if barstate.islast
        table.cell(tb, 0, 0, "Market DNA", text_color=color.gray, text_size=t_sz)
        table.cell(tb, 1, 0, is_chop ? "ranging" : "trending ("+str.tostring(trend_pct)+"%)", text_color=color.white, bgcolor=is_chop ? color.new(color.orange, 70) : color.new(#363a45, 20), text_size=t_sz)
        
        table.cell(tb, 0, 1, "Status", text_color=color.white, text_size=t_sz)
        table.cell(tb, 1, 1, state == 1 ? "🟢 IN LONG" : state == -1 ? "🔴 IN SHORT" : "⏸ Waiting", text_color=color.white, bgcolor=state==1 ? color.new(color.green, 80) : state==-1 ? color.new(color.red, 80) : na, text_size=t_sz)
        
        table.cell(tb, 0, 2, "Ribbon", text_color=color.white, text_size=t_sz)
        table.cell(tb, 1, 2, bull_count >= 4 ? "🟢 Strong Bull" : bear_count >= 4 ? "🔴 Strong Bear" : "⚪ Mixed", text_color=color.white, text_size=t_sz)
        
        table.cell(tb, 0, 3, "Performance", text_color=color.white, text_size=t_sz)
        table.cell(tb, 1, 3, str.tostring(wins)+"W/"+str.tostring(losses)+"L ("+str.tostring(win_rate)+"%)", text_color=color.white, text_size=t_sz)
        
        table.cell(tb, 0, 4, "P&L", text_color=color.gray, text_size=t_sz, bgcolor=color.new(#363a45, 20))
        table.cell(tb, 1, 4, state != 0 ? (pnl >= 0 ? "+" : "") + str.tostring(pnl, "#.##") + "%" : "-", text_color=pnl > 0 ? color.green : pnl < 0 ? color.red : color.gray, bgcolor=pnl > 0 ? color.new(color.green, 90) : pnl < 0 ? color.new(color.red, 90) : color.new(#363a45, 20), text_size=t_sz)
        
        table.cell(tb, 0, 5, "Entry", text_color=color.gray, bgcolor=color.new(#FFD54F, 90), text_size=t_sz)
        table.cell(tb, 1, 5, state != 0 ? str.tostring(ep, "#.##") : "-", text_color=color.white, bgcolor=color.new(#FFD54F, 90), text_size=t_sz)
        
        table.cell(tb, 0, 6, "Stop", text_color=color.gray, text_size=t_sz)
        table.cell(tb, 1, 6, state != 0 ? str.tostring(sl, "#.##") : "-", text_color=color.white, text_size=t_sz)
        
        if not en_ptp
            table.cell(tb, 0, 7, "Target", text_color=color.gray, text_size=t_sz)
            table.cell(tb, 1, 7, state != 0 ? str.tostring(sin_tp, "#.##") : "-", text_color=color.white, text_size=t_sz)
        else
            table.cell(tb, 0, 7, "TP1 ("+str.tostring(tp1_pos)+"%)", text_color=color.gray, text_size=t_sz)
            table.cell(tb, 1, 7, state != 0 ? str.tostring(tp1, "#.##") : "-", text_color=color.white, text_size=t_sz)
            
            table.cell(tb, 0, 8, "TP2 ("+str.tostring(tp2_pos)+"%)", text_color=color.gray, text_size=t_sz)
            table.cell(tb, 1, 8, state != 0 ? str.tostring(tp2, "#.##") : "-", text_color=color.white, text_size=t_sz)
            
            table.cell(tb, 0, 9, "Final", text_color=color.gray, text_size=t_sz)
            table.cell(tb, 1, 9, state != 0 ? str.tostring(tp3, "#.##") : "-", text_color=color.white, text_size=t_sz)
````
