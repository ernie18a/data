<!-- tradingview-pine-id: PUB;39ece97dfb6545c7bf410dc555babaff -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Universal Daily Leverage Simulator (Candles)

Source: https://www.tradingview.com/script/Mcoomdyc-Universal-Daily-Leverage-Simulator-Candles/

## Description

Have you ever wondered what any Daily Leveraged ETF on your favorite stock, index, or crypto would look like over decades?

This open-source indicator transforms any standard asset chart into a simulated daily leveraged product. By calculating the exact compounding math and daily rebalancing mechanics, it accurately reveals the powerful growth—and the destructive beta slippage (volatility decay)—associated with leveraged holding over long timeframes.

🌟 Key Features:

Universal Compatibility: Works seamlessly on ANY chart (S&P 500, NASDAQ, individual stocks like NVDA or TSLA, and Cryptocurrencies).

True Candlestick Rendering: Unlike basic line overlays, this script computes synthetic Open, High, Low, and Close (OHLC) values to print actual candlesticks.

Fully Customizable Leverage: Want to test a 1.5x, 2x, 3x, or even a 4x leverage? Simply open the Pine Editor and change the leverageFactor variable at the very top of the script to your desired number.

🛠 How to use it:

Open the chart of your choice on a Daily (1D) timeframe.

Add this script to the chart.

Zoom out to observe how severe market crashes (like 2000, 2008, or 2022) mathematically impact leveraged capital through compounding decay.

Disclaimer: This script is an educational and analytical tool designed to visualize mathematical compounding. It does not constitute financial or investment advice. Leveraged products carry extreme risk of capital loss, especially in volatile or sideways markets. Past performance does not guarantee future results.

---

## Source Code

````pine
// © Cypher_Brothers

//@version=6
indicator("Universal Daily Leverage Simulator (Candles)", overlay=false)

// ==========================================
// ADJUST YOUR LEVERAGE FACTOR HERE (e.g., 2.0 = 2x, 3.0 = 3x, etc.)
float leverageFactor = 2
// ==========================================

// 1. Calculate daily percentage returns based on the underlying asset's previous close
prevClose = nz(close[1], close)

returnOpen  = (open - prevClose) / prevClose
returnHigh  = (high - prevClose) / prevClose
returnLow   = (low - prevClose) / prevClose
returnClose = (close - prevClose) / prevClose

// 2. Compute compounded equity for the close price
var float compoundedEquity = 100
if bar_index > 0
    compoundedEquity := nz(compoundedEquity[1], 100) * (1 + leverageFactor * returnClose)

previousEquityClose = nz(compoundedEquity[1], 100)

// 3. Apply leverage to open, high, and low levels
syntheticOpen  = previousEquityClose * (1 + leverageFactor * returnOpen)
syntheticClose = compoundedEquity

rawHigh        = previousEquityClose * (1 + leverageFactor * returnHigh)
rawLow         = previousEquityClose * (1 + leverageFactor * returnLow)

// Safety checks to ensure High is the highest and Low is the lowest point
syntheticHigh  = math.max(syntheticOpen, syntheticClose, rawHigh, rawLow)
syntheticLow   = math.min(syntheticOpen, syntheticClose, rawHigh, rawLow)

// 4. Plot the simulated leveraged candlesticks (Green for up, Red for down)
candleColor = syntheticClose >= syntheticOpen ? color.green : color.red
plotcandle(syntheticOpen, syntheticHigh, syntheticLow, syntheticClose, title="Simulated Leveraged Candles", color=candleColor, wickcolor=candleColor, bordercolor=candleColor)
````
