# ADX + Volume Strategy

- url: https://www.tradingview.com/script/whPK8Qlh-ADX-Volume-Strategy/
- type: strategy
- pine_id: PUB;a902d08165d1455183601660ef911b05
- version: 1.0

## Description

### Strategy Description: ADX and Volume-Based Trading Strategy

This strategy is designed to identify strong market trends using the **Average Directional Index (ADX)** and confirm trading signals with **Volume**. The idea behind the strategy is to enter trades only when the market shows a strong trend (as indicated by ADX) and when the price movement is supported by high trading volume. This combination helps filter out weaker signals and provides more reliable entries into positions.

### Key Indicators:

1. **ADX (Average Directional Index)**:
   - **Purpose**: ADX is a technical indicator that measures the strength of a trend, regardless of its direction (up or down).
   - **Usage**: The strategy uses ADX to determine whether the market is trending strongly. If ADX is above a certain threshold (default is 25), it indicates that a strong trend is present.
   - **Directional Indicators**:
     - **DI+ (Directional Indicator Plus)**: Indicates the strength of the upward price movement.
     - **DI- (Directional Indicator Minus)**: Indicates the strength of the downward price movement.
   - ADX does not indicate the direction of the trend but confirms that a trend exists. DI+ and DI- are used to determine the direction.

2. **Volume**:
   - **Purpose**: Volume is a key indicator for confirming the strength of a price movement. High volume suggests that a large number of market participants are supporting the movement, making it more likely to continue.
   - **Usage**: The strategy compares the current volume to the 20-period moving average of the volume. The trade signal is confirmed if the current volume is greater than the average volume by a specified **Volume Multiplier** (default multiplier is 1.5). This ensures that the trade is supported by strong market participation.

### Strategy Logic:

#### **Entry Conditions:**

1. **Long Position** (Buy):
   - **ADX** is above the threshold (default is 25), indicating a strong trend.
   - **DI+ > DI-**, signaling that the market is trending upward.
   - The **current volume** is greater than the 20-period average volume multiplied by the **Volume Multiplier** (e.g., 1.5), indicating that the upward price movement is backed by sufficient market activity.

2. **Short Position** (Sell):
   - **ADX** is above the threshold (default is 25), indicating a strong trend.
   - **DI- > DI+**, signaling that the market is trending downward.
   - The **current volume** is greater than the 20-period average volume multiplied by the **Volume Multiplier** (e.g., 1.5), indicating that the downward price movement is backed by strong selling activity.

#### **Exit Conditions**:
- Positions are closed when the opposite signal appears:
  - **For long positions**: Close when the short conditions are met (ADX still above the threshold, DI- > DI+, and the volume condition holds).
  - **For short positions**: Close when the long conditions are met (ADX still above the threshold, DI+ > DI-, and the volume condition holds).

### Parameters:
- **ADX Period**: The period used to calculate ADX (default is 14). This controls how sensitive the ADX is to price movements.
- **ADX Threshold**: The minimum ADX value required for the strategy to consider the market trend as strong (default is 25). Higher values focus on stronger trends.
- **Volume Multiplier**: This parameter adjusts how much higher the current volume needs to be compared to the 20-period moving average for the signal to be valid. A value of 1.5 means the current volume must be 50% higher than the average volume.

### Example Trade Flow:

1. **Long Trade Example**:
   - ADX > 25, confirming a strong trend.
   - DI+ > DI-, confirming that the trend direction is upward.
   - The current volume is 50% higher than the 20-period average volume (multiplied by 1.5).
   - **Action**: Enter a long position.

2. **Short Trade Example**:
   - ADX > 25, confirming a strong trend.
   - DI- > DI+, confirming that the trend direction is downward.
   - The current volume is 50% higher than the 20-period average volume.
   - **Action**: Enter a short position.

### Strengths of the Strategy:
- **Trend Filtering**: The strategy ensures that trades are only taken when the market is trending strongly (confirmed by ADX) and that the price movement is supported by high volume, reducing the likelihood of false signals.
- **Volume Confirmation**: Using volume as confirmation provides an additional layer of reliability, as volume spikes often accompany sustained price moves.
- **Dual Signal Confirmation**: Both trend strength (ADX) and volume conditions must be met for a trade, making the strategy more robust.

### Weaknesses of the Strategy:
- **Limited Effectiveness in Range-Bound Markets**: Since the strategy relies on strong trends, it may underperform in sideways or non-trending markets where ADX stays below the threshold.
- **Lagging Nature of ADX**: ADX is a lagging indicator, which means that it may confirm the trend after it has already begun, potentially leading to late entries.
- **Volume Requirement**: In low-volume markets, the volume multiplier condition may not be met often, leading to fewer trade opportunities.

### Customization:
- **Adjust the ADX Threshold**: You can raise the threshold if you want to focus only on very strong trends, or lower it to capture moderate trends.
- **Adjust the Volume Multiplier**: You can change the multiplier to be more or less strict. A higher multiplier (e.g., 2.0) will require a stronger volume spike to confirm the signal, while a lower multiplier (e.g., 1.2) will allow more trades with weaker volume confirmation.

### Summary:
This ADX and Volume strategy is ideal for traders who want to follow strong trends while ensuring that the trend is supported by high trading volume. By combining a trend strength filter (ADX) and volume confirmation, the strategy aims to increase the probability of entering profitable trades while reducing the number of false signals. However, it may underperform in range-bound markets or in markets with low volume.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © traderhub

//@version=5
strategy("ADX + Volume Strategy", overlay=true)

// Strategy parameters
adxLength = input(21, title="ADX Period")  // ADX period
adxThreshold = input(26, title="ADX Threshold")  // ADX threshold to determine strong trend
volumeMultiplier = input.float(1.8, title="Volume Multiplier", minval=0.1, maxval=10 , step = 0.1)  // Volume multiplier, adjustable float

// Calculate ADX, DI+, DI-
[diPlus, diMinus, adx] = ta.dmi(adxLength, adxLength)

// Average volume for signal confirmation
avgVolume = ta.sma(volume, 20)  // Simple Moving Average of volume over 20 bars

// Conditions for entering a long position
longCondition = adx > adxThreshold and diPlus > diMinus and volume > avgVolume * volumeMultiplier

// Conditions for entering a short position
shortCondition = adx > adxThreshold and diMinus > diPlus and volume > avgVolume * volumeMultiplier

// Enter a long position
if (longCondition)
    strategy.entry("Long", strategy.long)

// Enter a short position
if (shortCondition)
    strategy.entry("Short", strategy.short)

// Close positions on opposite signals
if (strategy.position_size > 0 and shortCondition)
    strategy.close("Long")
if (strategy.position_size < 0 and longCondition)
    strategy.close("Short")

// Display ADX on the chart
plot(adx, color=color.red, title="ADX")
hline(adxThreshold, "ADX Threshold", color=color.green)
````
