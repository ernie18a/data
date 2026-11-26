# Ultimate Sideways Market Detector PRO V2

- url: https://www.tradingview.com/script/EAW07rcv-Ultimate-Sideways-Market-Detector-PRO-V2/
- type: indicator
- pine_id: PUB;74f9e9772c38403caeb76652ca354ad5
- version: 1.0

## Description

Ultimate Sideways Market Detector PRO V2

Advanced Market Structure, Consolidation & Breakout Detection System

Ultimate Sideways Market Detector PRO V2 is an advanced all-in-one TradingView indicator designed to identify sideways markets, consolidation zones, volatility compression, liquidity sweeps, smart money activity, and potential breakout opportunities before major price movements occur.

Instead of relying on a single indicator, this system combines multiple market analysis techniques into one powerful scoring engine that helps traders understand current market conditions and prepare for future market expansion.

Suitable for Crypto, Forex, Stocks, Indices, and Commodities.

---

# Core Features

✅ Sideways Market Detection

✅ ADX Trend Strength Analysis

✅ Choppiness Index Analysis

✅ ATR Compression Detection

✅ Bollinger Band Width Compression

✅ EMA Flatness Detection

✅ Range Compression Analysis

✅ Volume Compression Filter

✅ Volatility Squeeze Detection

✅ Keltner Channel Compression

✅ Multi-Timeframe Confirmation

✅ Smart Money Consolidation Detection

✅ Liquidity Sweep Detection

✅ Fake Breakout Filter

✅ Auto Support & Resistance

✅ Breakout Probability Engine

✅ Sideways Strength Meter

✅ Market State Dashboard

✅ Trend Cloud Visualization

✅ Real-Time Alerts

---

# Market States

The dashboard automatically classifies market conditions into the following states:

### SIDEWAYS

Market is consolidating inside a range.

Best Use:
• Buy near support
• Sell near resistance
• Prepare for breakouts

---

### UPTREND

Strong bullish market.

Best Use:
• Focus on long opportunities
• Buy pullbacks

---

### DOWNTREND

Strong bearish market.

Best Use:
• Focus on short opportunities
• Sell pullbacks

---

### VOLATILE

High volatility environment.

Best Use:
• Reduce position size
• Expect larger price swings

---

### TRANSITION

Market is changing conditions.

Best Use:
• Wait for confirmation
• Avoid aggressive entries

---

# Dashboard Guide

### STATE

Current market condition.

### SCORE

Overall consolidation score.

Below 40 = Trending

40-70 = Moderate Consolidation

70-90 = Strong Sideways Market

Above 90 = Extreme Compression

---

### STRENGTH

Measures consolidation quality.

0-30 = Weak

30-60 = Moderate

60-80 = Strong

80-100 = Very Strong

Higher values often indicate stronger breakout potential.

---

### SQUEEZE

Measures volatility compression intensity.

Higher values indicate stronger energy build-up.

---

### MTF

Multi-Timeframe Agreement.

YES = Multiple timeframes agree.

NO = Timeframes disagree.

---

### BREAKOUT

Breakout Probability Meter.

0-40% = Low Probability

40-60% = Moderate Probability

60-80% = Strong Probability

80-100% = Very High Probability

---

### ADX

Trend Strength Measurement.

Below 20 = Weak Trend

Above 25 = Strong Trend

Above 35 = Very Strong Trend

---

### MODE

RANGE = Sideways Market

TREND = Trending Market

---

# Feature Breakdown

### ADX Analysis

Measures trend strength.

Low ADX often indicates consolidation.

High ADX often indicates trending conditions.

---

### Choppiness Index

Measures how directional or random price action is.

High Choppiness = Sideways Market

Low Choppiness = Trending Market

---

### ATR Compression

Measures volatility contraction.

Low ATR often appears before major expansion phases.

---

### Bollinger Band Width

Measures market compression.

Narrow Bands = Compression

Wide Bands = Expansion

---

### EMA Flatness

Flat EMA often indicates consolidation.

Steep EMA often indicates trend strength.

---

### Range Compression

