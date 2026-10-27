# TQQQ Dual Entry

- url: https://www.tradingview.com/script/n9apx0pf/
- type: indicator
- pine_id: PUB;80f092f9c3c34b3598bb07e6bf62f48c
- version: 1.0

## Description

EMA进场和200日均线进场双策略

## Source Code

````pine
//@version=6
indicator("QQQ 均线信号 (驱动 TQQQ, 次日开盘执行) - 标注进出场方式", shorttitle="QQQ MA信号 (TQQQ 双进场)", overlay=true, max_bars_back=5000, max_labels_count=500)

// =========================
// 参数
// =========================
qqqSymbol  = input.symbol("QQQ", "QQQ 标的代码")

// =========================
// 进场设置
// =========================
entryGroup = "进场设置"

// ✅ 原始进场均线（Entry MA）
entryLen     = input.int(200, "原始进场均线长度", minval=1, group=entryGroup)
entryMaType  = input.string("SMA", "原始进场均线类型", options = ["SMA", "EMA"], group=entryGroup)
showEntryMa  = input.bool(true, "显示原始进场均线", group=entryGroup)

// ✅ EMA 进场
crossEntryLen     = input.int(10, "收盘价上穿EMA进场：EMA长度", minval=1, group=entryGroup)
showCrossEntryEma = input.bool(false, "显示收盘价上穿EMA进场均线", group=entryGroup)

// ✅ EMA 进场：成交量过滤
crossEntryVolGroup = "收盘价上穿EMA进场 - 成交量过滤"
useCrossEntryVolFilter  = input.bool(true, "启用成交量过滤", group=crossEntryVolGroup)
crossEntryVolMaLen      = input.int(20, "成交量均线长度", minval=1, group=crossEntryVolGroup)
crossEntryVolMultiplier = input.float(1.2, "成交量倍数", minval=0.1, step=0.1, group=crossEntryVolGroup)
showCrossEntryVolMa     = input.bool(false, "显示成交量均线（仅数据窗口）", group=crossEntryVolGroup)

// =========================
// 原始进场 Buffer 参数
// =========================
entryBufferGroup = "原始进场 Buffer"

useTimeBuffer  = input.bool(true, "进场时间Buffer：连续站上均线N根", group=entryBufferGroup, inline="entry_bar")
timeBufferBars = input.int(2, "", minval=1, maxval=50, group=entryBufferGroup, inline="entry_bar")

usePctBuffer   = input.bool(false, "进场百分比Buffer：高于均线X%", group=entryBufferGroup, inline="entry_pct")
aboveMaPct     = input.float(1.0, "", minval=0.0, maxval=50.0, step=0.1, group=entryBufferGroup, inline="entry_pct")

// =========================
// 趋势过滤参数（仅用于 EMA 进场）
// =========================
emaTrendFilterGroup = "EMA 趋势过滤（仅EMA进场）"

useEma21TrendFilter = input.bool(true, "启用 EMA 趋势过滤", group=emaTrendFilterGroup)
ema21TrendMethod    = input.string("连续N根递增", "趋势判断方式", options=["连续N根递增", "连续两根递增"], group=emaTrendFilterGroup)
ema21LookbackBars   = input.int(3, "连续N根递增：回看根数", minval=1, maxval=20, group=emaTrendFilterGroup)
showEma21           = input.bool(false, "显示 趋势过滤 EMA", group=emaTrendFilterGroup)

// =========================
// 退场均线（Exit MA）
// =========================
exitGroup = "退场设置"
exitLen      = input.int(200, "退场均线长度", minval=1, group=exitGroup)
exitMaType   = input.string("SMA", "退场均线类型", options = ["SMA", "EMA"], group=exitGroup)
showExitMa   = input.bool(true, "显示退场均线", group=exitGroup)

// =========================
// 退场 Buffer 参数
// =========================
exitBufferGroup = "退场 Buffer"

