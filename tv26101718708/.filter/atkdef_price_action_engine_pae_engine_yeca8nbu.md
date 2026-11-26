# ATK/DEF Price Action Engine PAE -ENGINE 

- url: https://www.tradingview.com/script/YEca8nbU/
- type: indicator
- pine_id: PUB;866c162fbaf844b489ebdfd78b106af4
- version: 1.0

## Description

PAE - Price Action Engine  is a custom market behavior analysis framework designed to study the interaction between candle structure, momentum development, liquidity activity, and price movement characteristics.

The idea behind PAE comes from the observation that price movement is not only defined by whether the market moves upward or downward. Each candle contains multiple layers of information, including body strength, wick rejection, volume participation, directional pressure, and movement consistency.

Traditional indicators usually focus on a single measurement source, such as price average, momentum calculation, or volume analysis. PAE takes a multi-dimensional approach by combining several independent analytical components into one structured observation system.

The purpose of PAE is not to predict future market movement, but to provide a visual representation of current market behavior through matheml analysis of price and volume data.

Core Concept

These concepts are visualized through multiple internal calcula instead of relying on a single traditional indicator formula.

Main Components
1. K TURN — Price Turning Behavior

K TURN analyzes changes in short-term price direction together with liquidity flow variation.

The calcula considers:

candle direction changes
candle body strength
CMF-based m flow changes
volume participation

The objective is to identify changes in market behavior intensity and observe when price movement characteristics begin to shift.

2. K MOMENTUM — Candle Momentum Measurement

K MOMENTUM evaluat the relationship between candle body strength and relative volume activity.

The calcula combines:

candle body efficiency
volume expansion
directional candle pressure

This creates a numerical representation of current movement strength based on candle behavior rather than only price distance.

3. K TIME TREND — Trend Structure Observation

K TIME TREND analyzes broader directional conditions through:

EMA relationship
price range expansion
candle strength

It also includes a trap index based on wick structure and candle efficiency to visualize situations where movement shows reduced confirmation.

4. FUND FLOW — Volume Flow Observation

FUND FLOW uses Chaikin Mon Flow (CMF) calculat to analyze the relationship between:

closing position inside candle range
volume participation
accumulation and distribution characteristics

It provides a view of volume-supported price activity.

5. K BEHAVIOR — Market Behavior Condition

K BEHAVIOR combines:

short-term momentum
medium-term momentum
acceleration changes
volume momentum
money flow condition

The goal is to measure consistency between different market measurements.

6. K LIQUIDITY PUSH — Movement Quality Analysis

K LIQUIDITY PUSH evalua whether strong candle movement is supported by:

body strength
volume expansion
wick structure
recent price expansion

It distinguishes different types of movement characteristics, including:

strong liquidity-supported movement
weak movement conditions
high-volume situations without efficient expansion
7. REAL K CONCENTRATION — Price Efficiency Measurement

REAL K CONCENTRATION measures candle efficiency by comparing:

current candle range
historical volatility conditions
recent price expansion

It helps visualize whether price activity is concentrated or dispersed.

Why PAE Is Different

Unlike traditional indicators that mainly answer one specific question, PAE combines several market behavior dimensions into one framework.

Instead of only measuring:

price direction
momentum level
volume change

PAE studies the relationship between:

how candles are formed
how pressure develops
how liquidity participates
how momentum changes
how efficiently price moves
Design Philosophy

PAE is built as a price behavior observation tool.

It does not provide finan advice, guaran outcomes, or future predictions.

The purpose of this indicator is to help users analyze the internal characteristics of market movement through a structured combination of candle analysis, liquidity measurement, and momentum observation.

## Source Code

````pine
//@version=6
indicator(" PAE ", overlay=false, precision=2)

// ============================================================
// 1. Raw Candle Data
// ============================================================
body = math.abs(close - open)
candleRange = high - low

upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

upperWickRatio = candleRange > 0 ? upperWick / candleRange : 0
lowerWickRatio = candleRange > 0 ? lowerWick / candleRange : 0
bodyStrength = candleRange > 0 ? (close - open) / candleRange : 0
bodyPct = candleRange > 0 ? body / candleRange : 0

// ============================================================
// 2. Money Flow (CMF)
// ============================================================
moneyFlowMultiplier = candleRange > 0 ? ((close - low) - (high - close)) / candleRange : 0
moneyFlowVolume = moneyFlowMultiplier * volume

sumVolume = math.sum(volume, 20)
cmf = sumVolume > 0 ? math.sum(moneyFlowVolume, 20) / sumVolume : 0

