# Doji at 50, 100, 200 EMA (v6)

- url: https://www.tradingview.com/script/3gOSAaf6-Doji-at-50-100-200-EMA-v6/
- type: indicator
- pine_id: PUB;d224864e894d448f8fb80084b6b1cff9
- version: 1.0

## Description

Doji at Key EMAs (50, 100, 200) — Dynamic Pullback & Reversal Signals
Overview
This indicator identifies Doji candlestick patterns forming directly at or near major dynamic support and resistance levels (50 EMA, 100 EMA, and 200 EMA).

When price tests a key Exponential Moving Average and prints an indecision candle (Doji), it often signals an exhaustion of the prevailing momentum and sets up high-probability trend continuation pullbacks or mean-reversion bounces.

Key Features
Key Dynamic Moving Averages: Plots 50, 100, and 200 EMAs directly on the chart.

Smart Doji Detection: Identifies Doji candles by evaluating the candle's body size relative to its total high-to-low range (customizable threshold).

Proximity Buffer: Checks if price action is touching or within a tight tolerance percentage of the selected EMA to avoid false misses due to slight wick differences.

Clear Visual Labels: Displays color-coded labels beneath the signal bars identifying which specific EMA the Doji is interacting with:

Blue: 50 EMA

Orange: 100 EMA

Purple: 200 EMA

Integrated Alerts: Single alert condition trigger for real-time notifications on your watchlist.

How to Use
Best Timeframes: Daily (D) and Weekly (W) charts for swing/positional setups; also functional on 1-hour/4-hour timeframes for active traders.

Trend-Following Setup (High Probability):

In an established uptrend, look for pullbacks to a rising 50 or 100 EMA marked by a Doji signal.

Trigger a long entry when the high of the Doji candle is breached on the subsequent candle.

Place the Stop Loss slightly below the Doji low or the corresponding EMA line.

Macro Reversals:

Watch for Doji prints at the 200 EMA for potential long-term trend pivots or major structural retests.

Settings & Inputs
EMA Lengths: Default 50, 100, 200 (fully adjustable).

Max Doji Body Size (%): Percentage of total range the body cannot exceed (default: 10%).

Proximity to EMA (%): Tolerance distance around the EMA line to qualify an interaction (default: 0.5%).

Disclaimer: This indicator is designed for educational and technical analysis purposes. Always combine candlestick signals with multi-timeframe analysis and proper risk management.

## Source Code

````pine
//@version=6
indicator("Doji at 50, 100, 200 EMA (v6)", overlay = true)

// --- EMA Inputs ---
ema50_len  = input.int(50, title="EMA 1 Length")
ema100_len = input.int(100, title="EMA 2 Length")
ema200_len = input.int(200, title="EMA 3 Length")
doji_pct   = input.float(10.0, title="Max Doji Body Size (% of Total Range)", minval=1.0, maxval=25.0)
proximity  = input.float(0.5, title="Proximity to EMA (%)", step=0.1)

// --- Calculations ---
ema50  = ta.ema(close, ema50_len)
ema100 = ta.ema(close, ema100_len)
ema200 = ta.ema(close, ema200_len)

// Plot EMAs
plot(ema50,  color=color.new(color.blue, 0),   title="50 EMA",  linewidth=2)
plot(ema100, color=color.new(color.orange, 0), title="100 EMA", linewidth=2)
plot(ema200, color=color.new(color.purple, 0), title="200 EMA", linewidth=2)

// Doji Detection: Body <= X% of total range
candle_range = high - low
candle_body  = math.abs(close - open)
is_doji      = candle_range > 0 and (candle_body <= (candle_range * (doji_pct / 100.0)))

// Check if High/Low touches or is within proximity of EMAs
near_ema(ema_val) =>
    tolerance = ema_val * (proximity / 100.0)
    (high >= (ema_val - tolerance)) and (low <= (ema_val + tolerance))

at_ema50  = is_doji and near_ema(ema50)
at_ema100 = is_doji and near_ema(ema100)
at_ema200 = is_doji and near_ema(ema200)

doji_at_any_ema = at_ema50 or at_ema100 or at_ema200

// --- Visual Signals ---
plotshape(at_ema50,  title="Doji at 50 EMA",  style=shape.labelup, location=location.belowbar, color=color.blue,   text="Doji 50",  textcolor=color.white)
plotshape(at_ema100, title="Doji at 100 EMA", style=shape.labelup, location=location.belowbar, color=color.orange, text="Doji 100", textcolor=color.white)
plotshape(at_ema200, title="Doji at 200 EMA", style=shape.labelup, location=location.belowbar, color=color.purple, text="Doji 200", textcolor=color.white)

// --- Alerts ---
alertcondition(doji_at_any_ema, title="Doji at EMA Alert", message="Doji candle formed at 50/100/200 EMA on {{ticker}}")
````
