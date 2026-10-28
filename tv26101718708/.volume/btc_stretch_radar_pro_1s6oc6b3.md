# BTC Stretch Radar PRO

- url: https://www.tradingview.com/script/1s6oc6B3-BTC-Stretch-Radar-PRO/
- type: indicator
- pine_id: PUB;d6e63edc34294f5991a26abc7e484f99
- version: 1.0

## Description

BTC Stretch Radar PRO is a market condition and volatility awareness tool designed for short-term BTC and ETH trading. Instead of trying to predict the future with magical arrows and “100% win rate” nonsense, the script measures the current market environment and helps adapt risk to actual conditions.

The indicator combines several components:

• EMA Stretch
Measures how far price is stretched from the EMA. Think of it like a rubber band. The further price moves away from equilibrium, the higher probability of exhaustion, pullback, or volatility spike.

• VWAP Stretch
Shows distance from session fair value (VWAP). Useful for spotting emotional overextension and intraday imbalance.

• Statistical Extremes
Uses standard deviation over historical stretch values to identify abnormal price expansion zones instead of arbitrary levels.

• Volume Spike Detection
Highlights sudden participation increases that often appear during liquidity grabs, breakouts, reversals, or panic moves.

• ATR Regime Detection
Separates sleepy low-volatility conditions from active market phases. Useful for avoiding overtrading during dead sessions.

• 24h Volatility Engine
Calculates real market expansion using recent price range percentage. This provides a live reference for how aggressive or calm the market currently is.

• Volatility Ratio
Compares current volatility to average baseline volatility. Helps identify whether current conditions are compressed, normal, or highly unstable.

• Adaptive Leverage Reference
Suggests safer leverage levels dynamically based on current volatility conditions.
Higher volatility = lower suggested leverage.
ETH leverage is automatically adjusted lower because ETH typically moves more aggressively than BTC.

The script is NOT intended as a buy/sell signal generator. It is designed as a situational awareness system and market “weather station” to help traders:

* avoid emotional overexposure
* adapt leverage to volatility
* recognize stretched market conditions
* identify active vs dead regimes
* improve decision quality before entering trades

In simple terms:
this script tries to answer:
“What kind of market am I dealing with right now?”
before asking:
“Should I enter a trade?”

## Source Code

````pine
//@version=5
indicator("BTC Stretch Radar PRO", overlay=false)

// ======================================================
// INPUTS
// ======================================================

// Stretch system
emaLen          = input.int(21, "EMA Length")
lookback        = input.int(200, "Statistics Length")
mult            = input.float(2.0, "Extreme Multiplier")

// Volume
volLookback     = input.int(10, "Volume Lookback")
volMultiplier   = input.float(2.5, "Volume Spike Multiplier")

// ATR regime
atrLen          = input.int(14, "ATR Length")
atrFilterLen    = input.int(50, "ATR Baseline Length")

// Volatility engine
rangeLookback   = input.int(1440, "Range Lookback Candles")
rangeAvgLen     = input.int(7, "Range Average Length")

// Adaptive leverage
baseBTCLev      = input.float(50, "Base BTC Leverage")
ethVolFactor    = input.float(2.0, "ETH Volatility Factor")

// ======================================================
// CORE CALCULATIONS
// ======================================================

// Gravity centers
emaValue = ta.ema(close, emaLen)
vwapVal  = ta.vwap(close)

// Stretch calculations
stretchEMA  = (close - emaValue) / emaValue * 100
stretchVWAP = (close - vwapVal) / vwapVal * 100

// ======================================================
// STRETCH STATISTICS
// ======================================================

meanStretch = ta.sma(stretchEMA, lookback)
devStretch  = ta.stdev(stretchEMA, lookback)

upperExtreme = meanStretch + devStretch * mult
lowerExtreme = meanStretch - devStretch * mult

// ======================================================
// VOLUME SPIKES
// ======================================================

avgVol   = ta.sma(volume, volLookback)
volSpike = volume > avgVol * volMultiplier

// ======================================================
// VOLATILITY REGIME
// ======================================================

atr = ta.atr(atrLen)
atrBaseline = ta.sma(atr, atrFilterLen)

marketAwake = atr > atrBaseline
saturdayMode = atr < atrBaseline

// ======================================================
// 24H RANGE VOLATILITY
// ======================================================

// Highest and lowest price in selected range
highestPrice = ta.highest(high, rangeLookback)
lowestPrice  = ta.lowest(low, rangeLookback)

// Raw volatility %
rangePercent = ((highestPrice - lowestPrice) / lowestPrice) * 100

// Average volatility baseline
avgRange = ta.sma(rangePercent, rangeAvgLen)

// Relative volatility ratio
volatilityRatio = avgRange > 0 ? rangePercent / avgRange : 1

// ======================================================
// ADAPTIVE LEVERAGE
// ======================================================

// Dynamic leverage scaling
safeBTCLev = baseBTCLev / volatilityRatio

// ETH adjusted leverage
safeETHLev = safeBTCLev / ethVolFactor

