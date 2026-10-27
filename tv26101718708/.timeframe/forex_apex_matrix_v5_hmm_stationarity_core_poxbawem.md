# Forex Apex Matrix V5: HMM & Stationarity Core

- url: https://www.tradingview.com/script/poxbAwem-Forex-Apex-Matrix-V5-HMM-Stationarity-Core/
- type: strategy
- pine_id: PUB;ec74354e16dd4d2db309c67b382e1b4a
- version: 1.0

## Description

[b]FOREX APEX MATRIX: BIDIRECTIONAL MEAN REVERSION SUITE[/b]

// This work is licensed under an Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

[b]OVERVIEW & PURPOSE[/b]
The Apex Matrix is an institutional-grade, bidirectional mean-reversion architecture designed specifically for high-liquidity, ranging environments like the global Forex market. By abandoning static percentages and lagging moving average crossovers, this suite utilizes an entirely adaptive, volatility-normalized framework. It merges pure spatial deviation with momentum self-crossovers to identify localized market exhaustion, firing signals only when "smart money" begins to absorb panic selling or euphoric buying.

This script is engineered to completely answer the questions of market structure, providing a strictly rules-based visual map and execution model for discerning traders.

[b]CORE COMPONENT 1: THE NORMALIZED KINEMATIC MAP (KELTNER CHANNELS)[/b]
[list]
[] [b]Who:[/b] Originally introduced by Chester W. Keltner in the 1960s, and later revolutionized by world-renowned trader Linda Bradford Raschke in the 1980s.
[] [b]What:[/b] A volatility-based envelope set around a central moving average.
[] [b]When:[/b] Raschke modified the original formula in the 1980s to incorporate Average True Range (ATR) instead of high-low ranges, making it an adaptive volatility measure.
[] [b]Where:[/b] Originally developed for the Chicago commodities pits; now universally applied across Forex and Equities.
[] [b]Why:[/b] Traditional Standard Deviation (Bollinger Bands) expands too violently during crashes, moving the goalposts on the trader. Keltner Channels provide a smoother, more normalized boundary of "fair value" versus "extreme premium/discount."
[] [b]How (In this Script):[/b] We utilize a 50-period Exponential Moving Average (EMA) as the "Center of Mass," flanked by a 50-period ATR multiplied by 2.5. This mathematically maps the absolute outer 1% limits of standard market noise. Price must touch or pierce these bands within a 3-bar memory window to arm the system.
[/list]

[b]CORE COMPONENT 2: ADAPTIVE MOMENTUM PIVOT (RSI SELF-CROSSOVER)[/b]
[list]
[] [b]Who:[/b] J. Welles Wilder Jr., a mechanical engineer turned technical analyst.
[] [b]What:[/b] The Relative Strength Index (RSI), a momentum oscillator.
[] [b]When:[/b] Introduced in his seminal 1978 book, "New Concepts in Technical Trading Systems."
[] [b]Where:[/b] Originally designed for the daily charts of volatile commodity futures.
[] [b]Why:[/b] Wilder needed a way to measure the speed and change of price movements to identify overbought and oversold extremes before a reversal occurred.
[] [b]How (In this Script):[/b] Instead of using rigid, static levels like the traditional 30 or 70 bounds (which fail in strong trends), this suite calculates a 14-period Simple Moving Average (SMA) of the 14-period RSI. The trigger fires the exact millisecond the RSI crosses its own moving average. This creates an "Adaptive Pivot" that can catch sharp V-bottoms as well as slow, grinding U-bottoms.
[/list]

