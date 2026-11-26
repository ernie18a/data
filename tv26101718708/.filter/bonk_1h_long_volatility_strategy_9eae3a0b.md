# BONK 1H Long Volatility Strategy

- url: https://www.tradingview.com/script/9eAe3a0B-BONK-1H-Long-Volatility-Strategy/
- type: strategy
- pine_id: PUB;1eeb416164724d46ac78819975fe158e
- version: 2.0

## Description

Grok 1hr bonk strategy:

Key Changes and Why They’re Made
1. Indicator Adjustments
Moving Averages:
Fast MA: Changed to 5 periods (from, e.g., 9 on a higher timeframe).

Slow MA: Changed to 13 periods (from, e.g., 21).

Why: Shorter periods make the moving averages more sensitive to quick price changes on the 1-hour chart, helping identify trends faster.

ATR (Average True Range):
Length: Set to 10 periods (down from, e.g., 14).

Multiplier: Reduced to 1.5 (from, e.g., 2.0).

Why: A shorter ATR length tracks recent volatility better, and a lower multiplier lets the strategy catch smaller price swings, which are more common hourly.

RSI:
Kept at 14 periods with an overbought level of 70.

Why: RSI stays the same to filter out overbought conditions, maintaining consistency with the original strategy.

2. Entry Conditions
Trend: Requires the fast MA to be above the slow MA, ensuring a bullish direction.

Volatility: The candle’s range (high - low) must exceed 1.5 times the ATR, confirming a significant move.

Momentum: RSI must be below 70, avoiding entries at potential peaks.

Price: The close must be above the fast MA, signaling a pullback or trend continuation.

Why: These conditions are tightened to capture frequent volatility spikes while filtering out noise, which is more prevalent on a 1-hour chart.

3. Exit Strategy
Profit Target: Default is 5% (adjustable from 3-7%).

Stop-Loss: Default is 3% (adjustable from 1-5%).

Why: These levels remain conservative to lock in gains quickly and limit losses, suitable for the faster pace of a 1-hour timeframe.

4. Risk Management
The strategy may trigger more trades on a 1-hour chart. To avoid overtrading:
The ATR filter ensures only volatile moves are traded.

Trading fees (e.g., 0.5% on Coinbase) reduce the net profit to ~4% on winners and -3.5% on losers, requiring a win rate above 47% for profitability.

Suggestion: Risk only 1-2% of your capital per trade to manage exposure.

5. Visuals and Alerts
Plots: Blue fast MA, red slow MA, and green triangles for buy signals.

Alerts: Trigger when an entry condition is met, so you don’t need to watch the chart constantly.

How to Use the Strategy
Setup:
Load TradingView, select BONK/USD on the 1-hour chart (Coinbase pair).

Paste the script into the Pine Editor and add it to your chart.

Customize:
Adjust the profit target (e.g., 5%) and stop-loss (e.g., 3%) to your preference.

Tweak ATR or MA lengths if BONK’s volatility shifts.

Trade:
Look for green triangle signals and confirm with market context (e.g., volume or news).

Enter trades manually or via TradingView’s broker tools if supported.

Exit when the profit target or stop-loss is hit.

Test:
Use TradingView’s Strategy Tester to backtest on historical data and refine settings.

Benefits of the 1-Hour Timeframe
Faster Opportunities: Captures shorter-term uptrends in BONK’s volatile price action.

Responsive: Adjusted indicators react quickly to hourly changes.

Conservative: Maintains the 3-7% profit goal with tight risk control.

Potential Challenges
Noise: The 1-hour chart has more false signals. The ATR and MA filters help, but caution is needed.

Fees: Frequent trading increases costs, so ensure each trade’s potential justifies the expense.

Volatility: BONK can move unpredictably—monitor broader market trends or Solana ecosystem news.

Final Thoughts
Switching to a 1-hour timeframe makes the strategy more active, targeting shorter volatility spikes while keeping profits conservative at 3-7%. The adjusted indicators and conditions balance responsiveness with reliability. Backtest it on TradingView to confirm it suits BONK’s behavior, and always use proper risk management, as meme coins are highly speculative.
Disclaimer: This is for educational purposes, not financial advice. Cryptocurrency trading, especially with assets like BONK, is risky. Test thoroughly and trade responsibly.

