# CVD Divergence Lite

- url: https://www.tradingview.com/script/VjEslI6c-CVD-Divergence-Lite/
- type: indicator
- pine_id: PUB;0952710053a84a77b62a68c80382350d
- version: 1.0

## Description

[b]CVD Divergence Lite:[/b]

Cumulative Volume Delta with regular bullish/bearish divergence detection.


Green bars = accumulation. Red bars = distribution. 
B/S labels mark divergence signals where CVD disagrees with price — the classic smart-money footprint.

🟢 B = Price making lower low, CVD making higher low (bullish divergence — buyers accumulating)
🔴 S = Price making higher high, CVD making lower high (bearish divergence — distribution at highs)



This is the Lite version. The Pro version adds:

• Hidden divergence (bullish + bearish) — continuation signals
• 3 CVD calculation methods (Direction, Volume-Weighted, Close Location)
• Phone push alerts via TradingView — 4 alert types + combined
• Adjustable sensitivity, pivot bars, and cooldown
• Full color customization

→ Pro version is Invite-only
→ Read the review of the Pro version at https://theindicatorlab.com/reviews/cvd-divergence-alerts-pro/





## Category
Volume / Divergence

## Compatible Markets
Stocks, Crypto, Forex, Futures, Indices

## Compatible Timeframes
All (optimized for 15m–4h)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © glycdigital

//@version=6
// ═══════════════════════════════════════════════════
// CVD Divergence Lite v1.0 — FREE
// Built by The Indicator Lab
// ═══════════════════════════════════════════════════
//
// Detects regular bullish/bearish divergences between
// Cumulative Volume Delta and price. Lite version —
// no alerts, no hidden divergence, no customization.
//
// ╔══════════════════════════════════════════════════╗
// ║  GET THE PRO VERSION:                            ║
// ║  theindicatorlab.com/lab-originals               ║
// ║                                                  ║
// ║  • 3 CVD calculation methods                     ║
// ║  • Hidden divergence detection                   ║
// ║  • Phone push alerts via TradingView             ║
// ║  • Adjustable sensitivity & cooldown             ║
// ║  • Full customization                            ║
// ║  • $25 one-time • Lifetime access                ║
// ╚══════════════════════════════════════════════════╝
//
// How to use:
// 1. Add to chart (separate pane or overlay)
// 2. Green bars = accumulation, Red bars = distribution
// 3. B = Bullish divergence (price ↓, CVD ↑ → reversal signal)
// 4. S = Bearish divergence (price ↑, CVD ↓ → distribution warning)

indicator("CVD Divergence Lite", "CVD Lite", false, format.volume, max_bars_back=500)

// ═══════════════════════════════════════════════════
// CONSTANTS (fixed — upgrade to Pro for customization)
// ═══════════════════════════════════════════════════

// CVD: Direction method — bar close direction determines delta
// (Pro: 3 methods — Direction, Volume-Weighted, Close Location)

// Divergence detection: 2-bar pivot window, 10 pivots tracked
// (Pro: adjustable pivot bars, sensitivity, cooldown)

// ═══════════════════════════════════════════════════
// CVD CALCULATION
// ═══════════════════════════════════════════════════

float delta = close >= open ? volume : -volume

var float cvd = 0.0
cvd += delta

// ═══════════════════════════════════════════════════
// PIVOT DETECTION
// ═══════════════════════════════════════════════════

int pvLeft  = 2
int pvRight = 2
int pvMax   = 10

float ph   = ta.pivothigh(high, pvLeft, pvRight)
float pl   = ta.pivotlow(low, pvLeft, pvRight)
float cvdH = ta.pivothigh(cvd, pvLeft, pvRight)
float cvdL = ta.pivotlow(cvd, pvLeft, pvRight)

// Rolling arrays for pivot history
var float[]  priceHiVals = array.new_float(pvMax, 0)
var int[]    priceHiBars = array.new_int(pvMax, 0)
var float[]  priceLoVals = array.new_float(pvMax, 0)
var int[]    priceLoBars = array.new_int(pvMax, 0)
var float[]  cvdHiVals   = array.new_float(pvMax, 0)
var int[]    cvdHiBars   = array.new_int(pvMax, 0)
var float[]  cvdLoVals   = array.new_float(pvMax, 0)
var int[]    cvdLoBars   = array.new_int(pvMax, 0)

var int priceHiCount = 0
var int priceLoCount = 0
var int cvdHiCount   = 0
var int cvdLoCount   = 0

if not na(ph)
    array.push(priceHiVals, ph)
    array.push(priceHiBars, bar_index)
    array.shift(priceHiVals)
    array.shift(priceHiBars)
    priceHiCount := math.min(priceHiCount + 1, pvMax)

