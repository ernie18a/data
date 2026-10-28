# Final  June 14-2026 - Ultimate Stochastic & ADX Exhaustion V17

- url: https://www.tradingview.com/script/P7ruNYDD-Final-June-14-2026-Ultimate-Stochastic-ADX-Exhaustion-V17/
- type: indicator
- pine_id: PUB;2815e51222a64eeb905f5d3adf09c02e
- version: 1.0

## Description

it identifies tops and bottoms - stochastics and some filters

## Source Code

````pine
//@version=6
indicator("Ultimate Stochastic & ADX Exhaustion V17", overlay = true)

// --- Group Constants ---
G_PERIODS   = "Stochastic Periods"
G_THRESH    = "Extreme Thresholds"
G_FILTERS   = "Advanced Exhaustion Filters"
G_ADX       = "ADX Trend Strength Filters (No MA)"
G_VOL_VOLAT = "Volume & Volatility Filters"
G_STYLE     = "Style"

// --- Inputs ---
k1 = input.int(9, "Stoch 1 %K", group = G_PERIODS)
d1 = input.int(3, "Stoch 1 %D", group = G_PERIODS)

k2 = input.int(14, "Stoch 2 %K", group = G_PERIODS)
d2 = input.int(3, "Stoch 2 %D", group = G_PERIODS)

k3 = input.int(40, "Stoch 3 %K", group = G_PERIODS)
d3 = input.int(4, "Stoch 3 %D", group = G_PERIODS)

k4 = input.int(60, "Stoch 4 %K", group = G_PERIODS)
d4 = input.int(10, "Stoch 4 %D", group = G_PERIODS)

useTightLevels = input.bool(false, "Use 90/10 Levels (Instead of 80/20)", group = G_THRESH)
overbought = useTightLevels ? 90 : 80
oversold   = useTightLevels ? 10 : 20

// Toggles for Advanced Filters
mainSource     = input.string("Stoch 4", "Main Signal Trigger Stoch", options = ["Stoch 1", "Stoch 2", "Stoch 3", "Stoch 4"], group = G_FILTERS)
contSource     = input.string("Stoch 3", "Continuation Dot Trigger Stoch", options = ["Stoch 1", "Stoch 2", "Stoch 3", "Stoch 4"], group = G_FILTERS)
filterCandle   = input.bool(true, "Require Matching Candle Color (Green Buy/Red Sell)", group = G_FILTERS)
filterStructure = input.bool(true, "Require Price Pivot Confirmation", group = G_FILTERS)
pivotLookback  = input.int(3, "Price Pivot Lookback Bars", minval = 1, maxval = 10, group = G_FILTERS)

// ADX Filters
useAdxFilter   = input.bool(true, "Require ADX Trend Exhaustion", group = G_ADX, tooltip = "Ensures a powerful trend was established and is now dying out before printing a reversal.")
adxLength      = input.int(14, "ADX Smoothing Length", group = G_ADX)
adxThreshold   = input.int(25, "Minimum ADX Peak Level", group = G_ADX, tooltip = "ADX must have scaled above this number during the trend to qualify it as strong enough to collapse.")

// Volume & Volatility Switches
useVolFilter   = input.bool(false, "Require Volume Climax Filter", group = G_VOL_VOLAT)
volLookback    = input.int(14, "Volume SMA Lookback", group = G_VOL_VOLAT)
useAtrFilter   = input.bool(false, "Require Minimum Volatility (ATR)", group = G_VOL_VOLAT)
atrLookback    = input.int(14, "ATR Lookback", group = G_VOL_VOLAT)

