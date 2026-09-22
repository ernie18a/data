<!-- tradingview-pine-id: PUB;9440e4988145448ba9fbb4406dc39ef1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Momentum Core [MasterTonyTA]

Source: https://www.tradingview.com/script/5xoD3UVb-Momentum-Core-MasterTonyTA/

## Description

# Momentum Core — Publish Description

---

## WHAT IT IS

Momentum Core is a composite momentum oscillator that blends four non-redundant momentum sources into a single normalized reading, then layers on a MACD-derived wave, a volatility/participation regime gate, and health zones that separate tradeable momentum from both chop and exhaustion.

Most momentum oscillators measure the same thing twice. MACD is essentially rate-of-change on EMAs. Stochastic and RSI both measure position within range. CCI overlaps normalized ROC. Stacking those gives you four confirmations of one idea and a false sense of confluence.

This indicator deliberately selects sources that measure **different** things: smoothed directional force, volatility-adjusted velocity, thrust acceleration, and participation. Each is z-scored against its own recent history before being weighted, so no single component can dominate simply because it has a larger raw scale.

---

## HOW TO READ IT

### The Momentum Line (main plot)

The line is the composite reading, squashed to a **-100 to +100** range. Its color encodes two things at once:

| Color | Meaning |
|---|---|
| **Solid green** | Momentum rising, above signal line — clean bullish impulse |
| **Faded green** | Momentum rising, below signal line — early turn, not yet confirmed |
| **Faded red** | Momentum falling, above signal line — exhaustion; the move is decaying while still reading positive |
| **Solid red** | Momentum falling, below signal line — clean bearish impulse |
| **Grey / dimmed** | Regime gate failed — ADX or relative volume too low to trust the reading |

The key read is the **faded states**. A faded red above the signal line is the earliest exit tell in the indicator: price may still be making highs, but the force behind it is already draining. A faded green below the signal is the mirror — the turn has started before the crossover confirms it.

Direction is set by the **slope** of momentum, not by its position. A deadzone input prevents flicker during flat patches — the last direction holds until slope decisively flips.

### The Signal Line (orange)

A 9-period EMA of the composite. It is not a trade trigger on its own; it defines conviction. The wider the gap between momentum and signal, the stronger the current state. Crossovers matter most when they happen **inside a good zone** rather than in chop.

### The Momentum Wave (area fill)

A MACD histogram, z-scored and squashed onto the same scale as the main line. This is the cycle-rhythm layer — it shows you the breathing pattern of impulses.

- **Green** above zero, **red** below zero — always, regardless of the main line's state
- **Transparency scales with magnitude** — solid means a strong impulse, faded means a decaying one

By default the wave carries **zero weight** in the composite, so it is purely visual. This is intentional: MACD overlaps TSI, and scoring both double-counts the same signal. The weight input exists if you want it, but keep it at or below 0.5.

The wave's most useful read is **disagreement with the main line**. When the line is green and the wave is fading toward zero, the impulse is losing its engine.

### The Zones

Four regions, defined by two boundaries per side:

- **Bull good zone (+15 to +60)** — shaded green. Momentum is meaningfully positive but not stretched. This is where trends actually run.
- **Bear good zone (-15 to -60)** — shaded red. Same logic, downside.
- **Chop zone (-15 to +15)** — shaded neutral. Momentum lacks conviction. Signals here have the worst expectancy in the entire indicator.
- **Overextended (beyond ±60)** — unshaded. Momentum is stretched; continuation still happens, but reward-to-risk on new entries is poor and mean reversion risk is elevated.

Treat zones as a filter, not a signal. A crossover in the good zone and the identical crossover in chop are not the same event.

### Divergence Labels

**D** labels mark divergence between the composite and price, detected on confirmed pivots. A bullish divergence prints when price makes a lower low while momentum makes a higher low; bearish is the inverse. Labels are offset back to the pivot bar, so they confirm with a lag equal to the right-pivot setting — this is by design, since unconfirmed pivots repaint.

---

## THE CALCULATIONS

### Step 1 — Component extraction