volumeMA = ta.sma(volume, 20)
volumeRatio = volumeMA > 0 ? volume / volumeMA : 1

// ============================================================
// 3. K TURN
// ============================================================
priceDirection = close > close[1] ? 1 : (close < close[1] ? -1 : 0)
prevPriceDirection = close[1] > close[2] ? 1 : (close[1] < close[2] ? -1 : 0)
priceTurn = priceDirection != prevPriceDirection and priceDirection != 0

cmfDirection = cmf > cmf[1] ? 1 : (cmf < cmf[1] ? -1 : 0)
prevCmfDirection = cmf[1] > cmf[2] ? 1 : (cmf[1] < cmf[2] ? -1 : 0)
cmfTurn = cmfDirection != prevCmfDirection and cmfDirection != 0

volumeSurge = volumeRatio > 1.2
priceConfirm = math.abs(bodyStrength) > 0.1

turnStrength = 0.0
if priceTurn and cmfTurn and volumeSurge and priceConfirm
    turnStrength := (priceDirection + cmfDirection) / 2 * 1.5
else if (priceTurn or cmfTurn) and volumeSurge and priceConfirm
    turnStrength := (priceDirection + cmfDirection) / 2 * 0.7

turnStrength := turnStrength > 1 ? 1 : (turnStrength < -1 ? -1 : turnStrength)

turnLabel = turnStrength > 0.5 ? "Strong Bull Turn" : turnStrength > 0.15 ? "Mild Bull Turn" : turnStrength < -0.5 ? "Strong Bear Turn" : turnStrength < -0.15 ? "Mild Bear Turn" : "No Turn"
turnColor = turnStrength > 0.15 ? color.green : turnStrength < -0.15 ? color.red : color.gray

// ============================================================
// 4. K MOMENTUM
// ============================================================
volumeRatioClamp = volumeRatio > 3 ? 3 : (volumeRatio < 0.3 ? 0.3 : volumeRatio)
rawBull = bodyStrength > 0 ? bodyStrength * volumeRatioClamp : 0
rawBear = bodyStrength < 0 ? -bodyStrength * volumeRatioClamp : 0

netMomentumRaw = ta.sma(rawBull, 3) - ta.sma(rawBear, 3)
netMomentum = netMomentumRaw > 2 ? 2 : (netMomentumRaw < -2 ? -2 : netMomentumRaw)

momentumLabel = netMomentum > 1.2 ? "Extreme Bull" : netMomentum > 0.6 ? "Strong Bull" : netMomentum > 0.2 ? "Mild Bull" : netMomentum < -1.2 ? "Extreme Bear" : netMomentum < -0.6 ? "Strong Bear" : netMomentum < -0.2 ? "Mild Bear" : "Neutral"
momentumColor = netMomentum > 0.2 ? color.green : netMomentum < -0.2 ? color.red : color.gray

// ============================================================
// 5. K TIME TREND
// ============================================================
ema20 = ta.ema(close, 20)
ema60 = ta.ema(close, 60)
trendDirection = ema20 > ema60 ? 1 : (ema20 < ema60 ? -1 : 0)

priceRange = (high - low) / close * 100
emaSpread = math.abs(ema20 - ema60) / close * 100

trendStrength = (priceRange * 0.3) + (emaSpread * 0.5) + (math.abs(bodyStrength) * 0.2)
trendStrength := trendStrength > 1.5 ? 1.5 : trendStrength
trendStrengthNorm = trendStrength / 1.5

trapIndex = (upperWickRatio + lowerWickRatio) * (1 + (1 - bodyPct))
trapIndex := trapIndex > 1 ? 1 : (trapIndex < 0 ? 0 : trapIndex)

trendLabel = trendDirection > 0 and trendStrengthNorm > 0.5 ? "Bull Time Trend" : trendDirection > 0 ? "Weak Bull Time Trend" : trendDirection < 0 and trendStrengthNorm > 0.5 ? "Bear Time Trend" : trendDirection < 0 ? "Weak Bear Time Trend" : "Sideways"
trendColor = trendDirection > 0 ? color.green : trendDirection < 0 ? color.red : color.gray

trapLabel = trapIndex > 0.6 ? "High Trap Risk" : trapIndex > 0.35 ? "Medium Trap Risk" : "Low Trap Risk"
trapColor = trapIndex > 0.6 ? color.rgb(255, 50, 50) : trapIndex > 0.35 ? color.rgb(255, 200, 0) : color.rgb(0, 200, 255)

