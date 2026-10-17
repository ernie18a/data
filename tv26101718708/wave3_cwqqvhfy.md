# Wave3

- url: https://www.tradingview.com/script/CwqqvhfY-Wave3/
- type: indicator
- pine_id: PUB;b4aad24ca3554301ad079813158878e5
- version: 1.0

## Description

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
//  波浪收割机 复刻版 V2  [低吸进场 + 分批出场 + 持仓手数 + 浮盈标签]
//  说明:按截图行为还原的「功能等价」复刻版,非原作者源码。
//  V2 相对 V1 的修正:
//    ① 进场改为"低吸"(回调到下轨后反扑),绿三角落在底部,贴近原图
//    ② 数字口径改为"持仓手数/股数"(进场 +N,减仓 -N,离场 -剩余)
//    ③ 减仓信号去重:每一波上涨只在第一次超买回落时减一次
//    ④ 新增持仓期"浮盈"标签(最后一根K线实时显示)
//  挂载:主图 overlay=true
// =============================================================================
indicator("波浪收割机 复刻版V2 [低吸+分批]", shorttitle="波浪收割机V2", overlay=true, max_labels_count=500)

// ─────────────────────────── 输入参数 ───────────────────────────
gMA   = "① 均线"
maType = input.string("EMA", "均线类型", options=["EMA","SMA","WMA"], group=gMA)
len1  = input.int(21,  "均线1 (灰)",      minval=1, group=gMA)
len2  = input.int(34,  "均线2 (浅蓝)",    minval=1, group=gMA)
len3  = input.int(55,  "均线3 (橙/中轴)", minval=1, group=gMA)
len4  = input.int(89,  "均线4 (紫)",      minval=1, group=gMA)
len5  = input.int(120, "均线5 (蓝/趋势)", minval=1, group=gMA)

gCloud = "② 波动率云 (Keltner)"
cloudLen  = input.int(34,  "云中轴周期",        minval=1,  group=gCloud)
cloudMult = input.float(2.0,"云宽 (ATR 倍数)",  minval=0.1, step=0.1, group=gCloud)
atrLen    = input.int(20,  "ATR 周期",          minval=1,  group=gCloud)
showCloud = input.bool(true, "显示云填充", group=gCloud)

gSig = "③ 信号"
dipLook   = input.int(10, "下轨回看(几根内触碰过下轨)", minval=1, group=gSig)
rsiLen    = input.int(14, "动量 RSI 周期",     minval=2, group=gSig)
obLevel   = input.int(70, "超买阈值(减仓)",    group=gSig)
buyRsiMax = input.int(65, "进场时 RSI 上限",   group=gSig)
failBars  = input.int(5,  "突破失败判定K线数", minval=1, group=gSig)

gPos = "④ 仓位 / 标签"
capital   = input.float(25000, "假设本金(用于算手数)", minval=1, group=gPos)
reducePct = input.int(50, "每次减仓比例 %",  minval=1, maxval=99, group=gPos)
showFloat = input.bool(true, "显示持仓浮盈标签", group=gPos)

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
basis  = f_ma(close, cloudLen)
atrv   = ta.atr(atrLen)
upBand = basis + cloudMult * atrv
dnBand = basis - cloudMult * atrv

pUp = plot(upBand, "云上轨", color=color.new(color.red,  20), style=plot.style_circles)
pDn = plot(dnBand, "云下轨", color=color.new(color.green,20), style=plot.style_circles)
fill(pUp, pDn, color = showCloud ? color.new(color.teal, 90) : na, title="云填充")

// ─────────────────────────── 辅助量 ───────────────────────────
rsi      = ta.rsi(close, rsiLen)
dippedLo = ta.lowest(low, dipLook)[1] <= dnBand[1]   // 近 dipLook 根内是否触碰过下轨