## Source Code

````pine
//@version=5
strategy("BONK 1H Enhanced Volatility Strategy", overlay=true, margin_long=100, margin_short=0, calc_on_order_fills=true)

// --- Inputs ---
profit_target_pct = input.float(5.0, "Profit Target % (3-7%)", minval=3.0, maxval=7.0, step=0.1)
stop_loss_pct = input.float(3.0, "Stop Loss %", minval=1.0, maxval=5.0, step=0.1)
atr_length = input.int(10, "ATR Length", minval=1)
atr_multiplier = input.float(1.5, "ATR Multiplier", minval=1.0, step=0.1)
rsi_length = input.int(14, "RSI Length", minval=1)
rsi_overbought = input.int(65, "RSI Overbought", minval=50, maxval=100)
rsi_oversold = input.int(35, "RSI Oversold", minval=0, maxval=50)
macd_fast = input.int(12, "MACD Fast Length", minval=1)
macd_slow = input.int(26, "MACD Slow Length", minval=1)
macd_signal = input.int(9, "MACD Signal Length", minval=1)
volume_sma_length = input.int(20, "Volume SMA Length", minval=1)
volume_threshold = input.float(1.5, "Volume Spike Threshold", minval=1.0, step=0.1)
ma_fast_length = input.int(5, "Fast MA Length", minval=1)
ma_slow_length = input.int(13, "Slow MA Length", minval=1)
lookback_days = input.int(30, "Lookback Days (Last Month)", minval=1)

// --- Time Filter: Last 30 Days ---
time_filter = timestamp(year(timenow), month(timenow), dayofmonth(timenow) - lookback_days, 0, 0)
is_recent = time >= time_filter

// --- Indicators ---
// Moving Averages
ma_fast = ta.sma(close, ma_fast_length)
ma_slow = ta.sma(close, ma_slow_length)

// ATR for Volatility
atr = ta.atr(atr_length)
atr_threshold = atr * atr_multiplier

// RSI for Momentum
rsi = ta.rsi(close, rsi_length)

// MACD for Trend Confirmation
[macd_line, signal_line, _] = ta.macd(close, macd_fast, macd_slow, macd_signal)
macd_bullish = macd_line > signal_line and macd_line > 0

// Volume Filter
volume_sma = ta.sma(volume, volume_sma_length)
volume_spike = volume > volume_sma * volume_threshold

// --- Conditions ---
// Trend: Fast MA above Slow MA
bullish_trend = ma_fast > ma_slow

// Volatility: Price range exceeds ATR threshold
price_range = high - low
volatile_condition = price_range > atr_threshold

// Entry: Combine trend, volatility, RSI, MACD, and volume
entry_condition = is_recent and bullish_trend and volatile_condition and rsi < rsi_overbought and rsi > rsi_oversold and macd_bullish and volume_spike and close > ma_fast

// Exit: Dynamic profit target and stop-loss based on ATR
profit_target = close * (1 + profit_target_pct / 100)
stop_loss = close * (1 - stop_loss_pct / 100)
atr_stop = close - (atr * 1.5) // Alternative ATR-based stop

// --- Strategy Logic ---
// Enter Long
if (entry_condition)
    strategy.entry("Long", strategy.long)

// Exit Conditions
strategy.exit("Exit Long", "Long", limit=profit_target, stop=math.max(stop_loss, atr_stop))

// --- Trailing Stop ---
trail_points = atr * 100 // Convert ATR to points
strategy.exit("Trail Exit", "Long", trail_points=trail_points, trail_offset=trail_points)

// --- Plotting ---
plot(ma_fast, color=color.blue, title="Fast MA")
plot(ma_slow, color=color.red, title="Slow MA")
plotshape(entry_condition, title="Buy Signal", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small)
plotshape(rsi < rsi_oversold, title="Oversold Warning", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.tiny)
````