// Prevent insanity
safeBTCLev := math.max(safeBTCLev, 1)
safeETHLev := math.max(safeETHLev, 1)

// ======================================================
// VOLATILITY STATES
// ======================================================

highVol = volatilityRatio > 1.5
lowVol  = volatilityRatio < 0.7

volState =
     highVol ? "HIGH VOL" :
     lowVol  ? "LOW VOL" :
     "NORMAL"

// ======================================================
// PLOTS
// ======================================================

// Stretch lines
plot(stretchEMA, "EMA Stretch %", color=color.orange, linewidth=2)
plot(stretchVWAP, "VWAP Stretch %", color=color.blue, linewidth=2)

// Statistical boundaries
plot(upperExtreme, "Upper Extreme", color=color.red)
plot(lowerExtreme, "Lower Extreme", color=color.green)

hline(0, "Equilibrium", color=color.gray)

// ======================================================
// BACKGROUNDS
// ======================================================

// Stretch extremes
bgcolor(
     stretchEMA > upperExtreme and marketAwake
     ? color.new(color.red, 85)
     : na)

bgcolor(
     stretchEMA < lowerExtreme and marketAwake
     ? color.new(color.green, 85)
     : na)

// Sleepy regime
bgcolor(
     saturdayMode
     ? color.new(color.gray, 92)
     : na)

// High volatility atmosphere
bgcolor(
     highVol
     ? color.new(color.orange, 93)
     : na)

// ======================================================
// VOLUME SPIKE MARKERS
// ======================================================

plotshape(
     volSpike,
     title="Volume Spike",
     location=location.top,
     style=shape.triangleup,
     color=color.yellow,
     size=size.tiny)

// ======================================================
// INFO TABLE
// ======================================================

var table statsTbl = table.new(
     position.bottom_left,
     2,
     9,
     border_width=1,
     frame_color=color.gray,
     border_color=color.gray)

// ======================================================
// TABLE UPDATE
// ======================================================

if barstate.islast

    // ===== COLORS =====
    bgMain   = color.rgb(10, 10, 10)
    bgHeader = color.rgb(0, 0, 0)

    // ===== SPACER ROWS =====
    table.cell(statsTbl, 0, 0, "", bgcolor=bgMain)
    table.cell(statsTbl, 1, 0, "", bgcolor=bgMain)

    table.cell(statsTbl, 0, 1, "", bgcolor=bgMain)
    table.cell(statsTbl, 1, 1, "", bgcolor=bgMain)

    // ===== HEADER =====
    table.cell(
         statsTbl, 0, 2,
         "Metric",
         bgcolor=bgHeader,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 2,
         "Value",
         bgcolor=bgHeader,
         text_color=color.white)

    // ===== VOLATILITY =====
    table.cell(
         statsTbl, 0, 3,
         "24h Vol %",
         bgcolor=bgMain,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 3,
         str.tostring(rangePercent, "#.##"),
         bgcolor=bgMain,
         text_color=color.aqua)

    // ===== VOL RATIO =====
    table.cell(
         statsTbl, 0, 4,
         "Vol Ratio",
         bgcolor=bgMain,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 4,
         str.tostring(volatilityRatio, "#.##"),
         bgcolor=bgMain,
         text_color=color.orange)

    // ===== REGIME =====
    table.cell(
         statsTbl, 0, 5,
         "Regime",
         bgcolor=bgMain,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 5,
         volState,
         bgcolor =
              highVol ? color.rgb(80,20,20) :
              lowVol  ? color.rgb(20,80,20) :
              color.rgb(80,60,20),
         text_color=color.white)

    // ===== BTC LEVERAGE =====
    table.cell(
         statsTbl, 0, 6,
         "BTC Lev",
         bgcolor=bgMain,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 6,
         "x" + str.tostring(safeBTCLev, "#"),
         bgcolor=bgMain,
         text_color=color.lime)

    // ===== ETH LEVERAGE =====
    table.cell(
         statsTbl, 0, 7,
         "ETH Lev",
         bgcolor=bgMain,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 7,
         "x" + str.tostring(safeETHLev, "#"),
         bgcolor=bgMain,
         text_color=color.yellow)

    // ===== ATR STATE =====
    table.cell(
         statsTbl, 0, 8,
         "ATR Mode",
         bgcolor=bgMain,
         text_color=color.white)

    table.cell(
         statsTbl, 1, 8,
         marketAwake ? "AWAKE" : "SLEEP",
         bgcolor =
              marketAwake
              ? color.rgb(20,70,20)
              : color.rgb(40,40,40),
         text_color=color.white)

// ======================================================
// ALERTS
// ======================================================

alertcondition(
     stretchEMA > upperExtreme and marketAwake,
     "Extreme Up Stretch",
     "Price extremely stretched above EMA")

alertcondition(
     stretchEMA < lowerExtreme and marketAwake,
     "Extreme Down Stretch",
     "Price extremely stretched below EMA")

alertcondition(
     volSpike and marketAwake,
     "Volume Spike",
     "Volume spike detected")
````
