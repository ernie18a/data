# indigobigboss

- url: https://www.tradingview.com/script/JWl6PydK/
- type: indicator
- pine_id: PUB;de11a9b1b39a4f8293e73c27e862a17e
- version: 1.0

## Description

厲害

## Source Code

````pine
//@version=6
indicator("indigo揚帆起航", overlay=true, max_labels_count=500)

// ===== Inputs =====
emaFastLen = input.int(12, "EMA 12", minval=1)
ema144Len  = input.int(144, "EMA 144", minval=1)
ema169Len  = input.int(169, "EMA 169", minval=1)
ema576Len  = input.int(576, "EMA 576", minval=1)
ema676Len  = input.int(676, "EMA 676", minval=1)

atrLen    = input.int(14, "ATR Length", minval=1)
atrMult   = input.float(2.0, "SL ATR Multiplier", minval=0.1, step=0.1)

useTrendFilter = input.bool(true, "Use 576/676 Trend Filter")
showLabels     = input.bool(true, "Show Labels")
showSignals    = input.bool(true, "Show Signals")
showSLTP       = input.bool(true, "Show SL / TP")

// ===== EMA =====
ema12  = ta.ema(close, emaFastLen)
ema144 = ta.ema(close, ema144Len)
ema169 = ta.ema(close, ema169Len)
ema576 = ta.ema(close, ema576Len)
ema676 = ta.ema(close, ema676Len)
atr    = ta.atr(atrLen)

// ===== Vegas =====
vegasTop = math.max(ema144, ema169)
vegasBot = math.min(ema144, ema169)

bigTop = math.max(ema576, ema676)
bigBot = math.min(ema576, ema676)

// ===== Trend =====
bullTrend = ema576 > ema676
bearTrend = ema576 < ema676

// ===== Setup 條件 =====
// 做多 setup：價格已跌破 vegas 下緣，但 EMA12 還在 vegas 上方
longSetupBar = low < vegasBot and ema12 > vegasTop and (not useTrendFilter or bullTrend)

// 做空 setup：價格已突破 vegas 上緣，但 EMA12 還在 vegas 下方
shortSetupBar = high > vegasTop and ema12 < vegasBot and (not useTrendFilter or bearTrend)

// ===== 狀態機 =====
var bool waitLongTurn = false
var bool waitShortTurn = false

// 觸發 setup 後，進入等待拐頭狀態
if longSetupBar
    waitLongTurn := true
    waitShortTurn := false

if shortSetupBar
    waitShortTurn := true
    waitLongTurn := false

// ===== 拐頭確認 =====
// 做多：等待 setup 後，出現轉強K
longTurn = waitLongTurn and close > open and close > close[1] and high > high[1]

// 做空：等待 setup 後，出現轉弱K
shortTurn = waitShortTurn and close < open and close < close[1] and low < low[1]

// ===== 最終訊號 =====
longSignal = longTurn
shortSignal = shortTurn

// 出現訊號後，重置等待
if longSignal
    waitLongTurn := false

if shortSignal
    waitShortTurn := false

// 若 EMA12 已經失守 Vegas，取消等待
if ema12 <= vegasTop
    waitLongTurn := false

if ema12 >= vegasBot
    waitShortTurn := false

// ===== Entry / SL / TP =====
longEntry = close
longSL    = longEntry - atr * atrMult
longTP    = longEntry + (longEntry - longSL)   // 1:1

shortEntry = close
shortSL    = shortEntry + atr * atrMult
shortTP    = shortEntry - (shortSL - shortEntry) // 1:1

// ===== Plot =====
plot(ema12, title="EMA 12", color=color.white, linewidth=2)

p144 = plot(ema144, title="EMA 144", color=color.blue, linewidth=2)
p169 = plot(ema169, title="EMA 169", color=color.blue, linewidth=2)
fill(p144, p169, color=color.new(color.blue, 85), title="Vegas 144/169")

p576 = plot(ema576, title="EMA 576", color=color.red, linewidth=2)
p676 = plot(ema676, title="EMA 676", color=color.red, linewidth=2)
fill(p576, p676, color=color.new(color.red, 88), title="Vegas 576/676")

// ===== Signals =====
plotshape(showSignals and longSignal, title="LONG", location=location.belowbar, style=shape.labelup, color=color.blue, text="做多")
plotshape(showSignals and shortSignal, title="SHORT", location=location.abovebar, style=shape.labeldown, color=color.red, text="做空")

// ===== SL / TP =====
plot(showSLTP and longSignal ? longSL : na, title="Long SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(showSLTP and longSignal ? longTP : na, title="Long TP", color=color.green, linewidth=2, style=plot.style_linebr)

plot(showSLTP and shortSignal ? shortSL : na, title="Short SL", color=color.red, linewidth=2, style=plot.style_linebr)
plot(showSLTP and shortSignal ? shortTP : na, title="Short TP", color=color.green, linewidth=2, style=plot.style_linebr)

// ===== Labels =====
if showLabels and longSignal
    label.new(
         bar_index,
         low,
         "做多\nEntry: " + str.tostring(longEntry, format.mintick) +
         "\nSL: " + str.tostring(longSL, format.mintick) +
         "\nTP: " + str.tostring(longTP, format.mintick),
         style=label.style_label_up,
         textcolor=color.white,
         color=color.blue
     )

if showLabels and shortSignal
    label.new(
         bar_index,
         high,
         "做空\nEntry: " + str.tostring(shortEntry, format.mintick) +
         "\nSL: " + str.tostring(shortSL, format.mintick) +
         "\nTP: " + str.tostring(shortTP, format.mintick),
         style=label.style_label_down,
         textcolor=color.white,
         color=color.red
     )

// ===== Alerts =====
alertcondition(longSignal, title="Vegas Pullback Long", message="價格跌破 Vegas，但 EMA12 未跌破，且價格開始往上拐 -> 做多")
alertcondition(shortSignal, title="Vegas Pullback Short", message="價格突破 Vegas，但 EMA12 未突破，且價格開始往下拐 -> 做空")
````
