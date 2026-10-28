# Crypto Confirmation Engine - Auto Detect Coin

- url: https://www.tradingview.com/script/YZUF32q6-Crypto-Confirmation-Engine-Auto-Detect-Coin/
- type: indicator
- pine_id: PUB;e702f42acd7e48b6867121c78a3bd064
- version: 1.0

## Description

Full Description:

This indicator provides a multi-factor market confirmation system designed to evaluate whether a trading setup is aligned with the broader crypto market.

Instead of generating signals, it focuses on context, strength, and confirmation.

🔍 What it analyzes:
Relative strength of the coin vs BTC and ETH
Market direction using TOTAL, TOTAL2, and OTHERS
Risk sentiment through USDT Dominance (USDT.D)
Internal trend using EMA structure and RSI
🧠 How it works:

The script calculates two independent scores:

Long Score
Short Score

Then derives a final market bias:

🟢 LONG BIAS → strong bullish alignment
🔴 SHORT BIAS → strong bearish alignment
⚪ NEUTRAL / WAIT → mixed or weak conditions

All outputs are visually simplified into a clean, transparent table.

⚙️ Key Features:
Auto-detects the active chart symbol
Fully adapts to the current timeframe
Multi-market confirmation (BTC, ETH, TOTAL2, USDT.D)
Soft UI for distraction-free analysis
Designed for decision support, not signal chasing
📌 Best Use Cases:
Confirming trade setups before entry
Avoiding trades during conflicting market conditions
Evaluating altcoin strength vs the market
Filtering out low-probability trades
⚠️ Disclaimer:

This tool does not provide trading signals or financial advice.

It is intended to assist traders in understanding market alignment and should always be used alongside proper risk management and personal analysis.

## Source Code

````pine
//@version=6
indicator("Crypto Confirmation Engine - Auto Detect Coin", overlay=true)

// -------- Inputs
autoDetectCoin = input.bool(true, "Auto detect coin from chart?")
manualExchange = input.string("BINANCE", "Exchange for data")
manualCoin     = input.string("SOL", "Manual coin symbol")

tf = timeframe.period

fastLen  = input.int(20, "Fast EMA")
slowLen  = input.int(50, "Slow EMA")
rsiLen   = input.int(14, "RSI Length")

btcUSDT  = input.symbol("BINANCE:BTCUSDT", "BTC / USDT")
ethUSDT  = input.symbol("BINANCE:ETHUSDT", "ETH / USDT")

total    = input.symbol("CRYPTOCAP:TOTAL", "TOTAL")
total2   = input.symbol("CRYPTOCAP:TOTAL2", "TOTAL2")
others   = input.symbol("CRYPTOCAP:OTHERS", "OTHERS")
usdtd    = input.symbol("CRYPTOCAP:USDT.D", "USDT.D")

// -------- Detect Coin From Chart
cleanTicker(ticker) =>
    t = str.upper(ticker)
    t := str.replace_all(t, ".P", "")
    t := str.replace_all(t, "PERP", "")
    t := str.replace_all(t, "USDT", "")
    t := str.replace_all(t, "USDC", "")
    t := str.replace_all(t, "BUSD", "")
    t := str.replace_all(t, "USD", "")
    t := str.replace_all(t, "BTC", "")
    t := str.replace_all(t, "ETH", "")
    t

detectedCoin = cleanTicker(syminfo.ticker)
coinClean = autoDetectCoin ? detectedCoin : str.upper(str.trim(manualCoin))
exchangeToUse = manualExchange

// -------- Auto Symbols
coinUSDT = exchangeToUse + ":" + coinClean + "USDT"
coinBTC  = exchangeToUse + ":" + coinClean + "BTC"
coinETH  = exchangeToUse + ":" + coinClean + "ETH"

// -------- Trend Function
getTrend(sym) =>
    c       = request.security(sym, tf, close, ignore_invalid_symbol=true)
    emaFast = request.security(sym, tf, ta.ema(close, fastLen), ignore_invalid_symbol=true)
    emaSlow = request.security(sym, tf, ta.ema(close, slowLen), ignore_invalid_symbol=true)
    rsiVal  = request.security(sym, tf, ta.rsi(close, rsiLen), ignore_invalid_symbol=true)

    noData = na(c) or na(emaFast) or na(emaSlow) or na(rsiVal)

    bullish = not noData and c > emaFast and emaFast > emaSlow and rsiVal > 50
    bearish = not noData and c < emaFast and emaFast < emaSlow and rsiVal < 50

    result = 0
    if noData
        result := 99
    else if bullish
        result := 1
    else if bearish
        result := -1
    else
        result := 0

    result

// -------- Trends
trendCoinUSDT = getTrend(coinUSDT)
trendCoinBTC  = getTrend(coinBTC)
trendCoinETH  = getTrend(coinETH)

trendBTC      = getTrend(btcUSDT)
trendETH      = getTrend(ethUSDT)

trendTOTAL    = getTrend(total)
trendTOTAL2   = getTrend(total2)
trendOTHERS   = getTrend(others)
trendUSDTD    = getTrend(usdtd)

// -------- Scores
longScore = 50
shortScore = 50

longScore += trendCoinUSDT == 1 ? 20 : trendCoinUSDT == -1 ? -20 : 0
longScore += trendCoinBTC  == 1 ? 20 : trendCoinBTC  == -1 ? -20 : 0
longScore += trendCoinETH  == 1 ? 15 : trendCoinETH  == -1 ? -15 : 0
longScore += trendBTC      == 1 ? 10 : trendBTC      == -1 ? -10 : 0
longScore += trendETH      == 1 ? 5  : trendETH      == -1 ? -5  : 0
longScore += trendTOTAL    == 1 ? 10 : trendTOTAL    == -1 ? -10 : 0
longScore += trendTOTAL2   == 1 ? 15 : trendTOTAL2   == -1 ? -15 : 0
longScore += trendOTHERS   == 1 ? 10 : trendOTHERS   == -1 ? -10 : 0
longScore += trendUSDTD    == -1 ? 10 : trendUSDTD   == 1 ? -10 : 0

