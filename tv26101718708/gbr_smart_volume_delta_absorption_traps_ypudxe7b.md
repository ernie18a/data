# GBR Smart Volume Delta [Absorption & Traps]

- url: https://www.tradingview.com/script/ypUdxe7b-GBR-Smart-Volume-Delta-Absorption-Traps/
- type: indicator
- pine_id: PUB;37e6511386de4d23bddd5b3308c4ecad
- version: 1.0

## Description

The traditional Volume Delta indicator is fundamentally flawed for modern day trading. It only calculates aggressive market orders, completely blinding you to the passive institutional limit orders (icebergs) that actually stop the price.

The GBR Smart Delta doesn't just count orders; it thinks. It analyzes the relationship between raw delta and the actual candlestick close to detect Institutional Absorption in real-time.

🔥 Core Features & Visual Logic:

Trap Detection: Exposes moments when retail traders are aggressively selling, but the price refuses to drop (or leaves a massive wick).

💥 UV Yellow (Bear Trap / Bullish Absorption): Delta is negative (heavy selling), but the candle closes bullish or forms a hammer. Passive buyers are absorbing the selling pressure. Prime long opportunity.

💥 UV Cyan (Bull Trap / Bearish Absorption): Delta is positive (heavy buying), but the candle closes bearish or forms a shooting star. Passive sellers have built a wall. Prime short opportunity.

Faint Colors for Normalcy: When price and volume agree, the histogram uses muted Green (70% transparent) and muted Red to keep your focus strictly on the anomalies.

Zero Clutter: No moving averages on the volume, no unnecessary lines. Just raw data and high-visibility trap signals.

🎯 How to execute:
Never trade delta in a vacuum. Wait for price to reach a major Support/Resistance level. If you see a bright UV Yellow or UV Cyan spike at these key structural zones, you know the Smart Money has stepped in. Enter with them.

## Source Code

````pine
//@version=6
indicator("GBR Smart Delta [Absorption]", format=format.volume)

// ==========================================
// 1. SMART DELTA CALCULATION (Estimation)
// ==========================================
// Kiszámolja a gyertyán belüli tényleges vételi és eladási nyomást
range_val = high - low == 0 ? syminfo.mintick : high - low
buyVol = volume * (close - low) / range_val
sellVol = volume * (high - close) / range_val

// Nyers Delta
delta = buyVol - sellVol

// ==========================================
// 2. ABSORPTION (CSAPDA) LOGIKA
// ==========================================
// Bika Abszorpció (Medve Csapda): Negatív Delta, de az ár emelkedik vagy kalapácsot formál
bullish_absorption = delta < 0 and (close > open or (close - low) > (high - close) * 1.5)

// Medve Abszorpció (Bika Csapda): Pozitív Delta, de az ár esik vagy hullócsillagot formál
bearish_absorption = delta > 0 and (close < open or (high - close) > (close - low) * 1.5)

// ==========================================
// 3. GBR ARCULAT ÉS SZÍNEZÉS
// ==========================================
colNormBull = color.new(#00FF00, 70) // Halvány Zöld (Normál Vétel)
colNormBear = color.new(#FF0033, 70) // Halvány Piros (Normál Eladás)

colBearTrap = color.new(#FFFF00, 0)  // UV SÁRGA (Vételi Szignál! Eladók csapdában)
colBullTrap = color.new(#00E5FF, 0)  // UV TÜRKIZ (Eladási Szignál! Vevők csapdában)

// Színek kiosztása a logikának megfelelően
barColor = bullish_absorption ? colBearTrap : bearish_absorption ? colBullTrap : delta > 0 ? colNormBull : colNormBear

// ==========================================
// 4. MEGJELENÍTÉS
// ==========================================
plot(delta, title="GBR Smart Delta", style=plot.style_histogram, color=barColor, linewidth=3)
hline(0, title="Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
````
