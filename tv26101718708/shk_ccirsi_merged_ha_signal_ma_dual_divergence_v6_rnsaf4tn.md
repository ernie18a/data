# SHK CCI+RSI Merged | HA Signal MA | Dual Divergence | v6

- url: https://www.tradingview.com/script/rnsaf4Tn-SHK-CCI-RSI-Merged-HA-Signal-MA-Dual-Divergence-v6/
- type: indicator
- pine_id: PUB;6e71389d37a5418fba4e3d2c97c9a458
- version: 1.0

## Description

// ============================================================================
// DISCLAIMER: This script is for educational purposes only.
// The author is NOT responsible for any trading losses.
// Past performance does not guarantee future results.
// Trade entirely at your own risk.
// ============================================================================
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


🔷 SHK CCI+RSI MERGED — CLEAN 2-LINE OSCILLATOR
       Powered by Pine Script v6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Stop cluttering your chart with two separate oscillators.
This indicator fuses CCI and RSI into ONE intelligent 
blended line — giving you stronger, more reliable signals 
with less noise.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📐 HOW THE BLEND WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RSI is first normalized onto the CCI scale:

  • RSI 50  →    0  (neutral / zero line)
  • RSI 70  →  +100 (overbought boundary)
  • RSI 30  →  -100 (oversold boundary)

Then both are averaged into one line:
  ➤ Blended = ( CCI + Normalized RSI ) / 2

The ±100 and ±200 levels now represent overbought 
and oversold zones for BOTH indicators at once.
If RSI is disabled, the line falls back to pure CCI.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 WHAT YOU SEE — ONLY 2 LINES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

● LINE 1 — CCI+RSI Blended (thick)
  Color changes dynamically based on position 
  relative to the Signal MA and zero line:

  🟢 Bright Green  → above MA + above zero  (strong bull)
  🟢 Faded Green   → above MA + below zero  (weak bull)
  🔴 Bright Red    → below MA + below zero  (strong bear)
  🔴 Faded Red     → below MA + above zero  (weak bear)

● LINE 2 — Signal MA (EMA / SMA / WMA)
  Colored by Heikin Ashi candle direction:

  🟢 Green MA → HA candle is bullish (trend rising)
  🔴 Red MA   → HA candle is bearish (trend falling)

  The MA color flip is your early trend change warning —
  before price confirms the move.

● HISTOGRAM — Strength Bars
  Displayed behind the lines. Brighter color = deeper 
  into overbought / oversold territory.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📉 DUAL DIVERGENCE ENGINE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Two independent divergence detectors run simultaneously:

🟩 CCI+RSI Divergence  (solid lines)
  Pivot-based detection on the blended oscillator vs price:
  • Lime solid line  + "Bull Div"  → Bullish divergence
  • Red  solid line  + "Bear Div"  → Bearish divergence

🟦 RSI-Only Divergence  (dashed lines)
  Detected on raw RSI pivots, plotted at normalized scale:
  • Aqua   dashed + "RSI Bull Div" → RSI bullish divergence
  • Orange dashed + "RSI Bear Div" → RSI bearish divergence

Both engines use adjustable lookback and threshold 
settings so you can tune sensitivity to your style.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ ZERO LINE CROSSES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔼 Green triangle at bottom → crossed above zero (bull)
  🔽 Red   triangle at top    → crossed below zero (bear)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎨 EXTREME ZONE BACKGROUND
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Background shading activates when blended is in 
an extreme zone (beyond ±100 and above/below MA):

  🟢 Green background → strong bullish pressure
  🔴 Red   background → strong bearish pressure

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔔 BUILT-IN ALERTS (14 CONDITIONS)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Strong Bullish signal (blended > +100 & above MA)
  ✅ Strong Bearish signal (blended < -100 & below MA)
  ✅ Zero line cross — bullish & bearish
  ✅ CCI+RSI crossed above +100
  ✅ CCI+RSI crossed below -100
  ✅ Overbought zone entry & exit
  ✅ Oversold zone entry & exit
  ✅ RSI crossed overbought / oversold
  ✅ RSI crossed above / below midline (50)
  ✅ Heikin Ashi flipped bullish (MA turns green)
  ✅ Heikin Ashi flipped bearish (MA turns red)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️ SETTINGS & CUSTOMIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  CCI Settings
  • Length (default 20), Source (default HLC3)
  • Signal MA type: EMA / SMA / WMA
  • Signal MA length (default 14)

  CCI Levels
  • Overbought: +200  |  Oversold: -200
  • Upper level: +100  |  Lower level: -100

  RSI Settings
  • Enable / disable RSI blend
  • Length (default 14), Source (default Close)
  • OB / OS levels (default 70 / 30)

  Features (each individually toggleable)
  • CCI+RSI divergence lines
  • RSI-only divergence lines
  • Trend strength histogram
  • Zero line cross markers
  • Extreme zone background shading

  Divergence Settings
  • Lookback bars (1–20)
  • CCI divergence threshold
  • RSI divergence threshold

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 WORKS BEST WITH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  • Key support and resistance levels on price chart
  • VWAP or Volume Profile for confluence
  • Higher timeframe trend bias confirmation
  • All markets: Equities, Futures, Forex, Crypto, Commodities
  • All timeframes: Scalping to Swing trading

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