bullColor = input.color(#089981, "Buy Color", group = G_STYLE)
bearColor = input.color(#f23645, "Sell Color", group = G_STYLE)

// --- Calculations ---
stoch1D = ta.sma(ta.stoch(close, high, low, k1), d1)
stoch2D = ta.sma(ta.stoch(close, high, low, k2), d2)
stoch3D = ta.sma(ta.stoch(close, high, low, k3), d3)
stoch4D = ta.sma(ta.stoch(close, high, low, k4), d4)

float activeD = switch mainSource
    "Stoch 1" => stoch1D
    "Stoch 2" => stoch2D
    "Stoch 3" => stoch3D
    "Stoch 4" => stoch4D
    => stoch4D

float activeContStoch = switch contSource
    "Stoch 1" => stoch1D
    "Stoch 2" => stoch2D
    "Stoch 3" => stoch3D
    "Stoch 4" => stoch4D
    => stoch3D

// --- ADX Technical Logic ---
// True ADX calculation requires tracking Directional Movement (+DI and -DI)
[plusDI, minusDI, adxValue] = ta.dmi(adxLength, adxLength)

// Track if ADX historically climbed into heavy trend territory since the Stochastic entered its extreme zone
var bool adxExceededThreshold = false
if activeD <= oversold or activeD >= overbought
    if adxValue >= adxThreshold
        adxExceededThreshold := true

// ADX is falling when its current value is lower than its previous bar value
adxFalling = adxValue < adxValue[1]
passADX    = not useAdxFilter or (adxExceededThreshold and adxFalling)

// --- 50-Line Macro Exhaustion Logic ---
var bool visitedOversold   = false
var bool visitedOverbought = false

if activeD <= oversold
    visitedOversold := true
if activeD >= overbought
    visitedOverbought := true

// Reset safety clamp if it cross extremes without hitting 50
if activeD >= overbought and visitedOversold
    visitedOversold := false
    adxExceededThreshold := false
if activeD <= oversold and visitedOverbought
    visitedOverbought := false
    adxExceededThreshold := false

// Base 50-Cross Signals
baseBuy  = ta.crossover(activeD, 50) and visitedOversold
baseSell = ta.crossunder(activeD, 50) and visitedOverbought

// --- Filter Validations ---

// 1. Candle Color Confirmation
candleBull = close > open
candleBear = close < open
passCandleBuy  = not filterCandle or candleBull
passCandleSell = not filterCandle or candleBear

// 2. Market Structure Confirmation
priceStructureBuy  = not filterStructure or (low > ta.lowest(low, pivotLookback)[1])
priceStructureSell = not filterStructure or (high < ta.highest(high, pivotLookback)[1])

// 3. Volume Filter
avgVol = ta.sma(volume, volLookback)
passVolume = not useVolFilter or (volume > avgVol)

// 4. ATR Volatility Filter
myAtr = ta.atr(atrLookback)
avgAtr = ta.sma(myAtr, 50)
passVolatility = not useAtrFilter or (myAtr > avgAtr * 0.8)

// Combined Master Signals
bool buySignal  = baseBuy and passCandleBuy and priceStructureBuy and passVolume and passVolatility and passADX
bool sellSignal = baseSell and passCandleSell and priceStructureSell and passVolume and passVolatility and passADX

// Reset all state machine trackers upon successful execution
if buySignal
    visitedOversold := false
    adxExceededThreshold := false
if sellSignal
    visitedOverbought := false
    adxExceededThreshold := false

// --- Continuation Logic (50-line crosses) ---
contUp   = ta.crossover(activeContStoch, 50)
contDown = ta.crossunder(activeContStoch, 50)

var bool bullMode = false
var bool bearMode = false

if buySignal
    bullMode := true
    bearMode := false
if sellSignal
    bullMode := false
    bearMode := true

contBuy  = bullMode and contUp
contSell = bearMode and contDown

// --- Visual Layout (Retaining Direct Anchor Mapping) ---
plotshape(
     series    = buySignal, 
     title     = "Ultimate ADX Buy", 
     location  = location.belowbar, 
     style     = shape.labelup, 
     color     = bullColor, 
     text      = "✔", 
     textcolor = color.white, 
     size      = size.large
     )

plotshape(
     series    = sellSignal, 
     title     = "Ultimate ADX Sell", 
     location  = location.abovebar, 
     style     = shape.labeldown, 
     color     = bearColor, 
     text      = "✖", 
     textcolor = color.white, 
     size      = size.large
     )

plotshape(
     series    = contBuy, 
     title     = "Bull Continuation Dot", 
     location  = location.belowbar, 
     style     = shape.circle, 
     color     = bullColor, 
     size      = size.tiny
     )

plotshape(
     series    = contSell, 
     title     = "Bear Continuation Dot", 
     location  = location.abovebar, 
     style     = shape.circle, 
     color     = bearColor, 
     size      = size.tiny
     )
````
