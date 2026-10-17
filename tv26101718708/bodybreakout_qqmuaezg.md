# BODY_BREAKOUT

- url: https://www.tradingview.com/script/qQmUAEZg/
- type: indicator
- pine_id: PUB;9984fc02825b44858deac779cb985681
- version: 4.0

## Description

BODY_BREAKOUT Alert when K bar eat previous opposite K bar

## Source Code

````pine
//@version=6
indicator("BODY_BREAKOUT 實體突破提醒", overlay=true, max_labels_count=500)

// 註：歷史 K 棒無盤中 tick 資料，僅能依收盤價判定；即時 K 棒才會盤中不等收盤即時觸發。

// ===== 偵測時間窗：美東時間每日 02:30–09:00 ET =====
// 錨定美東（NQ 所屬交易所時區）；以 America/New_York 計算，Pine 自動處理 EST/EDT 日光節約
// 等效台北時間：夏令 14:30–21:00、冬令 15:30–22:00（隨美國 DST 自動切換，免改參數）
// 依偏好硬編碼為 const，不開放 input，避免 chart instance 數值漂移
WIN_START = 2 * 60 + 30
WIN_END   = 9 * 60
MIN_LABEL_PTS = 55.0
etMinOfDay = hour(time, "America/New_York") * 60 + minute(time, "America/New_York")
inWindow = etMinOfDay >= WIN_START and etMinOfDay <= WIN_END

// ===== 當下 K 棒方向（即時，不等收盤）=====
isBull = close > open
isBear = close < open

// ===== 追蹤最後一根「下跌／上漲 K 棒」的實體端點 =====
// 下跌 K 棒實體最高 = max(open,close) = 開盤價；上漲 K 棒實體最低 = min(open,close) = 開盤價
var float lastBearBodyHigh = na
var float lastBullBodyLow  = na

// ===== 突破條件（比對上一根收盤前的追蹤值；僅時間窗內偵測）=====
bullActive = inWindow and isBull and not na(lastBearBodyHigh) and close > lastBearBodyHigh
bearActive = inWindow and isBear and not na(lastBullBodyLow)  and close < lastBullBodyLow
bullReverseWickPts = close - low
bearReverseWickPts = high - close

// ===== 一根 K 棒總共只提醒一次、且只在「突破當下」觸發 =====
// varip：即時 K 棒多 tick 之間保留 latch（var 每 tick 會被 rollback，無法跨 tick latch）
varip bool firedThisBar = false
varip bool firedBull = false
varip bool firedBear = false
if barstate.isnew
    firedThisBar := false
    firedBull := false
    firedBear := false
bullEvent = bullActive and not bullActive[1] and not firedThisBar
bearEvent = bearActive and not bearActive[1] and not firedThisBar
if bullEvent
    firedThisBar := true
    firedBull := true
if bearEvent
    firedThisBar := true
    firedBear := true

// ===== 發出提醒 =====
if bullEvent
    alert("BODY_BREAKOUT: 上漲突破 — 現價突破最後一根下跌K棒實體高 " + str.tostring(lastBearBodyHigh, format.mintick) + " on " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)
if bearEvent
    alert("BODY_BREAKOUT: 下跌跌破 — 現價跌破最後一根上漲K棒實體低 " + str.tostring(lastBullBodyLow, format.mintick) + " on " + syminfo.ticker + " @ " + str.tostring(close, format.mintick), alert.freq_once_per_bar)

// ===== 標記反向針尖距離 =====
if bullEvent and bullReverseWickPts > MIN_LABEL_PTS
    label.new(bar_index, low, str.tostring(bullReverseWickPts, format.mintick), style=label.style_label_up, textcolor=color.white, color=color.new(color.green, 0), size=size.small, yloc=yloc.price)
if bearEvent and bearReverseWickPts > MIN_LABEL_PTS
    label.new(bar_index, high, str.tostring(bearReverseWickPts, format.mintick), style=label.style_label_down, textcolor=color.white, color=color.new(color.red, 0), size=size.small, yloc=yloc.price)

// ===== 更新追蹤值（務必在條件判斷之後，避免把當根折入門檻）=====
if barstate.isconfirmed
    if isBear
        lastBearBodyHigh := math.max(open, close)
    else if isBull
        lastBullBodyLow := math.min(open, close)

// ===== 視覺化 =====
plotshape(firedBull, title="上漲突破", style=shape.triangleup,   location=location.belowbar, color=color.new(color.green, 0), size=size.small)
plotshape(firedBear, title="下跌跌破", style=shape.triangledown, location=location.abovebar, color=color.new(color.red, 0),   size=size.small)
plot(lastBearBodyHigh, title="最後下跌K棒實體高", color=color.new(color.red, 55),   style=plot.style_stepline)
plot(lastBullBodyLow,  title="最後上漲K棒實體低", color=color.new(color.green, 55), style=plot.style_stepline)
bgcolor(inWindow ? color.new(color.blue, 92) : na, title="偵測時間窗")
````