useExitBarBuffer = input.bool(true, "退场时间Buffer：连续跌破均线N根", group=exitBufferGroup, inline="exit_bar")
exitBarBufferN   = input.int(2, "", minval=1, maxval=50, group=exitBufferGroup, inline="exit_bar")

useExitPctBuffer = input.bool(false, "退场百分比Buffer：低于均线X%", group=exitBufferGroup, inline="exit_pct")
belowMaPct       = input.float(1.0, "", minval=0.0, maxval=50.0, step=0.1, group=exitBufferGroup, inline="exit_pct")

// =========================
// 统计设置
// =========================
statsGroup = "统计设置"
showStatsTable      = input.bool(true,  "显示交易统计面板", group=statsGroup)
useStatsDateFilter  = input.bool(false, "按日期区间过滤统计", group=statsGroup)
statsStartDate      = input.time(timestamp("2000-01-01T00:00:00"), "统计开始日期", group=statsGroup)
useTodayAsEnd       = input.bool(true, "统计结束日期=今天", group=statsGroup)
customEndDate       = input.time(timestamp("2100-12-31T23:59:00"), "自定义统计结束日期", group=statsGroup)
showExitGainLabel   = input.bool(true,  "卖出/止损时显示收益率标签", group=statsGroup)
enableVirtualExit   = input.bool(true,  "回测结束时虚拟卖出并计入面板（黄色标签）", group=statsGroup)

// 统一统计结束时间
effectiveEndDate = useTodayAsEnd ? timenow : customEndDate

// =========================
// 止损设置
// =========================
stopGroup = "止损设置"
useStopLoss         = input.bool(true,  "启用止损（按进场价回撤%）", group=stopGroup)
stopLossPct         = input.float(5.0,  "止损阈值：盘中低点低于进场价的百分比(%)", minval=0.1, maxval=50.0, step=0.1, group=stopGroup)

// =========================
// 统计面板样式设置
// =========================
panelGroup = "统计面板样式"
panelPosition = input.string("top_right", "统计面板位置", options=["top_left", "top_right", "bottom_left", "bottom_right"], group=panelGroup)
panelBgColor = input.color(color.new(color.black, 20), "统计面板背景色", group=panelGroup)
panelBorderColor = input.color(color.new(color.white, 80), "统计面板边框颜色", group=panelGroup)

titleTextColor = input.color(color.gray, "标题文字颜色", group=panelGroup)
valueTextColor = input.color(color.white, "普通数值颜色", group=panelGroup)
profitTextColor = input.color(color.lime, "盈利数值颜色", group=panelGroup)
lossTextColor = input.color(color.red, "亏损数值颜色", group=panelGroup)
neutralTextColor = input.color(color.yellow, "中性高亮颜色", group=panelGroup)
drawdownTextColor = input.color(color.orange, "回撤颜色", group=panelGroup)

// =========================
// 工具函数
// =========================
formatGainStr(gain) =>
    gain > 0 ? "+" + str.tostring(gain, "#.1") + "%" :
     gain < 0 ? "-" + str.tostring(math.abs(gain), "#.1") + "%" :
     "0.0%"

inStatsRange(entryTime) =>
    not useStatsDateFilter or (not na(entryTime) and entryTime >= statsStartDate and entryTime <= effectiveEndDate)

gainColor(v) =>
    na(v) ? valueTextColor : v > 0 ? profitTextColor : v < 0 ? lossTextColor : neutralTextColor

getTablePosition(pos) =>
    pos == "top_left" ? position.top_left :
     pos == "top_right" ? position.top_right :
     pos == "bottom_left" ? position.bottom_left :
     position.bottom_right

fmtDays(x) =>
    not na(x) ? str.tostring(x, "#.1") + " 天" : "N/A"

// =========================
// QQQ 数据 & 均线
// =========================
qqqClose  = request.security(qqqSymbol, timeframe.period, close)
qqqVolume = request.security(qqqSymbol, timeframe.period, volume)

entryMa = request.security(
    qqqSymbol,
    timeframe.period,
    entryMaType == "SMA" ? ta.sma(close, entryLen) : ta.ema(close, entryLen)
)

