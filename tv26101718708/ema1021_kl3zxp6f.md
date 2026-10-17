# EMA1021

- url: https://www.tradingview.com/script/kl3Zxp6f/
- type: indicator
- pine_id: PUB;3c1d57ffef4240f78c9e9ab5b83882d9
- version: 1.0

## Description

EMA10上穿EMA21进场，前提是有很长一段的下跌，而不是震荡
EMA10下穿EMA21止盈

## Source Code

````pine
//@version=6
indicator("EMA10/21 开盘进场 + 止损 + EMA死叉离场（带数据看板）", shorttitle="EMA10/21 策略看板", overlay=true, max_bars_back=5000)

// =========================
// 参数
// =========================
emaFastLen = input.int(10, "快线长度（默认 EMA10）", minval=1)
emaSlowLen = input.int(21, "慢线长度（默认 EMA21）", minval=1)
showEmaFast = input.bool(true, "显示快线 EMA")
showEmaSlow = input.bool(true, "显示慢线 EMA")

// 止损设置
useStopLoss = input.bool(true, "启用固定百分比止损")
stopLossPct = input.float(5.0, "止损比例(%)", minval=0.1, maxval=50.0, step=0.1)

// 统计与日期过滤
showStatsTable     = input.bool(true,  "显示交易统计面板")
useStatsDateFilter = input.bool(false, "按日期区间过滤统计")
statsStartDate     = input.time(timestamp("2000-01-01T00:00:00"), "统计开始日期")
useTodayAsEnd      = input.bool(true, "统计结束日期=今天")
customEndDate      = input.time(timestamp("2100-12-31T23:59:00"), "自定义统计结束日期")

effectiveEndDate = useTodayAsEnd ? timenow : customEndDate

// 卖出标签
showExitGainLabel = input.bool(true, "卖出/止损时显示收益率标签")

// 回测末尾虚拟卖出
enableVirtualExit = input.bool(true, "回测结束时虚拟卖出并计入面板（黄色标签）")

// =========================
// 统计面板样式设置
// =========================
panelPosition     = input.string("top_right", "统计面板位置", options=["top_left", "top_right", "bottom_left", "bottom_right"])
panelBgColor      = input.color(color.new(color.black, 20), "统计面板背景色")
panelBorderColor  = input.color(color.new(color.white, 80), "统计面板边框颜色")

titleTextColor    = input.color(color.gray, "标题文字颜色")
valueTextColor    = input.color(color.white, "普通数值颜色")
profitTextColor   = input.color(color.lime, "盈利数值颜色")
lossTextColor     = input.color(color.red, "亏损数值颜色")
neutralTextColor  = input.color(color.yellow, "中性高亮颜色")
drawdownTextColor = input.color(color.orange, "回撤颜色")

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
// EMA
// =========================
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

plot(showEmaFast ? emaFast : na, color=color.new(color.green, 0), linewidth=2, title="快线 EMA")
plot(showEmaSlow ? emaSlow : na, color=color.new(color.red, 0), linewidth=2, title="慢线 EMA")

// =========================
// MA 信息标签
// =========================
var label maInfoLabel = na
if barstate.islast
    if showEmaFast or showEmaSlow
        if not na(maInfoLabel)
            label.delete(maInfoLabel)

        fastTxt = showEmaFast ? ("Fast EMA (" + str.tostring(emaFastLen) + ")") : ""
        slowTxt = showEmaSlow ? ("Slow EMA (" + str.tostring(emaSlowLen) + ")") : ""
        sepTxt  = (showEmaFast and showEmaSlow) ? "\n" : ""
        fullTxt = fastTxt + sepTxt + slowTxt
        anchorY = showEmaFast ? emaFast : emaSlow

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
var int   entryTime  = na   // 实际进场时间（执行日开盘）

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
// 持仓时间统计（仅统计“普通卖出”，忽略止损）
// =========================
var int   holdCountSellOnly     = 0
var float holdSumDaysSellOnly   = 0.0
var float holdMaxDaysSellOnly   = na
var float holdMinDaysSellOnly   = na

// =========================
// 待执行信号（次日开盘执行）
// =========================
var bool pendingBuy      = false
var bool pendingSell     = false
var int  pendingBuyTime  = na
var int  pendingExitTime = na

// 实际执行事件
var bool execBuyThisBar  = false
var bool execSellThisBar = false
var bool execStopThisBar = false

execBuyThisBar  := false
execSellThisBar := false
execStopThisBar := false

