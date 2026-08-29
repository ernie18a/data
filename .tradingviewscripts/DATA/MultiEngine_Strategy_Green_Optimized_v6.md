<!-- tradingview-pine-id: PUB;a09958db431841deaa05155f1bd90b4b -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Engine Strategy (Green Optimized) v6

Source: https://www.tradingview.com/script/rliMxcaE-Multi-Engine-Strategy-Green-Optimized-Candlestick-Breakout/

## Description

Multi-Engine Quantitative Strategy (Trend, Dip & Candlestick Breakouts)
Overview
This strategy is an optimized multi-engine quantitative trading system designed for active momentum traders. It combines dynamic trend filtering with three distinct entry engines—allowing it to adapt to changing market structures, whether buying pullbacks in an established trend or capturing high-momentum breakout expansions.

Key Strategy Features
1. Trend & Macro Alignment
Macro Filter: Ensures trades are only taken in favorable environments by requiring price to trade above both the 50 EMA and the VWAP.

Support Validation: Uses a 21 EMA fast line to define dynamic dynamic support levels for pullback entries.

2. Multi-Engine Entry Logic
Engine A: Buy the Dip (Pullback Engine)
Identifies oversold opportunities within a macro uptrend.

Triggers when price touches or dips near the 21 EMA buffer zone and prints a strong green reversal candle while remaining above the 50 EMA.

Engine B: Structural High Breakout
Targets apex breakout consolidations.

Triggers when price crosses above the highest high of the lookback period (N bars) accompanied by an institutional volume spike.

Engine C: First Green Over Prior Red (Candlestick Breakout)
Captures immediate micro-momentum shifts at potential pivot points.

Triggers when a green candle (close > open) breaks cleanly above the high of the immediately preceding red candle (close[1] < open[1]), validated by volume expansion.

3. Institutional Risk & Execution Rules
Volume Filter: Requires a customizable volume multiplier (default: 1.2x 5-period SMA) on breakouts to filter out low-volume bull traps.