crossEntryEma   = request.security(qqqSymbol, timeframe.period, ta.ema(close, crossEntryLen))
crossEntryVolMa = request.security(qqqSymbol, timeframe.period, ta.sma(volume, crossEntryVolMaLen))

exitMa = request.security(
    qqqSymbol,
    timeframe.period,
    exitMaType == "SMA" ? ta.sma(close, exitLen) : ta.ema(close, exitLen)
)

// 趋势过滤 EMA：仅用于“收盘价上穿EMA进场”
trendFilterEma = request.security(qqqSymbol, timeframe.period, ta.ema(close, crossEntryLen))

plot(showEntryMa ? entryMa : na, color=color.new(color.teal, 0), linewidth=2, title="原始进场均线")
plot(showCrossEntryEma ? crossEntryEma : na, color=color.new(color.blue, 0), linewidth=2, title="收盘价上穿EMA进场均线")
plot(showExitMa ? exitMa : na, color=color.new(color.purple, 0), linewidth=2, title="退场均线")
plot(showEma21 ? trendFilterEma : na, color=color.new(color.orange, 0), linewidth=2, title="趋势过滤 EMA")

// 仅用于数据窗口查看
plot(showCrossEntryVolMa ? crossEntryVolMa : na, title="成交量均线(数据窗口)", display=display.data_window)

// =========================
// MA 信息标签
// =========================
var label maInfoLabel = na
if barstate.islast
    if showEntryMa or showExitMa or showEma21 or showCrossEntryEma
        if not na(maInfoLabel)
            label.delete(maInfoLabel)

        entryTxt = showEntryMa ? ("Entry MA: " + entryMaType + " (" + str.tostring(entryLen) + ")") : ""
        crossTxt = showCrossEntryEma ? ("Cross Entry EMA: EMA (" + str.tostring(crossEntryLen) + ")") : ""
        volTxt   = useCrossEntryVolFilter ? ("Vol MA: SMA (" + str.tostring(crossEntryVolMaLen) + ") × " + str.tostring(crossEntryVolMultiplier, "#.0#")) : ""
        ema21Txt = showEma21 ? ("Trend Filter EMA (" + str.tostring(crossEntryLen) + ")") : ""
        exitTxt  = showExitMa ? ("Exit MA: "  + exitMaType  + " (" + str.tostring(exitLen)  + ")") : ""

        fullTxt = ""
        fullTxt := entryTxt != "" ? entryTxt : fullTxt
        fullTxt := crossTxt != "" ? (fullTxt == "" ? crossTxt : fullTxt + "\n" + crossTxt) : fullTxt
        fullTxt := volTxt   != "" ? (fullTxt == "" ? volTxt   : fullTxt + "\n" + volTxt)   : fullTxt
        fullTxt := ema21Txt != "" ? (fullTxt == "" ? ema21Txt : fullTxt + "\n" + ema21Txt) : fullTxt
        fullTxt := exitTxt  != "" ? (fullTxt == "" ? exitTxt  : fullTxt + "\n" + exitTxt)  : fullTxt

        anchorY = crossEntryEma
        anchorY := showEntryMa ? entryMa : anchorY
        anchorY := showExitMa ? exitMa : anchorY
        anchorY := showEma21 ? trendFilterEma : anchorY

        maInfoLabel := label.new(bar_index, anchorY, fullTxt,
            style=label.style_label_left,
            color=color.new(color.gray, 0),
            textcolor=color.white)
    else
        if not na(maInfoLabel)
            label.delete(maInfoLabel)
            maInfoLabel := na

// =========================
// 图表时间边界（用于按统计区间算年化）
// =========================
var int chartStartTime = na
if barstate.isfirst
    chartStartTime := time

// =========================
// 交易状态与统计变量
// =========================
var bool  inTrade    = false
var float entryPrice = na
var int   entryTime  = na

// 当前持仓的进场来源：0=无, 1=原始均线进场, 2=EMA进场
var int tradeEntryMode = 0