// ─────────────────────────── 状态变量 ───────────────────────────
var int   pos        = 0       // 0=空仓, 1=持多
var float entryP     = na
var int   entryBar   = na
var float posQty     = na      // 当前持仓手数
var bool  reducedLeg = false   // 本轮上涨是否已减过仓(去重)
var label flLbl      = na

// ─────────────────────────── 信号(序列) ───────────────────────────
// 进场:回调到下轨后,收盘重新站上中轴(低吸反扑),且未超买、空仓
rawEntry    = pos == 0 and ta.crossover(close, basis) and dippedLo and rsi < buyRsiMax

// 全仓离场:持仓中,收盘跌破中轴均线(均线3)
fullExitSig = pos == 1 and ta.crossunder(close, ma3)

// 突破失败早退:进场后 failBars 根内就跌破成本且回到中轴下方
breakFailSig= pos == 1 and (bar_index - entryBar <= failBars) and close < entryP and close < basis

closeAll    = fullExitSig or breakFailSig

// 超买回落减仓:持仓中,RSI 从超买区下穿,且本轮还没减过、且不是要全平
reduceSig   = pos == 1 and ta.crossunder(rsi, obLevel) and not reducedLeg and not closeAll

// ─────────────────────────── 状态机 + 数字标签 ───────────────────────────
if rawEntry
    pos        := 1
    entryP     := close
    entryBar   := bar_index
    posQty     := math.max(1, math.round(capital / close))
    reducedLeg := false
    label.new(bar_index, low, "Wave3\n+" + str.tostring(posQty, "0"),
              style=label.style_label_up, color=color.new(color.green, 10),
              textcolor=color.white, size=size.small)
else if closeAll
    txt = "全仓离场 -" + str.tostring(posQty, "0")
    txt2 = breakFailSig ? "突破失败早退 -" + str.tostring(posQty, "0") : txt
    label.new(bar_index, high, txt2, style=label.style_label_down,
              color=color.new(color.fuchsia, 10), textcolor=color.white, size=size.small)
    pos        := 0
    posQty     := na
    entryP     := na
    reducedLeg := false
else if reduceSig
    cut = math.max(1, math.round(posQty * reducePct / 100))
    posQty     := posQty - cut
    reducedLeg := true
    label.new(bar_index, high, "超买回落减仓 -" + str.tostring(cut, "0"),
              style=label.style_label_down, color=color.new(color.orange, 10),
              textcolor=color.white, size=size.small)

// 价格回到中轴下方=一波结束,重新允许下次减仓
if pos == 1 and close < basis
    reducedLeg := false

// ─────────────────────────── 信号图形 ───────────────────────────
plotshape(rawEntry, title="Wave3进场", style=shape.triangleup,
          location=location.belowbar, color=color.new(color.green, 0), size=size.small)

plotshape(reduceSig, title="减仓", style=shape.flag,
          location=location.abovebar, color=color.new(color.orange, 0), size=size.tiny, text="减仓")

plotshape(fullExitSig and not breakFailSig, title="全仓离场", style=shape.arrowdown,
          location=location.abovebar, color=color.new(color.fuchsia, 0), size=size.small)

// ─────────────────────────── 持仓浮盈标签(只在最后一根) ───────────────────────────
if barstate.islast
    label.delete(flLbl)
    if pos == 1 and showFloat
        fp = posQty * (close - entryP)
        flLbl := label.new(bar_index, low,
                  "浮盈 " + (fp >= 0 ? "+" : "") + str.tostring(fp, "0.0") +
                  "  (持 " + str.tostring(posQty, "0") + ")",
                  style=label.style_label_up,
                  color=fp >= 0 ? color.new(color.green, 0) : color.new(color.red, 0),
                  textcolor=color.white, size=size.small)

// ─────────────────────────── 提醒 ───────────────────────────
alertcondition(rawEntry,  title="进场", message="波浪收割机V2:低吸进场")
alertcondition(reduceSig, title="减仓", message="波浪收割机V2:超买减仓")
alertcondition(closeAll,  title="离场", message="波浪收割机V2:全仓离场")
````
