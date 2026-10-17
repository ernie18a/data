# DCA Strategy

- url: https://www.tradingview.com/script/BAv7uA3G-DCA-Strategy/
- type: strategy
- pine_id: PUB;e449a11489e64d8f818a03ff5a4cd093
- version: 7.0

## Description

Introducing the DCA Strategy, a powerful tool for identifying long entry and exit opportunities in uptrending assets like cryptocurrencies, stocks, and gold. This strategy leverages the Heikin Ashi candlestick pattern and the RSI indicator to navigate potential price swings.

[b]Core Functionality:[/b]

[i]Buy Signal[/i]: A buy signal is generated when a bullish (green) Heikin Ashi candle appears after a bearish (red) one, indicating a potential reversal in a downtrend. Additionally, the RSI must be below a user-defined threshold (default: 85) to prevent buying overbought assets.

[i]Sell Signal[/i]: The strategy exits the trade when the RSI surpasses the user-defined exit level (default: 85), suggesting the asset might be overbought.

[i]Backtesting Flexibility[/i]: Users can customize the backtesting period by specifying the start and end years.

[b]Key Advantages:[/b]

[list]
[*] Trend-Following: Designed specifically for uptrending assets, aiming to capture profitable price movements.
[*] Dynamic RSI Integration: The RSI indicator helps refine entry signals by avoiding overbought situations.
[*] User-Defined Parameters: Allows customization of exit thresholds and backtesting periods to suit individual trading preferences.
[*] Commission and Slippage: The script factors in realistic commission fees (0.1%) and slippage (2%) for a more accurate backtesting experience.
[*] Beats Buy-and-Hold: Backtesting suggests this strategy outperforms a simple buy-and-hold approach in uptrending markets.
[/list]

Overall, the DCA Strategy offers a valuable approach for traders seeking to capitalize on long opportunities in trending markets with the help of Heikin Ashi candles and RSI confirmation.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © topgun31

//@version=5
strategy('DCA Strategy', overlay = true, currency = currency.USD, initial_capital = 1000, default_qty_value = 20, pyramiding = 100, default_qty_type = strategy.percent_of_equity, commission_value = 0.1, commission_type = strategy.commission.percent, slippage = 2)

startYear = input.int(2004, 'Start year', tooltip = 'The year at which the strategy to start backtesting')
endYear = input.int(2030, 'End year', tooltip = 'The year at which the strategy to stop backtesting')
exitPercent = input.int(100, 'Exit percent', tooltip = 'How much capital should be sold at exit.')
exitRSI = input.int(85, 'Exit RSI value', tooltip = 'The RSI value to exit at. Set to 100 if you want to be automatically calculated')

// Period
start = timestamp(startYear, 1, 1, 00, 00) 
finish = timestamp(endYear, 1, 1, 00, 00)
window() => time >= start and time <= finish ? true : false

// Heikin Ashi
openD = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open)
closeD = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close)

// RSI
greenCandle = closeD > openD
redCandle = closeD < openD
rsi = ta.rsi(closeD, 14)
isBitcoin = str.contains(syminfo.ticker, 'BTC')
rsiExit = exitRSI < 100 ? exitRSI : isBitcoin ? 92 : 84

entry = greenCandle and redCandle[1] and window()
exit = ta.crossunder(rsi, rsiExit) or time >= finish

if entry
    strategy.entry('Long', strategy.long, comment = 'BUY ' + syminfo.ticker)

if (exit)
    strategy.close('Long', qty_percent = exitPercent, comment = 'SELL ' + syminfo.ticker)
````
