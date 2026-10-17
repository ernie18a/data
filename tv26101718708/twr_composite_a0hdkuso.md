# TWR Composite

- url: https://www.tradingview.com/script/A0hdkuSo-TWR-Composite/
- type: indicator
- pine_id: PUB;ff2df26462594af9b088469d5735856b
- version: 1.0

## Description

Smart move publishing it open-source — let people build their own signals on top of a clean base.
Here's the description, then tags, then a few publishing tips.

Description
TWR Composite — Weighted Momentum Oscillator with Gradient Midline Fill
TWR Composite blends six classical momentum measures into a single normalized oscillator: RSI, CCI, OBV-momentum, Stochastic %K, MFI, and the Awesome Oscillator. Each component is individually weighted (all adjustable) and normalized to a common 0–1 range, then lightly smoothed. The result is one line that summarizes momentum across several independent lenses instead of forcing you to read multiple panes.
Component handling
Each input is normalized so the composite stays bounded between 0 and 1, regardless of asset or timeframe:

RSI, Stochastic %K, and MFI are divided by 100.
CCI (which is unbounded) is soft-clipped via a tanh function. The clip scale is configurable.
OBV is cumulative by nature, so the indicator normalizes its N-bar change over a rolling 100-bar range rather than the raw cumulative value.
The Awesome Oscillator is also normalized against its rolling 100-bar range.

The six normalized components are combined using your weights, then smoothed with a short SMA to filter single-bar noise. Set any weight to zero to remove that component entirely.
Visualization
The composite plots with a gradient fill anchored between the line and the 0.5 midline — opaque at the line, fading toward the midline. The hue flips automatically: green when the composite is above 0.5, red when below. Configurable overbought and oversold levels (default 0.8 / 0.2) are drawn as dotted reference lines, with optional background shading when the composite enters those zones.
Optional layers (default off)

Fib levels on price: an ATR-trailing stop tracks the prevailing swing, and three retracement levels (61.8 / 78.6 / 88.6 by default) are projected from the swing extreme back toward the trail. Useful as confluence reference points with the composite.
Regime line: an SMA of the composite itself, drawn alongside a configurable reference line, to give you a slower read on overall momentum bias.

What this is and isn't
This is a visualization tool. It does not generate buy/sell signals, does not have alerts, and does not claim any edge. It's a clean way to see multi-component momentum on one line, with the visual contrast strong enough to read at a glance. Use it as a building block — pair it with your own entries, divergence detection, signal logic, or whatever fits your system.
The code is open. Fork it, modify it, build signals on top of it.

works very well with the Precision Pulse 8 indicator

Disclaimer:
This indicator is provided for educational and informational purposes only. It is a visualization of mathematical relationships between common momentum components — nothing more. It does not constitute financial, investment, or trading advice, and no part of it should be interpreted as a recommendation to buy, sell, or hold any asset.Past behavior of any indicator is not indicative of future results. Trading and investing carry substantial risk, including the risk of total loss. You alone are responsible for your decisions, your risk management, and any outcomes. Always do your own research and consult a licensed professional before acting on any market information.By using this script you acknowledge that the author makes no representation or warranty regarding its accuracy, completeness, or fitness for any particular purpose, and accepts no liability for any losses or damages arising from its use.



good luck trading.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator("TWR Composite", overlay=false, max_labels_count=500, max_lines_count=500)

// =============================================================================
// TWR Composite
// -----------------------------------------------------------------------------
// Weighted composite momentum oscillator combining RSI, CCI, OBV-momentum,
// Stochastic %K, MFI, and Awesome Oscillator. Each component is normalized
// to [0,1] and blended via user-set weights, then lightly smoothed.
//
// Rendered with a midline-anchored gradient fill (green above 0.5, red below)
// and configurable overbought/oversold zones with background shading.
//
// Optional visual layers (default off):
//   - Fib levels on price: ATR-trail-based retracements (61.8/78.6/88.6)
//   - Regime line: SMA of the composite with a reference midline
//
// This is a visualization tool. It produces no buy/sell signals and no alerts.
// =============================================================================

