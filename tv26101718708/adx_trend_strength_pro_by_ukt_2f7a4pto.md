# ADX Trend Strength Pro [BY UKT]

- url: https://www.tradingview.com/script/2f7a4PTo-ADX-Trend-Strength-Pro-BY-UKT/
- type: indicator
- pine_id: PUB;7e6ccc28927949f983b80c6b846103e4
- version: 1.0

## Description

[b]ADX Trend Strength Pro [BY UKT][/b]

A clean and reliable trend strength indicator built on the Directional Movement Index (DMI), combining ADX, +DI, and -DI with custom levels to help traders quickly assess market strength and direction.

This tool is designed for traders who want clarity without clutter, making it easy to identify whether the market is trending, weakening, or lacking momentum.
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
🔍 Key Features
ADX Line with Dynamic Color
Highlights trend strength based on momentum behavior
+DI / -DI Directional Lines
Clear visualization of bullish vs bearish pressure
Custom Strength Levels
Key levels to identify low vs strong trend conditions
Minimal & Clean Layout
No unnecessary complexity — focused decision support

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

📊 How to Use
Trend Strength
ADX rising → Strength increasing
ADX falling → Momentum weakening
Directional Bias
+DI above -DI → Bullish pressure
-DI above +DI → Bearish pressure
Key Levels
Below 15 → Low strength / sideways market
Above 45 → Strong trend environment

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

⚙️ Best Use Cases
Intraday trading
Trend-following strategies
Breakout confirmation
Momentum validation

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

⚠️ Notes
This indicator measures trend strength, not direction alone
Best used in combination with price action or structure
Not a standalone signal tool

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

🧠 Designed For

Traders who prefer simple, structured decision-making without overloaded indicators.

## Source Code

````pine
//@version=6
indicator("ADX Trend Strength Pro [BY UKT]", overlay=false)

lensig = input.int(14, title="ADX Smoothing", minval=1)
len = input.int(14, minval=1, title="DI Length")
up = ta.change(high)
down = -ta.change(low)

upMove   = high - high[1]
downMove = low[1] - low
plusDM  = (upMove > downMove and upMove > 0)   ? upMove   : 0
minusDM = (downMove > upMove and downMove > 0) ? downMove : 0
trur = ta.rma(ta.tr, len)
plusDI = fixnan(100 * ta.rma(plusDM, len) / trur)
minusDI = fixnan(100 * ta.rma(minusDM, len) / trur)
sum = plusDI + minusDI
adx = 100 * ta.rma(math.abs(plusDI - minusDI) / (sum == 0 ? 1 : sum), lensig)

// === INPUT ===

adxsrising = adx > adx[2]
adxColor = adxsrising ? color.black : color.aqua
// === PLOT ADX LINE ===

plot(adx, title="ADX", color=adxColor, linewidth=2)

// === PLOT +DI & -DI ===
plot(plusDI,  title="+DI", color=color.green, linewidth=1)
plot(minusDI, title="-DI", color=color.red,   linewidth=1)

// === CUSTOM HORIZONTAL LEVELS (WIDTH 2) ===
hline(15, "15", color=color.green, linestyle=hline.style_dashed, linewidth=2)
//hline(25, "25", color=color.green, linestyle=hline.style_dashed, linewidth=2)
//hline(35, "35", color=color.red,   linestyle=hline.style_dashed, linewidth=2)
hline(45, "45", color=color.red,   linestyle=hline.style_dashed, linewidth=2)
````
