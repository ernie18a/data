<!-- tradingview-pine-id: PUB;046d4c4a7c9e43dea5c3feae3bdecf90 -->
<!-- tradingviewscripts-format: 1 -->
# Sovereign Horizon Matrix (SHM) v8.0

Source: https://www.tradingview.com/script/wVNfdkHu-Sovereign-Horizon-Matrix-SHM-v8-0/

## Description

SHM Bidirectional v8.0

⚔️ Executive Summary (SHM v8.0)
SHM Bidirectional v8.0 is an institutional-grade, macro trend-following execution matrix engineered for higher-timeframe swing trading on the Daily chart.
Built primarily for Bitcoin (BTC)—and modeled after real-world Coinbase Nano Bitcoin Futures execution mechanics—SHM v8.0 combines an 8-pillar technical framework with strict, non-repainting risk management. It eliminates chart fatigue and emotional bias, allowing Institutional and Retail traders to capture major trends while keeping their time free for the gym, work, and family.
* Primary Design: Daily Chart Swing Trading & Automation-Ready Execution Engine
* Core Focus: Bitcoin (BTC) macro expansion cycles (Fully adjustable for Altcoins, Futures, and Equities)
* Key Mechanics: Dual Baseline (63/480 WMA), Dual Break & Retest Engines, RSI Momentum Gate, and 3-Module Risk Engine
* Backtest Snapshot (BTC Daily): 7.617 Profit Factor | 18.85% Max Drawdown | 124.49% CAGR (56 trades)

⚙️ Purpose, Asset Focus & Time-Saving Design
The Purpose:
SHM v8.0 was created to solve a fundamental trading challenge: eliminating emotional bias, filtering out bad breakouts, and enforcing strict, automated risk management across volatile market cycles. The goal is to provide traders with a clean, repeatable strategy that captures real trends while shielding capital during choppy sideways movement.
Primary Target & Chart Focus:
* Primary Asset: Engineered primarily for Bitcoin (BTC) to handle its unique cycles, volatility spikes, and macro trend expansions.
* Daily Chart Focus: Designed specifically around higher-timeframe swing trading on the Daily chart. This makes it ideal for traders who don't have the time to sit in front of charts all day managing intraday noise.
* Full Adjustability: Works seamlessly across other crypto pairs, futures, and stocks. You have complete freedom to tweak all parameters—WMA lengths, envelope percentages, RSI filters, and stop distances—to match any market or timeframe.

⚙️ Core System Architecture
SHM v8.0 functions as a macro trend-following execution matrix. Because every signal and exit runs on fixed non-repainting calculations, it can also operate as a quantitative trend follower when linked to automated webhooks or trading bots.
1. Dual Baseline Framework: Combines a 63 Fast Institutional WMA with a 480 Macro Baseline WMA Tide filter to keep daily trades aligned with macro market structure.
2. Dual Break & Retest (B&R) Engine: Dedicated Micro (63 WMA) and Macro (480 WMA) engines track depth, touch penetration, and bounce candles to filter out false breakouts.
3. Timeframe-Locked RSI Momentum Gate: Verifies directional expansion so you don't buy near local tops or short into oversold bottoms.
4. Triple-Band Envelope System: Uses multi-layer WMA volatility bands to highlight expansion channels and potential exhaustion zones visually.

🛡️ SHM Modular Risk Engine
The script features three non-repainting exit modules:
* Module 1 (Flat TP to Breakeven): Moves your stop loss straight to entry price once a set profit percentage target is reached.
* Module 2 (65 WMA Ribbon Trail): Dynamically trails stops along the 65 WMA ribbon floor or ceiling during sustained trends.
* Module 3 (Candle-Close Trail): Steps your stop loss behind recent candle closes to lock in profits during sharp extensions.

📊 Default Properties, Backtest Metrics & Real-World Execution
To maintain total transparency and adhere to TradingView backtesting standards, default strategy Properties reflect realistic exchange execution mechanics (modeled after Coinbase Nano Bitcoin Futures / Derivatives environment settings):
* Initial Capital: $717 USD
* Position Sizing: 80% of Equity (default size is set higher for compounding, but can easily be adjusted in settings to match your personal risk tolerance)
* Leverage: 4x Long / ~3x Short
* Commission: 0.075% per trade
* Slippage & Delay: 30 ticks slippage / 1 tick order execution delay
* Execution Realism: Calculates on bar closes, order fills, and real-time bar ticks.

