# Precision Engulfing Pro

- url: https://www.tradingview.com/script/7dsTgdAq-Precision-Engulfing-Pro/
- type: indicator
- pine_id: PUB;577eab26c68d4ee3b5d4a4df41aa4765
- version: 1.0

## Description

Short Description

Detects high-quality engulfing candles using multi-bar confirmation and adjustable strictness for 
better trade filtering.

Full Description

Precision Engulfing Pro — Adjustable Strictness is an advanced candlestick pattern indicator designed to identify high-probability engulfing setups while reducing noise and false signals.

Unlike basic engulfing indicators, this script uses multi-candle confirmation (3-bar context) combined with a body strength filter to ensure only meaningful market moves are highlighted.

🔍 Key Features
✅ Advanced Engulfing Logic
Uses a 3-candle trend filter before detecting engulfing patterns for higher reliability.
🎚️ Adjustable Strictness (Body Strength)
Control how strong the engulfing candle must be compared to the previous candle.
Lower value → More signals (looser)
Higher value → Fewer but stronger signals (stricter)
🎯 Single Clean Visual Output
Highlights engulfing candles with one consistent color — no clutter, no confusion.
⚡ Non-Repainting Behavior
Uses only confirmed historical data — signals remain stable after candle close.
🔔 Alert Support
Built-in alert condition for automated monitoring.
📊 How It Works
Detects trend context using previous candles
Confirms engulfing only when:
Candle fully engulfs prior structure
Body size meets strictness threshold
Highlights only validated engulfing candles
⚙️ Settings
Engulfing Bar Color → Customize highlight color
Strictness (Body Strength) → Controls signal quality vs frequency
💡 Best Use Cases
Intraday trading (Scalping / Momentum)
Swing trading entries
Trend reversal confirmation
Works well with:
Support & Resistance
Moving Averages
Volume confirmation
⚠️ Notes
Higher strictness = fewer but higher-quality signals
Lower strictness = more signals but may include noise
Best used with additional confluence tools
🚀 Recommended Setup
Start with Strictness = 1.0
Increase to 1.5 – 2.0 for strong trends
Decrease to 0.5 – 0.8 for early entries
🛠 Alert Message

Engulfing Signal Triggered

🧠 Author Notes

This indicator is built for traders who prefer precision over quantity, focusing on strong market intent rather than every possible engulfing pattern.

⚖️ Legal Disclaimer
This script is for educational and informational purposes only and does not constitute financial or investment advice.
No guarantees are made regarding its accuracy or performance. Trading involves significant risk, including potential loss of capital, and past results do not ensure future outcomes.
This tool does not account for market conditions, slippage, or execution differences. Always do your own analysis, use proper risk management, and backtest before live trading.
By using this script, you accept full responsibility for your trading decisions and agree that the author is not liable for any losses or damages.

## Source Code

````pine
//@version=5
indicator("Precision Engulfing Pro — Adjustable Strictness", overlay=true)

//==================== INPUTS ====================//
engulfColor = input.color(color.yellow, "Engulfing Bar Color")
strictness  = input.float(1.0, "Strictness (Body Strength)", minval=0.1, step=0.1)

//==================== BODY CALC ====================//
currBullBody = math.max(close - open, 0)
prevBearBody = math.max(open[1] - close[1], 0)

currBearBody = math.max(open - close, 0)
prevBullBody = math.max(close[1] - open[1], 0)

//==================== ENGULFING LOGIC ====================//
bullCond = open[3] > close[3] and open[2] > close[2] and open[1] > close[1] and close > open and close >= open[1] and close[1] >= open and currBullBody > prevBearBody * strictness

bearCond = open[3] < close[3] and open[2] < close[2] and close[1] > open[1] and open > close and open >= close[1] and open[1] >= close and currBearBody > prevBullBody * strictness

//==================== FINAL SIGNAL ====================//
signal = bullCond or bearCond

//==================== VISUAL ====================//
barcolor(signal ? engulfColor : na)

//==================== ALERT ====================//
alertcondition(signal, title="Engulfing Signal", message="Engulfing Signal Triggered")
````
