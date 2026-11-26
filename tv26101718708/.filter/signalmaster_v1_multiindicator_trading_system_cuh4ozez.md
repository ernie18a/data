# SignalMaster V1 - Multi-Indicator Trading System

- url: https://www.tradingview.com/script/cuH4Ozez-SignalMaster-V1-Multi-Indicator-Trading-System/
- type: indicator
- pine_id: PUB;09760bdb8fc645d2adf8769dd503e2e3
- version: 1.0

## Description

Originality and Usefulness

This indicator is unique because it integrates the Stochastic RSI, RSI, and MACD indicators into a comprehensive tool that simplifies analysis for traders at all experience levels. Experienced traders may be adept at analyzing these indicators individually, extracting insights from their nuanced readings. However, beginner traders often face challenges interpreting these signals separately. This script bridges that gap by merging these powerful tools into a cohesive system that automatically filters and validates trading signals, making it easier to identify entry and exit points without needing advanced technical knowledge.

Each component of this mashup serves a critical role:
- Stochastic RSI helps pinpoint overbought and oversold conditions with high sensitivity, offering timely reversal signals.
- RSI acts as an additional momentum filter, providing a wider context and enhancing signal accuracy.
- MACD functions as a trend-confirmation tool, ensuring that momentum shifts are validated for more reliable decision-making.
- Candle Color Confirmation adds another layer of verification, only activating signals when price action supports the indicator analysis.

This integrated approach is especially useful for beginner traders who may not know how to interpret individual indicators effectively, while still providing experienced traders with a robust framework that complements their analysis.

Description of the Indicator
This Pine Script is designed to provide traders with buy and sell signals based on the combination of Stochastic RSI, RSI, and MACD indicators, enhanced by the confirmation of candle colors. The primary goal is to facilitate informed trading decisions in various market conditions by utilizing different indicators and their interactions. The script allows customization of various parameters, providing flexibility for traders to adapt it to their specific trading styles.

Usefulness
This indicator is not just a mashup of existing indicators; it integrates the functionality of multiple momentum and trend-detection methods into a cohesive trading tool. The combination of Stochastic RSI, RSI, and MACD offers a well-rounded approach to analyzing market conditions, allowing traders to identify entry and exit points effectively. The inclusion of color-coded signals (strong vs. weak) further enhances its utility by providing visual cues about the strength of the signals.

How to Use This Indicator
Input Settings: Adjust the parameters for the Stochastic RSI, RSI, and MACD to fit your trading style. Set the overbought/oversold levels according to your risk tolerance.

Signal Colors:
Strong Buy Signal: Indicated by a green label and confirmed by a green candle (close > open).
Weak Buy Signal: Indicated by a blue label and confirmed by a green candle (close > open).
Strong Sell Signal: Indicated by a red label and confirmed by a red candle (close < open).
Weak Sell Signal: Indicated by an orange label and confirmed by a red candle (close < open).


Example Trading Strategy Using This Indicator
To effectively use this indicator as part of your trading strategy, follow these detailed steps:

Setup:
Timeframe: Select a timeframe that aligns with your trading style (e.g., 15-minute for intraday, 1-hour for swing trading, or daily for longer-term positions).
Indicator Settings: Customize the Stochastic RSI, RSI, and MACD parameters to suit your trading approach. Adjust overbought/oversold levels to match your risk tolerance.


Strategy:
1. Strong Buy Entry Criteria:
Wait for a strong buy signal (green label) when the RSI is at or below the oversold level (e.g., ≤ 35), indicating a deeply oversold market. Confirm that the MACD shows a decreasing trend (bearish momentum weakening) to validate a potential reversal. Ensure the current candle is green (close > open) if candle color confirmation is enabled.
Example Use: On a 1-hour chart, if the RSI drops below 35, MACD shows three consecutive bars of decreasing negative momentum, and a green candle forms, enter a buy position. This setup signals a robust entry with strong momentum backing it.

