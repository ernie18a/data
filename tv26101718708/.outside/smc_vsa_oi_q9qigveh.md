# SMC + VSA & OI

- url: https://www.tradingview.com/script/q9QIgVeh-SMC-VSA-OI/
- type: indicator
- pine_id: PUB;0f3443c5c9c04d2a8011d77c350eada5
- version: 1.0

## Description

Overview
This is a hardcore institutional-grade indicator built on Pine Script v6, combining Smart Money Concepts (SMC), Volume Spread Analysis (VSA), and real-time Open Interest (OI) tracking to expose market manipulation and liquidity hunts.

Core Features:
1. Dynamic Session Liquidity (SMC): Automatically tracks Asian, London, and NY session highs/lows. It alerts you when retail stop-losses are swept (Sweep BSL/SSL) at these key levels.

2. VSA Anomaly Detection (Volume): > * Blue Candles: Ultra-high volume climaxes.

Cyan Candles: High volume pushes.

3. The Ultimate Lie Detector (Real-time OI):

Yellow Candles (Institutional Push): Price pushes UP accompanied by an Open Interest surge (> 3x average). This validates a true breakout backed by limit orders.

Fuchsia/Magenta Candles (Retail Squeeze): Price pushes violently, but Open Interest PLUMMETS. This exposes a fakeout fueled by forced liquidations (Stop Runs). Do not buy the pullback; prepare for a reversal!

How to use:
Never trade a blind FVG again. Use the Yellow candles to find solid order blocks, and use the Fuchsia candles to hunt for extreme reversals after retail capitulation.

(Chinese description can be added below if needed)

## Source Code

