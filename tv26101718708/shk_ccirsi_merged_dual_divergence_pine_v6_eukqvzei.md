# SHK CCI+RSI Merged | Dual Divergence | Pine v6

- url: https://www.tradingview.com/script/eUkqvZEi-SHK-CCI-RSI-Merged-Dual-Divergence-Pine-v6/
- type: indicator
- pine_id: PUB;113e93955df943b29a75701b1bf9c80e
- version: 1.0

## Description

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔷 SHK CCI+RSI MERGED — CLEAN 2-LINE OSCILLATOR
          Built with Pine Script v6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Why run two oscillators when one can do more?

This indicator intelligently merges CCI and RSI into 
a single blended line — reducing chart noise while 
combining the strengths of both indicators into 
one clean, actionable signal.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 THE BLEND — HOW IT WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Step 1 — RSI is normalized to the CCI scale:

   RSI  50  →    0   (zero / neutral line)
   RSI  70  →  +100  (overbought boundary)
   RSI  30  →  -100  (oversold boundary)

Step 2 — Both are averaged:

   Blended = ( CCI + Normalized RSI ) / 2

The ±100 levels now act as the unified overbought 
and oversold zone for BOTH CCI and RSI together.

When RSI is disabled → falls back to pure CCI.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 WHAT YOU SEE — JUST 2 LINES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

● LINE 1 — CCI+RSI Blended  (thick line)

  Color reflects momentum state in real time:

  🟢 Bright Green → above MA + above zero  (strong bull)
  🟢 Faded  Green → above MA + below zero  (weak bull)
  🔴 Bright Red   → below MA + below zero  (strong bear)
  🔴 Faded  Red   → below MA + above zero  (weak bear)

● LINE 2 — Signal MA  (yellow line)

  EMA / SMA / WMA of the blended line.
  Acts as the dynamic trend filter and crossover trigger.

● HISTOGRAM — Strength Bars

  Plotted behind both lines. Color intensity shows 
  how deep into overbought / oversold territory 
  the blended line has moved.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📉 DUAL DIVERGENCE DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Two independent engines detect divergences simultaneously:

🟩 CCI+RSI Divergence  (solid lines)
   Blended oscillator pivots compared to price pivots:
   • Lime  solid line + "Bull Div"  → Bullish divergence
   • Red   solid line + "Bear Div"  → Bearish divergence

🟦 RSI-Only Divergence  (dashed lines)
   Raw RSI pivots detected, drawn at normalized scale:
   • Aqua   dashed + "RSI Bull Div" → RSI bullish divergence
   • Orange dashed + "RSI Bear Div" → RSI bearish divergence

Lookback and threshold are independently adjustable 
for both engines — tune to your trading style.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ ZERO LINE CROSS MARKERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔼 Green triangle (bottom) → blended crossed above 0
  🔽 Red   triangle (top)    → blended crossed below 0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 EXTREME ZONE BACKGROUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Background shading activates at strong momentum zones:

  🟢 Green shade → blended > +100 and above MA
  🔴 Red   shade → blended < -100 and below MA

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS — 14 CONDITIONS READY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Strong Bullish  (blended > +100 & above MA)
  ✅ Strong Bearish  (blended < -100 & below MA)
  ✅ Zero cross — bullish
  ✅ Zero cross — bearish
  ✅ Blended crossed above +100
  ✅ Blended crossed below -100
  ✅ Overbought zone entry
  ✅ Oversold zone entry
  ✅ Exit overbought zone
  ✅ Exit oversold zone
  ✅ RSI crossed overbought level
  ✅ RSI crossed oversold level
  ✅ RSI crossed above midline (50)
  ✅ RSI crossed below midline (50)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ FULL SETTINGS REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CCI Settings
  ├─ Length            (default: 20)
  ├─ Source            (default: HLC3)
  ├─ Signal MA Type    (EMA / SMA / WMA)
  └─ Signal MA Length  (default: 14)

  CCI Levels
  ├─ Overbought        (default: +100)
  ├─ Oversold          (default: -100)
  ├─ Upper Level       (default: +100)
  └─ Lower Level       (default: -100)

  RSI Settings
  ├─ Enable RSI blend  (toggle on/off)
  ├─ RSI Length        (default: 14)
  ├─ RSI Source        (default: Close)
  ├─ RSI Overbought    (default: 70)
  └─ RSI Oversold      (default: 30)

  Features  (each individually toggleable)
  ├─ Show CCI+RSI Divergences
  ├─ Show RSI-Only Divergences
  ├─ Show Trend Strength Bars
  ├─ Show Zero Line Cross Markers
  └─ Highlight Extreme Zone Background

  Divergence Settings
  ├─ Lookback bars         (1–20, default: 5)
  ├─ CCI Divergence Threshold  (default: 10)
  └─ RSI Divergence Threshold  (default: 3)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 BEST USED WITH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • Support / Resistance levels on price chart
  • VWAP or Volume Profile for zone confluence
  • Higher timeframe trend bias
  • Supply & Demand or Order Block frameworks
  • Works on all markets and all timeframes

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This script is published for EDUCATIONAL and
INFORMATIONAL purposes only.

