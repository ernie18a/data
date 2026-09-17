<!-- tradingview-pine-id: PUB;c7c61c00186a4bfa97cc84e003ada5cf -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Double U Strategy with Webhook Alerts

Source: https://www.tradingview.com/script/Fnph6Wzr-Double-U-Strategy-with-Webhook-Alerts/

## Description

Double U Strategy with Webhook Alerts

Double U Strategy is a trend-following strategy built around two independent ATR-based engines, one for long entries and one for short entries. The idea comes from the ATR trailing-stop approach commonly associated with UT Bot, but Double U uses a different implementation and trading structure. The reason for separating the two sides is simple: bullish and bearish moves often behave differently, so forcing both directions to use exactly the same ATR settings is not always useful.

The long and short engines each have their own sensitivity and ATR period. A long entry can occur when price crosses above the long ATR trail while remaining above the trend EMA, while a short entry can occur when price crosses below the short ATR trail while remaining below the same EMA. The EMA is therefore used as a regime filter rather than as an entry signal by itself.

The strategy also supports pyramiding. If another valid signal appears while a position in the same direction is already open, the strategy can add to that position until the pyramiding limit is reached. The default limit is three entries, but this can be changed from the Strategy Properties.

Exits use a separate mechanism instead of simply waiting for the ATR engine to reverse. The script compares the current close with the close a configurable number of bars earlier and counts consecutive moves in the same direction. Once the required sequence is reached, the current position is closed. This keeps entry and exit logic independent: ATR behavior decides when to enter, while the sequence logic decides when an extended move has progressed far enough to exit.

The default configuration was selected as a practical starting point for testing rather than as a claim of universal optimization. The current setup uses a long-term EMA filter together with different ATR settings for long and short trades, reflecting the asymmetric design of the strategy. Results can change significantly between instruments and timeframes, so the parameters should be tested rather than treated as fixed recommendations.

Webhook alerts

Webhook support is built directly into the strategy. Entry and exit orders generate structured alert messages automatically, so there is no need to manually create separate JSON messages for buys, sells, or closes.

When creating a TradingView strategy alert, the Message field should contain only:

{{strategy.order.alert_message}}

The strategy includes a platform selector and an optional symbol override. If the symbol field is left empty, the chart ticker is sent in the webhook message. If an external execution system requires a different symbol, the required ticker can be entered directly. This is useful not only for crypto, but also for futures, forex, indices, metals, or any case where the TradingView symbol differs from the execution symbol.

For example, a strategy can run on a continuous futures chart while the webhook sends the currently tradable contract instead. The trading logic remains attached to the chart, while the execution symbol can be changed without modifying the Pine code.

Statistics

A compact statistics table is displayed on the chart to make parameter testing faster. It shows net profit, number of closed trades, win rate, profit factor, test period, pessimistic profit factor, maximum intratrade drawdown, and Sharpe ratio.

The drawdown value in this table is intentionally different from TradingView's portfolio-level maximum drawdown. It shows the largest adverse movement experienced inside any closed trade, which makes it useful when comparing parameter combinations and estimating how much floating loss a trade may have experienced before closing.

The Sharpe ratio is calculated from monthly equity returns using a 2% annual risk-free rate and is annualized from monthly observations.

Backtesting notes

The strategy uses 10% of equity as the default order size, allows up to three pyramided entries, processes orders on bar close, and includes 15 ticks of slippage by default. Commission is not hard-coded because the script can be tested on instruments with very different pricing models. Users should set commission, margin, slippage, and other Strategy Properties according to the broker, exchange, and instrument they actually intend to trade.

Historical results are hypothetical and depend on the selected market, timeframe, data source, execution assumptions, and parameters. The purpose of Double U Strategy is to provide a transparent strategy that can be backtested, adjusted, and connected to webhook-based execution, not to predict future performance.

---

## Source Code

````pine
//@version=6
//@strategy_alert_message {{strategy.order.alert_message}}

strategy(title="Double U Strategy with Webhook Alerts", shorttitle="Double U Strategy", overlay=true, pyramiding=3, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, process_orders_on_close=true, slippage=15)

// Double U Strategy with Webhook Alerts
// Independent implementation of a dual ATR trailing-stop model inspired by the widely known UT Bot concept.
// Two independent ATR engines are used for short and long entries.
// Trend direction is filtered by a long-term EMA.
// Repeated entry signals allow pyramiding.
// Price-sequence conditions are used as position exits.
// AlgoWay integration generates execution-ready strategy alerts.

// ==========================================
// TREND FILTER
// ==========================================

trendLength = input.int(700, title="Trend EMA Length", minval=1, group="Trend Filter")
trendLine = ta.ema(close, trendLength)

shortSensitivity = input.float(5.0, title="Short Sensitivity", minval=0.1, step=0.1, group="Short Engine")
shortAtrLength = input.int(3, title="Short ATR Length", minval=1, group="Short Engine")

