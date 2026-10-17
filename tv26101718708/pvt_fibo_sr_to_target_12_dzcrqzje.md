# Pvt Fibo S&R to Target 12

- url: https://www.tradingview.com/script/dzcrqZJe/
- type: indicator
- pine_id: PUB;5e7aa0e5f66e4c7ebd5b7e4b1a8fb149
- version: 1.0

## Description

Pvt Fibo S&R to Target 12 is an institutional-grade breakout and automated target management engine built completely on classical Daily/Weekly/Monthly Pivot Points and Fibonacci Support/Resistance (S/R) levels.

Instead of chasing lagging signals, this script monitors the heavy institutional liquidity pools yoked tightly to major horizontal key levels. By processing live price action through three selectable algorithmic breakout frameworks simultaneously, it provides non-repainting, highly optimized breakout signals coupled with an automated 2-tier take-profit sequence.

🎯 The 3 Multi-Mode Algorithmic Breakout Engines
To adapt to varying market environments, the script operates 3 distinct breakout styles (all active by default to maximize strategic flexibility):

Mode 1 (Volume & Candle Anatomy Expansion): Triggers only when the main pivot line is violated by a candle with significant volume (surpassing its 20-period SMA) and a tightly packed, dominant body ratio (Marubozu style). This mode filters out low-volume institutional retail traps (fakeouts).

Mode 2 (Direct Raw Momentum Breakout): Fires immediately upon a raw crossover/crossunder of the key horizontal line. It completely strips away filters to capitalize on sudden, news-driven, hyper-aggressive market expansions where speed is paramount.

Mode 3 (Safe-Zone Hold Confirmation): A strict trend-verification system designed for conservative execution. Rather than reacting to the initial breach, it tracks market absorption by requiring the price to successfully close and hold on the breakout side for X consecutive bars without slipping back across the line.

💰 Automated Target Lifecycle Management (Target 1-2)
The script is natively engineered with a stateful order sequence controller optimized for webhook routers like WunderTrading. It eliminates manual intervention by actively trailing the position's lifecycle:

The Entry: When any selected Mode condition is met, an entry signal (L1/L2/L3 or S1/S2/S3) prints visually on the chart and triggers the entry webhook message.

Target 1 (Partial Take-Profit): The exact moment the live price breaches the first major Fibonacci extension line (R1 for Longs, S1 for Shorts), a TARGET-1 alert fires. This allows automated bots to scale out partially or move stops to break-even.

Target 2 (Take-Profit & Position Liquidation): When the price strikes the primary institutional target line (R2 for Longs, S2 for Shorts), a TARGET-2 alert fires. Simultaneously, the internal position script state completely resets to zero, terminating the trade lifecycle securely without needing to wait for a lagging opposite signal.

🛠️ Key UI Parameters for Fine-Tuning
Pivot Calculation Period: Shift smoothly between D (Daily), W (Weekly), or M (Monthly) horizontal levels. Daily/Weekly lines are highly recommended for intraday timeframes.

Volume Multiplier: Increase this value (e.g., 1.8 or 2.0) to restrict Mode 1 signals only to massive, institutional-sized volume anomalies.

Min Candle Body Ratio (%): Filter out indecisive dojis or long-wick candles by demanding a solid, determined candle structure during breakout tests.

Safe-Zone Bar Count (X): Adjust the number of consecutive candle closes required for Mode 3 validation before entering.

⚡ Best Testing Environments & Timeframes
Top Performing Timeframes: * 15-Minute (15m) and 1-Hour (1h) charts provide the ultimate balance between asset noise reduction and massive intra-week trend capture.

5-Minute (5m) charts work excellent for scalpers, provided you raise the Volume Multiplier to counter micro-fakeouts.

Optimal Trading Assets: * Cryptocurrencies: High-momentum majors (BTC, ETH) that experience explosive expansion out of tight sideways consolidation ranges.

Indices & Commodities: NASDAQ (NAS100), S&P500, and GOLD (XAU/USD) due to their aggressive trend continuity when major daily key levels break.

Forex Major Pairs: EUR/USD, GBP/USD, and USD/JPY during high-liquidity New York and London session overlaps.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
indicator("Pvt Fibo S&R to Target 12", overlay=true, max_labels_count=500)

// =========================================================================
// --- INPUTS & SETTINGS ---
// =========================================================================
grp_vis = "0. LINE VISIBILITY SETTINGS"
show_main   = input.bool(true, "Show Main Pivot Line (PP)", group=grp_vis)
show_levels = input.bool(true, "Show 3 Upper / 3 Lower Fibo Lines (S/R)", group=grp_vis)

grp_anchor = "1. ANCHOR TIME PERIOD"
pivot_time = input.string("D", "Pivot Calculation Period", options=["D", "W", "M"], group=grp_anchor)