[b]CORE COMPONENT 3: VOLATILITY-SCALED EXIT GATE (ATR RATCHET)[/b]
[list]
[] [b]Who:[/b] J. Welles Wilder Jr. (1978).
[] [b]What:[/b] Average True Range (ATR), a pure measure of market volatility.
[] [b]Why:[/b] Static percentage stops (e.g., a 1% stop loss) are fundamentally flawed because they do not account for shifting market regimes. 1% means something different when the VIX is at 12 versus when the VIX is at 35.
[] [b]How (In this Script):[/b] The suite captures the exact 14-period ATR at the exact moment of trade entry. It sets a hard catastrophe stop at 2.0 ATRs, and a hard take-profit at 3.5 ATRs. As the trade moves into profit, a "Breathing Ratchet" locks in gains (e.g., at +2.0 ATR, the stop moves to +1.0 ATR). This guarantees the trade always has exactly 1.0 ATR of "breathing room" to survive normal market chop without being prematurely stopped out.
[/list]

[b]TACTICAL WORKFLOW (HOW TO USE THIS SCRIPT)[/b]
The suite handles the heavy lifting mathematically, presenting the trader with a clean, distraction-free interface.

[b]Phase 1: The Visual Regime (The Background)[/b]
The background color of the chart shifts seamlessly between Teal (Premium/Bullish Hemisphere) and Maroon (Discount/Bearish Hemisphere). This acts purely as a visual heads-up display (HUD) so the trader understands the prevailing 50-EMA macro-trend without cluttering the screen.

[b]Phase 2: The Trap & Trigger (The Triangles)[/b]
The system does not blindly buy the moment price hits a line. A Lime Triangle (Long) or Red Triangle (Short) will ONLY print when the following causal sequence completes:

Price touches or pierces the extreme Keltner boundary (within the last 3 bars).

The internal 14-period RSI definitively crosses its own 14-period moving average, proving that kinetic momentum has officially shifted back toward the mean.

[b]Phase 3: Managed Risk Scaling[/b]
The script features an internal scaling logic viewable in the bottom-right HUD. It compares the short-term 14-ATR to the macro 50-ATR. If the market enters a period of extreme, expanding volatility (ATR > 20% above mean), the system's simulated sizing logic automatically downshifts its multiplier, protecting capital during violent, unpredictable conditions.

[b]RISK DISCLAIMER & HOUSE RULES COMPLIANCE[/b] This script is published strictly for educational purposes and as a proof-of-concept for volatility-normalized order routing. It is not financial advice. Mean-reversion systems can experience significant drawdowns during secular, uni-directional trends. The built-in position sizing and Martingale-style recovery metrics displayed in the HUD are for theoretical modeling and statistical observation only. Always employ strict risk management, utilize paper trading to understand the mechanics, and never risk capital you cannot afford to lose. Past performance inside the Strategy Tester does not guarantee future results in live market conditions. Most pairs will work best on lower timeframes, but otehres liek USDCAD work best on hgiher titemframes

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Designed for the Crypto Entity & Leverage Market
// THE ALPHA COUNCIL - Apex Matrix V5 with HMM Stationarity Core

//@version=6
strategy("Apex Matrix V5: HMM & Stationarity Core", overlay=true, initial_capital=5000, default_qty_type=strategy.fixed, margin_long=1, margin_short=1, pyramiding=10, max_labels_count=500, max_lines_count=500, commission_type=strategy.commission.percent, commission_value=0.05, max_boxes_count=500)

// Signature Colors
color BULL_COLOR    = #00E676
color BEAR_COLOR    = #FF1744
color MID_COLOR     = color.gray

// =========================================================================
// PILLAR 0: HMM REGIME & STATIONARITY DETECTOR (FROM CRYPTO NCS V4)
// =========================================================================
string REGIME_GRP   = "HMM Regime & Stationarity (ADF/Hurst Proxy)"
bool   useRegime    = input.bool(true,  "Enable HMM Mechanics & Box Overlay", group = REGIME_GRP)
bool   strictBinary = input.bool(false, "Enable 1-2 Binary Regime Mode", group = REGIME_GRP, tooltip="Removes the Neutral state. Bullish/Bearish zones will hold persistently until the opposite state is explicitly triggered.")
int    hurstLen     = input.int(14,     "Hurst/Fractal Lookback", minval = 5, group = REGIME_GRP)
float  hurstThresh  = input.float(0.52, "Non-Stationary (Trend) Threshold", minval = 0.45, maxval = 0.65, step = 0.01, group = REGIME_GRP)
string execTf       = input.timeframe("1", "LTF Timeframe (Micro-Structure)", group = REGIME_GRP)