Detects narrow trading ranges that may lead to future breakouts.

---

### Volume Compression

Detects reduced participation before volatility expansion.

---

### Volatility Squeeze

Compares Bollinger Bands and Keltner Channels to identify volatility compression.

Strong squeeze conditions often appear before significant market moves.

---

### Multi-Timeframe Confirmation

Uses multiple timeframes to improve signal quality and reduce false setups.

---

### Smart Money Consolidation

Highlights accumulation and distribution zones where larger market participants may be active.

---

### Liquidity Sweeps

Identifies potential stop hunts and liquidity grabs.

Bull Sweep:
Price breaks below support and quickly recovers.

Bear Sweep:
Price breaks above resistance and quickly rejects.

---

### Fake Breakout Filter

Attempts to eliminate weak breakout attempts and improve signal quality.

---

### Auto Support & Resistance

Automatically detects important swing levels for entries, exits, stop placement, and breakout validation.

---

# How To Use This Indicator

### Step 1

Check STATE.

Determine whether the market is Sideways, Trending, Volatile, or in Transition.

---

### Step 2

Check SCORE.

Higher scores indicate stronger consolidation.

---

### Step 3

Check STRENGTH.

Higher strength means stronger compression and greater breakout potential.

---

### Step 4

Check Volatility Squeeze.

Compression often precedes expansion.

---

### Step 5

Check MTF Agreement.

Signals become stronger when multiple timeframes agree.

---

### Step 6

Check Breakout Probability.

Higher values indicate stronger breakout potential.

---

### Step 7

Wait for a Valid BUY or SELL Breakout Signal.

---

### Step 8

Apply proper risk management.

---

# Best High-Probability Breakout Setup

Look for:

✅ STATE = SIDEWAYS

✅ SCORE Above 80

✅ STRENGTH Above 70

✅ Volatility Squeeze Active

✅ MTF Agreement = YES

✅ Breakout Probability Above 70

Then wait for:

✅ Valid BUY Breakout

or

✅ Valid SELL Breakout

---

# Best Reversal Setup

Look for:

✅ Bull Sweep near Support

or

✅ Bear Sweep near Resistance

Then wait for confirmation.

These setups often indicate trapped traders and liquidity grabs.

---

# Alerts Available

• Sideways Started

• Sideways Ended

• Bullish Breakout

• Bearish Breakout

• Bull Liquidity Sweep

• Bear Liquidity Sweep

• Volatility Squeeze Active

---

# Recommended Markets

✅ Crypto

✅ Forex

✅ Stocks

✅ Indices

✅ Commodities

---

# Recommended Timeframes

Scalping:
5M, 15M

Intraday:
15M, 30M, 1H

Swing Trading:
4H, 1D

---

# Important Notice

This indicator is intended for educational and decision-support purposes only.

No indicator can predict future price movements with complete accuracy.

Always use proper risk management, position sizing, and independent analysis before entering any trade.

Thank you for using Ultimate Sideways Market Detector PRO V2.

## Source Code

````pine
//@version=6
indicator("Ultimate Sideways Market Detector PRO V2", overlay=true, max_boxes_count=500)

//====================================================
// INPUTS
//====================================================

groupCore = "Core Detection"

enableADX    = input.bool(true, "Enable ADX", group=groupCore)
enableCI     = input.bool(true, "Enable Choppiness", group=groupCore)
enableATR    = input.bool(true, "Enable ATR Compression", group=groupCore)
enableBBW    = input.bool(true, "Enable BB Width Compression", group=groupCore)
enableEMA    = input.bool(true, "Enable EMA Flatness", group=groupCore)
enableRange  = input.bool(true, "Enable Range Compression", group=groupCore)
enableVolume = input.bool(false, "Enable Volume Compression", group=groupCore)

adxLen      = input.int(14, "ADX Length")
ciLen       = input.int(14, "CI Length")
atrLen      = input.int(14, "ATR Length")
emaLen      = input.int(50, "EMA Length")
rangeLen    = input.int(20, "Range Length")

