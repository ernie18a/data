# Sector RS Entry Tool

- url: https://www.tradingview.com/script/OZfra1vw-Sector-RS-Entry-Tool/
- type: indicator
- pine_id: PUB;eb92cac4efa04b48876621988c03a0dd
- version: 1.0

## Description

Shows the Outperformance and Underperformance of the selected script to the selected sector or stock.

## Source Code

````pine
//@version=5
indicator("Sector RS Entry Tool", overlay=false)

// 1. Inputs
sectorTicker = input.symbol("NSE:CNXAUTO", "Compare with Sector Index")
length = input.int(20, "RS Lookback Period")

// 2. Fetch Sector Data safely
sectorPrice = request.security(sectorTicker, timeframe.period, close)

// 3. Calculate Relative Strength (RS)
// We use a ratio of Stock Close to Sector Close
rsRatio = close / sectorPrice
rsSMA = ta.sma(rsRatio, length)

// 4. Plotting
plot(rsRatio, title="Stock/Sector Ratio", color=color.blue, linewidth=2)
plot(rsSMA, title="RS Average", color=color.gray, linewidth=1)

// 5. Entry Signal Visual (Green background when outperforming)
bgcolor(rsRatio > rsSMA ? color.new(color.green, 90) : na)
````
