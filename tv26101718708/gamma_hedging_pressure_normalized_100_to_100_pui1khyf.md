# Gamma Hedging Pressure (Normalized -100 to +100)

- url: https://www.tradingview.com/script/puI1KhyF-Gamma-Hedging-Pressure-Normalized-100-to-100/
- type: indicator
- pine_id: PUB;00f81743af394e02a2a79fdfa2b9c136
- version: 2.0

## Description

[b]Gamma Hedging Pressure PRO (Normalized –100 to +100) [Invite-Only][/b]

[b]Overview:
[/b]
Gamma Hedging Pressure PRO is a normalized dealer-flow oscillator designed to measure relative hedging pressure in a clean, automation-friendly format.

This version transforms raw gamma pressure into a standardized –100 to +100 range, making it consistent across different stocks, indices, and ETFs.

The normalization allows traders to use identical alert thresholds on any symbol without having to reconfigure values per instrument.

[b]Why Normalization Matters:
[/b]
Raw gamma values vary significantly across assets due to differences in volatility and price structure.

By mapping pressure to a bounded –100 → +100 range:

• +100 represents maximum bullish gamma pressure within the selected lookback
• 0 represents neutral pressure
• –100 represents maximum bearish gamma pressure

This makes the indicator:

[list]
[*]Automation friendly
[*]
[*]Portfolio consistent
[*]
[*]Screener compatible
[*]
[*]Alert standardized
[/list]

[b]Key Features:[/b]

✔ Normalized –100 to +100 scaling
✔ Rolling lookback adaptive structure
✔ Optional EMA smoothing
✔ Extreme pressure level detection
✔ Universal alert thresholds
✔ Works across stocks, indices, ETFs, futures:


[b]How to Use
[/b]
Suggested framework:
[list]
[*]
[*]+70 to +100 → Strong bullish gamma pressure
[*]+80 to +100 → Extreme squeeze conditions
[*]–70 to –100 → Strong bearish gamma pressure
[*]–80 to –100 → Capitulation risk
[/list]

Zero line crossovers can be used for directional bias shifts.

This indicator is best used in confluence with:

• Price structure
• Liquidity zones
• Volume analysis
• Trend context

It is not a standalone trading system.

[b]Automation & Alerts[/b]

Because the values are normalized, traders can deploy identical alert logic across multiple symbols without manual recalibration.

Example:

[list]
[*]Alert when Gamma > 80
[*]Alert when Gamma < –80
[*]Alert on zero crossover
[/list]

This significantly simplifies webhook and bot integration.

[b]Disclaimer:
[/b]
This script does not use proprietary options order flow data. It provides a proxy-based gamma pressure model for analytical purposes only. It does not constitute financial advice.

## Source Code

````pine
//@version=6
indicator("Gamma Hedging Pressure PRO (0–100 / 0–100)", overlay = false)

//------------------------------------------------------------
// 🔹 INPUTS
//------------------------------------------------------------

gammaLength   = input.int(20,  "Gamma Calculation Length")
normLookback  = input.int(100, "Normalization Lookback")
useSmoothing  = input.bool(true, "Enable EMA Smoothing")
smoothLength  = input.int(5,   "EMA Length")
extremeLevel  = input.int(70,  "Extreme Level", minval = 50, maxval = 100)

//------------------------------------------------------------
// 🔹 RAW GAMMA MODEL (Proxy)
// Replace this section with your proprietary logic if needed
//------------------------------------------------------------

volatility = ta.stdev(close, gammaLength)
momentum   = close - close[gammaLength]
gammaRaw   = momentum / math.max(volatility, 0.00001)

//------------------------------------------------------------
// 🔹 NORMALIZE TO -100 → +100 (INTERNAL)
//------------------------------------------------------------

lowestVal  = ta.lowest(gammaRaw, normLookback)
highestVal = ta.highest(gammaRaw, normLookback)
rangeVal   = math.max(highestVal - lowestVal, 0.00001)

gammaNorm = 200 * (gammaRaw - lowestVal) / rangeVal - 100

//------------------------------------------------------------
// 🔹 OPTIONAL SMOOTHING
//------------------------------------------------------------

gammaFinal = useSmoothing ? ta.ema(gammaNorm, smoothLength) : gammaNorm

//------------------------------------------------------------
// 🔹 SPLIT INTO 0–100 / 0–100 FORMAT
//------------------------------------------------------------

bullPressure = math.max(gammaFinal, 0)
bearPressure = math.abs(math.min(gammaFinal, 0))

//------------------------------------------------------------
// 🔹 PLOTS (COG-STYLE VISUAL)
//------------------------------------------------------------

plot(bullPressure, title="Bullish Gamma Pressure",
     color=color.green, linewidth=2)

plot(bearPressure, title="Bearish Gamma Pressure",
     color=color.red, linewidth=2)

hline(extremeLevel, "Extreme Level", color=color.gray)
hline(0, "Zero Line", color=color.gray)

// Background highlight for extremes
bgcolor(bullPressure > extremeLevel ? color.new(color.green, 85) :
       bearPressure > extremeLevel ? color.new(color.red, 85) :
       na)

//------------------------------------------------------------
// 🔹 ALERT CONDITIONS
//------------------------------------------------------------

alertcondition(bullPressure > extremeLevel,
     title="Extreme Bullish Gamma",
     message="Bullish Gamma Pressure above threshold")

alertcondition(bearPressure > extremeLevel,
     title="Extreme Bearish Gamma",
     message="Bearish Gamma Pressure above threshold")

alertcondition(ta.crossover(bullPressure, extremeLevel),
     title="Bullish Pressure Rising",
     message="Bullish Gamma crossing extreme level")

alertcondition(ta.crossover(bearPressure, extremeLevel),
     title="Bearish Pressure Rising",
     message="Bearish Gamma crossing extreme level")
````