sidewaysThreshold = input.int(70, "Sideways Score Threshold", minval=10, maxval=130)

//====================================================
// MANUAL ADX
//====================================================

upMove   = high - high[1]
downMove = low[1] - low

plusDM  = (upMove > downMove and upMove > 0) ? upMove : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0

trur = ta.rma(ta.tr(true), adxLen)

plusDI  = 100 * ta.rma(plusDM, adxLen) / trur
minusDI = 100 * ta.rma(minusDM, adxLen) / trur

dx = 100 * math.abs(plusDI - minusDI) / math.max(plusDI + minusDI, 1)

adx = ta.rma(dx, adxLen)

adxScore = enableADX ? (adx < 20 ? 25 : 0) : 0

//====================================================
// CHOPPINESS INDEX
//====================================================

trSum = ta.sma(ta.tr(true), ciLen) * ciLen

hh = ta.highest(high, ciLen)
ll = ta.lowest(low, ciLen)

ci = 100 * math.log10(trSum / math.max(hh - ll, syminfo.mintick)) / math.log10(ciLen)

ciScore = enableCI ? (ci > 61.8 ? 25 : 0) : 0

//====================================================
// ATR COMPRESSION
//====================================================

atr = ta.atr(atrLen)
atrMA = ta.sma(atr, 50)

atrScore = enableATR ? (atr < atrMA * 0.8 ? 15 : 0) : 0

//====================================================
// BOLLINGER WIDTH
//====================================================

basis = ta.sma(close, 20)
dev   = ta.stdev(close, 20)

upper = basis + dev * 2.0
lower = basis - dev * 2.0

bbw = (upper - lower) / basis
bbwMA = ta.sma(bbw, 50)

bbwScore = enableBBW ? (bbw < bbwMA * 0.8 ? 20 : 0) : 0

//====================================================
// EMA FLATNESS
//====================================================

ema50 = ta.ema(close, emaLen)

flatEMA = math.abs(ema50 - ema50[10]) < atr

emaScore = enableEMA ? (flatEMA ? 15 : 0) : 0

//====================================================
// RANGE COMPRESSION
//====================================================

rangeHigh = ta.highest(high, rangeLen)
rangeLow  = ta.lowest(low, rangeLen)

rangeWidth = rangeHigh - rangeLow

rangeScore = enableRange ? (rangeWidth < atr * 8 ? 20 : 0) : 0

//====================================================
// VOLUME COMPRESSION
//====================================================

volMA = ta.sma(volume, 20)

volScore = enableVolume ? (volume < volMA ? 10 : 0) : 0

//====================================================
// FINAL SCORE
//====================================================

sidewaysScore =
     adxScore +
     ciScore +
     atrScore +
     bbwScore +
     emaScore +
     rangeScore +
     volScore

isSideways = sidewaysScore >= sidewaysThreshold

//====================================================
// STRENGTH METER
//====================================================

strength = math.min(100, math.round(sidewaysScore / 130 * 100))

//====================================================
// MARKET STATES
//====================================================

trendUp   = adx > 25 and close > ema50
trendDown = adx > 25 and close < ema50
volatile  = atr > atrMA * 1.3 and adx > 20

string marketState = "TRANSITION"

if isSideways
    marketState := "SIDEWAYS"
else if trendUp
    marketState := "UPTREND"
else if trendDown
    marketState := "DOWNTREND"
else if volatile
    marketState := "VOLATILE"

//====================================================
// BASIC VISUALS
//====================================================

bgcolor(isSideways ? color.new(color.yellow, 92) : na)

plot(ema50, color=color.aqua, linewidth=2, title="EMA 50")

//====================================================
// PART 1 END
//====================================================

//====================================================
// PART 2 : Volatilit SQUEEZE + MTF ENGINE (FIXED)
//====================================================

//----------------------------
// INPUTS
//----------------------------
groupSqueeze = "Volatility Squeeze"

enableSqueeze = input.bool(true, "Enable Volatility Squeeze", group=groupSqueeze)
kcLen  = input.int(20, "KC Length", group=groupSqueeze)
kcMult = input.float(1.5, "KC Multiplier", group=groupSqueeze)