📈 Historical Performance Context (Daily Chart)
* Historical Data Source: Because newer derivatives tickers lack long-term price history, the full historical aggregate BTC chart was used to provide maximum sample depth.
* Trade Frequency: Running on the Daily chart generates a focused sample size of 56 trades across the dataset. While it doesn't hit the high trade counts of lower-timeframe scalpers, the efficiency of the framework stands out:
    * Profit Factor: 7.617
    * Max Equity Drawdown: 18.85%
    * Average Winning Trade: +56.41% vs. Average Loss: -3.29%
    * Compound Annual Growth Rate (CAGR): 124.49%

📌 Usage & Automation
* Execution Modes: Toggle between pure Price Action Baseline entries, Break & Retest Standalone entries, or Combined execution in the input menu.
* Automation Ready: All order conditions and trailing exits execute instantly on confirmed bar closes, making SHM fully compatible with webhook automation tools.

⚠️ Disclaimer & Compliance:
This script is published for educational and technical analysis backtesting purposes only. Past backtested results do not guarantee future performance. Always apply strict risk management and adjust commission, slippage, and position sizing settings to match your specific execution platform prior to live deployment.

---

## Source Code

````pine
//@version=6
strategy("Sovereign Horizon Matrix (SHM) v8.0", overlay=true, max_labels_count=500, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=80, pyramiding=0, commission_type=strategy.commission.percent, commission_value=0.075, slippage=30, margin_long=25, margin_short=33.3)

// ==========================================
// 1. INPUTS & CONFIGURATION
// ==========================================
// Core Framework Settings
var_fast_wma_len = input.int(63, title="Fast Institutional WMA Length", group="Core Framework")
var_slow_wma_len = input.int(480, title="Macro Baseline WMA Length", group="Core Framework")
macro_envel_pct  = input.float(1.0, title="Macro 480 Envelope %", group="Core Framework") / 100.0
fast_envel_pct   = input.float(0.75, title="Fast 65 Envelope %", group="Core Framework") / 100.0
sensitivity      = input.int(41, title="Structural Sensitivity Filter", group="Core Framework")
src              = input.source(ohlc4, title="Price Source Data", group="Core Framework")
wma_offset       = input.int(1, title="WMA Visual Offset", minval=-500, maxval=500, group="Core Framework", tooltip="Shifts WMA plots right (positive) or left (negative) visually.")

// Break & Retest (B&R) Engine Execution Settings
var string G_BNR_EXEC = "B&R Execution Matrix"
bnr_exec_mode = input.string("Combined (Baseline OR B&R)", title="B&R Signal Execution Mode", options=["Visual Only", "Standalone (B&R Only)", "Combined (Baseline OR B&R)"], group=G_BNR_EXEC, tooltip="Select how Break & Retest signals interact with strategy entries.")

// Micro Break & Retest Engine (Fast WMA)
var string G_MICRO    = "Micro B&R Engine (Fast WMA)"
use_micro_visuals     = input.bool(true, "Enable Micro B&R Visual Labels", group=G_MICRO)
micro_proximity_pct   = input.float(3.5, "Micro Proximity Depth (%)", minval=0.1, step=0.1, tooltip="Allows retests to trigger within X% distance of the Fast WMA.", group=G_MICRO) / 100.0
micro_touch_depth_pct = input.float(0.7, "Micro WMA Touch Depth (%)", minval=0.0, step=0.1, tooltip="Maximum allowed penetration depth past Fast WMA during retest.", group=G_MICRO) / 100.0
micro_min_bars        = input.int(1, "Micro Min Bars After Break", minval=1, tooltip="Minimum candles required after breakout before retest triggers.", group=G_MICRO)
micro_max_bars        = input.int(4, "Micro Max Retest Window (Bars)", minval=3, tooltip="Max bars allowed for pullbacks.", group=G_MICRO)

// Macro Break & Retest Engine (Macro Baseline WMA)
var string G_MACRO    = "Macro B&R Engine (Macro Baseline WMA)"
use_macro_visuals     = input.bool(true, "Enable Macro B&R Visual Labels", group=G_MACRO)
macro_proximity_pct   = input.float(1.0, "Macro Proximity Depth (%)", minval=0.1, step=0.1, tooltip="Allows retests to trigger within X% distance of the Macro WMA.", group=G_MACRO) / 100.0
macro_touch_depth_pct = input.float(1.5, "Macro WMA Touch Depth (%)", minval=0.0, step=0.1, tooltip="Maximum allowed penetration depth past Macro WMA during retest.", group=G_MACRO) / 100.0
macro_min_bars        = input.int(1, "Macro Min Bars After Break", minval=1, tooltip="Minimum candles required after breakout before retest triggers.", group=G_MACRO)
macro_max_bars        = input.int(4000, "Macro Max Retest Window (Bars)", minval=3, tooltip="Max bars allowed for pullbacks.", group=G_MACRO)

