# RS Rating vs Index

- url: https://www.tradingview.com/script/2GW7eE2W-RS-Rating-vs-Index/
- type: indicator
- pine_id: PUB;4712de4eeefb43c9a85882b1e9ea06f1
- version: 1.0

## Description

RS Rating vs Index — Sector & Market
Tracks how a stock is really performing — not just whether the price is going up, but whether it's beating the market and its own sector.
Most relative-strength tools only compare a stock to one benchmark. This one runs two comparisons at the same time: the stock against its sector index (e.g. CSL vs XHJ) and against the broader market (default XJO). That distinction matters more than people give it credit for. A stock can look strong purely because its whole sector is hot — this indicator lets you see through that and tell whether a name is actually leading its peers, or just along for the ride.
The rating itself is built the IBD way: weighted quarterly price performance with the most recent quarter counted double, then scaled to a 0–100 read using the stock's own trailing history. Above 70 and it's showing real strength versus the benchmark; below 30 and it's lagging.
One honest caveat: this isn't a true cross-sectional RS Rating like you'd get from IBD's full universe ranking — Pine indicators can't see every other stock on the exchange at once. What you're getting is each stock ranked against its own history of relative performance, which in practice tracks strength and weakness pretty closely, just without the "top 1% of 3,000 stocks" precision.
Set your own sector benchmark in the settings — defaults are ASX sector indices, but it'll work on any exchange if you swap the symbols.

## Source Code

````pine
//@version=6
indicator("RS Rating vs Index", shorttitle="RS Rating", overlay=false)

// =========================================================================
// RS RATING vs INDEX (IBD-style proxy)
//
// True IBD RS Rating ranks a stock's performance against an entire universe
// of stocks (cross-sectional ranking). A single-symbol Pine indicator can't
// do that — indicators run in isolation, so there's no access to the rest
// of the universe. This script instead computes:
//   1) An IBD-style weighted relative performance vs the chosen benchmark
//      (most recent quarter weighted 2x, per O'Neil methodology)
//   2) A percentrank of that relative performance against the stock's OWN
//      history, scaled 0-100, as a self-relative RS Rating proxy.
//
// For a true cross-sectional RS Rating, this needs to run inside a
// multi-symbol screener (like your ADR_RS_Early.pine architecture) where
// all universe symbols are pulled via request.security() and ranked
// against each other in the same bar.
// =========================================================================

// === Inputs ===
marketSym = input.symbol("ASX:XJO", title="Broad Market Benchmark")
sectorSym = input.symbol("ASX:XHJ", title="Sector Benchmark", tooltip="e.g. XHJ Health Care, XFJ Financials, XEJ Energy, XMJ Materials, XNJ Industrials, XTJ Info Tech, XDJ Cons. Discretionary, XSJ Cons. Staples, XPJ A-REIT, XUJ Utilities, XCJ Comm. Services")
showSector   = input.bool(true, title="Show Sector RS Rating")
showMarket   = input.bool(true, title="Show Broad Market RS Rating")
rsLookback   = input.int(252, title="RS Rating Percentrank Lookback", minval=20, tooltip="Number of bars used to rank today's relative strength against this stock's own history")

q1 = input.int(63,  title="Quarter 1 Lookback (most recent, weighted 2x)")
q2 = input.int(126, title="Quarter 2 Lookback")
q3 = input.int(189, title="Quarter 3 Lookback")
q4 = input.int(252, title="Quarter 4 Lookback")

showRSLine = input.bool(true, title="Show RS Line label (price ratios)")

// === Benchmark data ===
marketClose = request.security(marketSym, timeframe.period, close, lookahead=barmerge.lookahead_off)
sectorClose = request.security(sectorSym, timeframe.period, close, lookahead=barmerge.lookahead_off)

// === IBD-style weighted quarterly performance ===
// Most recent quarter counted twice, per O'Neil's original RS formula.
weightedPerf(src) =>
    r1 = src / src[q1] - 1
    r2 = src / src[q2] - 1
    r3 = src / src[q3] - 1
    r4 = src / src[q4] - 1
    (r1 * 2 + r2 + r3 + r4) / 5

stockPerf = weightedPerf(close)
marketPerf = weightedPerf(marketClose)
sectorPerf = weightedPerf(sectorClose)

// === Relative strength: stock's weighted performance minus benchmark's ===
relStrengthMarket = stockPerf - marketPerf
relStrengthSector = stockPerf - sectorPerf

// === RS Rating proxy (0-100 scale), one per benchmark ===
rsRatingMarket = ta.percentrank(relStrengthMarket, rsLookback)
rsRatingSector = ta.percentrank(relStrengthSector, rsLookback)

ratingColor(r) =>
    r >= 80 ? color.new(color.green, 0) :     r >= 70 ? color.new(color.lime, 0) :    r >= 50 ? color.new(color.yellow, 0) :  r >= 30 ? color.new(color.orange, 0) : color.new(color.red, 0)

// === Plot: sector as main colored line, market as reference blue line ===
plot(showSector ? rsRatingSector : na, title="RS Rating vs Sector (proxy)", color=ratingColor(rsRatingSector), linewidth=2)
plot(showMarket ? rsRatingMarket : na, title="RS Rating vs Market (proxy)", color=color.new(color.blue, 20), linewidth=1)

hline(80, "Very Strong (80)", color=color.new(color.green, 60), linestyle=hline.style_dashed)
hline(70, "IBD Threshold (70)", color=color.new(color.green, 30), linestyle=hline.style_solid)
hline(50, "Neutral (50)", color=color.new(color.gray, 60), linestyle=hline.style_dotted)
hline(30, "Weak (30)", color=color.new(color.red, 30), linestyle=hline.style_solid)

bgcolor(showSector and rsRatingSector >= 70 ? color.new(color.green, 92) : showSector and rsRatingSector <= 30 ? color.new(color.red, 92) : na)

// === Info label on last bar ===
rsLineMarket = close / marketClose
rsLineSector = close / sectorClose
var label infoLabel = na
if showRSLine and barstate.islast
    label.delete(infoLabel)
    infoLabel := label.new(bar_index, math.max(rsRatingSector, rsRatingMarket),
         "RS vs Sector (" + syminfo.ticker(sectorSym) + "): " + str.tostring(rsRatingSector, "#.##") + "  [line " + str.tostring(rsLineSector, "#.####") + "]" +
         "\nRS vs Market (" + syminfo.ticker(marketSym) + "): " + str.tostring(rsRatingMarket, "#.##") + "  [line " + str.tostring(rsLineMarket, "#.####") + "]",
         style=label.style_label_left,
         color=color.new(color.blue, 80),
         textcolor=color.white,
         size=size.small)
````