groupMTF = "Multi Timeframe"

enableMTF = input.bool(true, "Enable MTF Confirmation", group=groupMTF)

tfFast   = input.timeframe("15", "Fast TF", group=groupMTF)
tfMedium = input.timeframe("60", "Medium TF", group=groupMTF)
tfSlow   = input.timeframe("240", "Slow TF", group=groupMTF)

//====================================================
// KELTNER CHANNEL
//====================================================

kcBasis = ta.ema(close, kcLen)

kcUpper = kcBasis + ta.atr(kcLen) * kcMult
kcLower = kcBasis - ta.atr(kcLen) * kcMult

//====================================================
// Volatilit SQUEEZE
//====================================================

squeezeOn  = upper < kcUpper and lower > kcLower
squeezeOff = upper > kcUpper and lower < kcLower

squeezeScore = enableSqueeze ? (squeezeOn ? 20 : 0) : 0

//====================================================
// SQUEEZE STRENGTH
//====================================================

bbwPercent =
     bbwMA > 0 ?
     (bbw / bbwMA) * 100 :
     100

squeezeStrength =
     math.max(
     0,
     math.min(
     100,
     math.round(100 - bbwPercent)))

//====================================================
// MTF EMA ENGINE
//====================================================

emaFast =
     request.security(
     syminfo.tickerid,
     tfFast,
     ta.ema(close, emaLen))

emaMedium =
     request.security(
     syminfo.tickerid,
     tfMedium,
     ta.ema(close, emaLen))

emaSlow =
     request.security(
     syminfo.tickerid,
     tfSlow,
     ta.ema(close, emaLen))

//====================================================
// MTF RANGE ENGINE
//====================================================

fastRangeHigh =
     request.security(
     syminfo.tickerid,
     tfFast,
     ta.highest(high, rangeLen))

fastRangeLow =
     request.security(
     syminfo.tickerid,
     tfFast,
     ta.lowest(low, rangeLen))

mediumRangeHigh =
     request.security(
     syminfo.tickerid,
     tfMedium,
     ta.highest(high, rangeLen))

mediumRangeLow =
     request.security(
     syminfo.tickerid,
     tfMedium,
     ta.lowest(low, rangeLen))

slowRangeHigh =
     request.security(
     syminfo.tickerid,
     tfSlow,
     ta.highest(high, rangeLen))

slowRangeLow =
     request.security(
     syminfo.tickerid,
     tfSlow,
     ta.lowest(low, rangeLen))

//====================================================
// MTF SIDEWAYS LOGIC
//====================================================

fastWidth =
     fastRangeHigh - fastRangeLow

mediumWidth =
     mediumRangeHigh - mediumRangeLow

slowWidth =
     slowRangeHigh - slowRangeLow

fastSideways =
     fastWidth <
     request.security(
     syminfo.tickerid,
     tfFast,
     ta.atr(atrLen)) * 8

mediumSideways =
     mediumWidth <
     request.security(
     syminfo.tickerid,
     tfMedium,
     ta.atr(atrLen)) * 8

slowSideways =
     slowWidth <
     request.security(
     syminfo.tickerid,
     tfSlow,
     ta.atr(atrLen)) * 8

//====================================================
// MTF SCORE
//====================================================

mtfCount =
     (fastSideways ? 1 : 0) +
     (mediumSideways ? 1 : 0) +
     (slowSideways ? 1 : 0)

mtfScore =
     enableMTF ?
     mtfCount * 10 :
     0

mtfAgreement =
     mtfCount >= 2

//====================================================
// TOTAL SCORE V2
//====================================================

totalScore =
     sidewaysScore +
     squeezeScore +
     mtfScore

isSidewaysV2 =
     totalScore >= sidewaysThreshold

//====================================================
// MTF TREND STATES
//====================================================

mtfBull =
     close > emaFast and
     close > emaMedium and
     close > emaSlow

mtfBear =
     close < emaFast and
     close < emaMedium and
     close < emaSlow