// ============================================================
// 6. FUND FLOW
// ============================================================
fundDirectionLabel = cmf > 0.2 ? "Strong Inflow" : cmf > 0.08 ? "Mild Inflow" : cmf < -0.2 ? "Strong Outflow" : cmf < -0.08 ? "Mild Outflow" : "Neutral"
fundDirectionColor = cmf > 0.08 ? color.green : cmf < -0.08 ? color.red : color.gray

// ============================================================
// 7. K BEHAVIOR
// ============================================================
priceMomentumShortNorm = (close - close[3]) / close * 100
priceMomentumMidNorm = (close - close[10]) / close * 100
priceAcceleration = priceMomentumShortNorm - (close[3] - close[6]) / close[3] * 100
volumeMomentumNorm = (volumeMA - volumeMA[5]) / volumeMA * 100

behaviorIndex = (priceMomentumShortNorm * 0.3) + (priceMomentumMidNorm * 0.2) + (priceAcceleration * 0.2) + (volumeMomentumNorm * 0.15) + (cmf * 20 * 0.15)
behaviorIndex := behaviorIndex > 5 ? 5 : (behaviorIndex < -5 ? -5 : behaviorIndex)

bullishConsistent = priceMomentumShortNorm > 0 and priceMomentumMidNorm > 0 and priceAcceleration > 0 and cmf > 0
bearishConsistent = priceMomentumShortNorm < 0 and priceMomentumMidNorm < 0 and priceAcceleration < 0 and cmf < 0

behaviorLabel = bullishConsistent and behaviorIndex > 2 ? "🔥 Strong Bullish" : bullishConsistent and behaviorIndex > 0.5 ? "📈 Mild Bullish" : bearishConsistent and behaviorIndex < -2 ? "❄️ Strong Bearish" : bearishConsistent and behaviorIndex < -0.5 ? "📉 Mild Bearish" : behaviorIndex > 1 and not bearishConsistent ? "📊 Bullish Divergence" : behaviorIndex < -1 and not bullishConsistent ? "📊 Bearish Divergence" : "⏸️ Neutral"
behaviorColor = behaviorIndex > 0.5 ? color.green : behaviorIndex < -0.5 ? color.red : color.gray

// ============================================================
// 8. K LIQUIDITY PUSH
// ============================================================
highest20 = ta.highest(high, 20)
lowest20 = ta.lowest(low, 20)
newHigh = close > highest20[1]
newLow = close < lowest20[1]

liquidityPushBull = bodyStrength > 0.2 and volumeRatio > 1.2 and upperWickRatio < 0.35 and (trendDirection >= 0 or newHigh)
liquidityPushBear = bodyStrength < -0.2 and volumeRatio > 1.2 and lowerWickRatio < 0.35 and (trendDirection <= 0 or newLow)
fakeLiquidityPushBull = bodyStrength > 0.2 and volumeRatio > 1.2 and upperWickRatio > 0.4 and (trendDirection <= 0 or not newHigh)
fakeLiquidityPushBear = bodyStrength < -0.2 and volumeRatio > 1.2 and lowerWickRatio > 0.4 and (trendDirection >= 0 or not newLow)

realLiquidityPush = liquidityPushBull or liquidityPushBear
fakeLiquidityPush = fakeLiquidityPushBull or fakeLiquidityPushBear

pushStrength = math.abs(bodyStrength) * volumeRatio * (1 + math.abs(trendDirection))
pushStrengthNorm = pushStrength > 2.5 ? 2.5 : pushStrength

pushLabel = realLiquidityPush ? "✅ Real Liquidity Push" : fakeLiquidityPush ? "⚠️ Fake Liquidity Push" : volumeRatio > 1.3 and math.abs(bodyStrength) < 0.2 ? "💥 Liquidity Spike No Push" : math.abs(bodyStrength) > 0.3 and volumeRatio < 0.7 ? "⚡ Push Low Liquidity" : "➖ No Liquidity Push"
pushColor = realLiquidityPush ? color.green : fakeLiquidityPush ? color.rgb(255, 200, 0) : volumeRatio > 1.3 and math.abs(bodyStrength) < 0.2 ? color.rgb(255, 100, 200) : math.abs(bodyStrength) > 0.3 and volumeRatio < 0.7 ? color.rgb(0, 200, 255) : color.gray

// ============================================================
// 9. REAL K CONCENTRATION
// ============================================================
trueRange = math.max(high, close[1]) - math.min(low, close[1])
atr14 = ta.rma(trueRange, 14)
volatilityRatio = candleRange / (atr14 + 0.001)

