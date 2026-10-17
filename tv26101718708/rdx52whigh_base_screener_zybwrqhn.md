# RDX-52W-High Base Screener

- url: https://www.tradingview.com/script/ZYbwRQhN-RDX-52W-High-Base-Screener/
- type: indicator
- pine_id: PUB;1c57e9aed099497e8e0d9d4c1c8073bd
- version: 1.0

## Description

Spike bar = a bar whose close-to-close move is ≥ your % threshold (so +10% vs the prior close; down bars are excluded automatically).
Within last N days = scan each of the last N bars as a candidate spike.
52-wk high = the spike bar's high is the highest high over ~252 trading days (toggleable).
"Stayed inside the move" / didn't undercut = every bar after the spike held above the spike bar's low. I made low-vs-close a toggle since "undercut" can mean either the wick or the close.
Pass = at least one spike bar in the window satisfies all of the above.

## Source Code

````pine
//@version=6
indicator("RDX-52W-High Base Screener", overlay=true)

// --- Tunable thresholds ---
high52Pct = input.float(2.5, "Max % below 52W high")   // criterion 1: at/near highs
near21Pct = input.float(3.0, "Max % from SMA21")       // criterion 2: not extended
near50Pct = input.float(8.0, "Max % above SMA50")      // criterion 3: not too far
slopeLen  = input.int(20,    "Slope lookback (bars)")  // criterion 4: trending up

sma21  = ta.sma(close, 21)
sma50  = ta.sma(close, 50)
sma200 = ta.sma(close, 200)
high52 = ta.highest(high, 252)   // ~52 weeks of trading days

// 1. Making/holding a new 52-week high
distHigh = (high52 - close) / high52 * 100
cond1 = distHigh <= high52Pct

// 2. Not extended — hugging the 21 SMA
dist21 = math.abs(close - sma21) / sma21 * 100
cond2 = dist21 <= near21Pct

// 3. Not too far above the 50 SMA (and above it)
dist50 = (close - sma50) / sma50 * 100
cond3 = close > sma50 and dist50 <= near50Pct

// 4. 21 / 50 / 200 all sloping up
cond4 = sma21 > sma21[slopeLen] and sma50 > sma50[slopeLen] and sma200 > sma200[slopeLen]

pass = cond1 and cond2 and cond3 and cond4

plot(distHigh, "Dist_52WHigh_%")
plot(dist21,   "Dist_SMA21_%")
plot(dist50,   "Dist_SMA50_%")
plot(pass ? 1 : 0, "Pass")
````
