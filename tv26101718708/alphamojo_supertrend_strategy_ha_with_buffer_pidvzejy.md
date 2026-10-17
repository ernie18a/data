# Alphamojo - Supertrend Strategy HA with Buffer

- url: https://www.tradingview.com/script/pIdVZEJY-Alphamojo-Supertrend-Strategy-HA-with-Buffer/
- type: strategy
- pine_id: PUB;22ba3916eb3045e69e964da4d687184a
- version: 1.0

## Description

**Title: SuperTrend Heikin Ashi Buffer [Your Name]**

**Overview**
Welcome to the **SuperTrend Heikin Ashi Buffer**! This indicator is designed for trend-following traders who want to filter out market noise and pinpoint high-probability zones. By combining the proven trend-detection capabilities of the SuperTrend with the smoothing effect of Heikin Ashi candles, this tool goes a step further by introducing a dynamic **Price Buffer** to help confirm breakouts and manage risk.

**How It Works**
This indicator relies on three core components working in harmony:

1. **SuperTrend:** Acts as our primary directional compass, identifying whether the market is currently in a bullish or bearish state.
2. **Heikin Ashi Candles:** Instead of using standard Japanese candlesticks, the indicator calculates values based on Heikin Ashi price action to eliminate erratic wicks and clearly define the trend momentum.
3. **Dynamic Buffer Logic:** A customizable buffer zone is applied directly to the extremes of the Heikin Ashi candles depending on the current SuperTrend direction.

**The Buffer Mechanism Explained**
The standout feature of this indicator is how it dynamically shifts the buffer placement based on market conditions:

* 🟩 **Bullish Phase (SuperTrend is Green):** When the SuperTrend flips green, the indicator applies the buffer to the **High** of the Heikin Ashi candle. This is incredibly useful for traders looking for breakout confirmations, ensuring price has truly pushed past the high + buffer before entering long or adding to a position.
* 🟥 **Bearish Phase (SuperTrend is Red):** When the SuperTrend flips red, the indicator applies the buffer to the **Low** of the Heikin Ashi candle. This helps traders identify true breakdowns below the local Heikin Ashi lows + buffer, making it ideal for short entries or trailing stop-loss placement.

**Key Features**

* **Noise Reduction:** Filters out fake-outs by relying on smoothed Heikin Ashi data rather than volatile standard price action.
* **Customizable Inputs:** Adjust the SuperTrend length and multiplier, as well as the exact size of your buffer to fit your specific asset and timeframe.
* **Visual Clarity:** Clean lines on the chart clearly display exactly where the buffer is at all times so you don't have to guess.

**How to Use This Indicator**

* **Breakout Confirmation:** Wait for the standard price to close beyond the Heikin Ashi buffer line before taking a trade in the direction of the SuperTrend.
* **Trailing Stops:** Use the dynamic buffer line as a strict trailing stop-loss to ride massive trends while protecting your capital from sudden reversals.
* **Confluence:** Pair this with volume indicators (like RSI or OBV) to ensure there is strong momentum when price interacts with the buffer zone.

*Disclaimer: This indicator is designed for educational and analytical purposes. Always backtest your strategies and practice proper risk management before trading with real capital.*

*** ### **Tips for Publishing on TradingView:**

* **Add a Chart Screenshot:** Make sure you upload a very clean, visually appealing screenshot of the indicator in action. Try to capture a moment on the chart where the SuperTrend flips and the buffer successfully catches a trend or filters out a fake-out.
* **Keep Settings Flexible:** When coding, make sure the user can change the "Buffer amount" in the inputs menu, as different assets (like Crypto vs. Forex) require vastly different buffer sizes.

## Source Code

````pine
//@version=6
strategy("Supertrend Strategy HA with Buffer", overlay=true, initial_capital=100000, pyramiding=0)

// Input for ATR Length and Factor
atrPeriod = input.int(10, "ATR Length")
factor = input.float(3.0, "Factor", step = 0.05)

// Input for Buffer Percentage (e.g., 0.05% by default)
bufferPercent = input.float(0.05, title="Buffer Percentage", step=0.01) / 100  // Convert input to decimal

// Pull Heikin Ashi Data
haTicker = ticker.heikinashi(syminfo.tickerid)
[haHigh, haLow] = request.security(haTicker, timeframe.period, [high, low])

// Calculate Supertrend on Heikin Ashi
[haSupertrendLine, haDirection] = request.security(haTicker, timeframe.period, ta.supertrend(factor, atrPeriod))

// Define buffer using the Heikin Ashi high/low
bufferLong = haHigh * bufferPercent  
bufferShort = haLow * bufferPercent  

// Long entry on HA high price with buffer
if ta.change(haDirection) < 0
    longPrice = haHigh + bufferLong  
    strategy.entry("My Long Entry Id", strategy.long, stop=longPrice)

// Short entry on HA low price with buffer
if ta.change(haDirection) > 0
    shortPrice = haLow - bufferShort  
    strategy.entry("My Short Entry Id", strategy.short, stop=shortPrice)

// Plot the Supertrend line with coloring
supertrendColor = (haDirection < 0) ? color.green : color.red
plot(haSupertrendLine, color=supertrendColor, linewidth=2, title="HA Supertrend")
````