// EXPERIMENTAL BASELINE PRICE ACTION TOGGLE MODULE
var string G_PA_TEST = "Experimental Baseline PA Module"
use_pa_test          = input.bool(true, title="Enable Experimental Baseline PA Module", tooltip="Turn ON to bypass standard entries and isolate pure line-crossing mechanics.", group=G_PA_TEST)
use_body_trigger     = input.bool(true, title="► Use Candle Body Trigger (Close Cross)", tooltip="Trigger entries when the candle CLOSE crosses the Fast WMA line.", group=G_PA_TEST)
use_wick_trigger     = input.bool(true, title="► Use Candle Wick Trigger (High/Low Cross)", tooltip="Trigger entries immediately when the candle WICK (High/Low) crosses the Fast WMA line.", group=G_PA_TEST)

// Idea 2: Macro Tide Filter (480 WMA Rules)
use_macro_tide = input.bool(false, title="Enable Macro Tide Filter", tooltip="Only allows BUYs above the 480 WMA and SELLs below the 480 WMA.", group="Idea 2: Macro Tide")

// Idea 3: RSI Momentum Matrix Filter (With Timeframe Locking)
use_rsi_filter  = input.bool(true, title="Enable RSI Momentum Filter", tooltip="Filters entries using momentum thresholds to prevent chasing exhausted moves.", group="Idea 3: RSI Filter")
rsi_tf          = input.timeframe("1440", title="Locked RSI Timeframe", tooltip="Select '1440' (24 Hours) to lock RSI to a 24h rolling period, or change to any timeframe. Leave empty or match chart timeframe to disable locking.", group="Idea 3: RSI Filter")
rsi_len         = input.int(33, title="RSI Lookback Period", group="Idea 3: RSI Filter")
rsi_long_min    = input.float(42.0, title="Min RSI for Longs (Velocity Gate)", group="Idea 3: RSI Filter")
rsi_long_max    = input.float(48.0, title="Max RSI for Longs (Exhaustion Cap)", group="Idea 3: RSI Filter")
rsi_short_max   = input.float(52.0, title="Max RSI for Shorts (Velocity Gate)", group="Idea 3: RSI Filter")
rsi_short_min   = input.float(46.0, title="Min RSI for Shorts (Exhaustion Floor)", group="Idea 3: RSI Filter")

// Supertrend Integration Settings
st_atr_len    = input.int(1, title="Supertrend ATR Length", group="Supertrend Extensions")
st_factor     = input.float(0.0, title="Supertrend Multiplier", group="Supertrend Extensions")
link_strategy = input.bool(false, title="Link Main Supertrend to Strategy Entry/Exit?", group="Supertrend Extensions")

// Risk Management Settings
var string G_RISK = "Risk Engine"
sl_anchor = input.string("Actual Execution Price", title="Stop Loss Reference Anchor", options=["Trigger Candle Extreme", "Actual Execution Price"], group=G_RISK, tooltip="Choose whether SL % is measured from signal candle High/Low or your exact fill price.")
sl_pct    = input.float(3.0, title="Stop Loss Buffer (%)", tooltip="Percentage distance for stop loss calculation.", group=G_RISK) / 100.0

// ESM MODULAR RISK ENGINE INPUTS
use_reentry_reset = input.bool(false, title="Enable Same-Direction Re-Entry Reset", tooltip="When active, triggering a new signal in the same direction closes the existing trade and resets entry/stop levels at current price.", group=G_RISK)
var string G_BE     = "ESM Module 1: Flat TP to Breakeven"
use_be              = input.bool(true, "Enable Breakeven on Flat TP", group=G_BE, tooltip="Snaps your stop loss to your exact entry price once a flat percentage target is touched.")
be_tp_pct           = input.float(77.2, "Flat TP Profit Target (%)", minval=0.0, step=0.1, group=G_BE)

