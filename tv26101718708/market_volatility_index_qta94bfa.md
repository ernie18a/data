# Market Volatility Index

- url: https://www.tradingview.com/script/qta94bfa-Market-Volatility-Index/
- type: indicator
- pine_id: PUB;9fc030616bab48a4a7d0cf05726505d5
- version: 1.0

## Description

Market Regime: Pivot Density + Efficiency + ATR Compression

A market regime detection tool designed to help identify whether price is currently behaving more like a trending market, ranging market, or transitioning environment.

Rather than relying on a single metric, this indicator combines three independent market behavior measurements into a weighted composite score:

• Pivot Density
• Price Efficiency Ratio
• ATR Compression/Expansion

The goal is to provide context before entering trades so you can better align strategy selection with current market conditions.

How It Works
Pivot Density

Measures how frequently pivot highs and lows occur over a lookback period.

High pivot density:

• More frequent reversals
• More indecision
• More likely ranging/choppy behavior

Low pivot density:

• Cleaner directional movement
• Stronger trends

Efficiency Ratio

Measures:

Net Movement ÷ Total Movement

High efficiency:

• Directional price movement
• Stronger trend behavior

Low efficiency:

• Back-and-forth movement
• Less directional conviction

ATR Compression / Expansion

Measures current volatility relative to historical volatility.

ATR compressed:

• Volatility contraction
• Common during ranges or consolidation

ATR expanded:

• Increasing volatility
• Common during stronger directional movement

Composite Regime Score

The three components are combined into a weighted score:

0 → Strong Trend Environment
1 → Strong Range Environment

Default interpretation:

🟢 Trend Zone
Range Score ≤ Trend Threshold

🟡 Transition Zone
Between thresholds

🔴 Range Zone
Range Score ≥ Range Threshold

Background Colors

Green Background

• Trending conditions
• Lower pivot density
• Higher efficiency
• Expanding volatility

Yellow Background

• Mixed or transitional conditions

Red Background

• Choppy/ranging conditions
• Higher pivot density
• Lower efficiency
• Volatility compression

Inputs
Timeframe

Calculation Timeframe
Allows calculations from an alternate timeframe while remaining on the current chart.

Wait Until Bar Close
Uses confirmed higher timeframe values to reduce intrabar fluctuations and maintain consistency.

Pivot Density

Pivot Length
Controls pivot sensitivity.

Lower values:

• More pivots
• Faster response

Higher values:

• Fewer pivots
• Smoother behavior

Pivot Lookback
Number of bars used for pivot density calculations.

Efficiency

Efficiency Length

Controls how far back directional efficiency is measured.

Lower values:

• Faster reactions

Higher values:

• More smoothing

ATR Compression

ATR Length

Length used for current volatility calculations.

ATR Baseline Length

Historical volatility average used for comparison.

Weighting

Adjust contribution of:

• Pivot Density
• Efficiency
• ATR Compression

Increasing a weight causes that component to have greater influence on the final regime score.

Potential Uses

✓ Trend-following strategy filter
✓ Mean reversion strategy filter
✓ Avoiding choppy conditions
✓ Volatility regime detection
✓ Multi-timeframe market context
✓ Strategy optimization

Notes

This indicator is intended as an environment and context tool rather than a direct buy or sell signal generator.

Market regimes constantly evolve, and understanding whether conditions favor trend continuation or mean reversion can help improve decision-making.

Best used alongside:

• Market structure
• Trend tools
• Volume analysis
• Entry and risk management systems

About TrendGenY Indicators
[i]
TrendGenY indicators are built from market experience, creative concepts, and a constant pursuit of unique perspectives. Rather than following conventional ideas, the focus is on uncovering alternative insights and viewing market behavior through different angles to reveal information that traditional tools may overlook and help traders build a more meaningful edge in the market.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TrendGenY

//@version=5
indicator("Market Regime: Pivot Density + Efficiency + ATR Compression", overlay=false, precision=3)

//====================
// Inputs
//====================
grp0 = "Timeframe"
calcTF    = input.timeframe("", "Calculation Timeframe (blank = chart TF)", group=grp0)
waitClose = input.bool(true, "Wait Until Bar Close", group=grp0)

grp1 = "Pivot Density"
pLen      = input.int(3,  "Pivot Length (L/R)", minval=1, group=grp1)
pLookback = input.int(150,"Pivot Count Lookback (bars)", minval=20, group=grp1)

grp2 = "Efficiency"
erLen     = input.int(50, "Efficiency Length", minval=5, group=grp2)

grp3 = "ATR Compression"
atrLen    = input.int(14, "ATR Length", minval=1, group=grp3)
atrBase   = input.int(50, "ATR Baseline Length (SMA)", minval=5, group=grp3)

grp4 = "Scoring / Thresholds"
wPivot    = input.float(1.0, "Weight: Pivot Density", step=0.1, group=grp4)
wEff      = input.float(1.0, "Weight: (1 - Efficiency)", step=0.1, group=grp4)
wATR      = input.float(1.0, "Weight: ATR Compression", step=0.1, group=grp4)

rangeThr  = input.float(0.65, "Range Threshold (>=)", step=0.01, group=grp4)
trendThr  = input.float(0.35, "Trend Threshold (<=)", step=0.01, group=grp4)

