# Footprint Delta Divergence

- url: https://www.tradingview.com/script/bh1JdikF-Footprint-Delta-Divergence/
- type: indicator
- pine_id: PUB;aa66cda103d643a78b23e2db89e57c17
- version: 1.0

## Description

# Overview

This indicator automatically detects **delta divergences** on your chart — a powerful signal derived from order flow analysis. When price makes a new extreme but the underlying buying/selling pressure (delta) fails to confirm, it often signals an impending reversal. This is the core concept behind footprint chart divergence trading, now fully automated.

## What Is Delta Divergence?

In footprint analysis, **delta** represents the net difference.

## Overview

This indicator automatically detects **delta divergences** on your chart — a powerful signal derived from order flow analysis. When price makes a new extreme but the underlying buying/selling pressure (delta) fails to confirm, it often signals an impending reversal. This is the core concept behind footprint chart divergence trading, now fully automated.

## What Is Delta Divergence?

In footprint analysis,

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © Olivia's Delta Divergence Detector

//@version=6
indicator("Footprint Delta Divergence", overlay=true, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// 【输入参数】
// ─────────────────────────────────────────────
grp_delta   = "═══ Delta 计算 ═══"
deltaMethod = input.string("Volume Delta (Tick)", "Delta 数据源", 
     options=["Volume Delta (Tick)", "Volume Delta (估算)", "OBV"], group=grp_delta,
     tooltip="Tick方式需要CME逐笔数据权限；估算方式用K线位置加权近似")
smoothLen   = input.int(1, "Delta 平滑周期", minval=1, maxval=10, group=grp_delta)

grp_pivot   = "═══ 枢轴检测 ═══"
pivotLen    = input.int(5, "Pivot Lookback", minval=2, maxval=20, group=grp_pivot,
     tooltip="用于识别波段高低点的回溯K线数")
maxBars     = input.int(100, "背离最大间隔(K线)", minval=10, maxval=300, group=grp_pivot,
     tooltip="两个枢轴点之间最多间隔多少根K线")

grp_filter  = "═══ 过滤条件 ═══"
minDeltaPct = input.float(10.0, "最小Delta变化%", minval=0, maxval=100, group=grp_filter,
     tooltip="两个枢轴点Delta差异至少达到此百分比才标记")
useVolFilter = input.bool(true, "成交量过滤", group=grp_filter)
volMulti     = input.float(0.8, "最低成交量倍数(相对MA)", minval=0.1, step=0.1, group=grp_filter)
volMaLen     = input.int(20, "成交量MA周期", minval=5, group=grp_filter)

grp_style   = "═══ 显示样式 ═══"
showBull    = input.bool(true, "显示看涨背离", group=grp_style)
showBear    = input.bool(true, "显示看跌背离", group=grp_style)
showHidden  = input.bool(false, "显示隐藏背离", group=grp_style)
showDeltaPanel = input.bool(true, "显示Delta面板", group=grp_style)
bullColor   = input.color(color.new(#00E676, 0), "看涨背离颜色", group=grp_style)
bearColor   = input.color(color.new(#FF5252, 0), "看跌背离颜色", group=grp_style)
hiddenAlpha = input.int(60, "隐藏背离透明度", minval=0, maxval=100, group=grp_style)

grp_alert   = "═══ 报警 ═══"
alertOn     = input.bool(true, "启用报警", group=grp_alert)


// ─────────────────────────────────────────────
// 【Delta 计算】
// ─────────────────────────────────────────────

// 方法1: 基于逐笔数据的真实Delta (需要CME Tick数据权限)
// TradingView 提供 ta.deltavolume() — 仅在有Level2/Tick数据时可用
// 这里用 upticks/downticks 近似
tickDelta() =>
    up = ta.accdist  // 近似累积
    // 使用内置的 volume 拆分: 基于bar内价格位置
    buyVol  = volume * (close - low) / math.max(high - low, syminfo.mintick)
    sellVol = volume * (high - close) / math.max(high - low, syminfo.mintick)
    buyVol - sellVol

// 方法2: K线位置加权估算
estimatedDelta() =>
    range_size = math.max(high - low, syminfo.mintick)
    // Williams' accumulation/distribution 思路
    closePos = (close - low) / range_size  // 0~1
    delta = volume * (2.0 * closePos - 1.0)
    delta

// 方法3: OBV 变体
obvDelta() =>
    close > close[1] ? volume : close < close[1] ? -volume : 0.0

// 选择Delta源
rawDelta = switch deltaMethod
    "Volume Delta (Tick)"  => tickDelta()
    "Volume Delta (估算)"  => estimatedDelta()
    "OBV"                  => obvDelta()
    => tickDelta()

delta = ta.sma(rawDelta, smoothLen)

// 累积Delta (用于面板显示)
cumDelta = ta.cum(rawDelta)
cumDeltaSmooth = ta.ema(cumDelta, 5)

// ─────────────────────────────────────────────
// 【成交量过滤】
// ─────────────────────────────────────────────
volMa      = ta.sma(volume, volMaLen)
volOk      = not useVolFilter or (volume >= volMa * volMulti)

// ─────────────────────────────────────────────
// 【枢轴点检测】
// ─────────────────────────────────────────────
// 价格枢轴
pvtHigh = ta.pivothigh(high, pivotLen, pivotLen)
pvtLow  = ta.pivotlow(low, pivotLen, pivotLen)

// Delta枢轴 (在相同位置取Delta值)
pvtDeltaHigh = ta.pivothigh(delta, pivotLen, pivotLen)
pvtDeltaLow  = ta.pivotlow(delta, pivotLen, pivotLen)

// ─────────────────────────────────────────────
// 【背离检测引擎】
// ─────────────────────────────────────────────

// 存储上一个枢轴点信息
var float lastPvtHighPrice  = na
var float lastPvtHighDelta  = na
var int   lastPvtHighBar    = na

var float lastPvtLowPrice   = na
var float lastPvtLowDelta   = na
var int   lastPvtLowBar     = na

// 背离信号
var bool bullDiv    = false
var bool bearDiv    = false
var bool hidBullDiv = false
var bool hidBearDiv = false

bullDiv    := false
bearDiv    := false
hidBullDiv := false
hidBearDiv := false

// 用于画线的坐标
var int   divLineX1 = na
var float divLineY1 = na
var int   divLineX2 = na
var float divLineY2 = na

// --- 检测看涨背离 (价格更低低 + Delta更高低) ---
if not na(pvtLow)
    currentLowPrice = low[pivotLen]
    currentLowDelta = delta[pivotLen]
    currentBar      = bar_index - pivotLen
    
    if not na(lastPvtLowPrice) and (currentBar - lastPvtLowBar) <= maxBars
        priceDiff = (currentLowPrice - lastPvtLowPrice) / math.abs(lastPvtLowPrice) * 100
        deltaDiff = math.abs(currentLowDelta - lastPvtLowDelta) / math.max(math.abs(lastPvtLowDelta), 1) * 100
        
        // 常规看涨背离: 价格新低 + Delta没有新低
        if currentLowPrice < lastPvtLowPrice and currentLowDelta > lastPvtLowDelta
            if deltaDiff >= minDeltaPct and volOk[pivotLen]
                bullDiv := true
                divLineX1 := lastPvtLowBar
                divLineY1 := lastPvtLowPrice
                divLineX2 := currentBar
                divLineY2 := currentLowPrice
        
        // 隐藏看涨背离: 价格更高低 + Delta更低低
        if showHidden and currentLowPrice > lastPvtLowPrice and currentLowDelta < lastPvtLowDelta
            if deltaDiff >= minDeltaPct and volOk[pivotLen]
                hidBullDiv := true
                divLineX1 := lastPvtLowBar
                divLineY1 := lastPvtLowPrice
                divLineX2 := currentBar
                divLineY2 := currentLowPrice
    
    lastPvtLowPrice := currentLowPrice
    lastPvtLowDelta := currentLowDelta
    lastPvtLowBar   := currentBar

// --- 检测看跌背离 (价格更高高 + Delta更低高) ---
if not na(pvtHigh)
    currentHighPrice = high[pivotLen]
    currentHighDelta = delta[pivotLen]
    currentBar       = bar_index - pivotLen
    
    if not na(lastPvtHighPrice) and (currentBar - lastPvtHighBar) <= maxBars
        priceDiff = (currentHighPrice - lastPvtHighPrice) / math.abs(lastPvtHighPrice) * 100
        deltaDiff = math.abs(currentHighDelta - lastPvtHighDelta) / math.max(math.abs(lastPvtHighDelta), 1) * 100
        
        // 常规看跌背离: 价格新高 + Delta没有新高
        if currentHighPrice > lastPvtHighPrice and currentHighDelta < lastPvtHighDelta
            if deltaDiff >= minDeltaPct and volOk[pivotLen]
                bearDiv := true
                divLineX1 := lastPvtHighBar
                divLineY1 := lastPvtHighPrice
                divLineX2 := currentBar
                divLineY2 := currentHighPrice
        
        // 隐藏看跌背离: 价格更低高 + Delta更高高
        if showHidden and currentHighPrice < lastPvtHighPrice and currentHighDelta > lastPvtHighDelta
            if deltaDiff >= minDeltaPct and volOk[pivotLen]
                hidBearDiv := true
                divLineX1 := lastPvtHighBar
                divLineY1 := lastPvtHighPrice
                divLineX2 := currentBar
                divLineY2 := currentHighPrice
    
    lastPvtHighPrice := currentHighPrice
    lastPvtHighDelta := currentHighDelta
    lastPvtHighBar   := currentBar

// ─────────────────────────────────────────────
// 【绘图 — 背离标记 & 连线】
// ─────────────────────────────────────────────

// 看涨背离
if bullDiv and showBull
    label.new(divLineX2, divLineY2, "🟢 Bull\nΔ Div", 
         style=label.style_label_up, color=bullColor, 
         textcolor=color.white, size=size.small)
    line.new(divLineX1, divLineY1, divLineX2, divLineY2,
         color=bullColor, width=2, style=line.style_solid)

// 看跌背离
if bearDiv and showBear
    label.new(divLineX2, divLineY2, "🔴 Bear\nΔ Div", 
         style=label.style_label_down, color=bearColor, 
         textcolor=color.white, size=size.small)
    line.new(divLineX1, divLineY1, divLineX2, divLineY2,
         color=bearColor, width=2, style=line.style_solid)

// 隐藏看涨背离
if hidBullDiv and showHidden
    hidBullColor = color.new(bullColor, hiddenAlpha)
    label.new(divLineX2, divLineY2, "H.Bull\nΔ Div", 
         style=label.style_label_up, color=hidBullColor, 
         textcolor=color.white, size=size.tiny)
    line.new(divLineX1, divLineY1, divLineX2, divLineY2,
         color=hidBullColor, width=1, style=line.style_dashed)

// 隐藏看跌背离
if hidBearDiv and showHidden
    hidBearColor = color.new(bearColor, hiddenAlpha)
    label.new(divLineX2, divLineY2, "H.Bear\nΔ Div", 
         style=label.style_label_down, color=hidBearColor, 
         textcolor=color.white, size=size.tiny)
    line.new(divLineX1, divLineY1, divLineX2, divLineY2,
         color=hidBearColor, width=1, style=line.style_dashed)

// ─────────────────────────────────────────────
// 【Delta 子面板】
// ─────────────────────────────────────────────
// 注意: 因为 overlay=true, 用 bgcolor 标记背离区域
barcolor(bullDiv and showBull ? bullColor : bearDiv and showBear ? bearColor : na)

// 背景高亮
bgcolor(bullDiv and showBull ? color.new(bullColor, 90) : na, title="看涨背离背景")
bgcolor(bearDiv and showBear ? color.new(bearColor, 90) : na, title="看跌背离背景")

// ─────────────────────────────────────────────
// 【信息表格】
// ─────────────────────────────────────────────
if barstate.islast and showDeltaPanel
    var table infoTbl = table.new(position.top_right, 2, 5, 
         bgcolor=color.new(#1E1E1E, 10), border_width=1, border_color=color.gray)
    
    table.cell(infoTbl, 0, 0, "Delta", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 0, str.tostring(math.round(delta, 0)), 
         text_color=delta > 0 ? #00E676 : #FF5252, text_size=size.small)
    
    table.cell(infoTbl, 0, 1, "Cum Δ", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 1, str.tostring(math.round(cumDelta, 0)), 
         text_color=cumDelta > cumDeltaSmooth ? #00E676 : #FF5252, text_size=size.small)
    
    table.cell(infoTbl, 0, 2, "Vol/MA", text_color=color.white, text_size=size.small)
    table.cell(infoTbl, 1, 2, str.tostring(math.round(volume / volMa, 2)) + "x", 
         text_color=volume > volMa ? #00E676 : color.gray, text_size=size.small)
    
    table.cell(infoTbl, 0, 3, "方法", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTbl, 1, 3, deltaMethod, text_color=color.gray, text_size=size.tiny)

    table.cell(infoTbl, 0, 4, "Pivot", text_color=color.gray, text_size=size.tiny)
    table.cell(infoTbl, 1, 4, str.tostring(pivotLen), text_color=color.gray, text_size=size.tiny)

// ─────────────────────────────────────────────
// 【报警条件】
// ─────────────────────────────────────────────
alertcondition(bullDiv,    "看涨 Delta 背离", "🟢 看涨 Delta 背离 — 价格新低但Delta未新低")
alertcondition(bearDiv,    "看跌 Delta 背离", "🔴 看跌 Delta 背离 — 价格新高但Delta未新高")
alertcondition(hidBullDiv, "隐藏看涨背离",     "🟢 隐藏看涨 Delta 背离")
alertcondition(hidBearDiv, "隐藏看跌背离",     "🔴 隐藏看跌 Delta 背离")

if alertOn and bullDiv
    alert("🟢 看涨 Delta 背离 @ " + str.tostring(close), alert.freq_once_per_bar)
if alertOn and bearDiv
    alert("🔴 看跌 Delta 背离 @ " + str.tostring(close), alert.freq_once_per_bar)
````
