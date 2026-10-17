# Top & Bottom Sniper (Keltner)

- url: https://www.tradingview.com/script/ujhVcyE4-Top-Bottom-Sniper-Keltner/
- type: indicator
- pine_id: PUB;a2ba5829b80a4abf86b5ccab8d45df35
- version: 1.0

## Description

【 What is this? 】
A powerful mean-reversion indicator designed to catch absolute tops and bottoms while filtering out consecutive false signals during strong trends. Built on a customized Dual-Band Keltner Channel, it identifies high-probability turning points and extreme V-shape reversals.

【 Key Features 】

🎯 Smart Signal Filter: No more "false consecutive signals" mid-trend. After a reversal signal fires, it locks down and requires a real-body close across the Middle Band to "reload" for the next setup.

✅ Real-Body Confirmation (High Win Rate): For regular channel touches (default 2.0 ATR), the script requires a candlestick reversal (e.g., closes red at the top) before printing a signal.

⚡ Extreme V-Shape Catcher (High Reward): If the price violently crashes through the Extreme Band (default 3.0 ATR), it bypasses all rules and fires immediately to catch panic selling or euphoric buying.

【 How to use 】

Red Cross: Potential Top / Short opportunity.

Green Cross: Potential Bottom / Long opportunity.

Tip: Increase the "Regular Multiplier" to 2.5 or 2.8 if you trade highly volatile crypto assets to avoid early signals.

【 Tags / Keywords 】 (發布時記得把這些填進標籤欄位，增加搜尋曝光)
Reversal, Top Bottom, Mean Reversion, Keltner Channel, Extreme, Sniper, Oscillator, Swing Trade

## Source Code

````pine
//@version=5
indicator("綜合震盪轉折指標 (雙軌例外版 15.0)", overlay=true)

// --- 1. 價格通道參數 ---
kcLen = input.int(20, title="通道週期 (Length)")
kcMult = input.float(2.0, title="常規通道倍數 (需實體確認)")
extremeMult = input.float(3.0, title="極端例外倍數 (無腦接刀)")
useEma = input.bool(true, title="使用 EMA 作為中軌")

// --- 2. 計算雙層通道 ---
basis = useEma ? ta.ema(close, kcLen) : ta.sma(close, kcLen)
atr = ta.atr(kcLen)

// 常規邊界 (2.0 ATR)
upperBand = basis + (kcMult * atr)
lowerBand = basis - (kcMult * atr)

// 極端邊界 (3.0 ATR)
exUpperBand = basis + (extremeMult * atr)
exLowerBand = basis - (extremeMult * atr)

// --- 3. 嚴謹的狀態機 (防連發重置邏輯) ---
var bool armedTop = true
var bool armedBot = true

// 嚴格均值回歸：實體 K 線收盤越過中軌，重新上膛
if (close < basis)
    armedTop := true
if (close > basis)
    armedBot := true

// --- 4. 觸發條件 (雙軌並行) ---
// 空頭：(碰到常規上軌 且 收黑) 或是 (瞬間戳破極端上軌)
condTop = ((high > upperBand and close < open) or (high > exUpperBand)) and armedTop

// 多頭：(碰到常規下軌 且 收紅) 或是 (瞬間砸穿極端下軌)
condBot = ((low < lowerBand and close > open) or (low < exLowerBand)) and armedBot

if condTop
    armedTop := false
if condBot
    armedBot := false

// --- 5. 視覺標示 ---
plot(upperBand, color=color.new(color.gray, 80), title="常規上軌")
plot(basis, color=color.new(color.blue, 80), title="中軌(重置線)")
plot(lowerBand, color=color.new(color.gray, 80), title="常規下軌")

// 印出轉折訊號
plotshape(series=condTop, title="空頭轉折(紅叉)", style=shape.xcross, location=location.abovebar, color=color.new(color.red, 0), size=size.small, force_overlay=true)
plotshape(series=condBot, title="多頭轉折(綠叉)", style=shape.xcross, location=location.belowbar, color=color.new(color.green, 0), size=size.small, force_overlay=true)
````
