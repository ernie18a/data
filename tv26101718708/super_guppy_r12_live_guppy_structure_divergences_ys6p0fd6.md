# Super Guppy R1.2 + LIVE Guppy Structure Divergences

- url: https://www.tradingview.com/script/yS6p0FD6-Super-Guppy-R1-2-LIVE-Guppy-Structure-Divergences/
- type: indicator
- pine_id: PUB;71989fea6bc749b68b023d741edbfdf8
- version: 2.0

## Description

# Super Guppy R1.2 + LIVE Guppy Structure Divergences

**Super Guppy R1.2 + LIVE Guppy Structure Divergences** combines a Guppy-style multi-EMA trend ribbon with a custom divergence engine designed to identify potential weakening in market structure before or around major turning points.

Rather than relying on a traditional oscillator such as RSI or MACD, the divergence system analyses the behaviour of the **Guppy EMA structure itself**.

### Guppy Trend Structure

The indicator uses two EMA groups:

**Fast Guppy:** 3–23 periods  
**Slow Guppy:** 25–70 periods

The relationship and ordering of these averages are used to visualise trend direction, trend alignment and changes in momentum.

Optional features include:

- Fast and slow Guppy averages
- EMA 200 trend filter
- Candle colouring based on Guppy trend
- Swing signals
- Trend-break signals
- Fast/slow trend confluence
- Alternate timeframe anchoring

### Guppy Structure Divergences

The main additional feature is a custom divergence system that compares new price extremes with the internal behaviour of the Guppy structure.

A **bearish Guppy divergence** occurs when price makes a higher high while one or more Guppy strength measurements fail to confirm that strength.

A **bullish Guppy divergence** occurs when price makes a lower low while the Guppy structure shows reduced downside participation.

The divergence engine can evaluate up to six components:

1. **Fast Average Divergence** — compares the behaviour of the fast Guppy average between price extremes.
2. **Slow Average Divergence** — measures whether the slower trend structure confirms the new extreme.
3. **Fast/Slow Spread Divergence** — evaluates changes in separation between the fast and slow Guppy groups.
4. **Ribbon Expansion Divergence** — checks whether overall Guppy ribbon expansion is weakening.
5. **Price Rejection** — incorporates ATR-normalised wick/rejection behaviour at the extreme.
6. **Time Divergence** — optionally considers whether the new price extreme required more time to develop.

These components are combined into a configurable **divergence score from 1–6**.

### LIVE vs Confirmed Divergences

The indicator provides two types of divergence signals.

**LIVE Guppy Divergence**

LIVE signals attempt to identify divergence while a price extreme is still developing. This can provide earlier information, but the signal can move, change score or disappear as price continues to develop.

For this reason, LIVE divergences should be considered **developing signals and may repaint**.

**Confirmed Guppy Divergence**

Confirmed signals use completed pivot structure. Once the required pivot-right bars have formed, the price pivot becomes fixed and the divergence is evaluated against the previous confirmed structural extreme.

These signals appear later than LIVE signals but provide a more stable historical reference.

### Trend-Bias Upgrade

Divergence signals can optionally be upgraded when the current Guppy trend structure has already moved into agreement with the potential reversal.

For example, a bullish divergence becomes more significant structurally when the Guppy configuration also begins showing bullish alignment.

### Interactive Signal Information

Hovering over a divergence label provides additional information including:

- Divergence direction
- LIVE or confirmed status
- Divergence score
- Which individual divergence components passed or failed
- Current Guppy trend agreement
- Explanation of the price/structure relationship

### Alerts

Alerts are available for:

- Guppy buy signals
- Guppy sell signals
- LIVE bullish Guppy divergence
- LIVE bearish Guppy divergence
- Confirmed bullish Guppy divergence
- Confirmed bearish Guppy divergence

### Suggested Use

This indicator is intended primarily as a **trend-structure and confluence tool**, rather than a standalone buy/sell system.

Higher divergence scores indicate that more of the selected Guppy measurements are showing divergence simultaneously; they do not guarantee a reversal.

LIVE signals can be useful for early awareness, while confirmed signals can be used when greater structural confirmation is preferred.

As with any technical indicator, signals should be evaluated alongside price structure, support/resistance, volume, liquidity and appropriate risk management.

**For educational and analytical purposes only. This indicator does not constitute financial advice.**

## Source Code

````pine
//@version=6

indicator(

     title="Super Guppy R1.2 + LIVE Guppy Structure Divergences",

     shorttitle="SuperGuppy DIV",

     overlay=true,

     max_labels_count=500,

     max_lines_count=200

)

//══════════════════════════════════════════════════════════════════════════════

// 1. ORIGINAL SUPER GUPPY SETTINGS

//══════════════════════════════════════════════════════════════════════════════

groupMain = "1. Super Guppy"

anchor     = input.int(0, "Alternate Anchor Timeframe (minutes, 0 = none)", minval=0, maxval=30240, group=groupMain)

src        = input.source(close, "EMA Source", group=groupMain)

showBreak  = input.bool(true, "Show Trend Break Arrows", group=groupMain)

