# DMI ADX Bollinger Bands

- url: https://www.tradingview.com/script/zyJMZGEK/
- type: indicator
- pine_id: PUB;a1bfe490f5ee4b49bb8b9af6880f9760
- version: 1.0

## Description

This Pine Script code merges the classic DMI (Directional Movement Index) and ADX (Average Directional Index) indicators with Bollinger Bands, but with a unique twist: the Bollinger Bands are applied to the ADX line itself rather than the price.

This structure allows you to analyze not just the strength of the trend, but the volatility of that trend's momentum.

1. Components of the Indicator
+DI (Navy Line): Represents the strength of the bullish (upward) momentum.

-DI (Red Line): Represents the strength of the bearish (downward) momentum.

ADX (Green Line): Measures the absolute strength of the trend.

Bollinger Bands (Gray Lines & Blue Shading): Measure the volatility of the ADX line (i.e., how rapidly the trend is gaining or losing momentum).

2. How to Interpret the Signals
A. Trend Direction (DMI)
+DI > -DI: The market is trending upward.

-DI > +DI: The market is trending downward.

B. Trend Strength (ADX Levels)
Below 20: The market lacks a clear trend or is in a "ranging" (sideways) state.

20 – 40: A trend is forming and gaining strength. This is usually the prime area for trend-following strategies.

Above 40: The trend is very strong, but it also indicates the market is becoming "overextended" or at risk of exhaustion.

C. Trend Momentum (ADX + Bollinger Bands)
This is the core feature of your script:

ADX crosses above the Upper Band: The trend is gaining momentum explosively. This often indicates a strong breakout or an acceleration in the current price move.

ADX nears the Lower Band: The trend is losing steam or entering a consolidation/sideways phase.

ADX is between the bands: The trend is moving at a consistent, sustainable pace.

3. Trading Strategies
Trend-Following (Entry)
Entry: Look for a cross where +DI > -DI (for long) or -DI > +DI (for short), while the ADX is above 20.

Confirmation: Ideally, you want to see the ADX line moving upward, ideally heading toward the Upper Bollinger Band, confirming that the momentum is building.

Profit Taking / Reversal (Exhaustion)
When the ADX reaches the 40–50 level and touches or exceeds the Upper Bollinger Band, the trend is likely "overextended." This is a strong signal to consider taking profits or tightening your stop-loss, as the market may be due for a correction.

Identifying Ranging Markets
If the ADX line drops below the Lower Bollinger Band, the market has officially entered a low-volatility/sideways phase. Avoid trend-following strategies in this zone and consider strategies better suited for choppy markets.

## Source Code

````pine
//@version=6
indicator(title="DMI ADX BB", shorttitle="ADX DMI BB", overlay=false)

// --- Girdiler ---
len      = input.int(14, "Periyot", minval = 1)
lensig   = input.int(14, "ADX Yumuşatma", minval = 1)

// Bollinger Bandı Girdileri
bb_len   = input.int(20, "BB Periyodu (ADX için)", minval = 1)
bb_mult  = input.float(2.0, "BB Standart Sapma", minval = 0.1, step = 0.1)

// --- Sabit Seviyeler (Level 1, 2, 3) ---
level1 = 20
level2 = 40
level3 = 60

// --- DMI & ADX Hesaplamaları ---
trur = ta.rma(ta.tr, len)
up = ta.change(high)
down = -ta.change(low)

plusDM = (up > down and up > 0) ? up : 0
minusDM = (down > up and down > 0) ? down : 0

plus = 100 * ta.rma(plusDM, len) / math.max(trur, 0.000001)
minus = 100 * ta.rma(minusDM, len) / math.max(trur, 0.000001)

sumDI = plus + minus
adx = 100 * ta.rma(math.abs(plus - minus) / math.max(sumDI, 1), lensig)

// --- ADX Üzerine Bollinger Bantları Hesaplaması ---
[bb_middle, bb_upper, bb_lower] = ta.bb(adx, bb_len, bb_mult)

// --- Çizimler ---

// Bollinger Bantları (Arka plan dolgusu ile)
p_upper = plot(bb_upper, color=color.new(color.gray, 50), title="BB Üst")
p_lower = plot(bb_lower, color=color.new(color.gray, 50), title="BB Alt")
fill(p_upper, p_lower, color=color.new(color.blue, 90), title="BB Arka Plan")
plot(bb_middle, color=color.new(color.gray, 70), title="BB Orta")

// Ana Çizgiler
plot(adx,   color=color.green, title="ADX", linewidth=2)
plot(plus,  color=color.navy,  title="+DI", linewidth=1)
plot(minus, color=color.red,   title="-DI", linewidth=1)

// --- Seviyeler (İstediğiniz Düzenleme) ---
hline(level1, "Seviye 1", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(level2, "Seviye 2", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(level3, "Seviye 3", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
````