// 若本笔单是 EMA 进场，只要曾经站上 entryMa，就永久切到原始退场规则
var bool promotedToOriginalExit = false

var int   tradeCount      = 0
var int   winCount        = 0
var int   lossCount       = 0
var float sumExitGainAll  = 0.0
var float sumWinGain      = 0.0
var float sumLossGain     = 0.0
var float maxExitGain     = na
var float minExitGain     = na

var float equityCurve = 1.0
var float peakEquity  = 1.0
var float maxDrawdown = 0.0

var int firstTradeTime = na
var int lastTradeTime  = na

var bool lastSignalIsBuy = false

// 导出用
var float exitGainSeriesValue = na
exitGainSeriesValue := na

// =========================
// 持仓时间统计（仅统计“卖出”，忽略止损）
// =========================
var int   holdCountSellOnly     = 0
var float holdSumDaysSellOnly   = 0.0
var float holdMaxDaysSellOnly   = na
var float holdMinDaysSellOnly   = na

// =========================
// 待执行信号（次日开盘执行）
// =========================
var bool pendingBuy       = false
var bool pendingSell      = false
var int  pendingBuyTime   = na
var int  pendingExitTime  = na
var int  pendingBuyMode   = 0   // 0=无, 1=原始均线进场, 2=EMA进场

// 可视化：实际执行事件
var bool execBuyThisBar  = false
var bool execSellThisBar = false
var bool execStopThisBar = false

execBuyThisBar  := false
execSellThisBar := false
execStopThisBar := false

// =========================
// 1) 先执行盘中止损，再执行上一根留下的待执行订单
// =========================
stopPrice = not na(entryPrice) ? entryPrice * (1.0 - stopLossPct / 100.0) : na
intrabarStopHit = useStopLoss and inTrade and not na(stopPrice) and low <= stopPrice

if intrabarStopHit
    float exitPrice = open <= stopPrice ? open : stopPrice
    float exitGain  = (exitPrice - entryPrice) / entryPrice * 100.0
    exitGainSeriesValue := exitGain
    execStopThisBar := true

    stopMethodText = tradeEntryMode == 1 ? "止损(均线单)" : tradeEntryMode == 2 ? "止损(EMA单)" : "止损"

    label.new(bar_index, high, stopMethodText,
        yloc=yloc.abovebar,
        style=label.style_label_down,
        color=color.new(color.orange, 0),
        textcolor=color.black)

    if showExitGainLabel
        label.new(bar_index, low, formatGainStr(exitGain),
            yloc=yloc.belowbar, style=label.style_label_up,
            color=exitGain >= 0 ? color.new(color.green, 0) : color.new(color.red, 0),
            textcolor=color.white)

    if inStatsRange(entryTime)
        tradeCount     += 1
        sumExitGainAll += exitGain

        if exitGain > 0
            winCount   += 1
            sumWinGain += exitGain
        else
            lossCount   += 1
            sumLossGain += exitGain

        maxExitGain := na(maxExitGain) ? exitGain : math.max(maxExitGain, exitGain)
        minExitGain := na(minExitGain) ? exitGain : math.min(minExitGain, exitGain)

        if na(firstTradeTime)
            firstTradeTime := entryTime
        lastTradeTime := time

        equityCurve *= (1 + exitGain / 100)
        peakEquity  := math.max(peakEquity, equityCurve)
        maxDrawdown := math.max(maxDrawdown, (peakEquity - equityCurve) / peakEquity * 100)

    inTrade                := false
    entryPrice             := na
    entryTime              := na
    tradeEntryMode         := 0
    promotedToOriginalExit := false
    lastSignalIsBuy        := false

    pendingSell     := false
    pendingExitTime := na