grp_salter = "🎯 SIGNAL TRIGGER SWITCHES (ALL ACTIVE BY DEFAULT)"
use_mode1 = input.bool(true, "Enable Mode 1: Strong Candle + Volume Expansion", group=grp_salter)
use_mode2 = input.bool(true, "Enable Mode 2: Direct Clean Breakout (No Filters)", group=grp_salter)
use_mode3 = input.bool(true, "Enable Mode 3: Safe-Zone Hold Confirmation (X Bars)", group=grp_salter)

grp_filtre = "🛠️ ALGORITHMIC FILTER PARAMETERS"
vol_multiplier = input.float(1.5, "[Mod 1] Volume Multiplier (SMA Ratio)", step=0.1, group=grp_filtre)
body_threshold = input.float(60.0, "[Mod 1] Min Candle Body Ratio (%)", minval=1.0, maxval=100.0, step=5.0, group=grp_filtre)
hold_bars_len  = input.int(3, "[Mod 3] Safe-Zone Bar Count (X)", minval=1, group=grp_filtre)
block_same     = input.bool(true, "Block Consecutive Same Direction Signals", group=grp_filtre)
same_dir_wait  = input.int(12, "Min Rest Period Between Same Signals (Bars)", minval=0, group=grp_filtre)
sig_delay      = input.int(0, "Signal Execution Delay (Bars)", minval=0, group=grp_filtre)

grp_bot = "🤖 AUTOMATED WEBHOOK ALERTS (TARGET MANAGEMENT)"
txt_long_ac     = input.string("ENTER-LONG", "Long Entry Message", group=grp_bot)
txt_long_kapat  = input.string("EXIT-LONG", "Long Exit (Stop) Message", group=grp_bot)
txt_short_ac    = input.string("ENTER-SHORT", "Short Entry Message", group=grp_bot)
txt_short_kapat = input.string("EXIT-SHORT", "Short Exit (Stop) Message", group=grp_bot)
txt_target1     = input.string("TARGET-1", "Take Profit 1 Message (R1/S1)", group=grp_bot)
txt_target2     = input.string("TARGET-2", "Take Profit 2 / Close Position (R2/S2)", group=grp_bot)

// =========================================================================
// --- MATHEMATICAL PIVOT & FIBONACCI CALCULATIONS ---
// =========================================================================
h_val = request.security(syminfo.tickerid, pivot_time, high[1])
l_val = request.security(syminfo.tickerid, pivot_time, low[1])
c_val = request.security(syminfo.tickerid, pivot_time, close[1])

main_pivot = (h_val + l_val + c_val) / 3
ranr = h_val - l_val

r1 = main_pivot + 0.382 * ranr
r2 = main_pivot + 0.618 * ranr
r3 = main_pivot + 1.000 * ranr

s1 = main_pivot - 0.382 * ranr
s2 = main_pivot - 0.618 * ranr
s3 = main_pivot - 1.000 * ranr

// Continuous dynamic plotting
plot(show_main ? main_pivot : na, "Main Pivot", color=color.yellow, linewidth=3)

plot(show_levels ? r3 : na, "Resistance 3", color=color.new(color.red, 30), linewidth=1)
plot(show_levels ? r2 : na, "Resistance 2", color=color.new(color.orange, 30), linewidth=2)
plot(show_levels ? r1 : na, "Resistance 1", color=color.new(color.fuchsia, 30), linewidth=1)

plot(show_levels ? s1 : na, "Support 1", color=color.new(color.teal, 30), linewidth=1)
plot(show_levels ? s2 : na, "Support 2", color=color.new(color.blue, 30), linewidth=2)
plot(show_levels ? s3 : na, "Support 3", color=color.new(color.navy, 30), linewidth=1)

// =========================================================================
// --- BREAKOUT ENGINE METRICS ---
// =========================================================================
raw_cross_up   = ta.crossover(close, main_pivot)
raw_cross_down = ta.crossunder(close, main_pivot)

// Mode 1 Logic
vol_avg = ta.sma(volume, 20)
is_strong_volume = volume > (vol_avg * vol_multiplier)
candle_total_range = high - low
candle_body_range  = math.abs(close - open)
body_percentage = candle_total_range > 0 ? (candle_body_range / candle_total_range) * 100 : 0
is_strong_body = body_percentage >= body_threshold
is_strong_breakout = is_strong_volume and is_strong_body

mode1_L = raw_cross_up and is_strong_breakout
mode1_S = raw_cross_down and is_strong_breakout

// Mode 2 Logic
mode2_L = raw_cross_up
mode2_S = raw_cross_down

// Mode 3 Logic
var int bars_above_line = 0
var int bars_below_line = 0

