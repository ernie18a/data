# Momentum-INSTITUTIONAL SPIKE + SQUEEZE ENGINE PRO

- url: https://www.tradingview.com/script/Luhkeft7-Momentum-INSTITUTIONAL-SPIKE-SQUEEZE-ENGINE-PRO/
- type: indicator
- pine_id: PUB;94b672ffab224322b3cdc9d6dd95f78f
- version: 1.0

## Description

## 📊 Institutional Spike + Squeeze Engine — Short Write-Up

This indicator is a **momentum intelligence system** designed to detect **early accumulation, breakout confirmation, and explosive moves** while filtering out false signals.

### 🔑 Core Idea

It tracks the **full lifecycle of a trade**:
**Squeeze → Pre-Spike → Breakout → Spike → Exhaustion**

---

### ⚙️ What It Uses

* **Momentum (ROC):** Detects acceleration (fast vs slow)
* **Volume:** Confirms strength (1.5× for entry, 3× for spikes)
* **Structure:** Breakout above previous day’s high
* **Trend Strength:** DMI/ADX filters real trends vs noise
* **Volatility:** Bollinger Bands + Keltner Channels for squeeze detection

---

### 🧠 Smart Features

* **Pre-Spike Detection:** Identifies quiet accumulation before big moves
* **Smart Spike vs Trap:** Differentiates institutional buying from retail traps
* **AI Score:** Combines multiple factors into a single confidence score
* **Lifecycle Mapping:** Shows whether the stock is in accumulation, breakout, or exhaustion

---

### 🎯 How to Use

* **Best Setup:** Squeeze ON → Pre-Spike → Breakout → Smart Spike
* **Early Entry:** On Pre-Spike signals (small position)
* **Confirmation Entry:** On breakout with volume
* **Avoid:** Trap spikes and exhaustion signals

---

### 💡 Edge

This system helps you:

* Enter **before large moves begin**
* Avoid **false breakouts**
* Trade with **institutional flow instead of retail noise**

## Source Code

````pine
//@version=6
indicator("INSTITUTIONAL SPIKE + SQUEEZE ENGINE PRO", overlay=false)

// ==========================
// ⚙️ INPUTS
// ==========================
fastLen   = input.int(5, "Fast Momentum")
slowLen   = input.int(21, "Slow Momentum")
volLen    = input.int(20, "Volume Avg Length")
rsiLen    = input.int(14, "RSI Length")
adxLen    = input.int(14, "ADX Length")

volMult   = input.float(1.5, "Breakout Volume Multiplier")
spikeMult = input.float(3.0, "Spike Volume Multiplier")

bbLen     = input.int(20, "BB Length")
bbMult    = input.float(2.0, "BB Mult")
kcLen     = input.int(20, "KC Length")
kcMult    = input.float(1.5, "KC Mult")

// ==========================
// 📊 CORE ENGINE
// ==========================

// Momentum
momFast = ta.roc(close, fastLen)
momSlow = ta.roc(close, slowLen)

// Strength
rsi = ta.rsi(close, rsiLen)

// ✅ FIXED DMI (2 parameters)
[diPlus, diMinus, adx] = ta.dmi(adxLen, adxLen)

trendUp   = diPlus > diMinus
trendDown = diMinus > diPlus

// Volume
avgVol     = ta.sma(volume, volLen)
volSpike15 = volume > avgVol * volMult
volSpike3x = volume > avgVol * spikeMult

// Structure
prevHigh = request.security(syminfo.tickerid, "D", high[1])
breakout = close > prevHigh

// Range
barRange       = high - low
avgRange       = ta.sma(barRange, 20)
rangeExpansion = barRange > avgRange * 1.5

// ==========================
// 🔒 VOLATILITY SQUEEZE
// ==========================

// Bollinger Bands
basis   = ta.sma(close, bbLen)
dev     = ta.stdev(close, bbLen)
upperBB = basis + bbMult * dev
lowerBB = basis - bbMult * dev

// Keltner Channels
emaKC   = ta.ema(close, kcLen)
rangeKC = ta.ema(barRange, kcLen)
upperKC = emaKC + kcMult * rangeKC
lowerKC = emaKC - kcMult * rangeKC

squeezeOn  = (upperBB < upperKC) and (lowerBB > lowerKC)
squeezeOff = (upperBB > upperKC) and (lowerBB < lowerKC)

// ==========================
// ⚡ PRE-SPIKE DETECTION
// ==========================

