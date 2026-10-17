# Wave3

- url: https://www.tradingview.com/script/Cfhw9mk2-Wave3/
- type: indicator
- pine_id: PUB;a9ccb7d4d2d84a038671e628befbe73c
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
//  波浪收割机 复刻版 V3  [通道反转:贴下轨买 / 贴上轨减 / 破中轴平]
//  说明:按截图行为还原的「功能等价」复刻版,非原作者源码。
//  V3 相对 V2 的修正(让信号贴近原版的"通道剥头皮"打法):
//    ① 进场 = 收盘跌破下轨后又重新站上(低吸反弹)→ 绿三角落在下轨
//    ② 减仓 = 价格触/破上轨(分批减)→ 橙旗落在上轨/顶部
//    ③ 全仓离场 = 收盘跌破中轴 → 见顶回落即平
//    ④ 通道收紧到 ATR×1.3,更贴价格,信号密度更高
//    ⑤ 数字=持仓手数(进 +N / 减 -N / 平 -剩余);持仓中显示浮盈
//  挂载:主图 overlay=true
// =============================================================================
indicator("波浪收割机 复刻版V3 [通道反转]", shorttitle="波浪收割机V3", overlay=true, max_labels_count=500)

// ─────────────────────────── 输入 ───────────────────────────
gMA   = "① 均线"
maType = input.string("EMA", "均线类型", options=["EMA","SMA","WMA"], group=gMA)
len1  = input.int(13,  "均线1 (灰/快)",   minval=1, group=gMA)
len2  = input.int(21,  "均线2 (浅蓝)",    minval=1, group=gMA)
len3  = input.int(34,  "均线3 (橙/中轴)", minval=1, group=gMA)
len4  = input.int(55,  "均线4 (紫)",      minval=1, group=gMA)
len5  = input.int(89,  "均线5 (蓝/趋势)", minval=1, group=gMA)

gCloud = "② 通道云 (Keltner, 收紧)"
cloudLen  = input.int(20,  "通道中轴周期",     minval=1,  group=gCloud)
cloudMult = input.float(1.3,"通道宽 (ATR倍数)", minval=0.1, step=0.1, group=gCloud)
atrLen    = input.int(14,  "ATR 周期",         minval=1,  group=gCloud)
showCloud = input.bool(true, "显示云填充", group=gCloud)

gSig = "③ 信号"
failBars  = input.int(4,  "突破失败判定K线数", minval=1, group=gSig)
trendFilt = input.bool(false, "仅在趋势线上方进场(更保守)", group=gSig)

gPos = "④ 仓位 / 标签"
capital   = input.float(25000, "假设本金(算手数)", minval=1, group=gPos)
reducePct = input.int(50, "每次减仓比例 %", minval=1, maxval=99, group=gPos)
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

// ─────────────────────────── 通道云 ───────────────────────────
basis  = f_ma(close, cloudLen)
atrv   = ta.atr(atrLen)
upBand = basis + cloudMult * atrv
dnBand = basis - cloudMult * atrv

pUp = plot(upBand, "上轨", color=color.new(color.red,  20), style=plot.style_circles)
pDn = plot(dnBand, "下轨", color=color.new(color.green,20), style=plot.style_circles)
fill(pUp, pDn, color = showCloud ? color.new(color.teal, 90) : na, title="云填充")

// ─────────────────────────── 状态变量 ───────────────────────────
var int   pos      = 0
var float entryP   = na
var int   entryBar = na
var float posQty   = na
var label flLbl    = na

// ─────────────────────────── 信号(序列) ───────────────────────────
trendOK    = not trendFilt or close > ma5
// 进场:收盘从下轨之下重新站上(低吸反弹),空仓
bandBuy    = pos == 0 and ta.crossover(close, dnBand) and trendOK
// 全仓离场:持仓中收盘跌破中轴
fullExit   = pos == 1 and ta.crossunder(close, ma3)
// 突破失败早退:进场后 failBars 根内跌破下轨且亏损
breakFail  = pos == 1 and (bar_index - entryBar <= failBars) and close < entryP and close < dnBand
closeAll   = fullExit or breakFail
// 超买减仓:价格上穿上轨,且还有仓、还有量可减、且不是要全平
reduceSig  = pos == 1 and ta.crossover(high, upBand) and posQty > 1 and not closeAll

// ─────────────────────────── 状态机 + 标签 ───────────────────────────
if bandBuy
    pos      := 1
    entryP   := close
    entryBar := bar_index
    posQty   := math.max(1, math.round(capital / close))
    label.new(bar_index, low, "Wave3\n+" + str.tostring(posQty, "0"),
              style=label.style_label_up, color=color.new(color.green, 10),
              textcolor=color.white, size=size.small)
else if closeAll
    txt = breakFail ? "突破失败早退 -" + str.tostring(posQty, "0") : "全仓离场 -" + str.tostring(posQty, "0")
    label.new(bar_index, high, txt, style=label.style_label_down,
              color=color.new(color.fuchsia, 10), textcolor=color.white, size=size.small)
    pos := 0
    posQty := na
    entryP := na
else if reduceSig
    cut = math.max(1, math.round(posQty * reducePct / 100))
    posQty := posQty - cut
    label.new(bar_index, high, "超买回落减仓 -" + str.tostring(cut, "0"),
              style=label.style_label_down, color=color.new(color.orange, 10),
              textcolor=color.white, size=size.small)

// ─────────────────────────── 信号图形 ───────────────────────────
plotshape(bandBuy, title="进场", style=shape.triangleup, location=location.belowbar,
          color=color.new(color.green, 0), size=size.small)
plotshape(reduceSig, title="减仓", style=shape.flag, location=location.abovebar,
          color=color.new(color.orange, 0), size=size.tiny, text="减仓")
plotshape(fullExit and not breakFail, title="离场", style=shape.arrowdown, location=location.abovebar,
          color=color.new(color.fuchsia, 0), size=size.small)

// ─────────────────────────── 持仓浮盈标签 ───────────────────────────
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
alertcondition(bandBuy,   title="进场", message="波浪收割机V3:贴下轨低吸进场")
alertcondition(reduceSig, title="减仓", message="波浪收割机V3:触上轨减仓")
alertcondition(closeAll,  title="离场", message="波浪收割机V3:跌破中轴离场")
````
