# Advanced Doji Detector

- url: https://www.tradingview.com/script/acRZjgr3-Advanced-Doji-Detector/
- type: indicator
- pine_id: PUB;32275d9bac2440f59c61dd65cf5e9c87
- version: 1.0

## Description

**Advanced Doji Detector (All Types + Alerts)**

This indicator identifies and classifies multiple types of Doji candlestick patterns in real time, helping traders spot potential market indecision, reversals, and volatility conditions.

🔍 **What it does**

* Detects Doji candles based on customizable body-size sensitivity
* Classifies Doji into:
  • Dragonfly Doji (Bullish reversal potential)
  • Gravestone Doji (Bearish reversal potential)
  • Long-Legged Doji (High volatility / indecision)
  • Neutral Doji (Standard indecision candle)

🎨 **Visual Features**

* Color-coded candles for quick identification:
  • Green → Dragonfly
  • Red → Gravestone
  • Orange → Long-Legged
  • Yellow → Neutral
* Clear labels plotted directly on the chart

🔔 **Alerts**

* Built-in alert conditions for each Doji type
* Easily set alerts from TradingView to get notified instantly

⚙️ **Custom Settings**

* Adjustable “Max Body Size %” to control Doji sensitivity
* Helps filter noise or capture more signals depending on your strategy

⚠️ **Important Notes**

* Doji candles represent indecision — not standalone trade signals
* Best used with:
  • Support & Resistance
  • Trend context
  • Volume confirmation

💡 **Tip**
Dragonfly Doji near support and Gravestone Doji near resistance tend to have higher reliability compared to random occurrences.

---

This script is designed to improve pattern recognition and assist traders in making more informed decisions, not to provide direct buy/sell signals.

Happy Trading 📊

## Source Code

````pine
//@version=6
indicator("Advanced Doji Detector", overlay = true)

// Input
precision = input.float(0.1, minval = 0.0001, title = "Max Body Size %")

// Candle calculations
body = math.abs(open - close)
candleRange = high - low
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

// Doji condition
isDoji = body <= candleRange * precision

// Doji types
dragonfly = isDoji and upperWick <= candleRange * 0.1 and lowerWick >= candleRange * 0.6
gravestone = isDoji and lowerWick <= candleRange * 0.1 and upperWick >= candleRange * 0.6
longLegged = isDoji and upperWick >= candleRange * 0.4 and lowerWick >= candleRange * 0.4
neutralDoji = isDoji and not dragonfly and not gravestone and not longLegged

// Bar colors
barcolor(
     dragonfly ? color.lime :
     gravestone ? color.red :
     longLegged ? color.orange :
     neutralDoji ? color.yellow : na
)

// Labels
plotshape(dragonfly, title="Dragonfly Doji", location=location.belowbar, color=color.lime, style=shape.labelup, text="Dragonfly")
plotshape(gravestone, title="Gravestone Doji", location=location.abovebar, color=color.red, style=shape.labeldown, text="Gravestone")
plotshape(longLegged, title="Long-Legged Doji", location=location.abovebar, color=color.orange, style=shape.labeldown, text="LongLeg")
plotshape(neutralDoji, title="Neutral Doji", location=location.abovebar, color=color.yellow, style=shape.circle, text="Doji")

// Alerts
alertcondition(dragonfly, title="Dragonfly Doji", message="Bullish Dragonfly Doji detected")
alertcondition(gravestone, title="Gravestone Doji", message="Bearish Gravestone Doji detected")
alertcondition(longLegged, title="Long-Legged Doji", message="High volatility Doji detected")
alertcondition(neutralDoji, title="Neutral Doji", message="Neutral Doji detected")
````