grp5 = "Visuals"
bgOn      = input.bool(true, "Color Background", group=grp5)
bgTrend   = input.color(color.new(color.green, 85), "BG Trend Color", group=grp5)
bgRange   = input.color(color.new(color.red,   85), "BG Range Color", group=grp5)
bgMid     = input.color(color.new(color.yellow,85), "BG Transition Color", group=grp5)

showScore = input.bool(true, "Plot Regime Score", group=grp5)
showPD    = input.bool(false,"Plot Pivot Density", group=grp5)
showER    = input.bool(false,"Plot Efficiency", group=grp5)
showATRr  = input.bool(false,"Plot ATR Ratio", group=grp5)

//====================
// TF selection + series (with wait for close)
//====================
tfUsed   = calcTF == "" ? timeframe.period : calcTF
tfCloseC = request.security(syminfo.tickerid, tfUsed, barstate.isconfirmed, barmerge.gaps_off, barmerge.lookahead_off)

tfHighR  = request.security(syminfo.tickerid, tfUsed, high,  barmerge.gaps_off, barmerge.lookahead_off)
tfLowR   = request.security(syminfo.tickerid, tfUsed, low,   barmerge.gaps_off, barmerge.lookahead_off)
tfCloseR = request.security(syminfo.tickerid, tfUsed, close, barmerge.gaps_off, barmerge.lookahead_off)

// Hold last confirmed TF values until TF bar closes (if enabled)
var float tfHigh  = na
var float tfLow   = na
var float tfClose = na

if waitClose
    tfHigh  := tfCloseC ? tfHighR  : nz(tfHigh[1],  tfHighR)
    tfLow   := tfCloseC ? tfLowR   : nz(tfLow[1],   tfLowR)
    tfClose := tfCloseC ? tfCloseR : nz(tfClose[1], tfCloseR)
else
    tfHigh  := tfHighR
    tfLow   := tfLowR
    tfClose := tfCloseR

//====================
// 1) Pivot Density (on TF series)
//====================
// Confirmed pivots (appear pLen bars after the pivot point)
ph = ta.pivothigh(tfHigh, pLen, pLen)
pl = ta.pivotlow(tfLow,  pLen, pLen)

pivotEvent   = (not na(ph)) or (not na(pl))   // true on the confirmation bar
pivotCount   = math.sum(pivotEvent ? 1.0 : 0.0, pLookback)
pivotDensity = pivotCount / pLookback         // 0..1-ish (usually small)

// Normalize density to a smoother 0..1 scale using a rolling max
pdMax  = ta.highest(pivotDensity, pLookback)
pdNorm = pdMax > 0 ? pivotDensity / pdMax : 0.0
pdNorm := math.min(math.max(pdNorm, 0.0), 1.0)

//====================
// 2) Efficiency (net move / total move) (on TF close)
//====================
netMove   = math.abs(tfClose - tfClose[erLen])
totalMove = math.sum(math.abs(tfClose - tfClose[1]), erLen)
eff       = totalMove == 0 ? 0.0 : netMove / totalMove          // 0..1 (higher = trendier)

// We want "ranginess", so use (1 - efficiency)
effInv = 1.0 - eff
effInv := math.min(math.max(effInv, 0.0), 1.0)

//====================
// 3) ATR Compression (ATR / ATR-SMA) (on TF series)
//====================
// True Range + ATR computed on TF high/low/close series
tr = math.max(tfHigh - tfLow, math.max(math.abs(tfHigh - tfClose[1]), math.abs(tfLow - tfClose[1])))
atr = ta.rma(tr, atrLen)

atrSma   = ta.sma(atr, atrBase)
atrRatio = atrSma == 0 ? 1.0 : atr / atrSma                      // <1 = compressed, >1 = expanded

// Convert to "ranginess": compressed => higher score
// atrRatio 0.6 -> very compressed (near 1), 1.4 -> expanded (near 0)
atrClamped = math.min(math.max(atrRatio, 0.6), 1.4)
atrInv     = 1.0 - (atrClamped - 0.6) / (1.4 - 0.6)              // 0..1, higher = more compressed

//====================
// Combined Regime Score
// Higher = range/chop, Lower = trend
//====================
wSum = math.max(wPivot + wEff + wATR, 0.0001)
rangeScore = (wPivot * pdNorm + wEff * effInv + wATR * atrInv) / wSum
rangeScore := math.min(math.max(rangeScore, 0.0), 1.0)

isRange = rangeScore >= rangeThr
isTrend = rangeScore <= trendThr
isMid   = not isRange and not isTrend

//====================
// Background coloring
//====================
bgcolor(bgOn ? (isTrend ? bgTrend : isRange ? bgRange : bgMid) : na)

//====================
// Plots
//====================
plot(showScore ? rangeScore : na, "Range Score (0 trend → 1 range)", linewidth=2)
hline(rangeThr, "Range Thr", linestyle=hline.style_dotted)
hline(trendThr, "Trend Thr", linestyle=hline.style_dotted)

plot(showPD   ? pdNorm   : na, "Pivot Density (norm)", linewidth=1)
plot(showER   ? eff      : na, "Efficiency (0..1)", linewidth=1)
plot(showATRr ? atrRatio : na, "ATR Ratio (ATR/ATR-SMA)", linewidth=1)

//====================
// Alerts (optional)
//====================
alertcondition(isRange, "Regime = Range", "Market Regime: RANGE (high pivot density / low efficiency / ATR compressed).")
alertcondition(isTrend, "Regime = Trend", "Market Regime: TREND (low pivot density / high efficiency / ATR expanding).")
````