volBuild      = volume > avgVol * 1.2 and volume < avgVol * spikeMult
momentumTight = math.abs(momFast - momSlow) < 0.5 and momFast > 0

preSpike = squeezeOn and volBuild and momentumTight

// ==========================
// 💥 SPIKE ENGINE
// ==========================

momentumBurst = momFast > momSlow * 1.2 and momFast > 1

smartSpike  = volSpike3x and breakout and momentumBurst and adx > 20 and trendUp
trapSpike   = volSpike3x and not breakout and rsi > 70 and momFast < momSlow and trendDown
exhaustSpike = volSpike3x and rsi > 75 and not rangeExpansion

// ==========================
// 🔄 MARKET STATES
// ==========================

slowRise    = momSlow > 0 and momFast > 0 and momFast < momSlow and not volSpike15
preMomentum = momFast > 0 and momSlow > 0 and volSpike15 and not breakout
strongBreak = breakout and volSpike15 and momentumBurst

// ==========================
// 🤖 AI SCORING
// ==========================

score = 0.0
score += momFast > 0 ? 1 : 0
score += momFast > momSlow ? 1 : 0
score += rsi > 55 ? 1 : 0
score += adx > 20 ? 1 : 0
score += volSpike15 ? 1.5 : 0
score += breakout ? 2 : 0
score += smartSpike ? 2 : 0
score += preSpike ? 1.5 : 0
score -= trapSpike ? 2 : 0
score -= exhaustSpike ? 1.5 : 0

aiScore = score / 11.5

// ==========================
// 🎯 SIGNALS
// ==========================

instBuy    = aiScore > 0.7 and strongBreak
earlyEntry = aiScore > 0.55 and (preMomentum or preSpike)

// ==========================
// 📊 PLOTS
// ==========================

plot(momFast, "Fast Momentum", linewidth=2)
plot(momSlow, "Slow Momentum", linewidth=2)
plot(aiScore, "AI Score", linewidth=3)

// ==========================
// 🔔 MARKERS
// ==========================

plotshape(instBuy, title="INST BUY", location=location.top, style=shape.triangleup, size=size.large)
plotshape(earlyEntry, title="EARLY", location=location.bottom, style=shape.triangleup, size=size.small)
plotshape(slowRise, title="SLOW RISE", location=location.bottom, style=shape.circle, size=size.small)

plotshape(preSpike, title="PRE-SPIKE", location=location.bottom, style=shape.diamond, size=size.small)

plotshape(smartSpike, title="SMART SPIKE", location=location.top, style=shape.diamond, size=size.large)
plotshape(trapSpike, title="TRAP", location=location.top, style=shape.xcross, size=size.large)
plotshape(exhaustSpike, title="EXHAUST", location=location.top, style=shape.square, size=size.normal)

// ==========================
// 🎨 BACKGROUND
// ==========================

bgcolor(instBuy ? color.new(color.green, 85) : na)
bgcolor(preSpike ? color.new(color.purple, 85) : na)
bgcolor(trapSpike ? color.new(color.red, 85) : na)

// ==========================
// 📋 TABLE
// ==========================

var table t = table.new(position.top_right, 2, 9)

if barstate.islast
    table.cell(t, 0, 0, "Metric")
    table.cell(t, 1, 0, "Value")

    table.cell(t, 0, 1, "AI Score")
    table.cell(t, 1, 1, str.tostring(aiScore, "#.##"))

    table.cell(t, 0, 2, "Squeeze")
    table.cell(t, 1, 2, squeezeOn ? "ON" : "OFF")

    table.cell(t, 0, 3, "Pre-Spike")
    table.cell(t, 1, 3, preSpike ? "YES" : "NO")

    table.cell(t, 0, 4, "Breakout")
    table.cell(t, 1, 4, breakout ? "YES" : "NO")

    table.cell(t, 0, 5, "Vol 3x")
    table.cell(t, 1, 5, volSpike3x ? "YES" : "NO")

    table.cell(t, 0, 6, "Smart Spike")
    table.cell(t, 1, 6, smartSpike ? "YES" : "NO")

    table.cell(t, 0, 7, "Trap Risk")
    table.cell(t, 1, 7, trapSpike ? "YES" : "NO")

    table.cell(t, 0, 8, "Phase")
    table.cell(t, 1, 8,
         preSpike ? "PRE-EXPLOSION" :
         slowRise ? "ACCUMULATION" :
         strongBreak ? "BREAKOUT" :
         exhaustSpike ? "EXHAUSTION" : "NEUTRAL")
````
