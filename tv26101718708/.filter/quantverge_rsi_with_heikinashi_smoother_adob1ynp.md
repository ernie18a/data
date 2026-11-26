# QuantVerge RSI with Heikin-Ashi Smoother

- url: https://www.tradingview.com/script/aDOB1yNp-QuantVerge-RSI-with-Heikin-Ashi-Smoother/
- type: indicator
- pine_id: PUB;25e6f28699884c3db2911767937d37ba
- version: 1.0

## Description

QuantVerge RSI with Heikin-Ashi Smoother

Advanced Multi-Dimensional Momentum & Shaved Candle Engine for TradingView
1. What is this product?
QuantVerge RSI with Heikin-Ashi Smoother is a proprietary technical analysis indicator on TradingView (developed in Pine Script v6), designed to completely eliminate the choppy noise of traditional RSI.
Instead of using a simple one-dimensional RSI line, this tool applies a 4-dimensional calculation system (Open, High, Low, Close) combined with the Heikin-Ashi (HA) smoothing algorithm. This transforms ordinary RSI lines into independent Heikin-Ashi candlestick charts, complete with a Dynamic Heatmap system and a highly visual Shaved Candle filter.
2. How does it help traders?
Most traders struggle because standard RSI frequently generates false signals in ranging or highly noisy markets. HA-RSI Pro solves this problem by:

Noise Reduction: Converting RSI momentum into clear candle bodies and wicks, allowing traders to easily see the true market momentum instead of messy zigzag lines.
High-probability reversal confirmation via “Shaved Candles”:
Flat Bottom (no lower wick): Signals that sellers are exhausted and buyers have full control.
Flat Top (no upper wick): Signals that buyers are exhausted and sellers are in complete dominance.

Instant “Hot Zone” recognition with Dynamic Heatmap: Automatically adjusts the intensity of the background color when the indicator enters deep Overbought (>70) or Oversold (<30) territory, helping you accurately quantify market tension.
Anti-Spam Cooldown: Locks the signal system for a set number of bars after each signal, keeping the chart clean and eliminating signal spam during short-term price spikes.

3. Detailed Settings Description, Examples & Impact of Changes
The indicator’s settings panel is divided into 4 main logical groups for easy personalization:
A. RSI Engine Logic (Core RSI Engine)

RSI Length (Default: 14): Standard RSI calculation period.
Example: Lowering it to 7 makes the indicator hug price more closely and react faster for scalping, but increases noise. Raising it to 21 provides excellent noise filtering for higher timeframes (swing trading).
Overbought Level (Default: 70) & Oversold Level (Default: 30): Overbought and Oversold alert thresholds.
Example: Raising Overbought to 80 and lowering Oversold to 20 if you only want to hunt extreme reversal points (fewer signals but higher quality).

B. Multi-Timeframe (MTF) Filter

Enable HTF Trend Filter (Default: False – disabled to prioritize signal quantity): Toggle for the higher-timeframe trend filter.
Example: When enabled (True) and set to the 60 (1-hour) timeframe, the indicator automatically blocks all Buy signals on the lower timeframe if the higher timeframe is below the 50 midline (in a downtrend). This helps you avoid trading against the major trend.
Higher Timeframe (Default: 60): The macro trend reference timeframe.

C. Shaved Candle & Anti-Spam Filters

Strict Mode / Extreme Zones Only (Default: True):
Impact: Requires reversal signals to occur inside Overbought or Oversold zones. Turning it off (False) allows signals from mid-line (50) crossovers as well, which suits strong trending markets.
Price Action Anchor (Default: True):
Impact: Requires the actual price candle on the main chart to confirm the direction (bullish candle for Buy signals, bearish candle for Sell signals). This prevents Buy signals while the real price is still plunging.
Cooldown Bars / Coolbar (Default: 20):
Impact: Number of bars the system “rests” after issuing a signal. Example: With 20 selected, after a Buy signal the system ignores all other signals for the next 20 bars to avoid repeated entries during a strong move.

4. Practical Trading Strategies

Strategy 1: Extreme Reversal Scalping
Conditions: Wait for the Heatmap to light up brightly in Overbought/Oversold zones → Appearance of a Flat Top / Flat Bottom HA candle → Real price candle on the main chart confirms the direction → Enter according to the signal arrow.
Strategy 2: Higher-Timeframe Trend Following (MTF)
Conditions: Enable the HTF Trend Filter (select 1H or 4H). Only take Buy signals when the higher timeframe is in an uptrend (>50) and ignore counter-trend Sell signals to maximize win rate.
Strategy 3: Combining with Price Patterns & Smart Money Concepts (SMC)
Conditions: Use HA-RSI Pro signals as the confirmation trigger after price has swept liquidity at key levels such as Order Blocks (OB) or Fair Value Gaps (FVG) on the main timeframe.

5. Risk Management Advice & Closing Notes

Capital management: Always place Stop Loss based on actual price structure on the chart (e.g., below the nearest swing low for long trades) rather than relying solely on the indicator.
Disclaimer: This tool is a powerful assistant that optimizes technical analysis perspective and probability — it is not a holy grail that guarantees 100% profits. Always manage risk strictly in every trade.