❌ NOT financial advice.
❌ NOT a buy or sell recommendation.
❌ Past performance does NOT guarantee future results.

Trading stocks, futures, forex, commodities and
cryptocurrencies involves SUBSTANTIAL RISK OF LOSS
and is not suitable for all investors or traders.

The author — SHK — is NOT responsible for any
trading losses or financial damages resulting from
the use or misuse of this indicator.

All trading decisions are SOLELY YOUR RESPONSIBILITY.
You agree to use this tool entirely at YOUR OWN RISK.

Consult a qualified financial advisor before making
any investment or trading decisions.

By using this indicator you fully accept all risks
and release the author from any and all liability.

📌 TRADE SMART. MANAGE YOUR RISK. PROTECT YOUR CAPITAL.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// ============================================================================
// SHK CCI+RSI Merged — 2 Line Edition
// Line 1: Blended CCI+RSI  |  Line 2: Signal MA of Blended
// ============================================================================
indicator(
     title          = "SHK CCI+RSI Merged",
     shorttitle     = "CCI+RSI",
     format         = format.price,
     precision      = 2,
     overlay        = false,
     max_lines_count  = 200,
     max_labels_count = 100
)

// ============================================================================
// INPUTS — CCI
// ============================================================================
length  = input.int   (20,    minval=1, title="CCI Length",          group="CCI Settings")
src     = input       (hlc3,            title="Source",               group="CCI Settings")
maType  = input.string("EMA",           title="Signal MA Type",       options=["SMA","EMA","WMA"], group="CCI Settings")
maLen   = input.int   (14,    minval=1, title="Signal MA Length",     group="CCI Settings")

// ============================================================================
// INPUTS — CCI LEVELS
// ============================================================================
customOB    = input.int( 100, "Overbought Level", group="CCI Levels")
customOS    = input.int(-100, "Oversold Level",   group="CCI Levels")
level100    = input.int( 100, "Upper Level",      group="CCI Levels")
levelNeg100 = input.int(-100, "Lower Level",      group="CCI Levels")

// ============================================================================
// INPUTS — RSI
// ============================================================================
rsiEnable = input.bool(true,  "Enable RSI",             group="RSI Settings")
rsiLength = input.int (14,    "RSI Length",  minval=1,  group="RSI Settings")
rsiSrc    = input     (close, "RSI Source",              group="RSI Settings")
rsiOB     = input.int (70,    "RSI Overbought (0-100)", group="RSI Settings")
rsiOS     = input.int (30,    "RSI Oversold  (0-100)",  group="RSI Settings")