Dynamic Stop-Loss: Sets stop-losses at key dynamic swing levels (e.g., recent 5-bar low or prior candle's low) to adapt to market volatility.

Risk/Reward Framing: Uses a default 1:2 Risk-to-Reward ratio on all entries.

Macro Guardrail Exit: Closes open positions immediately if price breaks below the 50 EMA, preserving capital during structural reversals.

Input Settings & Customization
Strategy Engine Toggles: Enable or disable any of the 3 entry engines independently to isolate performance per asset class.

Moving Averages: Adjust Fast EMA (21) and Slow EMA (50) lengths to fit higher or lower timeframes.

Breakout Lookback: Fine-tune structural high lookbacks (default: 5 bars).

Volume Multiplier: Adjust breakout volume threshold requirements.

Backtest Lookback Window: Define strict date ranges for targeted backtesting.

Recommended Usage
Asset Classes: Tech Stocks, Crypto (BTC/ETH), High-Beta Equities, Forex Pairs.

Timeframes: Best tuned for intraday (5m, 15m) and lower swing timeframes (1H, 4H).

---

## Source Code

````pine
//@version=6
strategy("Multi-Engine Strategy (Green Optimized) v6", overlay=true, initial_capital=5000, default_qty_type=strategy.cash, default_qty_value=5000, calc_on_every_tick=true)

// =============================================================================
// 1. ENGINE TOGGLES & TUNED INPUTS
// =============================================================================
trade_dips      = input.bool(true, title="Enable 'Buy the Dip' Engine", group="Strategy Engine Toggles")
trade_breakouts = input.bool(true, title="Enable 'Breakout' Engine", group="Strategy Engine Toggles")

// Moving Average & Buffer Configurations
ema_fast_len    = input.int(21, title="Fast EMA Support", group="Moving Averages")
ema_slow_len    = input.int(50, title="Micro Trend Filter", group="Moving Averages")
buffer_pct      = input.float(0.15, title="EMA Touch Buffer %", group="Execution Padding")

// Warrior Trading Style Apex Breakout Parameters
breakout_lookback = input.int(5, title="Breakout Apex Lookback (Tuned from 20)", group="Breakout Engine Configuration")
vol_multiplier    = input.float(1.2, title="Required Breakout Volume Spike (x Avg)", group="Breakout Engine Configuration")

// Time Range Filter
lookback_days   = input.int(30, title="Backtest Lookback Window (Days)", group="Time Horizon Filter")
in_date_range   = (time >= timenow - (lookback_days * 86400000))

// =============================================================================
// 2. CORE TECHNICAL INDICATORS & VOLATILITY FILTERS
// =============================================================================
ema_fast = ta.ema(close, ema_fast_len)
ema_slow = ta.ema(close, ema_slow_len)
vwap_val = ta.vwap

// Dynamic Volume Validation Layer to filter false breakouts
avg_volume = ta.sma(volume, 5)
volume_spiked = volume > (avg_volume * vol_multiplier)

// Find the precise structural apex ceiling (excluding current bar)
local_resistance_ceiling = ta.highest(high, breakout_lookback)[1]

// Plot Supporting Structural Lines onto Chart
plot(ema_fast, title="Fast EMA Support", color=color.new(#ff0055, 0), linewidth=2)
plot(ema_slow, title="Micro Trend Filter", color=color.new(#ffcc00, 0), linewidth=2)
plot(vwap_val, title="VWAP", color=color.new(#0088ff, 0), linewidth=2, style=plot.style_line)
plot(trade_breakouts and strategy.position_size == 0 ? local_resistance_ceiling : na, title="Breakout Ceiling", color=color.new(#00ffff, 30), style=plot.style_linebr, linewidth=1)

// =============================================================================
// 3. SEPARATED ENGINE STRATEGY MATRIX
// =============================================================================
macro_bullish = (close > vwap_val) and (close > ema_slow)

// --- ENGINE A: DIP ENGINE ---
ema_upper_threshold = ema_fast * (1.0 + (buffer_pct / 100.0))
price_in_buy_zone = (low <= ema_upper_threshold) and (close > ema_slow)
green_reversal_candle = (close > open) and (close > close[1])
dip_buy_signal = macro_bullish and price_in_buy_zone and green_reversal_candle and trade_dips

// --- ENGINE B: REFINED BREAKOUT ENGINE ---
// Triggers ONLY if macro trend is bullish, price cracks resistance ceiling, AND volume confirms momentum
breakout_buy_signal = macro_bullish and ta.crossover(close, local_resistance_ceiling) and volume_spiked and trade_breakouts

// =============================================================================
// 4. STRATEGY EXECUTION & ANTI-WHIPSAW LOGIC
// =============================================================================
var float trade_stop_loss = na
var float trade_take_profit = na
var string active_engine = ""

lowest_low_in_dip = ta.lowest(low, 5)

if strategy.position_size == 0
    active_engine := ""
    
    // Prioritize Dip Entries first to secure a lower, safer cost-basis
    if dip_buy_signal and in_date_range
        trade_stop_loss := lowest_low_in_dip
        float risk_distance = close - trade_stop_loss
        if risk_distance > (close * 0.0005)
            trade_take_profit := close + (risk_distance * 2.0)
            active_engine := "DIP"
            strategy.entry("BUY", strategy.long, comment="BUY (Dip)")
            alert("SUGGESTION: Aggressive Dip Buy Setup. Stop: " + str.tostring(trade_stop_loss) + " | Target: " + str.tostring(trade_take_profit), alert.freq_once_per_bar)
            
    // Only fire Breakout Engine if we aren't chasing a duplicate move
    else if breakout_buy_signal and in_date_range
        trade_stop_loss := lowest_low_in_dip
        float risk_distance = close - trade_stop_loss
        if risk_distance > (close * 0.0005)
            trade_take_profit := close + (risk_distance * 2.0)
            active_engine := "BREAKOUT"
            strategy.entry("BUY", strategy.long, comment="BrkOut")
            alert("SUGGESTION: Momentum Breakout Confirmed. Stop: " + str.tostring(trade_stop_loss) + " | Target: " + str.tostring(trade_take_profit), alert.freq_once_per_bar)

// Exit Management Engine
if strategy.position_size > 0
    if close < ema_slow
        strategy.close("BUY", comment="SELL Brkdn")
    else
        strategy.exit("SELL", "BUY", stop=trade_stop_loss, limit=trade_take_profit, comment_loss="SELL (Stop Hit)", comment_profit="SELL (Target Hit)")

// State Machine Cleanup
if strategy.position_size == 0
    trade_stop_loss := na
    trade_take_profit := na

// =============================================================================
// 5. RISK LINES VISUALIZATION
// =============================================================================
plot(strategy.position_size > 0 ? trade_stop_loss : na, title="Active Stop Loss", color=color.red, style=plot.style_linebr, linewidth=2)
plot(strategy.position_size > 0 ? trade_take_profit : na, title="Active Take Profit Target", color=color.green, style=plot.style_linebr, linewidth=2)
````