longSensitivity = input.float(3.0, title="Long Sensitivity", minval=0.1, step=0.1, group="Long Engine")
longAtrLength = input.int(4, title="Long ATR Length", minval=1, group="Long Engine")

exitReference = input.int(5, title="Reference Bars", minval=1, group="Exit")
exitSequenceLength = input.int(9, title="Sequence Length", minval=1, group="Exit")

plot(trendLine, title="Trend EMA", color=color.gray, linewidth=2)

// ==========================================
// SHORT ENGINE
// ==========================================


shortAtr = ta.atr(shortAtrLength)
shortDistance = shortSensitivity * shortAtr

var float shortTrail = na
shortPreviousTrail = nz(shortTrail[1], close)

if na(shortTrail[1])
    shortTrail := close + shortDistance
else if close > shortPreviousTrail and close[1] > shortPreviousTrail
    shortTrail := math.max(shortPreviousTrail, close - shortDistance)
else if close < shortPreviousTrail and close[1] < shortPreviousTrail
    shortTrail := math.min(shortPreviousTrail, close + shortDistance)
else
    shortTrail := close > shortPreviousTrail ? close - shortDistance : close + shortDistance

shortSignal = ta.crossunder(close, shortTrail) and close < trendLine

// ==========================================
// LONG ENGINE
// ==========================================


longAtr = ta.atr(longAtrLength)
longDistance = longSensitivity * longAtr

var float longTrail = na
longPreviousTrail = nz(longTrail[1], close)

if na(longTrail[1])
    longTrail := close - longDistance
else if close > longPreviousTrail and close[1] > longPreviousTrail
    longTrail := math.max(longPreviousTrail, close - longDistance)
else if close < longPreviousTrail and close[1] < longPreviousTrail
    longTrail := math.min(longPreviousTrail, close + longDistance)
else
    longTrail := close > longPreviousTrail ? close - longDistance : close + longDistance

longSignal = ta.crossover(close, longTrail) and close > trendLine

// ==========================================
// EXIT ENGINE
// ==========================================


var int bullishSequence = 0
var int bearishSequence = 0

if close > close[exitReference]
    bullishSequence += 1
    bearishSequence := 0
else if close < close[exitReference]
    bearishSequence += 1
    bullishSequence := 0

longExit = bullishSequence == exitSequenceLength
shortExit = bearishSequence == exitSequenceLength

// ==========================================
// ALGOWAY PLATFORMS
// ==========================================

string awGroup = "AlgoWay Platforms  |  Alert Message: {{strategy.order.alert_message}}"

awPlatform = input.string("metatrader5", title="Platform", options=["metatrader5", "tradelocker", "matchtrader", "dxtrade", "ctrader", "ctrader_oapi", "ibkr", "alpaca", "capitalcom", "tradovate", "projectx", "binance", "bybit", "okx", "mexc", "bitget", "bingx", "gateio", "kraken", "kucoin", "toobit", "weex"], group=awGroup)
awSymbolMapping = input.string("", title="Symbol Mapping", tooltip="Leave empty to send the chart symbol. Enter a symbol to override it, for example MNQU6, GOLD, BTCUSDT or NAS100.", group=awGroup)

awTicker = awSymbolMapping != "" ? awSymbolMapping : syminfo.ticker

// ==========================================
// ORDER QUANTITY
// ==========================================

defaultOrderQty = strategy.default_entry_qty(close)

qtyForex = math.round(defaultOrderQty / 1000) * 1000
qtyStandard = math.round(defaultOrderQty * 100) / 100
qtyCryptoOneDecimal = math.round(qtyStandard * 10) / 10
qtyCryptoHundreds = math.round(qtyStandard / 100) * 100
qtyCrypto = qtyStandard > 1000 ? qtyCryptoHundreds : qtyStandard > 10 ? math.round(qtyStandard) : qtyStandard > 1 ? qtyCryptoOneDecimal : qtyStandard
qtyCfd = math.round(defaultOrderQty * 10) / 10

tradeQty = syminfo.type == "forex" ? qtyForex : syminfo.type == "crypto" ? qtyCrypto : syminfo.type == "cfd" ? qtyCfd : qtyStandard

// ==========================================
// ALGOWAY ALERT JSON
// ==========================================

awQtyString(float qty) =>
    str.tostring(math.abs(qty))

awEntryJson(string orderId, string action, float qty) =>
    '{"platform_name":"' + awPlatform + '","ticker":"' + awTicker + '","order_id":"' + orderId + '","order_action":"' + action + '","order_contracts":"' + awQtyString(qty) + '","price":"' + str.tostring(close, format.mintick) + '"}'

awFlatJson(string orderId, float qty) =>
    '{"platform_name":"' + awPlatform + '","ticker":"' + awTicker + '","order_id":"' + orderId + '","order_action":"flat","order_contracts":"' + awQtyString(qty) + '","price":"' + str.tostring(close, format.mintick) + '"}'

// ==========================================
// EXECUTION
// ==========================================

if longExit and strategy.position_size > 0
    float longCloseQty = math.abs(strategy.position_size)
    strategy.close("Long", immediately=true, comment="EX", alert_message=awFlatJson("Long", longCloseQty))

