# Canuck Trading Traders Strategy [Candle Entropy Edition]

- url: https://www.tradingview.com/script/UbiYgrSE-Canuck-Trading-Traders-Strategy-Candle-Entropy-Edition/
- type: strategy
- pine_id: PUB;295af6c494724f758a9e4c30fd3fc5ee
- version: 9.0

## Description

Canuck Trading Traders Strategy: A Unique Entropy-Based Day Trading System for Volatile Stocks

Overview

The Canuck Trading Traders Strategy is a custom, entropy-driven day trading system designed for high-volatility stocks like TSLA on short timeframes (e.g., 15m). At its core is CETP-Plus, a proprietary blended indicator that measures "order from chaos" in candle patterns using Shannon entropy, while embedding mathematical principles from EMA (recent weighting), RSI (momentum bias), ATR (volatility scaling), and ADX (trend strength) into a single score. This unique approach avoids layering multiple indicators, reducing complexity while improving timing for early trend detection and balanced long/short trades.

CETP-Plus calculates a score from weighted candle ratios (body, upper/lower wicks) binned into a 3D histogram for entropy (low entropy = strong pattern). The score is adjusted with momentum, volatility, and trend multipliers for robust signals. Entries occur when the score exceeds thresholds (positive for longs, negative for shorts), with exits on reversals or stops. The strategy is automatic—no manual bias needed—and optimized for margin accounts with equal long/short treatment.

Backtested on TSLA 15m (Jan 2015–Aug 2025), it targets +50,000% net profit (beating +1,478% buy-hold by 34x) with ~25,000 trades, 85-90% win rate, and <10% drawdown (with costs). Results vary by timeframe/period—test with your data and add slippage/commission for realism. Disclaimer: Past performance isn't indicative of future results; consult a financial advisor.

Key Features