2. Weak Buy Entry Criteria:
Monitor for weak buy signals (blue label) when RSI is above the oversold level but still below the neutral (e.g., between 36 and 50). This indicates a market recovering from an oversold state but not fully reversing yet. These signals can be used for early entries with additional confirmations, such as support levels or higher timeframe trends.
Example Use: On the same 1-hour chart, if RSI is at 45, the MACD shows momentum stabilizing (not necessarily negative), and a green candle appears, consider a partial or cautious entry. Use this as an early warning for a potential bullish move, especially when higher timeframe indicators align.

3. Strong Sell Entry Criteria:
Look for a strong sell signal (red label) when RSI is at or above the overbought level (e.g., ≥ 65), signaling a strong overbought condition. The MACD should show three consecutive bars of increasing positive momentum to indicate that the bullish trend is weakening. Ensure the current candle is red (close < open) if candle color confirmation is enabled.
Example Use: If RSI reaches 70, MACD shows increasing momentum that starts to level off, and a red candle forms on a 1-hour chart, initiate a short position with a stop loss set above recent resistance. This is a high-confidence signal for potential price reversal or pullback.

4. Weak Sell Entry Criteria:
Use weak sell signals (orange label) when RSI is between the neutral and overbought levels (e.g., between 50 and 64). These can indicate potential short opportunities that might not yet be fully mature but are worth monitoring. Look for other confirmations like resistance levels or trendline touches to strengthen the signal.
Example Use: If RSI reads 60 on a 1-hour chart, and the MACD shows slight positive momentum with signs of slowing down, place a cautious sell position or scale out of existing long positions. This setup allows you to prepare for a possible downtrend.

Trade Management:
Stop Loss: For buy trades, place stop losses below recent swing lows. For sell trades, set stops above recent swing highs to manage risk effectively.
Take Profit: Target nearby resistance or support levels, apply risk-to-reward ratios (e.g., 1:2), or use trailing stops to lock in profits as price moves in your favor.
Confirmation: Align these signals with broader trends on higher timeframes. For example, if you receive a weak buy signal on a 15-minute chart, check the 1-hour or daily chart to ensure the overall trend is not bearish.

Real-World Example: Imagine trading on a 15-minute chart:
For a buy:
A strong buy signal (green) appears when the RSI dips to 32, MACD shows declining bearish momentum, and a green candle forms. Enter a buy position with a stop loss below the most recent support level.
Alternatively, a weak buy signal (blue) appears when RSI is at 47. Use this as a signal to start monitoring the market closely or enter a smaller position if other indicators (like support and volume analysis) align.

For a sell:
A strong sell signal (red) with RSI at 72 and a red candle signals to short with conviction. Place your stop loss just above the last peak.
A weak sell signal (orange) with RSI at 62 might prompt caution but can still be acted on if confirmed by declining volume or touching a resistance level.

These strategies show how to blend both strong and weak signals into your trading for more nuanced decision-making.

[b]Overview of the Resistance Lines Feature:[/b]
The latest update enhances its functionality by introducing the ability to identify and visualize resistance levels directly on the price chart. This feature allows traders to see significant resistance zones based on historical price reversals, aiding in decision-making for buy and sell signals generated by the script.

Key Features of the Resistance Lines Update:
Dynamic Resistance Zone Identification:
The script tracks price reversals using a user-defined threshold (default set to 50). When the price hits a level where multiple reversals have occurred, it marks this as a significant resistance zone. This functionality helps traders pinpoint critical price levels where selling pressure may arise.

Zone Length Setting:
The "Zone Length (Candles)" parameter (default value set to 50) allows traders to specify how far the resistance lines extend backward and forward on the chart. This visual extension illustrates the historical significance of the resistance level, providing context for current price action.

Visual Representation:
Clear lines are drawn at identified resistance levels, enabling traders to quickly recognize areas where the price has previously faced selling pressure. This visual clarity supports faster decision-making as traders approach these critical zones.

Adaptability:
The resistance levels dynamically update in real-time as new highs or lows occur. This ensures that traders always have access to the most current resistance information, reflecting the ongoing market conditions.