showSwing  = input.bool(true, "Show Swing Arrows", group=groupMain)

showCon    = input.bool(false, "Require Fast + Slow Confluence", group=groupMain)

useBarFlip = input.bool(false, "Add Candle Colour Change to Swing Alerts", group=groupMain)

lookback   = input.int(6, "Alert Lookback", minval=1, group=groupMain)

showAvgs   = input.bool(false, "Show Average Fast and Slow Curves", group=groupMain)

show200    = input.bool(false, "Show EMA 200", group=groupMain)

emaFilter  = input.bool(false, "Filter Alerts with EMA 200", group=groupMain)

clrBars    = input.bool(false, "Colour Candles by Guppy Trend", group=groupMain)

// Fast EMAs

groupFast = "2. Fast Guppy EMAs"

lenF1  = input.int(3,  "Fast EMA 1",  minval=1, group=groupFast)

lenF2  = input.int(5,  "Fast EMA 2",  minval=1, group=groupFast)

lenF3  = input.int(7,  "Fast EMA 3",  minval=1, group=groupFast)

lenF4  = input.int(9,  "Fast EMA 4",  minval=1, group=groupFast)

lenF5  = input.int(11, "Fast EMA 5",  minval=1, group=groupFast)

lenF6  = input.int(13, "Fast EMA 6",  minval=1, group=groupFast)

lenF7  = input.int(15, "Fast EMA 7",  minval=1, group=groupFast)

lenF8  = input.int(17, "Fast EMA 8",  minval=1, group=groupFast)

lenF9  = input.int(19, "Fast EMA 9",  minval=1, group=groupFast)

lenF10 = input.int(21, "Fast EMA 10", minval=1, group=groupFast)

lenF11 = input.int(23, "Fast EMA 11", minval=1, group=groupFast)

// Slow EMAs

groupSlow = "3. Slow Guppy EMAs"

lenS1  = input.int(25, "Slow EMA 1",  minval=1, group=groupSlow)

lenS2  = input.int(28, "Slow EMA 2",  minval=1, group=groupSlow)

lenS3  = input.int(31, "Slow EMA 3",  minval=1, group=groupSlow)

lenS4  = input.int(34, "Slow EMA 4",  minval=1, group=groupSlow)

lenS5  = input.int(37, "Slow EMA 5",  minval=1, group=groupSlow)

lenS6  = input.int(40, "Slow EMA 6",  minval=1, group=groupSlow)

lenS7  = input.int(43, "Slow EMA 7",  minval=1, group=groupSlow)

lenS8  = input.int(46, "Slow EMA 8",  minval=1, group=groupSlow)

lenS9  = input.int(49, "Slow EMA 9",  minval=1, group=groupSlow)

lenS10 = input.int(52, "Slow EMA 10", minval=1, group=groupSlow)

lenS11 = input.int(55, "Slow EMA 11", minval=1, group=groupSlow)

lenS12 = input.int(58, "Slow EMA 12", minval=1, group=groupSlow)

lenS13 = input.int(61, "Slow EMA 13", minval=1, group=groupSlow)

lenS14 = input.int(64, "Slow EMA 14", minval=1, group=groupSlow)

lenS15 = input.int(67, "Slow EMA 15", minval=1, group=groupSlow)

lenS16 = input.int(70, "Slow EMA 16", minval=1, group=groupSlow)

len200 = input.int(200, "EMA 200 Length", minval=1, group=groupMain)

// Anchor multiplier.

float chartMinutes =

     timeframe.isseconds ? timeframe.multiplier / 60.0 :

     timeframe.isintraday ? timeframe.multiplier :

     timeframe.isdaily ? 1440.0 * timeframe.multiplier :

     timeframe.isweekly ? 7200.0 * timeframe.multiplier :

     timeframe.ismonthly ? 30240.0 * timeframe.multiplier : 1.0

int mult = anchor <= 0 or chartMinutes >= anchor ? 1 : math.max(1, int(math.round(anchor / chartMinutes)))

// Fast ribbon

emaF1  = ta.ema(src, lenF1  * mult)

emaF2  = ta.ema(src, lenF2  * mult)

emaF3  = ta.ema(src, lenF3  * mult)

emaF4  = ta.ema(src, lenF4  * mult)

emaF5  = ta.ema(src, lenF5  * mult)

emaF6  = ta.ema(src, lenF6  * mult)

emaF7  = ta.ema(src, lenF7  * mult)

emaF8  = ta.ema(src, lenF8  * mult)

emaF9  = ta.ema(src, lenF9  * mult)

emaF10 = ta.ema(src, lenF10 * mult)

emaF11 = ta.ema(src, lenF11 * mult)

emafast = (emaF1 + emaF2 + emaF3 + emaF4 + emaF5 + emaF6 + emaF7 + emaF8 + emaF9 + emaF10 + emaF11) / 11.0

// Slow ribbon

emaS1  = ta.ema(src, lenS1  * mult)

emaS2  = ta.ema(src, lenS2  * mult)

emaS3  = ta.ema(src, lenS3  * mult)

emaS4  = ta.ema(src, lenS4  * mult)