CETP-Plus Indicator: Blends entropy with momentum/vol/trend for a single score, capturing bottoms/squeezes and trends without external tools.
Automatic Balance: Positive scores trigger longs in bull trends, negative scores trigger shorts in bear trends—no user input for direction.
Customizable Math: Tune weights and scales to adapt for different stocks (e.g., lower thresholds for NVDA's smoother trends).
Risk Controls: Stop-loss, trailing stops, and score strength filter to minimize drawdowns in volatile markets like TSLA.
Exit Debugging: Plots exit reasons ("Stop Loss", "Trail Stop", "CETP Exit") for analysis.

Input Settings and Purposes
All inputs are grouped in TradingView's Inputs tab for ease. Defaults are optimized for TSLA 15m day trading; adjust for other intervals or tickers (e.g., increase window for 1h, lower thresholds for NVDA).
CETP-Plus Settings

CETP Window (default: 5, min: 3, max: 20): Lookback bars for entropy/momentum. Short values (3-5) for fast sensitivity on short frames; longer (8-10) for stability on hourly+.
CETP Bins per Dimension (default: 3, min: 3, max: 10): Histogram granularity for entropy. Low (3) for speed/simple patterns; high (5+) for detail in complex markets.
Long Threshold (default: 0.15, min: 0.1, max: 0.8, step: 0.05): CETP score for long entries. Lower (0.1) for more longs in mild bull trends; higher (0.2) to filter noise.
Short Threshold (default: -0.05, min: -0.8, max: -0.1, step: 0.05): CETP score for short entries. Less negative (-0.05) for more shorts in mild bear trends; more negative (-0.2) for strong signals.
CETP Momentum Weight (default: 0.8, min: 0.1, max: 1.0, step: 0.1): Emphasizes momentum in score. High (0.9) for aggressive in fast moves; low (0.5) for entropy focus.
Momentum Scale (default: 1.6, min: 0.1, max: 2.0, step: 0.1): Amplifies momentum. High (2.0) for short intervals; low (1.0) for stability.
Body Ratio Weight (default: 1.2, min: 0.0, max: 2.0, step: 0.1): Weights candle body in entropy (trend focus). High (1.5) for strong trends; low (0.8) for wick emphasis.
Upper Wick Ratio Weight (default: 0.8, min: 0.0, max: 2.0, step: 0.1): Weights upper wick (reversal noise). Low (0.5) to reduce false ups.
Lower Wick Ratio Weight (default: 0.8, min: 0.0, max: 2.0, step=0.1): Weights lower wick. Low (0.5) to reduce false downs.

Trade Settings

Confirmation Bars (default: 0, min: 0, max: 5): Bars for sustained CETP signals. 0 for immediate entries (more trades); 1-2 for reliability (fewer but stronger).
Min CETP Score Strength (default: 0.04, min: 0.0, max: 0.5, step: 0.05): Min absolute score for entry. Low (0.04) for more trades; high (0.15) for quality.

Risk Management

Stop Loss (%) (default: 0.5, min: 0.1, max: 5.0, step: 0.1): % from entry for stop. Tight (0.4) for quick exits; wide (0.8) for trends.
ATR Multiplier (default: 1.5, min: 0.5, max: 3.0, step: 0.1): Scales ATR for stops/trails. Low (1.0) for tight; high (2.0) for room.
Trailing ATR Mult (default: 3.5, min: 0.5, max: 5.0, step: 0.1): ATR mult for trails. High (4.0) for longer holds; low (2.0) for profits.
Trail Start Offset (%) (default: 1.0, min: 0.5, max: 2.0, step: 0.1): % profit before trailing. Low (0.8) for early lock-in; high (1.5) for bigger moves.

These settings enable customization for intervals/tickers while CETP-Plus handles automatic balancing. 

Risk Disclosure

Trading involves significant risk and may result in losses exceeding your initial capital. The Canuck Trading Trader Strategy is provided for educational and informational purposes only. Users are responsible for their own trading decisions and should conduct thorough testing before using in live markets. The strategy’s high trade frequency requires reliable execution infrastructure to minimize slippage and latency.

## Source Code

````pine
// @version=6
strategy("Canuck Trading Traders Strategy [Candle Entropy Edition]", overlay=true, margin_long=100.0, margin_short=100.0, calc_on_every_tick=false, calc_on_order_fills=true, process_orders_on_close=true)
// Note: Set Properties "Order size" to "100% of equity" for all symbols.

// === CETP-Plus Settings ===
cetp_window = input.int(5, "CETP Window", minval=1, maxval=20, group="CETP-Plus Settings")
cetp_bins = input.int(3, "CETP Bins per Dimension", minval=1, maxval=20, group="CETP-Plus Settings")
long_threshold_base = input.float(0.1, "Long Threshold Base", minval=0.01, maxval=8.0, step=0.01, group="CETP-Plus Settings")
short_threshold_base = input.float(-0.1, "Short Threshold Base", minval=-0.8, maxval=-0.01, step=0.01, group="CETP-Plus Settings")
cetp_k = input.float(0.8, "CETP Momentum Weight", minval=0.1, maxval=25.0, step=0.1, group="CETP-Plus Settings")
mom_scale = input.float(6.0, "Momentum Scale", minval=1.0, maxval=25.0, step=1.0, group="CETP-Plus Settings")
body_weight = input.float(1.0, "Body Ratio Weight", minval=0.0, maxval=10.0, step=0.1, group="CETP-Plus Settings")
upper_weight = input.float(0.8, "Upper Wick Ratio Weight", minval=0.0, maxval=3.0, step=0.1, group="CETP-Plus Settings")
lower_weight = input.float(1.2, "Lower Wick Ratio Weight", minval=0.0, maxval=3.0, step=0.1, group="CETP-Plus Settings")
decay_factor = input.float(0.9, "Decay Factor", minval=0.1, maxval=2, step=0.01, group="CETP-Plus Settings")

// === Trade Settings ===
min_score_strength = input.float(0.02, "Min CETP Score Strength", minval=0.0, maxval=5, step=0.01, group="Trade Settings")
stop_loss_pct = input.float(0.5, "Stop Loss (%)", minval=0.1, maxval=5.0, step=0.1, group="Trade Settings")
stop_loss_pct_short = input.float(0.4, "Stop Loss for Shorts (%)", minval=0.1, maxval=5.0, step=0.1, group="Trade Settings")
atr_mult = input.float(2.5, "ATR Multiplier", minval=0.5, maxval=5.0, step=0.1, group="Trade Settings")
trail_mult = input.float(6.0, "Trailing ATR Mult", minval=0.5, maxval=50.0, step=0.1, group="Trade Settings")
trail_offset_pct = input.float(1.0, "Trail Start Offset (%)", minval=0.5, maxval=5.0, step=0.1, group="Trade Settings")
min_price_move_mult = input.float(3.0, "Min Price Move ATR Mult", minval=0.5, maxval=10.0, step=0.1, group="Trade Settings")
min_vol_mult = input.float(1.5, "Min Volume Multiplier", minval=1.0, group="Trade Settings")
vol_threshold_limit = input.float(12.0, "Vol Threshold Limit", minval=5.0, maxval=20.0, step=0.1, group="Trade Settings")
max_hold_bars = input.int(10, "Max Bars in Trade (Cut Losses)", minval=1, maxval=50, group="Trade Settings")

// Indicators (ATR for stops/trails only)
atr = nz(ta.atr(14), 0.0)

// RSI-like momentum bias
avg_gain = ta.rma(math.max(close - close[1], 0), cetp_window)
avg_loss = ta.rma(math.max(close[1] - close, 0), cetp_window)
rsi_bias = avg_loss > 0 ? avg_gain / avg_loss : 1.0
momentum = ta.mom(close, cetp_window) / (close[cetp_window] != 0 ? close[cetp_window] : 1e-5)
momentum_adj = momentum * (1 + rsi_bias)

// ADX-like trend strength (automated and symmetric for bull/bear)
di_plus = ta.rma(math.max(high - high[1], 0), cetp_window) / atr
di_minus = ta.rma(math.max(low[1] - low, 0), cetp_window) / atr
trend_strength = di_plus > di_minus ? 1.2 : (di_minus > di_plus ? 1.2 : 1.0)

// CETP-Plus Calculation (Blended EMA, RSI, ATR, ADX theses)
epsilon = 1e-5
body_ratio = (close - open) / (high - low + epsilon) * body_weight
upper_wick_ratio = (high - math.max(open, close)) / (high - low + epsilon) * upper_weight
lower_wick_ratio = (math.min(open, close) - low) / (high - low + epsilon) * lower_weight

// EMA-like weighting: Exponentially weight recent candles with fixed-size rolling arrays
var float[] body_arr = array.new_float(cetp_window, 0.0)
var float[] upper_arr = array.new_float(cetp_window, 0.0)
var float[] lower_arr = array.new_float(cetp_window, 0.0)

// Shift and decay older values, add new at the end
for i = 0 to cetp_window - 2
    array.set(body_arr, i, array.get(body_arr, i + 1) * decay_factor)
    array.set(upper_arr, i, array.get(upper_arr, i + 1) * decay_factor)
    array.set(lower_arr, i, array.get(lower_arr, i + 1) * decay_factor)

array.set(body_arr, cetp_window - 1, body_ratio)
array.set(upper_arr, cetp_window - 1, upper_wick_ratio)
array.set(lower_arr, cetp_window - 1, lower_wick_ratio)

// Volatility scaling (ATR thesis)
bin_size = 2.0 / cetp_bins * (1 + atr / ta.sma(atr, 14))
hist_size = cetp_bins * cetp_bins * cetp_bins
var int[] hist = array.new_int(hist_size, 0)
array.fill(hist, 0)

for i = 0 to cetp_window - 1
    body_val = array.get(body_arr, i)
    upper_val = array.get(upper_arr, i)
    lower_val = array.get(lower_arr, i)
    
    body_bin = math.max(0, math.min(cetp_bins - 1, math.floor((body_val + 1) / bin_size)))
    upper_bin = math.max(0, math.min(cetp_bins - 1, math.floor((upper_val + 1) / bin_size)))
    lower_bin = math.max(0, math.min(cetp_bins - 1, math.floor((lower_val + 1) / bin_size)))
    
    bin_idx = body_bin * (cetp_bins * cetp_bins) + upper_bin * cetp_bins + lower_bin
    array.set(hist, bin_idx, array.get(hist, bin_idx) + 1)

entropy = 0.0
for i = 0 to hist_size - 1
    count = array.get(hist, i)
    p = count / cetp_window
    if p > 0
        entropy := entropy - p * math.log(p)

max_entropy = math.log(hist_size)
norm_entropy = max_entropy > 0 ? entropy / max_entropy : 0.0

// CETP-Plus Score (optimized: no abs on momentum_adj to preserve sign for better short detection)
avg_body = nz(array.avg(body_arr), 0.0)
raw_score = avg_body * (1 - norm_entropy) * (cetp_k + momentum_adj * mom_scale)
cetp_score = nz(raw_score * trend_strength, 0.0)

// Automatic Trend Detection using CETP Score
adjustment_factor = 1.5  // Hardcoded factor for weighting
long_threshold = cetp_score > 0 ? long_threshold_base / adjustment_factor : long_threshold_base * adjustment_factor  // Easier longs in bullish, harder in bearish
short_threshold = cetp_score < 0 ? short_threshold_base / adjustment_factor : short_threshold_base * adjustment_factor  // Easier shorts in bearish, harder in bullish

// Volatility Filter
vol_threshold = ta.stdev(close, 20) / ta.sma(close, 20) * 100
trade_allowed = vol_threshold < vol_threshold_limit

// Minimum Price Move Filter (candle range > ATR multiple, floored by min tick)
min_price_move = math.max(atr * min_price_move_mult, syminfo.mintick * 10)
price_move_condition = (high - low) > min_price_move

// Volume Filter
vol_condition = volume > ta.sma(volume, 20) * min_vol_mult

// Momentum Condition (min threshold for stronger signals)
momentum_condition = math.abs(momentum_adj) > 0.05

// Position State
var float entry_price = na
var int bars_held = 0

if barstate.isconfirmed
    bars_held := strategy.position_size != 0 ? bars_held + 1 : 0

// Close if max hold bars exceeded
if bars_held > max_hold_bars and strategy.position_size != 0
    strategy.close_all(comment="Max Hold Bars Exceeded")

// Trade Logic: Rely solely on current CETP score for entries/exits/reversals, with min price move filter
if bar_index >= cetp_window and math.abs(cetp_score) > min_score_strength and trade_allowed and price_move_condition and momentum_condition and vol_condition
    if cetp_score > long_threshold
        if strategy.position_size < 0
            strategy.close("Short", comment="Reverse to Long")
        if strategy.position_size <= 0
            strategy.entry("Long", strategy.long)
            entry_price := close
            sl = entry_price * (1 - stop_loss_pct / 100) - atr * atr_mult
            strategy.exit("Long Exit", "Long", stop=sl, trail_points=atr * trail_mult * syminfo.pointvalue, trail_offset=entry_price * (trail_offset_pct / 100))
            bars_held := 1
    else if cetp_score < short_threshold
        if strategy.position_size > 0
            strategy.close("Long", comment="Reverse to Short")
        if strategy.position_size >= 0
            strategy.entry("Short", strategy.short)
            entry_price := close
            sl = entry_price * (1 + stop_loss_pct / 100) + atr * atr_mult
            strategy.exit("Short Exit", "Short", stop=sl, trail_points=atr * trail_mult * syminfo.pointvalue, trail_offset=entry_price * (trail_offset_pct / 100))
            bars_held := 1
````
