# ATR Trailing Stop Strategy with EMA Trend Filter

- url: https://www.tradingview.com/script/43eIQfDj-ATR-Trailing-Stop-Strategy-with-EMA-Trend-Filter/
- type: strategy
- pine_id: PUB;96ae04cda31a42d8a0fb885cd120e04b
- version: 1.0

## Description

Most stop-loss approaches treat risk as a fixed number, a percentage, a dollar amount, a set number of points. The problem with fixed stops is that they ignore the market's actual behavior at any given moment. A 1% stop that makes sense in a low-volatility environment will get hit constantly in a high-volatility one. A wide fixed stop that survives a volatile period is needlessly large when the market quiets down.

ATR-based trailing stops solve this by scaling the stop distance to what the market is actually doing right now. ATR measures average true range, the average distance price moves per bar over a given period, including gaps. When volatility expands, the stop widens to give the trade room to breathe. When volatility contracts, the stop tightens to protect more of the open profit. The stop follows price as it moves in the trade's direction and never moves backward — only trailing further in the profitable direction or holding its level until price reverses through it and the trade closes.

The EMA filter is added for one specific reason: trailing stop systems are naturally reactive rather than predictive, which means without a trend filter they will generate signals in both directions during choppy, range-bound conditions. The 200 EMA acts as a simple regime gate. 

Long trades are only considered when price is above the 200 EMA, broadly in an uptrend. Short trades are only considered when price is below it. This doesn't eliminate losing trades, but it meaningfully reduces the number of counter-trend entries that trail stop systems would otherwise generate in oscillating markets.

[b]How the trailing stop works:[/b]

On each bar, the strategy calculates a long stop level at close - (ATR × multiplier) and a short stop level at close + (ATR × multiplier). When price is in an uptrend, the long stop ratchets upward with price but never moves down, it holds its highest reached level until price closes below it, at which point the trend flips to bearish and the stop becomes a downward-trailing short stop. The opposite applies in a downtrend. A trend flip from bearish to bullish generates a long entry signal if price is above the 200 EMA. A flip from bullish to bearish generates a short entry signal if price is below the 200 EMA.

[b]Parameters worth adjusting:[/b]

The ATR multiplier controls the sensitivity of the trailing stop. A lower multiplier (1.5x or below) produces a tighter stop that flips trend direction more frequently, useful on lower timeframes where you want faster reaction but will generate more signals. A higher multiplier (2.5x or above) produces a wider stop that flips less often, better suited for higher timeframes where you want to stay in a trend longer and can tolerate larger drawdowns on individual trades before exit. The ATR length controls how many bars the average is computed over. Shorter lengths react faster to recent volatility changes; longer lengths smooth out volatility spikes.

The EMA length can be adjusted depending on your timeframe. 200 periods is the standard for daily charts. On a 4-hour chart, 100 to 150 periods covers a similar calendar range. On a 1-hour chart, 50 to 100 periods is reasonable. The goal is for the EMA to represent the dominant trend, not a short-term moving average that whipsaws with every swing.

[b]What this is not:[/b]

This strategy does not predict market direction. It reacts to price behavior and exits when price reverses by a defined volatility-adjusted distance. It will produce losing trades, every trailing stop system does, and sequences of losses in choppy conditions are expected behavior, not a flaw. The expectation is that winning trades capture significantly more than they risk because the stop trails and locks in profit, while losing trades are cut at a defined ATR-based distance. 

Evaluate this on your own instruments and timeframes with realistic backtest conditions before drawing any conclusions about expected performance.

Shared for educational purposes. This is not investment advice. Always backtest thoroughly and size positions according to your own risk tolerance.

## Source Code

````pine
//@version=6
strategy("ATR Trailing Stop + EMA Filter", overlay=true,
     default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// ── INPUTS ─────────────────────────────────────────────
atrLen  = input.int(14,    "ATR Length",     group="ATR Trailing Stop")
atrMult = input.float(2.0, "ATR Multiplier", group="ATR Trailing Stop", step=0.1)
emaLen  = input.int(200,   "EMA Length",     group="Trend Filter")

// ── INDICATORS ──────────────────────────────────────────
atrVal = ta.atr(atrLen)
emaVal = ta.ema(close, emaLen)

// ── ATR TRAILING STOP ───────────────────────────────────
var float trail   = na
var bool  upTrend = true

longStop  = close - atrVal * atrMult
shortStop = close + atrVal * atrMult

if na(trail)
    trail   := longStop
    upTrend := true
else
    if upTrend[1]
        trail   := close < trail[1] ? shortStop : math.max(trail[1], longStop)
    else
        trail   := close > trail[1] ? longStop  : math.min(trail[1], shortStop)
    upTrend := close >= trail

// ── TREND FILTER ────────────────────────────────────────
emaLong  = close > emaVal
emaShort = close < emaVal

// ── FLIP DETECTION ──────────────────────────────────────
flipToLong  = upTrend  and not upTrend[1]
flipToShort = not upTrend and upTrend[1]

// ── ENTRY CONDITIONS ────────────────────────────────────
longCond  = flipToLong  and emaLong  and strategy.position_size <= 0
shortCond = flipToShort and emaShort and strategy.position_size >= 0

// ── EXECUTION ───────────────────────────────────────────
if longCond
    strategy.entry("Long",  strategy.long,
         alert_message="ATR Trail flip to long — {{ticker}} @ {{close}}")

if shortCond
    strategy.entry("Short", strategy.short,
         alert_message="ATR Trail flip to short — {{ticker}} @ {{close}}")

// ── VISUALS ─────────────────────────────────────────────
plot(trail,  "ATR Trailing Stop", color=upTrend ? color.green : color.red, linewidth=2)
plot(emaVal, "EMA Trend Filter",  color=color.new(color.blue, 50), linewidth=1)

plotshape(longCond,  location=location.belowbar, color=color.green,
     style=shape.triangleup,   size=size.small, text="L")
plotshape(shortCond, location=location.abovebar, color=color.red,
     style=shape.triangledown, size=size.small, text="S")
````