shortScore += trendCoinUSDT == -1 ? 20 : trendCoinUSDT == 1 ? -20 : 0
shortScore += trendCoinBTC  == -1 ? 20 : trendCoinBTC  == 1 ? -20 : 0
shortScore += trendCoinETH  == -1 ? 15 : trendCoinETH  == 1 ? -15 : 0
shortScore += trendBTC      == -1 ? 10 : trendBTC      == 1 ? -10 : 0
shortScore += trendETH      == -1 ? 5  : trendETH      == 1 ? -5  : 0
shortScore += trendTOTAL    == -1 ? 10 : trendTOTAL    == 1 ? -10 : 0
shortScore += trendTOTAL2   == -1 ? 15 : trendTOTAL2   == 1 ? -15 : 0
shortScore += trendOTHERS   == -1 ? 10 : trendOTHERS   == 1 ? -10 : 0
shortScore += trendUSDTD    == 1 ? 10 : trendUSDTD    == -1 ? -10 : 0

longFinalScore  = math.max(0, math.min(100, longScore))
shortFinalScore = math.max(0, math.min(100, shortScore))

bias = "NEUTRAL / WAIT"

if longFinalScore >= 70 and longFinalScore > shortFinalScore + 10
    bias := "LONG BIAS"
else if shortFinalScore >= 70 and shortFinalScore > longFinalScore + 10
    bias := "SHORT BIAS"

// -------- UI Functions
trendText(x) =>
    txt = "Neutral"
    if x == 1
        txt := "Bullish"
    else if x == -1
        txt := "Bearish"
    else if x == 99
        txt := "No data"
    txt

trendColor(x) =>
    col = color.new(color.white, 25)
    if x == 1
        col := color.new(color.green, 40)
    else if x == -1
        col := color.new(color.red, 40)
    else if x == 99
        col := color.new(color.gray, 60)
    col

scoreColor(x) =>
    col = color.new(color.red, 30)
    if x >= 70
        col := color.new(color.green, 30)
    else if x >= 55
        col := color.new(color.orange, 35)
    else if x >= 45
        col := color.new(color.white, 25)
    col

biasColor() =>
    col = color.new(color.white, 25)
    if bias == "LONG BIAS"
        col := color.new(color.green, 20)
    else if bias == "SHORT BIAS"
        col := color.new(color.red, 20)
    col

cellBg() =>
    color.new(color.black, 85)

headerBg() =>
    color.new(color.gray, 85)

// -------- Table
var table t = table.new(position.top_right, 2, 15, border_width=1, frame_color=color.new(color.white, 85), border_color=color.new(color.white, 90))

if barstate.islast
    table.cell(t, 0, 0, "Item", text_color=color.white, bgcolor=headerBg())
    table.cell(t, 1, 0, "Status", text_color=color.white, bgcolor=headerBg())

    table.cell(t, 0, 1, "Detected Coin", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 1, coinClean, text_color=color.yellow, bgcolor=cellBg())

    table.cell(t, 0, 2, "Chart Symbol", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 2, syminfo.ticker, text_color=color.new(color.white, 20), bgcolor=cellBg())

    table.cell(t, 0, 3, "Auto Bias", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 3, bias, text_color=biasColor(), bgcolor=cellBg())

    table.cell(t, 0, 4, "Long Score", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 4, str.tostring(longFinalScore) + " / 100", text_color=scoreColor(longFinalScore), bgcolor=cellBg())

    table.cell(t, 0, 5, "Short Score", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 5, str.tostring(shortFinalScore) + " / 100", text_color=scoreColor(shortFinalScore), bgcolor=cellBg())

    table.cell(t, 0, 6, "Coin/USDT", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 6, trendText(trendCoinUSDT), text_color=trendColor(trendCoinUSDT), bgcolor=cellBg())

    table.cell(t, 0, 7, "Coin/BTC", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 7, trendText(trendCoinBTC), text_color=trendColor(trendCoinBTC), bgcolor=cellBg())

    table.cell(t, 0, 8, "Coin/ETH", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 8, trendText(trendCoinETH), text_color=trendColor(trendCoinETH), bgcolor=cellBg())

    table.cell(t, 0, 9, "BTC", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 9, trendText(trendBTC), text_color=trendColor(trendBTC), bgcolor=cellBg())

    table.cell(t, 0, 10, "ETH", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 10, trendText(trendETH), text_color=trendColor(trendETH), bgcolor=cellBg())

    table.cell(t, 0, 11, "TOTAL", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 11, trendText(trendTOTAL), text_color=trendColor(trendTOTAL), bgcolor=cellBg())

    table.cell(t, 0, 12, "TOTAL2", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 12, trendText(trendTOTAL2), text_color=trendColor(trendTOTAL2), bgcolor=cellBg())

    table.cell(t, 0, 13, "OTHERS", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 13, trendText(trendOTHERS), text_color=trendColor(trendOTHERS), bgcolor=cellBg())

    table.cell(t, 0, 14, "USDT.D", text_color=color.white, bgcolor=cellBg())
    table.cell(t, 1, 14, trendText(trendUSDTD), text_color=trendColor(trendUSDTD), bgcolor=cellBg())
````