if not na(pl)
    array.push(priceLoVals, pl)
    array.push(priceLoBars, bar_index)
    array.shift(priceLoVals)
    array.shift(priceLoBars)
    priceLoCount := math.min(priceLoCount + 1, pvMax)

if not na(cvdH)
    array.push(cvdHiVals, cvdH)
    array.push(cvdHiBars, bar_index)
    array.shift(cvdHiVals)
    array.shift(cvdHiBars)
    cvdHiCount := math.min(cvdHiCount + 1, pvMax)

if not na(cvdL)
    array.push(cvdLoVals, cvdL)
    array.push(cvdLoBars, bar_index)
    array.shift(cvdLoVals)
    array.shift(cvdLoBars)
    cvdLoCount := math.min(cvdLoCount + 1, pvMax)

// ═══════════════════════════════════════════════════
// DIVERGENCE DETECTION — Regular only
// (Pro: adds Hidden Bullish & Hidden Bearish divergence)
// ═══════════════════════════════════════════════════

int minAligned = 5
int minDist    = 3
float minStr   = 0.5

bool isBullReg = false
bool isBearReg = false

// ── Regular Bullish: Price LL + CVD HL ──
if priceLoCount >= 2 and cvdLoCount >= 2 and barstate.isconfirmed
    float  p1 = array.get(priceLoVals, pvMax - 2)
    float  p2 = array.get(priceLoVals, pvMax - 1)
    float  c1 = array.get(cvdLoVals, pvMax - 2)
    float  c2 = array.get(cvdLoVals, pvMax - 1)
    int    pb1 = array.get(priceLoBars, pvMax - 2)
    int    pb2 = array.get(priceLoBars, pvMax - 1)
    int    cb1 = array.get(cvdLoBars, pvMax - 2)
    int    cb2 = array.get(cvdLoBars, pvMax - 1)

    if p2 < p1 and c2 > c1 and pb1 != 0 and cb1 != 0
        if math.abs(pb2 - cb2) <= minAligned and (pb2 - pb1) >= minDist and (cb2 - cb1) >= minDist
            float dPrice = 100 * (p1 - p2) / math.max(p1, 0.0001)
            float dCVD   = 100 * (c2 - c1) / math.max(math.abs(c1), 0.0001)
            if dPrice + dCVD >= minStr
                isBullReg := true

// ── Regular Bearish: Price HH + CVD LH ──
if priceHiCount >= 2 and cvdHiCount >= 2 and barstate.isconfirmed
    float  p1 = array.get(priceHiVals, pvMax - 2)
    float  p2 = array.get(priceHiVals, pvMax - 1)
    float  c1 = array.get(cvdHiVals, pvMax - 2)
    float  c2 = array.get(cvdHiVals, pvMax - 1)
    int    pb1 = array.get(priceHiBars, pvMax - 2)
    int    pb2 = array.get(priceHiBars, pvMax - 1)
    int    cb1 = array.get(cvdHiBars, pvMax - 2)
    int    cb2 = array.get(cvdHiBars, pvMax - 1)

    if p2 > p1 and c2 < c1 and pb1 != 0 and cb1 != 0
        if math.abs(pb2 - cb2) <= minAligned and (pb2 - pb1) >= minDist and (cb2 - cb1) >= minDist
            float dPrice = 100 * (p2 - p1) / math.max(p1, 0.0001)
            float dCVD   = 100 * (c1 - c2) / math.max(math.abs(c1), 0.0001)
            if dPrice + dCVD >= minStr
                isBearReg := true

// ═══════════════════════════════════════════════════
// PLOTTING
// ═══════════════════════════════════════════════════

color cvdCol = delta >= 0 ? #00bcd4 : #e91e63
plot(cvd, "CVD", color=cvdCol, style=plot.style_columns, linewidth=2)
plot(cvd, "CVD Line", color=color.new(#ffffff, 50), linewidth=1)
hline(0, "Zero", color.new(color.gray, 50), hline.style_dotted)

// Divergence Markers
int bullSig = isBullReg ? 1 : 0
plotshape(bullSig, "Bull Div", style=shape.triangleup, location=location.belowbar,
     color=color.new(#00e676, 80), text="B", textcolor=color.white, size=size.small)

int bearSig = isBearReg ? 1 : 0
plotshape(bearSig, "Bear Div", style=shape.triangledown, location=location.abovebar,
     color=color.new(#ff1744, 80), text="S", textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════
// ║  theindicatorlab.com/lab-originals
// ║  Upgrade for hidden divergence + push alerts
// ═══════════════════════════════════════════════════
````
