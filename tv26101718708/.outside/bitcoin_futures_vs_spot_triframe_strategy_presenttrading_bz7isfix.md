# Bitcoin Futures vs. Spot Tri-Frame - Strategy [presentTrading]

- url: https://www.tradingview.com/script/Bz7isFiX-Bitcoin-Futures-vs-Spot-Tri-Frame-Strategy-presentTrading/
- type: strategy
- pine_id: PUB;2ef68fe482a548479d2499cea68e5da0
- version: 2.0

## Description

Prove idea with a backtest is always true for trading.

I developed and open-sourced it as an educational material for crypto traders to understand that the futures and spot spread may be effective but not be as effective as they might think. It serves as an indicator of sentiment rather than a reliable predictor of market trends over certain periods. It is better suited for specific trading environments, which require further research.

█ Introduction and How it is Different

The "Bitcoin Futures vs. Spot Tri-Frame Strategy" utilizes three different timeframes to calculate the Z-Score of the spread between BTC futures and spot prices on Binance and OKX exchanges. The strategy executes long or short trades based on composite Z-Score conditions across the three timeframes. 

The spread refers to the difference in price between BTC futures and BTC spot prices, calculated by taking a weighted average of futures prices from multiple exchanges (Binance and OKX) and subtracting a weighted average of spot prices from the same exchanges.

BTCUSD 1D L/S Performance
[image]https://www.tradingview.com/x/yEmUBhdX/[/image]


█ Strategy, How It Works: Detailed Explanation

🔶 Calculation of the Spread

The spread is the difference in price between BTC futures and BTC spot prices. The strategy calculates the spread by taking a weighted average of futures prices from multiple exchanges (Binance and OKX) and subtracting a weighted average of spot prices from the same exchanges. This spread serves as the primary metric for identifying trading opportunities.

Spread = Weighted Average Futures Price - Weighted Average Spot Price

🔶 Z-Score Calculation

The Z-Score measures how many standard deviations the current spread is from its historical mean. This is calculated for each timeframe as follows:

Spread Mean_tf = SMA(Spread_tf, longTermSMA)

Spread StdDev_tf = STDEV(Spread_tf, longTermSMA)

Z-Score_tf = (Spread_tf - Spread Mean_tf) / Spread StdDev_tf

Local performance
[image]https://www.tradingview.com/x/dE2xm1XX/[/image]

🔶 Composite Entry Conditions

The strategy triggers long and short entries based on composite Z-Score conditions across all three timeframes:

- Long Condition: All three Z-Scores must be greater than the long entry threshold.
  Long Condition = (Z-Score_tf1 > zScoreLongEntryThreshold) and (Z-Score_tf2 > zScoreLongEntryThreshold) and (Z-Score_tf3 > zScoreLongEntryThreshold)

- Short Condition: All three Z-Scores must be less than the short entry threshold.
  Short Condition = (Z-Score_tf1 < zScoreShortEntryThreshold) and (Z-Score_tf2 < zScoreShortEntryThreshold) and (Z-Score_tf3 < zScoreShortEntryThreshold)

█ Trade Direction

The strategy allows the user to specify the trading direction:

- Long: Only long trades are executed.
- Short: Only short trades are executed.
- Both: Both long and short trades are executed based on the Z-Score conditions.

█ Usage

The strategy can be applied to BTC or Crypto trading on major exchanges like Binance and OKX. By leveraging discrepancies between futures and spot prices, traders can exploit market inefficiencies. This strategy is suitable for traders who prefer a statistical approach and want to diversify their timeframes to validate signals.

█ Default Settings

- Input TF 1 (60 minutes): Sets the first timeframe for Z-Score calculation.
- Input TF 2 (120 minutes): Sets the second timeframe for Z-Score calculation.
- Input TF 3 (180 minutes): Sets the third timeframe for Z-Score calculation.
- Long Entry Z-Score Threshold (3): Defines the threshold above which a long trade is triggered.
- Short Entry Z-Score Threshold (-3): Defines the threshold below which a short trade is triggered.
- Long-Term SMA Period (100): The period used to calculate the simple moving average for the spread.
- Use Hold Days (true): Enables holding trades for a specified number of days.
- Hold Days (5): Number of days to hold the trade before exiting.
- TPSL Condition (None): Defines the conditions for taking profit and stop loss.
- Take Profit (%) (30.0): The percentage at which the trade will take profit.
- Stop Loss (%) (20.0): The percentage at which the trade will stop loss.

By fine-tuning these settings, traders can optimize the strategy to suit their risk tolerance and trading style, enhancing overall performance.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PresentTrading

// "Bitcoin Futures vs. Spot Tri-Frame - Strategy," utilizes three different timeframes (60, 120, and 180 minutes) to calculate 
// the Z-Score of the spread between BTC futures and spot prices on Binance and OKX exchanges. The strategy executes long or short trades based on composite Z-Score conditions across the three timeframes, 
// the "spread" refers to the difference in price between BTC futures and BTC spot prices. Specifically, 
// it calculates the spread by taking a weighted average of futures prices from multiple exchanges (Binance and OKX) and subtracting a weighted average of spot prices from the same exchanges. 

