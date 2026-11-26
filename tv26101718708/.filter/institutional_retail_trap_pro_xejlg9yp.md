# Institutional Retail Trap PRO

- url: https://www.tradingview.com/script/xejLG9yP-Institutional-Retail-Trap-PRO/
- type: indicator
- pine_id: PUB;ec8e5233ee9f48dcac43df2b42fc9153
- version: 1.0

## Description

Description:
Institutional Retail Trap PRO is an advanced order flow indicator designed to identify the behavioral difference between institutional ("smart money") participants and retail traders — and more importantly, to detect when retail traders are caught on the wrong side of the market.
Unlike standard momentum indicators, this tool weights price movement against relative volume and candle displacement to estimate who is actually driving price at any given moment.

How it works:
The indicator calculates buy and sell pressure based on where price closes within each candle's range, then scales that pressure by relative volume (current volume vs. average volume). This creates a raw flow signal that is split into two streams — one representing institutional activity and one representing retail activity — both normalized using RSI to produce clear, readable oscillator lines.

The two lines:

Aqua line (Commercials / Smart Money) — rises when volume-weighted buying pressure dominates, suggesting institutional accumulation or aggressive buying
Red line (Retail Traders) — the inverse, rising when retail-style selling or chasing behavior dominates


Key levels:

Above 60 — dominant zone, one side is in control
50 — equilibrium, no clear dominance
Below 20 — exhaustion zone, the dominant flow is fading


Signals:

Lime circle (Smart Money Entry) — smart money line crosses above retail line while still in low territory, suggesting institutional accumulation beginning
Orange circle (Smart Money Exit) — smart money line crosses below retail line from high territory, suggesting distribution
Red triangle down (Retail Long Trap) — retail is overextended long while smart money is weak and price closes bearish with displacement — classic bull trap setup
Aqua triangle up (Retail Short Trap) — retail is overextended short while smart money is strong and price closes bullish with displacement — classic bear trap setup


Background shading:

Green background — smart money in dominant zone
Red background — retail flow dominant, potential exhaustion or reversal ahead


Displacement filter:
A built-in displacement filter ensures signals only trigger when the candle body exceeds the average range by a configurable multiplier. This filters out low-conviction signals during choppy, low-momentum periods.

Best used with:
Price action context, key support and resistance levels, volume profile, and multi-timeframe analysis. Works on all liquid markets — indices (ES, NQ, DAX), forex majors, gold (XAUUSD), and high-volume crypto pairs. Most effective on the 1m, 3m, 5m, and 15m timeframes for intraday trading.

Settings:

Flow Length — RSI normalization period (default 14)
Flow Smoothing — EMA smoothing on the raw flow signal (default 5)
Volume Average — baseline volume period for relative volume calculation (default 20)
Displacement Strength — multiplier for the candle body displacement filter (default 1.5)
Show Trap Signals — toggle all signals on/off
Show Zones — toggle zone fills on/off
Background Coloring — toggle background shading on/off


Note:
This indicator does not use real-time order book or Level 2 data. Institutional flow is estimated using price-volume analysis relative to recent averages. Always use in confluence with other tools and proper risk management. Past signals do not guarantee future results.

## Source Code

````pine
//@version=5
indicator("Institutional Retail Trap PRO", overlay=false, max_labels_count=500)

// =====================================================
// SETTINGS
// =====================================================
length         = input.int(14,   "Flow Length")
smoothLength   = input.int(5,    "Flow Smoothing")
volumeLength   = input.int(20,   "Volume Average")
signalStrength = input.float(1.5,"Displacement Strength", step=0.1)
showSignals    = input.bool(true, "Show Trap Signals")
showZones      = input.bool(true, "Show Zones")
showBackground = input.bool(true, "Background Coloring")

// =====================================================
// CORE FLOW ENGINE
// =====================================================
bodySize     = math.abs(close - open)
rangeSize    = high - low
avgRange     = ta.sma(rangeSize, 20)
displacement = bodySize > avgRange * signalStrength

volAvg       = ta.sma(volume, volumeLength)
relativeVol  = volume / volAvg

buyPressure  = ((close - low)  / math.max(rangeSize, syminfo.mintick)) * volume
sellPressure = ((high - close) / math.max(rangeSize, syminfo.mintick)) * volume

smartRaw    = (buyPressure - sellPressure) * relativeVol
smartFlow   = ta.ema(smartRaw,  smoothLength)
retailFlow  = ta.ema(-smartRaw, smoothLength)

// =====================================================
// NORMALIZATION
// =====================================================
smartIndex  = ta.rsi(smartFlow,  length)
retailIndex = ta.rsi(retailFlow, length)

// =====================================================
// ZONES
// =====================================================
commercialBase = 60
retailBase     = 20

// =====================================================
// BACKGROUND
// =====================================================
bgcolor(showBackground and smartIndex  > commercialBase ? color.new(color.green, 92) : na)
bgcolor(showBackground and retailIndex > commercialBase ? color.new(color.red,   92) : na)

// =====================================================
// ZONE LINES + FILLS
// =====================================================
commercialLine = hline(commercialBase, "Commercial Zone", color=color.new(color.green, 40))
retailLine     = hline(retailBase,     "Retail Zone",     color=color.new(color.red,   40))
midLine        = hline(50,             "Equilibrium",     color=color.new(color.gray,  70))

fill(commercialLine, midLine, color=showZones ? color.new(color.green, 92) : na)
fill(retailLine,     midLine, color=showZones ? color.new(color.red,   92) : na)

// =====================================================
// PLOTS
// =====================================================
plot(smartIndex,  title="Commercials", color=color.aqua, linewidth=3)
plot(retailIndex, title="Retail",      color=color.red,  linewidth=3)

// =====================================================
// LIQUIDITY TRAP LOGIC
// =====================================================
retailTrapLong  = retailIndex > 70 and smartIndex < 40 and displacement and close < open
retailTrapShort = retailIndex < 30 and smartIndex > 60 and displacement and close > open
smartEntry      = ta.crossover(smartIndex,  retailIndex) and smartIndex < 40
smartExit       = ta.crossunder(smartIndex, retailIndex) and smartIndex > 60

// =====================================================
// SIGNALS
// =====================================================
plotshape(showSignals and smartEntry,       title="Smart Buy",         style=shape.circle,        location=location.bottom, color=color.lime,   size=size.small)
plotshape(showSignals and smartExit,        title="Smart Sell",        style=shape.circle,        location=location.top,    color=color.orange, size=size.small)
plotshape(showSignals and retailTrapLong,   title="Retail Long Trap",  style=shape.triangledown,  location=location.top,    color=color.red,    size=size.normal)
plotshape(showSignals and retailTrapShort,  title="Retail Short Trap", style=shape.triangleup,    location=location.bottom, color=color.aqua,   size=size.normal)

// =====================================================
// ALERTS
// =====================================================
alertcondition(smartEntry,      title="Smart Money Entry",  message="Commercial traders entering")
alertcondition(smartExit,       title="Smart Money Exit",   message="Commercial traders exiting")
alertcondition(retailTrapLong,  title="Retail Long Trap",   message="Retail longs trapped")
alertcondition(retailTrapShort, title="Retail Short Trap",  message="Retail shorts trapped")
````
