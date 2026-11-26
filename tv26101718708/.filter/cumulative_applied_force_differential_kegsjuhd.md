# Cumulative Applied Force Differential

- url: https://www.tradingview.com/script/keGsJUHD-Cumulative-Applied-Force-Differential/
- type: indicator
- pine_id: PUB;6c10553676d848efb7d6cc14e77b08ad
- version: 7.0

## Description

[b]What[/b]
The purpose of the model is to measure how buying and selling pressure builds up during today’s session and compare it directly to how pressure built up at the same moment in the previous session. By aligning both sessions bar‑for‑bar, the model reveals whether today’s market is applying more, less, or opposite “force” than yesterday. This gives traders a real‑time view of strength, weakness, or behavioral shifts that price alone cannot show.

[b]How[/b]
The model calculates market pressure using cumulative delta, which is built from bid/ask proxy volume; a method that estimates whether buyers or sellers were more aggressive on each bar. Each bar’s net pressure is added to a running total, creating a live measure of how buying or selling force accumulates throughout the session. To contextualize this pressure, the script also classifies each bar into ATR‑defined zones (upper, lower, or neutral), helping identify whether pressure is building near extremes or in the middle of the range.
Every cumulative delta value is stored in a session‑indexed array, which acts like a timeline of the session: bar 1, bar 2, bar 3, and so on. When a new session begins, yesterday’s array is saved, and a fresh one starts for today. Because both arrays are indexed by bar number, the script can match today’s bar with yesterday’s bar at each timepoint. This alignment allows the model to retrieve yesterday’s cumulative delta at the exact same point in the session and compare it to today’s value. The script then computes the divergence, at each bar, the model takes today’s cumulative delta and subtracts yesterday’s cumulative delta at the same point in the session to find how much stronger or weaker today’s pressure is. This difference is the market‑microstructure equivalent of a Cumulative Applied Force Differential; a measure of whether today’s pressure is stronger, weaker, or reversing relative to the previous session. The results are displayed in a table showing today’s value, yesterday’s aligned value, and the differential, with color coding to highlight strength, weakness, or neutrality at a glance.

[b]Why[/b]
The rationale behind the model is that cumulative delta becomes far more meaningful when compared in context rather than viewed in isolation. Markets often repeat, invert, or distort behavioral patterns across sessions, and aligning sessions by bar index exposes these patterns with precision. By measuring the differential between today’s accumulated pressure and yesterday’s at the same moment, the model highlights acceleration, fading strength, absorption, or early signs of reversal before they appear in price. In essence, it quantifies how today’s underlying “force profile” deviates from yesterday’s, giving traders an objective and early read on evolving market intent.

## Source Code

````pine
//@version=6
indicator("CAFD – Core 6 Curves (VWAP Anchor)", "CAFD Core+", overlay=false)

//---------------------------------------------------------
// 1. Inputs
//---------------------------------------------------------
srcMid = input.source(hl2, "Source Midline")
anchor = input.string("Session", "Anchor Period",
 options=["Session","Week","Month","Quarter","Year","Decade","Century",
          "Earnings","Dividends","Splits"])
atrLen = input.int(14, "ATR Length")

//---------------------------------------------------------
// 2. VWAP-Style Anchor Logic
//---------------------------------------------------------
isNewPeriod = switch anchor
    "Earnings" =>
        new_earnings_actual = request.earnings(syminfo.tickerid, earnings.actual,
            barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        new_earnings_standardized = request.earnings(syminfo.tickerid, earnings.standardized,
            barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_earnings_actual) or not na(new_earnings_standardized)

    "Dividends" =>
        new_div = request.dividends(syminfo.tickerid, dividends.gross,
            barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_div)

    "Splits" =>
        new_split = request.splits(syminfo.tickerid, splits.denominator,
            barmerge.gaps_on, barmerge.lookahead_on, ignore_invalid_symbol=true)
        not na(new_split)

    "Session" => timeframe.change("D")
    "Week"    => timeframe.change("W")
    "Month"   => timeframe.change("M")
    "Quarter" => timeframe.change("3M")
    "Year"    => timeframe.change("12M")
    "Decade"  => timeframe.change("12M") and year % 10 == 0
    "Century" => timeframe.change("12M") and year % 100 == 0
    => false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(srcMid[1]) and not isEsdAnchor
    isNewPeriod := true

//---------------------------------------------------------
// 3. Volume Split Logic
//---------------------------------------------------------
priceRange = math.max(high - low, syminfo.mintick)
askVolBar  = volume * (close - low)  / priceRange
bidVolBar  = volume * (high - close) / priceRange

//---------------------------------------------------------
// 4. ATR Upper/Lower Zones
//---------------------------------------------------------
atr        = ta.atr(atrLen)
upperLimit = srcMid + atr
lowerLimit = srcMid - atr

inUpper = close > srcMid and close <= upperLimit
inLower = close < srcMid and close >= lowerLimit

upperAskVol = inUpper ? askVolBar : 0.0
upperBidVol = inUpper ? bidVolBar : 0.0
lowerAskVol = inLower ? askVolBar : 0.0
lowerBidVol = inLower ? bidVolBar : 0.0

//---------------------------------------------------------
// 5. Cumulative Curves (Core 4)
//---------------------------------------------------------
var float cumUpperAsk = 0.0
var float cumUpperBid = 0.0
var float cumLowerAsk = 0.0
var float cumLowerBid = 0.0

cumUpperAsk := isNewPeriod ? upperAskVol : cumUpperAsk + upperAskVol
cumUpperBid := isNewPeriod ? upperBidVol : cumUpperBid + upperBidVol
cumLowerAsk := isNewPeriod ? lowerAskVol : cumLowerAsk + lowerAskVol
cumLowerBid := isNewPeriod ? lowerBidVol : cumLowerBid + lowerBidVol

//---------------------------------------------------------
// 6. NEW: Total Buy/Sell Curves
//---------------------------------------------------------
// cumBuyTotal  = cumUpperAsk + cumLowerAsk
// cumSellTotal = cumUpperBid + cumLowerBid
// delta = cumBuyTotal - cumSellTotal

//---------------------------------------------------------
// 7. Plots (6 Curves)
//---------------------------------------------------------
plot(cumUpperAsk, "Cum Upper Ask", color=color.new(color.lime, 20), linewidth=1)
plot(cumUpperBid, "Cum Upper Bid", color=color.new(color.orange, 20), linewidth=1)
plot(cumLowerAsk, "Cum Lower Ask", color=color.new(color.teal, 20), linewidth=1)
plot(cumLowerBid, "Cum Lower Bid", color=color.new(color.red, 20), linewidth=1)

// plot(cumBuyTotal,  "Total Buy",  color=color.new(color.blue, 0), linewidth=1)
// plot(cumSellTotal, "Total Sell", color=color.new(color.yellow, 0), linewidth=1)

// plot(delta, "Delta", color=color.new(color.white, 0), linewidth=1)

hline(0, color = color.gray)
````
