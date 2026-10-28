# Developing FAB4 Zone

- url: https://www.tradingview.com/script/Q6Cff6nq-Developing-FAB4-Zone/
- type: indicator
- pine_id: PUB;2575baf027df40a7a4e70ffe9a19490f
- version: 1.0

## Description

# Developing FAB4 Zone — Indicator Documentation

## Overview
The Developing FAB4 Zone is a TradingView indicator designed to visualize a dynamic price zone using four key reference elements: the 20 SMA, 200 SMA, current day's closing price, and the high and low of the last 45 minutes.

## Calculation Logic
- **20 SMA:** Identifies the short-term trend.
- **200 SMA:** Provides a longer-term trend reference.
- **Current day's closing price:** Uses the latest available price/close during the ongoing session.
- **Last 45-minute high and low:** Tracks the highest and lowest prices over a rolling 45-minute window. On a 2-minute chart, this uses 23 candles (approximately 46 minutes).

## Zone Formation
- **Zone High:** The highest value among the 20 SMA, 200 SMA, current price, and rolling 45-minute high.
- **Zone Low:** The lowest value among the 20 SMA, 200 SMA, current price, and rolling 45-minute low.

The zone updates as market conditions change, allowing traders to observe shifts in price structure and key reference levels.

## Intended Use
The indicator is intended to help traders visualize dynamic support and resistance areas, monitor price relative to moving averages, and identify potential breakout or rejection zones.

**Note:** This is a custom interpretation of the FAB4 concept, not a verified reproduction of Oliver Velez's exact trading rules. The indicator provides visual reference levels and does not independently generate trade signals.

## Source Code

````pine

 //@version=6
indicator("Developing FAB4 Zone", overlay=true)

// ── Inputs ──
smaFastLen = input.int(20, "Fast SMA Length", minval=1)
smaSlowLen = input.int(200, "Slow SMA Length", minval=1)
rangeMinutes = input.int(45, "Rolling Range (Minutes)", minval=2)

showSMAs = input.bool(true, "Show 20 & 200 SMA")
showZone = input.bool(true, "Show Developing Zone")
showRange = input.bool(true, "Show Rolling High/Low")

// ── Calculate lookback ──
barMinutes = timeframe.in_seconds() / 60.0
barsNeeded = math.max(1, int(math.ceil(rangeMinutes / barMinutes)))

// ── Moving averages ──
sma20 = ta.sma(close, smaFastLen)
sma200 = ta.sma(close, smaSlowLen)

// ── Reset rolling range at start of each day ──
newDay = timeframe.change("D")
barsToday = nz(ta.barssince(newDay), 0) + 1
effectiveBars = math.max(1, math.min(barsNeeded, barsToday))

rangeHigh = ta.highest(high, effectiveBars)
rangeLow = ta.lowest(low, effectiveBars)

// ── Developing FAB4 zone ──
// Zone includes the 20 SMA, 200 SMA, current close,
// and rolling 45-minute high/low.
zoneHigh = math.max(
     math.max(sma20, sma200),
     math.max(close, rangeHigh))

zoneLow = math.min(
     math.min(sma20, sma200),
     math.min(close, rangeLow))

// ── Plot moving averages ──
plot(showSMAs ? sma20 : na, title="20 SMA",
     color=color.orange, linewidth=2)

plot(showSMAs ? sma200 : na, title="200 SMA",
     color=color.blue, linewidth=2)

// ── Plot rolling high and low ──
plot(showRange ? rangeHigh : na, title="Last 45m High",
     color=color.green, linewidth=1,
     style=plot.style_stepline)

plot(showRange ? rangeLow : na, title="Last 45m Low",
     color=color.red, linewidth=1,
     style=plot.style_stepline)

// ── Plot developing zone ──
pHigh = plot(showZone ? zoneHigh : na,
     title="FAB4 Zone High",
     color=color.lime, linewidth=2)

pLow = plot(showZone ? zoneLow : na,
     title="FAB4 Zone Low",
     color=color.fuchsia, linewidth=2)

// ── Shade the zone ──
fill(pHigh, pLow,
     color=showZone ? color.new(color.aqua, 88) : na,
     title="Developing FAB4 Zone")
````