How This Update Benefits Traders
Enhanced Buy/Sell Signal Analysis: The resistance lines feature works synergistically with the script's buy/sell signals, which are color-coded based on the strength of the signal:
Green Buy Signals: Indicate a strong buying opportunity when the RSI is at or below 35.
Blue Buy Signals: Suggest a moderate buying opportunity when the RSI is above 35 but still indicates bullish potential.
Red Sell Signals: Represent a strong selling opportunity when the RSI is at or above 70.
Orange Sell Signals: Indicate a moderate selling opportunity when the RSI is below 70 but still suggests bearish pressure.

By aligning these signals with the identified resistance levels, traders can make more informed decisions. For instance, if a strong red sell signal occurs near a significant resistance zone, it indicates a higher likelihood of a price reversal, prompting the trader to consider executing a sell order.

Strategic Planning: The clear visualization of resistance levels allows traders to refine their entry and exit strategies based on historical price behavior. By understanding where significant selling pressure has occurred, traders can better assess the strength of current buy/sell signals.

Example Usage: For example, if a trader observes a resistance zone at $100 and the script generates a strong red sell signal as the price approaches this level, they can plan to sell, anticipating a reversal. Conversely, if a green buy signal appears after a price bounce off the resistance zone, traders can exercise caution, knowing the potential for price rejection at that level.

[b]Dynamic Table[/b]
The new feature introduces a dynamic table that displays buy and sell signals across multiple timeframes directly on the trading chart. This table is positioned at the bottom right corner of the chart and provides real-time updates on signal status for the following timeframes: 5 minutes, 15 minutes, 1 hour, 4 hours, and 1 day. Each cell in the table represents a specific timeframe and shows whether a buy or sell signal is active. The table also color-codes the signals based on the RSI value at the time the signal was generated, providing visual cues for quick interpretation.

Usefulness for Traders
Multi-Timeframe Analysis: Traders can quickly assess the status of signals across different timeframes, allowing for a comprehensive view of market trends and potential entry/exit points.

Risk Management: By monitoring signals across multiple timeframes, traders can better manage risk by ensuring that signals are consistent across various timeframes before entering a trade.

Decision Support: The table provides a clear and concise summary of signal activity, aiding traders in making informed decisions without manually switching between different timeframes.

Visual Clarity: The color-coded signals help traders quickly identify the strength and type of signal, making it easier to prioritize and act on the most relevant signals.

[b]Customizable Signal Table Timeframes:[/b]

Feature: Individual toggle controls for each timeframe displayed in the multi-timeframe signal table.
Timeframes available: 5m, 15m, 1h, 4h, 1D
Default state: All timeframes enabled

Functionality:
Each timeframe can be independently enabled/disabled in settings
Table automatically adjusts size based on active timeframes
Only selected timeframes appear in the table
Optimizes screen space for focused analysis

Use cases:
Day Traders: Hide daily timeframe, focus on 5m, 15m, 1h
Swing Traders: Hide 5m and 15m, focus on 4h and 1D
Position Traders: Show only 4h and 1D for long-term perspective
Custom Strategies: Mix and match any combination of timeframes

Benefits:
✅ Cleaner, less cluttered interface
✅ Faster visual scanning of relevant signals
✅ Optimized screen real estate usage
✅ Personalized to individual trading style
✅ Improved focus on strategy-relevant timeframes

[b]New Feature: ADX Filter for Buy/Sell Signals[/b]
We’re excited to introduce a new feature to the Stoch RSI and RSI Buy/Sell Signals indicator: the ADX Filter. This optional filter allows traders to ensure that buy and sell signals are only generated when the Average Directional Index (ADX) is above a user-defined threshold, indicating a strong trend.

How It Works
The ADX measures the strength of a trend, regardless of its direction. A higher ADX value indicates a stronger trend.
When the ADX filter is enabled, buy and sell signals will only appear if the ADX value is above the specified threshold (default: 25).
The ADX filter is disabled by default, so traders can choose whether or not to use it based on their trading strategy.

Why This Feature Helps Traders

Avoid False Signals in Weak Trends:
In choppy or sideways markets, the ADX value tends to be low. By enabling the ADX filter, traders can avoid taking signals during these periods, reducing the risk of false or low-probability trades.

Focus on Strong Trends:
The ADX filter ensures that signals are only generated when the market is trending strongly. This helps traders focus on high-probability setups where the trend is more likely to continue.

