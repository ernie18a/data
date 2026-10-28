# RSI + MACD Multi-Timeframe Strategy

- url: https://www.tradingview.com/script/Epqb0L8C-RSI-MACD-Multi-Timeframe-Strategy/
- type: strategy
- pine_id: PUB;6c34907eba564a7e9ec5742eed59ebb3
- version: 1.0

## Description

This strategy combines the Relative Strength Index (RSI) from the daily timeframe with the Moving Average Convergence Divergence (MACD) from the 4-hour timeframe to generate precise long entry and exit signals.

The system uses a multi-timeframe approach to align longer-term trend conditions with shorter-term momentum shifts — allowing traders to catch dips with confirmation and exit before reversals.

[b]🧠 Strategy Logic[/b]
✅ Long Entry Condition:

- RSI on the daily (1D) timeframe is oversold (below your defined threshold)
- MACD on the 4H timeframe crosses above the signal line

→ A long trade is opened when these two align

✅ Long Exit Condition:

- RSI on the daily timeframe is overbought
- MACD on the 4H timeframe crosses below the signal line

→ The long trade is closed when these two conditions are met

💡 This strategy currently supports long entries only. Short logic can be added if needed.

[b]📊 Indicator Components[/b]
🔹 RSI (Relative Strength Index):

- A momentum oscillator that measures the speed and magnitude of price changes.
- Helps identify overbought (potential sell) and oversold (potential buy) conditions.
- Applied on the 1D timeframe (by default) to reflect broader market trend or exhaustion levels.

🔹 MACD (Moving Average Convergence Divergence):

- A trend-following momentum indicator based on moving averages.
- The MACD Line (fast EMA - slow EMA) crossing above the Signal Line indicates bullish momentum.
- Used here on the 4-hour timeframe (by default) for shorter-term momentum confirmation.

🔹 Multi-Timeframe (MTF) Logic:

- Uses request.security() to pull higher timeframe data (1D for RSI, 4H for MACD).
- Ensures no repainting, as it only uses closed candles from the higher timeframe.
- Aligns longer-term signals with shorter-term entries, reducing false signals.

[b]📈 Plotting Options[/b]

The script includes a plot selector input allowing you to toggle between:

- RSI Plot (with overbought/oversold lines)
- MACD Plot (MACD line and signal line)
- This helps visualize signal conditions clearly on your chart.

🛠 Customization

- RSI & MACD settings are fully configurable
- RSI and MACD timeframes can be adjusted independently

⚠️ Disclaimer

[i]This strategy is provided for educational and informational purposes only.
It is not financial advice or a recommendation to buy or sell any asset.
Past performance does not guarantee future results. Always test strategies in a simulated environment before live use, and consult with a licensed financial advisor for investment decisions.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © RWCS_LTD

//@version=6
strategy("RSI + MACD Multi-Timeframe Strategy", overlay=false, default_qty_type=strategy.percent_of_equity, default_qty_value=100)

// === INPUTS ===
group1 = "Plotting Options"
group2 = "Relative Strength Index"
group3 = "Moving Average Convergence/Divergence"

plotChoice = input.string("RSI", title="Plot Selector", options=["RSI", "MACD"], group = group1)

RSI_TIME = input.timeframe("1D", "RSI Timeframe", group = group2)
rsiLength = input.int(14, "RSI Length", group = group2)
rsiOB = input.int(70, "RSI Overbought Level", group = group2)
rsiOS = input.int(30, "RSI Oversold Level", group = group2)

MACD_TIME = input.timeframe("240", "MACD Timeframe", group = group3)
macdFast = input.int(12, "MACD Fast Length", group = group3)
macdSlow = input.int(26, "MACD Slow Length", group = group3)
macdSignal = input.int(9, "MACD Signal Smoothing", group = group3)


// === RSI on 1D ===
rsi1D = request.security(syminfo.tickerid, RSI_TIME, ta.rsi(close, rsiLength))
isOB = rsi1D > rsiOB
isOS = rsi1D < rsiOS

// === MACD on 4H ===
[macdLine, signalLine, _] = request.security(syminfo.tickerid, MACD_TIME, ta.macd(close, macdFast, macdSlow, macdSignal))
macdCrossOver = ta.crossover(macdLine, signalLine)
macdCrossUnder = ta.crossunder(macdLine, signalLine)

// === Long Entry ===
longCondition = isOS and macdCrossOver
if (longCondition)
    strategy.entry("Long", strategy.long)

// === Long Exit ===
longExit = isOB and macdCrossUnder
if (longExit)
    strategy.close("Long")

// === Plotting ===
showRSI = plotChoice == "RSI"
showMACD = plotChoice == "MACD"

// === Conditional Plotting ===
plot(showRSI ? rsi1D : na, title="RSI (1D)", color=color.blue)
hline(showRSI ? rsiOB : na, "Overbought", color=color.red)
hline(showRSI ? rsiOS : na, "Oversold", color=color.green)

plot(showMACD ? macdLine : na, title="MACD Line (4H)", color=color.orange)
plot(showMACD ? signalLine : na, title="Signal Line (4H)", color=color.purple)
````
