# AC Bias Filter

- url: https://www.tradingview.com/script/YFbJdxHH-AC-Bias-Filter/
- type: indicator
- pine_id: PUB;d65b0718e3294b8e9e60cdb0b5b6d3d2
- version: 1.0

## Description

This script is a systematic, trend-following quantitative strategy developed in Pine Script v6, specifically optimized for trading Gold (XAU/USD). It utilizes the classic dual exponential moving average (EMA) crossover system to capture sustained market impulses while incorporating an automatic position-reversal mechanism to ensure constant market alignment during macro trends.

## Source Code

````pine
//@version=6
indicator("黃金大盤多空偏向儀 (Bias Filter)", overlay=true)

// ==========================================
// 1. 參數設定 (使用經典的 200 EMA 作為大趨勢 Bias 分水嶺)
// ==========================================
biasLen = input.int(200, title="【大趨勢 Bias 均線長度】(預設 200 EMA)")
showBackground = input.bool(true, title="是否顯示背景多空顏色？")
showDashboard = input.bool(true, title="是否顯示右上角風向儀儀表板？")

// ==========================================
// 2. 計算 Bias 均線
// ==========================================
biasMA = ta.ema(close, biasLen)

// 繪製 200 EMA 趨勢線（粗線）
plot(biasMA, color=color.new(color.purple, 30), title="200 EMA 趨勢生命線", linewidth=3)

// ==========================================
// 3. 判斷多空偏向 (Bias)
// ==========================================
// 價格在 200 EMA 之上 = 偏多 (Bullish Bias)
// 價格在 200 EMA 之下 = 偏空 (Bearish Bias)
isBullishBias = close > biasMA
isBearishBias = close < biasMA

// ==========================================
// 4. 背景顏色渲染
// ==========================================
bgColor = isBullishBias ? color.new(color.green, 93) : (isBearishBias ? color.new(color.red, 93) : color.new(color.gray, 90))
bgcolor(showBackground ? bgColor : na, title="Bias 背景顏色")

// ==========================================
// 5. 右上角風向儀儀表板 (Dashboard)
// ==========================================
var table infoTable = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if (showDashboard and barstate.islast)
    // 標題欄
    table.cell(infoTable, 0, 0, "黃金市場風向", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    table.cell(infoTable, 1, 0, "目前 Bias 偏向", text_color=color.white, text_size=size.small, bgcolor=color.gray)
    
    // 數據欄
    if (isBullishBias)
        table.cell(infoTable, 0, 1, "K線在200EMA上方", text_color=color.green, text_size=size.small)
        table.cell(infoTable, 1, 1, "🟢 強勢多頭 (BIAS LONG)", text_color=color.green, text_size=size.small)
    else if (isBearishBias)
        table.cell(infoTable, 0, 1, "K線在200EMA下方", text_color=color.red, text_size=size.small)
        table.cell(infoTable, 1, 1, "🔴 強勢空頭 (BIAS SHORT)", text_color=color.red, text_size=size.small)
````