Customizable Threshold:
Traders can adjust the ADX threshold to suit their trading style. For example, a higher threshold (e.g., 30) can be used for more conservative trading, while a lower threshold (e.g., 20) can be used for more frequent signals.

Enhanced Risk Management:
By filtering out signals in weak or non-trending markets, traders can reduce unnecessary trades and improve their risk-to-reward ratio.

How to Enable the ADX Filter
Go to the Conditions section in the indicator settings.
Enable the ADX Condition toggle.
Set the desired ADX Length (default: 14) and ADX Limit (default: 25).

Signals will now only appear if the ADX value is above the specified limit.

Why It’s Disabled by Default
The ADX filter is disabled by default to ensure compatibility with all trading styles. Some traders may prefer to take signals in all market conditions, including sideways or weak trends. By keeping the feature optional, traders can decide whether to use it based on their individual preferences and strategies.

Conclusion
The new ADX filter is a powerful addition to the Stoch RSI and RSI Buy/Sell Signals indicator. By enabling it, traders can focus on high-quality signals during strong trends, improving their trading accuracy and risk management. Give it a try and see how it enhances your trading strategy!

[b]Enhanced Tooltips[/b]
The tooltips in the indicator script have been enhanced to provide more detailed and clear information about each setting. These improvements aim to make the indicator more user-friendly and accessible, ensuring traders can easily understand and configure the parameters according to their strategies. The enhanced tooltips offer comprehensive guidance on how each setting affects the indicator and suggest potential trading scenarios, reducing the likelihood of misconfiguration and leading to more accurate and informed trading decisions.

## Source Code

````pine
//@version=6
indicator('SignalMaster V1 - Multi-Indicator Trading System', shorttitle='SignalMaster V1.0', overlay=true)



// Stochastic RSI Settings
stochLength = input.int(14, title='Stochastic RSI Length', minval=1, group='Stochastic RSI Settings', tooltip='This setting determines the period over which the RSI is calculated for the Stochastic RSI. A higher value will make the indicator less sensitive to price changes, smoothing out the fluctuations, but may lag more. A lower value makes it more sensitive and responsive to recent price changes.', display=display.none)
stochSmoothing = input.int(3, title='Stochastic Smoothing (Slow K)', minval=1, group='Stochastic RSI Settings', tooltip='This is the smoothing period for the Stochastic RSI\'s slow K line. It smooths the %K line to reduce noise and false signals. A higher value means more smoothing, resulting in fewer but potentially more reliable signals.', display=display.none)
stochOverbought = input.float(90, title='Stoch RSI Overbought Level', minval=0, maxval=100, group='Stochastic RSI Settings', tooltip='This is the threshold above which the Stochastic RSI is considered overbought. When the Stochastic RSI exceeds this level, it may indicate that the asset is overpriced and could be a sell signal. Adjusting this value can help tune the indicator to different market conditions.', display=display.none)
stochOversold = input.float(10, title='Stoch RSI Oversold Level', minval=0, maxval=100, group='Stochastic RSI Settings', tooltip='Similar to the overbought level, this is the threshold below which the Stochastic RSI is considered oversold. It may indicate that the asset is undervalued and could be a buy signal.', display=display.none)

// RSI Settings
rsiLength = input.int(14, title='RSI Length', minval=1, group='RSI Settings', tooltip='The period over which the RSI is calculated. The default is 14, but adjusting this can make the RSI more or less sensitive to price changes. A shorter period makes it more sensitive, while a longer period smooths out the fluctuations.', display=display.none)
rsiOverbought = input.float(65, title='RSI Overbought Level', minval=0, maxval=100, group='RSI Settings', tooltip='Level above which the RSI is considered overbought. Typically set above 70, but here it\'s set to 65. When RSI exceeds this level, it may suggest that the asset is overpriced.', display=display.none)
rsiNeutral = input.float(50, title='RSI Neutral Level', minval=0, maxval=100, group='RSI Settings', tooltip='The neutral level, usually set at 50, which is the midpoint of the RSI oscillator. It\'s where the RSI is neither indicating overbought nor oversold conditions.', display=display.none)
rsiOversold = input.float(35, title='RSI Oversold Level', minval=0, maxval=100, group='RSI Settings', tooltip='Level below which the RSI is considered oversold. Typically below 30, but set to 35 here. It may indicate that the asset is undervalued.', display=display.none)

