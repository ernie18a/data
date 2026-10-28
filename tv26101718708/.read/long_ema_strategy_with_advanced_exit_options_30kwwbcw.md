# Long EMA Strategy with Advanced Exit Options

- url: https://www.tradingview.com/script/30KWwbCw/
- type: strategy
- pine_id: PUB;5198cefb54984bcc8d1eca5dc4f18c8c
- version: 8.0

## Description

This  strategy  is designed for traders seeking a  trend-following system with a focus on precision and adaptability.

**Core Strategy Concept**

The essence of this strategy lies in use of Exponential Moving Averages (EMAs) to identify potential long (buy) positions based on the relative positions of short-term, medium-term, and long-term EMAs. The use of EMAs is a classic yet powerful approach to trend detection, as these indicators smooth out price data over time, emphasizing the direction of recent price movements and potentially signaling the beginning of new trends.

**Customizable Parameters**

- **EMA Periods**: Users can define the periods for three EMAs - long-term, medium-term, and short-term - allowing for a tailored approach to capture trends based on individual trading styles and market conditions.
- **Volatility Filter**: An optional Average True Range (ATR)-based volatility filter can be toggled on or off. When activated, it ensures that trades are only entered when market volatility exceeds a user-defined threshold, aiming to filter out entries during low-volatility periods which are often characterized by indecisive market movements.
- **Trailing Stop Loss**: A trailing stop loss mechanism, expressed as a percentage of the highest price achieved since entry, provides a dynamic way to manage risk by allowing profits to run while cutting losses.
- **EMA Exit Condition**: This advanced exit option enables closing positions when the short-term EMA crosses below the medium-term EMA, serving as a signal that the immediate trend may be reversing.
- **Close Below EMA Exit**: An additional exit condition, which is disabled by default, allows positions to be closed if the price closes below a user-selected EMA. This provides an extra layer of flexibility and risk management, catering to traders who prefer to exit positions based on specific EMA thresholds.

**Operational Mechanics**

Upon activation, the strategy evaluates the current price in relation to the set EMAs. A long position is considered when the current price is above the long-term EMA, and the short-term EMA is above the medium-term EMA. This setup aims to identify moments where the price momentum is strong and likely to continue.

The strategy's versatility is further enhanced by its optional settings:
- The **Volatility Filter** adjusts the sensitivity of the strategy to market movements, potentially improving the quality of the entries during volatile market conditions.
 The Average True Range (ATR) is a key component of this filter, providing a measure of market volatility by calculating the average range between the high and low prices over a specified number of periods. Here's how you can adjust the volatility filter settings for various market conditions, focusing on filtering out low-volatility markets:

Setting Examples for Volatility Filter
1. High Volatility Markets (e.g., Cryptocurrencies, Certain Forex Pairs):

ATR Periods: 14 (default)
ATR Multiplier: Setting the multiplier to a lower value, such as 1.0 or 1.2, can be beneficial in high-volatility markets. This sensitivity allows the strategy to react to volatility changes more quickly, ensuring that you're entering trades during periods of significant movement.
2. Medium Volatility Markets (e.g., Major Equity Indices, Medium-Volatility Forex Pairs):

ATR Periods: 14 (default)
ATR Multiplier: A multiplier of 1.5 (default) is often suitable for medium volatility markets. It provides a balanced approach, ensuring that the strategy filters out low-volatility conditions without being overly restrictive.
3. Low Volatility Markets (e.g., Some Commodities, Low-Volatility Forex Pairs):

ATR Periods: Increasing the ATR period to 20 or 25 can smooth out the volatility measure, making it less sensitive to short-term fluctuations. This adjustment helps in focusing on more significant trends in inherently stable markets.
ATR Multiplier: Raising the multiplier to 2.0 or even 2.5 increases the threshold for volatility, effectively filtering out low-volatility conditions. This setting ensures that the strategy only triggers trades during periods of relatively higher volatility, which are more likely to result in significant price movements.
How to Use the Volatility Filter for Low-Volatility Markets
For traders specifically interested in filtering out low-volatility markets, the key is to adjust the ATR Multiplier to a higher level. This adjustment increases the threshold required for the market to be considered sufficiently volatile for trade entries. Here's a step-by-step guide:

Adjust the ATR Multiplier: Increase the ATR Multiplier to create a higher volatility threshold. A multiplier of 2.0 to 2.5 is a good starting point for very low-volatility markets.

Fine-Tune the ATR Periods: Consider lengthening the ATR calculation period if you find that the strategy is still entering trades in undesirable low-volatility conditions. A longer period provides a more averaged-out measure of volatility, which might better suit your needs.

Monitor and Adjust: Volatility is not static, and market conditions can change. Regularly review the performance of your strategy in the context of current market volatility and adjust the settings as necessary.

Backtest in Different Conditions: Before applying the strategy live, backtest it across different market conditions with your adjusted settings. This process helps ensure that your approach to filtering low-volatility conditions aligns with your trading objectives and risk tolerance.

By fine-tuning the volatility filter settings according to the specific characteristics of the market you're trading in, you can enhance the performance of this strategy
- The **Trailing Stop Loss** and **EMA Exit Conditions** provide two layers of exit strategies, focusing on capital preservation and profit maximization.

**Visualizations**

For clarity and ease of use, the strategy plots the three EMAs and, if enabled, the ATR threshold on the chart. These visual cues not only aid in decision-making but also help in understanding the market's current trend and volatility state.

**How to Use**

Traders can customize the EMA periods to fit their trading horizon, be it short, medium, or long-term trading. The volatility filter and exit options allow for further customization, making the strategy adaptable to different market conditions and personal risk tolerance levels.

