# KN JMA Baseline (JMA + EMA200)

- url: https://www.tradingview.com/script/bVa7Z3ZO-KN-JMA-Baseline-JMA-EMA200/
- type: indicator
- pine_id: PUB;f24c9c48d8a74cc898dbe54957b722af
- version: 1.0

## Description

KN JMA Baseline (JMA + EMA200) is a clean trend-following indicator designed to help traders identify market direction using a fast Jurik Moving Average (JMA), a slow JMA baseline, and the EMA200 trend filter.

Features:
• Fast JMA baseline for responsive trend detection
• Slow JMA baseline for higher timeframe trend confirmation
• EMA200 for overall market direction filtering
• Smooth and low-lag movement compared to traditional moving averages
• Clean chart design suitable for scalping, intraday, and swing trading

Trend Logic:
• Bullish trend when fast JMA is above slow JMA and price is above EMA200
• Bearish trend when fast JMA is below slow JMA and price is below EMA200

Recommended Markets:
• Gold (XAUUSD)
• Forex
• Crypto
• Indices

Recommended Timeframes:
• H1
• H4
• Daily

This indicator is designed for educational and analytical purposes only and should be combined with proper risk management and price action confirmation.

## Source Code

````pine
//@version=6
indicator("KN JMA Baseline (JMA + EMA200)", shorttitle="KN JMA", overlay=true)

//--------------------------------------------------------
// Inputs
//--------------------------------------------------------
show_bl = input.bool(true, title="Show Baseline?")
length = input.int(70, title="Baseline: Length")
phase = input.float(5, title="Baseline: Phase", step=0.1, minval=-100, maxval=100)
power = input.int(2, title="Baseline: Power")
src_bl = input.source(close, title="Baseline: Source")

show_bl_slow = input.bool(true, title="Show Slow Baseline?")
length_slow = input.int(150, title="Slow Baseline: Length")
phase_slow = input.float(0, title="Slow Baseline: Phase", step=0.1, minval=-100, maxval=100)
power_slow = input.int(2, title="Slow Baseline: Power")
src_bl_slow = input.source(close, title="Slow Baseline: Source")

show_ema200 = input.bool(true, title="Show EMA200?")

//--------------------------------------------------------
// JMA Function
//--------------------------------------------------------
jma(src, length, power, phase) =>
    phaseRatio = phase < -100 ? 0.5 : phase > 100 ? 2.5 : phase / 100 + 1.5

    beta = 0.45 * (length - 1) / (0.45 * (length - 1) + 2)
    alpha = math.pow(beta, power)

    var float e0 = na
    var float e1 = na
    var float e2 = na
    var float jma = na

    e0 := (1 - alpha) * src + alpha * nz(e0[1])
    e1 := (src - e0) * (1 - beta) + beta * nz(e1[1])
    e2 := (e0 + phaseRatio * e1 - nz(jma[1])) * math.pow(1 - alpha, 2) + math.pow(alpha, 2) * nz(e2[1])
    jma := e2 + nz(jma[1])

    jma

//--------------------------------------------------------
// Calculate Baselines
//--------------------------------------------------------
baseline = jma(src_bl, length, power, phase)
baseline_slow = jma(src_bl_slow, length_slow, power_slow, phase_slow)

// EMA200
ema200 = ta.ema(close, 200)

//--------------------------------------------------------
// Plot
//--------------------------------------------------------
plot(
     show_bl ? baseline : na,
     color=color.orange,
     linewidth=1,
     title="Baseline (JMA)"
)

plot(
     show_bl_slow ? baseline_slow : na,
     color=color.blue,
     linewidth=1,
     title="Slow Baseline (JMA)"
)

plot(
     show_ema200 ? ema200 : na,
     color=color.red,
     linewidth=2,
     title="EMA200"
)
````
