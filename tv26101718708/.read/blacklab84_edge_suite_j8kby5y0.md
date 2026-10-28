# Blacklab84 EDGE Suite

- url: https://www.tradingview.com/script/J8kBy5y0-Blacklab84-EDGE-Suite/
- type: indicator
- pine_id: PUB;1a5c04ca72044fb3ba9c730c36ae5d57
- version: 1.0

## Description

Clean trading suite

E D G E  —  A Clean Trading Suite                          
                                                              
  Philosophy: Every element earns its place.                  
  No noise. Clear states. Institutional logic.                
                                                             
 OVERLAY COMPONENTS:                                         
 • Candle States  — 4-tier color system (strength + trend)   
 • MA        — Fast, low-lag trend backbone             
 • VWAP Band      — Anchored value area (daily reset)        
• RSI Divergence — Bullish/bearish divergence markers       

• Signals        — Entry dots (trend + divergence confluence)

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════╗
// ║  E D G E  —  A Clean Trading Suite                          ║
// ║                                                              ║
// ║  Philosophy: Every element earns its place.                  ║
// ║  No noise. Clear states. Institutional logic.                ║
// ║                                                              ║
// ║  OVERLAY COMPONENTS:                                         ║
// ║  • Candle States  — 4-tier color system (strength + trend)   ║
// ║  • Hull MA        — Fast, low-lag trend backbone             ║
// ║  • VWAP Band      — Anchored value area (daily reset)        ║
// ║  • RSI Divergence — Bullish/bearish divergence markers       ║

