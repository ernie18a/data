# Crypto Realised (on-chain) Price

- url: https://www.tradingview.com/script/hrMVIBvW-Crypto-Realised-on-chain-Price/
- type: indicator
- pine_id: PUB;c79a095f60df4856bc359d62b194c9fe
- version: 1.0

## Description

Realized Price represents the average price at which coins have changed hands on their respective network. It is fundamentally different from a standard moving average on exchange price because a moving average simply calculates a mathematical average of daily closing prices over an arbitrary time window (like 50 or 200 days), completely ignoring whether any significant number of coins actually traded at those levels.

In contrast, Realized Price tracks the actual on-chain cost basis of the entire network. It looks at the history of the blockchain and values every single coin at the exact price it was last moved between wallets. This turns it into a true, volume-weighted floor that shows what investors actually paid for their assets over time, rather than just a smoothed line of recent exchange noise.

It only works for cryptos for which Tradingview has data.

Free to use and modify with proper attribution. If you find this indicator helpful, sharing it on X or social media to support the account is highly appreciated!

## Source Code

````pine
// © macrotides (X: @macrotides)
//@version=5
indicator("Crypto Realised (on-chain) Price", overlay=true)

// ==========================================
// 1. SYMBOL PARSING & CLEANING
// ==========================================

// Get current chart symbol and exchange prefix
chart_symbol    = syminfo.ticker
exchange_prefix = syminfo.prefix

// Strip out common quote assets to isolate the base crypto asset (e.g., "BTC" from "BTCUSDT")
base_symbol = chart_symbol
base_symbol := str.replace_all(base_symbol, "USDT", "")
base_symbol := str.replace_all(base_symbol, "USD", "")
base_symbol := str.replace_all(base_symbol, "BUSD", "")
base_symbol := str.upper(base_symbol)

// ==========================================
// 2. CONSTRUCT DATA FEED TICKERS
// ==========================================

// Map out the required on-chain metric paths for CoinMetrics and Glassnode
realizedcap_symbol = "COINMETRICS:" + base_symbol + "_MARKETCAPREAL"
supply_symbol      = "GLASSNODE:"    + base_symbol + "_SUPPLY"

// ==========================================
// 3. FETCH ON-CHAIN DATA
// ==========================================

// Fetch daily close data for Realized Cap and Circulating Supply
realizedcap = request.security(realizedcap_symbol, "D", close)
supply      = request.security(supply_symbol, "D", close)

// ==========================================
// 4. CALCULATIONS & PLOTTING
// ==========================================

// Realized Price = Realized Capitalization / Total Circulating Supply
// Fallback to 'na' if either on-chain data point is missing to prevent script errors
realizedprice = na(realizedcap) or na(supply) ? na : realizedcap / supply

// Plot the Realized Price line directly on the main chart pane
plot(realizedprice, title="Realised Price", color=color.new(#ff9500, 46), display=display.pane, linewidth=4)
````
