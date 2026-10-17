# Wave reaper copy

- url: https://www.tradingview.com/script/7hUVLKT8-Wave-reaper-copy/
- type: indicator
- pine_id: PUB;9fef3be2a7484b38af0f71ff74630bb1
- version: 1.0

## Description

0602 Wave reaper copy wg
5 moving averages + Keltner Volatility Cloud (red/green dots match the dashed lines in the original chart + light fill). Here's how the signals work:
Green triangle "Wave3" = uptrend, close breaks recent high + RSI > 50 + price closes above the cloud's upper band
Blue arrow = pullback bounce when price dips to the cloud's lower band and gets bought back up
Magenta down arrow "Full exit" = price breaks below the middle moving average
Orange flag "Scale down" = RSI drops back out of the overbought zone
"Early exit for failed breakout" = price drops back below the upper band within N bars after entering on Wave3
When you exit a trade, the var state machine calculates the profit/loss in pips for that trade, and slaps it right on the label (just like those +606 / -721 numbers on the original chart)

## Source Code

````pine
//@version=5
// =============================================================================
//  波浪收割机 复刻版 V1  [均线 + 波动率云 + 进场/出场信号]
//  说明:这是按截图行为还原的「功能等价」复刻版,不是原作者源码。
//        所有参数都暴露成输入,方便你自己微调到和原图一致。
//  挂载方式:这是主图指标(overlay=true),直接叠加在K线上。
// =============================================================================
indicator("波浪收割机 复刻版 [进场+出场]", shorttitle="波浪收割机V1", overlay=true, max_labels_count=500)

// ─────────────────────────── 输入参数 ───────────────────────────
gMA   = "① 均线"
maType = input.string("EMA", "均线类型", options=["EMA","SMA","WMA"], group=gMA)
len1  = input.int(21,  "均线1 (灰)",      minval=1, group=gMA)
len2  = input.int(34,  "均线2 (浅蓝)",    minval=1, group=gMA)
len3  = input.int(55,  "均线3 (橙/中轴)", minval=1, group=gMA)
len4  = input.int(89,  "均线4 (紫)",      minval=1, group=gMA)
len5  = input.int(120, "均线5 (蓝/趋势)", minval=1, group=gMA)

gCloud = "② 波动率云 (Keltner 风格)"
cloudLen  = input.int(34,  "云中轴周期",        minval=1,  group=gCloud)
cloudMult = input.float(2.0,"云宽 (ATR 倍数)",  minval=0.1, step=0.1, group=gCloud)
atrLen    = input.int(20,  "ATR 周期",          minval=1,  group=gCloud)
showCloud = input.bool(true, "显示云填充", group=gCloud)

gSig = "③ 信号"
brkLook  = input.int(20, "突破回看(摆动高/低)", minval=2, group=gSig)
rsiLen   = input.int(14, "动量 RSI 周期",        minval=2, group=gSig)
obLevel  = input.int(70, "超买阈值",             group=gSig)
osLevel  = input.int(30, "超卖阈值",             group=gSig)
failBars = input.int(5,  "突破失败判定K线数",     minval=1, group=gSig)
showPnL  = input.bool(true, "出场时显示盈亏点数", group=gSig)

// ─────────────────────────── 均线 ───────────────────────────
f_ma(src, l) =>
    maType == "SMA" ? ta.sma(src, l) : maType == "WMA" ? ta.wma(src, l) : ta.ema(src, l)

ma1 = f_ma(close, len1)
ma2 = f_ma(close, len2)
ma3 = f_ma(close, len3)
ma4 = f_ma(close, len4)
ma5 = f_ma(close, len5)

plot(ma1, "均线1", color=color.new(color.gray,   0), linewidth=1)
plot(ma2, "均线2", color=color.new(color.aqua,   0), linewidth=1)
plot(ma3, "均线3", color=color.new(color.orange, 0), linewidth=2)
plot(ma4, "均线4", color=color.new(color.purple, 0), linewidth=1)
plot(ma5, "趋势线", color=color.new(color.blue,  0), linewidth=3)

