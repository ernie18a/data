# Z-Score Mean Reversion

- url: https://www.tradingview.com/script/4BN6styq-Z-Score-Mean-Reversion/
- type: indicator
- pine_id: PUB;ffb81b9915d041fd878ec13397f40b0d
- version: 1.0

## Description

Plaots mean reversion Z score & Standad deviations

## Source Code

````pine
//@version=6
indicator("Z-Score Mean Reversion",
     overlay=false, max_bars_back=5000)

//========================
// Inputs
//========================
src      = input.source(close, "Price Source")
lenMean  = input.int(90,  "Mean Length", minval=2)
meanType = input.string("EMA", "Mean Type", options=["EMA","SMA"])
volType  = input.string("EWMA", "Volatility Type", options=["STD","EWMA"])
hl       = input.int(20,  "EWMA Half-Life (bars)", minval=2)
zSmooth  = input.int(3,   "Z-Score Smoothing (EMA)", minval=1)

// EMA gate (visual context)
useGate  = input.bool(true, "Show EMA Gate Shading?")
shortLen = input.int(13, "EMA Short (Gate)", minval=1)
longLen  = input.int(23, "EMA Long (Gate)",  minval=1)

// Mean Reversion base & curve
mrMode   = input.string("Z-Score", "MR Mode", options=["Z-Score","Raw Dev"],
           tooltip="Z-Score = (price-MA)/stdev; Raw Dev = (price-MA)/MA (wider bandwidth).")

curve    = input.string("tanh", "MR Curve",
           options=["tanh","atan","softsign","linear-clip"],
           tooltip="Nonlinear mapping to ±1. atan/softsign give wider wings than tanh; linear-clip clamps to ±1.")

mrScale  = input.float(1.0, "MR Pre-Curve Gain", minval=0.1, maxval=5, step=0.1,
           tooltip="Multiplicative gain before curve (affects how often the MR reaches extremes).")

mrSmooth = input.int(1, "MR Smoothing (EMA)", minval=1)

// OB/OS in curve units (±1 range for all choices)
obLvl    = input.float( 0.80, "MR Overbought (curve units)", minval=0.50, maxval=0.99)
osLvl    = input.float(-0.80, "MR Oversold  (curve units)",  minval=-0.99, maxval=-0.50)

// Z waves visibility
showZWaves = input.bool(true, "Show Z-Score Waves?")

// Dot trigger mode (IA-like)
dotMode  = input.string("ReversalOut", "Dot Trigger",
          options = ["ReversalOut","SlopeFlipInside"],
          tooltip = "ReversalOut = dot when MR crosses back out of OB/OS. SlopeFlipInside = dot when slope flips while still inside.")

// Optional Z thresholds for alerts
zBuyLvl  = input.float(-1.5, "Z Long Threshold (σ)")
zSellLvl = input.float( 1.5, "Z Short Threshold (σ)")

//========================
// Helpers
//========================
// tanh (Pine has no math.tanh)
f_tanh(x) =>
    num = math.exp(2 * x) - 1
    den = math.exp(2 * x) + 1
    num / den  // −1..+1

f_atan(x)     => (2 / math.pi) * math.atan(x)            // −1..+1
f_softsign(x) => x / (1 + math.abs(x))                   // −1..+1
f_clip(x)     => math.max(-1.0, math.min(1.0, x))        // −1..+1

// Pick curve
f_shape(x, curve) =>
    curve == "tanh"       ? f_tanh(x)     : curve == "atan"       ? f_atan(x)     : curve == "softsign"   ? f_softsign(x) : f_clip(x)

// Safe divide
f_safediv(a, b) => a / (b == 0.0 ? 1e-12 : b)

//========================
// Mean + Volatility
//========================
ma = meanType == "EMA" ? ta.ema(src, lenMean) : ta.sma(src, lenMean)

// EWMA variance/std (if chosen)
var float ewmaMean = na
var float ewmaVar  = na
alpha = 1.0 - math.exp(-math.log(2) / hl)

ewmaMean := na(ewmaMean) ? src : ewmaMean + alpha * (src - ewmaMean)
devEW    = src - ewmaMean
ewmaVar  := na(ewmaVar) ? devEW * devEW : (1 - alpha) * ewmaVar + alpha * devEW * devEW
ewmaStd  = math.sqrt(math.max(ewmaVar, 1e-12))

