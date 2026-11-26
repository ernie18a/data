# Connors VIX Reversal III invented by Dave Landry

- url: https://www.tradingview.com/script/M5sJBicO/
- type: strategy
- pine_id: PUB;6535f8a6761349c5b45cd6921314895d
- version: 1.0

## Description

This strategy is based on trading signals derived from the behavior of the Volatility Index (VIX) relative to its 10-day moving average. The rules are split into buying and selling conditions:
Buy Conditions:

    The VIX low must be above its 10-day moving average.
    The VIX must close at least 10% above its 10-day moving average.
    If both conditions are met, a buy signal is generated at the market's close.

Sell Conditions:

    The VIX high must be below its 10-day moving average.
    The VIX must close at least 10% below its 10-day moving average.
    If both conditions are met, a sell signal is generated at the market's close.

Exit Conditions:

For long positions, the strategy exits when the VIX trades intraday below its previous day’s 10-day moving average.
    
For short positions, the strategy exits when the VIX trades intraday above its previous day’s 10-day moving average.

This strategy is primarily a mean-reversion strategy, where the market is expected to revert to a more normal state after the VIX exhibits extreme behavior (i.e., large deviations from its moving average).
About Dave Landry

Dave Landry is a well-known figure in the world of trading, particularly in technical analysis. He is an author, trader, and educator, best known for his work on swing trading strategies. Landry focuses on trend-following and momentum-based techniques, teaching traders how to capitalize on shorter-term price swings in the market. He has written books like "Dave Landry on Swing Trading" and "The Layman's Guide to Trading Stocks," which emphasize practical, actionable trading strategies.
About Connors Research

Connors Research is a financial research firm known for its quantitative research in financial markets. Founded by Larry Connors, the firm specializes in developing high-probability trading systems based on historical market behavior. Connors’ work is widely respected for its data-driven approach, including systems like the RSI(2) strategy, which focuses on short-term mean reversion. The firm also provides trading education and tools for institutional and retail traders alike, emphasizing strategies that can be backtested and quantified.
Risks of the Strategy

While this strategy may appear to offer promising opportunities to exploit extreme VIX movements, it carries several risks:

Market Volatility: The VIX itself is a measure of market volatility, meaning the strategy can be exposed to sudden and unpredictable market swings. This can result in whipsaws, where positions are opened and closed in rapid succession due to sharp reversals in the VIX.

 Overfitting: Strategies based on specific conditions like the VIX closing 10% above or below its moving average can be subject to overfitting, meaning they work well in historical tests but may underperform in live markets. This is a common issue in quantitative trading systems that are not adaptable to changing market conditions .

Mean-Reversion Assumption: The core assumption behind this strategy is that markets will revert to their mean after extreme movements. However, during periods of sustained trends (e.g., market crashes or rallies), this assumption may break down, leading to prolonged drawdowns.

Liquidity and Slippage: Depending on the asset being traded (e.g., S&P 500 futures, ETFs), liquidity issues or slippage could occur when executing trades at market close, particularly in volatile conditions. This could increase costs or worsen trade execution.

Scientific Explanation of the Strategy

The VIX is often referred to as the "fear gauge" because it measures the market's expectations of volatility based on options prices. Research has shown that the VIX tends to spike during periods of market stress and revert to lower levels when conditions stabilize . Mean reversion strategies like this one assume that extreme VIX levels are unsustainable in the long run, which aligns with findings from academic literature on volatility and market behavior.

Studies have found that the VIX is inversely correlated with stock market returns, meaning that higher VIX levels often correspond to lower stock prices and vice versa . By using the VIX’s relationship with its 10-day moving average, this strategy aims to capture reversals in market sentiment. The 10% threshold is designed to identify moments when the VIX is significantly deviating from its norm, signaling a potential reversal.

However, academic research also highlights the limitations of relying on the VIX alone for trading signals. The VIX does not predict market direction, only volatility, meaning that it cannot indicate the magnitude of price movements . Furthermore, extreme VIX levels can persist longer than expected, particularly during financial crises.

In conclusion, while the strategy is grounded in well-established financial principles (e.g., mean reversion and the relationship between volatility and market performance), it carries inherent risks and should be used with caution. Backtesting and careful risk management are essential before applying this strategy in live markets.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © EdgeTools

//@version=5
strategy("Connors VIX Reversal III invented by Dave Landry", overlay=true)

// Inputs
vixSymbol = input("VIX", "VIX Symbol")
lengthMA = input(10, title="Length of Moving Average")
percentThreshold = input(10, title="Percentage Threshold")
buyColor = input(color.rgb(0, 255, 0,90), title="Buy Signal Color")
sellColor = input(color.rgb(255, 0, 0,90), title="Sell Signal Color")
exitColor = input(color.rgb(0, 0, 255,90), title="Exit Signal Color")

// Fetch VIX data
vixClose = request.security(vixSymbol, "D", close)
vixHigh = request.security(vixSymbol, "D", high)
vixLow = request.security(vixSymbol, "D", low)

// Calculate 10-day Moving Average of VIX
vixMA = ta.sma(vixClose, lengthMA)

// Calculate yesterday's 10-day Moving Average
vixMA_yesterday = ta.sma(vixClose[1], lengthMA)

// Buy Rules
buyCondition1 = vixLow > vixMA
buyCondition2 = vixClose > vixMA * (1 + percentThreshold / 100)
buySignal = buyCondition1 and buyCondition2

// Sell Rules
sellCondition1 = vixHigh < vixMA
sellCondition2 = vixClose < vixMA * (1 - percentThreshold / 100)
sellSignal = sellCondition1 and sellCondition2

// Exit Rules
buyExit = vixLow < vixMA_yesterday
sellExit = vixHigh > vixMA_yesterday

// Plot Buy/Sell Signals
bgcolor(buySignal ? buyColor : na)
bgcolor(sellSignal ? sellColor : na)

// Exit Signals
bgcolor(buyExit ? exitColor : na)
bgcolor(sellExit ? exitColor : na)

// Strategy
if (buySignal)
    strategy.entry("Buy", strategy.long)
if (sellSignal)
    strategy.entry("Sell", strategy.short)

if (buyExit)
    strategy.close("Buy")
if (sellExit)
    strategy.close("Sell")
````