**TSI (True Strength Index)** — double-smoothed momentum, default 13/25. Chosen over MACD because the double smoothing removes most whipsaw while keeping the zero-line cross meaningful.

**ATR-Normalized ROC** — `(close - close[n]) / ATR(n)`. Dividing by ATR is what makes this portable: a 2% move in a quiet tape and a 2% move in a volatile one produce very different readings, which is correct. Raw ROC would treat them identically.

**RSI Velocity** — the *change* in RSI over a short window, not the RSI level itself. Level tells you where you are in the range; velocity tells you how hard you are moving through it. Velocity turns first.

**OBV Slope** — change in OBV over n bars, normalized by average volume so it scales across instruments. This is the participation check. Momentum without volume behind it is a fade waiting to happen.

### Step 2 — Normalization

Each component is converted to a **z-score** against its own trailing mean and standard deviation over the lookback window:

```
z = (value - SMA(value, len)) / STDEV(value, len)
```

This is the step that makes the blend legitimate. Without it, TSI (roughly ±100 scale) would swamp OBV slope (unbounded, instrument-dependent) regardless of the weights you set. After z-scoring, every component speaks the same language: standard deviations from its own normal.

### Step 3 — Weighted composite and squash

Z-scores are combined as a weighted average, then compressed through a logistic function:

```
raw = Σ(zᵢ × wᵢ) / Σ(wᵢ)
mom = 100 × (2 / (1 + e^(-raw × 0.9)) - 1)
```

The sigmoid squash bounds the output to ±100 while preserving resolution in the middle of the range, where most trading decisions actually happen. A hard clamp would flatten all extreme readings into an identical value and destroy the distinction between "strong" and "absurd." The sigmoid compresses the tails smoothly instead.

Default weights: TSI 1.2, ROC 1.0, RSI velocity 0.8, OBV slope 0.7, wave 0.0.

### Step 4 — Signal and acceleration

```
signal = EMA(mom, 9)
accel  = EMA(Δmom, 3)
```

`accel` is the second derivative of momentum — the rate of change of the rate of change. It drives the line's directional coloring and the exhaustion alerts. This is the component most oscillators omit entirely, and it is what lets the indicator flag a decaying impulse before any crossover occurs.

### Step 5 — Regime gate

```
gateOK = ADX ≥ threshold AND relativeVolume ≥ threshold
```

When the gate fails, the momentum line dims to grey. Nothing is hidden or suppressed — you still see the full reading — but the visual weight drops, because momentum readings during low-ADX, low-participation conditions are mostly noise. Relative volume is current volume against its 20-period average.

---

## SETTINGS THAT MATTER MOST

**Z-Score Lookback (default 100)** — the single most impactful input. This is the window that defines "normal." For intraday and short-dated options work, drop it to **50**; the 100-bar window is too slow to adapt within a session. For daily and swing timeframes, leave at 100 or extend to 150.

**ROC Length (default 14)** — pair with the lookback. Intraday, drop to **7**.

**Slope Deadzone (default 0.15)** — raise toward 0.3 if the line flips color more often than you want. This trades responsiveness for stability.

**Wave Sensitivity** — the divisor in the wave transparency calculation. Lower it to 35 if the wave rarely reaches full opacity on your instrument; raise to 70 if everything saturates.

**Weights** — the defaults are a reasonable starting point, not a result of optimization. If you trade a volume-thin instrument, cut the OBV weight. If you trade something gappy, lean harder on the ATR-normalized ROC.

---

## ALERTS INCLUDED

- Momentum Flip Bull / Bear — zero cross with the regime gate passing
- Bull / Bear Exhaustion — momentum at an extreme while decelerating
- Bullish / Bearish Divergence
- Wave Flip Bull / Bear — momentum wave crossing zero
- Wave Stalling — wave rolling over without crossing
- Enter Bull Zone / Enter Bear Zone
- Overextended

---

## NOTES AND LIMITATIONS

Divergence labels confirm on a lag equal to the right-pivot setting. This is unavoidable in honest pivot detection — anything faster repaints.

The z-score normalization means readings are **relative to recent history**, not absolute. A +70 reading in a quiet regime and a +70 in a volatile one represent different raw moves. This is the intended behavior, but it means you should not port threshold settings between instruments without checking them.

