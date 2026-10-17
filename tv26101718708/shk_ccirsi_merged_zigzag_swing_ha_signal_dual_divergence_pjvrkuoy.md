# SHK CCI+RSI Merged | ZigZag Swing | HA Signal | Dual Divergence

- url: https://www.tradingview.com/script/pJvrKuOy-SHK-CCI-RSI-Merged-ZigZag-Swing-HA-Signal-Dual-Divergence/
- type: indicator
- pine_id: PUB;5f96653097cd495e9d0fcc7889fd7484
- version: 1.0

## Description

// ============================================================================
// DISCLAIMER: This script is for educational purposes only.
// The author is NOT responsible for any trading losses.
// Past performance does not guarantee future results.
// Trade entirely at your own risk.
// ============================================================================
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔷 SHK CCI+RSI MERGED — FULL CONFLUENCE INDICATOR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

A clean, all-in-one oscillator that merges CCI and RSI into a 
single blended line — eliminating indicator clutter while 
preserving the best signals from both.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 HOW THE BLEND WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RSI is normalized to the CCI scale before blending:
  • RSI 50  →  0  (zero line)
  • RSI 70  → +100 (upper level)
  • RSI 30  → -100 (lower level)

The two oscillators are then averaged:
  Blended = (CCI + Normalized RSI) / 2

This means ±100 is the true overbought/oversold boundary 
for BOTH indicators simultaneously.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 WHAT YOU SEE — 2 LINES ONLY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟢 CCI+RSI Blended Line
  Dynamic color based on position vs Signal MA and zero line:
  • Bright green  → above MA and above zero (strong bull)
  • Faded green   → above MA but below zero (weak bull)
  • Bright red    → below MA and below zero (strong bear)
  • Faded red     → below MA but above zero (weak bear)

🟡 Signal MA Line (EMA / SMA / WMA — your choice)
  Colored by Heikin Ashi candle direction:
  • 🟢 Green → HA candle is bullish (momentum rising)
  • 🔴 Red   → HA candle is bearish (momentum falling)
  The MA color flip gives early trend change warning.

📊 Histogram bars behind the lines show trend strength 
  with intensity — brighter = deeper into extreme zone.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔀 ZIGZAG — SWING & INTERNAL
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ZigZag is drawn directly ON the blended oscillator — 
not on price — so you see market structure on the 
indicator itself.

✅ Main Swing ZigZag — major HH / HL / LH / LL pivots
✅ Internal ZigZag   — minor swings inside the main structure
✅ Labels: HH, HL, LH, LL at every confirmed pivot
✅ Customizable: depth, deviation, backstep, color, style

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📉 DUAL DIVERGENCE DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Two independent divergence engines running simultaneously:

🟩 CCI+RSI Divergence (solid lines)
  Detected on the blended oscillator pivots vs price pivots
  • Lime line + "Bull Div" label  → bullish divergence
  • Red  line + "Bear Div" label  → bearish divergence

🟦 RSI-Only Divergence (dashed lines)
  Detected on raw RSI pivots, drawn at normalized scale
  • Aqua   dashed + "RSI Bull Div" → RSI bullish divergence
  • Orange dashed + "RSI Bear Div" → RSI bearish divergence

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ ZERO LINE CROSSES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔼 Green triangle (bottom) → blended crossed above zero
  🔽 Red   triangle (top)    → blended crossed below zero

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 EXTREME ZONE HIGHLIGHTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Background shading activates when blended crosses ±100:
  • 🟢 Green background → strong bullish zone
  • 🔴 Red   background → strong bearish zone

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 ALERTS INCLUDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Strong Bullish / Bearish signal
  ✅ Zero line cross (bull & bear)
  ✅ CCI+RSI above +100 / below -100
  ✅ Overbought / Oversold zone entry & exit
  ✅ RSI overbought / oversold / mid cross
  ✅ Heikin Ashi direction flip (MA color change)
  ✅ ZigZag swing high / swing low confirmed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ FULLY CUSTOMIZABLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • CCI length and source
  • RSI length, source, OB/OS levels
  • Signal MA type (EMA / SMA / WMA) and length
  • ZigZag depth, deviation, backstep, colors, styles
  • Internal ZigZag independently configurable
  • Divergence lookback and threshold (separate for CCI & RSI)
  • All visual elements individually toggleable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 BEST USED WITH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • Price action / support-resistance levels
  • Volume profile or VWAP on the main chart
  • Higher timeframe trend confirmation
  • Works on all markets: equities, futures, forex, crypto

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This indicator is published for EDUCATIONAL and 
INFORMATIONAL purposes only.