//====================================================
// VISUALS
//====================================================

plotshape(squeezeOn, title="Volatility Squeeze", style=shape.circle, location=location.bottom, color=color.orange, size=size.tiny)

plotchar(
     mtfAgreement,
     title="MTF Agreement",
     char="M",
     location=location.bottom)

//====================================================
// PART 2 END
//====================================================

//====================================================
// PART 3 : SMART MONEY + BREAKOUT ENGINE
//====================================================

groupSMC = "Smart Money Engine"

enableSMC = input.bool(true, "Enable Smart Money Logic", group=groupSMC)

pivotLen = input.int(5, "Pivot Length", group=groupSMC)

fakeATR = input.float(0.50, "Fake Breakout ATR Filter", group=groupSMC)

//====================================================
// PIVOTS
//====================================================

pivotHigh =
     ta.pivothigh(
     high,
     pivotLen,
     pivotLen)

pivotLow =
     ta.pivotlow(
     low,
     pivotLen,
     pivotLen)

//====================================================
// AUTO SR
//====================================================

var float lastResistance = na
var float lastSupport = na

if not na(pivotHigh)
    lastResistance := pivotHigh

if not na(pivotLow)
    lastSupport := pivotLow

plot(
     lastResistance,
     "Resistance",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr)

plot(
     lastSupport,
     "Support",
     color=color.lime,
     linewidth=2,
     style=plot.style_linebr)

//====================================================
// CONSOLIDATION
//====================================================

consolidationWidth =
     rangeHigh - rangeLow

smartMoneyZone =
     consolidationWidth <
     atr * 6

smcScore =
     enableSMC ?
     (smartMoneyZone ? 15 : 0)
     : 0

//====================================================
// LIQUIDITY SWEEP
//====================================================

bullSweep =
     not na(lastSupport) and
     low < lastSupport and
     close > lastSupport

bearSweep =
     not na(lastResistance) and
     high > lastResistance and
     close < lastResistance

//====================================================
// SWEEP SCORE
//====================================================

sweepScore =
     bullSweep or bearSweep ?
     10 :
     0

//====================================================
// BREAKOUTS
//====================================================

bullBreakout =
     close > rangeHigh and
     close > high[1]

bearBreakout =
     close < rangeLow and
     close < low[1]

//====================================================
// FAKE BREAKOUT FILTER
//====================================================

bullDistance =
     close - rangeHigh

bearDistance =
     rangeLow - close

bullFakeBreakout =
     bullBreakout and
     bullDistance <
     atr * fakeATR

bearFakeBreakout =
     bearBreakout and
     bearDistance <
     atr * fakeATR

validBullBreakout =
     bullBreakout and
     not bullFakeBreakout

validBearBreakout =
     bearBreakout and
     not bearFakeBreakout

//====================================================
// BREAKOUT PROBABILITY
//====================================================

breakoutProbability =
     math.min(
     100,
     strength +
     squeezeStrength / 2 +
     mtfScore +
     smcScore)

//====================================================
// UPDATED SCORE
//====================================================

finalScore =
     totalScore +
     smcScore +
     sweepScore

isSidewaysPRO =
     finalScore >= sidewaysThreshold

//====================================================
// VISUALS
//====================================================

plotshape(
     bullSweep,
     title="Bull Sweep",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.lime,
     size=size.tiny)

plotshape(
     bearSweep,
     title="Bear Sweep",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.tiny)

plotshape(
     validBullBreakout,
     title="Bull Breakout",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     text="BUY")

plotshape(
     validBearBreakout,
     title="Bear Breakout",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     text="SELL")

plotshape(
     bullFakeBreakout,
     title="Fake Bull",
     style=shape.circle,
     location=location.abovebar,
     color=color.orange,
     size=size.tiny)

plotshape(
     bearFakeBreakout,
     title="Fake Bear",
     style=shape.circle,
     location=location.belowbar,
     color=color.orange,
     size=size.tiny)

//====================================================
// PART 3 END
//====================================================


//====================================================
// PART 4 : DASHBOARD + ALERTS + FINAL VISUALS
//====================================================