else if bar_index > 0
    if pendingSell and inTrade
        float exitPrice = open
        float exitGain  = (exitPrice - entryPrice) / entryPrice * 100.0
        exitGainSeriesValue := exitGain
        execSellThisBar := true

        sellMethodText =
             tradeEntryMode == 1 ? "卖(均线)" :
             tradeEntryMode == 2 ? (promotedToOriginalExit ? "卖(均线)" : "卖(EMA)") :
             "卖"

        label.new(bar_index, high, sellMethodText,
            yloc=yloc.abovebar,
            style=label.style_label_down,
            color=color.new(color.red, 0),
            textcolor=color.white)

        if showExitGainLabel
            label.new(bar_index, low, formatGainStr(exitGain),
                yloc=yloc.belowbar, style=label.style_label_up,
                color=exitGain >= 0 ? color.new(color.green, 0) : color.new(color.red, 0),
                textcolor=color.white)

        if inStatsRange(entryTime)
            tradeCount     += 1
            sumExitGainAll += exitGain

            if exitGain > 0
                winCount   += 1
                sumWinGain += exitGain
            else
                lossCount   += 1
                sumLossGain += exitGain

            maxExitGain := na(maxExitGain) ? exitGain : math.max(maxExitGain, exitGain)
            minExitGain := na(minExitGain) ? exitGain : math.min(minExitGain, exitGain)

            if na(firstTradeTime)
                firstTradeTime := entryTime
            lastTradeTime := time

            equityCurve *= (1 + exitGain / 100)
            peakEquity  := math.max(peakEquity, equityCurve)
            maxDrawdown := math.max(maxDrawdown, (peakEquity - equityCurve) / peakEquity * 100)

            holdDays = (time - entryTime) / 1000.0 / 60.0 / 60.0 / 24.0
            holdCountSellOnly   += 1
            holdSumDaysSellOnly += holdDays
            holdMaxDaysSellOnly := na(holdMaxDaysSellOnly) ? holdDays : math.max(holdMaxDaysSellOnly, holdDays)
            holdMinDaysSellOnly := na(holdMinDaysSellOnly) ? holdDays : math.min(holdMinDaysSellOnly, holdDays)

        inTrade                := false
        entryPrice             := na
        entryTime              := na
        tradeEntryMode         := 0
        promotedToOriginalExit := false
        lastSignalIsBuy        := false

        pendingSell     := false
        pendingExitTime := na

    if pendingBuy and not inTrade
        inTrade                := true
        entryPrice             := open
        entryTime              := time
        tradeEntryMode         := pendingBuyMode
        promotedToOriginalExit := false
        lastSignalIsBuy        := true
        execBuyThisBar         := true

        buyLabelText = tradeEntryMode == 1 ? "买(均线)" : tradeEntryMode == 2 ? "买(EMA)" : "买"

        label.new(bar_index, low, buyLabelText,
            yloc=yloc.belowbar,
            style=label.style_label_up,
            color=color.new(color.green, 0),
            textcolor=color.white)

        pendingBuy      := false
        pendingBuyTime  := na
        pendingBuyMode  := 0

// =========================
// 2) 用本根收盘数据生成新信号（留给下一根开盘执行）
// =========================

// —— 趋势过滤 EMA：连续N根递增 / 连续两根递增（仅供 EMA 进场使用）
emaTrendUpN = bar_index > ema21LookbackBars ? true : false
if emaTrendUpN
    for i = 0 to ema21LookbackBars - 1
        emaTrendUpN := emaTrendUpN and trendFilterEma[i] > trendFilterEma[i + 1]

emaTrendUp2Bars = trendFilterEma > trendFilterEma[1] and trendFilterEma[1] > trendFilterEma[2]
ema21TrendUp    = ema21TrendMethod == "连续N根递增" ? emaTrendUpN : emaTrendUp2Bars
ema21FilterOk   = useEma21TrendFilter ? ema21TrendUp : true

// —— 原始均线进场逻辑（不使用 EMA 趋势过滤）
aboveBars         = ta.barssince(qqqClose < entryMa)
timeBufferOk      = useTimeBuffer ? (not na(aboveBars) and aboveBars >= timeBufferBars) : true
pctBufferOk       = usePctBuffer ? (qqqClose >= entryMa * (1 + aboveMaPct / 100.0)) : true
entryStateOkMA    = timeBufferOk and pctBufferOk
rawBuySignalMA    = entryStateOkMA and not entryStateOkMA[1]