❌ This is NOT financial advice.
❌ This is NOT a buy or sell recommendation.
❌ Past performance does NOT guarantee future results.

Trading financial instruments including stocks, futures, 
forex, commodities and cryptocurrencies involves 
SUBSTANTIAL RISK OF LOSS and is not suitable for 
every investor or trader.

The creator(s) of this script — SHK — are NOT responsible 
for any trading losses, damages or financial consequences 
resulting from the use or misuse of this indicator.

All trading decisions are SOLELY YOUR OWN RESPONSIBILITY.
You agree to trade entirely at YOUR OWN RISK.

Always conduct your own due diligence. Consult a 
qualified and licensed financial advisor before making 
any investment or trading decisions.

By using this indicator you acknowledge and accept 
all risks associated with trading and release the 
author from any and all liability.

📌 TRADE SMART. MANAGE YOUR RISK. PROTECT YOUR CAPITAL.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// ============================================================================
// SHK CCI+RSI + ZigZag Swing & Internal — Full Merge
// ============================================================================
indicator(
     title            = "SHK CCI+RSI + ZigZag",
     shorttitle        = "CCI+RSI+ZZ",
     format            = format.price,
     precision         = 2,
     overlay           = false,
     max_lines_count   = 500,
     max_labels_count  = 500
)

// ============================================================================
// INPUTS — CCI
// ============================================================================
length  = input.int   (20,    minval=1, title="CCI Length",      group="CCI Settings")
src     = input       (hlc3,            title="Source",           group="CCI Settings")
maType  = input.string("EMA",           title="Signal MA Type",   options=["SMA","EMA","WMA"], group="CCI Settings")
maLen   = input.int   (14,    minval=1, title="Signal MA Length", group="CCI Settings")

// ============================================================================
// INPUTS — CCI LEVELS
// ============================================================================
customOB    = input.int( 200, "Overbought Level", group="CCI Levels")
customOS    = input.int(-200, "Oversold Level",   group="CCI Levels")
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
// INPUTS — CCI+RSI FEATURES
// ============================================================================
showCCIDiv    = input.bool(true, "Show CCI+RSI Divergences", group="CCI+RSI Features")
showRSIDiv    = input.bool(true, "Show RSI Divergences",     group="CCI+RSI Features")
showStrength  = input.bool(true, "Show Trend Strength Bars", group="CCI+RSI Features")
showZeroCross = input.bool(true, "Show Zero Line Crosses",   group="CCI+RSI Features")
showExtremes  = input.bool(true, "Highlight Extreme Zones",  group="CCI+RSI Features")

// ============================================================================
// INPUTS — DIVERGENCE
// ============================================================================
divLookback  = input.int  (5,  "Divergence Lookback",      minval=1, maxval=20, group="Divergence Settings")
cciDivThresh = input.float(10, "CCI Divergence Threshold", minval=1, maxval=50, group="Divergence Settings")
rsiDivThresh = input.float(3,  "RSI Divergence Threshold", minval=1, maxval=20, group="Divergence Settings")