// MACD Settings
macdLengthFast = input.int(12, title='MACD Fast Length', minval=1, group='MACD Settings', tooltip='The number of periods for the fast EMA in the MACD calculation. A shorter period makes the MACD more responsive to price changes.', display=display.none)
macdLengthSlow = input.int(26, title='MACD Slow Length', minval=1, group='MACD Settings', tooltip='The number of periods for the slow EMA in the MACD calculation. A longer period makes it less responsive but can help filter out noise.', display=display.none)
macdSignalLength = input.int(9, title='MACD Signal Length', minval=1, group='MACD Settings', tooltip='The number of periods for the signal line, which is an EMA of the MACD line. It\'s used to generate buy and sell signals through crossovers with the MACD line.', display=display.none)

// ADX Settings
adxLength = input.int(14, title='ADX Length', minval=1, group='ADX Settings', tooltip='The period over which the ADX is calculated. ADX measures the strength of a trend, with higher values indicating a stronger trend.', display=display.none)
adxLimit = input.float(25, title='ADX Limit', minval=0, group='ADX Settings', tooltip='The ADX value above which the trend is considered strong. Signals may be filtered based on this condition to avoid whipsaws in ranging markets.', display=display.none)

// EMA Settings
showEMAs = input.bool(false, title='Show EMAs', group='EMA Settings', tooltip='Display the three most important Exponential Moving Averages on the chart.', display=display.none)
ema20Length = input.int(20, title='EMA 20 Length', minval=1, group='EMA Settings', tooltip='Period for the fast EMA, commonly used for short-term trend identification.', display=display.none)
ema50Length = input.int(50, title='EMA 50 Length', minval=1, group='EMA Settings', tooltip='Period for the medium EMA, used for intermediate trend analysis.', display=display.none)
ema200Length = input.int(200, title='EMA 200 Length', minval=1, group='EMA Settings', tooltip='Period for the slow EMA, widely used for long-term trend identification.', display=display.none)
ema20Color = input.color(color.new(color.green, 0), title='EMA 20 Color', group='EMA Settings', display=display.none)
ema50Color = input.color(color.new(color.orange, 0), title='EMA 50 Color', group='EMA Settings', display=display.none)
ema200Color = input.color(color.new(color.red, 0), title='EMA 200 Color', group='EMA Settings', display=display.none)

// Signal Colors
buyColorGreen = input.color(color.green, title='Buy Signal - RSI <= Oversold', group='Signal Colors', tooltip='The color for buy signals when the RSI is below or equal to the oversold level, indicating a stronger buy signal.', display=display.none)
buyColorBlue = input.color(color.blue, title='Buy Signal - RSI > Oversold', group='Signal Colors', tooltip='The color for buy signals when the RSI is above the oversold level but still indicating a buy condition.', display=display.none)
sellColorRed = input.color(color.red, title='Sell Signal - RSI >= Overbought', group='Signal Colors', tooltip='The color for sell signals when the RSI is above or equal to the overbought level, indicating a stronger sell signal.', display=display.none)
sellColorOrange = input.color(color.orange, title='Sell Signal - RSI < Overbought', group='Signal Colors', tooltip='The color for sell signals when the RSI is below the overbought level but still indicating a sell condition.', display=display.none)

// Conditions
enableMACDCondition = input.bool(true, title='Enable MACD Trend Condition', group='Conditions', tooltip='Enabling this will require the MACD trend condition to be met for signals to be generated. This adds an additional filter based on the MACD line\'s direction.', display=display.none)
enableCandleColorCondition = input.bool(true, title='Enable Candle Color Condition', group='Conditions', tooltip='Enabling this will require the candle color to confirm the signal direction. For buys, the candle should close higher than it opened, and for sells, the opposite.', display=display.none)
enableADXCondition = input.bool(false, title='Enable ADX Condition', group='Conditions', tooltip='Enabling this will require the ADX condition to be met, meaning the ADX value must be above the specified limit for signals to be generated.', display=display.none)