// ============================================================================
// INPUTS — FEATURES
// ============================================================================
showCCIDiv    = input.bool(true, "Show CCI Divergences",     group="Features")
showRSIDiv    = input.bool(true, "Show RSI Divergences",     group="Features")
showStrength  = input.bool(true, "Show Trend Strength Bars", group="Features")
showZeroCross = input.bool(true, "Show Zero Line Crosses",   group="Features")
showExtremes  = input.bool(true, "Highlight Extreme Zones",  group="Features")

// ============================================================================
// INPUTS — DIVERGENCE
// ============================================================================
divLookback  = input.int  (5,  "Divergence Lookback",      minval=1, maxval=20, group="Divergence Settings")
cciDivThresh = input.float(10, "CCI Divergence Threshold", minval=1, maxval=50, group="Divergence Settings")
rsiDivThresh = input.float(3,  "RSI Divergence Threshold", minval=1, maxval=20, group="Divergence Settings")

// ============================================================================
// CCI CALCULATION
// ============================================================================
basis = ta.sma(src, length)
cci   = (src - basis) / (0.015 * ta.dev(src, length))

// ============================================================================
// RSI CALCULATION + NORMALIZE TO CCI SCALE
// RSI 50 → 0  |  RSI OB → +100  |  RSI OS → -100
// ============================================================================
rsi     = ta.rsi(rsiSrc, rsiLength)
rsiNorm = rsiEnable ? (rsi - 50.0) / float(rsiOB - 50) * float(level100) : na

// ============================================================================
// BLENDED LINE = AVERAGE OF CCI + NORMALIZED RSI
// Falls back to pure CCI if RSI disabled
// ============================================================================
blended = rsiEnable and not na(rsiNorm) ? (cci + rsiNorm) / 2.0 : cci

// ============================================================================
// SIGNAL MA OF BLENDED LINE
// ============================================================================
var float blendMA = na
if maType == "SMA"
    blendMA := ta.sma(blended, maLen)
else if maType == "EMA"
    blendMA := ta.ema(blended, maLen)
else
    blendMA := ta.wma(blended, maLen)

// ============================================================================
// SIGNAL CLASSIFICATION
// ============================================================================
strongBullish = blended > level100    and blended >= blendMA
strongBearish = blended < levelNeg100 and blended  < blendMA

// ============================================================================
// COLOR LOGIC — v6 if/else blocks (no multi-line ternary)
// ============================================================================
var color blendColor = na
if blended >= blendMA and blended > 0
    blendColor := color.new(color.lime, 0)
else if blended >= blendMA and blended <= 0
    blendColor := color.new(color.lime, 50)
else if blended < blendMA and blended < 0
    blendColor := color.new(color.red, 0)
else
    blendColor := color.new(color.red, 50)

var color histColor = na
if blended > 0
    histColor := blended > level100 ? color.new(color.lime, 30) : color.new(color.lime, 70)
else
    histColor := blended < levelNeg100 ? color.new(color.red, 30) : color.new(color.red, 70)

// ============================================================================
// PIVOTS (shared by both divergence blocks)
// ============================================================================
blendPivHigh = ta.pivothigh(blended, divLookback, divLookback)
blendPivLow  = ta.pivotlow (blended, divLookback, divLookback)
priceHigh    = ta.pivothigh(high,    divLookback, divLookback)
priceLow     = ta.pivotlow (low,     divLookback, divLookback)

rsiPivHigh   = ta.pivothigh(rsi, divLookback, divLookback)
rsiPivLow    = ta.pivotlow (rsi, divLookback, divLookback)

rsiPivHighNorm = not na(rsiPivHigh) ? (rsiPivHigh - 50.0) / float(rsiOB - 50) * float(level100) : na
rsiPivLowNorm  = not na(rsiPivLow)  ? (rsiPivLow  - 50.0) / float(rsiOB - 50) * float(level100) : na

// ============================================================================
// CCI DIVERGENCE (on blended line)
// ============================================================================
var float lastBLow    = na
var float lastPrcLow  = na
var int   lastBLowBar = na

