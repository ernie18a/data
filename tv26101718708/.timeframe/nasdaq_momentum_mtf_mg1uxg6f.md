# NASDAQ Momentum MTF

- url: https://www.tradingview.com/script/MG1uXg6f/
- type: indicator
- pine_id: PUB;626bd1b4074348dbb47dfb3aceb19018
- version: 1.0

## Description

NASDAQ Momentum MTF is a multi-timeframe momentum indicator designed to visualize market pressure, trend strength, and momentum alignment across different timeframes in a clear and intuitive way.

It combines a classic EMA-based momentum calculation with higher timeframe projections to help traders identify high-probability trend continuation and reversal zones.

⚙️ Core Features
Multi-Timeframe Momentum (MTF)
Native chart momentum
Automatic higher timeframe projections (×5 and ×15)
No manual timeframe selection required
Dynamic HTF Histogram (×5)
Strength-based color intensity
Adaptive transparency (strong moves = more visible)
Enhanced readability of momentum expansion vs. contraction
Momentum & Signal Lines
EMA-based momentum line
Signal smoothing for cleaner trend structure
Directional color change for instant trend recognition
Dominance Scaling
Internal normalization aligns chart momentum with HTF strength
Helps detect when higher timeframe pressure dominates
Adaptive Overbought / Oversold Levels
Dynamically calculated based on current market conditions
Expands and contracts with volatility
🎯 How to Use
Trend Confirmation
When HTF ×5 histogram expands strongly → trend is accelerating
Align entries with the dominant direction
Momentum Shifts
Weakening histogram + flattening momentum → potential slowdown
Watch for reversals or pullbacks
Multi-Timeframe Alignment
Best setups occur when:
Chart momentum
HTF ×5
HTF ×15
are all pointing in the same direction
Exhaustion Detection
Extreme histogram expansion often signals late-stage moves
Combine with structure or key levels
🔧 Notes
Designed for fast markets like NASDAQ (US100) but works on any asset
Especially effective on lower timeframes (M1–M15)
No repainting (uses request.security with lookahead off)
🚀 Summary

This indicator helps you see momentum like institutional flow:

Clear trend direction
Real-time strength visualization
Multi-timeframe confirmation
Cleaner entries, fewer false signals

## Source Code

````pine
//@version=6
indicator("NASDAQ Momentum MTF", overlay=false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━
group_mom = "Momentum Settings"
fastLen   = input.int(12, "Fast Length", group=group_mom)
slowLen   = input.int(26, "Slow Length", group=group_mom)
momSmooth = input.int(2,  "Momentum Smooth", group=group_mom)
sigLen    = input.int(5,  "Signal Length", group=group_mom)

group_dom = "Dominance Settings"
dominanceStrength = input.float(1.25, "Chart Dominance Strength", step=0.1, group=group_dom)

// OB/OS
group_obos = "OB/OS Settings"
showOBOS = input.bool(true, "Show OB/OS Levels", group=group_obos)
lenOBOS  = input.int(50, "OB/OS Length", group=group_obos)
multOB   = input.float(1.5, "OB Multiplier", group=group_obos)

// 🔥 Histogram Farben
group_hist = "HTF ×5 Histogram Colors"
bullBaseColor = input.color(color.rgb(0, 150, 0), "Bull Color", group=group_hist)
bearBaseColor = input.color(color.rgb(150, 0, 0), "Bear Color", group=group_hist)

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━
neonGreen = color.rgb(0, 255, 0)
neonRed   = color.rgb(255, 0, 0)

chartSignalColor = input.color(color.yellow, "Chart Signal")
htf5SignalColor  = input.color(color.blue,   "HTF ×5 Signal")
htf15SignalColor = input.color(color.purple, "HTF ×15 Signal")

htf5LineColor  = input.color(color.aqua,   "HTF ×5 Line")
htf15LineColor = input.color(color.orange, "HTF ×15 Line")

zeroLineColor  = input.color(color.gray, "Zero Line")

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHART CALCULATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

momentum = ta.ema(emaFast - emaSlow, momSmooth)
signal   = ta.ema(momentum, sigLen)
hist     = momentum - signal

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// HTF AUTO MULTIPLIER
//━━━━━━━━━━━━━━━━━━━━━━━━━━
curSec = timeframe.in_seconds()
tf5  = str.tostring(math.round((curSec * 5)  / 60))
tf15 = str.tostring(math.round((curSec * 15) / 60))

// HTF ×5
momentum5 = request.security(syminfo.tickerid, tf5,
     ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), momSmooth),
     barmerge.gaps_off, barmerge.lookahead_off)