// =========================
// 1) 先执行盘中止损，再执行上一根留下的待执行订单 —— 本根成交
// =========================
stopPrice = inTrade and not na(entryPrice) ? entryPrice * (1.0 - stopLossPct / 100.0) : na
intrabarStopHit = useStopLoss and inTrade and not na(stopPrice) and low <= stopPrice

if intrabarStopHit
    exitPrice = open <= stopPrice ? open : stopPrice
    exitGain  = (exitPrice - entryPrice) / entryPrice * 100.0
    exitGainSeriesValue := exitGain
    execStopThisBar := true

    label.new(bar_index, high, "止损",
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

    inTrade         := false
    entryPrice      := na
    entryTime       := na
    lastSignalIsBuy := false

    pendingSell     := false
    pendingExitTime := na

else if bar_index > 0
    // 先处理普通出场
    if pendingSell and inTrade
        exitPrice = open
        exitGain  = (exitPrice - entryPrice) / entryPrice * 100.0
        exitGainSeriesValue := exitGain
        execSellThisBar := true

        label.new(bar_index, high, "卖",
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

        inTrade         := false
        entryPrice      := na
        entryTime       := na
        lastSignalIsBuy := false

        pendingSell     := false
        pendingExitTime := na

    // 再处理进场
    if pendingBuy and not inTrade
        inTrade         := true
        entryPrice      := open
        entryTime       := time
        lastSignalIsBuy := true
        execBuyThisBar  := true

        pendingBuy      := false
        pendingBuyTime  := na

// =========================
// 2) 用本根收盘数据生成新信号（留给下一根开盘执行）
// =========================

// 进场逻辑：EMA10 上穿 EMA21
rawBuySignal = ta.crossover(emaFast, emaSlow)

// 离场逻辑：EMA10 下穿 EMA21
rawSellSignal = ta.crossunder(emaFast, emaSlow)

// =========================
// 3) 记录待执行信号
// =========================
if rawSellSignal and inTrade and not intrabarStopHit
    pendingSell     := true
    pendingExitTime := time

if rawBuySignal and not inTrade and not pendingBuy
    pendingBuy     := true
    pendingBuyTime := time

// =========================
// 实际执行标签
// =========================
plotshape(execBuyThisBar, title="真实买(次日开盘执行)", style=shape.labelup, location=location.belowbar,
     color=color.new(color.green, 0), textcolor=color.white, text="买")

plotshape(execSellThisBar, title="真实卖(次日开盘执行)", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.red, 0), textcolor=color.white, text="卖")

plotshape(execStopThisBar, title="真实止损(盘中执行)", style=shape.labeldown, location=location.abovebar,
     color=color.new(color.orange, 0), textcolor=color.black, text="止损")

plotshape(rawBuySignal, title="买入信号", style=shape.circle, location=location.belowbar,
     color=color.new(color.green, 0), size=size.tiny)

plotshape(rawSellSignal, title="卖出信号", style=shape.circle, location=location.abovebar,
     color=color.new(color.red, 0), size=size.tiny)

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

        // 虚拟卖出：仅用于面板显示
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

            label.new(bar_index, high, "卖(虚)", yloc=yloc.abovebar, style=label.style_label_down,
                color=color.new(color.yellow, 0), textcolor=color.black)

            if showExitGainLabel
                label.new(bar_index, low, formatGainStr(lastExitGain), yloc=yloc.belowbar, style=label.style_label_up,
                    color=color.new(color.yellow, 0), textcolor=color.black)

        winRate  = effTradeCount > 0 ? effWinCount * 100.0 / effTradeCount : na
        avgWin   = effWinCount  > 0 ? effSumWinGain / effWinCount : na
        avgLoss  = effLossCount > 0 ? effSumLossGain / effLossCount : na
        totalRet = effTradeCount > 0 ? (effEquityCurve - 1.0) * 100.0 : na

        // 按统计区间计算年化收益率
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
alertcondition(rawBuySignal,    "买入信号(次日开盘执行)", "EMA快线上穿慢线，下一根K线开盘执行买入")
alertcondition(rawSellSignal,   "卖出信号(次日开盘执行)", "EMA快线下穿慢线，下一根K线开盘执行卖出")
alertcondition(intrabarStopHit, "盘中止损信号", "止损价在当前K线盘中被触发")

// =========================
// 可导出事件/收益率
// =========================
plot(execSellThisBar ? 1 : na, title="真实卖出执行标记(可导出)", display=display.data_window)
plot(execStopThisBar ? 1 : na, title="真实止损执行标记(可导出)", display=display.data_window)
plot(exitGainSeriesValue, title="出场收益率%(可导出)", display=display.data_window)
plot(stopPrice, title="止损价(可导出)", display=display.data_window)
````
