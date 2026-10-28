# Auto Crypto Market Cap

- url: https://www.tradingview.com/script/PhfsXZ8T-Auto-Crypto-Market-Cap/
- type: indicator
- pine_id: PUB;1e51d99384ab440995451ef0d202a932
- version: 1.0

## Description

Auto Crypto Market Cap is a simple utility indicator that automatically displays the current market capitalization of the cryptocurrency shown on your chart.

The script detects the base asset from the current symbol, for example:
AAVEUSDT → AAVE
SOLUSDT → SOL
ETHUSDT → ETH

It then requests the matching TradingView CRYPTOCAP symbol, such as CRYPTOCAP:AAVE or CRYPTOCAP:SOL, and displays the result in a clean table on the chart.

Features:
• Automatically detects the crypto ticker from the current chart
• Displays market cap in a readable format: K, M, B, or T
• Optional manual ticker override for special symbols
• Useful for quickly checking whether a coin is small-cap, mid-cap, or large-cap
• Works directly on price charts without needing to open a separate CRYPTOCAP chart

Examples:
AAVEUSDT → shows AAVE market cap
BTCUSDT → shows BTC market cap
ETHUSDT → shows ETH market cap
LINKUSDT → shows LINK market cap

For symbols like 1000PEPEUSDT, WETHUSDT, or WBTCUSDT, you can use the manual override input to set the correct ticker, for example PEPE, ETH, or BTC.

Important:
This indicator depends on TradingView’s CRYPTOCAP data. If TradingView does not provide a CRYPTOCAP symbol for a specific asset, the market cap may show as unavailable.

## Source Code

````pine
//@version=6
indicator("Auto Crypto Market Cap Table", overlay=true, dynamic_requests=true)

overrideTicker = input.string("", "Override ticker, optional")
showDominance  = input.bool(true, "Show dominance if available")

baseTicker = overrideTicker != "" ? str.upper(overrideTicker) : syminfo.basecurrency

mcapSymbol = "CRYPTOCAP:" + baseTicker
domSymbol  = "CRYPTOCAP:" + baseTicker + ".D"

mcap = request.security(mcapSymbol, timeframe.period, close, ignore_invalid_symbol=true)
dom  = request.security(domSymbol, timeframe.period, close, ignore_invalid_symbol=true)

formatNumber(x) =>
    string result = ""
    if na(x)
        result := "n/a"
    else if x >= 1e12
        result := "$" + str.tostring(x / 1e12, "#.##") + "T"
    else if x >= 1e9
        result := "$" + str.tostring(x / 1e9, "#.##") + "B"
    else if x >= 1e6
        result := "$" + str.tostring(x / 1e6, "#.##") + "M"
    else if x >= 1e3
        result := "$" + str.tostring(x / 1e3, "#.##") + "K"
    else
        result := "$" + str.tostring(x, "#.##")
    result

formatPercent(x) =>
    na(x) ? "n/a" : str.tostring(x, "#.####") + "%"

var table t = table.new(position.top_right, 1, 3)

if barstate.islast
    table.cell(t, 0, 0, baseTicker)
    table.cell(t, 0, 1, "Market cap: " + formatNumber(mcap))
    table.cell(t, 0, 2, showDominance ? "Dominance: " + formatPercent(dom) : "")
````