// === Inputs: composite weights ===========================================
g_w = "Composite Weights"
rsiWeight    = input.float(1.0, "RSI weight",      group=g_w)
cciWeight    = input.float(1.0, "CCI weight",      group=g_w)
obvWeight    = input.float(1.0, "OBV weight",      group=g_w)
stochKWeight = input.float(1.0, "Stoch %K weight", group=g_w)
mfiWeight    = input.float(1.0, "MFI weight",      group=g_w)
aoWeight     = input.float(1.0, "AO weight",       group=g_w)

// === Inputs: composite normalization =====================================
g_n = "Composite Normalization"
cciScale          = input.float(150.0, "CCI tanh scale", step=10, group=g_n,
     tooltip="CCI is unbounded; tanh soft-clips it. Larger scale = gentler clip.")
obvMomentumLength = input.int  (14, "OBV momentum length", minval=1, group=g_n,
     tooltip="OBV is cumulative; we normalize its N-bar change instead of the raw cum.")
oversoldLevel     = input.float(0.2, "Oversold level",   step=0.05, group=g_n)
overboughtLevel   = input.float(0.8, "Overbought level", step=0.05, group=g_n)

// === Inputs: optional fib display ========================================
g_f = "Fib Levels on Price (Optional)"
fibEnabled    = input.bool(false, "Show fib levels on price chart", group=g_f)
atrPeriod     = input.int  (28,   "ATR period",                     minval=1, group=g_f)
atrFactor     = input.float(5.0,  "ATR factor",                     minval=0.1, group=g_f)
fibLevel1     = input.float(61.8, "Fib level 1",   minval=10, maxval=100, step=0.1, group=g_f)
fibLevel2     = input.float(78.6, "Fib level 2",   minval=10, maxval=100, step=0.1, group=g_f)
fibLevel3     = input.float(88.6, "Fib level 3",   minval=10, maxval=100, step=0.1, group=g_f)

// === Inputs: optional regime line ========================================
g_r = "Regime Line (Optional)"
regimeEnabled = input.bool (false, "Show composite-SMA regime line", group=g_r)
regimeLength  = input.int  (20,    "Composite-SMA length", minval=1, group=g_r)
regimeMid     = input.float(0.5,   "Regime reference line", step=0.05, group=g_r)

// === Inputs: display =====================================================
g_disp = "Display"
showLine  = input.bool(true,        "Show composite line",             group=g_disp)
showFill  = input.bool(true,        "Shade overbought / oversold zones", group=g_disp)
lineColor = input.color(color.blue, "Default line color",              group=g_disp)

// === Inputs: midline fill ================================================
g_mf = "Midline Fill"
mfEnabled = input.bool (true,         "Enable midline fill", group=g_mf,
     tooltip="Gradient fill between the composite line and the 0.5 midline. Green above, red below, opaque at the line and fading toward the midline.")
mfBullCol = input.color(color.green,  "Above-mid color", group=g_mf, inline="mf")
mfBearCol = input.color(color.red,    "Below-mid color", group=g_mf, inline="mf")

// =============================================================================
// COMPOSITE CALCULATION
// =============================================================================
normalize(val, minval, maxval) =>
    maxval == minval ? 0.5 : (val - minval) / (maxval - minval)

rsiValue    = ta.rsi(close, 14)
cciValue    = ta.cci(close, 20)
obvValue    = ta.cum(volume * (close > close[1] ? 1 : close < close[1] ? -1 : 0))
obvMomentum = ta.change(obvValue, obvMomentumLength)
stochK      = ta.stoch(close, high, low, 14)
mfiValue    = ta.mfi(hlc3, 14)
aoValue     = ta.sma(hl2, 5) - ta.sma(hl2, 34)

loObv = ta.lowest(obvMomentum, 100)
hiObv = ta.highest(obvMomentum, 100)
loAo  = ta.lowest(aoValue, 100)
hiAo  = ta.highest(aoValue, 100)

normRsi    = rsiValue / 100.0
normStochK = stochK   / 100.0
normMfi    = mfiValue / 100.0
normObv    = math.max(0, math.min(1, normalize(obvMomentum, loObv, hiObv)))
normAo     = math.max(0, math.min(1, normalize(aoValue,     loAo,  hiAo)))

// CCI: tanh soft-clip — math.tanh is absent in Pine v6, so inline via math.exp.
cciScaled = math.max(-10, math.min(10, cciValue / cciScale))
expPos    = math.exp(cciScaled)
expNeg    = math.exp(-cciScaled)
tanhCci   = (expPos - expNeg) / (expPos + expNeg)
normCci   = (tanhCci + 1) / 2