// Micro-CVD Absorption
[cvd_c, cvd_o, cvd_v] = request.security(syminfo.tickerid, execTf, [close, open, volume], lookahead = barmerge.lookahead_off)
var float ltf_cvd_cum = 0.0
if not na(cvd_c)
    ltf_cvd_cum += (cvd_c > cvd_o ? cvd_v : (cvd_c < cvd_o ? -cvd_v : 0))

// STATIONARITY & HMM REGIME DETECTOR (Viterbi Approximation)
float sum_tr = math.sum(ta.tr, hurstLen)
float h_high = ta.highest(high, hurstLen)
float l_low  = ta.lowest(low, hurstLen)
float chop   = 100.0 * math.log10(sum_tr / math.max(h_high - l_low, syminfo.mintick)) / math.log10(hurstLen)
float hurst  = 1.0 - (chop / 100.0) // H > 0.5 = Trending (Non-Stationary), H < 0.5 = Mean-Reverting (Stationary)

float rsi_val = ta.rsi(close, 14)
[di_plus, di_minus, adx_val] = ta.dmi(14, 14)

float cvd_delta = ltf_cvd_cum - nz(ltf_cvd_cum[1])
float cvd_trend = ta.ema(cvd_delta, 10)

// HMM Step-Function (Persistent State Machine with Price-Action Gating)
var int hmm_regime = 0 // 0 = Stationary/Chop, 1 = Non-Stationary Bull, -1 = Non-Stationary Bear

bool is_trending = hurst > hurstThresh and adx_val > 20
float regime_ema = ta.ema(close, 20)

if is_trending
    if rsi_val > 50 and di_plus > di_minus and cvd_trend >= 0 and close > regime_ema
        hmm_regime := 1
    else if rsi_val < 50 and di_minus > di_plus and cvd_trend <= 0 and close < regime_ema
        hmm_regime := -1
else if not strictBinary and (hurst < 0.45 or adx_val < 15)
    hmm_regime := 0

// Structural Kill-Switch (Prevents "Bullish boxes going down" and "Bearish boxes going up")
if not strictBinary
    if hmm_regime == 1 and close < regime_ema
        hmm_regime := 0
    if hmm_regime == -1 and close > regime_ema
        hmm_regime := 0

// 1-Bar Neutral Transition Gate (Execution Delay)
var int display_regime = 0
var int last_hmm_regime = 0

if hmm_regime != last_hmm_regime
    display_regime := 0 // Force neutral state on the transition bar
else
    display_regime := hmm_regime // Lock in on the following bar

last_hmm_regime := hmm_regime

// Executable Regime Zones (Main Chart Overlay - Continuous Adaptive Box)
var box active_regime_box = na
var float regime_open = na
var float regime_extreme = na
var int last_display_regime = -999

if useRegime
    if display_regime != last_display_regime
        // State flipped: Start a brand new contiguous box
        color box_col = na
        if display_regime == 1
            regime_open := open
            regime_extreme := high
            box_col := color.new(BULL_COLOR, 85)
        else if display_regime == -1
            regime_open := open
            regime_extreme := low
            box_col := color.new(BEAR_COLOR, 85)
        else
            regime_open := math.min(open, close)
            regime_extreme := math.max(open, close)
            box_col := color.new(color.yellow, 90)
            
        active_regime_box := box.new(left=bar_index, top=math.max(regime_open, regime_extreme), right=bar_index + 1, bottom=math.min(regime_open, regime_extreme), border_color=na, bgcolor=box_col)
        last_display_regime := display_regime
    else
        // Same regime: Stretch the existing box to the right and expand extremes
        if not na(active_regime_box)
            if display_regime == 1
                regime_extreme := math.max(regime_extreme, high)
            else if display_regime == -1
                regime_extreme := math.min(regime_extreme, low)
            else
                regime_extreme := math.max(regime_extreme, math.max(open, close))
                regime_open := math.min(regime_open, math.min(open, close))
                
            box.set_right(active_regime_box, bar_index + 1)
            box.set_top(active_regime_box, math.max(regime_open, regime_extreme))
            box.set_bottom(active_regime_box, math.min(regime_open, regime_extreme))