var string G_WMA    = "ESM Module 2: 65 WMA Trend Line Trail"
use_wma_trail       = input.bool(false, "Enable 65 WMA Ribbon Trail", group=G_WMA, tooltip="Trails your position directly beneath the active green trend floor or above the red trend ceiling.")
wma_len             = input.int(65, "WMA Lookback Period", group=G_WMA)
wma_buffer_pct      = input.float(0.5, "WMA Line Percentage Buffer (%)", minval=0.0, step=0.1, group=G_WMA)

var string G_CANDLE = "ESM Module 3: Candle-Close Percentage Trail"
use_candle_trail    = input.bool(true, "Enable Candle-Close Trail", group=G_CANDLE, tooltip="Steps your stop loss up or down behind every single closed candle at a flexible percentage distance.")
candle_trail_pct    = input.float(77.2, "Candle Trail Percentage Distance (%)", minval=0.0, step=0.1, group=G_CANDLE)

// ==========================================
// 2. INDICATOR MATHEMATICS & FILTERS
// ==========================================
// Core WMAs
fast_wma = ta.wma(src, var_fast_wma_len)
slow_wma = ta.wma(src, var_slow_wma_len)

// Macro 480 Envelopes
upper_envelope = slow_wma * (1 + macro_envel_pct)
lower_envelope = slow_wma * (1 - macro_envel_pct)

// Triple Band 65 WMA Envelopes
fast_upper_envelope = fast_wma * (1 + fast_envel_pct)
fast_lower_envelope = fast_wma * (1 - fast_envel_pct)

// Sensitivity Filter
filter_ma = ta.sma(src, sensitivity)

// Macro Tide Logic (480 WMA Architectural Bias)
macro_bullish = not use_macro_tide or (close > slow_wma)
macro_bearish = not use_macro_tide or (close < slow_wma)

// Timeframe-Locked RSI Engine Logic
rsi_raw = ta.rsi(src, rsi_len)
rsi_val = request.security(syminfo.tickerid, rsi_tf, rsi_raw[1], barmerge.gaps_off, barmerge.lookahead_off)

rsi_long_ok  = not use_rsi_filter or (rsi_val >= rsi_long_min and rsi_val <= rsi_long_max)
rsi_short_ok = not use_rsi_filter or (rsi_val <= rsi_short_max and rsi_val >= rsi_short_min)

// Shared ATR Component
st_atr = ta.atr(st_atr_len)

// --- Engine 1: Main Fast WMA Supertrend ---
src_up = fast_wma - (st_factor * st_atr)
src_dn = fast_wma + (st_factor * st_atr)
var float up_band = 0.0
var float dn_band = 0.0
var int direction = 1
up_band := nz(up_band[1]) == 0.0 ? src_up : (close[1] > up_band[1] ? math.max(src_up, up_band[1]) : src_up)
dn_band := nz(dn_band[1]) == 0.0 ? src_dn : (close[1] < dn_band[1] ? math.min(src_dn, dn_band[1]) : src_dn)
direction := close > dn_band[1] ? -1 : (close < up_band[1] ? 1 : nz(direction[1], 1))
supertrend = direction == -1 ? up_band : dn_band

// --- Engine 2: Upper Fast WMA Envelope Supertrend ---
src_up_u = fast_upper_envelope - (st_factor * st_atr)
src_dn_u = fast_upper_envelope + (st_factor * st_atr)
var float up_band_u = 0.0
var float dn_band_u = 0.0
var int direction_u = 1
up_band_u := nz(up_band_u[1]) == 0.0 ? src_up_u : (close[1] > up_band_u[1] ? math.max(src_up_u, up_band_u[1]) : src_up_u)
dn_band_u := nz(dn_band_u[1]) == 0.0 ? src_dn_u : (close[1] < dn_band_u[1] ? math.min(src_dn_u, dn_band_u[1]) : src_dn_u)
direction_u := close > dn_band_u[1] ? -1 : (close < up_band_u[1] ? 1 : nz(direction_u[1], 1))
supertrend_u = direction_u == -1 ? up_band_u : dn_band_u

