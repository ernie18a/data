# PRIORAXIS Zone Bands

- url: https://www.tradingview.com/script/qMTjDHAS-PRIORAXIS-Zone-Bands/
- type: indicator
- pine_id: PUB;09db77a432684cada8aac89131dd6564
- version: 1.0

## Description

PRIORAXIS 200W Zones

WHAT IT SHOWS
This indicator measures how far Bitcoin's price is stretched from its
200-week moving average — one of the most-watched secular levels in BTC —
and ranks that distance against its own history on a 0–1 scale. The result
is split into five zones, Deep Value through Distribution, drawn as price
bands on the chart and colored on the bars.

HOW IT WORKS
Each week it takes the ratio of price to its 200-week MA, then finds where
that ratio sits in its own historical distribution (a rolling percentile).
The zone boundaries are percentile thresholds; each band is the price level
where that percentile historically sat, multiplied by today's 200-week MA.
Because the percentiles roll forward, the bands self-adjust as new cycles
print — the upper band compresses over time on its own, reflecting
Bitcoin's diminishing cycle amplitude. No fixed multipliers, no
curve-fitting.

HOW TO USE IT
Run it on the weekly timeframe, on a log price scale, on a long-history
Bitcoin symbol. Read it as secular context, not a timing signal: it tells
you whether price is historically cheap or expensive relative to its
long-term mean, so accumulation and distribution decisions are anchored to
data instead of emotion. The zone boundaries are inputs — adjust them to
your own framework.

WHAT IT IS NOT
This is a single factor. It lags, it does not call tops or bottoms, and its
extremes are estimated from a small number of historical cycles — treat the
boundaries as approximate, not precise. It is one input of a broader
multi-factor framework, not a complete model and not a trading system.

OPEN SOURCE BY DESIGN
The full code is public and verifiable. If you can read it, you can check
exactly what it does. No black box.

For informational and educational purposes only. This is not financial
advice, not a recommendation to buy or sell any asset, and past behavior
does not predict future results. Do your own research.

## Source Code

````pine
//@version=6
indicator("PRIORAXIS Zone Bands", shorttitle="PRIORAXIS Zones", overlay=true)

// ─── Metric inputs ───────────────────────────────────────
maLen   = input.int(200, "200W MA length (weeks)", minval=50, group="Metric")
rankLen = input.int(416, "Quantile lookback (weeks)", minval=52, group="Metric",
   tooltip="History the price/200W ratio is measured over. ~8 years.")

// ─── Zone boundaries (percentiles, 0–1) ─────────────────
b1 = input.float(0.40, "Deep Value → Value",     minval=0, maxval=1, step=0.01, group="Zone boundaries (percentile)")
b2 = input.float(0.58, "Value → Neutral",        minval=0, maxval=1, step=0.01, group="Zone boundaries (percentile)")
b3 = input.float(0.70, "Neutral → Caution",      minval=0, maxval=1, step=0.01, group="Zone boundaries (percentile)")
b4 = input.float(0.85, "Caution → Distribution", minval=0, maxval=1, step=0.01, group="Zone boundaries (percentile)")

// ─── Colors ──────────────────────────────────────────────
cDeep = input.color(#2e9e6b, "Deep Value",   group="Colors")
cVal  = input.color(#8bc34a, "Value",        group="Colors")
cNeut = input.color(#9e9e9e, "Neutral",      group="Colors")
cCaut = input.color(#f0a030, "Caution",      group="Colors")
cDist = input.color(#e2433f, "Distribution", group="Colors")
colorBars = input.bool(true, "Color price bars by zone", group="Display")

// ─── Metric: price / 200W MA ────────────────────────────
ma    = ta.sma(close, maLen)
ratio = close / ma

// ─── Zone boundaries as price levels (rolling quantiles) ─
pLo = ta.percentile_linear_interpolation(ratio, rankLen, 1)      * ma
p1  = ta.percentile_linear_interpolation(ratio, rankLen, b1*100) * ma
p2  = ta.percentile_linear_interpolation(ratio, rankLen, b2*100) * ma
p3  = ta.percentile_linear_interpolation(ratio, rankLen, b3*100) * ma
p4  = ta.percentile_linear_interpolation(ratio, rankLen, b4*100) * ma
pHi = ta.percentile_linear_interpolation(ratio, rankLen, 98)     * ma

// ─── Plot levels + fill zones ───────────────────────────
plLo = plot(pLo, "Floor",        color=color.new(cDeep, 65), linewidth=1)
pl1  = plot(p1,  "DV / Value",   color=color.new(cVal,  35), linewidth=1)
pl2  = plot(p2,  "Value / Neut", color=color.new(cNeut, 35), linewidth=1)
pl3  = plot(p3,  "Neut / Caut",  color=color.new(cCaut, 35), linewidth=1)
pl4  = plot(p4,  "Caut / Dist",  color=color.new(cDist, 35), linewidth=1)
plHi = plot(pHi, "Ceiling",      color=color.new(cDist, 65), linewidth=1)

fill(plLo, pl1,  color.new(cDeep, 90), title="Deep Value")
fill(pl1,  pl2,  color.new(cVal,  90), title="Value")
fill(pl2,  pl3,  color.new(cNeut, 90), title="Neutral")
fill(pl3,  pl4,  color.new(cCaut, 90), title="Caution")
fill(pl4,  plHi, color.new(cDist, 90), title="Distribution")

// ─── Current zone ───────────────────────────────────────
risk   = ta.percentrank(ratio, rankLen) / 100.0
zColor = risk < b1 ? cDeep : risk < b2 ? cVal : risk < b3 ? cNeut : risk < b4 ? cCaut : cDist
zName  = risk < b1 ? "DEEP VALUE" : risk < b2 ? "VALUE" : risk < b3 ? "NEUTRAL" : risk < b4 ? "CAUTION" : "DISTRIBUTION"

barcolor(colorBars ? zColor : na)

// ─── Readout: tag on the latest candle ───
var label tag = na
if barstate.islast
    label.delete(tag)
    tag := label.new(bar_index + 2, close,
       "PRIORAXIS  " + zName + "  " + str.tostring(risk, "0.00"),
       xloc=xloc.bar_index, yloc=yloc.price,
       style=label.style_label_left,
       color=color.new(zColor, 10), textcolor=color.white, size=size.normal)
````