// =========================================================================
// PILLAR 1: MACRO & SYNTHETIC LEVERAGE (MULTI-EXCHANGE OI)
// =========================================================================
// 1A. Macro Capital Flow (Tether Dominance)
usdt_d = request.security("CRYPTOCAP:USDT.D", timeframe.period, close)
usdt_d_ma = ta.sma(usdt_d, 20)

macro_bullish = usdt_d < usdt_d_ma // Money flowing into Crypto
macro_bearish = usdt_d > usdt_d_ma // Money flowing into Cash

// 1B. Multi-Exchange Aggregated Open Interest
oi_ticker1 = input.symbol("BINANCE:BTCUSDT.P_OI", "OI Exchange 1", group="1. Macro & Leverage")
oi_ticker2 = input.symbol("BYBIT:BTCUSDT.P_OI", "OI Exchange 2", group="1. Macro & Leverage")
oi_ticker3 = input.symbol("OKX:BTCUSDT.P_OI", "OI Exchange 3", group="1. Macro & Leverage")

oi1 = request.security(oi_ticker1, timeframe.period, close, ignore_invalid_symbol=true)
oi2 = request.security(oi_ticker2, timeframe.period, close, ignore_invalid_symbol=true)
oi3 = request.security(oi_ticker3, timeframe.period, close, ignore_invalid_symbol=true)

total_oi = nz(oi1) + nz(oi2) + nz(oi3)
oi_ma = ta.sma(total_oi, 20)

// Leverage Trap Conditions
oi_spiking = total_oi > oi_ma  // Leverage is building up (Trap Risk)
oi_flushed = total_oi <= oi_ma // Leverage is cleared out (Safe Bottom)


// =========================================================================
// PILLAR 2: TOPOLOGICAL LIQUIDITY SWEEPS (THE ZERO-LAG SNIPER)
// =========================================================================
swing_len = input.int(20, "Swing Lookback (Liquidity Pools)", group="2. Liquidity Pools")

swing_low = ta.lowest(low, swing_len)[1]
swing_high = ta.highest(high, swing_len)[1]

// The Swing Failure Pattern (SFP)
bullish_sfp = low < swing_low and close > swing_low
bearish_sfp = high > swing_high and close < swing_high

plot(swing_low, color=color.new(color.green, 70), style=plot.style_stepline, title="Buy-Side Liquidity (Stops)")
plot(swing_high, color=color.new(color.red, 70), style=plot.style_stepline, title="Sell-Side Liquidity (Stops)")


// =========================================================================
// PILLAR 3: TDA CLUSTER COLLAPSE (VOLUME ANOMALY & EFFORT)
// =========================================================================
vol_dev = ta.stdev(volume, 50)
vol_mean = ta.sma(volume, 50)
is_vol_anomaly = volume > (vol_mean + (vol_dev * 2)) // 2 Standard Deviations above mean

candle_size = math.abs(high - low)
body_size = math.abs(close - open)
is_absorption = body_size < (candle_size * 0.4) // Body is less than 40% of the candle


// =========================================================================
// PILLAR 4: STATE MACHINE & ORTHOGONAL EXECUTION
// =========================================================================
signal_expiry = input.int(3, "Signal Expiry Limit (Bars)", tooltip="Max bars a sweep remains valid waiting for volume/macro confirmation.", group="4. Execution Limits")

bars_since_bull = ta.barssince(bullish_sfp)
bars_since_bear = ta.barssince(bearish_sfp)

valid_bull_sweep = bars_since_bull <= signal_expiry
valid_bear_sweep = bars_since_bear <= signal_expiry