emaS5  = ta.ema(src, lenS5  * mult)

emaS6  = ta.ema(src, lenS6  * mult)

emaS7  = ta.ema(src, lenS7  * mult)

emaS8  = ta.ema(src, lenS8  * mult)

emaS9  = ta.ema(src, lenS9  * mult)

emaS10 = ta.ema(src, lenS10 * mult)

emaS11 = ta.ema(src, lenS11 * mult)

emaS12 = ta.ema(src, lenS12 * mult)

emaS13 = ta.ema(src, lenS13 * mult)

emaS14 = ta.ema(src, lenS14 * mult)

emaS15 = ta.ema(src, lenS15 * mult)

emaS16 = ta.ema(src, lenS16 * mult)

emaslow = (

     emaS1 + emaS2 + emaS3 + emaS4 + emaS5 + emaS6 + emaS7 + emaS8 +

     emaS9 + emaS10 + emaS11 + emaS12 + emaS13 + emaS14 + emaS15 + emaS16

) / 16.0

ema200 = ta.ema(src, len200 * mult)

// Complete ribbon ordering

colfastL = emaF1 > emaF2 and emaF2 > emaF3 and emaF3 > emaF4 and emaF4 > emaF5 and emaF5 > emaF6 and emaF6 > emaF7 and emaF7 > emaF8 and emaF8 > emaF9 and emaF9 > emaF10 and emaF10 > emaF11

colfastS = emaF1 < emaF2 and emaF2 < emaF3 and emaF3 < emaF4 and emaF4 < emaF5 and emaF5 < emaF6 and emaF6 < emaF7 and emaF7 < emaF8 and emaF8 < emaF9 and emaF9 < emaF10 and emaF10 < emaF11

colslowL = (

     emaS1 > emaS2 and emaS2 > emaS3 and emaS3 > emaS4 and emaS4 > emaS5 and emaS5 > emaS6 and emaS6 > emaS7 and emaS7 > emaS8 and

     emaS8 > emaS9 and emaS9 > emaS10 and emaS10 > emaS11 and emaS11 > emaS12 and emaS12 > emaS13 and emaS13 > emaS14 and emaS14 > emaS15 and emaS15 > emaS16

)

colslowS = (

     emaS1 < emaS2 and emaS2 < emaS3 and emaS3 < emaS4 and emaS4 < emaS5 and emaS5 < emaS6 and emaS6 < emaS7 and emaS7 < emaS8 and

     emaS8 < emaS9 and emaS9 < emaS10 and emaS10 < emaS11 and emaS11 < emaS12 and emaS12 < emaS13 and emaS13 < emaS14 and emaS14 < emaS15 and emaS15 < emaS16

)

colFinal  = colfastL and emaS1 > emaS16 ? color.aqua : colfastS and emaS1 < emaS16 ? color.blue : color.gray

colFinal2 = colslowL ? color.lime : colslowS ? color.red : color.gray

// Ribbon plots

// All 27 EMAs remain active in the calculations. Only representative lines

// are displayed to remain safely below TradingView's 64 plot-count limit.

pF1 = plot(emaF1, "Fast EMA 1", color=colFinal, linewidth=2)

plot(emaF3,  "Fast EMA 3",  color=colFinal)

plot(emaF5,  "Fast EMA 5",  color=colFinal)

plot(emaF7,  "Fast EMA 7",  color=colFinal)

plot(emaF9,  "Fast EMA 9",  color=colFinal)

pF11 = plot(emaF11, "Fast EMA 11", color=colFinal, linewidth=2)

plot(showAvgs ? emafast : na, "Fast Average", color=color.rgb(255, 215, 0), linewidth=2, style=plot.style_circles)

fill(pF1, pF11, color=color.new(color.silver, 95))

pS1 = plot(emaS1, "Slow EMA 1", color=colFinal2, linewidth=2)

plot(emaS3,  "Slow EMA 3",  color=colFinal2)

plot(emaS5,  "Slow EMA 5",  color=colFinal2)

plot(emaS7,  "Slow EMA 7",  color=colFinal2)

plot(emaS9,  "Slow EMA 9",  color=colFinal2)

plot(emaS11, "Slow EMA 11", color=colFinal2)

plot(emaS13, "Slow EMA 13", color=colFinal2)

pS16 = plot(emaS16, "Slow EMA 16", color=colFinal2, linewidth=2)

plot(showAvgs ? emaslow : na, "Slow Average", color=color.fuchsia, linewidth=2, style=plot.style_circles)

fill(pS1, pS16, color=color.new(color.silver, 95))

plot(show200 ? ema200 : na, "EMA 200", color=color.black, linewidth=2, style=plot.style_circles)

barTrendColor = colfastL and emaS1 > emaS16 ? color.aqua : colfastS and emaS1 < emaS16 ? color.blue : color.gray

barcolor(clrBars ? barTrendColor : na)

//══════════════════════════════════════════════════════════════════════════════

// 2. ORIGINAL GUPPY SIGNALS

//══════════════════════════════════════════════════════════════════════════════

var int buy = 0

var int sell = 0

var int buybreak = 0

var int sellbreak = 0