This is an indicator, not a system. It has no position sizing, no stop logic, and no backtest attached. Zones and gates are filters that improve signal quality; they do not create an edge on their own.

---

*Author: MasterTonyTA*

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MasterTonyTA

//@version=6
indicator("Momentum Core [MasterTonyTA]", shorttitle="MOM Core", overlay=false, precision=2)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
grpC = "Core Engine"
tsiS    = input.int(13,  "TSI Short",        group=grpC, minval=1)
tsiL    = input.int(25,  "TSI Long",         group=grpC, minval=1)
rocLen  = input.int(14,  "ROC Length",       group=grpC, minval=1)
atrLen  = input.int(14,  "ATR Norm Length",  group=grpC, minval=1)
rsiLen  = input.int(14,  "RSI Length",       group=grpC, minval=1)
velLen  = input.int(3,   "RSI Velocity Len", group=grpC, minval=1)
obvLen  = input.int(10,  "OBV Slope Len",    group=grpC, minval=1)
zLen    = input.int(100, "Z-Score Lookback", group=grpC, minval=20)
sigLen  = input.int(9,   "Signal EMA",       group=grpC, minval=1)

grpW = "Weights"
wTsi = input.float(1.2, "TSI",          group=grpW, step=0.1)
wRoc = input.float(1.0, "ROC (ATR-N)",  group=grpW, step=0.1)
wRsi = input.float(0.8, "RSI Velocity", group=grpW, step=0.1)
wObv = input.float(0.7, "OBV Slope",    group=grpW, step=0.1)

grpM = "Momentum Wave (MACD)"
showWave = input.bool(true,  "Show Wave",               group=grpM)
macdF    = input.int(12,     "Fast",                    group=grpM, minval=1)
macdS    = input.int(26,     "Slow",                    group=grpM, minval=1)
macdSigL = input.int(9,      "Signal",                  group=grpM, minval=1)
waveAmp  = input.float(0.7,  "Wave Amplitude",          group=grpM, step=0.1, minval=0.1, maxval=1.0)
wWave    = input.float(0.0,  "Wave Weight in Composite",group=grpM, step=0.1, minval=0, maxval=2)

grpG = "Regime Gate"
useGate    = input.bool(true, "Enable Gate",       group=grpG)
diLen      = input.int(14,    "DI Length",         group=grpG, minval=1)
adxLen     = input.int(14,    "ADX Smoothing",     group=grpG, minval=1)
adxMin     = input.float(20,  "Min ADX",           group=grpG, step=1)
rvMin      = input.float(0.8, "Min Rel Volume",    group=grpG, step=0.1)
flipThresh = input.float(10,  "Regime Flip Level", group=grpG, step=1, minval=0)
confirmBars= input.int(2,     "Confirm Bars",      group=grpG, minval=1)

grpD = "Divergence"
useDiv = input.bool(true, "Show Divergence", group=grpD)
divL   = input.int(5,     "Pivot Left",      group=grpD, minval=1)
divR   = input.int(3,     "Pivot Right",     group=grpD, minval=1)


