# Takhtupuria All-in-One Sniper & Alligator ..2

- url: https://www.tradingview.com/script/q9TuIDkV-Takhtupuria-All-in-One-Sniper-Alligator-2/
- type: indicator
- pine_id: PUB;0010b880d4fd40728a87fbdfa7f303e3
- version: 1.0

## Description

All-in-One Sniper & Alligator Pro
This advanced trading tool integrates the power of the Alligator indicator and Exponential Moving Averages (EMA) with visual buy/sell signal shapes, making trend identification clearer than ever.
Key Features:
 Trend Confirmation: Includes 21 EMA and 200 EMA for institutional-level trend analysis.
 Alligator Precision: Uses the full Alligator system (Jaw, Teeth, Lips) to identify precise market entry points.
 Visual Signals: Automated shapes (Up/Down triangles) are plotted directly on the chart to indicate potential trend reversals and entry signals.
How to use:
 Settings: Easily customize the visibility of EMAs and Alligator lines in the Inputs tab.
 Visuals: Use the Style tab to adjust the appearance of signals and lines to suit your trading environment.
Designed by Takhtupuria for traders who demand clarity and precision in their trend analysis.
ਕੈਟਾਗਰੀ ਅਤੇ ਟੈਗਸ:

## Source Code

````pine
//@version=5
indicator("All-in-One Sniper & Alligator Pro", overlay=true)

// --- SMMA ਫਾਰਮੂਲਾ (ਇਹ error ਨੂੰ ਠੀਕ ਕਰੇਗਾ) ---
ta_smma(src, length) =>
    var float smma = na
    smma := na(smma[1]) ? ta.sma(src, length) : (smma[1] * (length - 1) + src) / length
    smma

// --- ਇਨਪੁਟਸ ---
ema21 = ta.ema(close, 21)
ema200 = ta.ema(close, 200)

// Alligator Calculation (ਹੁਣ ਇਹ ਠੀਕ ਕੰਮ ਕਰੇਗਾ)
jaw = ta_smma(hl2, 13)
teeth = ta_smma(hl2, 8)
lips = ta_smma(hl2, 5)

// --- ਸਿਗਨਲ ਲਾਜਿਕ ---
bodySize = math.abs(close - open)
candleRange = high - low
percentOutside = (bodySize / candleRange) * 100

var bool inTrade = false
buySignal = (ema21 > ema200) and (close > ema21) and (percentOutside >= 70) and not inTrade
sellSignal = (ema21 < ema200) and (close < ema21) and (percentOutside >= 70) and not inTrade
touchEma = (close <= ema21 and ema21 > ema200) or (close >= ema21 and ema21 < ema200)

if buySignal or sellSignal
    inTrade := true

if touchEma
    inTrade := false

// --- ਪਲੌਟਿੰਗ ---
plot(ema21, color=color.blue, linewidth=2, title="21 EMA")
plot(ema200, color=color.white, linewidth=3, title="200 EMA")
plot(jaw, color=color.blue, offset=8, title="Alligator Jaw")
plot(teeth, color=color.red, offset=5, title="Alligator Teeth")
plot(lips, color=color.green, offset=3, title="Alligator Lips")

// ਸਿਗਨਲ ਸ਼ੇਪਸ
plotshape(buySignal, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(sellSignal, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)
````