buyCondition = emafast > emaslow and emaS1 > emaS16 and not colslowS and colfastL and (not showCon or colslowL) and (not emaFilter or emafast > ema200)

sellCondition = emafast < emaslow and emaS1 < emaS16 and not colslowL and colfastS and (not showCon or colslowS) and (not emaFilter or emafast < ema200)

buy := buyCondition ? (nz(buy[1]) > 0 ? buy[1] + 1 : 1) : 0

sell := sellCondition ? (nz(sell[1]) > 0 ? sell[1] + 1 : 1) : 0

buy := buy > 1 and colfastL and useBarFlip and close[1] < open[1] and close > open ? 1 : buy

sell := sell > 1 and colfastS and useBarFlip and close[1] > open[1] and close < open ? 1 : sell

buyBreakCondition = emafast > emaslow and not colslowS and (not emaFilter or emafast > ema200)

sellBreakCondition = emafast < emaslow and not colslowL and (not emaFilter or emafast < ema200)

buybreak := buyBreakCondition ? (nz(buybreak[1]) > 0 ? buybreak[1] + 1 : 1) : 0

sellbreak := sellBreakCondition ? (nz(sellbreak[1]) > 0 ? sellbreak[1] + 1 : 1) : 0

buySwingSignal = showSwing and buy == 1 and ta.barssince(nz(buy[1], 1) == 1) > lookback

sellSwingSignal = showSwing and sell == 1 and ta.barssince(nz(sell[1], 1) == 1) > lookback

buyBreakSignal = showBreak and buybreak == 1 and ta.barssince(nz(sellbreak[1], 1) == 1) > lookback and ta.barssince(nz(buybreak[1], 1) == 1) > lookback

sellBreakSignal = showBreak and sellbreak == 1 and ta.barssince(nz(buybreak[1], 1) == 1) > lookback and ta.barssince(nz(sellbreak[1], 1) == 1) > lookback

plotshape(buySwingSignal, "BUY Swing", shape.arrowup, location.belowbar, color=color.lime, size=size.small)

plotshape(sellSwingSignal, "SELL Swing", shape.arrowdown, location.abovebar, color=color.red, size=size.small)

plotshape(buyBreakSignal, "BUY Break", shape.arrowup, location.belowbar, color=color.aqua, size=size.small)

plotshape(sellBreakSignal, "SELL Break", shape.arrowdown, location.abovebar, color=color.blue, size=size.small)

//══════════════════════════════════════════════════════════════════════════════

// 3. LIVE + CONFIRMED GUPPY STRUCTURE DIVERGENCES

//

// BEARISH:

// Price makes a higher high, but one or more Guppy strength measurements

// make a lower high / show weaker participation.

//

// BULLISH:

// Price makes a lower low, but one or more Guppy strength measurements

// make a higher low / show weaker downside participation.

//══════════════════════════════════════════════════════════════════════════════

groupDiv = "4. LIVE + Confirmed Guppy Divergences"

showLiveDiv      = input.bool(true, "Show LIVE Guppy Divergences", group=groupDiv)

keepFailedLiveDiv = input.bool(true, "Keep Failed LIVE Divergences Grey", group=groupDiv)

showConfirmedDiv = input.bool(true, "Show Confirmed Guppy Divergences", group=groupDiv)

showDivScore     = input.bool(true, "Show Score", group=groupDiv)

showTrendUpgrade = input.bool(true, "Upgrade When Guppy Bias Agrees", group=groupDiv)

pivotLeft  = input.int(2, "Confirmation Pivot Left", minval=1, group=groupDiv)

pivotRight = input.int(2, "Confirmation Pivot Right", minval=1, group=groupDiv)

liveExtremeLookback = input.int(12, "LIVE Extreme Lookback", minval=2, group=groupDiv)

minimumLiveScore    = input.int(2, "Minimum LIVE Score", minval=1, maxval=6, group=groupDiv)

minimumConfirmScore = input.int(2, "Minimum Confirmed Score", minval=1, maxval=6, group=groupDiv)

useFastAvgDiv   = input.bool(true, "Fast Average Divergence", group=groupDiv)

useSlowAvgDiv   = input.bool(true, "Slow Average Divergence", group=groupDiv)

useSpreadDiv    = input.bool(true, "Fast-vs-Slow Spread Divergence", group=groupDiv)

useRibbonDiv    = input.bool(true, "Ribbon Expansion Divergence", group=groupDiv)

useRejectionDiv = input.bool(true, "Stronger Wick/Rejection", group=groupDiv)

useTimeDiv      = input.bool(false, "New Extreme Takes Longer", group=groupDiv)

requireTrendContext = input.bool(false, "Require Prior Guppy Trend Context", group=groupDiv)

atr14 = ta.atr(14)

// Guppy strength measurements.

fastSlowSpread = emafast - emaslow

fastRibbonWidth = math.abs(emaF1 - emaF11)

slowRibbonWidth = math.abs(emaS1 - emaS16)

totalRibbonExpansion = fastRibbonWidth + slowRibbonWidth

// Positive values represent bullish alignment; negative values bearish.