Developed with precision by QuantVerge.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// 
// Special thanks to TradingView and the open-source community for providing the robust core engines 
// (such as RSI and built-in technical libraries) that make advanced indicator development possible.
// 
// ─── AUTHORSHIP & INTELLECTUAL PROPERTY NOTICE ──────────────────────────────
// • Original Creator & Lead Developer: Phan Nhật Nguyên (QuantVerge / AlphaSignalLTD)
// • Notice: This proprietary script was originally conceptualized and programmed by the author 
//   for potential deployment under external partnerships. As no exclusive intellectual property 
//   assignment, transfer agreement, or binding exclusivity contract was executed regarding this 
//   specific codebase, full ownership and distribution rights remain with the original author.
// • Re-deployment: This module is officially reclaimed, restructured, and integrated under 
//   the QuantVerge ecosystem. (Verification documentation and development history available upon request).
// ────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("QuantVerge RSI with Heikin-Ashi Smoother", overlay=false)

// ─── USER INTERFACE & SETTINGS ──────────────────────────────────────────────
GRP_RSI    = "RSI ENGINE LOGIC"
GRP_MTF    = "MULTI-TIMEFRAME (MTF) FILTER"
GRP_FILTER = "SHAVED CANDLE & ANTI-SPAM"
GRP_UI     = "QUANTVERGE NEON UI"

// RSI Engine Inputs
int rsi_len      = input.int(14, title="RSI Length", minval=1, group=GRP_RSI)
int ob_level     = input.int(70, title="Overbought Level", group=GRP_RSI)
int os_level     = input.int(30, title="Oversold Level", group=GRP_RSI)

// Multi-Timeframe Filter Inputs
bool use_mtf     = input.bool(false, title="[X] Enable HTF Trend Filter", group=GRP_MTF, tooltip="Default OFF for maximum signal frequency. Turn ON to strictly follow macro trend.")
string htf_res   = input.timeframe("60", title="Higher Timeframe (HTF)", group=GRP_MTF)

// Shaved Candle Filters Inputs
bool strict_mode = input.bool(true, title="[X] Strict Mode (Extreme Zones Only)", group=GRP_FILTER, tooltip="Triggers signals ONLY when HA-RSI reverses inside Overbought or Oversold zones.")
bool pa_filter   = input.bool(true, title="[X] Price Action Anchor", group=GRP_FILTER, tooltip="Requires the main chart price candle to close in the same direction as station signal.")
int cooldown     = input.int(20, title="Cooldown Bars (Coolbar)", minval=0, group=GRP_FILTER, tooltip="Number of bars to lock the engine after a signal is fired to prevent spam.")

// UI Colors
color c_bull = input.color(color.rgb(0, 255, 255), title="Bullish Neon", group=GRP_UI)
color c_bear = input.color(color.rgb(255, 20, 147), title="Bearish Neon", group=GRP_UI)

// ─── FUNCTION: HTF HA-RSI CALCULATION ───────────────────────────────────────
f_ha_rsi_close(len) =>
    float ro = ta.rsi(open, len)
    float rh = ta.rsi(high, len)
    float rl = ta.rsi(low, len)
    float rc = ta.rsi(close, len)
    (ro + rh + rl + rc) / 4