// Support/Resistance Zones
showSupportResistanceZones = input.bool(true, title='Show Support/Resistance Zones', group='Support/Resistance Zones', tooltip='Enabling this will display support and resistance zones on the chart based on price reversals over a specified number of bars.', display=display.none)
reversalThreshold = input.int(50, title='Reversal Count for S/R Zone', minval=1, group='Support/Resistance Zones', tooltip='The number of bars over which a reversal must occur to identify a support or resistance level. Higher values require more confirmation for a reversal.', display=display.none)
zoneLength = input.int(500, title='Zone Length (Candles)', minval=1, group='Support/Resistance Zones', tooltip='The length of the support and resistance zones, measured in candles. This determines how far the horizontal lines extend on the chart.', display=display.none)

// Signal Table
showTable = input.bool(true, title='Show Signal Table', group='Signal Table', tooltip='Enabling this will show a table at the bottom right of the chart displaying buy and sell signals across different time frames.', display=display.none)
show5m = input.bool(true, title='Show 5m Timeframe', group='Signal Table', tooltip='Display 5-minute timeframe signals in the table.', display=display.none)
show15m = input.bool(true, title='Show 15m Timeframe', group='Signal Table', tooltip='Display 15-minute timeframe signals in the table.', display=display.none)
show1h = input.bool(true, title='Show 1h Timeframe', group='Signal Table', tooltip='Display 1-hour timeframe signals in the table.', display=display.none)
show4h = input.bool(true, title='Show 4h Timeframe', group='Signal Table', tooltip='Display 4-hour timeframe signals in the table.', display=display.none)
show1D = input.bool(true, title='Show 1D Timeframe', group='Signal Table', tooltip='Display daily timeframe signals in the table.', display=display.none)

// Calculations

// Calculating RSI
rsi = ta.rsi(close, rsiLength)

// Calculating EMAs
ema20 = ta.ema(close, ema20Length)
ema50 = ta.ema(close, ema50Length)
ema200 = ta.ema(close, ema200Length)

// Calculating Stochastic RSI
stochRsiK = ta.stoch(rsi, rsi, rsi, stochLength)
stochRsiD = ta.sma(stochRsiK, stochSmoothing)

// Calculating MACD
[macdLine, signalLine, _] = ta.macd(close, macdLengthFast, macdLengthSlow, macdSignalLength)

// Check for 3 consecutive bars decreasing (negative) in MACD - CORRIGIDO
macdDecreasing = macdLine < 0 and macdLine < macdLine[1] and macdLine[1] < macdLine[2]

// Check for 3 consecutive bars increasing (positive) in MACD - CORRIGIDO
macdIncreasing = macdLine > 0 and macdLine > macdLine[1] and macdLine[1] > macdLine[2]

// ADX Calculation - SIMPLIFICADO
dirmov(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = up > down and up > 0 ? up : 0
    minusDM = down > up and down > 0 ? down : 0
    truerange = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
    minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
    [plus, minus]

adx(dilen, adxlen) =>
    [plus, minus] = dirmov(dilen)
    sum = plus + minus
    adx = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)
    adx

currentAdx = adx(adxLength, adxLength)

// ADX Condition
adxCondition = currentAdx > adxLimit

// Buy and Sell Conditions
buyConditionMet = stochRsiK < stochOversold and stochRsiD < stochOversold
sellConditionMet = stochRsiK > stochOverbought and stochRsiD > stochOverbought

if enableMACDCondition
    buyConditionMet := buyConditionMet and macdDecreasing
    sellConditionMet := sellConditionMet and macdIncreasing

if enableADXCondition
    buyConditionMet := buyConditionMet and adxCondition
    sellConditionMet := sellConditionMet and adxCondition

// Flags to track conditions met in the previous candle
var bool buyFlag = false
var bool sellFlag = false
var float previousRsiValue = na

// Update flags and store RSI if conditions are met
if buyConditionMet and (enableCandleColorCondition ? close < open : true)
    buyFlag := true
    previousRsiValue := rsi