//@version=5
strategy("Bitcoin Futures vs. Spot Tri-Frame - Strategy [presentTrading]", shorttitle="Bitcoin Futures vs. Spot Tri-Frame - Strategy [presentTrading]", overlay=false,  precision=3, commission_value= 0.1, commission_type=strategy.commission.percent, slippage= 1, currency=currency.USD, default_qty_type = strategy.percent_of_equity, 
 default_qty_value = 10, initial_capital= 10000)
// Parameters
tradingDirection = input.string("Both", title="Trading Direction", options=["Long", "Short", "Both"])
string tfInput1 = input.timeframe(defval = "60", title = "Input TF 1")
string tfInput2 = input.timeframe(defval = "120", title = "Input TF 2")
string tfInput3 = input.timeframe(defval = "180", title = "Input TF 3") // Adding third timeframe
zScoreLongEntryThreshold = input.float(3, title="Long Entry Z-Score Threshold")
zScoreShortEntryThreshold = input.float(-3, title="Short Entry Z-Score Threshold")
longTermSMA = input(100, title="Long-Term SMA Period")

// Settings for Hold Days and TPSL Conditions
useHoldDays = input.bool(true, title="Use Hold Days")
holdDays = input.int(5, title="Hold Days", minval=1, maxval=60, step=1)
TPSLCondition = input.string("None", "TPSL Condition", options=["TP", "SL", "Both", "None"])
takeProfitPerc = input(30.0, title="Take Profit (%)")
stopLossPerc = input(20.0, title="Stop Loss (%)")

// Example symbols (these might not correspond to actual data available on TradingView)
binanceFu1Symbol = "BINANCE:BTCUSD.P" // BTCUSDT on Binance
binanceFuS2ymbol = "BINANCE:BTCUSDT.P" // BTCUSDT on Binance
okxFuSymbol = "OKX:BTCUSDT.P"
binanceSpot1Symbol = "BINANCE:BTCUSD" // BTCUSDT on Binance
binanceSpot2Symbol = "BINANCE:BTCUSDT" // BTCUSDT on Binance
okxSpotSymbol = "OKX:BTCUSDT"

// BTC Futures/Spot Ratio for TF 1
binanceFu1Price_tf1 = request.security(binanceFu1Symbol, tfInput1, close)
binanceFu2Price_tf1 = request.security(binanceFuS2ymbol, tfInput1, close)
okxFuPrice_tf1 = request.security(okxFuSymbol, tfInput1, close)
binanceSpot1Price_tf1 = request.security(binanceSpot1Symbol, tfInput1, close)
binanceSpot2Price_tf1 = request.security(binanceSpot2Symbol, tfInput1, close)
okxSpotPrice_tf1 = request.security(okxSpotSymbol, tfInput1, close)

btcFuturesPrice_tf1 = (binanceFu1Price_tf1 * 0.4 + binanceFu2Price_tf1 * 0.4 + okxFuPrice_tf1 * 0.2)
btcSpotPrice_tf1 = (binanceSpot1Price_tf1 * 0.4 + binanceSpot2Price_tf1 * 0.4 + okxSpotPrice_tf1 * 0.2)
FutureSpotSpread_tf1 = btcFuturesPrice_tf1 - btcSpotPrice_tf1
FutureSpotSpreadSpread_mean_tf1 = ta.sma(FutureSpotSpread_tf1, longTermSMA)
FutureSpotSpread_stdDev_tf1 = ta.stdev(FutureSpotSpread_tf1, longTermSMA)
FutureSpotSpread_zScore_tf1 = (FutureSpotSpread_tf1 - FutureSpotSpreadSpread_mean_tf1) / FutureSpotSpread_stdDev_tf1

// BTC Futures/Spot Ratio for TF 2
binanceFu1Price_tf2 = request.security(binanceFu1Symbol, tfInput2, close)
binanceFu2Price_tf2 = request.security(binanceFuS2ymbol, tfInput2, close)
okxFuPrice_tf2 = request.security(okxFuSymbol, tfInput2, close)
binanceSpot1Price_tf2 = request.security(binanceSpot1Symbol, tfInput2, close)
binanceSpot2Price_tf2 = request.security(binanceSpot2Symbol, tfInput2, close)
okxSpotPrice_tf2 = request.security(okxSpotSymbol, tfInput2, close)

btcFuturesPrice_tf2 = (binanceFu1Price_tf2 * 0.4 + binanceFu2Price_tf2 * 0.4 + okxFuPrice_tf2 * 0.2)
btcSpotPrice_tf2 = (binanceSpot1Price_tf2 * 0.4 + binanceSpot2Price_tf2 * 0.4 + okxSpotPrice_tf2 * 0.2)
FutureSpotSpread_tf2 = btcFuturesPrice_tf2 - btcSpotPrice_tf2
FutureSpotSpreadSpread_mean_tf2 = ta.sma(FutureSpotSpread_tf2, longTermSMA)
FutureSpotSpread_stdDev_tf2 = ta.stdev(FutureSpotSpread_tf2, longTermSMA)
FutureSpotSpread_zScore_tf2 = (FutureSpotSpread_tf2 - FutureSpotSpreadSpread_mean_tf2) / FutureSpotSpread_stdDev_tf2