grpV = "Visuals"
showBg  = input.bool(true, "State Background", group=grpV)
bgTrans = input.int(92, "Background Transparency", group=grpV, minval=70, maxval=99)
cBull = input.color(#00c853, "Bull", group=grpV, inline="c")
cBear = input.color(#ff1744, "Bear", group=grpV, inline="c")
cNeut = input.color(#78909c, "Chop", group=grpV, inline="c")

slopeDead = input.float(0.15, "Slope Deadzone", group=grpV, step=0.05, minval=0)
dimTrans  = input.int(55, "Weak State Transparency", group=grpV, minval=0, maxval=90)

grpZ = "Zones"
showZones = input.bool(true, "Show Zones",      group=grpZ)
bullEntry = input.float(15,  "Bull Zone Start", group=grpZ, step=1)
bearEntry = input.float(-15, "Bear Zone Start", group=grpZ, step=1)
exhaustUpLvl = input.float(60,  "Bull Exhaustion", group=grpZ, step=1)
exhaustDnLvl = input.float(-60, "Bear Exhaustion", group=grpZ, step=1)
zoneTrans = input.int(90, "Zone Transparency", group=grpZ, minval=70, maxval=99)
// ═══════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════
f_z(src, len) =>
    m = ta.sma(src, len)
    s = ta.stdev(src, len)
    s == 0 ? 0.0 : (src - m) / s

f_squash(x) => 100 * (2 / (1 + math.exp(-x * 0.9)) - 1)

// ═══════════════════════════════════════════════════════════
// COMPONENTS
// ═══════════════════════════════════════════════════════════
// 1. TSI — double-smoothed momentum
tsiRaw = ta.tsi(close, tsiS, tsiL) * 100
zTsi   = f_z(tsiRaw, zLen)

// 2. ATR-normalized ROC — volatility-adjusted velocity
atrV   = ta.atr(atrLen)
rocRaw = atrV == 0 ? 0.0 : (close - close[rocLen]) / atrV
zRoc   = f_z(rocRaw, zLen)

// 3. RSI velocity — thrust, not level
rsiV   = ta.change(ta.rsi(close, rsiLen), velLen)
zRsi   = f_z(rsiV, zLen)

// 4. OBV slope — participation confirmation
obvS   = ta.change(ta.obv, obvLen)
avgVol = ta.sma(volume, 20)
obvN   = avgVol == 0 ? 0.0 : obvS / (avgVol * obvLen)
zObv   = f_z(obvN, zLen)

// 5. MACD momentum wave — cycle rhythm / impulse decay
[mcdLine, mcdSigLine, mcdHist] = ta.macd(close, macdF, macdS, macdSigL)
zWave  = f_z(mcdHist, zLen)
wave   = f_squash(zWave) * waveAmp
waveUp = wave > wave[1]

// ═══════════════════════════════════════════════════════════
// COMPOSITE
// ═══════════════════════════════════════════════════════════
wSum   = wTsi + wRoc + wRsi + wObv + wWave
rawMom = wSum == 0 ? 0.0 : (zTsi*wTsi + zRoc*wRoc + zRsi*wRsi + zObv*wObv + zWave*wWave) / wSum
mom    = f_squash(rawMom)
sig    = ta.ema(mom, sigLen)
accel  = ta.ema(ta.change(mom, 1), 3)

// ═══════════════════════════════════════════════════════════
// REGIME GATE
// ═══════════════════════════════════════════════════════════
[diP, diM, adxV] = ta.dmi(diLen, adxLen)
relVol = avgVol == 0 ? 1.0 : volume / avgVol
gateOK = not useGate or (adxV >= adxMin and relVol >= rvMin)

// ═══════════════════════════════════════════════════════════
// STATE + COLOR
// ═══════════════════════════════════════════════════════════
rising  = accel >  slopeDead
falling = accel < -slopeDead
above   = mom > sig

// Slope sets direction, mom/sig spread sets conviction
var bool dirBull = true
if rising
    dirBull := true
else if falling
    dirBull := false

strong = (dirBull and above) or (not dirBull and not above)

bull = dirBull
bear = not dirBull
baseCol = not gateOK ? cNeut : bull ? cBull : cBear
momCol  = color.new(baseCol, not gateOK ? 45 : strong ? 0 : dimTrans)

// Macro regime — held until confirmed flip
flipBullRaw = bull and gateOK
flipBearRaw = bear and gateOK

var int bullBars = 0
var int bearBars = 0
bullBars := flipBullRaw ? bullBars + 1 : 0
bearBars := flipBearRaw ? bearBars + 1 : 0

var int regime = 0
if bullBars >= confirmBars
    regime := 1
else if bearBars >= confirmBars
    regime := -1

bgCol = not showBg ? na : regime == 1 ? color.new(cBull, bgTrans) : regime == -1 ? color.new(cBear, bgTrans) : na


// ═══════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════
waveStr = math.min(math.abs(wave) / 50, 1.0)
waveCol = color.new(wave >= 0 ? cBull : cBear, int(88 - waveStr * 30))
plot(showWave ? wave : na, "Momentum Wave", color=waveCol, style=plot.style_area, linewidth=1)

// Zone boundaries
pBullEnt = plot(showZones ? bullEntry : na, "Bull Entry", color=color.new(cBull, 55), style=plot.style_linebr)
pBullExh = plot(showZones ? exhaustUpLvl : na, "Bull Exhaust", color=color.new(cBull, 55), style=plot.style_linebr)
pBearEnt = plot(showZones ? bearEntry : na, "Bear Entry", color=color.new(cBear, 55), style=plot.style_linebr)
pBearExh = plot(showZones ? exhaustDnLvl : na, "Bear Exhaust", color=color.new(cBear, 55), style=plot.style_linebr)

fill(pBullEnt, pBullExh, color=color.new(cBull, zoneTrans), title="Bull Good Zone")
fill(pBearEnt, pBearExh, color=color.new(cBear, zoneTrans), title="Bear Good Zone")
fill(pBullEnt, pBearEnt, color=color.new(cNeut, zoneTrans + 4), title="Chop Zone")

plot(mom, "Momentum", color=momCol, linewidth=2)
plot(sig, "Signal",   color=color.new(color.orange, 20), linewidth=1)

hline(0, "Zero", color=color.new(color.gray, 40), linestyle=hline.style_solid)



// ═══════════════════════════════════════════════════════════
// DIVERGENCE
// ═══════════════════════════════════════════════════════════
pl = ta.pivotlow(mom, divL, divR)
ph = ta.pivothigh(mom, divL, divR)

prevPL     = ta.valuewhen(not na(pl), pl, 1)
currPL     = ta.valuewhen(not na(pl), pl, 0)
prevPLbar  = ta.valuewhen(not na(pl), low[divR], 1)
currPLbar  = ta.valuewhen(not na(pl), low[divR], 0)

prevPH     = ta.valuewhen(not na(ph), ph, 1)
currPH     = ta.valuewhen(not na(ph), ph, 0)
prevPHbar  = ta.valuewhen(not na(ph), high[divR], 1)
currPHbar  = ta.valuewhen(not na(ph), high[divR], 0)

bullDiv = useDiv and not na(pl) and currPL > prevPL and currPLbar < prevPLbar
bearDiv = useDiv and not na(ph) and currPH < prevPH and currPHbar > prevPHbar

plotshape(bullDiv ? mom[divR] : na, "Bull Div", shape.labelup,   location.absolute, color.new(cBull, 20), text="D", textcolor=color.white, size=size.tiny, offset=-divR)
plotshape(bearDiv ? mom[divR] : na, "Bear Div", shape.labeldown, location.absolute, color.new(cBear, 20), text="D", textcolor=color.white, size=size.tiny, offset=-divR)

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════
crossUp   = ta.crossover(mom, 0)  and gateOK
crossDn   = ta.crossunder(mom, 0) and gateOK
exhaustUp = mom > 60  and accel < 0
exhaustDn = mom < -60 and accel > 0

alertcondition(crossUp,   "Momentum Flip Bull", "MOM Core: bullish zero cross, gate passed")
alertcondition(crossDn,   "Momentum Flip Bear", "MOM Core: bearish zero cross, gate passed")
alertcondition(exhaustUp, "Bull Exhaustion",    "MOM Core: momentum decelerating at extreme high")
alertcondition(exhaustDn, "Bear Exhaustion",    "MOM Core: momentum decelerating at extreme low")
alertcondition(bullDiv,   "Bullish Divergence", "MOM Core: bullish divergence")
alertcondition(bearDiv,   "Bearish Divergence", "MOM Core: bearish divergence")

waveFlipUp = ta.crossover(wave, 0)
waveFlipDn = ta.crossunder(wave, 0)
waveStall  = (wave > 0 and not waveUp and waveUp[1]) or (wave < 0 and waveUp and not waveUp[1])

alertcondition(waveFlipUp, "Wave Flip Bull", "MOM Core: momentum wave crossed above zero")
alertcondition(waveFlipDn, "Wave Flip Bear", "MOM Core: momentum wave crossed below zero")
alertcondition(waveStall,  "Wave Stalling",  "MOM Core: momentum wave rolled over")
````