// ─────────────────────────── 波动率云 ───────────────────────────
basis = f_ma(close, cloudLen)
atrv  = ta.atr(atrLen)
upBand = basis + cloudMult * atrv
dnBand = basis - cloudMult * atrv

// 用圆点样式近似原图的红/绿虚线
pUp = plot(upBand, "云上轨", color=color.new(color.red,  20), style=plot.style_circles)
pDn = plot(dnBand, "云下轨", color=color.new(color.green,20), style=plot.style_circles)
fill(pUp, pDn, color = showCloud ? color.new(color.teal, 90) : na, title="云填充")

// ─────────────────────────── 计算辅助量 ───────────────────────────
rsi      = ta.rsi(close, rsiLen)
swingHi  = ta.highest(high, brkLook)[1]   // 不含当前K线的近期高点
swingLo  = ta.lowest(low,  brkLook)[1]
trendUp  = close > ma5
trendDn  = close < ma5

// ─────────────────────────── 信号条件 ───────────────────────────
// 【进场1】Wave 3 突破:上升趋势中收盘突破近期摆动高点,且动量配合
wave3 = trendUp and close > swingHi and rsi > 50 and close > upBand

// 【进场2】回调反扑(蓝色上箭头):跌到下轨被买回 + 非超买
buyDip = (low <= dnBand) and close > open and rsi < (osLevel + 20) and trendUp

// 【出场A】全仓离场:收盘跌破中轴均线
exitFull = ta.crossunder(close, ma3)

// 【出场B】超买回落减仓:RSI 从超买区回落
exitOB = ta.crossunder(rsi, obLevel)

// ─────────────────────────── 持仓状态机 ───────────────────────────
// 指标里用 var 模拟一个多头仓位,用来:① 只在持仓时画出场 ② 出场时算盈亏点数
var int   pos       = 0      // 0=空仓, 1=持多
var float entryP    = na
var int   entryBar  = na
var bool  enteredW3 = false  // 本笔是否由 Wave3 突破进场(用于判断突破失败)

longEntry = (wave3 or buyDip) and pos == 0

// 【出场C】突破失败早退:Wave3 进场后 failBars 根内又跌回上轨之下
breakFail = pos == 1 and enteredW3 and (bar_index - entryBar <= failBars) and close < upBand

exitAny = pos == 1 and (exitFull or breakFail)

// 状态切换 + 盈亏标签
if longEntry
    pos       := 1
    entryP    := close
    entryBar  := bar_index
    enteredW3 := wave3

if exitAny
    pts = close - entryP
    if showPnL
        txt = (pts >= 0 ? "+" : "") + str.tostring(pts, format.mintick)
        lblTxt = breakFail ? "突破失败早退 " + txt : "全仓离场 " + txt
        label.new(bar_index, high, lblTxt, style=label.style_label_down,
                   color=color.new(color.fuchsia, 20), textcolor=color.white, size=size.small)
    pos       := 0
    entryP    := na
    enteredW3 := false

// ─────────────────────────── 画信号 ───────────────────────────
// 绿三角:Wave3 突破进场
plotshape(longEntry and wave3, title="Wave3突破",
          style=shape.triangleup, location=location.belowbar,
          color=color.new(color.green, 0), size=size.small, text="Wave3")

// 蓝上箭头:回调反扑进场
plotshape(longEntry and not wave3, title="回调反扑",
          style=shape.arrowup, location=location.belowbar,
          color=color.new(color.blue, 0), size=size.tiny)

// 品红下箭头:全仓离场
plotshape(exitAny and exitFull and not breakFail, title="全仓离场",
          style=shape.arrowdown, location=location.abovebar,
          color=color.new(color.fuchsia, 0), size=size.small)

// 顶部橙色「减仓」旗标:超买回落
plotshape(exitOB and trendUp, title="减仓",
          style=shape.flag, location=location.abovebar,
          color=color.new(color.orange, 0), size=size.tiny, text="减仓")

// ─────────────────────────── 提醒 ───────────────────────────
alertcondition(longEntry,  title="进场信号", message="波浪收割机:进场")
alertcondition(exitAny,    title="出场信号", message="波浪收割机:出场")
alertcondition(exitOB,     title="减仓信号", message="波浪收割机:超买减仓")
````