// --- Engine 3: Lower Fast WMA Envelope Supertrend ---
src_up_l = fast_lower_envelope - (st_factor * st_atr)
src_dn_l = fast_lower_envelope + (st_factor * st_atr)
var float up_band_l = 0.0
var float dn_band_l = 0.0
var int direction_l = 1
up_band_l := nz(up_band_l[1]) == 0.0 ? src_up_l : (close[1] > up_band_l[1] ? math.max(src_up_l, up_band_l[1]) : src_up_l)
dn_band_l := nz(dn_band_l[1]) == 0.0 ? src_dn_l : (close[1] < dn_band_l[1] ? math.min(src_dn_l, dn_band_l[1]) : src_dn_l)
direction_l := close > dn_band_l[1] ? -1 : (close < up_band_l[1] ? 1 : nz(direction_l[1], 1))
supertrend_l = direction_l == -1 ? up_band_l : dn_band_l

st_bullish = (direction == -1)
st_bearish = (direction == 1)

// =========================================================================
// DUAL PROXIMITY BREAK & RETEST MATH ENGINES WITH TOUCH DEPTH
// =========================================================================

// --- A. MICRO RETEST ENGINE (Fast WMA) ---
var int bars_since_micro_bull = 0
var int bars_since_micro_bear = 0

if ta.crossover(close, fast_wma)
    bars_since_micro_bull := 0
else
    bars_since_micro_bull += 1

if ta.crossunder(close, fast_wma)
    bars_since_micro_bear := 0
else
    bars_since_micro_bear += 1

bool micro_bull_touch  = (bars_since_micro_bull >= micro_min_bars) and (bars_since_micro_bull <= micro_max_bars) and (low <= fast_wma * (1 + micro_proximity_pct)) and (low >= fast_wma * (1 - micro_touch_depth_pct))
bool micro_bull_bounce = micro_bull_touch and (close > open) and (close > fast_wma)

bool micro_bear_touch  = (bars_since_micro_bear >= micro_min_bars) and (bars_since_micro_bear <= micro_max_bars) and (high >= fast_wma * (1 - micro_proximity_pct)) and (high <= fast_wma * (1 + micro_touch_depth_pct))
bool micro_bear_bounce = micro_bear_touch and (close < open) and (close < fast_wma)

var bool micro_bull_fired = false
if bars_since_micro_bull == 0
    micro_bull_fired := false

bool signal_micro_bull = false
if micro_bull_bounce and not micro_bull_fired
    signal_micro_bull := true
    micro_bull_fired  := true

var bool micro_bear_fired = false
if bars_since_micro_bear == 0
    micro_bear_fired := false

bool signal_micro_bear = false
if micro_bear_bounce and not micro_bear_fired
    signal_micro_bear := true
    micro_bear_fired  := true


// --- B. MACRO RETEST ENGINE (Macro Baseline WMA / 480) ---
var int bars_since_macro_bull = 0
var int bars_since_macro_bear = 0

if ta.crossover(close, slow_wma)
    bars_since_macro_bull := 0
else
    bars_since_macro_bull += 1

if ta.crossunder(close, slow_wma)
    bars_since_macro_bear := 0
else
    bars_since_macro_bear += 1

bool macro_bull_touch  = (bars_since_macro_bull >= macro_min_bars) and (bars_since_macro_bull <= macro_max_bars) and (low <= slow_wma * (1 + macro_proximity_pct)) and (low >= slow_wma * (1 - macro_touch_depth_pct))
bool macro_bull_bounce = macro_bull_touch and (close > open) and (close > slow_wma)

bool macro_bear_touch  = (bars_since_macro_bear >= macro_min_bars) and (bars_since_macro_bear <= macro_max_bars) and (high >= slow_wma * (1 - macro_proximity_pct)) and (high <= slow_wma * (1 + macro_touch_depth_pct))
bool macro_bear_bounce = macro_bear_touch and (close < open) and (close < slow_wma)

var bool macro_bull_fired = false
if bars_since_macro_bull == 0
    macro_bull_fired := false

bool signal_macro_bull = false
if macro_bull_bounce and not macro_bull_fired
    signal_macro_bull := true
    macro_bull_fired  := true

var bool macro_bear_fired = false
if bars_since_macro_bear == 0
    macro_bear_fired := false

bool signal_macro_bear = false
if macro_bear_bounce and not macro_bear_fired
    signal_macro_bear := true
    macro_bear_fired  := true

// ==========================================
// 3. PLOTS & VISUALIZATION
// ==========================================
plot(slow_wma, color=color.rgb(120, 123, 134), linewidth=1, title="480 WMA Tide Line", offset=wma_offset)
plot(upper_envelope, color=color.rgb(250, 170, 104, 50), linewidth=1, title="Upper 480 Envelope", offset=wma_offset)
plot(lower_envelope, color=color.rgb(250, 170, 104, 50), linewidth=1, title="Lower 480 Envelope", offset=wma_offset)

