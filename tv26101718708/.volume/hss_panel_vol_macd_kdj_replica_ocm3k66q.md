# HSS Panel: VOL + MACD + KDJ Replica

- url: https://www.tradingview.com/script/OCM3K66Q/
- type: indicator
- pine_id: PUB;824ffd6a5bc5420bbc1fec59cc656c2d
- version: 1.0

## Description

个人测试

## Source Code

````pine
//@version=6
indicator("HSS Panel: VOL + MACD + KDJ Replica", shorttitle="HSS_PANEL_VMK_R", overlay=false)

//====================================================
// 参数
//====================================================
groupVol = "VOL"
volMa1Len  = input.int(5, "VOL MA1", minval=1, group=groupVol)
volMa2Len  = input.int(10, "VOL MA2", minval=1, group=groupVol)
volNormLen = input.int(120, "VOL归一化长度", minval=20, group=groupVol)

groupMacd = "MACD"
macdFastLen   = input.int(12, "Fast", minval=1, group=groupMacd)
macdSlowLen   = input.int(26, "Slow", minval=1, group=groupMacd)
macdSignalLen = input.int(9, "Signal", minval=1, group=groupMacd)
macdNormLen   = input.int(120, "MACD归一化长度", minval=20, group=groupMacd)

groupKdj = "KDJ"
kdjLen   = input.int(9, "Length", minval=1, group=groupKdj)
kSmooth  = input.int(3, "K Smooth", minval=1, group=groupKdj)
dSmooth  = input.int(3, "D Smooth", minval=1, group=groupKdj)

groupView = "显示"
showGuides  = input.bool(true, "显示KDJ参考线", group=groupView)
showBgBands = input.bool(false, "显示分区背景", group=groupView)

//====================================================
// 固定分区范围
//====================================================
float volTop  = 100.0
float volBot  = 72.0

float macdTop = 66.0
float macdBot = 34.0
float macdMid = 50.0
float macdAmp = (macdTop - macdBot) * 0.5

float kdjTop  = 28.0
float kdjBot  = 0.0

//====================================================
// VOL
//====================================================
vol = volume
volMa1 = ta.sma(vol, volMa1Len)
volMa2 = ta.sma(vol, volMa2Len)

volRefRaw = ta.highest(math.max(vol, math.max(volMa1, volMa2)), volNormLen)
volRef = volRefRaw == 0.0 ? 1.0 : volRefRaw

volY    = volBot + vol    / volRef * (volTop - volBot)
volMa1Y = volBot + volMa1 / volRef * (volTop - volBot)
volMa2Y = volBot + volMa2 / volRef * (volTop - volBot)

volColor = close >= open ? color.rgb(40, 200, 185) : color.rgb(225, 85, 85)

//====================================================
// MACD
//====================================================
dif = ta.ema(close, macdFastLen) - ta.ema(close, macdSlowLen)
dea = ta.ema(dif, macdSignalLen)
macdHist = (dif - dea) * 2.0

macdRef1 = ta.highest(math.abs(dif), macdNormLen)
macdRef2 = ta.highest(math.abs(dea), macdNormLen)
macdRef3 = ta.highest(math.abs(macdHist), macdNormLen)
macdRefRaw = math.max(macdRef1, math.max(macdRef2, macdRef3))
macdRef = macdRefRaw == 0.0 ? 1.0 : macdRefRaw

difY  = macdMid + dif      / macdRef * macdAmp
deaY  = macdMid + dea      / macdRef * macdAmp
histY = macdMid + macdHist / macdRef * macdAmp

macdColor = macdHist >= 0 ? color.rgb(40, 200, 185) : color.rgb(225, 85, 85)

//====================================================
// KDJ
//====================================================
ll = ta.lowest(low, kdjLen)
hh = ta.highest(high, kdjLen)
rsv = hh == ll ? 50.0 : (close - ll) / (hh - ll) * 100.0

