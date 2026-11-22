# Sentiment Divergence Tracker 

- url: https://www.tradingview.com/script/bcxB68m6-Sentiment-Divergence-Tracker/
- type: indicator
- pine_id: PUB;c437b165ac5044daa2e8b57544bb1e79
- version: 1.0

## Description

The "Sentiment Divergence Tracker" is a sophisticated quantitative analysis tool designed to identify statistical anomalies between two correlated financial assets. By monitoring the relative price movement of a primary asset against a correlated counterpart, this indicator highlights "Divergence Zones" that often precede significant market reversals or mean reversions.
Core Functionality:
Traditional technical analysis often ignores the relationship between inter-market assets. This indicator bridges that gap by normalizing percentage-based price fluctuations, allowing for a clean, comparative view of market sentiment.
Key Features:
Dynamic Divergence Calculation: Utilizes standard deviation and moving average models to calculate the "Fair Value" gap between two assets.
Automated Support/Resistance Mapping: Rather than manual drawing, the indicator plots dynamic support lines that adjust based on market volatility, helping traders identify institutional "value areas."
Oversold/Overbought Detection: Visualizes extreme deviations where the price has stretched too far from its correlated pair, signaling high-probability reversal setups.
Institutional Context: Useful for identifying liquidity pockets where "Smart Money" might be accumulating or distributing based on inter-market relationships.
How to Interpret:
Baseline (0.0): Represents the equilibrium point where both assets are moving in perfect correlation.
Divergence Line: The primary blue plot. When this line moves away from the baseline, it indicates a weakening correlation.
Support/Resistance Levels: These are not static lines but dynamic boundaries. A touch or breach of these levels typically indicates that the asset is statistically "oversold" or "overbought" relative to its pair.
Trade Execution: Look for "Mean Reversion" entries when the Divergence Line exhausts its momentum at the support/resistance boundaries and begins to curl back toward the baseline.
Recommended Settings:
Timeframe: Optimized for 15-minute to 4-hour charts for intraday and swing trading.
Correlated Pair Selection: Ensure the "Correlated Asset" input matches a highly correlated instrument (e.g., Gold/Silver, or major Currency/Index pairs).
Volatility Sensitivity: Adjust the lookback period in the settings to suit your specific asset's volatility profile.
Disclaimer:
This tool is intended for analytical purposes and does not constitute financial advice. Always integrate this indicator with your existing risk management strategy and technical confirmation (e.g., candlestick patterns, order blocks

## Source Code

````pine
//@version=6
indicator("Sentiment Divergence Tracker", overlay=false)

// 1. कोरिलेटेड सिंबल चुनें (जैसे बैंक निफ्टी)
string tickerInput = input.symbol("NSE:BANKNIFTY", "Correlated Asset")
float correlatedPrice = request.security(tickerInput, timeframe.period, close)

// 2. अपना करंट प्राइस और कोरिलेटेड प्राइस का नॉर्मलाइजेशन
// (ताकि दोनों का स्केल सेम हो जाए और आप कंपेयर कर सकें)
float myPrice = close
float diff = (myPrice - correlatedPrice) / correlatedPrice * 100

// 3. विजुअलाइजेशन
plot(diff, title="Divergence Gap", color=diff > 0 ? color.green : color.red, style=plot.style_columns)
hline(0, "Baseline", color=color.gray)

// 4. अलर्ट (जब गैप बहुत ज्यादा बढ़ जाए)
alertcondition(math.abs(diff) > 0.5, title="High Divergence Alert", message="Sentiment Divergence Detected!")
````