fastAlignment =

     (emaF1 > emaF2 ? 1 : -1) + (emaF2 > emaF3 ? 1 : -1) + (emaF3 > emaF4 ? 1 : -1) +

     (emaF4 > emaF5 ? 1 : -1) + (emaF5 > emaF6 ? 1 : -1) + (emaF6 > emaF7 ? 1 : -1) +

     (emaF7 > emaF8 ? 1 : -1) + (emaF8 > emaF9 ? 1 : -1) + (emaF9 > emaF10 ? 1 : -1) +

     (emaF10 > emaF11 ? 1 : -1)

slowAlignment =

     (emaS1 > emaS2 ? 1 : -1) + (emaS2 > emaS3 ? 1 : -1) + (emaS3 > emaS4 ? 1 : -1) +

     (emaS4 > emaS5 ? 1 : -1) + (emaS5 > emaS6 ? 1 : -1) + (emaS6 > emaS7 ? 1 : -1) +

     (emaS7 > emaS8 ? 1 : -1) + (emaS8 > emaS9 ? 1 : -1) + (emaS9 > emaS10 ? 1 : -1) +

     (emaS10 > emaS11 ? 1 : -1) + (emaS11 > emaS12 ? 1 : -1) + (emaS12 > emaS13 ? 1 : -1) +

     (emaS13 > emaS14 ? 1 : -1) + (emaS14 > emaS15 ? 1 : -1) + (emaS15 > emaS16 ? 1 : -1)

totalAlignment = fastAlignment + slowAlignment

bullBias = emafast > emaslow and emaS1 > emaS16

bearBias = emafast < emaslow and emaS1 < emaS16

f_confidenceText(int score) =>

    score >= 6 ? "VERY HIGH" :

     score == 5 ? "HIGH" :

     score == 4 ? "GOOD" :

     score == 3 ? "MEDIUM" :

     score == 2 ? "LOW" : "VERY LOW"

f_checkLine(bool enabled, bool passed, string name, string passedText) =>

    not enabled ? "• " + name + ": disabled" :

     passed ? "✓ " + name + ": " + passedText :

     "✗ " + name + ": condition not met"

f_divTooltip(

     bool bullish,

     bool isLive,

     int score,

     bool fastPass,

     bool slowPass,

     bool spreadPass,

     bool ribbonPass,

     bool rejectionPass,

     bool timePass,

     bool trendAgrees

) =>

    string direction = bullish ? "BULLISH" : "BEARISH"

    string priceMove = bullish ? "Price made a lower low." : "Price made a higher high."

    string meaning = bullish

         ? "The Guppy structure weakened less than price. Downside participation is fading and an upside reversal may develop."

         : "The Guppy structure strengthened less than price. Upside participation is fading and a downside reversal may develop."

    string status = isLive

         ? "LIVE: based on the current developing extreme. It can move, disappear or change score."

         : "CONFIRMED: the price pivot is fixed after the selected right-bar delay."

    string biasText = trendAgrees

         ? "✓ Current Guppy bias agrees with the reversal direction."

         : "• Current Guppy bias has not yet flipped into agreement."

    direction + " GUPPY DIVERGENCE — " + (isLive ? "LIVE" : "CONFIRMED") + "\n\n" +

     priceMove + "\n" + meaning + "\n\n" +

     "Score: " + str.tostring(score) + "/6 — " + f_confidenceText(score) + "\n\n" +

     f_checkLine(useFastAvgDiv, fastPass, "Fast average", bullish ? "price made LL while fast average made HL" : "price made HH while fast average made LH") + "\n" +

     f_checkLine(useSlowAvgDiv, slowPass, "Slow average", bullish ? "price made LL while slow average made HL" : "price made HH while slow average made LH") + "\n" +

     f_checkLine(useSpreadDiv, spreadPass, "Fast/slow spread", bullish ? "bearish separation became less negative" : "bullish separation became smaller") + "\n" +

     f_checkLine(useRibbonDiv, ribbonPass, "Ribbon expansion", "the combined Guppy ribbon expanded less than at the prior pivot") + "\n" +

     f_checkLine(useRejectionDiv, rejectionPass, "Rejection", bullish ? "lower-wick recovery strengthened" : "upper-wick rejection strengthened") + "\n" +

     f_checkLine(useTimeDiv, timePass, "Time", "the new extreme took longer to form") + "\n\n" +

     biasText + "\n\n" + status

confirmedPivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

confirmedPivotLow  = ta.pivotlow(low, pivotLeft, pivotRight)

newConfirmedHigh = not na(confirmedPivotHigh)

newConfirmedLow  = not na(confirmedPivotLow)

// Previous confirmed high reference

var float refHighPrice = na

var float refHighFast = na

var float refHighSlow = na

var float refHighSpread = na

var float refHighExpansion = na

var float refHighReject = na

var int refHighAlignment = na

var int refHighBar = na

var int previousHighGap = na

// Previous confirmed low reference

var float refLowPrice = na

var float refLowFast = na

var float refLowSlow = na

var float refLowSpread = na

var float refLowExpansion = na

var float refLowReject = na