volatilityPercentile = 0.0
for i = 0 to 19
    if candleRange > (high[i] - low[i])
        volatilityPercentile := volatilityPercentile + 1
volatilityPercentile := volatilityPercentile / 20

rawRealConcentration = 1 - (volatilityRatio > 1.5 ? 1.5 : volatilityRatio) / 1.5
realConcentration = (rawRealConcentration * 0.6) + ((1 - volatilityPercentile) * 0.4)
smoothRealConcentration = ta.sma(realConcentration, 5)

concentrationLabel = smoothRealConcentration > 0.65 ? "High Concentration" : smoothRealConcentration > 0.35 ? "Medium Concentration" : "Low Concentration"
concentrationColor = smoothRealConcentration > 0.65 ? color.rgb(255, 200, 0) : smoothRealConcentration > 0.35 ? color.rgb(0, 200, 255) : color.rgb(200, 100, 255)

// ============================================================
// 10. Plot Indicators
// ============================================================
hline(0.7, "Heavy Sell", color=color.new(color.white,0), linestyle=hline.style_dashed)
plot(upperWickRatio, title="Upper Wick", color=color.new(color.red, 60), linewidth=2, style=plot.style_area)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
plot(bodyStrength, title="Body Strength", color=color.new(color.green, 0), linewidth=2, style=plot.style_histogram)
plot(cmf, title="CMF", color=color.rgb(8, 217, 249), linewidth=2)

// ============================================================
// 11. Info Panel
// ============================================================
color border = color.rgb(60, 100, 140, 60)
color cyan = color.rgb(0, 220, 255)
color dim = color.rgb(140, 165, 185)

var table info = table.new(position.bottom_right, 2, 14,
     bgcolor=color.new(color.black, 0),
     border_width=1,
     border_color=border)

if barstate.islast
    table.cell(info, 0, 0, "◆ PAE", text_color=cyan, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(info, 1, 0, " MONITOR", text_color=cyan, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    
    table.cell(info, 0, 1, "K TURN", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 1, str.tostring(turnStrength, "#0.00") + " " + turnLabel, text_color=turnColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 2, "K MOMENTUM", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 2, str.tostring(netMomentum, "#0.00") + " " + momentumLabel, text_color=momentumColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 3, "K TIME TREND", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 3, trendLabel + " | " + trapLabel, text_color=trendColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 4, "FUND FLOW", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 4, fundDirectionLabel + " (" + str.tostring(cmf, "#0.00") + ")", text_color=fundDirectionColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 5, "K BEHAVIOR", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 5, str.tostring(behaviorIndex, "#0.00") + " " + behaviorLabel, text_color=behaviorColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 6, "K LIQUIDITY PUSH", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 6, str.tostring(pushStrengthNorm, "#0.00") + " " + pushLabel, text_color=pushColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 7, "REAL K CONCENTRATION", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 7, str.tostring(smoothRealConcentration, "#0.00") + " " + concentrationLabel, text_color=concentrationColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    
    table.cell(info, 0, 8, "─────────────────────", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(info, 1, 8, "─────────────────────", text_color=dim, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
    
    statusColor = color.white
    statusText = ""
    if realLiquidityPush and bodyStrength > 0 and cmf > 0.08
        statusText := "🔥 STRONG BUY"
        statusColor := color.rgb(0, 230, 140)
    else if realLiquidityPush and bodyStrength < 0 and cmf < -0.08
        statusText := "❄️ STRONG SELL"
        statusColor := color.rgb(255, 60, 60)
    else if fakeLiquidityPush and bodyStrength > 0
        statusText := "⚠️ FAKE BULL · CAUTION"
        statusColor := color.rgb(255, 200, 0)
    else if fakeLiquidityPush and bodyStrength < 0
        statusText := "⚠️ FAKE BEAR · CAUTION"
        statusColor := color.rgb(255, 200, 0)
    else if cmf > 0 and bodyStrength > 0
        statusText := "📈 BULLISH · ACTIVE"
        statusColor := color.rgb(0, 200, 255)
    else if cmf < 0 and bodyStrength < 0
        statusText := "📉 BEARISH · ALERT"
        statusColor := color.rgb(255, 200, 0)
    else
        statusText := "⏸️ NEUTRAL · MONITOR"
        statusColor := color.rgb(140, 165, 185)
    
    table.cell(info, 0, 9, "◆", text_color=statusColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_right)
    table.cell(info, 1, 9, statusText, text_color=statusColor, bgcolor=color.new(color.black, 0), text_size=size.small, text_halign=text.align_left)
````
