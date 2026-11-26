# HT RSI + MTF + Stoch PRO

- url: https://www.tradingview.com/script/Up8NMNkg/
- type: indicator
- pine_id: PUB;744d9b48459447879a55c1ec7e773a22
- version: 1.0

## Description

This indicator combines RSI and Stochastic to identify overbought and oversold conditions.

When both indicators are in oversold territory, it signals potential buy opportunities. When both are overbought, it indicates potential sell opportunities.

It helps traders spot clearer reversal points by confirming signals through dual momentum analysis.

## Source Code

````pine
//@version=5
indicator("HT RSI + MTF + Stoch PRO", overlay=false)

// =====================
// RSI
// =====================
rsi = ta.rsi(close, 14)
rsi_5m = request.security(syminfo.tickerid, "5", ta.rsi(close, 14))

// =====================
// ESTOCÁSTICO
// =====================
k = ta.stoch(close, high, low, 14)
d = ta.sma(k, 3)

// =====================
// NIVELES
// =====================
rsi_ob = 70
rsi_os = 30

stoch_ob = 80
stoch_os = 20

// =====================
// FONDO SOLO RSI
// =====================
bgcolor(rsi > rsi_ob ? color.new(color.green, 85) : na)
bgcolor(rsi < rsi_os ? color.new(color.red, 85) : na)

// =====================
// PLOTS
// =====================

// RSI
plot(rsi, color=color.white, linewidth=2, title="RSI 1M")
plot(rsi_5m, color=color.orange, linewidth=2, title="RSI 5M")

// Estocástico
plot(k, color=color.blue, title="Stoch K")
plot(d, color=color.purple, title="Stoch D")

// =====================
// ZONAS VISUALES
// =====================
hline(rsi_ob, "RSI OB", color=color.green)
hline(rsi_os, "RSI OS", color=color.red)

hline(stoch_ob, "Stoch OB", color=color.green, linestyle=hline.style_dotted)
hline(stoch_os, "Stoch OS", color=color.red, linestyle=hline.style_dotted)
````
