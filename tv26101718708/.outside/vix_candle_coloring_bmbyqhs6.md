# VIX Candle Coloring

- url: https://www.tradingview.com/script/BMByQhs6/
- type: indicator
- pine_id: PUB;a31fdf48c7364bbbbd431331d089a56a
- version: 1.0

## Description

Visualize market fear and greed at a glance — directly on your price chart.
This indicator overlays CBOE VIX (Volatility Index) sentiment levels onto your candlesticks by dynamically recoloring each candle based on the prevailing VIX closing value. Instead of switching between charts, you can instantly read market anxiety from the color of the candles themselves.

🎨 Color Zones
🔴 VIX ≥ 50 — Extreme Fear / Market Panic
🟠 VIX 30–49 — High Fear / Elevated Volatility
🟡 VIX 25–29 — Moderate Fear / Caution Zone
🔵 VIX 20–24 — Calm / Stable Market
🟢 VIX < 20 — Optimism / Low Volatility

⚙️ How It Works
The script fetches the real-time VIX close via request.security("CBOE:VIX") on the current timeframe, then replots each candle with a corresponding color. Wick and border colors remain neutral gray to keep focus on the body color signal.

📌 Use Cases

Quickly spot regime changes between fear and complacency
Combine with your existing strategy as a macro sentiment filter
Useful across equities, ETFs, and index instruments


📝 Notes

Works on any symbol and timeframe; VIX data is always sourced at the same resolution as the chart
Candles are redrawn using plotcandle — disable your chart's default candles to avoid overlap (uncheck "Candles" in chart settings)
VIX data requires a TradingView data plan that includes CBOE feed access

## Source Code

````pine
//@version=5
indicator("VIX Candle Coloring", overlay=true)

// 1. 抓取 VIX 指數數據 (使用復權收盤價)
vixTicker = "CBOE:VIX"
vixClose = request.security(vixTicker, timeframe.period, close)

// 2. 定義 VIX 數值對應嘅 K 線顏色
// 按照你原本嘅邏輯設定顏色區間
candleColor = if vixClose >= 50
    color.new(#FF3B30, 0) // 極度恐慌 (深紅色)
else if vixClose >= 30
    color.new(#FF6A00, 0) // 高度恐慌 (橘紅色)
else if vixClose >= 25
    color.new(#FFB020, 0) // 中度恐慌 (橘黃色)
else if vixClose >= 20
    color.new(#00C2FF, 0) // 市場平穩 (淺藍色)
else
    color.new(#00C853, 0) // 市場樂觀 (綠色)

// 3. 將顏色套用到圖表嘅 K 線上
// 使用 plotcandle 重繪蠟燭圖，並保留原本嘅影線顏色
plotcandle(open, high, low, close, color=candleColor, wickcolor=color.gray, bordercolor=color.gray)
````