K = ta.sma(rsv, kSmooth)
D = ta.sma(K, dSmooth)
J = 3.0 * K - 2.0 * D

kY = kdjBot + (K + 20.0) / 140.0 * (kdjTop - kdjBot)
dY = kdjBot + (D + 20.0) / 140.0 * (kdjTop - kdjBot)
jY = kdjBot + (J + 20.0) / 140.0 * (kdjTop - kdjBot)

k20Y = kdjBot + 40.0  / 140.0 * (kdjTop - kdjBot)
k50Y = kdjBot + 70.0  / 140.0 * (kdjTop - kdjBot)
k80Y = kdjBot + 100.0 / 140.0 * (kdjTop - kdjBot)

//====================================================
// 背景分区
//====================================================
bgVolTopPlot  = plot(showBgBands ? volTop  : na, title="BG_VOL_TOP",  color=color.new(color.white, 100), display=display.none)
bgVolBotPlot  = plot(showBgBands ? volBot  : na, title="BG_VOL_BOT",  color=color.new(color.white, 100), display=display.none)
bgMacdTopPlot = plot(showBgBands ? macdTop : na, title="BG_MACD_TOP", color=color.new(color.white, 100), display=display.none)
bgMacdBotPlot = plot(showBgBands ? macdBot : na, title="BG_MACD_BOT", color=color.new(color.white, 100), display=display.none)
bgKdjTopPlot  = plot(showBgBands ? kdjTop  : na, title="BG_KDJ_TOP",  color=color.new(color.white, 100), display=display.none)
bgKdjBotPlot  = plot(showBgBands ? kdjBot  : na, title="BG_KDJ_BOT",  color=color.new(color.white, 100), display=display.none)

fill(bgVolTopPlot, bgVolBotPlot, color=color.new(color.gray, 96), title="VOL_BG")
fill(bgMacdTopPlot, bgMacdBotPlot, color=color.new(color.gray, 96), title="MACD_BG")
fill(bgKdjTopPlot, bgKdjBotPlot, color=color.new(color.gray, 96), title="KDJ_BG")

//====================================================
// VOL 绘制
//====================================================
pVolBase = plot(volBot, title="VOL_BASE", color=color.new(color.white, 100), display=display.none)
pVolTop  = plot(volY, title="VOL_BAR", color=color.new(color.white, 100), style=plot.style_columns)
fill(pVolBase, pVolTop, color=color.new(volColor, 0), title="VOL_FILL")

plot(volMa1Y, title="VOL_MA5", color=color.rgb(215, 215, 215), linewidth=1)
plot(volMa2Y, title="VOL_MA10", color=color.rgb(230, 205, 70), linewidth=1)

//====================================================
// MACD 绘制
//====================================================
pMacdMid = plot(macdMid, title="MACD_MID", color=color.new(color.gray, 88), linewidth=1)
pMacdTop = plot(histY, title="MACD_HIST", color=color.new(color.white, 100), style=plot.style_columns)
fill(pMacdMid, pMacdTop, color=color.new(macdColor, 0), title="MACD_FILL")

plot(difY, title="DIF", color=color.rgb(215, 215, 215), linewidth=1)
plot(deaY, title="DEA", color=color.rgb(230, 205, 70), linewidth=1)

//====================================================
// KDJ 绘制
//====================================================
plot(showGuides ? k20Y : na, title="KDJ20", color=color.new(color.gray, 78), linewidth=1)
plot(showGuides ? k50Y : na, title="KDJ50", color=color.new(color.gray, 85), linewidth=1)
plot(showGuides ? k80Y : na, title="KDJ80", color=color.new(color.gray, 78), linewidth=1)

plot(kY, title="K", color=color.rgb(230, 205, 70), linewidth=1)
plot(dY, title="D", color=color.rgb(215, 215, 215), linewidth=1)
plot(jY, title="J", color=color.rgb(220, 75, 200), linewidth=1)
````