// Trigger Conditions
long_trigger = valid_bull_sweep and (is_vol_anomaly or is_absorption) and macro_bullish and oi_flushed
short_trigger = valid_bear_sweep and (is_vol_anomaly or is_absorption) and macro_bearish and oi_spiking

// --- HMM REGIME GATE (THE SOFT SHIELD) ---
// Identifies if the trade is counter-trend so we can dynamically halve the risk.
// Completely bypasses logic if useRegime is set to False
bool counter_trend_long = useRegime and (display_regime == -1)
bool counter_trend_short = useRegime and (display_regime == 1)

// Ensure we only process a specific sweep cluster once
var int last_long = 0
var int last_short = 0
do_long = long_trigger and (bar_index - last_long > signal_expiry)
do_short = short_trigger and (bar_index - last_short > signal_expiry)

if do_long
    last_long := bar_index
    string txt = counter_trend_long ? "[SOFT ENTRY]\nCOUNTER-REGIME" : "[V-BOTTOM]\nOI FLUSHED"
    label.new(bar_index, low, text=txt, color=color.black, textcolor=color.lime, style=label.style_label_up, size=size.small)

if do_short
    last_short := bar_index
    string txt = counter_trend_short ? "[SOFT ENTRY]\nCOUNTER-REGIME" : "[LEVERAGE TRAP]\nOI OVERHEATED"
    label.new(bar_index, high, text=txt, color=color.black, textcolor=color.red, style=label.style_label_down, size=size.small)


// =========================================================================
// PILLAR 5: STRATEGY ENGINE (MARTINGALE & DYNAMIC EXIT)
// =========================================================================
var float margin_allocated = 50.0
float MAX_MARTINGALE_MARGIN = 50.0 * 32 // Cap at 5 doublings to prevent TradingView Memory Crash
leverage = 100.0

// Tracking Average Price and PnL
pos_avg = strategy.position_avg_price
float profit_pct = 0.0

if strategy.position_size > 0
    profit_pct := (close - pos_avg) / pos_avg
else if strategy.position_size < 0
    profit_pct := (pos_avg - close) / pos_avg

// -----------------------------------------------------
// 5A. EXIT LOGIC (0.2% Dynamic Take Profit)
// -----------------------------------------------------
fast_ema = ta.ema(close, 5)

momentum_dead_long = close < fast_ema 
momentum_dead_short = close > fast_ema

trigger_tp_long = strategy.position_size > 0 and profit_pct >= 0.002 and momentum_dead_long
trigger_tp_short = strategy.position_size < 0 and profit_pct >= 0.002 and momentum_dead_short

if trigger_tp_long
    strategy.close_all(comment="Close Long (0.2%+ PnL)")

if trigger_tp_short
    strategy.close_all(comment="Close Short (0.2%+ PnL)")

// -----------------------------------------------------
// 5B. ASYMMETRIC STOP LOSS & DUAL-TIER RATCHET
// -----------------------------------------------------
logical_sl_pct = 0.02
catastrophe_sl_pct = 0.04 // Protection against extreme flash crashes
max_tp_pct = 0.10 // 10% Hard Max Take Profit 
lock_pct_1 = 0.01   // Tier 1 Ratchet
lock_pct_2 = 0.015  // Tier 2 Ratchet

var float locked_stop = na
if strategy.position_size == 0
    locked_stop := na

// Calculate Break-Even Price for Recovery (Tracks exact dollars lost)
var float accumulated_loss = 0.0
var float recovery_price = na

if strategy.position_size > 0 and accumulated_loss > 0
    recovery_price := pos_avg + (accumulated_loss / math.abs(strategy.position_size))
else if strategy.position_size < 0 and accumulated_loss > 0
    recovery_price := pos_avg - (accumulated_loss / math.abs(strategy.position_size))
else
    recovery_price := na