// —— EMA 进场逻辑：收盘价站上指定EMA + 成交量过滤 + EMA趋势过滤
crossPriceOk      = qqqClose > crossEntryEma
crossVolThreshold = crossEntryVolMa * crossEntryVolMultiplier
crossVolOk        = useCrossEntryVolFilter ? (qqqVolume > crossVolThreshold) : true
crossEntryStateOk = crossPriceOk and crossVolOk and ema21FilterOk
rawBuySignalCross = crossEntryStateOk and not crossEntryStateOk[1]

// —— 合并进场逻辑：谁先满足就按谁进场
// 同一根K线若两者同时满足，默认优先 原始均线 进场
rawBuySignal = rawBuySignalMA or rawBuySignalCross

// —— 若本笔单是 EMA 进场，只要持仓期间曾经站上 entryMa，就永久升级
if inTrade and tradeEntryMode == 2 and not promotedToOriginalExit and qqqClose > entryMa
    promotedToOriginalExit := true

// =========================
// 卖出逻辑
// =========================

// —— 原始退场逻辑：QQQ 连续跌破/低于退场均线
belowExitMa     = qqqClose < exitMa
belowBars       = ta.barssince(not belowExitMa)
exitBarBufferOk = useExitBarBuffer ? (not na(belowBars) and belowBars >= exitBarBufferN - 1) : true
exitPctBufferOk = useExitPctBuffer ? (qqqClose <= exitMa * (1 - belowMaPct / 100.0)) : true
exitStateOk     = belowExitMa and exitBarBufferOk and exitPctBufferOk
rawSellSignalOriginal = exitStateOk and not exitStateOk[1]

// —— EMA 进场模式下的 EMA 卖出：收盘价跌破用于新进场的 EMA
rawSellSignalCrossEma = ta.crossunder(qqqClose, crossEntryEma)

// —— 根据当前持仓来源决定卖出逻辑
rawSellSignal =
     tradeEntryMode == 1 ? rawSellSignalOriginal :
     tradeEntryMode == 2 ? (promotedToOriginalExit ? rawSellSignalOriginal : rawSellSignalCrossEma) :
     false

// =========================
// 3) 记录待执行信号
// =========================
if rawSellSignal and inTrade and not intrabarStopHit
    pendingSell     := true
    pendingExitTime := time

if rawBuySignal and not inTrade and not pendingBuy
    pendingBuy     := true
    pendingBuyTime := time
    pendingBuyMode := rawBuySignalMA ? 1 : 2

// =========================
// 辅助执行标记（固定文字，避免 plotshape 报错）
// =========================
plotshape(execBuyThisBar, title="真实买(执行标记)", style=shape.circle, location=location.belowbar,
     color=color.new(color.green, 0), size=size.tiny)

plotshape(execSellThisBar, title="真实卖(执行标记)", style=shape.circle, location=location.abovebar,
     color=color.new(color.red, 0), size=size.tiny)

plotshape(execStopThisBar, title="真实止损(执行标记)", style=shape.circle, location=location.abovebar,
     color=color.new(color.orange, 0), size=size.tiny)

// =========================
// Lump Sum（区间一次性买入持有）收益率
// =========================
var float lumpEntryPrice = na
var float lumpExitPrice  = na

if na(lumpEntryPrice) and time >= statsStartDate and time <= effectiveEndDate
    lumpEntryPrice := close

if time >= statsStartDate and time <= effectiveEndDate
    lumpExitPrice := close

lumpSumRet = (not na(lumpEntryPrice) and not na(lumpExitPrice)) ? (lumpExitPrice - lumpEntryPrice) / lumpEntryPrice * 100.0 : na

// =========================
// 统计面板
// =========================
var table statsTable = na

var string lastPanelPosition = panelPosition
if lastPanelPosition != panelPosition
    if not na(statsTable)
        table.delete(statsTable)
        statsTable := na
    lastPanelPosition := panelPosition