//----------------------------
// TREND CLOUDS
//----------------------------

bullCloud = mtfBull and not isSidewaysPRO
bearCloud = mtfBear and not isSidewaysPRO

bgcolor(
     isSidewaysPRO ?
     color.new(color.yellow, 92) :
     bullCloud ?
     color.new(color.green, 94) :
     bearCloud ?
     color.new(color.red, 94) :
     na)

//----------------------------
// DASHBOARD
//----------------------------

var table dash = table.new(position.top_right, 2, 8)

if barstate.islast

    stateColor =
         marketState == "UPTREND" ? color.lime :
         marketState == "DOWNTREND" ? color.red :
         marketState == "SIDEWAYS" ? color.yellow :
         color.orange

    table.cell(dash, 0, 0, "STATE")
    table.cell(dash, 1, 0, marketState, text_color=stateColor)

    table.cell(dash, 0, 1, "SCORE")
    table.cell(dash, 1, 1, str.tostring(finalScore))

    table.cell(dash, 0, 2, "STRENGTH")
    table.cell(dash, 1, 2, str.tostring(strength) + "%")

    table.cell(dash, 0, 3, "SQUEEZE")
    table.cell(dash, 1, 3, str.tostring(squeezeStrength) + "%")

    table.cell(dash, 0, 4, "MTF")
    table.cell(dash, 1, 4, mtfAgreement ? "YES" : "NO")

    table.cell(dash, 0, 5, "BREAKOUT")
    table.cell(dash, 1, 5, str.tostring(math.round(breakoutProbability)) + "%")

    table.cell(dash, 0, 6, "ADX")
    table.cell(dash, 1, 6, str.tostring(math.round(adx)))

    table.cell(dash, 0, 7, "MODE")
    table.cell(
         dash,
         1,
         7,
         isSidewaysPRO ? "RANGE" : "TREND")

//----------------------------
// SIDEWAYS START/END
//----------------------------

sidewaysStart =
     isSidewaysPRO and
     not isSidewaysPRO[1]

sidewaysEnd =
     not isSidewaysPRO and
     isSidewaysPRO[1]

//----------------------------
// SIDEWAYS BOXES
//----------------------------

var box rangeBox = na

if sidewaysStart
    rangeBox :=
         box.new(
         left=bar_index,
         top=rangeHigh,
         right=bar_index,
         bottom=rangeLow,
         bgcolor=color.new(color.yellow, 88),
         border_color=color.yellow)

if isSidewaysPRO and not na(rangeBox)
    box.set_right(rangeBox, bar_index)
    box.set_top(rangeBox, rangeHigh)
    box.set_bottom(rangeBox, rangeLow)

//----------------------------
// ALERTS
//----------------------------

alertcondition(
     sidewaysStart,
     title="Sideways Started",
     message="Sideways Market Started")

alertcondition(
     sidewaysEnd,
     title="Sideways Ended",
     message="Sideways Market Ended")

alertcondition(
     validBullBreakout,
     title="Bullish Breakout",
     message="Bullish Breakout Detected")

alertcondition(
     validBearBreakout,
     title="Bearish Breakout",
     message="Bearish Breakout Detected")

alertcondition(
     bullSweep,
     title="Bull Liquidity Sweep",
     message="Bull Liquidity Sweep Detected")

alertcondition(
     bearSweep,
     title="Bear Liquidity Sweep",
     message="Bear Liquidity Sweep Detected")

alertcondition(
     squeezeOn,
     title="Volatilit Squeeze",
     message="Volatilit Squeeze Active")

//----------------------------
// FINAL PLOTS
//----------------------------

plot(
     emaFast,
     title="MTF EMA Fast",
     color=color.new(color.green, 0))

plot(
     emaMedium,
     title="MTF EMA Medium",
     color=color.new(color.orange, 0))

plot(
     emaSlow,
     title="MTF EMA Slow",
     color=color.new(color.red, 0))

//====================================================
// END OF ULTIMATE SIDEWAYS MARKET DETECTOR PRO V2
//====================================================
````