stdev    = volType == "STD" ? ta.stdev(src, lenMean) : ewmaStd
stdevFix = math.max(stdev, 1e-8)

//========================
// Z-score (probability waves)
//========================
zRaw = (src - ma) / stdevFix
z    = ta.ema(zRaw, zSmooth)

// Pane-only EMA gate shading (kept to ±3.5σ bounds)
shortEMA = ta.ema(src, shortLen)
longEMA  = ta.ema(src, longLen)
bull     = shortEMA >= longEMA
topLevel = 3.5
botLevel = -3.5
pTop = plot(useGate ? topLevel : na, title="Shade Top", color=color.new(color.white, 100))
pBot = plot(useGate ? botLevel : na, title="Shade Bot", color=color.new(color.white, 100))
fill(pTop, pBot, title="Gate Shade",
     color = useGate ? (bull ? color.new(color.teal, 92) : color.new(color.orange, 92)) : na)

// Z waves (columns by sigma)
colZ = z <= -3 ? color.rgb(0, 120, 255) :
       z <= -2 ? color.rgb(26, 147, 246) :
       z <= -1 ? color.rgb(140, 190, 255) :
       z >=  3 ? color.rgb(255, 60, 60)   :
       z >=  2 ? color.rgb(255, 120, 120) :
       z >=  1 ? color.rgb(255, 170, 170) :
                 color.new(color.gray, 60)

plot(showZWaves ? z : na, "Z-Score Waves", style=plot.style_columns, color=colZ)
hline( 0, "0",   color=color.new(color.gray,70))
hline( 1, "+1σ", color=color.new(color.red,70))
hline(-1, "−1σ", color=color.new(color.teal,70))
hline( 2, "+2σ", color=color.new(color.red,80))
hline(-2, "−2σ", color=color.new(color.teal,80))
hline( 3, "+3σ", color=color.new(color.red,85))
hline(-3, "−3σ", color=color.new(color.teal,85))

//========================
// Mean Reversion (toggleable base + curve)
//========================
// Base A: Z-Score
baseZ   = zRaw
// Base B: Raw deviation vs MA (wider bandwidth): (price - MA) / MA
baseRaw = f_safediv(src - ma, ma)

// Choose base, then map with chosen curve
baseMR   = mrMode == "Z-Score" ? baseZ : baseRaw
mrCurve  = f_shape(baseMR * mrScale, curve)     // −1..+1
mrSm     = ta.ema(mrCurve, mrSmooth)

// Scale to Z-pane visual units (×3) so OB/OS align with σ grid
mrZ   = mrSm * 3.0
obZ   = obLvl * 3.0
osZ   = osLvl * 3.0

// Plot MR line & OB/OS guides (in Z units)
plot(mrZ, "MR ×3", color=color.white, linewidth=2)
plot(obZ, "MR Overbought (Z units)", color=color.new(color.red, 40))
plot(osZ, "MR Oversold (Z units)",   color=color.new(color.teal,40))

// Dots at extremes + reversal (IA-style, on scaled MR)
revUp_inside = (mrZ[1] <= osZ) and (mrZ > mrZ[1])   // slope flips up while in OS
revDn_inside = (mrZ[1] >= obZ) and (mrZ < mrZ[1])   // slope flips down while in OB
revUp_exit   = ta.crossover(mrZ, osZ)               // crosses up out of OS
revDn_exit   = ta.crossunder(mrZ, obZ)              // crosses down out of OB

osDot = dotMode == "ReversalOut" ? revUp_exit : revUp_inside
obDot = dotMode == "ReversalOut" ? revDn_exit : revDn_inside

plot(osDot ? mrZ : na, title="OS Dot", style=plot.style_circles, color=color.new(color.teal, 0), linewidth=3)
plot(obDot ? mrZ : na, title="OB Dot", style=plot.style_circles, color=color.new(color.red, 0),  linewidth=3)

//========================
// Alerts (optional)
//========================
alertcondition(bull and z <= zBuyLvl,        "Z ≤ Long Threshold (Bull Gate)",  "Z ≤ threshold and EMA gate bullish")
alertcondition((not bull) and z >= zSellLvl, "Z ≥ Short Threshold (Bear Gate)", "Z ≥ threshold and EMA gate bearish")
alertcondition(osDot, "MR Oversold Reversal",   "MR extreme at low and reversing up")
alertcondition(obDot, "MR Overbought Reversal", "MR extreme at high and reversing down")
````