// BTC Futures/Spot Ratio for TF 3
binanceFu1Price_tf3 = request.security(binanceFu1Symbol, tfInput3, close)
binanceFu2Price_tf3 = request.security(binanceFuS2ymbol, tfInput3, close)
okxFuPrice_tf3 = request.security(okxFuSymbol, tfInput3, close)
binanceSpot1Price_tf3 = request.security(binanceSpot1Symbol, tfInput3, close)
binanceSpot2Price_tf3 = request.security(binanceSpot2Symbol, tfInput3, close)
okxSpotPrice_tf3 = request.security(okxSpotSymbol, tfInput3, close)

btcFuturesPrice_tf3 = (binanceFu1Price_tf3 * 0.4 + binanceFu2Price_tf3 * 0.4 + okxFuPrice_tf3 * 0.2)
btcSpotPrice_tf3 = (binanceSpot1Price_tf3 * 0.4 + binanceSpot2Price_tf3 * 0.4 + okxSpotPrice_tf3 * 0.2)
FutureSpotSpread_tf3 = btcFuturesPrice_tf3 - btcSpotPrice_tf3
FutureSpotSpreadSpread_mean_tf3 = ta.sma(FutureSpotSpread_tf3, longTermSMA)
FutureSpotSpread_stdDev_tf3 = ta.stdev(FutureSpotSpread_tf3, longTermSMA)
FutureSpotSpread_zScore_tf3 = (FutureSpotSpread_tf3 - FutureSpotSpreadSpread_mean_tf3) / FutureSpotSpread_stdDev_tf3

// Composite Entry Conditions
longCondition = (FutureSpotSpread_zScore_tf1 > zScoreLongEntryThreshold) and (FutureSpotSpread_zScore_tf2 > zScoreLongEntryThreshold) and (FutureSpotSpread_zScore_tf3 > zScoreLongEntryThreshold)
shortCondition = (FutureSpotSpread_zScore_tf1 < zScoreShortEntryThreshold) and (FutureSpotSpread_zScore_tf2 < zScoreShortEntryThreshold) and (FutureSpotSpread_zScore_tf3 < zScoreShortEntryThreshold)

// Variables to track entry times
var float longEntryTime = na
var float shortEntryTime = na

// Executing trades based on the entry logic
if (longCondition and (tradingDirection == "Long" or tradingDirection == "Both")) 
    if (strategy.position_size < 0)
        strategy.close("Short Entry")
    strategy.entry("Long Entry", strategy.long)
    longEntryTime := time

if (shortCondition and (tradingDirection == "Short" or tradingDirection == "Both")) 
    if (strategy.position_size > 0)
        strategy.close("Long Entry")
    strategy.entry("Short Entry", strategy.short)
    shortEntryTime := time

if (strategy.position_size > 0) 
    float takeProfitPrice = strategy.position_avg_price * (1 + takeProfitPerc / 100)
    float stopLossPrice = strategy.position_avg_price * (1 - stopLossPerc / 100)

    if (useHoldDays and (time >= (longEntryTime + holdDays * 86400000)))
        strategy.close("Long Entry")
    if (TPSLCondition == "TP" or TPSLCondition == "Both")
        strategy.exit("Take Profit", "Long Entry", limit=takeProfitPrice)
    if (TPSLCondition == "SL" or TPSLCondition == "Both")
        strategy.exit("Stop Loss", "Long Entry", stop=stopLossPrice)

if (strategy.position_size < 0) 
    float takeProfitPrice = strategy.position_avg_price * (1 - takeProfitPerc / 100)
    float stopLossPrice = strategy.position_avg_price * (1 + stopLossPerc / 100)

    if (useHoldDays and (time >= (shortEntryTime + holdDays * 86400000)))
        strategy.close("Short Entry")
    if (TPSLCondition == "TP" or TPSLCondition == "Both")
        strategy.exit("Take Profit", "Short Entry", limit=takeProfitPrice)
    if (TPSLCondition == "SL" or TPSLCondition == "Both")
        strategy.exit("Stop Loss", "Short Entry", stop=stopLossPrice)

// Plotting for visualization
plot(FutureSpotSpread_zScore_tf1, title="Futures-Spot Spread Z-Score TF1", color=color.blue)
plot(FutureSpotSpread_zScore_tf2, title="Futures-Spot Spread Z-Score TF2", color=color.orange)
plot(FutureSpotSpread_zScore_tf3, title="Futures-Spot Spread Z-Score TF3", color=color.green)
hline(zScoreLongEntryThreshold, "Long Entry Threshold", color=color.green)
hline(zScoreShortEntryThreshold, "Short Entry Threshold", color=color.red)
````