if not na(blendPivLow)
    if not na(lastBLow)
        float pl = na(priceLow) ? low[divLookback] : priceLow
        if pl < lastPrcLow and blendPivLow > lastBLow and (blendPivLow - lastBLow) > cciDivThresh
            if showCCIDiv
                line.new(lastBLowBar, lastBLow, bar_index[divLookback], blendPivLow,
                     color=color.new(color.lime, 0), width=2)
                label.new(bar_index[divLookback], blendPivLow, "Bull Div",
                     style=label.style_label_up, color=color.new(color.lime, 20),
                     textcolor=color.white, size=size.small)
    lastBLow    := blendPivLow
    lastPrcLow  := na(priceLow) ? low[divLookback] : priceLow
    lastBLowBar := bar_index[divLookback]

var float lastBHigh    = na
var float lastPrcHigh  = na
var int   lastBHighBar = na

if not na(blendPivHigh)
    if not na(lastBHigh)
        float ph = na(priceHigh) ? high[divLookback] : priceHigh
        if ph > lastPrcHigh and blendPivHigh < lastBHigh and (lastBHigh - blendPivHigh) > cciDivThresh
            if showCCIDiv
                line.new(lastBHighBar, lastBHigh, bar_index[divLookback], blendPivHigh,
                     color=color.new(color.red, 0), width=2)
                label.new(bar_index[divLookback], blendPivHigh, "Bear Div",
                     style=label.style_label_down, color=color.new(color.red, 20),
                     textcolor=color.white, size=size.small)
    lastBHigh    := blendPivHigh
    lastPrcHigh  := na(priceHigh) ? high[divLookback] : priceHigh
    lastBHighBar := bar_index[divLookback]

// ============================================================================
// RSI DIVERGENCE (on raw RSI pivots, drawn at normalized scale)
// ============================================================================
var float lastRSILow     = na
var float lastRSILowNorm = na
var float lastRSIPrcLow  = na
var int   lastRSILowBar  = na

if not na(rsiPivLow) and rsiEnable
    if not na(lastRSILow)
        float pl = na(priceLow) ? low[divLookback] : priceLow
        if pl < lastRSIPrcLow and rsiPivLow > lastRSILow and (rsiPivLow - lastRSILow) > rsiDivThresh
            if showRSIDiv
                line.new(lastRSILowBar, lastRSILowNorm, bar_index[divLookback], rsiPivLowNorm,
                     color=color.new(color.aqua, 0), width=2, style=line.style_dashed)
                label.new(bar_index[divLookback], rsiPivLowNorm, "RSI Bull Div",
                     style=label.style_label_up, color=color.new(color.aqua, 20),
                     textcolor=color.white, size=size.small)
    lastRSILow     := rsiPivLow
    lastRSILowNorm := rsiPivLowNorm
    lastRSIPrcLow  := na(priceLow) ? low[divLookback] : priceLow
    lastRSILowBar  := bar_index[divLookback]

var float lastRSIHigh     = na
var float lastRSIHighNorm = na
var float lastRSIPrcHigh  = na
var int   lastRSIHighBar  = na

if not na(rsiPivHigh) and rsiEnable
    if not na(lastRSIHigh)
        float ph = na(priceHigh) ? high[divLookback] : priceHigh
        if ph > lastRSIPrcHigh and rsiPivHigh < lastRSIHigh and (lastRSIHigh - rsiPivHigh) > rsiDivThresh
            if showRSIDiv
                line.new(lastRSIHighBar, lastRSIHighNorm, bar_index[divLookback], rsiPivHighNorm,
                     color=color.new(color.orange, 0), width=2, style=line.style_dashed)
                label.new(bar_index[divLookback], rsiPivHighNorm, "RSI Bear Div",
                     style=label.style_label_down, color=color.new(color.orange, 20),
                     textcolor=color.white, size=size.small)
    lastRSIHigh     := rsiPivHigh
    lastRSIHighNorm := rsiPivHighNorm
    lastRSIPrcHigh  := na(priceHigh) ? high[divLookback] : priceHigh
    lastRSIHighBar  := bar_index[divLookback]