The creator — SHK — is NOT responsible for any trading
losses, damages or financial consequences resulting
from the use or misuse of this indicator.

All trading decisions are SOLELY YOUR OWN RESPONSIBILITY.
You agree to trade entirely at YOUR OWN RISK.

Always conduct your own due diligence and consult a
qualified financial advisor before making any trading
or investment decisions.

By using this indicator you acknowledge and fully accept
all risks and release the author from any liability.

📌 TRADE SMART. MANAGE YOUR RISK. PROTECT YOUR CAPITAL.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Source Code

````pine
//@version=6
// ============================================================================
// SHK CCI+RSI Merged — 2 Line Edition
// Signal MA colored by Heikin Ashi candle direction
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
// HEIKIN ASHI CALCULATION
// ============================================================================
haClose = (open + high + low + close) / 4.0
var float haOpen = na
haOpen := na(haOpen[1]) ? (open + close) / 2.0 : (haOpen[1] + haClose[1]) / 2.0
haHigh  = math.max(high, math.max(haOpen, haClose))
haLow   = math.min(low,  math.min(haOpen, haClose))

// HA direction: bullish = haClose >= haOpen
haBull = haClose >= haOpen

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
// COLOR LOGIC
// ============================================================================

// Blended line — color by position vs MA and zero
var color blendColor = na
if blended >= blendMA and blended > 0
    blendColor := color.new(color.lime, 0)
else if blended >= blendMA and blended <= 0
    blendColor := color.new(color.lime, 50)
else if blended < blendMA and blended < 0
    blendColor := color.new(color.red, 0)
else
    blendColor := color.new(color.red, 50)

// Histogram — color by zone
var color histColor = na
if blended > 0
    histColor := blended > level100 ? color.new(color.lime, 30) : color.new(color.lime, 70)
else
    histColor := blended < levelNeg100 ? color.new(color.red, 30) : color.new(color.red, 70)

// Signal MA — color by Heikin Ashi direction
// Bullish HA candle  → bright green MA
// Bearish HA candle  → bright red MA
// Neutral transition → use previous color (handled by var persistence)
var color maColor = na
if haBull
    maColor := color.new(color.green, 0)
else
    maColor := color.new(color.red, 0)

// ============================================================================
// PIVOTS
// ============================================================================
blendPivHigh = ta.pivothigh(blended, divLookback, divLookback)
blendPivLow  = ta.pivotlow (blended, divLookback, divLookback)
priceHigh    = ta.pivothigh(high,    divLookback, divLookback)
priceLow     = ta.pivotlow (low,     divLookback, divLookback)

rsiPivHigh     = ta.pivothigh(rsi, divLookback, divLookback)
rsiPivLow      = ta.pivotlow (rsi, divLookback, divLookback)
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
// RSI DIVERGENCE
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

plot(blended, "CCI+RSI",   color=blendColor,  linewidth=3)
plot(blendMA, "Signal MA", color=maColor,      linewidth=2)

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
// BGCOLOR — EXTREME ZONES
// ============================================================================
bgcolor(showExtremes and strongBullish ? color.new(color.lime, 92) :
        showExtremes and strongBearish  ? color.new(color.red,  92) : na,
        title="Extreme Zone")

// ============================================================================
// ALERTS — BLENDED LINE
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
alertcondition(haBull  and not haBull[1],  "HA Turned Bullish", "Heikin Ashi flipped bullish — MA green")
alertcondition(not haBull and haBull[1],   "HA Turned Bearish", "Heikin Ashi flipped bearish — MA red")
````
