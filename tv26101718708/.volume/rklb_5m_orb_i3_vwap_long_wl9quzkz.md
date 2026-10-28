# RKLB 5m ORB I3 VWAP Long

- url: https://www.tradingview.com/script/Wl9QUzkZ/
- type: strategy
- pine_id: PUB;3db63c626f004f11aa1e83244d0b967e
- version: 1.0

## Description

这是一套针对 RKLB 5 分钟 K 线的日内开盘区间突破策略。脚本以美股常规交易时段开盘后的第一根 5 分钟 K 线作为 Opening Range，使用其高低点定义当日关键突破区间；仅在盘中指定时间窗口内寻找向上突破机会，并通过 VWAP 方向过滤提高趋势一致性。策略采用单日最多一笔交易、固定风险回报比、开盘区间大小过滤、突破缓冲 tick、开盘区间低点止损和 2R 目标止盈机制。为避免隔夜风险，脚本会在收盘前强制平仓，并且不允许持仓跨越常规交易时段。

## Source Code

````pine
//@version=6
strategy("RKLB 5m ORB I3 VWAP Long", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.05, slippage=1, pyramiding=0, process_orders_on_close=false)

sideInput = input.string("Long only", "Trade side", options=["Both", "Long only", "Short only"])
rr = input.float(2.0, "Reward/Risk I3", minval=0.25, step=0.25)
bufferTicks = input.int(1, "Breakout buffer ticks", minval=0)
maxRangePct = input.float(6.0, "Max opening range %", minval=0.1, step=0.1)
minRangePct = input.float(0.3, "Min opening range %", minval=0.0, step=0.1)
useVwapFilter = input.bool(true, "Use VWAP direction filter")
useRetestEntry = input.bool(false, "Require pullback into range before breakout")
entryCutoff = input.session("0935-1530", "Entry window")
flatWindow = input.session("1555-1600", "Force flat window")
regularSession = input.session("0930-1600", "Regular session")
showStats = input.bool(true, "Show stats table")

inRegular = not na(time(timeframe.period, regularSession))
inEntryWindow = not na(time(timeframe.period, entryCutoff))
inFlatWindow = not na(time(timeframe.period, flatWindow))
newRegularSession = inRegular and (barstate.isfirst or ta.change(time("D")) != 0)
vwapValue = ta.vwap(hlc3)

var float orHigh = na
var float orLow = na
var float orMid = na
var bool rangeReady = false
var bool tradedToday = false
var bool pulledBackLong = false
var bool pulledBackShort = false
var int openingBarIndex = na

if newRegularSession
    orHigh := high
    orLow := low
    orMid := na
    rangeReady := false
    tradedToday := false
    pulledBackLong := false
    pulledBackShort := false
    openingBarIndex := bar_index

if inRegular and not rangeReady and not na(openingBarIndex) and bar_index > openingBarIndex
    orMid := (orHigh + orLow) / 2.0
    rangeReady := true

if rangeReady and inEntryWindow
    pulledBackLong := pulledBackLong or low <= orHigh
    pulledBackShort := pulledBackShort or high >= orLow

rangePct = rangeReady ? (orHigh - orLow) / orMid * 100.0 : na
rangeOk = rangeReady and rangePct >= minRangePct and rangePct <= maxRangePct
longAllowed = sideInput == "Both" or sideInput == "Long only"
shortAllowed = sideInput == "Both" or sideInput == "Short only"
longFilterOk = not useVwapFilter or close > vwapValue
shortFilterOk = not useVwapFilter or close < vwapValue
longRetestOk = not useRetestEntry or pulledBackLong
shortRetestOk = not useRetestEntry or pulledBackShort

longStopPrice = rangeReady ? orLow : na
shortStopPrice = rangeReady ? orHigh : na
longEntryStop = rangeReady ? orHigh + bufferTicks * syminfo.mintick : na
shortEntryStop = rangeReady ? orLow - bufferTicks * syminfo.mintick : na
longRisk = rangeReady ? longEntryStop - longStopPrice : na
shortRisk = rangeReady ? shortStopPrice - shortEntryStop : na
longTarget = rangeReady ? longEntryStop + longRisk * rr : na
shortTarget = rangeReady ? shortEntryStop - shortRisk * rr : na

canPlaceOrders = rangeOk and inEntryWindow and not tradedToday and strategy.position_size == 0
if canPlaceOrders and longAllowed and longRisk > syminfo.mintick and longFilterOk and longRetestOk
    strategy.entry("ORB Long", strategy.long, stop=longEntryStop)
if canPlaceOrders and shortAllowed and shortRisk > syminfo.mintick and shortFilterOk and shortRetestOk
    strategy.entry("ORB Short", strategy.short, stop=shortEntryStop)

if strategy.position_size > 0
    tradedToday := true
    strategy.cancel("ORB Short")
    strategy.exit("Long exit", from_entry="ORB Long", stop=longStopPrice, limit=longTarget)
if strategy.position_size < 0
    tradedToday := true
    strategy.cancel("ORB Long")
    strategy.exit("Short exit", from_entry="ORB Short", stop=shortStopPrice, limit=shortTarget)

if not inEntryWindow or tradedToday
    strategy.cancel("ORB Long")
    strategy.cancel("ORB Short")

if inFlatWindow or not inRegular
    strategy.cancel("ORB Long")
    strategy.cancel("ORB Short")
    strategy.close_all(comment="EOD flat")

plot(rangeReady ? orHigh : na, "Opening range high", color=color.new(color.lime, 0), linewidth=2, style=plot.style_linebr)
plot(rangeReady ? orLow : na, "Opening range low", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)
plot(rangeReady ? orMid : na, "Opening range mid", color=color.new(color.gray, 35), linewidth=1, style=plot.style_linebr)
plotshape(newRegularSession, title="Opening bar", style=shape.square, location=location.belowbar, color=color.new(color.yellow, 0), size=size.tiny, text="OR")

var table statsTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 25), frame_color=color.new(color.gray, 60), frame_width=1)
if showStats and barstate.islast
    closedTrades = strategy.closedtrades
    winRate = closedTrades > 0 ? strategy.wintrades / closedTrades * 100.0 : na
    profitFactor = strategy.grossloss != 0 ? strategy.grossprofit / math.abs(strategy.grossloss) : na
    table.cell(statsTable, 0, 0, "Net", text_color=color.white)
    table.cell(statsTable, 1, 0, str.tostring(strategy.netprofit, "#.##"), text_color=strategy.netprofit >= 0 ? color.lime : color.red)
    table.cell(statsTable, 0, 1, "Trades", text_color=color.white)
    table.cell(statsTable, 1, 1, str.tostring(closedTrades), text_color=color.white)
    table.cell(statsTable, 0, 2, "Win %", text_color=color.white)
    table.cell(statsTable, 1, 2, str.tostring(winRate, "#.##"), text_color=color.white)
    table.cell(statsTable, 0, 3, "PF", text_color=color.white)
    table.cell(statsTable, 1, 3, str.tostring(profitFactor, "#.###"), text_color=color.white)
    table.cell(statsTable, 0, 4, "Max DD", text_color=color.white)
    table.cell(statsTable, 1, 4, str.tostring(strategy.max_drawdown, "#.##"), text_color=color.white)
    table.cell(statsTable, 0, 5, "Range %", text_color=color.white)
    table.cell(statsTable, 1, 5, str.tostring(rangePct, "#.##"), text_color=color.white)
````