if showStatsTable
    if na(statsTable)
        statsTable := table.new(
             getTablePosition(panelPosition),
             2,
             11,
             border_color = panelBorderColor,
             bgcolor = panelBgColor
        )

    if barstate.islast
        effTradeCount     = tradeCount
        effWinCount       = winCount
        effLossCount      = lossCount
        effSumExitGainAll = sumExitGainAll
        effSumWinGain     = sumWinGain
        effSumLossGain    = sumLossGain
        effMaxExitGain    = maxExitGain
        effMinExitGain    = minExitGain
        effEquityCurve    = equityCurve
        effPeakEquity     = peakEquity
        effMaxDrawdown    = maxDrawdown
        effFirstTradeTime = firstTradeTime
        effLastTradeTime  = lastTradeTime

        effHoldCountSellOnly   = holdCountSellOnly
        effHoldSumDaysSellOnly = holdSumDaysSellOnly
        effHoldMaxDaysSellOnly = holdMaxDaysSellOnly
        effHoldMinDaysSellOnly = holdMinDaysSellOnly

        if enableVirtualExit and inTrade and lastSignalIsBuy and not na(entryPrice) and inStatsRange(entryTime)
            float lastExitGain = (close - entryPrice) / entryPrice * 100

            effTradeCount     += 1
            effSumExitGainAll += lastExitGain

            if lastExitGain > 0
                effWinCount   += 1
                effSumWinGain += lastExitGain
            else
                effLossCount   += 1
                effSumLossGain += lastExitGain

            effMaxExitGain := na(effMaxExitGain) ? lastExitGain : math.max(effMaxExitGain, lastExitGain)
            effMinExitGain := na(effMinExitGain) ? lastExitGain : math.min(effMinExitGain, lastExitGain)

            if na(effFirstTradeTime)
                effFirstTradeTime := entryTime
            effLastTradeTime := time

            effEquityCurve *= (1 + lastExitGain / 100)
            effPeakEquity   := math.max(effPeakEquity, effEquityCurve)
            ddLast          = (effPeakEquity - effEquityCurve) / effPeakEquity * 100
            effMaxDrawdown  := math.max(effMaxDrawdown, ddLast)

            virtualSellText =
                 tradeEntryMode == 1 ? "卖(虚,均线)" :
                 tradeEntryMode == 2 ? (promotedToOriginalExit ? "卖(虚,均线)" : "卖(虚,EMA)") :
                 "卖(虚)"

            label.new(bar_index, high, virtualSellText, yloc=yloc.abovebar, style=label.style_label_down,
                color=color.new(color.yellow, 0), textcolor=color.black)

            if showExitGainLabel
                label.new(bar_index, low, formatGainStr(lastExitGain), yloc=yloc.belowbar, style=label.style_label_up,
                    color=color.new(color.yellow, 0), textcolor=color.black)

        winRate  = effTradeCount > 0 ? effWinCount * 100.0 / effTradeCount : na
        avgWin   = effWinCount  > 0 ? effSumWinGain / effWinCount : na
        avgLoss  = effLossCount > 0 ? effSumLossGain / effLossCount : na
        totalRet = effTradeCount > 0 ? (effEquityCurve - 1.0) * 100.0 : na

        // =========================
        // 年化收益率：按统一统计区间计算
        // =========================
        annualStartTime = useStatsDateFilter ? statsStartDate : chartStartTime
        annualEndTime   = useStatsDateFilter ? effectiveEndDate : time

        daysInPeriod  = not na(annualStartTime) and not na(annualEndTime) ? (annualEndTime - annualStartTime) / 1000.0 / 60.0 / 60.0 / 24.0 : na
        yearsInPeriod = not na(daysInPeriod) ? daysInPeriod / 365.0 : na
        annualRet     = effTradeCount > 0 and not na(yearsInPeriod) and yearsInPeriod > 0 ? (math.pow(effEquityCurve, 1.0 / yearsInPeriod) - 1.0) * 100.0 : na

        avgHoldDays = effHoldCountSellOnly > 0 ? effHoldSumDaysSellOnly / effHoldCountSellOnly : na
        maxHoldDays = effHoldMaxDaysSellOnly
        minHoldDays = effHoldMinDaysSellOnly

        table.clear(statsTable, 0, 0, 1, 10)

        table.cell(statsTable, 0, 0, "交易笔数", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 0, str.tostring(effTradeCount), text_color=valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 1, "胜率", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 1, effTradeCount > 0 ? str.tostring(winRate, "#.0") + "%" : "N/A",
             text_color=effTradeCount > 0 ? neutralTextColor : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 2, "平均盈利率", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 2, effWinCount > 0 ? str.tostring(avgWin, "+#.1") + "%" : "N/A",
             text_color=effWinCount > 0 ? profitTextColor : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 3, "平均亏损率", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 3, effLossCount > 0 ? str.tostring(avgLoss, "#.1") + "%" : "N/A",
             text_color=effLossCount > 0 ? lossTextColor : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 4, "总收益率", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 4, effTradeCount > 0 ? formatGainStr(totalRet) : "N/A",
             text_color=effTradeCount > 0 ? gainColor(totalRet) : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 5, "最大回撤", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 5, effTradeCount > 0 ? "-" + str.tostring(effMaxDrawdown, "#.1") + "%" : "N/A",
             text_color=effTradeCount > 0 ? drawdownTextColor : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 6, "年化收益率", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 6, effTradeCount > 0 and not na(annualRet) ? formatGainStr(annualRet) : "N/A",
             text_color=effTradeCount > 0 and not na(annualRet) ? gainColor(annualRet) : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 7, "Lump Sum收益率", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 7, not na(lumpSumRet) ? formatGainStr(lumpSumRet) : "N/A",
             text_color=not na(lumpSumRet) ? gainColor(lumpSumRet) : valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 8, "平均持仓时间(仅卖出)", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 8, fmtDays(avgHoldDays), text_color=valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 9, "最长持仓时间(仅卖出)", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 9, fmtDays(maxHoldDays), text_color=valueTextColor, bgcolor=panelBgColor)

        table.cell(statsTable, 0, 10, "最短持仓时间(仅卖出)", text_color=titleTextColor, bgcolor=panelBgColor)
        table.cell(statsTable, 1, 10, fmtDays(minHoldDays), text_color=valueTextColor, bgcolor=panelBgColor)