totalWeight = rsiWeight + cciWeight + obvWeight + stochKWeight + mfiWeight + aoWeight
combined    = (normRsi*rsiWeight + normCci*cciWeight + normObv*obvWeight + normStochK*stochKWeight + normMfi*mfiWeight + normAo*aoWeight) / totalWeight
twr         = ta.sma(combined, 3)

// =============================================================================
// OPTIONAL: ATR TRAIL + FIB LEVELS (display only)
// =============================================================================
trAlt    = math.max(high - low, math.abs(high - close[1]), math.abs(low - close[1]))
atrV     = ta.rma(trAlt, atrPeriod)
loss     = atrFactor * atrV
upLine   = close - loss
dnLine   = close + loss

var float trendUp  = na
var float trendDn  = na
var int   trendDir = 1
var float fibEx    = na

trendUp := na(trendUp[1]) ? upLine : (close[1] > trendUp[1] ? math.max(upLine, trendUp[1]) : upLine)
trendDn := na(trendDn[1]) ? dnLine : (close[1] < trendDn[1] ? math.min(dnLine, trendDn[1]) : dnLine)

newDir   = close > trendDn[1] ? 1 : close < trendUp[1] ? -1 : nz(trendDir[1], 1)
flipped  = not na(trendDir[1]) and newDir != trendDir[1]
trendDir := newDir

fibEx := flipped and newDir ==  1 ? high : flipped and newDir == -1 ? low : newDir == 1 ? math.max(nz(fibEx[1], high), high) : math.min(nz(fibEx[1], low), low)

trail = trendDir == 1 ? trendUp : trendDn
f1    = fibEx + (trail - fibEx) * fibLevel1 / 100
f2    = fibEx + (trail - fibEx) * fibLevel2 / 100
f3    = fibEx + (trail - fibEx) * fibLevel3 / 100

// =============================================================================
// OPTIONAL: REGIME SMA (display only)
// =============================================================================
twrSma = ta.sma(twr, regimeLength)

// =============================================================================
// PLOTTING
// =============================================================================
plotColor = twr > overboughtLevel ? color.red : twr < oversoldLevel ? color.green : lineColor
twrPlot   = plot(showLine ? twr : na, color=plotColor, linewidth=2, title="TWR")

// Midline fill: opaque at the composite line, transparent at the 0.5 midline.
// top_color binds positionally to top_value (0.5, the midline); bottom_color to
// bottom_value (twr, the line). Midline slot = transparent (100), line slot = opaque (50),
// hue switches on twr vs 0.5.
midPlot = plot(mfEnabled ? 0.5 : na, "Midline", color=color.new(chart.fg_color, 70), style=plot.style_linebr)
mfHue   = twr > 0.5 ? mfBullCol : mfBearCol
fill(midPlot, twrPlot, 0.5, twr,
     color.new(mfHue, 100),
     color.new(mfHue, 50))

// Optional regime SMA in the pane
plot(regimeEnabled ? twrSma    : na, "Regime SMA",      color=color.new(color.orange, 20), linewidth=1)
plot(regimeEnabled ? regimeMid : na, "Regime midline",  color=color.new(color.orange, 70), linewidth=1, style=plot.style_linebr)

// Reference lines
hline(1, color=color.gray, linestyle=hline.style_solid)
hline(0, color=color.gray, linestyle=hline.style_solid)
hline(overboughtLevel, color=color.red,   linestyle=hline.style_dotted)
hline(oversoldLevel,   color=color.green, linestyle=hline.style_dotted)

bgcolor(showFill and twr > overboughtLevel ? color.new(color.red, 90) : showFill and twr < oversoldLevel ? color.new(color.green, 90) : na)

// Optional fib levels on price
plot(fibEnabled ? f1    : na, "Fib 1", color=color.new(color.gray, 30),   linewidth=1, force_overlay=true)
plot(fibEnabled ? f2    : na, "Fib 2", color=color.new(color.gray, 40),   linewidth=1, force_overlay=true)
plot(fibEnabled ? f3    : na, "Fib 3", color=color.new(color.gray, 50),   linewidth=1, force_overlay=true)
plot(fibEnabled ? trail : na, "Trail", color=color.new(color.orange, 30), linewidth=1, force_overlay=true)
````