By offering a blend of trend-following principles with advanced risk management features, this strategy aims to cater to a wide range of trading styles, from cautious to aggressive. Its strength lies in its flexibility, allowing traders to fine-tune settings to their specific needs, making it a potentially valuable tool in the arsenal of any trader looking for a disciplined approach to navigating the markets.

## Source Code

````pine
//@version=5
strategy("Long EMA Strategy with Advanced Exit Options", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=5, initial_capital=10000, commission_type=strategy.commission.cash_per_order, commission_value=1)

// === ENTRY STRATEGY ===
// Input per la scelta del tipo di media mobile e le condizioni di ingresso
maTypeInput = input.string("EMA", title="Select MA Type", options=["EMA", "SMA", "WMA", "HMA"])
entryConditionType = input.string("Crossover", title="Entry Condition Type", options=["Crossover", "Above MA"])
emaLongTermPeriod = input.int(200, title="Long Term MA Period", minval=1)
emaShortTermPeriod = input.int(5, title="Short Term MA Period", minval=1)
emaMidTermPeriod = input.int(10, title="Medium Term MA Period", minval=1)

// Funzione per calcolare la media mobile in base alla scelta dell'utente
calculateMA(type, source, length) =>
    float result = na
    if type == "SMA"
        result := ta.sma(source, length)
    else if type == "WMA"
        result := ta.wma(source, length)
    else if type == "HMA"
        result := ta.hma(source, length)  // Esempio di come integrare l'Hull Moving Average
    else
        result := ta.ema(source, length)
    result

// Calcolo delle medie mobili con funzione personalizzata
longTermMA = calculateMA(maTypeInput, close, emaLongTermPeriod)
shortTermMA = calculateMA(maTypeInput, close, emaShortTermPeriod)
midTermMA = calculateMA(maTypeInput, close, emaMidTermPeriod)

// Condizione di entrata
var bool enterLongCondition = false
if entryConditionType == "Crossover"
    enterLongCondition := ta.crossover(shortTermMA, midTermMA) and close > longTermMA
else if entryConditionType == "Above MA"
    enterLongCondition := shortTermMA > midTermMA and close > longTermMA

if (enterLongCondition)
    strategy.entry("Enter Long", strategy.long)

// === EXIT STRATEGY ===
enableMacdExit = input.bool(true, title="Enable MACD Exit Strategy")
timeframeSelection = input.string("W", title="Select MACD Timeframe", options=["D", "W"])
macdSource = input(close, title="MACD Source")
macdFastLength = input.int(12, title="MACD Fast Length")
macdSlowLength = input.int(26, title="MACD Slow Length")
macdSignalSmoothing = input.int(9, title="MACD Signal Smoothing")
useTrailingStop = input.bool(false, title="Enable Trailing Stop Exit Strategy")  // Disabilitato di default
trailingStopPercent = input.float(15.0, title="Trailing Stop Percentage", minval=0.1, step=0.1) / 100.0
useEMACloseExit = input.bool(false, title="Close position if price closes below Selected MA")
emaCloseExitPeriod = input.int(50, title="MA Period for Exit Condition", minval=1)
useEMAExit = input.bool(true, title="Close position if Short EMA crosses downwards Medium EMA")

// === MACD Exit ===
[macdLine, signalLine, _] = request.security(syminfo.tickerid, timeframeSelection, ta.macd(macdSource, macdFastLength, macdSlowLength, macdSignalSmoothing))
macdCrossdown = ta.crossunder(macdLine, signalLine)
if (enableMacdExit and macdCrossdown)
    strategy.close("Enter Long", comment="MACD Crossdown Exit")

// === EMA Close Exit ===
selectedMA = calculateMA(maTypeInput, close, emaCloseExitPeriod)
if (useEMACloseExit and close < selectedMA)
    strategy.close("Enter Long", comment="Close Below Selected MA Exit")

// === EMA Cross Exit ===
if (useEMAExit and ta.crossunder(shortTermMA, midTermMA))
    strategy.close("Enter Long", comment="EMA Cross Exit")

// === TRAILING STOP LOGIC ===
var float maxPriceSinceEntry = na
var float previousStopLevel = na  // Memorizza il livello di stop precedente

if (strategy.position_size > 0 and useTrailingStop)
    maxPriceSinceEntry := math.max(na(maxPriceSinceEntry) ? high : maxPriceSinceEntry, high)
    float trailStopLevel = maxPriceSinceEntry * (1 - trailingStopPercent)
    if (na(previousStopLevel) or trailStopLevel > previousStopLevel)
        previousStopLevel := trailStopLevel
        strategy.exit("Trailing Stop", "Enter Long", stop=previousStopLevel)
else
    maxPriceSinceEntry := na
    previousStopLevel := na  // Reset quando non ci sono posizioni aperte

// Visualizzazione del livello di stop sul grafico
plot(previousStopLevel, color=color.red, title="Trailing Stop Level", style=plot.style_linebr)

// === OPTION FILTER ===
// Parametri di input generali e ATR
useVolatilityFilter = input.bool(false, title="Volatility Filter")
atrPeriods = input.int(14, title="ATR Period", minval=1)
atrMultiplier = input.float(1.5, title="ATR Multiplier", step=0.1)

// Calcolo ATR e soglia di volatilità
atr = ta.atr(atrPeriods)
atrThreshold = ta.sma(atr, atrPeriods) * atrMultiplier
enterLong = useVolatilityFilter ? (enterLongCondition and atr > atrThreshold) : enterLongCondition

// Visualizzazioni
plot(longTermMA, color=color.yellow, title="Long Term MA")
plot(shortTermMA, color=color.blue, title="Short Term MA")
plot(midTermMA, color=color.green, title="Medium Term MA")
plot(useVolatilityFilter ? atrThreshold : na, color=color.purple, title="ATR Threshold")
````