else
    if not na(statsTable)
        table.delete(statsTable)
        statsTable := na

// =========================
// Alerts
// =========================
alertcondition(rawBuySignal,  "TQQQ - 买入信号(次日开盘执行)", "买入信号已确认：下一根K线开盘执行买入")
alertcondition(rawSellSignal, "TQQQ - 卖出信号(次日开盘执行)", "卖出信号已确认：下一根K线开盘执行卖出")
alertcondition(intrabarStopHit, "TQQQ - 盘中止损信号", "止损价在当前K线盘中被触发")

// =========================
// 可导出事件/收益率
// =========================
plot(execSellThisBar ? 1 : na, title="真实卖出执行标记(可导出)", display=display.data_window)
plot(execStopThisBar ? 1 : na, title="真实止损执行标记(可导出)", display=display.data_window)
plot(exitGainSeriesValue, title="出场收益率%(可导出)", display=display.data_window)
plot(qqqVolume, title="QQQ成交量(可导出)", display=display.data_window)
plot(crossEntryVolMa, title="QQQ成交量均线(可导出)", display=display.data_window)
plot(crossVolThreshold, title="QQQ成交量阈值(可导出)", display=display.data_window)
plot(tradeEntryMode, title="当前持仓进场模式(0无/1原始/2EMA)", display=display.data_window)
plot(promotedToOriginalExit ? 1 : 0, title="EMA进场后是否已永久切换原始退场(0否/1是)", display=display.data_window)
plot(stopPrice, title="止损价(可导出)", display=display.data_window)
````