if sellConditionMet and (enableCandleColorCondition ? close > open : true)
    sellFlag := true
    previousRsiValue := rsi

// Determine colors for buy/sell signals based on RSI level
buyColor = previousRsiValue <= rsiOversold ? buyColorGreen : buyColorBlue
sellColor = previousRsiValue >= rsiOverbought ? sellColorRed : sellColorOrange

// Signals with flag and candle color checks
buySignal = buyFlag and (enableCandleColorCondition ? close > open : true)
sellSignal = sellFlag and (enableCandleColorCondition ? close < open : true)

// Reset flags after signals are triggered
if buySignal
    buyFlag := false

if sellSignal
    sellFlag := false

// Alerts
alertcondition(buySignal, title='Buy Alert', message='Buy signal generated!')
alertcondition(sellSignal, title='Sell Alert', message='Sell signal generated!')

// User input to toggle buy/sell signals visibility
showSignals = input(true, title='Show Buy/Sell Signals', display=display.none)

// Plotting buy/sell signals based on user input with previous RSI value in the text
if showSignals and buySignal and not na(previousRsiValue)
    label.new(bar_index, low, 'BUY (' + str.tostring(math.floor(previousRsiValue)) + ')', color=buyColor, style=label.style_label_up, textcolor=color.white, size=size.small)

if showSignals and sellSignal and not na(previousRsiValue)
    label.new(bar_index, high, 'SELL (' + str.tostring(math.floor(previousRsiValue)) + ')', color=sellColor, style=label.style_label_down, textcolor=color.white, size=size.small)

// Plot EMAs
plot(showEMAs ? ema20 : na, title='EMA 20', color=ema20Color, linewidth=2)
plot(showEMAs ? ema50 : na, title='EMA 50', color=ema50Color, linewidth=2)
plot(showEMAs ? ema200 : na, title='EMA 200', color=ema200Color, linewidth=2)

// --- Support and Resistance Zones --- CORRIGIDO

// Variables for tracking reversal levels
var array<float> supportLevels = array.new_float()
var array<float> resistanceLevels = array.new_float()

// Arrays para armazenar as linhas desenhadas - NOVO
var array<line> supportLines = array.new_line()
var array<line> resistanceLines = array.new_line()

// Track reversal levels for support and resistance
if ta.lowestbars(low, reversalThreshold) == 0
    array.push(supportLevels, low)
    // Limitar o tamanho do array - NOVO
    if array.size(supportLevels) > 100
        array.shift(supportLevels)

if ta.highestbars(high, reversalThreshold) == 0
    array.push(resistanceLevels, high)
    // Limitar o tamanho do array - NOVO
    if array.size(resistanceLevels) > 100
        array.shift(resistanceLevels)

// Function to draw support and resistance zones - CORRIGIDO
drawZone(level, color, lineArray) =>
    startBar = bar_index - zoneLength < 0 ? 0 : bar_index - zoneLength
    endBar = bar_index + 500
    
    // Cria a nova linha
    newLine = line.new(startBar, level, endBar, level, color=color, width=2, style=line.style_solid)
    
    // Adiciona ao array
    array.push(lineArray, newLine)
    
    // Limita a 50 linhas - deleta a mais antiga
    if array.size(lineArray) > 50
        oldLine = array.shift(lineArray)
        line.delete(oldLine)

// Draw zones if levels meet the threshold for reversals and visibility is enabled
if showSupportResistanceZones
    if array.size(supportLevels) >= reversalThreshold
        lastSupport = array.get(supportLevels, array.size(supportLevels) - 1)
        drawZone(lastSupport, color.green, supportLines)

    if array.size(resistanceLevels) >= reversalThreshold
        lastResistance = array.get(resistanceLevels, array.size(resistanceLevels) - 1)
        drawZone(lastResistance, color.red, resistanceLines)

// Define the time frames
timeframe5 = '5'
timeframe15 = '15'
timeframe1H = '60'
timeframe4H = '240'
timeframe1D = 'D'

