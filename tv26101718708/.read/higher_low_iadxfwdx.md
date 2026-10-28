# Higher Low

- url: https://www.tradingview.com/script/iaDXfwDX/
- type: indicator
- pine_id: PUB;31ee18511d0640c797c3d2af3461a3c6
- version: 2.0

## Description

Higher Low Higher Low Higher Low Higher Low Higher Low

## Source Code

````pine
//@version=5
indicator("Higher Low 確立通知器 (36.8)", overlay=true)

// --- 1. 基礎數據 ---
s20 = ta.sma(close, 20)
v5  = ta.sma(volume, 5)

// --- 2. 尋找前一個有效的波段低點 (Swing Low) ---
// 這裡用較小的左側確認，增加靈敏度
leftLen = 10
rightLen = 2
lb = ta.pivotlow(low, leftLen, rightLen)

var float prev_swing_low = na
if not na(lb)
    prev_swing_low := lb

// --- 3. 判斷「確立」的瞬間 ---
// 條件 A：當前價格高於前一個波段低點 (確保是 Higher Low 結構)
// 條件 B：股價回踩 s20 附近 (代表回調到位)
// 條件 C：今日收陽線 且 量大於昨天 (代表買盤介入，確立低點)
// 條件 D：價格不能偏離 s20 太遠 (防止已經漲高)

near_s20 = close > s20 and close < s20 * 1.05 // 在生命線上方 5% 以內
rebound  = close > open and volume > volume[1]
is_hl_confirmed = (close > prev_swing_low) and near_s20 and rebound and not na(prev_swing_low)

// --- 4. 輸出與顯示 ---
plot(is_hl_confirmed ? 1 : 0, title="HL_Confirmed", display=display.none)

plotshape(is_hl_confirmed, title="HL 確立", style=shape.labelup, location=location.belowbar, color=color.new(#2196f3, 0), text="HL確立", textcolor=color.white, size=size.normal)

// 畫出前低支撐線，方便目測
plot(prev_swing_low, "前波低點支撐", color=color.new(color.gray, 50), style=plot.style_linebr)
````
