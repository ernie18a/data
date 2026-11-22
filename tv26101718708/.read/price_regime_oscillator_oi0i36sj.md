# Price Regime Oscillator

- url: https://www.tradingview.com/script/OI0i36SJ-Price-Regime-Oscillator/
- type: indicator
- pine_id: PUB;cc18901028f244c3ae471b26440634f9
- version: 2.0

## Description

📊 Price Regime Oscillator (PRC)
🧠 Overview

Price Regime Oscillator (PRC) is a custom-built market regime indicator designed to detect trend direction and momentum shifts using a normalized price-change approach.

Unlike traditional oscillators, PRC focuses on relative price movement over a defined lookback period, then smooths it to produce a cleaner signal. The result is a dynamic regime filter that can be used for both trend identification and entry confirmation.

This indicator is built on the previous PRC Market Regime Indicator, now directly integrated onto the chart. The PRC logic drives the visual representation through the EMA line and candle coloring, providing a clearer and more practical real-time application.

This version integrates PRC directly into the chart by driving:

EMA color (trend filter)
Candle coloring (market bias)
⚙️ How It Works

The core logic is based on:

Price change over a selected period (PRC Length)
Smoothing via EMA (PRC Smoothing)
Signal line using EMA of PRC (EMA Length)
🔑 Signals:
Bullish Regime
PRC crosses ABOVE its EMA
EMA turns green
Candles turn green
Bearish Regime
PRC crosses BELOW its EMA
EMA turns red
Candles turn red
Neutral
No active crossover
No coloring applied
📈 How To Use
✅ Trend Filter

Use EMA color as a simple trend filter:

Green → look for BUY setups
Red → look for SELL setups
✅ Entry Confirmation

Combine with your strategy:

Enter after PRC crossover confirmation
Or wait for pullback while trend color remains active
✅ Best Use Case

Works best in:

Trending markets
Breakout environments

⚠️ Like all indicators, performance may degrade in sideways (range-bound) conditions.

⚙️ Inputs
PRC Length → Lookback period for price change
PRC Smoothing → Noise reduction on PRC
EMA Length → Signal sensitivity
🎯 Key Features
Clean trend visualization directly on chart
PRC-based momentum logic (not standard EMA crossover)
Non-repainting (based on confirmed bar close)
Lightweight and fast
⚠️ Disclaimer

This indicator is provided for educational and analytical purposes only.
It does not constitute financial advice. Always use proper risk management and test any strategy before applying it in live trading.

## Source Code

````pine
//@version=6
indicator("Price Regime Oscillator", overlay=true)

//========================
// INPUTS
//========================
pcrLen      = input.int(80, "PRC Length")
smoothLen   = input.int(3, "PRC Smoothing")
emaLen      = input.int(10, "EMA Length")

//========================
// PRC (ENGINE)
//========================
priceChange = close - close[pcrLen]
prc = ta.ema(priceChange, smoothLen)
prcEMA = ta.ema(prc, emaLen)

//========================
// PRC TREND
//========================
breakUp   = ta.crossover(prc, prcEMA)
breakDown = ta.crossunder(prc, prcEMA)

var int trend = 0

if breakUp
    trend := 1
else if breakDown
    trend := -1

//========================
// EMA NA CENI (NORMALNA)
//========================
ema = ta.ema(close, emaLen)

//========================
// BOJA EMA (PRC FILTER)
//========================
emaColor = trend == 1 ? color.lime : trend == -1 ? color.red : color.gray

plot(ema, color=emaColor, linewidth=2, title="EMA (PRC Driven)")

//========================
// BOJA SVEĆA
//========================
barcolor(trend == 1 ? color.lime : trend == -1 ? color.red : na)
````
