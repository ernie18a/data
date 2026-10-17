# Stochastic Bot with SL/TP

- url: https://www.tradingview.com/script/EVvWJ4Us-Stochastic-Bot-with-SL-TP/
- type: strategy
- pine_id: PUB;be5d128d227843779683650a52feb8b9
- version: 1.0

## Description

[b]Stochastic Momentum Bot with Risk Management
[/b]
[b]Description[/b]

This trading bot is an automated strategy designed for TradingView. It aims to capitalize on short-term price reversals by identifying when an asset is temporarily "oversold" (priced too low) or "overbought" (priced too high) using the Stochastic Oscillator.

Unlike basic indicator scripts that simply highlight buy and sell signals on a chart, this is a full Strategy Script. This means it virtually executes trades using historical data, applying strict Stop-Loss (SL) and Take-Profit (TP) percentages to protect your capital. 
It is highly customizable, allowing you to fine-tune the parameters to suit different assets and timeframes.

[b]How the Logic Works
[/b]
Entry (Buy): The bot enters a Long position when the %K line crosses above the %D line, but only if both lines are below the 20 threshold (indicating the asset is heavily oversold and momentum is shifting upward).

Exit 1 (Take Profit): The bot will automatically close the trade if the price rises by your set Take-Profit percentage.

Exit 2 (Stop Loss): The bot will automatically cut its losses and close the trade if the price drops by your set Stop-Loss percentage.

Exit 3 (Momentum Reversal): If neither the SL nor TP is hit, the bot will close the trade early if the %K line crosses below the %D line while above the 60 threshold (indicating the asset is overbought and momentum is dying).

[b]Step-by-Step Guide to Using the Bot
[/b]
Part 1: Loading the Script into TradingView
Open TradingView and load the chart you want to trade (e.g., TAO/USDT on the 15-minute timeframe).
At the very bottom of the screen, click on the Pine Editor tab.Delete any existing code in the editor window so it is completely blank.
Copy the Pine Script code provided previously and paste it into the editor.
Click the Save button (floppy disk icon) at the top right of the Pine Editor and give your script a name (e.g., "Stochastic Bot").
Click the "Add to Chart" button.

Part 2: Customizing the Strategy SettingsOnce the script is on your chart, a new menu will appear at the top left of your chart area with the name of your script.Hover over the script's name and click the Gear Icon (Settings).Click on the Inputs tab. 

Here is what each setting controls:
Setting Name
Default
Description
%K Length14

The number of previous candles used to calculate the main momentum line.%K Smoothing3Smooths out the %K line to reduce false signals.%D Smoothing3The moving average of the %K line, used as the trigger line for crossovers.

Stop Loss (%)2.5
The maximum percentage of price drop you are willing to risk before exiting a trade.

Take Profit (%)6.0
The percentage of price increase required to automatically lock in profits and exit.

Part 3: Reading the Strategy Tester
Once the bot is on your chart, the Strategy Tester tab at the bottom of the screen will automatically populate with backtesting data based on your current settings and timeframe.

Net Profit: The total amount of money the bot made (or lost) over the given time period.
Total Closed Trades: How many times the bot bought and sold.
Percent Profitable (Win Rate): The percentage of trades that ended in a profit.
Max Drawdown: The largest percentage drop in your account balance from its peak. This is a crucial metric for understanding risk; a high drawdown means the bot experienced severe losing streaks.

List of Trades: A tab inside the Strategy Tester that shows you every single historical entry, exit, and the exact price it triggered at.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JimmyPerez

//@version=5
strategy("Stochastic Bot with SL/TP", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// --- Inputs ---
kLength = input.int(14, title="%K Length")
smoothK = input.int(3, title="%K Smoothing")
dLength = input.int(3, title="%D Smoothing")
sl_pct = input.float(2.5, title="Stop Loss (%)", step=0.1) / 100
tp_pct = input.float(6.0, title="Take Profit (%)", step=0.1) / 100

// --- Calculate Stochastic ---
// TradingView's standard stochastic calculation
k = ta.sma(ta.stoch(close, high, low, kLength), smoothK)
d = ta.sma(k, dLength)

// --- Strategy Logic ---
// Buy Signal: K crosses ABOVE D while both are in Oversold territory (< 30)
buy_signal = ta.crossover(k, d) and k < 20

// Sell Signal: K crosses BELOW D in Overbought territory (> 70)
sell_signal = ta.crossunder(k, d) and k > 60

// --- Execution ---
// Enter a long position when buy signal triggers
if (buy_signal)
    strategy.entry("Long", strategy.long)

// Manage the exit with Stop Loss, Take Profit, or the Sell Signal
if (strategy.position_size > 0)
    // Get the average entry price of the current position
    entry_price = strategy.opentrades.entry_price(0)
    
    // Calculate precise price levels for SL and TP
    stop_level = entry_price * (1 - sl_pct)
    profit_level = entry_price * (1 + tp_pct)
    
    // Tell TradingView to automatically exit if price hits SL or TP
    strategy.exit("SL/TP", from_entry="Long", stop=stop_level, limit=profit_level)
    
    // Also exit if the standard Stochastic sell signal triggers before SL/TP are hit
    if (sell_signal)
        strategy.close("Long", comment="Sell Signal")
````