var int refLowAlignment = na

var int refLowBar = na

var int previousLowGap = na

var label liveBearLabel = na

var label liveBullLabel = na

var int liveBearExtremeBar = na

var int liveBullExtremeBar = na

//──────────────────────────────────────────────────────────────────────────────

// LIVE DEVELOPING EXTREMES

//──────────────────────────────────────────────────────────────────────────────

newLiveHighExtreme = high >= ta.highest(high, liveExtremeLookback)

newLiveLowExtreme  = low <= ta.lowest(low, liveExtremeLookback)

currentHighReject = atr14 > 0 ? (high - close) / atr14 : na

currentLowReject  = atr14 > 0 ? (close - low) / atr14 : na

livePriceHH = not na(refHighPrice) and high > refHighPrice

liveBearFast = livePriceHH and emafast < refHighFast

liveBearSlow = livePriceHH and emaslow < refHighSlow

liveBearSpread = livePriceHH and fastSlowSpread < refHighSpread

liveBearRibbon = livePriceHH and (totalRibbonExpansion < refHighExpansion or totalAlignment < refHighAlignment)

liveBearRejection = livePriceHH and currentHighReject > refHighReject

liveHighGap = not na(refHighBar) ? bar_index - refHighBar : na

liveBearTime = livePriceHH and not na(liveHighGap) and not na(previousHighGap) and liveHighGap > previousHighGap

liveBearScore =

     (useFastAvgDiv and liveBearFast ? 1 : 0) +

     (useSlowAvgDiv and liveBearSlow ? 1 : 0) +

     (useSpreadDiv and liveBearSpread ? 1 : 0) +

     (useRibbonDiv and liveBearRibbon ? 1 : 0) +

     (useRejectionDiv and liveBearRejection ? 1 : 0) +

     (useTimeDiv and liveBearTime ? 1 : 0)

livePriceLL = not na(refLowPrice) and low < refLowPrice

liveBullFast = livePriceLL and emafast > refLowFast

liveBullSlow = livePriceLL and emaslow > refLowSlow

liveBullSpread = livePriceLL and fastSlowSpread > refLowSpread

liveBullRibbon = livePriceLL and (totalRibbonExpansion < refLowExpansion or totalAlignment > refLowAlignment)

liveBullRejection = livePriceLL and currentLowReject > refLowReject

liveLowGap = not na(refLowBar) ? bar_index - refLowBar : na

liveBullTime = livePriceLL and not na(liveLowGap) and not na(previousLowGap) and liveLowGap > previousLowGap

liveBullScore =

     (useFastAvgDiv and liveBullFast ? 1 : 0) +

     (useSlowAvgDiv and liveBullSlow ? 1 : 0) +

     (useSpreadDiv and liveBullSpread ? 1 : 0) +

     (useRibbonDiv and liveBullRibbon ? 1 : 0) +

     (useRejectionDiv and liveBullRejection ? 1 : 0) +

     (useTimeDiv and liveBullTime ? 1 : 0)

bearContextOK = not requireTrendContext or refHighSpread > 0

bullContextOK = not requireTrendContext or refLowSpread < 0

liveBearSignal = showLiveDiv and newLiveHighExtreme and bearContextOK and liveBearScore >= minimumLiveScore

liveBullSignal = showLiveDiv and newLiveLowExtreme and bullContextOK and liveBullScore >= minimumLiveScore

if newLiveHighExtreme and not liveBearSignal and not na(liveBearLabel)

    if keepFailedLiveDiv

        label.set_color(liveBearLabel, color.gray)

        label.set_textcolor(liveBearLabel, color.white)

        label.set_text(liveBearLabel, "FAILED LIVE DIV")

        label.set_tooltip(liveBearLabel, "FAILED LIVE BEARISH GUPPY DIVERGENCE\n\nThis LIVE divergence appeared while the extreme was developing, but later stopped meeting the LIVE divergence conditions. It is retained in grey for historical failure analysis.")

    else

        label.delete(liveBearLabel)

    liveBearLabel := na

    liveBearExtremeBar := na

if newLiveLowExtreme and not liveBullSignal and not na(liveBullLabel)

    if keepFailedLiveDiv

        label.set_color(liveBullLabel, color.gray)

        label.set_textcolor(liveBullLabel, color.white)

        label.set_text(liveBullLabel, "FAILED LIVE DIV")

        label.set_tooltip(liveBullLabel, "FAILED LIVE BULLISH GUPPY DIVERGENCE\n\nThis LIVE divergence appeared while the extreme was developing, but later stopped meeting the LIVE divergence conditions. It is retained in grey for historical failure analysis.")

    else

        label.delete(liveBullLabel)

    liveBullLabel := na

    liveBullExtremeBar := na

