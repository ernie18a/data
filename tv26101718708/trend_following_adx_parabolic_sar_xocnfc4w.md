# Trend Following ADX + Parabolic SAR

- url: https://www.tradingview.com/script/xoCNFc4W-Trend-Following-ADX-Parabolic-SAR/
- type: strategy
- pine_id: PUB;57abe080979748be8861e39f9b3f1cd0
- version: 1.0

## Description

### Strategy Description: Trend Following using **ADX** and **Parabolic SAR**

This strategy is designed to follow market trends using two popular indicators: **Average Directional Index (ADX)** and **Parabolic SAR**. The strategy attempts to enter trades when the market shows a strong trend (using ADX) and confirms the trend direction using the Parabolic SAR. Here's a breakdown:

### Key Indicators:
1. **ADX (Average Directional Index)**:
   - **Purpose**: ADX measures the strength of a trend, regardless of direction.
   - **Usage**: The strategy uses ADX to confirm that the market is trending. When ADX is above a certain threshold (e.g., 25), it indicates a strong trend.
   - **Directional Indicators**:
     - **DI+ (Directional Indicator Plus)**: Indicates upward movement strength.
     - **DI- (Directional Indicator Minus)**: Indicates downward movement strength.

2. **Parabolic SAR**:
   - **Purpose**: Parabolic SAR is a trend-following indicator used to identify potential reversals in the price direction.
   - **Usage**: It provides specific price points above or below which the strategy confirms buy or sell signals.

### Strategy Logic:

#### **Entry Conditions**:

1. **Long Position** (Buy):
   - **ADX** is above the threshold (default: 25), indicating a strong trend.
   - **DI+ > DI-**, indicating the upward trend is stronger than the downward.
   - The price is above the **Parabolic SAR** level, confirming the upward trend.

2. **Short Position** (Sell):
   - **ADX** is above the threshold (default: 25), indicating a strong trend.
   - **DI- > DI+**, indicating the downward trend is stronger than the upward.
   - The price is below the **Parabolic SAR** level, confirming the downward trend.

#### **Exit Conditions**:
- Positions are closed when an opposite signal is detected.
  - For example, if a long position is open and the conditions for a short position are met, the long position is closed, and a short position is opened.

### Parameters:
1. **ADX Period**: Defines the length of the period for the ADX calculation (default: 14).
2. **ADX Threshold**: The minimum value of ADX to confirm a strong trend (default: 25).
3. **Parabolic SAR Start**: The initial step for the SAR (default: 0.02).
4. **Parabolic SAR Increment**: The step increment for SAR (default: 0.02).
5. **Parabolic SAR Max**: The maximum step for SAR (default: 0.2).

### Example Trade Flow:

#### **Long Trade**:
1. ADX > 25, confirming a strong trend.
2. DI+ > DI-, indicating the market is trending upward.
3. The price is above the Parabolic SAR, confirming the upward direction.
4. **Action**: Enter a long (buy) position.
5. Exit the long position when a short signal is triggered (i.e., DI- > DI+, price below Parabolic SAR).

#### **Short Trade**:
1. ADX > 25, confirming a strong trend.
2. DI- > DI+, indicating the market is trending downward.
3. The price is below the Parabolic SAR, confirming the downward direction.
4. **Action**: Enter a short (sell) position.
5. Exit the short position when a long signal is triggered (i.e., DI+ > DI-, price above Parabolic SAR).

### Strengths of the Strategy:
- **Trend-Following**: It performs well in markets with strong trends, whether upward or downward.
- **Dual Confirmation**: The combination of ADX and Parabolic SAR reduces false signals by ensuring both trend strength and direction are considered before entering a trade.
  
### Weaknesses:
- **Range-Bound Markets**: This strategy may perform poorly in choppy, non-trending markets because both ADX and SAR are trend-following indicators.
- **Lagging Nature**: Since both ADX and SAR are lagging indicators, the strategy may enter trades after the trend has already started, potentially missing early profits.

### Customization:
- **ADX Threshold**: You can increase the threshold if you only want to trade in very strong trends, or lower it to capture more moderate trends.
- **SAR Parameters**: Adjusting the SAR `start`, `increment`, and `max` values will make the Parabolic SAR more or less sensitive to price changes.

### Summary:
This strategy combines the ADX and Parabolic SAR to take advantage of strong market trends. By confirming both trend strength (ADX) and trend direction (Parabolic SAR), it aims to enter high-probability trades in trending markets while minimizing false signals. However, it may struggle in sideways or non-trending markets.

For Educational purposes only !!!

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © traderhub

//@version=5
strategy("Trend Following ADX + Parabolic SAR", overlay=true)

// Strategy parameters
adxLength = input(14, title="ADX Period")
adxThreshold = input(25, title="ADX Threshold")
adxSmoothing = input(14, title="ADX Smoothing")
sarStart = input(0.02, title="Parabolic SAR Start")  // Starting acceleration factor
sarIncrement = input(0.02, title="Parabolic SAR Increment")  // Increment step
sarMax = input(0.2, title="Parabolic SAR Max")  // Maximum acceleration factor

// Calculate ADX, DI+, and DI-
[diPlus, diMinus, adx] = ta.dmi(adxLength, adxSmoothing)

// Parabolic SAR calculation
sar = ta.sar(sarStart, sarIncrement, sarMax)

// Conditions for a long position
longCondition = adx > adxThreshold and diPlus > diMinus and close > sar

// Conditions for a short position
shortCondition = adx > adxThreshold and diMinus > diPlus and close < sar

// Enter a long position
if (longCondition)
    strategy.entry("Long", strategy.long)

// Enter a short position
if (shortCondition)
    strategy.entry("Short", strategy.short)

// Close position on reverse signal
if (strategy.position_size > 0 and shortCondition)
    strategy.close("Long")
if (strategy.position_size < 0 and longCondition)
    strategy.close("Short")

// Plot indicators on the chart
plot(sar, color=color.blue, style=plot.style_circles, linewidth=2, title="Parabolic SAR")
plot(adx, color=color.red, title="ADX")
hline(adxThreshold, "ADX Threshold", color=color.green)
````