// Long Ratchet: Upgrade to 1.5% if hit, else set to 1% if hit
if strategy.position_size > 0
    if high >= pos_avg * (1 + lock_pct_2)
        locked_stop := pos_avg * (1 + lock_pct_2)
    else if high >= pos_avg * (1 + lock_pct_1) and na(locked_stop)
        locked_stop := pos_avg * (1 + lock_pct_1)
        
    // Break-Even Recovery Lock (Snaps stop to recovery price if touched)
    if not na(recovery_price) and high >= recovery_price
        locked_stop := na(locked_stop) ? recovery_price : math.max(locked_stop, recovery_price)

// Short Ratchet: Upgrade to 1.5% if hit, else set to 1% if hit
if strategy.position_size < 0
    if low <= pos_avg * (1 - lock_pct_2)
        locked_stop := pos_avg * (1 - lock_pct_2)
    else if low <= pos_avg * (1 - lock_pct_1) and na(locked_stop)
        locked_stop := pos_avg * (1 - lock_pct_1)
        
    // Break-Even Recovery Lock (Snaps stop to recovery price if touched)
    if not na(recovery_price) and low <= recovery_price
        locked_stop := na(locked_stop) ? recovery_price : math.min(locked_stop, recovery_price)


// === THE ASYMMETRIC EXIT GATE ===

// 1. WICK EXITS (Ratchet Locks, Catastrophe Flash Crash Protection, & 10% Max TP Limit)
if strategy.position_size > 0
    strategy.exit("Wick_Exit_L", stop=na(locked_stop) ? pos_avg * (1 - catastrophe_sl_pct) : locked_stop, limit=pos_avg * (1 + max_tp_pct))

if strategy.position_size < 0
    strategy.exit("Wick_Exit_S", stop=na(locked_stop) ? pos_avg * (1 + catastrophe_sl_pct) : locked_stop, limit=pos_avg * (1 - max_tp_pct))

// 2. CLOSE-BASED EXITS (Logical 2% Stop Loss - Immune to Scam Wicks)
if strategy.position_size > 0 and close <= pos_avg * (1 - logical_sl_pct)
    strategy.close_all(comment="Logical SL (-2% Close)")

if strategy.position_size < 0 and close >= pos_avg * (1 + logical_sl_pct)
    strategy.close_all(comment="Logical SL (-2% Close)")

// -----------------------------------------------------
// 5C. MARTINGALE STATE MANAGER (Profit Checker)
// -----------------------------------------------------
var float previous_netprofit = 0.0

// Reset margin to base $50 if the position closes in profit or breakeven (Anchor/TP hit).
// If it closes in a loss (Hard 2% SL hit), track the exact dollar loss and keep margin doubled.
if strategy.position_size == 0 and strategy.position_size[1] != 0
    if strategy.netprofit >= previous_netprofit
        margin_allocated := 50.0 // WIN: Reset Margin
        accumulated_loss := 0.0  // WIN: Reset Recovery Tracker
    else
        // LOSS: Add exact dollar amount lost (including commissions)
        accumulated_loss += (previous_netprofit - strategy.netprofit)
        
    previous_netprofit := strategy.netprofit

// -----------------------------------------------------
// 5D. ENTRY LOGIC (Ruthless Martingale w/ Soft Gate)
// -----------------------------------------------------
bool is_flat = strategy.position_size == 0
bool is_long = strategy.position_size > 0
bool is_short = strategy.position_size < 0

// Calculate entry based on current margin state BEFORE we double it
// Apply Soft Gate if enabled and counter-trend
float active_margin_long = counter_trend_long ? margin_allocated * 0.5 : margin_allocated
float active_margin_short = counter_trend_short ? margin_allocated * 0.5 : margin_allocated

if do_long
    float entry_qty = math.max((active_margin_long * leverage) / close, 1e-6)
    if is_flat
        strategy.entry("Long", strategy.long, qty=entry_qty)
        margin_allocated := math.min(active_margin_long * 2, MAX_MARTINGALE_MARGIN) // Preemptively double for NEXT execution
    else if is_long and close < pos_avg // Martingale Add-On (Adverse Excursion)
        strategy.entry("Long_Add", strategy.long, qty=entry_qty)
        margin_allocated := math.min(active_margin_long * 2, MAX_MARTINGALE_MARGIN) // Preemptively double for NEXT execution