// ║  • Signals        — Entry dots (trend + divergence confluence)║
// ╚══════════════════════════════════════════════════════════════╝
indicator("Blacklab84 EDGE Suite", shorttitle="EDGE", overlay=true, max_labels_count=300, max_lines_count=200)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PALETTE  — layered visual hierarchy, no color fighting
//   Candles  = teal / red     (primary — loudest)
//   Hull MA  = white          (neutral backbone)
//   VWAP     = soft blue/indigo fill (zone layer)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle tiers — teal/red, these are the loudest elements
COL_BULL_STRONG  = color.new(#00ff5a, 0)   // electric green — strong bull (vibrant)
COL_BULL_WEAK    = color.new(#00e5d0, 0)   // bright teal/aqua — weak bull (more vibrant)
COL_BEAR_STRONG  = color.new(#ff1744, 0)   // bright red — strong bear
COL_BEAR_WEAK    = color.new(#ff9800, 0)   // bright orange — weak bear (more vibrant)
COL_DOJI         = color.new(#8899aa, 0)   // grey — indecision

// Hull MA — clean white/grey, reads as neutral trend backbone
COL_HULL_BULL    = color.new(#00bfa5, 0)   // teal when bullish
COL_HULL_BEAR    = color.new(#ef5350, 0)   // red when bearish

// VWAP — soft indigo/blue, visually distinct from candles
COL_VWAP_LINE    = color.new(#88a5ff, 40)  // periwinkle line (slightly brighter)
COL_VWAP_BAND    = color.new(#5577ee, 86)  // soft blue fill (slightly more visible)

// Signals
COL_SIG_LONG     = color.new(#26a69a, 0)
COL_SIG_SHORT    = color.new(#ef5350, 0)
COL_DIV_BULL     = color.new(#00e676, 0)   // bright green — bullish divergence
COL_DIV_BEAR     = color.new(#ff1744, 0)   // bright red   — bearish divergence


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
g1 = "Hull MA"
hullLen      = input.int(55,   "Length",          group=g1, minval=5)
showHull     = input.bool(true,"Show Hull MA",     group=g1)

g2 = "VWAP"
showVwap     = input.bool(true,"Show VWAP + Band", group=g2)
vwapMult     = input.float(1.5,"Band Width (ATR×)",group=g2, minval=0.1)
atrLen       = input.int(14,   "ATR Length",       group=g2, minval=1)

g4 = "RSI Divergence"
showDiv      = input.bool(true,  "Show RSI Divergence",    group=g4)
rsiLen       = input.int(14,     "RSI Length",             group=g4, minval=2)
divLookback  = input.int(10,     "Pivot Lookback",         group=g4, minval=2)

g5 = "Entry Signals"
showSigs     = input.bool(true,"Show Entry Signals",group=g5)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ① HULL MOVING AVERAGE
//    HMA = WMA(2×WMA(n/2) − WMA(n), √n)
//    Fastest standard MA. Reacts before price, no repaint.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
hullHalf  = math.round(hullLen / 2)
hullSqrt  = math.round(math.sqrt(hullLen))
hullRaw   = ta.wma(2 * ta.wma(close, hullHalf) - ta.wma(close, hullLen), hullSqrt)
hullDir   = hullRaw > hullRaw[2]   // use [2] to avoid 1-bar flicker

hullColor = hullDir ? COL_HULL_BULL : COL_HULL_BEAR
plot(showHull ? hullRaw : na, title="Hull MA", color=hullColor, linewidth=2)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ② CANDLE STATE COLORING
//    4 tiers based on:
//    - Trend direction (above/below Hull MA)
//    - Bar strength (close position within bar range)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Cleaner 2-factor logic: Hull trend + momentum velocity
// Strong = trend and momentum agree, Weak = they disagree (potential reversal warning)
inUpTrend = close > hullRaw
momRising = ta.change(ta.sma(close, 10)) > 0

candleCol = inUpTrend and momRising      ? COL_BULL_STRONG : inUpTrend                  ? COL_BULL_WEAK : not inUpTrend and not momRising  ? COL_BEAR_STRONG : COL_BEAR_WEAK

// plotcandle renders body + wicks in the same color
// bordercolor matches so body edges are clean
plotcandle(open, high, low, close, title="Candles", color=candleCol, wickcolor=candleCol, bordercolor=candleCol)

// Hide the native chart candles so ours render cleanly on top
// (User should also set chart candle colors to transparent in Settings → Symbol)
barcolor(color.new(color.black, 100))

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ③ VWAP + ATR BAND
//    Daily-anchored VWAP = true "fair value"
//    Band = VWAP ± N×ATR (not std dev — more stable)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Rolling VWAP (session-style using cumulative approach over 20 bars
// as a proxy when anchor isn't available in non-intraday)
vwapVal   = ta.vwap(hlc3)
atrVal    = ta.atr(atrLen)
vwapUpper = vwapVal + vwapMult * atrVal
vwapLower = vwapVal - vwapMult * atrVal

priceAboveVwap = close > vwapVal

vwapLine  = plot(showVwap ? vwapVal   : na, title="VWAP",       color=COL_VWAP_LINE, linewidth=1)
vwapUp    = plot(showVwap ? vwapUpper : na, title="VWAP Upper", color=COL_VWAP_BAND, linewidth=1)
vwapDn    = plot(showVwap ? vwapLower : na, title="VWAP Lower", color=COL_VWAP_BAND, linewidth=1)
fill(vwapUp, vwapDn, color=COL_VWAP_BAND, title="VWAP Band")


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑤ RSI DIVERGENCE
//    Classic divergence: price and RSI moving in opposite
//    directions at pivot points.
//
//    Bullish: price lower low, RSI higher low → bottom signal
//    Bearish: price higher high, RSI lower high → top signal
//
//    Detection uses confirmed pivot lows/highs with a range
//    search — RSI pivot doesn't have to be on the exact same
//    bar as the price pivot, just within the lookback window.
//    This catches the broad multi-swing divergences you see
//    by eye on charts like BTC.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsiVal = ta.rsi(close, rsiLen)

// Confirmed price pivots
priceH = ta.pivothigh(high, divLookback, divLookback)
priceL = ta.pivotlow(low,  divLookback, divLookback)

// RSI value at the confirmed price pivot bar
// We look at RSI at the pivot bar itself (offset by divLookback)
rsiAtPivotH = rsiVal[divLookback]
rsiAtPivotL = rsiVal[divLookback]

// Track last TWO confirmed pivot lows and their RSI values
var float prevPriceL1 = na    // most recent low
var float prevRsiL1   = na
var float prevPriceL2 = na    // second most recent low
var float prevRsiL2   = na

var float prevPriceH1 = na
var float prevRsiH1   = na
var float prevPriceH2 = na
var float prevRsiH2   = na

bullDiv = false
bearDiv = false

// On each new confirmed price pivot low
if not na(priceL)
    prevPriceL2 := prevPriceL1
    prevRsiL2   := prevRsiL1
    prevPriceL1 := priceL
    prevRsiL1   := rsiAtPivotL

    // Bullish divergence: current low < previous low, but RSI now > RSI then
    if not na(prevPriceL2) and not na(prevRsiL2)
        if prevPriceL1 < prevPriceL2 and prevRsiL1 > prevRsiL2
            bullDiv := true

// On each new confirmed price pivot high
if not na(priceH)
    prevPriceH2 := prevPriceH1
    prevRsiH2   := prevRsiH1
    prevPriceH1 := priceH
    prevRsiH1   := rsiAtPivotH

    // Bearish divergence: current high > previous high, but RSI now < RSI then
    if not na(prevPriceH2) and not na(prevRsiH2)
        if prevPriceH1 > prevPriceH2 and prevRsiH1 < prevRsiH2
            bearDiv := true

// Use label.new for precise price positioning — plotshape doesn't support y offsets
// Labels plotted after RSI(9) is calculated below

// ─── RSI(9) Divergence — white diamond, closer to candle ─
rsiVal9 = ta.rsi(close, 9)

rsiAtPivotH9 = rsiVal9[divLookback]
rsiAtPivotL9 = rsiVal9[divLookback]

var float prevRsiL1_9 = na
var float prevRsiL2_9 = na
var float prevPriceL1_9 = na
var float prevPriceL2_9 = na
var float prevRsiH1_9 = na
var float prevRsiH2_9 = na
var float prevPriceH1_9 = na
var float prevPriceH2_9 = na

bullDiv9 = false
bearDiv9 = false

if not na(priceL)
    prevPriceL2_9 := prevPriceL1_9
    prevRsiL2_9   := prevRsiL1_9
    prevPriceL1_9 := priceL
    prevRsiL1_9   := rsiAtPivotL9
    if not na(prevPriceL2_9) and not na(prevRsiL2_9)
        if prevPriceL1_9 < prevPriceL2_9 and prevRsiL1_9 > prevRsiL2_9
            bullDiv9 := true

if not na(priceH)
    prevPriceH2_9 := prevPriceH1_9
    prevRsiH2_9   := prevRsiH1_9
    prevPriceH1_9 := priceH
    prevRsiH1_9   := rsiAtPivotH9
    if not na(prevPriceH2_9) and not na(prevRsiH2_9)
        if prevPriceH1_9 > prevPriceH2_9 and prevRsiH1_9 < prevRsiH2_9
            bearDiv9 := true

// ─── CMO Divergence — cyan diamond, outermost (catches broader oscillator div) ──
// CMO has different sensitivity than RSI — catches tops/bottoms RSI misses
// Uses its OWN smaller pivot lookback (5) to catch tighter swings than RSI div
cmoLen = 14
cmoPivLb = 5
cmoMomUp   = math.sum(math.max(close - close[1], 0), cmoLen)
cmoMomDn   = math.sum(math.max(close[1] - close, 0), cmoLen)
cmoVal     = (cmoMomUp + cmoMomDn) != 0 ? 100 * (cmoMomUp - cmoMomDn) / (cmoMomUp + cmoMomDn) : 0

// CMO uses its own price pivots with smaller lookback
cmoPriceH = ta.pivothigh(high, cmoPivLb, cmoPivLb)
cmoPriceL = ta.pivotlow(low,  cmoPivLb, cmoPivLb)

cmoAtPivotH = cmoVal[cmoPivLb]
cmoAtPivotL = cmoVal[cmoPivLb]

var float prevCmoL1   = na
var float prevCmoL2   = na
var float prevCmoL3   = na
var float prevCmoL4   = na
var float prevCmoPL1  = na
var float prevCmoPL2  = na
var float prevCmoPL3  = na
var float prevCmoPL4  = na
var float prevCmoH1   = na
var float prevCmoH2   = na
var float prevCmoH3   = na
var float prevCmoH4   = na
var float prevCmoPH1  = na
var float prevCmoPH2  = na
var float prevCmoPH3  = na
var float prevCmoPH4  = na

bullDivCmo = false
bearDivCmo = false

if not na(cmoPriceL)
    // Shift history down
    prevCmoPL4 := prevCmoPL3
    prevCmoL4  := prevCmoL3
    prevCmoPL3 := prevCmoPL2
    prevCmoL3  := prevCmoL2
    prevCmoPL2 := prevCmoPL1
    prevCmoL2  := prevCmoL1
    prevCmoPL1 := cmoPriceL
    prevCmoL1  := cmoAtPivotL
    // Check divergence against ANY of the last 4 pivots — catches broader structural divergences
    if not na(prevCmoPL2) and not na(prevCmoL2) and prevCmoPL1 < prevCmoPL2 and prevCmoL1 > prevCmoL2
        bullDivCmo := true
    if not na(prevCmoPL3) and not na(prevCmoL3) and prevCmoPL1 < prevCmoPL3 and prevCmoL1 > prevCmoL3
        bullDivCmo := true
    if not na(prevCmoPL4) and not na(prevCmoL4) and prevCmoPL1 < prevCmoPL4 and prevCmoL1 > prevCmoL4
        bullDivCmo := true

if not na(cmoPriceH)
    prevCmoPH4 := prevCmoPH3
    prevCmoH4  := prevCmoH3
    prevCmoPH3 := prevCmoPH2
    prevCmoH3  := prevCmoH2
    prevCmoPH2 := prevCmoPH1
    prevCmoH2  := prevCmoH1
    prevCmoPH1 := cmoPriceH
    prevCmoH1  := cmoAtPivotH
    if not na(prevCmoPH2) and not na(prevCmoH2) and prevCmoPH1 > prevCmoPH2 and prevCmoH1 < prevCmoH2
        bearDivCmo := true
    if not na(prevCmoPH3) and not na(prevCmoH3) and prevCmoPH1 > prevCmoPH3 and prevCmoH1 < prevCmoH3
        bearDivCmo := true
    if not na(prevCmoPH4) and not na(prevCmoH4) and prevCmoPH1 > prevCmoPH4 and prevCmoH1 < prevCmoH4
        bearDivCmo := true

// (diamonds plotted above with absolute positioning)

// ── Sequence counters — show 2,3,4... for consecutive divergences ──
// First divergence in a sequence shows just the diamond (no number)
// Subsequent ones show the count so you can see how many have stacked
var int bullDivSeq  = 0
var int bearDivSeq  = 0
var int bullDiv9Seq = 0
var int bearDiv9Seq = 0

// Reset sequence if no divergence for a while (price made a new non-diverging pivot)
if not na(priceL) and not bullDiv and not bullDiv9
    bullDivSeq  := 0
    bullDiv9Seq := 0
if not na(priceH) and not bearDiv and not bearDiv9
    bearDivSeq  := 0
    bearDiv9Seq := 0

if bullDiv
    bullDivSeq := bullDivSeq + 1
if bearDiv
    bearDivSeq := bearDivSeq + 1
if bullDiv9
    bullDiv9Seq := bullDiv9Seq + 1
if bearDiv9
    bearDiv9Seq := bearDiv9Seq + 1

// ── Diamond labels with sequence numbers ──
// White ◆ (RSI 9) — closer to candle at 0.8×ATR
// Gold  ◆ (RSI 14) — further out at 1.8×ATR, sits just beyond white
if showDiv and bullDiv9
    _seq9b = bullDiv9Seq > 1 ? "◆" + str.tostring(bullDiv9Seq) : "◆"
    label.new(bar_index - divLookback, low[divLookback]  - atrVal[divLookback] * 0.6, _seq9b, color=color.new(#000000, 100), textcolor=color.new(#ffffff, 10), style=label.style_none, size=size.tiny)
if showDiv and bearDiv9
    _seq9r = bearDiv9Seq > 1 ? "◆" + str.tostring(bearDiv9Seq) : "◆"
    label.new(bar_index - divLookback, high[divLookback] + atrVal[divLookback] * 0.8, _seq9r, color=color.new(#000000, 100), textcolor=color.new(#ffffff, 10), style=label.style_none, size=size.tiny)
if showDiv and bullDiv
    _seq14b = bullDivSeq > 1 ? "◆" + str.tostring(bullDivSeq) : "◆"
    label.new(bar_index - divLookback, low[divLookback]  - atrVal[divLookback] * 1.4, _seq14b, color=color.new(#000000, 100), textcolor=color.new(#ffd600, 0),  style=label.style_none, size=size.tiny)
if showDiv and bearDiv
    _seq14r = bearDivSeq > 1 ? "◆" + str.tostring(bearDivSeq) : "◆"
    label.new(bar_index - divLookback, high[divLookback] + atrVal[divLookback] * 1.8, _seq14r, color=color.new(#000000, 100), textcolor=color.new(#ffd600, 0),  style=label.style_none, size=size.tiny)

// CMO divergence — cyan diamond, outermost layer (uses its own smaller pivot lookback)
if showDiv and bullDivCmo
    label.new(bar_index - cmoPivLb, low[cmoPivLb]  - atrVal[cmoPivLb] * 2.2, "◆", color=color.new(#000000, 100), textcolor=color.new(#00e5ff, 0),  style=label.style_none, size=size.tiny)
if showDiv and bearDivCmo
    label.new(bar_index - cmoPivLb, high[cmoPivLb] + atrVal[cmoPivLb] * 2.6, "◆", color=color.new(#000000, 100), textcolor=color.new(#00e5ff, 0),  style=label.style_none, size=size.tiny)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑥ ENTRY SIGNALS
//    Confluence-only entries — ALL must align:
//
//    LONG:  Hull bullish + close > VWAP + bullish RSI div + not overbought
//    SHORT: Hull bearish + close < VWAP + bearish RSI div + not oversold
//
//    Rendered as clean geometric dots, not arrows
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Simple momentum filter (avoid chasing extremes)
rsi14         = ta.rsi(close, 14)
notOverbought = rsi14 < 75
notOversold   = rsi14 > 25

// Volume confirmation (above 20-bar average)
volAvg      = ta.sma(volume, 20)
volConfirm  = volume > volAvg * 0.8

longSignal  = showSigs and hullDir and close > vwapVal and bullDiv and notOverbought and volConfirm
shortSignal = showSigs and not hullDir and close < vwapVal and bearDiv and notOversold and volConfirm

plotshape(longSignal,  title="Long Signal",  style=shape.circle, location=location.belowbar, color=COL_SIG_LONG,  size=size.small)
plotshape(shortSignal, title="Short Signal", style=shape.circle, location=location.abovebar, color=COL_SIG_SHORT, size=size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑦ HIDDEN DIVERGENCE — trend continuation after pullback
//    Bullish hidden div: price higher low, RSI lower low
//      → uptrend resuming, buy the dip signal
//    Bearish hidden div: price lower high, RSI higher high
//      → downtrend resuming, sell the bounce signal
//    Visualized as small open diamonds (different from solid div diamonds)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showHiddenDiv = input.bool(true, "Show Hidden Divergence", group="Hidden Divergence")

bullHiddenDiv = false
bearHiddenDiv = false

// Bullish hidden: price higher low, RSI lower low (uptrend continuation)
if not na(priceL)
    if not na(prevPriceL2) and not na(prevRsiL2)
        if prevPriceL1 > prevPriceL2 and prevRsiL1 < prevRsiL2
            bullHiddenDiv := true

// Bearish hidden: price lower high, RSI higher high (downtrend continuation)
if not na(priceH)
    if not na(prevPriceH2) and not na(prevRsiH2)
        if prevPriceH1 < prevPriceH2 and prevRsiH1 > prevRsiH2
            bearHiddenDiv := true

// Hollow diamond using ◇ unicode — visually distinct from solid ◆
if showHiddenDiv and bullHiddenDiv
    label.new(bar_index - divLookback, low[divLookback]  - atrVal[divLookback] * 1.0, "◇", color=color.new(#000000, 100), textcolor=color.new(#26a69a, 0), style=label.style_none, size=size.tiny)
if showHiddenDiv and bearHiddenDiv
    label.new(bar_index - divLookback, high[divLookback] + atrVal[divLookback] * 1.0, "◇", color=color.new(#000000, 100), textcolor=color.new(#ef5350, 0), style=label.style_none, size=size.tiny)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑧ VOLUME CLIMAX — capitulation/blowoff marker
//    Volume ≥ climax multiplier × 20-bar average AND bar is a
//    swing extreme. Marks panic selling or euphoric buying.
//    Visualized as a colored circle outside the candle.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showClimax    = input.bool(true, "Show Volume Climax",  group="Volume Climax")
climaxMult    = input.float(2.5, "Volume × Avg",         group="Volume Climax", minval=1.5, step=0.1)
climaxLookback= input.int(10,    "Swing Lookback",       group="Volume Climax", minval=3)

volAvg20 = ta.sma(volume, 20)
volSpike = volume >= volAvg20 * climaxMult

// Bullish climax: volume spike + bar made a new low in lookback window + closed in upper half (recovery)
isLowestInWindow  = low <= ta.lowest(low, climaxLookback)
isHighestInWindow = high >= ta.highest(high, climaxLookback)
closedUpper       = close > (high + low) / 2
closedLower       = close < (high + low) / 2

bullClimax = showClimax and volSpike and isLowestInWindow and closedUpper
bearClimax = showClimax and volSpike and isHighestInWindow and closedLower

plotshape(bullClimax, title="Bull Climax", style=shape.circle, location=location.belowbar, color=color.new(#00e676, 20), size=size.small)
plotshape(bearClimax, title="Bear Climax", style=shape.circle, location=location.abovebar, color=color.new(#ff1744, 20), size=size.small)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑨ VWAP BAND REJECTION — intermediate top/bottom catcher
//    When price tags or pierces the upper VWAP band but closes
//    back inside, that's a top rejection. Same logic for lower
//    band = bottom rejection. Catches intermediate pivots that
//    are too quick for divergence to detect.
//
//    Tighter version of SFP — uses VWAP band as the resistance/
//    support reference instead of recent high/low.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showBandRej = input.bool(true, "Show VWAP Band Rejection", group="Band Rejection")
bandRejBuffer = input.float(0.5, "Tag Buffer (×ATR)", group="Band Rejection", minval=0.0, step=0.1, tooltip="How close price must come to band to count as a tag. 0 = exact touch, 0.5 = within half an ATR.")

// Buffer zone — bar must come within bufferZone of the band to count
bufferZone = atrVal * bandRejBuffer

// Bull rejection: low pierced or tagged the LOWER band, but closed back ABOVE it
bullBandRej = showBandRej and low <= (vwapLower + bufferZone) and close > vwapLower

// Bear rejection: high pierced or tagged the UPPER band, but closed back BELOW it
bearBandRej = showBandRej and high >= (vwapUpper - bufferZone) and close < vwapUpper

// Pink/magenta diamond — distinct from all other signals
plotshape(bullBandRej, title="Bull Band Rejection", style=shape.triangleup,   location=location.belowbar, color=color.new(#b388ff, 40), size=size.tiny)
plotshape(bearBandRej, title="Bear Band Rejection", style=shape.triangledown, location=location.abovebar, color=color.new(#b388ff, 40), size=size.tiny)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ⑨ HULL SLOPE ACCELERATION — confirmation that move has begun
//    Measures Hull MA slope steepness. When slope crosses above
//    a threshold from below, signals trend acceleration.
//    Filters false starts — divergence tells you exhaustion,
//    Hull acceleration tells you the new move is real.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
showAccel  = input.bool(true,  "Show Hull Acceleration", group="Trend Acceleration")
accelMult  = input.float(0.5,  "Slope Threshold (×ATR)", group="Trend Acceleration", minval=0.1, step=0.1)

hullSlope    = hullRaw - hullRaw[3]
slopeThresh  = atrVal * accelMult

bullAccel = showAccel and hullSlope > slopeThresh and hullSlope[1] <= slopeThresh
bearAccel = showAccel and hullSlope < -slopeThresh and hullSlope[1] >= -slopeThresh

// Vertical bar marker — short colored tick on the Hull line
plotshape(bullAccel, title="Bull Accel", style=shape.arrowup,   location=location.belowbar, color=color.new(#00e5a0, 20), size=size.tiny)
plotshape(bearAccel, title="Bear Accel", style=shape.arrowdown, location=location.abovebar, color=color.new(#ff4455, 20), size=size.tiny)


alertcondition(longSignal,  title="EDGE Long Signal",      message="EDGE: Long confluence signal fired!")
alertcondition(shortSignal, title="EDGE Short Signal",     message="EDGE: Short confluence signal fired!")
alertcondition(bullDiv,     title="Bullish RSI Divergence",message="EDGE: Bullish RSI divergence — potential bottom!")
alertcondition(bearDiv,     title="Bearish RSI Divergence",message="EDGE: Bearish RSI divergence — potential top!")
alertcondition(bullHiddenDiv, title="Bullish Hidden Divergence", message="EDGE: Bullish hidden divergence — uptrend resuming!")
alertcondition(bearHiddenDiv, title="Bearish Hidden Divergence", message="EDGE: Bearish hidden divergence — downtrend resuming!")
alertcondition(bullClimax,  title="Bullish Volume Climax", message="EDGE: Bullish volume climax — capitulation low!")
alertcondition(bearClimax,  title="Bearish Volume Climax", message="EDGE: Bearish volume climax — euphoric blowoff top!")
alertcondition(bullAccel,   title="Bull Trend Acceleration", message="EDGE: Bullish trend accelerating!")
alertcondition(bearAccel,   title="Bear Trend Acceleration", message="EDGE: Bearish trend accelerating!")
alertcondition(bullBandRej, title="Bull Band Rejection",    message="EDGE: Lower band rejection — intermediate bottom!")
alertcondition(bearBandRej, title="Bear Band Rejection",    message="EDGE: Upper band rejection — intermediate top!")
````