// ============================================================================
// INPUTS — MAIN ZIGZAG
// ============================================================================
showZZG       = input.bool  (true,                    "Show Swing ZigZag",       group="Main ZigZag")
zzgDepth      = input.int   (12,                      "Depth",      minval=1, maxval=500, group="Main ZigZag")
zzgDeviation  = input.int   (5,                       "Deviation",  minval=1, maxval=100, group="Main ZigZag")
zzgBackstep   = input.int   (2,                       "Backstep",   minval=1, maxval=50,  group="Main ZigZag")
zzgBullColor  = input.color (color.new(#00FF00, 0),   "Bull Color", group="Main ZigZag",  inline="c")
zzgBearColor  = input.color (color.new(#F23645, 0),   "Bear Color", group="Main ZigZag",  inline="c")
zzgWidth      = input.int   (2,                       "Line Width", group="Main ZigZag",  inline="w", minval=1, maxval=4)
zzgStyle      = input.string("⎯⎯⎯",                  "Line Style", group="Main ZigZag",  inline="w", options=["⎯⎯⎯","----","····"])
zzgShowLabels = input.bool  (true,                    "Show HH/HL/LH/LL Labels", group="Main ZigZag")
zzgLabelSize  = input.string(size.small,              "Label Size", group="Main ZigZag",  options=[size.tiny, size.small, size.normal])

// ============================================================================
// INPUTS — INTERNAL ZIGZAG
// ============================================================================
zzgShowInternal = input.bool  (false,                   "Show Internal ZigZag",  group="Internal ZigZag")
zzgiDepth       = input.int   (5,                       "Int Depth",    minval=1, maxval=500, group="Internal ZigZag")
zzgiDeviation   = input.int   (3,                       "Int Deviation",minval=1, maxval=100, group="Internal ZigZag")
zzgiBackstep    = input.int   (1,                       "Int Backstep", minval=1, maxval=50,  group="Internal ZigZag")
zzgiBullColor   = input.color (color.new(#00FF00, 0),   "Int Bull Color", group="Internal ZigZag", inline="ic")
zzgiBearColor   = input.color (color.new(#ff9800, 0),   "Int Bear Color", group="Internal ZigZag", inline="ic")
zzgiWidth       = input.int   (1,                       "Int Width",    group="Internal ZigZag", inline="iw", minval=1, maxval=4)
zzgiStyle       = input.string("----",                  "Int Style",    group="Internal ZigZag", inline="iw", options=["⎯⎯⎯","----","····"])

// ============================================================================
// HEIKIN ASHI
// ============================================================================
haClose  = (open + high + low + close) / 4.0
var float haOpen = na
haOpen  := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haBull   = haClose >= haOpen

// ============================================================================
// CCI CALCULATION
// ============================================================================
basis = ta.sma(src, length)
cci   = (src - basis) / (0.015 * ta.dev(src, length))

// ============================================================================
// RSI + NORMALIZE TO CCI SCALE
// ============================================================================
rsi     = ta.rsi(rsiSrc, rsiLength)
rsiNorm = rsiEnable ? (rsi - 50.0) / float(rsiOB - 50) * float(level100) : na

// ============================================================================
// BLENDED LINE
// ============================================================================
blended = rsiEnable and not na(rsiNorm) ? (cci + rsiNorm) / 2.0 : cci

// ============================================================================
// SIGNAL MA
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
// COLOR LOGIC
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

var color maColor = na
if haBull
    maColor := color.new(color.green, 0)
else
    maColor := color.new(color.red, 0)

// ============================================================================
// CCI+RSI DIVERGENCE (pivot-based on blended line)
// ============================================================================
blendPivHigh = ta.pivothigh(blended, divLookback, divLookback)
blendPivLow  = ta.pivotlow (blended, divLookback, divLookback)
priceHigh    = ta.pivothigh(high,    divLookback, divLookback)
priceLow     = ta.pivotlow (low,     divLookback, divLookback)

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

// RSI divergence
rsiPivHigh     = ta.pivothigh(rsi, divLookback, divLookback)
rsiPivLow      = ta.pivotlow (rsi, divLookback, divLookback)
rsiPivHighNorm = not na(rsiPivHigh) ? (rsiPivHigh - 50.0) / float(rsiOB - 50) * float(level100) : na
rsiPivLowNorm  = not na(rsiPivLow)  ? (rsiPivLow  - 50.0) / float(rsiOB - 50) * float(level100) : na

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
// PLOTS — CCI+RSI (2 lines)
// ============================================================================
plot(showStrength ? blended : na, "Strength",
     style=plot.style_histogram, color=histColor, linewidth=1)
plot(blended, "CCI+RSI",   color=blendColor, linewidth=3)
plot(blendMA, "Signal MA", color=maColor,    linewidth=2)

// ============================================================================
// HORIZONTAL LEVELS
// ============================================================================
hline(customOB,    "OB",   color=color.new(color.red,   30), linestyle=hline.style_dashed, linewidth=2)
h_up = hline(level100,    "+100", color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(0,           "Zero", color=color.new(color.gray,  30), linewidth=2)
h_dn = hline(levelNeg100, "-100", color=color.new(#787B86, 50), linestyle=hline.style_dashed)
hline(customOS,    "OS",   color=color.new(color.green, 30), linestyle=hline.style_dashed, linewidth=2)
fill(h_up, h_dn, color=color.new(#2196F3, 92), title="Normal Zone")

// ============================================================================
// BGCOLOR
// ============================================================================
bgcolor(showExtremes and strongBullish ? color.new(color.lime, 92) :
        showExtremes and strongBearish  ? color.new(color.red,  92) : na,
        title="Extreme Zone")

// ============================================================================
// LINE STYLE HELPER
// ============================================================================
zzg_lineStyle(string s) =>
    s == "----" ? line.style_dashed : s == "····" ? line.style_dotted : line.style_solid

// ============================================================================
// ATR FOR LABEL OFFSET
// ============================================================================
atrMeasure = ta.atr(200)

// ============================================================================
// MAIN ZIGZAG — drawn on price chart (overlay=false workaround via chart.point)
// Note: since overlay=false this ZigZag draws on the indicator pane.
// For price-overlay ZigZag add a second indicator script on the chart.
// ============================================================================
var line  zzg_line  = na
var label zzg_lbl   = na
var line  zzg_stem  = na
var int   zzg_dir   = 0
var float zzg_pivH  = na
var int   zzg_pivHT = na
var float zzg_pivL  = na
var int   zzg_pivLT = na
var float zzg_prevH = na
var float zzg_prevL = na
var int   zzg_flipB = 0

// Map price pivots to blended scale for drawing in indicator pane
// ZigZag drawn at blended value at pivot bars
zzg_hi = ta.highest(high, zzgDepth)
zzg_lo = ta.lowest (low,  zzgDepth)

// Track blended value at swing highs/lows for ZigZag on indicator pane
var float zzg_blendH = na
var float zzg_blendL = na

if showZZG
    _isH = high >= zzg_hi
    _isL = low  <= zzg_lo

    if zzg_dir == 0
        if _isH
            zzg_dir    := 1
            zzg_pivH   := high
            zzg_pivHT  := bar_index
            zzg_blendH := blended
            zzg_line   := line.new(bar_index, blended, bar_index, blended,
                 color=zzgBullColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            if zzgShowLabels
                line.delete(zzg_stem)
                zzg_stem := line.new(bar_index, blended, bar_index, blended + 30,
                     color=color.new(zzgBearColor, 40), style=line.style_dashed, width=1)
                zzg_lbl  := label.new(bar_index, blended + 30, "HH",
                     color=color.new(zzgBearColor, 20), textcolor=color.white,
                     style=label.style_none, size=zzgLabelSize)
        else if _isL
            zzg_dir    := -1
            zzg_pivL   := low
            zzg_pivLT  := bar_index
            zzg_blendL := blended
            zzg_line   := line.new(bar_index, blended, bar_index, blended,
                 color=zzgBearColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            if zzgShowLabels
                line.delete(zzg_stem)
                zzg_stem := line.new(bar_index, blended, bar_index, blended - 30,
                     color=color.new(zzgBullColor, 40), style=line.style_dashed, width=1)
                zzg_lbl  := label.new(bar_index, blended - 30, "LL",
                     color=color.new(zzgBullColor, 20), textcolor=color.white,
                     style=label.style_none, size=zzgLabelSize)

    else if zzg_dir == 1
        if _isH and (high > zzg_pivH or bar_index - zzg_flipB < zzgBackstep)
            zzg_pivH   := high
            zzg_pivHT  := bar_index
            zzg_blendH := blended
            line.set_xy2(zzg_line, bar_index, blended)
            if zzgShowLabels
                label.delete(zzg_lbl)
                line.delete(zzg_stem)
                zzg_stem := line.new(bar_index, blended, bar_index, blended + 30,
                     color=color.new(zzgBearColor, 40), style=line.style_dashed, width=1)
                zzg_lbl  := label.new(bar_index, blended + 30,
                     na(zzg_prevH) ? "HH" : (high >= zzg_prevH ? "HH" : "LH"),
                     color=color.new(zzgBearColor, 20), textcolor=color.white,
                     style=label.style_none, size=zzgLabelSize)
        else if _isL and bar_index - zzg_flipB >= zzgBackstep
            zzg_prevH  := zzg_pivH
            zzg_dir    := -1
            zzg_flipB  := bar_index
            zzg_pivL   := low
            zzg_pivLT  := bar_index
            zzg_line   := line.new(zzg_pivHT, zzg_blendH, bar_index, blended,
                 color=zzgBearColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            zzg_blendL := blended
            if zzgShowLabels
                line.delete(zzg_stem)
                zzg_stem := line.new(bar_index, blended, bar_index, blended - 30,
                     color=color.new(zzgBullColor, 40), style=line.style_dashed, width=1)
                zzg_lbl  := label.new(bar_index, blended - 30,
                     na(zzg_prevL) ? "LL" : (low <= zzg_prevL ? "LL" : "HL"),
                     color=color.new(zzgBullColor, 20), textcolor=color.white,
                     style=label.style_none, size=zzgLabelSize)

    else if zzg_dir == -1
        if _isL and (low < zzg_pivL or bar_index - zzg_flipB < zzgBackstep)
            zzg_pivL   := low
            zzg_pivLT  := bar_index
            zzg_blendL := blended
            line.set_xy2(zzg_line, bar_index, blended)
            if zzgShowLabels
                label.delete(zzg_lbl)
                line.delete(zzg_stem)
                zzg_stem := line.new(bar_index, blended, bar_index, blended - 30,
                     color=color.new(zzgBullColor, 40), style=line.style_dashed, width=1)
                zzg_lbl  := label.new(bar_index, blended - 30,
                     na(zzg_prevL) ? "LL" : (low <= zzg_prevL ? "LL" : "HL"),
                     color=color.new(zzgBullColor, 20), textcolor=color.white,
                     style=label.style_none, size=zzgLabelSize)
        else if _isH and bar_index - zzg_flipB >= zzgBackstep
            zzg_prevL  := zzg_pivL
            zzg_dir    := 1
            zzg_flipB  := bar_index
            zzg_pivH   := high
            zzg_pivHT  := bar_index
            zzg_line   := line.new(zzg_pivLT, zzg_blendL, bar_index, blended,
                 color=zzgBullColor, width=zzgWidth, style=zzg_lineStyle(zzgStyle))
            zzg_blendH := blended
            if zzgShowLabels
                line.delete(zzg_stem)
                zzg_stem := line.new(bar_index, blended, bar_index, blended + 30,
                     color=color.new(zzgBearColor, 40), style=line.style_dashed, width=1)
                zzg_lbl  := label.new(bar_index, blended + 30,
                     na(zzg_prevH) ? "HH" : (high >= zzg_prevH ? "HH" : "LH"),
                     color=color.new(zzgBearColor, 20), textcolor=color.white,
                     style=label.style_none, size=zzgLabelSize)

// ============================================================================
// INTERNAL ZIGZAG
// ============================================================================
var line  zzgi_line  = na
var label zzgi_lbl   = na
var line  zzgi_stem  = na
var int   zzgi_dir   = 0
var float zzgi_pivH  = na
var int   zzgi_pivHT = na
var float zzgi_pivL  = na
var int   zzgi_pivLT = na
var float zzgi_prevH = na
var float zzgi_prevL = na
var int   zzgi_flipB = 0
var float zzgi_blendH = na
var float zzgi_blendL = na

zzgi_hi = ta.highest(high, zzgiDepth)
zzgi_lo = ta.lowest (low,  zzgiDepth)

if showZZG and zzgShowInternal
    _iH = high >= zzgi_hi
    _iL = low  <= zzgi_lo

    if zzgi_dir == 0
        if _iH
            zzgi_dir    := 1
            zzgi_pivH   := high
            zzgi_pivHT  := bar_index
            zzgi_blendH := blended
            zzgi_line   := line.new(bar_index, blended, bar_index, blended,
                 color=zzgiBullColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                line.delete(zzgi_stem)
                zzgi_stem := line.new(bar_index, blended, bar_index, blended + 20,
                     color=color.new(zzgiBearColor, 40), style=line.style_dashed, width=1)
                zzgi_lbl  := label.new(bar_index, blended + 20, "HH",
                     color=color.new(zzgiBearColor, 20), textcolor=color.white,
                     style=label.style_none, size=size.tiny)
        else if _iL
            zzgi_dir    := -1
            zzgi_pivL   := low
            zzgi_pivLT  := bar_index
            zzgi_blendL := blended
            zzgi_line   := line.new(bar_index, blended, bar_index, blended,
                 color=zzgiBearColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                line.delete(zzgi_stem)
                zzgi_stem := line.new(bar_index, blended, bar_index, blended - 20,
                     color=color.new(zzgiBullColor, 40), style=line.style_dashed, width=1)
                zzgi_lbl  := label.new(bar_index, blended - 20, "LL",
                     color=color.new(zzgiBullColor, 20), textcolor=color.white,
                     style=label.style_none, size=size.tiny)

    else if zzgi_dir == 1
        if _iH and (high > zzgi_pivH or bar_index - zzgi_flipB < zzgiBackstep)
            zzgi_pivH   := high
            zzgi_pivHT  := bar_index
            zzgi_blendH := blended
            line.set_xy2(zzgi_line, bar_index, blended)
            if zzgShowLabels
                label.delete(zzgi_lbl)
                line.delete(zzgi_stem)
                zzgi_stem := line.new(bar_index, blended, bar_index, blended + 20,
                     color=color.new(zzgiBearColor, 40), style=line.style_dashed, width=1)
                zzgi_lbl  := label.new(bar_index, blended + 20,
                     na(zzgi_prevH) ? "HH" : (high >= zzgi_prevH ? "HH" : "LH"),
                     color=color.new(zzgiBearColor, 20), textcolor=color.white,
                     style=label.style_none, size=size.tiny)
        else if _iL and bar_index - zzgi_flipB >= zzgiBackstep
            zzgi_prevH  := zzgi_pivH
            zzgi_dir    := -1
            zzgi_flipB  := bar_index
            zzgi_pivL   := low
            zzgi_pivLT  := bar_index
            zzgi_blendL := blended
            zzgi_line   := line.new(zzgi_pivHT, zzgi_blendH, bar_index, blended,
                 color=zzgiBearColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                line.delete(zzgi_stem)
                zzgi_stem := line.new(bar_index, blended, bar_index, blended - 20,
                     color=color.new(zzgiBullColor, 40), style=line.style_dashed, width=1)
                zzgi_lbl  := label.new(bar_index, blended - 20,
                     na(zzgi_prevL) ? "LL" : (low <= zzgi_prevL ? "LL" : "HL"),
                     color=color.new(zzgiBullColor, 20), textcolor=color.white,
                     style=label.style_none, size=size.tiny)

    else if zzgi_dir == -1
        if _iL and (low < zzgi_pivL or bar_index - zzgi_flipB < zzgiBackstep)
            zzgi_pivL   := low
            zzgi_pivLT  := bar_index
            zzgi_blendL := blended
            line.set_xy2(zzgi_line, bar_index, blended)
            if zzgShowLabels
                label.delete(zzgi_lbl)
                line.delete(zzgi_stem)
                zzgi_stem := line.new(bar_index, blended, bar_index, blended - 20,
                     color=color.new(zzgiBullColor, 40), style=line.style_dashed, width=1)
                zzgi_lbl  := label.new(bar_index, blended - 20,
                     na(zzgi_prevL) ? "LL" : (low <= zzgi_prevL ? "LL" : "HL"),
                     color=color.new(zzgiBullColor, 20), textcolor=color.white,
                     style=label.style_none, size=size.tiny)
        else if _iH and bar_index - zzgi_flipB >= zzgiBackstep
            zzgi_prevL  := zzgi_pivL
            zzgi_dir    := 1
            zzgi_flipB  := bar_index
            zzgi_pivH   := high
            zzgi_pivHT  := bar_index
            zzgi_blendH := blended
            zzgi_line   := line.new(zzgi_pivLT, zzgi_blendL, bar_index, blended,
                 color=zzgiBullColor, width=zzgiWidth, style=zzg_lineStyle(zzgiStyle))
            if zzgShowLabels
                line.delete(zzgi_stem)
                zzgi_stem := line.new(bar_index, blended, bar_index, blended + 20,
                     color=color.new(zzgiBearColor, 40), style=line.style_dashed, width=1)
                zzgi_lbl  := label.new(bar_index, blended + 20,
                     na(zzgi_prevH) ? "HH" : (high >= zzgi_prevH ? "HH" : "LH"),
                     color=color.new(zzgiBearColor, 20), textcolor=color.white,
                     style=label.style_none, size=size.tiny)

// ============================================================================
// ALERTS — BLENDED
// ============================================================================
alertcondition(strongBullish,                        "Strong Bullish",     "CCI+RSI above +100 & above MA")
alertcondition(strongBearish,                        "Strong Bearish",     "CCI+RSI below -100 & below MA")
alertcondition(bullishCross,                         "Bullish Zero Cross", "CCI+RSI crossed above zero")
alertcondition(bearishCross,                         "Bearish Zero Cross", "CCI+RSI crossed below zero")
alertcondition(ta.crossover (blended, level100),     "Above +100",         "CCI+RSI crossed above +100")
alertcondition(ta.crossunder(blended, levelNeg100),  "Below -100",         "CCI+RSI crossed below -100")
alertcondition(ta.cross     (blended, customOB),     "Overbought",         "CCI+RSI hit overbought zone")
alertcondition(ta.cross     (customOS, blended),     "Oversold",           "CCI+RSI hit oversold zone")
alertcondition(ta.crossunder(blended, customOB),     "Exit Overbought",    "CCI+RSI exiting overbought")
alertcondition(ta.crossover (blended, customOS),     "Exit Oversold",      "CCI+RSI exiting oversold")

// ============================================================================
// ALERTS — RSI
// ============================================================================
alertcondition(rsiEnable and ta.crossover (rsi, rsiOB), "RSI Overbought",  "RSI crossed above overbought")
alertcondition(rsiEnable and ta.crossunder(rsi, rsiOS), "RSI Oversold",    "RSI crossed below oversold")
alertcondition(rsiEnable and ta.crossover (rsi, 50),    "RSI Bullish Mid", "RSI crossed above 50")
alertcondition(rsiEnable and ta.crossunder(rsi, 50),    "RSI Bearish Mid", "RSI crossed below 50")

// ============================================================================
// ALERTS — HEIKIN ASHI FLIP
// ============================================================================
alertcondition(haBull  and not haBull[1], "HA Turned Bullish", "Heikin Ashi flipped bullish — MA green")
alertcondition(not haBull and haBull[1],  "HA Turned Bearish", "Heikin Ashi flipped bearish — MA red")

// ============================================================================
// ALERTS — ZIGZAG STRUCTURE
// ============================================================================
alertcondition(showZZG and zzg_dir == 1 and zzg_dir[1] != 1, "ZZ Swing High", "ZigZag swung to new High")
alertcondition(showZZG and zzg_dir == -1 and zzg_dir[1] != -1, "ZZ Swing Low",  "ZigZag swung to new Low")
````