if liveBearSignal

    bearText = showDivScore ? "LIVE GUPPY DIV " + str.tostring(liveBearScore) + "/6" : "LIVE GUPPY DIV"

    bearColor = bearBias and showTrendUpgrade ? color.maroon : color.orange

    bearTip = f_divTooltip(false, true, liveBearScore, liveBearFast, liveBearSlow, liveBearSpread, liveBearRibbon, liveBearRejection, liveBearTime, bearBias)

    if na(liveBearLabel)

        liveBearLabel := label.new(bar_index, high, bearText, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=bearColor, textcolor=color.white, size=size.tiny, tooltip=bearTip)

    else

        label.set_xy(liveBearLabel, bar_index, high)

        label.set_text(liveBearLabel, bearText)

        label.set_color(liveBearLabel, bearColor)

        label.set_tooltip(liveBearLabel, bearTip)

    liveBearExtremeBar := bar_index

if liveBullSignal

    bullText = showDivScore ? "LIVE GUPPY DIV " + str.tostring(liveBullScore) + "/6" : "LIVE GUPPY DIV"

    bullColor = bullBias and showTrendUpgrade ? color.green : color.aqua

    bullTip = f_divTooltip(true, true, liveBullScore, liveBullFast, liveBullSlow, liveBullSpread, liveBullRibbon, liveBullRejection, liveBullTime, bullBias)

    if na(liveBullLabel)

        liveBullLabel := label.new(bar_index, low, bullText, xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=bullColor, textcolor=color.white, size=size.tiny, tooltip=bullTip)

    else

        label.set_xy(liveBullLabel, bar_index, low)

        label.set_text(liveBullLabel, bullText)

        label.set_color(liveBullLabel, bullColor)

        label.set_tooltip(liveBullLabel, bullTip)

    liveBullExtremeBar := bar_index

//──────────────────────────────────────────────────────────────────────────────

// CONFIRMED DIVERGENCES

//──────────────────────────────────────────────────────────────────────────────

bool confirmedBearSignal = false

bool confirmedBullSignal = false

int confirmedBearScore = 0

int confirmedBullScore = 0

if newConfirmedHigh

    pivotBar = bar_index - pivotRight

    pivotPrice = high[pivotRight]

    pivotFast = emafast[pivotRight]

    pivotSlow = emaslow[pivotRight]

    pivotSpread = fastSlowSpread[pivotRight]

    pivotExpansion = totalRibbonExpansion[pivotRight]

    pivotAlignment = totalAlignment[pivotRight]

    pivotATR = atr14[pivotRight]

    pivotReject = pivotATR > 0 ? (high[pivotRight] - close[pivotRight]) / pivotATR : na

    priceHH = not na(refHighPrice) and pivotPrice > refHighPrice

    confirmedFast = priceHH and pivotFast < refHighFast

    confirmedSlow = priceHH and pivotSlow < refHighSlow

    confirmedSpread = priceHH and pivotSpread < refHighSpread

    confirmedRibbon = priceHH and (pivotExpansion < refHighExpansion or pivotAlignment < refHighAlignment)

    confirmedRejection = priceHH and pivotReject > refHighReject

    currentGap = not na(refHighBar) ? pivotBar - refHighBar : na

    confirmedTime = priceHH and not na(currentGap) and not na(previousHighGap) and currentGap > previousHighGap

    confirmedBearScore :=

         (useFastAvgDiv and confirmedFast ? 1 : 0) +

         (useSlowAvgDiv and confirmedSlow ? 1 : 0) +

         (useSpreadDiv and confirmedSpread ? 1 : 0) +

         (useRibbonDiv and confirmedRibbon ? 1 : 0) +

         (useRejectionDiv and confirmedRejection ? 1 : 0) +

         (useTimeDiv and confirmedTime ? 1 : 0)

    confirmedBearSignal := showConfirmedDiv and priceHH and bearContextOK and confirmedBearScore >= minimumConfirmScore

    if confirmedBearSignal

        trendAgrees = bearBias[pivotRight]

        confirmedText = showDivScore ? (trendAgrees and showTrendUpgrade ? "GUPPY DIV ✓ " : "GUPPY DIV ") + str.tostring(confirmedBearScore) + "/6" : (trendAgrees and showTrendUpgrade ? "GUPPY DIV ✓" : "GUPPY DIV")

        confirmedColor = trendAgrees and showTrendUpgrade ? color.maroon : color.red

        confirmedTip = f_divTooltip(false, false, confirmedBearScore, confirmedFast, confirmedSlow, confirmedSpread, confirmedRibbon, confirmedRejection, confirmedTime, trendAgrees)

        upgradedExisting = not na(liveBearLabel) and not na(liveBearExtremeBar) and liveBearExtremeBar == pivotBar

        if upgradedExisting

            label.set_xy(liveBearLabel, pivotBar, pivotPrice)

            label.set_text(liveBearLabel, confirmedText)

            label.set_color(liveBearLabel, confirmedColor)

            label.set_size(liveBearLabel, size.small)

            label.set_tooltip(liveBearLabel, confirmedTip)

            liveBearLabel := na

            liveBearExtremeBar := na

        else

            label.new(pivotBar, pivotPrice, confirmedText, xloc=xloc.bar_index, yloc=yloc.abovebar, style=label.style_label_down, color=confirmedColor, textcolor=color.white, size=size.small, tooltip=confirmedTip)

    previousHighGap := currentGap

    refHighPrice := pivotPrice

    refHighFast := pivotFast

    refHighSlow := pivotSlow

    refHighSpread := pivotSpread

    refHighExpansion := pivotExpansion

    refHighReject := pivotReject

    refHighAlignment := pivotAlignment

    refHighBar := pivotBar