// --- Fast WMA Matrix Cloud Visual ---
plot_fast_up = plot(fast_upper_envelope, color=color.new(#22ab94, 100), title="Fast Upper Boundary (Invisible)", offset=wma_offset)
plot_fast_dn = plot(fast_lower_envelope, color=color.new(#22ab94, 100), title="Fast Lower Boundary (Invisible)", offset=wma_offset)
plot(fast_wma, color=color.new(#22ab94, 60), title="Fast Mid Baseline", offset=wma_offset)
fill(plot_fast_up, plot_fast_dn, color=color.new(#22ab94, 90), title="Fast WMA Matrix Cloud")

bodyMiddle = plot((open + close) / 2, display=display.none, title="Candle Midpoint")

upTrend = plot(direction < 0 ? supertrend : na, "Main Up Trend", color=color.rgb(184, 184, 184, 50), style=plot.style_linebr, linewidth=1, offset=wma_offset)
downTrend = plot(direction < 0 ? na : supertrend, "Main Down Trend", color=color.rgb(184, 184, 184, 50), style=plot.style_linebr, linewidth=1, offset=wma_offset)
fill(bodyMiddle, upTrend, color=color.rgb(34, 171, 148, 92), title="Main Bullish Cloud")
fill(bodyMiddle, downTrend, color=color.rgb(238, 32, 0, 92), title="Main Bearish Cloud")

upTrend_u = plot(direction_u < 0 ? supertrend_u : na, "Upper Env Up Trend", color=#22ab943f, style=plot.style_linebr, linewidth=1, offset=wma_offset)
downTrend_u = plot(direction_u < 0 ? na : supertrend_u, "Upper Env Down Trend", color=#ee2000, style=plot.style_linebr, linewidth=2, offset=wma_offset)
fill(bodyMiddle, upTrend_u, color=color.rgb(34, 171, 148, 95), title="Upper Env Bullish Cloud")
fill(bodyMiddle, downTrend_u, color=color.rgb(238, 32, 0, 95), title="Upper Env Bearish Cloud")

upTrend_l = plot(direction_l < 0 ? supertrend_l : na, "Lower Env Up Trend", color=#22ab94, style=plot.style_linebr, linewidth=2, offset=wma_offset)
downTrend_l = plot(direction_l < 0 ? na : supertrend_l, "Lower Env Down Trend", color=color.rgb(238, 32, 0, 75), style=plot.style_linebr, linewidth=1, offset=wma_offset)
fill(bodyMiddle, upTrend_l, color=color.rgb(34, 171, 148, 95), title="Lower Env Bullish Cloud")
fill(bodyMiddle, downTrend_l, color=color.rgb(238, 32, 0, 95), title="Lower Env Bearish Cloud")

// Micro B&R Visual Labels
plotshape(use_micro_visuals and signal_micro_bull, title="Micro B&R Buy", style=shape.triangleup, location=location.belowbar, color=color.new(#00E676, 20), text="µB&R\nBUY", textcolor=color.rgb(54, 58, 69, 100), size=size.tiny)
plotshape(use_micro_visuals and signal_micro_bear, title="Micro B&R Sell", style=shape.triangledown, location=location.abovebar, color=color.new(#FF1744, 20), text="µB&R\nSELL", textcolor=color.rgb(255, 255, 255, 100), size=size.tiny)

// Macro B&R Visual Labels
plotshape(use_macro_visuals and signal_macro_bull, title="MACRO B&R Buy", style=shape.triangleup, location=location.belowbar, color=color.new(#2962FF, 0), text="MACRO B&R\nBUY", textcolor=color.rgb(255, 255, 255, 100), size=size.small)
plotshape(use_macro_visuals and signal_macro_bear, title="MACRO B&R Sell", style=shape.triangledown, location=location.abovebar, color=color.new(#FF6D00, 0), text="MACRO B&R\nSELL", textcolor=color.rgb(255, 255, 255, 100), size=size.small)

// ==========================================
// 4. STRATEGY EXECUTION ENGINE & RISK MATRIX
// ==========================================
// --- PURE BASELINE GEOMETRY CALCULATIONS ---
body_cross_fast_up   = ta.crossover(close, fast_wma)
body_cross_slow_up   = ta.crossover(close, slow_wma)
body_break_up        = body_cross_fast_up or body_cross_slow_up

body_cross_fast_dn   = ta.crossunder(close, fast_wma)
body_cross_slow_dn   = ta.crossunder(close, slow_wma)
body_break_down      = body_cross_fast_dn or body_cross_slow_dn

wick_cross_fast_up   = ta.crossover(high, fast_wma)
wick_cross_slow_up   = ta.crossover(high, slow_wma)
wick_break_up        = wick_cross_fast_up or wick_cross_slow_up

wick_cross_fast_dn   = ta.crossunder(low, fast_wma)
wick_cross_slow_dn   = ta.crossunder(low, slow_wma)
wick_break_down      = wick_cross_fast_dn or wick_cross_slow_dn

// --- DYNAMIC BASELINE ROUTING LAYER ---
bool raw_breakout_long  = false
bool raw_breakout_short = false

if use_pa_test
    bool has_active_toggle = use_body_trigger or use_wick_trigger
    
    if has_active_toggle
        raw_breakout_long  := (use_body_trigger and body_break_up) or (use_wick_trigger and wick_break_up)
        raw_breakout_short := (use_body_trigger and body_break_down) or (use_wick_trigger and wick_break_down)
    else
        raw_breakout_long  := body_break_up
        raw_breakout_short := body_break_down
else
    raw_breakout_long  := body_break_up
    raw_breakout_short := body_break_down

// B&R Signal Consolidation
bool bnr_bull_signal = signal_micro_bull or signal_macro_bull
bool bnr_bear_signal = signal_micro_bear or signal_macro_bear

// Execution Mode Selector Matrix
bool trigger_long  = false
bool trigger_short = false

if bnr_exec_mode == "Visual Only"
    trigger_long  := raw_breakout_long
    trigger_short := raw_breakout_short
else if bnr_exec_mode == "Standalone (B&R Only)"
    trigger_long  := bnr_bull_signal
    trigger_short := bnr_bear_signal
else // "Combined (Baseline OR B&R)"
    trigger_long  := raw_breakout_long or bnr_bull_signal
    trigger_short := raw_breakout_short or bnr_bear_signal

// Incorporate testing triggers seamlessly into macro filters
longCondition  = (link_strategy ? (trigger_long and st_bullish and close > filter_ma) : (trigger_long and close > filter_ma)) and macro_bullish and rsi_long_ok
shortCondition = (link_strategy ? (trigger_short and st_bearish and close < filter_ma) : (trigger_short and close < filter_ma)) and macro_bearish and rsi_short_ok

// Persistent Risk Engine State Variables
var float active_sl = na
var int trade_state = 0 // 1 = Active Long, -1 = Active Short, 0 = Flat

// --- STRATEGY ENTRIES ---
if (longCondition)
    strategy.entry("Buy", strategy.long)
    if sl_anchor == "Trigger Candle Extreme"
        active_sl := low * (1 - sl_pct)
    trade_state := 1

if (shortCondition)
    strategy.entry("Sell", strategy.short)
    if sl_anchor == "Trigger Candle Extreme"
        active_sl := high * (1 + sl_pct)
    trade_state := -1

// --- DYNAMIC STOP LOSS RE-ANCHORING ON BAR EXECUTION ---
if strategy.position_size > 0 and strategy.position_size[1] <= 0
    if sl_anchor == "Actual Execution Price"
        active_sl := strategy.position_avg_price * (1 - sl_pct)

if strategy.position_size < 0 and strategy.position_size[1] >= 0
    if sl_anchor == "Actual Execution Price"
        active_sl := strategy.position_avg_price * (1 + sl_pct)

// --- INITIAL GUARDRAIL EXITS ---
if (strategy.position_size > 0)
    strategy.exit("Long Risk Guardrail", from_entry="Buy", stop=active_sl)

if (strategy.position_size < 0)
    strategy.exit("Short Risk Guardrail", from_entry="Sell", stop=active_sl)

// ==========================================
// 5. VISUAL SHAPE LABELS (FILTERED ENTRIES)
// ==========================================
plotshape(longCondition, title="Buy Visual Label", style=shape.labelup, location=location.belowbar, color=#22ab94, text="BUY", textcolor=color.white, size=size.tiny)
plotshape(shortCondition, title="Sell Visual Label", style=shape.labeldown, location=location.abovebar, color=#f23645, text="SELL", textcolor=color.white, size=size.tiny)

// ==========================================
// 6. SYNCHRONIZED FALSE SIGNAL LOCATOR
// ==========================================
bool long_fail_trigger  = false
bool short_fail_trigger = false

if (trade_state == 1 and low <= active_sl)
    long_fail_trigger := true

if (trade_state == -1 and high >= active_sl)
    short_fail_trigger := true

plot_sl_line = active_sl

if (strategy.position_size == 0 and not longCondition and not shortCondition)
    active_sl   := na
    trade_state := 0

plot(plot_sl_line, title="ESM System Stop Line", 
     color=trade_state == 1 ? color.rgb(34, 171, 148, 75): trade_state == -1 ? color.rgb(238, 32, 0, 75): na, 
     linewidth=2, style=plot.style_linebr)

plotshape(long_fail_trigger, title="False Buy Indicator", style=shape.xcross, location=location.belowbar, color=#22ab94, text="FAKE\nBUY", textcolor=#22ab9400, size=size.tiny)
plotshape(short_fail_trigger, title="False Sell Indicator", style=shape.xcross, location=location.abovebar, color=#ee2000, text="FAKE\nSELL", textcolor=#f2364600, size=size.tiny)

// =========================================================================
// ESM RISK STATE ENGINE LOGIC
// =========================================================================
wma_high_ribbon = ta.wma(high, wma_len)
wma_low_ribbon  = ta.wma(low, wma_len)

var float final_sl_long    = na
var float final_sl_short   = na
var bool  be_activated_l   = false
var bool  be_activated_s   = false
var float peak_candle_cl   = na
var float valley_candle_cl = na

if strategy.position_size == 0
    final_sl_long    := na
    final_sl_short   := na
    be_activated_l   := false
    be_activated_s   := false
    peak_candle_cl   := na
    valley_candle_cl := na

// --- LONG POSITIONS EXITS ENGINE ---
if strategy.position_size > 0
    if strategy.position_size > strategy.position_size[1] or na(peak_candle_cl)
        peak_candle_cl := close
        be_activated_l := false

    if close > peak_candle_cl
        peak_candle_cl := close

    float candidate_sl_long = na

    if use_be and not be_activated_l and high >= strategy.position_avg_price * (1 + (be_tp_pct / 100))
        be_activated_l := true

    if be_activated_l
        candidate_sl_long := strategy.position_avg_price

    if use_wma_trail
        float wma_trail_level = wma_low_ribbon * (1 - (wma_buffer_pct / 100))
        if na(candidate_sl_long) or wma_trail_level > candidate_sl_long
            candidate_sl_long := wma_trail_level

    if use_candle_trail
        float candle_trail_level = peak_candle_cl * (1 - (candle_trail_pct / 100))
        if na(candidate_sl_long) or candle_trail_level > candidate_sl_long
            candidate_sl_long := candle_trail_level

    if not na(candidate_sl_long)
        if na(final_sl_long) or candidate_sl_long > final_sl_long
            final_sl_long := candidate_sl_long

    if not na(final_sl_long)
        strategy.exit(id="ESM Long Risk Exit", from_entry="Buy", stop=final_sl_long)

// --- SHORT POSITIONS EXITS ENGINE ---
if strategy.position_size < 0
    if strategy.position_size < strategy.position_size[1] or na(valley_candle_cl)
        valley_candle_cl := close
        be_activated_s   := false
    
    if close < valley_candle_cl
        valley_candle_cl := close

    float candidate_sl_short = na

    if use_be and not be_activated_s and low <= strategy.position_avg_price * (1 - (be_tp_pct / 100))
        be_activated_s := true
    
    if be_activated_s
        candidate_sl_short := strategy.position_avg_price

    if use_wma_trail
        float wma_trail_level = wma_high_ribbon * (1 + (wma_buffer_pct / 100))
        if na(candidate_sl_short) or wma_trail_level < candidate_sl_short
            candidate_sl_short := wma_trail_level

    if use_candle_trail
        float candle_trail_level = valley_candle_cl * (1 + (candle_trail_pct / 100))
        if na(candidate_sl_short) or candle_trail_level < candidate_sl_short
            candidate_sl_short := candle_trail_level

    if not na(candidate_sl_short)
        if na(final_sl_short) or candidate_sl_short < final_sl_short
            final_sl_short := candidate_sl_short

    if not na(final_sl_short)
        strategy.exit(id="ESM Short Risk Exit", from_entry="Sell", stop=final_sl_short)
````