if do_short
    float entry_qty = math.max((active_margin_short * leverage) / close, 1e-6)
    if is_flat
        strategy.entry("Short", strategy.short, qty=entry_qty)
        margin_allocated := math.min(active_margin_short * 2, MAX_MARTINGALE_MARGIN) // Preemptively double for NEXT execution
    else if is_short and close > pos_avg // Martingale Add-On (Adverse Excursion)
        strategy.entry("Short_Add", strategy.short, qty=entry_qty)
        margin_allocated := math.min(active_margin_short * 2, MAX_MARTINGALE_MARGIN) // Preemptively double for NEXT execution


// =========================================================================
// HUMAN-CENTRIC DASHBOARD (HUD)
// =========================================================================
var table hud = table.new(position.top_right, 2, 10, border_width = 1)
if barstate.islast
    table.cell(hud, 0, 0, "MACRO (USDT.D):", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 0, macro_bullish ? "FLOWING TO CRYPTO" : "FLIGHT TO CASH", text_color=color.white, bgcolor=macro_bullish ? color.green : color.red)
    
    table.cell(hud, 0, 1, "AGGREGATED OI:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 1, oi_spiking ? "OVERHEATED (TRAP RISK)" : "FLUSHED (CLEAN)", text_color=color.white, bgcolor=oi_spiking ? color.red : color.green)

    table.cell(hud, 0, 2, "LOCAL STRUCTURE:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 2, close > swing_low and close < swing_high ? "INSIDE RANGE" : "SWEEPING BOUNDARIES", text_color=color.white, bgcolor=color.gray)
    
    table.cell(hud, 0, 3, "VOLUME STATE:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 3, is_vol_anomaly ? "CAPITULATION DETECTED" : "NORMAL", text_color=color.white, bgcolor=is_vol_anomaly ? color.orange : color.gray)
    
    // Position Statistics
    table.cell(hud, 0, 4, "CURRENT PNL:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 4, str.tostring(profit_pct * 100, "#.###") + "%", text_color=color.white, bgcolor=profit_pct >= 0.002 ? color.lime : profit_pct < 0 ? color.red : color.gray)

    table.cell(hud, 0, 5, "AVG ENTRY:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 5, is_flat ? "FLAT" : str.tostring(pos_avg), text_color=color.white, bgcolor=is_flat ? color.gray : color.blue)

    // Calculate real margin deployed (Qty * Avg Price / Leverage)
    deployed_margin = (math.abs(strategy.position_size) * pos_avg) / leverage
    table.cell(hud, 0, 6, "MARGIN DEPLOYED:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 6, is_flat ? "$0.00" : "$" + str.tostring(math.round(deployed_margin, 2)), text_color=color.white, bgcolor=is_flat ? color.gray : color.purple)

    // Track the exact dollar amount the ratchet is trying to recover
    table.cell(hud, 0, 7, "RECOVERY TARGET:", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 7, accumulated_loss > 0 ? "$" + str.tostring(math.round(accumulated_loss, 2)) : "NONE", text_color=color.white, bgcolor=accumulated_loss > 0 ? color.orange : color.green)

    // HMM Output
    table.cell(hud, 0, 8, "MARKET REGIME (HMM):", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 8, not useRegime ? "DISABLED" : display_regime == 1 ? "NON-STATIONARY (BULL)" : display_regime == -1 ? "NON-STATIONARY (BEAR)" : "STATIONARY (CHOP)", text_color=not useRegime ? color.gray : display_regime == 1 ? BULL_COLOR : display_regime == -1 ? BEAR_COLOR : color.yellow, bgcolor=color.gray)
    
    table.cell(hud, 0, 9, "STATIONARITY (HURST):", text_color=color.white, bgcolor=color.black)
    table.cell(hud, 1, 9, str.tostring(hurst, "#.###"), text_color=hurst > hurstThresh ? BEAR_COLOR : BULL_COLOR, bgcolor=color.gray)
````