signal5 = request.security(syminfo.tickerid, tf5,
     ta.ema(ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), momSmooth), sigLen),
     barmerge.gaps_off, barmerge.lookahead_off)

hist5 = momentum5 - signal5

// HTF ×15
momentum15 = request.security(syminfo.tickerid, tf15,
     ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), momSmooth),
     barmerge.gaps_off, barmerge.lookahead_off)

signal15 = request.security(syminfo.tickerid, tf15,
     ta.ema(ta.ema(ta.ema(close, fastLen) - ta.ema(close, slowLen), momSmooth), sigLen),
     barmerge.gaps_off, barmerge.lookahead_off)

hist15 = momentum15 - signal15

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// DOMINANCE (intern)
//━━━━━━━━━━━━━━━━━━━━━━━━━━
absChart  = math.abs(hist)
absHTF5   = math.abs(hist5)
absHTF15  = math.abs(hist15)

maxHTF = math.max(absHTF5, absHTF15)
scaleFactor = absChart != 0 ? maxHTF / absChart : 1.0
chartDominantHist = hist * scaleFactor * dominanceStrength

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// 🎯 COLOR FIX + DYNAMIC TRANSPARENCY
//━━━━━━━━━━━━━━━━━━━━━━━━━━
base = ta.ema(math.abs(hist5), 20)
strengthRaw = base != 0 ? math.abs(hist5) / base : 0.0
strength = math.min(strengthRaw, 3.0)

intensity = math.pow(strength, 1.4)
scale = math.min(intensity, 1.0)

// RGB extrahieren
rBull = color.r(bullBaseColor)
gBull = color.g(bullBaseColor)
bBull = color.b(bullBaseColor)

rBear = color.r(bearBaseColor)
gBear = color.g(bearBaseColor)
bBear = color.b(bearBaseColor)

// Transparenz holen
tBull = color.t(bullBaseColor)
tBear = color.t(bearBaseColor)

// Dynamik → starke Moves = weniger transparent
transpBoost = math.min(int(strength * 40), 100)

// finale Transparenz
finalTranspBull = math.max(tBull - transpBoost, 0)
finalTranspBear = math.max(tBear - transpBoost, 0)

// finale Farben
bullColor = color.rgb(
     int(rBull * scale),
     int(gBull * scale),
     int(bBull * scale),
     finalTranspBull
)

bearColor = color.rgb(
     int(rBear * scale),
     int(gBear * scale),
     int(bBear * scale),
     finalTranspBear
)

hist5ColorDynamic = hist5 >= 0 ? bullColor : bearColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCALING (HTF ×5)
//━━━━━━━━━━━━━━━━━━━━━━━━━━
base5 = ta.ema(math.abs(hist5), 20)
scale5 = base5 != 0 ? 1 + math.pow(math.abs(hist5) / base5, 1.3) : 1
scale5 := math.min(scale5, 5.0)

hist5Scaled = hist5 * scale5

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE OB / OS
//━━━━━━━━━━━━━━━━━━━━━━━━━━
baseOB = ta.ema(math.abs(momentum), lenOBOS)
obLevel = baseOB * multOB
osLevel = -baseOB * multOB

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLOR LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━
chartLineColor = momentum > momentum[1] ? neonGreen : neonRed

//━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━

// versteckt
plot(chartDominantHist, style=plot.style_columns, color=color.gray, linewidth=1, display=display.none)

// HTF ×5 Histogram
plot(hist5Scaled,
     title="HTF ×5 Histogram",
     style=plot.style_columns,
     color=hist5ColorDynamic,
     linewidth=1)

// versteckt
plot(hist15, style=plot.style_columns, color=color.gray, linewidth=1, display=display.none)

// Linien
plot(momentum,  title="Chart Momentum", color=chartLineColor, linewidth=1)
plot(signal,    title="Chart Signal",   color=chartSignalColor, linewidth=1)

plot(momentum5, title="HTF ×5 Momentum", color=htf5LineColor, linewidth=1)
plot(signal5,   title="HTF ×5 Signal",   color=htf5SignalColor, linewidth=1)

plot(momentum15, title="HTF ×15 Momentum", color=htf15LineColor, linewidth=1)
plot(signal15,   title="HTF ×15 Signal",   color=htf15SignalColor, linewidth=1)

// OB/OS
plot(showOBOS ? obLevel : na, "Overbought", color=color.red, linewidth=1)
plot(showOBOS ? osLevel : na, "Oversold",  color=color.green, linewidth=1)

// Zero
hline(0, "Zero Line", color=zeroLineColor)
````