````pine
//@version=6
indicator("SMC 亚盘清算 + VSA & OI 变色终极版 (v6 引擎)", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. 设置面板 (Settings)
// ==========================================
grp_time = "1. 时间设置 (基于 UTC 时区)"
asianSession  = input.session("0000-0600", title="亚盘时间 (默认00:00-06:00 UTC)", group=grp_time)
londonSession = input.session("0700-1000", title="欧洲时间 (默认07:00-10:00 UTC)", group=grp_time)
nySession     = input.session("1300-1600", title="纽约时间 (默认13:00-16:00 UTC)", group=grp_time)

grp_line = "2. 动态边界线样式"
highLineColor = input.color(color.new(color.red, 40), title="高点延长线颜色", group=grp_line)
lowLineColor  = input.color(color.new(color.green, 40), title="低点延长线颜色", group=grp_line)
lineStyle     = input.string(line.style_solid, title="线型选择 (默认实线)", options=[line.style_solid, line.style_dashed, line.style_dotted], group=grp_line)
lineWidth     = input.int(2, title="线宽 (默认2像素)", minval=1, maxval=5, group=grp_line)

grp_vsa = "3. VSA 扫损基础判定"
volLength = input.int(50, title="均量线周期 (推荐50)", group=grp_vsa)
sweepMultiplier = input.float(1.5, title="扫损报警最低爆量门槛", step=0.1, group=grp_vsa)

grp_color = "4. K线异动变色设置 (巨量/高量) - 优先级 1"
ultraVolMultiplier = input.float(5.0, title="巨量门槛 (倍数)", step=0.5, group=grp_color)
ultraColor = input.color(#0000FF, title="巨量 K线颜色 (默认纯蓝)", group=grp_color)

highVolMultiplier = input.float(2.5, title="高量门槛 (倍数)", step=0.5, group=grp_color)
highColor = input.color(#1848CC, title="高量 K线颜色 (默认亮青)", group=grp_color)

grp_oi = "5. 订单流 OI 动态变色设置 - 优先级 2 (自动识别)"
oiLength = input.int(20, title="OI 平均变动基准周期", minval=1, group=grp_oi)
oiMultiplier = input.float(2.5, title="OI 暴增/暴减门槛 (默认3倍)", step=0.5, group=grp_oi)
oiSurgeColor = input.color(color.yellow, title="OI 暴增颜色 (主力建仓)", group=grp_oi)
oiDropColor = input.color(color.fuchsia, title="OI 暴减颜色 (散户挤兑)", group=grp_oi)

// ==========================================
// 2. 三大时区核心逻辑：捕捉与动态切换
// ==========================================
inAsia = not na(time(timeframe.period, asianSession, "UTC"))
isAsiaStart = inAsia and not inAsia[1]
isAsiaEnd = not inAsia and inAsia[1]

inLondon = not na(time(timeframe.period, londonSession, "UTC"))
isLondonStart = inLondon and not inLondon[1]
isLondonEnd = not inLondon and inLondon[1]

inNY = not na(time(timeframe.period, nySession, "UTC"))
isNYStart = inNY and not inNY[1]
isNYEnd = not inNY and inNY[1]

var float aHigh = na
var float aLow = na
var float lHigh = na
var float lLow = na
var float nHigh = na
var float nLow = na

// 动态狙击目标线
var float targetHigh = na
var float targetLow = na

var line activeHighLine = na
var line activeLowLine = na

// --- 记录各个时区的高低点 ---
if isAsiaStart
    aHigh := high
    aLow := low
else if inAsia
    aHigh := math.max(aHigh, high)
    aLow := math.min(aLow, low)

if isLondonStart
    lHigh := high
    lLow := low
else if inLondon
    lHigh := math.max(lHigh, high)
    lLow := math.min(lLow, low)

if isNYStart
    nHigh := high
    nLow := low
else if inNY
    nHigh := math.max(nHigh, high)
    nLow := math.min(nLow, low)

// --- 阶梯式动态切换与连线逻辑 ---
if isAsiaStart
    targetHigh := na
    targetLow := na
    activeHighLine := na
    activeLowLine := na

if isAsiaEnd
    targetHigh := aHigh
    targetLow := aLow
    activeHighLine := line.new(bar_index[1], targetHigh, bar_index, targetHigh, color=highLineColor, style=lineStyle, width=lineWidth)
    activeLowLine := line.new(bar_index[1], targetLow, bar_index, targetLow, color=lowLineColor, style=lineStyle, width=lineWidth)

if isLondonEnd
    prevHigh = targetHigh
    prevLow = targetLow
    targetHigh := lHigh
    targetLow := lLow
    
    if not na(prevHigh)
        line.new(bar_index[1], prevHigh, bar_index[1], targetHigh, color=highLineColor, style=lineStyle, width=lineWidth)
    if not na(prevLow)
        line.new(bar_index[1], prevLow, bar_index[1], targetLow, color=lowLineColor, style=lineStyle, width=lineWidth)
        
    activeHighLine := line.new(bar_index[1], targetHigh, bar_index, targetHigh, color=highLineColor, style=lineStyle, width=lineWidth)
    activeLowLine := line.new(bar_index[1], targetLow, bar_index, targetLow, color=lowLineColor, style=lineStyle, width=lineWidth)

if isNYEnd
    prevHigh = targetHigh
    prevLow = targetLow
    targetHigh := nHigh
    targetLow := nLow
    
    if not na(prevHigh)
        line.new(bar_index[1], prevHigh, bar_index[1], targetHigh, color=highLineColor, style=lineStyle, width=lineWidth)
    if not na(prevLow)
        line.new(bar_index[1], prevLow, bar_index[1], targetLow, color=lowLineColor, style=lineStyle, width=lineWidth)
        
    activeHighLine := line.new(bar_index[1], targetHigh, bar_index, targetHigh, color=highLineColor, style=lineStyle, width=lineWidth)
    activeLowLine := line.new(bar_index[1], targetLow, bar_index, targetLow, color=lowLineColor, style=lineStyle, width=lineWidth)

if not na(activeHighLine) and not inAsia
    line.set_x2(activeHighLine, bar_index)
if not na(activeLowLine) and not inAsia
    line.set_x2(activeLowLine, bar_index)

plot(targetHigh, title="当前高点突破线", color=color.new(color.red, 100), display=display.none)
plot(targetLow, title="当前低点跌破线", color=color.new(color.green, 100), display=display.none)

// ==========================================
// 3. 核心计算：VSA 交易量 & OI 订单流 (全自动识别版)
// ==========================================
// VSA 计算
avgVol = ta.sma(volume, volLength)
volRatio = avgVol > 0 ? (volume / avgVol) : 0

// OI 动态计算：全自动抓取当前品种合约的 OI (v6 原生支持动态序列)
auto_oi_ticker = syminfo.tickerid + "_OI"
oi_current = request.security(auto_oi_ticker, timeframe.period, close, ignore_invalid_symbol=true)
oi_prev    = request.security(auto_oi_ticker, timeframe.period, close[1], ignore_invalid_symbol=true)

// 计算 OI 单根变动真实值和绝对值
oi_change_raw = oi_current - oi_prev
oi_change_abs = math.abs(oi_change_raw)

// 计算过去 N 根 K 线的平均 OI 波动
avg_oi_change = ta.sma(oi_change_abs, oiLength)

// 判定 OI 极值 (大于均值的 N 倍)
is_oi_surge = (oi_change_raw > 0) and (oi_change_raw > (avg_oi_change * oiMultiplier))
is_oi_drop  = (oi_change_raw < 0) and (math.abs(oi_change_raw) > (avg_oi_change * oiMultiplier))

// ==========================================
// 4. 极致渲染：VSA 优先，OI 兜底 (变色矩阵)
// ==========================================
var color candleColor = na

// 严格按照优先级执行：VSA 巨量/高量排在最前面
if volRatio >= ultraVolMultiplier
    candleColor := ultraColor          // 优先级 1：成交量极度核爆 (蓝)
else if volRatio >= highVolMultiplier
    candleColor := highColor           // 优先级 2：成交量高点放量 (青)
else if is_oi_surge
    candleColor := oiSurgeColor        // 优先级 3：成交量没爆，但 OI 暴增 (黄 - 主力建仓)
else if is_oi_drop
    candleColor := oiDropColor         // 优先级 4：成交量没爆，但 OI 暴减 (紫红 - 散户挤兑)
else
    candleColor := na                  // 无异动，保持原色

barcolor(candleColor, title="异动 K 线终极染色")

// ==========================================
// 5. 早期预警与 VSA 扫损检测
// ==========================================
crossUpTarget = not na(targetHigh) and ta.crossover(high, targetHigh)
crossDownTarget = not na(targetLow) and ta.crossunder(low, targetLow)

if crossUpTarget
    alert("⏱️ 接近猎区: 价格刚刚【向上刺穿】当前目标高点！", alert.freq_once_per_bar)
if crossDownTarget
    alert("⏱️ 接近猎区: 价格刚刚【向下砸穿】当前目标低点！", alert.freq_once_per_bar)

isSweepVol = volume > avgVol * sweepMultiplier
sweepHigh = not na(targetHigh) and high > targetHigh and close < targetHigh and isSweepVol
sweepLow = not na(targetLow) and low < targetLow and close > targetLow and isSweepVol

plotshape(sweepHigh, title="扫损空", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(sweepLow, title="扫损多", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)

if sweepHigh
    alert("⚠️ 扫损确认: 目标高点假突破！放量看跌三角形，做空！", alert.freq_once_per_bar_close)
if sweepLow
    alert("⚠️ 扫损确认: 目标低点假突破！放量看涨三角形，做多！", alert.freq_once_per_bar_close)

// ==========================================
// 6. 反向真突破检测 (Breakout Logic)
// ==========================================
var float lastSweepHighPivot = na
var float lastSweepLowPivot = na

if sweepHigh
    lastSweepHighPivot := high
if sweepLow
    lastSweepLowPivot := low

if isAsiaStart
    lastSweepHighPivot := na
    lastSweepLowPivot := na

breakoutLong = not na(lastSweepHighPivot) and close > lastSweepHighPivot
breakoutShort = not na(lastSweepLowPivot) and close < lastSweepLowPivot

if breakoutLong
    lastSweepHighPivot := na
if breakoutShort
    lastSweepLowPivot := na

plotshape(breakoutLong, title="真突破做多", style=shape.circle, location=location.belowbar, color=color.new(#00BCD4, 0), size=size.small, text="追多", textcolor=color.new(#00d475, 0))
plotshape(breakoutShort, title="真跌破做空", style=shape.circle, location=location.abovebar, color=color.new(#FF9800, 0), size=size.small, text="追空", textcolor=color.new(#FF9800, 0))
````
