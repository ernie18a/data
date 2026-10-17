# PPO Divergence Strategy

- url: https://www.tradingview.com/script/WrEqzgAo-PPO-Divergence-Strategy/
- type: strategy
- pine_id: PUB;5fc8e26b4d2144e98ce0e32a1923c00a
- version: 1.0

## Description

PPO Divergence Strategy is a momentum-based trading approach that identifies potential market reversals by analyzing divergences between price action and the Percentage Price Oscillator (PPO).

At its core, the strategy looks for situations where price is making higher highs or lower lows, but the PPO fails to confirm that movement. This mismatch—known as divergence—often signals weakening momentum and a possible shift in trend direction.

A bearish divergence occurs when price forms higher highs while the PPO forms lower highs, suggesting that upward momentum is fading and a downside reversal may be imminent.
A bullish divergence appears when price makes lower lows while the PPO forms higher lows, indicating that selling pressure is weakening and a potential upward reversal could follow.

The strategy typically combines these divergence signals with additional confirmation factors—such as support and resistance levels, trend structure, or signal line crossovers—to refine entries and reduce false signals.

Risk management plays a key role, with trades often structured around recent swing highs/lows or volatility-based stops, ensuring that invalidated setups are exited quickly.

Overall, your PPO Divergence Strategy aims to capture early trend reversals by spotting momentum shifts before they become obvious in price alone.

## Source Code

````pine

//@version=6
strategy("PPO Divergence Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// --- Inputs ---
fastLen   = input.int(12, "Fast EMA Length", minval=1)
slowLen   = input.int(26, "Slow EMA Length", minval=1)
signalLen = input.int(9,  "Signal Length",   minval=1)
pivotLen  = input.int(5,  "Pivot Lookback",  minval=2)

// --- Risk Management ---
slPct = input.float(2.0, "Stop Loss %",    minval=0.1, step=0.1)
tpPct = input.float(4.0, "Take Profit %",  minval=0.1, step=0.1)

// --- PPO Calculation ---
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
ppo     = (fastEMA - slowEMA) / slowEMA * 100
signal  = ta.ema(ppo, signalLen)
hist    = ppo - signal

// --- Pivot Detection ---
pivotHigh_price = ta.pivothigh(high,  pivotLen, pivotLen)
pivotLow_price  = ta.pivotlow(low,   pivotLen, pivotLen)
pivotHigh_ppo   = ta.pivothigh(ppo,  pivotLen, pivotLen)
pivotLow_ppo    = ta.pivotlow(ppo,   pivotLen, pivotLen)

// --- Track last two pivots for divergence ---
var float prevPriceLow  = na
var float prevPpoLow    = na
var float prevPriceHigh = na
var float prevPpoHigh   = na

var float lastPriceLow  = na
var float lastPpoLow    = na
var float lastPriceHigh = na
var float lastPpoHigh   = na

if not na(pivotLow_price)
    prevPriceLow := lastPriceLow
    prevPpoLow   := lastPpoLow
    lastPriceLow := pivotLow_price
    lastPpoLow   := pivotLow_ppo

if not na(pivotHigh_price)
    prevPriceHigh := lastPriceHigh
    prevPpoHigh   := lastPpoHigh
    lastPriceHigh := pivotHigh_price
    lastPpoHigh   := pivotHigh_ppo

// --- Divergence Detection ---
bullDiv = not na(prevPriceLow) and not na(prevPpoLow) and not na(lastPriceLow) and not na(lastPpoLow) and (lastPriceLow < prevPriceLow) and (lastPpoLow > prevPpoLow)
bearDiv = not na(prevPriceHigh) and not na(prevPpoHigh) and not na(lastPriceHigh) and not na(lastPpoHigh) and (lastPriceHigh > prevPriceHigh) and (lastPpoHigh < prevPpoHigh)

// --- Signals ---
bullSignal = bullDiv and not na(pivotLow_price)
bearSignal = bearDiv and not na(pivotHigh_price)

// --- Plot signals on chart ---
plotshape(bullSignal, title="Bullish Div", location=location.belowbar, style=shape.triangleup,   color=color.new(color.green, 0), size=size.small, text="Bull Div")
plotshape(bearSignal, title="Bearish Div", location=location.abovebar, style=shape.triangledown, color=color.new(color.red,   0), size=size.small, text="Bear Div")

// --- Strategy Entries with SL/TP ---
if bullSignal
    sl = close * (1 - slPct / 100)
    tp = close * (1 + tpPct / 100)
    strategy.entry("Long", strategy.long)
    strategy.exit("Long Exit", from_entry="Long", stop=sl, limit=tp)

if bearSignal
    sl = close * (1 + slPct / 100)
    tp = close * (1 - tpPct / 100)
    strategy.entry("Short", strategy.short)
    strategy.exit("Short Exit", from_entry="Short", stop=sl, limit=tp)

// --- PPO Panel ---
plot(ppo,    "PPO",    color=color.new(color.blue,  0), linewidth=2, display=display.pane)
plot(signal, "Signal", color=color.new(color.orange,0), linewidth=1, display=display.pane)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dashed)
plot(hist,   "Hist",   color=hist >= 0 ? color.new(color.teal, 60) : color.new(color.red, 60), style=plot.style_columns, display=display.pane)
````