if close > main_pivot
    bars_above_line := bars_above_line + 1
    bars_below_line := 0
else if close < main_pivot
    bars_below_line := bars_below_line + 1
    bars_above_line := 0
else
    bars_above_line := 0
    bars_below_line := 0

mode3_L = (bars_above_line == hold_bars_len)
mode3_S = (bars_below_line == hold_bars_len)

// --- MULTI-MODE SIGNAL SYNTHESIS ---
final_trigger_L = (use_mode1 and mode1_L) or (use_mode2 and mode2_L) or (use_mode3 and mode3_L)
final_trigger_S = (use_mode1 and mode1_S) or (use_mode2 and mode2_S) or (use_mode3 and mode3_S)

// --- DEBOUNCING & BAR COUNTER DELAY ENGINE ---
var int long_counter = -1
var int short_counter = -1

if final_trigger_L
    long_counter := 0
if long_counter >= 0
    long_counter := long_counter + 1

if final_trigger_S
    short_counter := 0
if short_counter >= 0
    short_counter := short_counter + 1

bool boga_tetik = (long_counter == sig_delay + 1)
bool ayi_tetik  = (short_counter == sig_delay + 1)

// =========================================================================
// --- SMART MEMORY & NOISE REDUCTION CORES ---
// =========================================================================
bool plot_L = false
bool plot_S = false
var int last_dir = 0
var int last_L_bar = 0
var int last_S_bar = 0

if boga_tetik and barstate.isconfirmed
    if (not block_same or last_dir != 1) and (bar_index - last_L_bar >= same_dir_wait)
        plot_L := true
        last_dir := 1
        last_L_bar := bar_index
    long_counter := -1 

if ayi_tetik and barstate.isconfirmed
    if (not block_same or last_dir != -1) and (bar_index - last_S_bar >= same_dir_wait)
        plot_S := true
        last_dir := -1
        last_S_bar := bar_index
    short_counter := -1 

// Visualizers
plotshape(plot_L and use_mode1, "LONG Mode 1", shape.labelup, location.belowbar, color=#00FF00, text="L1", textcolor=color.black, size=size.normal)
plotshape(plot_L and use_mode2 and not use_mode1, "LONG Mode 2", shape.labelup, location.belowbar, color=#00FF00, text="L2", textcolor=color.black, size=size.normal)
plotshape(plot_L and use_mode3 and not use_mode1 and not use_mode2, "LONG Mode 3", shape.labelup, location.belowbar, color=#00FF00, text="L3", textcolor=color.black, size=size.normal)

plotshape(plot_S and use_mode1, "SHORT Mod 1", shape.labeldown, location.abovebar, color=#FF0000, text="S1", textcolor=color.white, size=size.normal)
plotshape(plot_S and use_mode2 and not use_mode1, "SHORT Mod 2", shape.labeldown, location.abovebar, color=#FF0000, text="S2", textcolor=color.white, size=size.normal)
plotshape(plot_S and use_mode3 and not use_mode1 and not use_mode2, "SHORT Mod 3", shape.labeldown, location.abovebar, color=#FF0000, text="S3", textcolor=color.white, size=size.normal)

// =========================================================================
// --- TARGET MANAGEMENT & POSITION LIFECYCLE ---
// =========================================================================
var int pozisyon = 0
var bool long_t1_hit = false
var bool short_t1_hit = false

// Reset target status when a new opposite position triggers
if plot_L
    long_t1_hit := false
if plot_S
    short_t1_hit := false

// Trigger entry signals and handle target evaluations
if plot_L and pozisyon != 1
    if pozisyon == -1
        alert(txt_short_kapat, alert.freq_once_per_bar_close)
    alert(txt_long_ac, alert.freq_once_per_bar_close)
    pozisyon := 1

if plot_S and pozisyon != -1
    if pozisyon == 1
        alert(txt_long_kapat, alert.freq_once_per_bar_close)
    alert(txt_short_ac, alert.freq_once_per_bar_close)
    pozisyon := -1

// Dynamic Profit Taking Checks (Target 1 & Target 2)
if pozisyon == 1 and barstate.isconfirmed
    if ta.crossover(high, r1) and not long_t1_hit
        alert(txt_target1, alert.freq_once_per_bar_close)
        long_t1_hit := true
    if ta.crossover(high, r2)
        alert(txt_target2, alert.freq_once_per_bar_close)
        pozisyon := 0 // Position completely closed at Target 2

if pozisyon == -1 and barstate.isconfirmed
    if ta.crossunder(low, s1) and not short_t1_hit
        alert(txt_target1, alert.freq_once_per_bar_close)
        short_t1_hit := true
    if ta.crossunder(low, s2)
        alert(txt_target2, alert.freq_once_per_bar_close)
        pozisyon := 0 // Position completely closed at Target 2
````
