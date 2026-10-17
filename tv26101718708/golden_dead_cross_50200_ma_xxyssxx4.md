# Golden & Dead Cross (50/200 MA)

- url: https://www.tradingview.com/script/XxYsSXX4-Golden-Dead-Cross-50-200-MA/
- type: indicator
- pine_id: PUB;904ab0e8a1594a3682f2618033eba52d
- version: 1.0

## Description

🚀 Golden & Dead Cross PRO (50/200 MA)

A refined and visually enhanced take on one of the most powerful and widely used market signals: the 50 / 200 Moving Average Crossover.

This indicator is designed for traders who want clean signals, dynamic trend visualization, and instant market bias recognition — without unnecessary noise.

💎 Why This Indicator?

The classic Golden Cross / Dead Cross strategy is powerful — but often lacks clarity in fast-moving markets.

This script solves that by combining:

Precision crossover detection
Adaptive trend coloring
Minimal yet powerful visual signals
⚡ Core Features

🟢 Golden Cross Detection
→ When MA(50) crosses above MA(200)
→ Marked with a clean green dot below price

🔴 Dead Cross Detection
→ When MA(50) crosses below MA(200)
→ Marked with a clean red dot above price

🎨 Smart Trend Coloring System

Bullish Structure → Both MAs turn Green
Bearish Structure → Both MAs turn Red
Instantly shows market bias at a glance

📉 Noise-Free Design

No clutter, no distractions
Built for focus and fast decision making
🧠 How Traders Use It
Identify trend reversals early with crossover signals
Stay aligned with the dominant trend using MA colors
Filter trades by trading only in trend direction

💡 Pro Tip:
Combine with:

Market structure (HH / HL - LH / LL)
Volume confirmation
Key support & resistance zones
🎯 Who Is This For?
Price action traders
Swing traders
Crypto & Forex traders
Anyone who values clean charts + high-quality signals
⚠️ Disclaimer

This indicator does not guarantee profits. It is a decision-support tool designed to enhance your trading process. Always manage risk and use proper confirmation.

## Source Code

````pine
//@version=6
indicator("Golden & Dead Cross (50/200 MA)", overlay=true)

// MA Ayarları
fastLength = 50
slowLength = 200

fastMA = ta.sma(close, fastLength)
slowMA = ta.sma(close, slowLength)

// Kesişimler
goldenCross = ta.crossover(fastMA, slowMA)
deadCross   = ta.crossunder(fastMA, slowMA)

// Trend belirleme
trendUp = fastMA > slowMA
trendDown = fastMA < slowMA

// Renkler
maColor = trendUp ? color.green : color.red

// MA Çizimleri
plot(fastMA, title="MA 50", color=maColor, linewidth=2)
plot(slowMA, title="MA 200", color=maColor, linewidth=2)

// Noktalar (kesişimler)
plotshape(goldenCross, title="Golden Cross",
     location=location.belowbar,
     color=color.green,
     style=shape.circle,
     size=size.small)

plotshape(deadCross, title="Dead Cross",
     location=location.abovebar,
     color=color.red,
     style=shape.circle,
     size=size.small)

// Alarm koşulları (isteğe bağlı)
alertcondition(goldenCross, title="Golden Cross Alert", message="Golden Cross oluştu!")
alertcondition(deadCross, title="Dead Cross Alert", message="Dead Cross oluştu!")
````
