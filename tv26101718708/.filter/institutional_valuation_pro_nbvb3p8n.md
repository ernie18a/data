# Institutional Valuation PRO

- url: https://www.tradingview.com/script/nBVb3p8N/
- type: indicator
- pine_id: PUB;607fe2173bb0451fb49485efd06ae377
- version: 1.0

## Description

Institutional Relative Valuation Indicator

This indicator is designed to measure whether an asset is relatively overvalued or undervalued compared to a benchmark market.

For Forex markets, the indicator compares the selected currency pair against the US Dollar Index (DXY).

For Metals, the indicator compares the selected metal against Gold Futures (GC1!).

The model is based on:

* Relative price strength
* Statistical deviation
* Mean reversion principles
* Institutional relative valuation concepts

How it works:

1. The indicator calculates the relationship between the asset and its benchmark.
2. It measures the historical average behavior over a selected lookback period.
3. It then calculates how far the current price relationship deviates from its normal range.

The result is a valuation score that helps identify:

* Overvalued conditions
* Undervalued conditions
* Fair value areas
* Extreme market extensions

Key Features:

* USD-based valuation model for FX
* Gold-based valuation model for Metals
* Smooth institutional-style valuation curves
* Professional premium/discount zones
* Overvaluation and undervaluation levels
* Optional benchmark visibility controls
* Mean reversion focused framework

This indicator is not designed as a traditional momentum tool like RSI or MACD. Instead, it focuses on relative market valuation and statistical market positioning, similar to concepts used in institutional macro and relative-value trading.

## Source Code

````pine
//@version=5
indicator("Institutional Valuation PRO", overlay=false)

//====================================================
// INPUTS
//====================================================

length        = input.int(120, "Lookback Length")
smoothLength  = input.int(10, "Smoothing")

showUSD       = input.bool(true, "Show USD Valuation")
showGold      = input.bool(true, "Show Gold Valuation")

//====================================================
// BENCHMARKS
//====================================================

// Dollar Index
dxy = request.security("TVC:DXY", timeframe.period, close)

// Gold Futures (GC)
gold = request.security("COMEX:GC1!", timeframe.period, close)

// Aktuelles Asset
asset = close

//====================================================
// VALUATION FUNCTION
//====================================================

f_valuation(src, benchmark) =>
    
    rel = src / benchmark
    
    mean = ta.sma(rel, length)
    dev  = ta.stdev(rel, length)
    
    z = (rel - mean) / dev
    
    // Professioneller geglätteter Score
    ta.ema(z * 50, smoothLength)

//====================================================
// CALCULATIONS
//====================================================

usdVal  = f_valuation(asset, dxy)
goldVal = f_valuation(asset, gold)

//====================================================
// COLORS
//====================================================

// Hellblau für USD
usdColor =
     usdVal > 75  ? color.rgb(0, 220, 255) :
     usdVal > 40  ? color.rgb(0, 180, 240) :
     usdVal < -75 ? color.rgb(0, 70, 120) :
     color.rgb(80, 200, 255)

// Goldgelb für Gold
goldColor =
     goldVal > 75  ? color.rgb(255, 220, 0) :
     goldVal > 40  ? color.rgb(240, 190, 0) :
     goldVal < -75 ? color.rgb(140, 110, 0) :
     color.rgb(255, 215, 50)

//====================================================
// PLOTS
//====================================================

// USD Linie
plot(
     showUSD ? usdVal : na,
     title="USD Valuation",
     color=usdColor,
     linewidth=3)

// Gold Linie
plot(
     showGold ? goldVal : na,
     title="Gold Valuation",
     color=goldColor,
     linewidth=3)

//====================================================
// PROFESSIONAL VALUATION ZONES
//====================================================

// Extreme Overvaluation
upperExtreme = hline(
     100,
     "Extreme Overvaluation",
     color=color.new(color.red, 30),
     linestyle=hline.style_dashed)

// Overvaluation
upper = hline(
     75,
     "Overvalued",
     color=color.new(color.red, 0))

// Fair Value Upper
upperMid = hline(
     25,
     "Premium",
     color=color.new(color.gray, 70),
     linestyle=hline.style_dotted)

// Fair Value
middle = hline(
     0,
     "Fair Value",
     color=color.new(color.white, 40),
     linestyle=hline.style_solid)

// Fair Value Lower
lowerMid = hline(
     -25,
     "Discount",
     color=color.new(color.gray, 70),
     linestyle=hline.style_dotted)

// Undervaluation
lower = hline(
     -75,
     "Undervalued",
     color=color.new(color.green, 0))

// Extreme Undervaluation
lowerExtreme = hline(
     -100,
     "Extreme Undervaluation",
     color=color.new(color.green, 30),
     linestyle=hline.style_dashed)

//====================================================
// BACKGROUND ZONES
//====================================================

// Premium Zone
fill(upper, upperExtreme, color.new(color.red, 92))

// Discount Zone
fill(lower, lowerExtreme, color.new(color.green, 92))

//====================================================
// ALERTS
//====================================================

alertcondition(
     usdVal > 75,
     title="USD Overvalued",
     message="Asset is OVERVALUED vs USD")

alertcondition(
     usdVal < -75,
     title="USD Undervalued",
     message="Asset is UNDERVALUED vs USD")

alertcondition(
     goldVal > 75,
     title="Gold Overvalued",
     message="Asset is OVERVALUED vs GOLD")

alertcondition(
     goldVal < -75,
     title="Gold Undervalued",
     message="Asset is UNDERVALUED vs GOLD")
````