// ============================================================================
// ZERO LINE CROSSES
// ============================================================================
bullishCross = ta.crossover (blended, 0)
bearishCross = ta.crossunder(blended, 0)

plotshape(showZeroCross and bullishCross, "Bullish Cross",
     style=shape.triangleup,   location=location.bottom,
     color=color.new(color.lime, 0), size=size.tiny)
plotshape(showZeroCross and bearishCross, "Bearish Cross",
     style=shape.triangledown, location=location.top,
     color=color.new(color.red,  0), size=size.tiny)

// ============================================================================
// PLOTS — 2 LINES ONLY
// ============================================================================
plot(showStrength ? blended : na, "Strength",
     style=plot.style_histogram, color=histColor, linewidth=1)

plot(blended, "CCI+RSI",   color=blendColor,    linewidth=3)
plot(blendMA, "Signal MA", color=color.yellow,  linewidth=2)

// ============================================================================
// HORIZONTAL LEVELS
// ============================================================================
hline(customOB,    "OB",      color=color.new(color.red,   30), linestyle=hline.style_dashed, linewidth=2)
h_up = hline(level100,    "+100",    color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(0,           "Zero",    color=color.new(color.gray,  30), linewidth=2)
h_dn = hline(levelNeg100, "-100",    color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(customOS,    "OS",      color=color.new(color.green, 30), linestyle=hline.style_dashed, linewidth=2)

fill(h_up, h_dn, color=color.new(#2196F3, 92), title="Normal Zone")

// ============================================================================
// BGCOLOR — EXTREME ZONES
// ============================================================================
bgcolor(showExtremes and strongBullish ? color.new(color.lime, 92) :
        showExtremes and strongBearish  ? color.new(color.red,  92) : na,
        title="Extreme Zone")

// ============================================================================
// ALERTS — BLENDED LINE
// ============================================================================
alertcondition(strongBullish,                            "Strong Bullish",       "CCI+RSI above +100 & above MA")
alertcondition(strongBearish,                            "Strong Bearish",       "CCI+RSI below -100 & below MA")
alertcondition(bullishCross,                             "Bullish Zero Cross",   "CCI+RSI crossed above zero")
alertcondition(bearishCross,                             "Bearish Zero Cross",   "CCI+RSI crossed below zero")
alertcondition(ta.crossover (blended, level100),         "Above +100",           "CCI+RSI crossed above +100")
alertcondition(ta.crossunder(blended, levelNeg100),      "Below -100",           "CCI+RSI crossed below -100")
alertcondition(ta.cross     (blended, customOB),         "Overbought",           "CCI+RSI hit overbought zone")
alertcondition(ta.cross     (customOS, blended),         "Oversold",             "CCI+RSI hit oversold zone")
alertcondition(ta.crossunder(blended, customOB),         "Exit Overbought",      "CCI+RSI exiting overbought")
alertcondition(ta.crossover (blended, customOS),         "Exit Oversold",        "CCI+RSI exiting oversold")

// ============================================================================
// ALERTS — RSI (global scope, gated with rsiEnable)
// ============================================================================
alertcondition(rsiEnable and ta.crossover (rsi, rsiOB), "RSI Overbought",  "RSI crossed above overbought")
alertcondition(rsiEnable and ta.crossunder(rsi, rsiOS), "RSI Oversold",    "RSI crossed below oversold")
alertcondition(rsiEnable and ta.crossover (rsi, 50),    "RSI Bullish Mid", "RSI crossed above 50")
alertcondition(rsiEnable and ta.crossunder(rsi, 50),    "RSI Bearish Mid", "RSI crossed below 50")
````