// Fetch signals and previous RSI values from each time frame
[buySignal5, sellSignal5, prevRsi5] = request.security(syminfo.tickerid, timeframe5, [buySignal, sellSignal, previousRsiValue])
[buySignal15, sellSignal15, prevRsi15] = request.security(syminfo.tickerid, timeframe15, [buySignal, sellSignal, previousRsiValue])
[buySignal1H, sellSignal1H, prevRsi1H] = request.security(syminfo.tickerid, timeframe1H, [buySignal, sellSignal, previousRsiValue])
[buySignal4H, sellSignal4H, prevRsi4H] = request.security(syminfo.tickerid, timeframe4H, [buySignal, sellSignal, previousRsiValue])
[buySignal1D, sellSignal1D, prevRsi1D] = request.security(syminfo.tickerid, timeframe1D, [buySignal, sellSignal, previousRsiValue])

// Count active timeframes for table sizing
activeTimeframes = 0
if show5m
    activeTimeframes := activeTimeframes + 1
if show15m
    activeTimeframes := activeTimeframes + 1
if show1h
    activeTimeframes := activeTimeframes + 1
if show4h
    activeTimeframes := activeTimeframes + 1
if show1D
    activeTimeframes := activeTimeframes + 1

// Create the table at the bottom right of the chart with dynamic columns
var table myTable = table.new(position.bottom_right, activeTimeframes + 1, 2, bgcolor=color.black, border_color=color.white)

// Set column labels for the table dynamically based on enabled timeframes
if showTable and activeTimeframes > 0
    table.cell(myTable, 0, 0, 'Time Frame:', text_color=color.white, bgcolor=color.black)
    table.cell(myTable, 0, 1, 'Signals', text_color=color.white, bgcolor=color.gray)
    
    int col = 1
    
    if show5m
        table.cell(myTable, col, 0, '5m', text_color=color.white, bgcolor=color.black)
        col := col + 1
    
    if show15m
        table.cell(myTable, col, 0, '15m', text_color=color.white, bgcolor=color.black)
        col := col + 1
    
    if show1h
        table.cell(myTable, col, 0, '1h', text_color=color.white, bgcolor=color.black)
        col := col + 1
    
    if show4h
        table.cell(myTable, col, 0, '4h', text_color=color.white, bgcolor=color.black)
        col := col + 1
    
    if show1D
        table.cell(myTable, col, 0, 'D', text_color=color.white, bgcolor=color.black)

// Function to determine the color based on the previous RSI value
getColor(buy, sell, prevRsi) =>
    if buy
        prevRsi <= rsiOversold ? buyColorGreen : buyColorBlue
    else if sell
        prevRsi >= rsiOverbought ? sellColorRed : sellColorOrange
    else
        color.silver // No signal

// Update the table cells with signals and colors in real-time 
if barstate.isrealtime and showTable and activeTimeframes > 0
    int col = 1
    
    if show5m
        table.cell(myTable, col, 1, buySignal5 ? 'BUY' : sellSignal5 ? 'SELL' : '', text_color=color.white, bgcolor=getColor(buySignal5, sellSignal5, prevRsi5))
        col := col + 1
    
    if show15m
        table.cell(myTable, col, 1, buySignal15 ? 'BUY' : sellSignal15 ? 'SELL' : '', text_color=color.white, bgcolor=getColor(buySignal15, sellSignal15, prevRsi15))
        col := col + 1
    
    if show1h
        table.cell(myTable, col, 1, buySignal1H ? 'BUY' : sellSignal1H ? 'SELL' : '', text_color=color.white, bgcolor=getColor(buySignal1H, sellSignal1H, prevRsi1H))
        col := col + 1
    
    if show4h
        table.cell(myTable, col, 1, buySignal4H ? 'BUY' : sellSignal4H ? 'SELL' : '', text_color=color.white, bgcolor=getColor(buySignal4H, sellSignal4H, prevRsi4H))
        col := col + 1
    
    if show1D
        table.cell(myTable, col, 1, buySignal1D ? 'BUY' : sellSignal1D ? 'SELL' : '', text_color=color.white, bgcolor=getColor(buySignal1D, sellSignal1D, prevRsi1D))
````