if newConfirmedLow

    pivotBar = bar_index - pivotRight

    pivotPrice = low[pivotRight]

    pivotFast = emafast[pivotRight]

    pivotSlow = emaslow[pivotRight]

    pivotSpread = fastSlowSpread[pivotRight]

    pivotExpansion = totalRibbonExpansion[pivotRight]

    pivotAlignment = totalAlignment[pivotRight]

    pivotATR = atr14[pivotRight]

    pivotReject = pivotATR > 0 ? (close[pivotRight] - low[pivotRight]) / pivotATR : na

    priceLL = not na(refLowPrice) and pivotPrice < refLowPrice

    confirmedFast = priceLL and pivotFast > refLowFast

    confirmedSlow = priceLL and pivotSlow > refLowSlow

    confirmedSpread = priceLL and pivotSpread > refLowSpread

    confirmedRibbon = priceLL and (pivotExpansion < refLowExpansion or pivotAlignment > refLowAlignment)

    confirmedRejection = priceLL and pivotReject > refLowReject

    currentGap = not na(refLowBar) ? pivotBar - refLowBar : na

    confirmedTime = priceLL and not na(currentGap) and not na(previousLowGap) and currentGap > previousLowGap

    confirmedBullScore :=

         (useFastAvgDiv and confirmedFast ? 1 : 0) +

         (useSlowAvgDiv and confirmedSlow ? 1 : 0) +

         (useSpreadDiv and confirmedSpread ? 1 : 0) +

         (useRibbonDiv and confirmedRibbon ? 1 : 0) +

         (useRejectionDiv and confirmedRejection ? 1 : 0) +

         (useTimeDiv and confirmedTime ? 1 : 0)

    confirmedBullSignal := showConfirmedDiv and priceLL and bullContextOK and confirmedBullScore >= minimumConfirmScore

    if confirmedBullSignal

        trendAgrees = bullBias[pivotRight]

        confirmedText = showDivScore ? (trendAgrees and showTrendUpgrade ? "GUPPY DIV ✓ " : "GUPPY DIV ") + str.tostring(confirmedBullScore) + "/6" : (trendAgrees and showTrendUpgrade ? "GUPPY DIV ✓" : "GUPPY DIV")

        confirmedColor = trendAgrees and showTrendUpgrade ? color.green : color.lime

        confirmedTip = f_divTooltip(true, false, confirmedBullScore, confirmedFast, confirmedSlow, confirmedSpread, confirmedRibbon, confirmedRejection, confirmedTime, trendAgrees)

        upgradedExisting = not na(liveBullLabel) and not na(liveBullExtremeBar) and liveBullExtremeBar == pivotBar

        if upgradedExisting

            label.set_xy(liveBullLabel, pivotBar, pivotPrice)

            label.set_text(liveBullLabel, confirmedText)

            label.set_color(liveBullLabel, confirmedColor)

            label.set_size(liveBullLabel, size.small)

            label.set_tooltip(liveBullLabel, confirmedTip)

            liveBullLabel := na

            liveBullExtremeBar := na

        else

            label.new(pivotBar, pivotPrice, confirmedText, xloc=xloc.bar_index, yloc=yloc.belowbar, style=label.style_label_up, color=confirmedColor, textcolor=color.white, size=size.small, tooltip=confirmedTip)

    previousLowGap := currentGap

    refLowPrice := pivotPrice

    refLowFast := pivotFast

    refLowSlow := pivotSlow

    refLowSpread := pivotSpread

    refLowExpansion := pivotExpansion

    refLowReject := pivotReject

    refLowAlignment := pivotAlignment

    refLowBar := pivotBar

//══════════════════════════════════════════════════════════════════════════════

// 4. ALERTS

//══════════════════════════════════════════════════════════════════════════════

guppyAlert = buySwingSignal or sellSwingSignal or buyBreakSignal or sellBreakSignal

alertcondition(guppyAlert, "Guppy Alert Arrow", "Guppy Alert")

alertcondition(buySwingSignal or buyBreakSignal, "Buy Arrow", "BUY")

alertcondition(sellSwingSignal or sellBreakSignal, "Sell Arrow", "SELL")

alertcondition(liveBullSignal, "LIVE Bullish Guppy Divergence", "LIVE bullish Guppy divergence on {{ticker}} {{interval}}. This signal can repaint until confirmed.")

alertcondition(liveBearSignal, "LIVE Bearish Guppy Divergence", "LIVE bearish Guppy divergence on {{ticker}} {{interval}}. This signal can repaint until confirmed.")

alertcondition(confirmedBullSignal, "Confirmed Bullish Guppy Divergence", "Confirmed bullish Guppy divergence on {{ticker}} {{interval}}.")

alertcondition(confirmedBearSignal, "Confirmed Bearish Guppy Divergence", "Confirmed bearish Guppy divergence on {{ticker}} {{interval}}.")
````