if shortExit and strategy.position_size < 0
    float shortCloseQty = math.abs(strategy.position_size)
    strategy.close("Short", immediately=true, comment="EX", alert_message=awFlatJson("Short", shortCloseQty))

if longSignal and not longExit
    strategy.entry("Long", strategy.long, qty=tradeQty, comment="B", alert_message=awEntryJson("Long", "buy", tradeQty))

if shortSignal and not shortExit
    strategy.entry("Short", strategy.short, qty=tradeQty, comment="S", alert_message=awEntryJson("Short", "sell", tradeQty))

// ==========================================
// STRATEGY STATISTICS
// ==========================================

var int firstBarTime = time

resultColor = strategy.netprofit > 0 ? color.green : color.fuchsia
netProfit = math.round(strategy.netprofit)
periodDays = math.max(1, math.round((time - firstBarTime) / 86400000))
winRate = strategy.closedtrades > 0 ? math.round((strategy.wintrades / strategy.closedtrades * 100) * 10) / 10 : na
profitFactor = strategy.grossloss > 0 ? math.round((strategy.grossprofit / strategy.grossloss) * 100) / 100 : na

canCalculatePpf = strategy.wintrades > 0 and strategy.losstrades > 0 and strategy.grossloss > 0
adjustedGrossProfit = canCalculatePpf ? strategy.grossprofit / strategy.wintrades * (strategy.wintrades - math.sqrt(strategy.wintrades)) : na
adjustedGrossLoss = canCalculatePpf ? strategy.grossloss / strategy.losstrades * (strategy.losstrades + math.sqrt(strategy.losstrades)) : na
ppfRaw = canCalculatePpf and adjustedGrossLoss > 0 ? adjustedGrossProfit / adjustedGrossLoss : na
ppfResult = na(ppfRaw) ? na : math.round(ppfRaw * 100) / 100

float maxDrawdown = 0.0

if strategy.closedtrades > 0
    for i = 0 to strategy.closedtrades - 1
        maxDrawdown := math.max(maxDrawdown, strategy.closedtrades.max_drawdown(i))

arrayAverage(array<float> values) =>
    int count = array.size(values)
    float total = 0.0
    if count > 0
        for i = 0 to count - 1
            total += array.get(values, i)
        total / count
    else
        na

arraySampleStdev(array<float> values) =>
    int count = array.size(values)
    if count > 1
        float average = arrayAverage(values)
        float total = 0.0
        for i = 0 to count - 1
            float value = array.get(values, i)
            total += math.pow(value - average, 2)
        math.sqrt(total / (count - 1))
    else
        na

var array<float> monthlyReturns = array.new<float>()
var float monthStartEquity = na

if na(monthStartEquity)
    monthStartEquity := strategy.equity

newMonth = month(time) != month(time[1]) or year(time) != year(time[1])

if newMonth and not na(strategy.equity[1]) and monthStartEquity > 0
    float monthReturn = (strategy.equity[1] - monthStartEquity) / monthStartEquity
    array.push(monthlyReturns, monthReturn)
    monthStartEquity := strategy.equity[1]

riskFreeAnnual = 0.02
riskFreeMonthly = riskFreeAnnual / 12.0
monthlyAverage = arrayAverage(monthlyReturns)
monthlyStdDev = arraySampleStdev(monthlyReturns)
sharpeRaw = not na(monthlyAverage) and not na(monthlyStdDev) and monthlyStdDev > 0 ? ((monthlyAverage - riskFreeMonthly) / monthlyStdDev) * math.sqrt(12) : na
sharpeRatio = na(sharpeRaw) ? na : math.round(sharpeRaw * 100) / 100

statValue(float value) =>
    na(value) ? "-" : str.tostring(value)

// ==========================================
// STATISTICS TABLE
// ==========================================

var table statsTable = table.new(position.top_right, 8, 2, border_width=3)

table.cell(statsTable, 0, 0, "Net Profit", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 1, 0, "Trades", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 2, 0, "Win %", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 3, 0, "Prf Fctr", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 4, 0, "Period", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 5, 0, "Psm Fctr", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 6, 0, "MxDrwDn", bgcolor=color.gray, text_color=color.white, width=7, height=4)
table.cell(statsTable, 7, 0, "Sharpe", bgcolor=color.gray, text_color=color.white, width=7, height=4)

table.cell(statsTable, 0, 1, str.tostring(netProfit), bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 1, 1, str.tostring(strategy.closedtrades), bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 2, 1, statValue(winRate) + " %", bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 3, 1, statValue(profitFactor), bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 4, 1, str.tostring(periodDays) + " d", bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 5, 1, statValue(ppfResult), bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 6, 1, str.tostring(math.round(maxDrawdown)), bgcolor=resultColor, text_color=color.black, width=7, height=4)
table.cell(statsTable, 7, 1, statValue(sharpeRatio), bgcolor=resultColor, text_color=color.black, width=7, height=4)
````