// Fetch Higher Timeframe HA-RSI close
float htf_ha_close = request.security(syminfo.tickerid, htf_res, f_ha_rsi_close(rsi_len), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// ─── 4-DIMENSIONAL RSI CALCULATION (CURRENT TF) ─────────────────────────────
float rsi_o = ta.rsi(open, rsi_len)
float rsi_h = ta.rsi(high, rsi_len)
float rsi_l = ta.rsi(low, rsi_len)
float rsi_c = ta.rsi(close, rsi_len)

// ─── HEIKIN ASHI SMOOTHING ENGINE ───────────────────────────────────────────
var float ha_open = na
float ha_close = (rsi_o + rsi_h + rsi_l + rsi_c) / 4
ha_open := na(ha_open[1]) ? (rsi_o + rsi_c) / 2 : (ha_open[1] + ha_close[1]) / 2

float ha_high = math.max(rsi_h, math.max(ha_open, ha_close))
float ha_low  = math.min(rsi_l, math.min(ha_open, ha_close))

// ─── SHAVED CANDLE SIGNAL LOGIC ─────────────────────────────────────────────
bool is_bull = ha_close >= ha_open
bool is_bear = ha_close < ha_open

bool bull_cross = ta.crossover(ha_close, ha_open)
bool bear_cross = ta.crossunder(ha_close, ha_open)

bool is_flat_bottom = is_bull and (ha_open == ha_low)
bool is_flat_top    = is_bear and (ha_open == ha_high)

bool signal_bull = bull_cross and is_flat_bottom
bool signal_bear = bear_cross and is_flat_top

// Strict Mode validation
bool raw_bull = strict_mode ? (signal_bull and ha_close[1] < os_level) : signal_bull
bool raw_bear = strict_mode ? (signal_bear and ha_close[1] > ob_level) : signal_bear

// ─── ADVANCED FILTERS (MTF + PA + COOLDOWN) ──────────────────────────────────
// 1. Multi-Timeframe Trend Filter
bool pass_mtf_bull = use_mtf ? (htf_ha_close > 50) : true
bool pass_mtf_bear = use_mtf ? (htf_ha_close < 50) : true

// 2. Price Action Anchor
bool pass_pa_bull = pa_filter ? (close > open) : true
bool pass_pa_bear = pa_filter ? (close < open) : true

// 3. Cooldown Engine (Coolbar)
var int last_signal_bar = -999
bool pass_cooldown = (bar_index - last_signal_bar) >= cooldown

// Final Validations
bool valid_bull = raw_bull and pass_mtf_bull and pass_pa_bull and pass_cooldown
bool valid_bear = raw_bear and pass_mtf_bear and pass_pa_bear and pass_cooldown

if valid_bull or valid_bear
    last_signal_bar := bar_index

// ─── VISUALIZATION (OSCILLATOR PANE) ─────────────────────────────────────────
color c_body = is_bull ? c_bull : c_bear
plotcandle(ha_open, ha_high, ha_low, ha_close, title="QV HA-RSI Candles", color=c_body, wickcolor=c_body, bordercolor=c_body)

hline(ob_level, title="Overbought Level", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(os_level, title="Oversold Level", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(50, title="Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

// ─── HEATMAP DYNAMIC COLOR LOGIC ─────────────────────────────────────────────
float ob_depth = math.min(1.0, math.max(0.0, (ha_close - ob_level) / (100 - ob_level)))
float os_depth = math.min(1.0, math.max(0.0, (os_level - ha_close) / os_level))

color heatmap_bear = color.new(c_bear, int(100 - (ob_depth * 60)))
color heatmap_bull = color.new(c_bull, int(100 - (os_depth * 60)))

bgcolor(ha_close > ob_level ? heatmap_bear : na, title="Overbought Heatmap Zone")
bgcolor(ha_close < os_level ? heatmap_bull : na, title="Oversold Heatmap Zone")

// ─── MAIN CHART OVERLAY SIGNALS ─────────────────────────────────────────────
plotshape(valid_bull, title="Buy Signal", style=shape.diamond, location=location.belowbar, color=c_bull, size=size.small, force_overlay=true)
plotshape(valid_bear, title="Sell Signal", style=shape.diamond, location=location.abovebar, color=c_bear, size=size.small, force_overlay=true)

// ─── CLEAN HUD DASHBOARD ON MAIN CHART ──────────────────────────────────────
var table dash = table.new(position.top_right, 2, 5, border_width=1, border_color=color.new(color.gray, 80), frame_color=color.new(color.gray, 80), frame_width=1, force_overlay=true)

if barstate.islast
    string state_str = ha_close > ob_level ? "OVERBOUGHT" : (ha_close < os_level ? "OVERSOLD" : "NEUTRAL")
    color state_color = ha_close > ob_level ? c_bear : (ha_close < os_level ? c_bull : color.gray)
    
    string mtf_str = use_mtf ? (htf_ha_close > 50 ? "BULLISH (>50)" : "BEARISH (<50)") : "DISABLED"
    color mtf_color = use_mtf ? (htf_ha_close > 50 ? c_bull : c_bear) : color.gray

    int bars_since = bar_index - last_signal_bar
    string cd_status = bars_since < cooldown ? "LOCKED (" + str.tostring(cooldown - bars_since) + ")" : "READY"
    color cd_color = bars_since < cooldown ? c_bear : c_bull
    
    table.cell(dash, 0, 0, "QUANTVERGE", text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(dash, 1, 0, "HA-RSI PRO", text_color=c_bull, bgcolor=color.new(color.black, 50), text_size=size.small)
    
    table.cell(dash, 0, 1, "HTF Trend Filter", text_color=color.gray, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(dash, 1, 1, mtf_str, text_color=mtf_color, bgcolor=color.new(color.black, 50), text_size=size.small)

    table.cell(dash, 0, 2, "Cooldown Status", text_color=color.gray, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(dash, 1, 2, cd_status, text_color=cd_color, bgcolor=color.new(color.black, 50), text_size=size.small)
    
    table.cell(dash, 0, 3, "Momentum Zone", text_color=color.gray, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(dash, 1, 3, state_str, text_color=state_color, bgcolor=color.new(color.black, 50), text_size=size.small)
    
    table.cell(dash, 0, 4, "HA-RSI Value", text_color=color.gray, bgcolor=color.new(color.black, 50), text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(ha_close, "#.##"), text_color=color.white, bgcolor=color.new(color.black, 50), text_size=size.small)

// ─── ALERTS ─────────────────────────────────────────────────────────────────
alertcondition(valid_bull, title="HA-RSI Buy Signal", message="QuantVerge HA-RSI: Bullish Shaved Candle Confirmed. Execute BUY.")
alertcondition(valid_bear, title="HA-RSI Sell Signal", message="QuantVerge HA-RSI: Bearish Shaved Candle Confirmed. Execute SELL.")
````
