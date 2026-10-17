# RSI Candle Coloring

- url: https://www.tradingview.com/script/B7zQIgHI/
- type: indicator
- pine_id: PUB;991a4cc9d30d466d8778e61375665ee9
- version: 1.0

## Description

**RSI Candle Coloring**

Visualize momentum strength instantly — without glancing at a separate RSI panel.

This indicator dynamically recolors each candlestick based on the current RSI value, letting you read overbought and oversold conditions directly from the price chart. Both the RSI period and threshold levels are fully adjustable to fit your trading style.

---

**🎨 Color Zones**

🔴 RSI ≥ 70 — Overbought / Strong Bullish Momentum

🟠 RSI 60–69 — Bullish Bias / Approaching Overbought

⚪ RSI 41–59 — Neutral / Consolidation Zone

🔵 RSI 31–40 — Bearish Bias / Approaching Oversold

🟢 RSI ≤ 30 — Oversold / Strong Bearish Momentum

---

**⚙️ How It Works**

RSI is calculated using the standard closing price over a configurable lookback period (default: 14). Each candle is then replotted via plotcandle with a color mapped to its RSI reading. Wick and border colors remain neutral gray to keep the focus on momentum signals.

---

**🔧 Inputs**

• RSI Period — Lookback length for RSI calculation (default: 14)

• Overbought Level — Upper threshold for deep red coloring (default: 70)

• Oversold Level — Lower threshold for deep green coloring (default: 30)

---

**📌 Use Cases**

• Instantly identify overbought and oversold conditions on the price chart

• Spot momentum shifts and neutral consolidation zones at a glance

• Combine with support/resistance levels or moving averages for entry/exit confirmation

• Works as a cleaner alternative to a traditional RSI subplot

---

**📝 Notes**

• Works on any symbol and timeframe

• Candles are redrawn using plotcandle — disable your chart's default candles to avoid overlap (uncheck "Candles" in chart settings)

• The 60 and 40 intermediate thresholds are fixed by design to create a consistent 5-zone color gradient; only the overbought and oversold extremes are user-adjustable

## Source Code

````pine
//@version=6
indicator("RSI Candle Coloring", overlay=true)

// 1. 設定 RSI 參數
rsiLength = input.int(14, title="RSI 週期長度")
overbought = input.int(70, title="超買水平 (深紅色)")
oversold = input.int(30, title="超賣水平 (深綠色)")

// 2. 計算 RSI 數值
rsiValue = ta.rsi(close, rsiLength)

// 3. 定義 RSI 數值對應的 K 線顏色
// 邏輯：RSI 越高顏色越紅，RSI 越低顏色越綠，中間為中性色
candleColor = if rsiValue >= overbought
    color.new(#FF3B30, 0) // 超買區域 (深紅色)
else if rsiValue >= 60
    color.new(#FF9800, 0) // 偏強區域 (橘色)
else if rsiValue <= oversold
    color.new(#00C853, 0) // 超賣區域 (深綠色)
else if rsiValue <= 40
    color.new(#00C2FF, 0) // 偏弱區域 (淺藍色)
else
    color.new(#B0BEC5, 0) // 中性震盪區域 (灰色)

// 4. 將顏色套用到圖表的 K 線上
// 使用 plotcandle 重繪蠟燭圖
plotcandle(open, high, low, close, color=candleColor, wickcolor=color.gray, bordercolor=color.gray)
````
