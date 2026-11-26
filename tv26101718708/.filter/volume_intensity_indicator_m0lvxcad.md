# Volume Intensity Indicator

- url: https://www.tradingview.com/script/m0LvXCAd/
- type: indicator
- pine_id: PUB;9f9a85cb2de94034973896e4dc41198a
- version: 1.0

## Description

📊 Volume Intensity Indicator
🇺🇸 English
📌 Overview
This indicator measures relative trading volume strength by comparing short-term and long-term volume averages.
It converts raw volume into a 7-level intensity scale to help traders quickly understand whether market participation is weak, normal, increasing, or extremely strong.
🧠 How It Works
Fast Volume = short-term SMA of volume
Slow Volume = long-term SMA of volume
Volume Ratio = Fast Volume / Slow Volume
This ratio is classified into 7 levels (0–6).
📊 Volume Levels
Level 0 → Low Volume (consolidation / inactivity)
Level 1 → Normal Volume
Level 2 → Slight Increase
Level 3 → Moderate Increase
Level 4 → Strong Volume
Level 5 → High Volume (breakout interest)
Level 6 → Extreme Volume (news / panic / major move)
📌 How to Use
1. Trend Confirmation
Price up + Level 4–6 → strong trend
Price up + Level 0–2 → weak move / possible fake breakout
2. Breakout Validation
Level 5–6 → high probability of real breakout
Level 0–2 → likely false breakout
3. Market Condition
0–1 → low activity / range
3–6 → active market / volatility expansion
⚠️ Note
This indicator does NOT predict direction.
It only measures volume strength (market participation).


🇹🇼 中文
📌 概述
這個指標用來衡量成交量的相對強度，透過比較短期與長期成交量平均值，將成交量轉換為 7 個等級。
幫助交易者快速判斷市場是：
弱量、正常、放量、還是極端爆量。
🧠 運作方式
快線成交量 = 短期均量
慢線成交量 = 長期均量
成交量比值 = 快線 / 慢線
並將結果分成 0～6 等級。
📊 等級說明
0 → 縮量（盤整 / 無行情）
1 → 正常量
2 → 微放量
3 → 溫和放量
4 → 強勢放量
5 → 爆量（突破關注）
6 → 極端爆量（消息 / 情緒行情）
📌 使用方法
1️⃣ 判斷趨勢
上漲 + 4～6級 → 趨勢較可信
上漲 + 0～2級 → 容易是假突破
2️⃣ 判斷突破
5～6級突破 → 成功率較高
0～2級突破 → 容易失敗
3️⃣ 判斷市場狀態
0～1 → 盤整
3～6 → 波動放大
⚠️ 注意
此指標不判斷方向，只判斷強度。
用來觀察市場參與度，而不是預測漲跌。

## Source Code

````pine
//@version=6
indicator("Volume Intensity Indicator", overlay=false)

// === Input Parameters ===
fastLen = input.int(1, title="Fast Length")
slowLen = input.int(16, title="Slow Length")

// === Fast / Slow Volume Calculation ===
vol_fast = ta.sma(volume, fastLen)
vol_slow = ta.sma(volume, slowLen)
vol_ratio = vol_fast / vol_slow

// === 7-Level Volume Intensity Classification ===
level = vol_ratio < 0.8 ? 0 :
         vol_ratio < 1.0 ? 1 :
         vol_ratio < 1.2 ? 2 :
         vol_ratio < 1.5 ? 3 :
         vol_ratio < 1.8 ? 4 :
         vol_ratio < 2.2 ? 5 : 6

// === Color Settings ===
levelColor = level == 0 ? color.new(color.gray, 30) :     // Low volume
             level == 1 ? color.silver :                  // Normal
             level == 2 ? color.new(color.green, 60) :    // Slight increase
             level == 3 ? color.green :                   // Moderate increase
             level == 4 ? color.blue :                    // Strong volume
             level == 5 ? color.orange :                  // High volume
                          color.red                        // Extreme volume

// === Level Names ===
levelName = 
             level == 0 ? "Low Volume" : 
             level == 1 ? "Normal" :
             level == 2 ? "Slight Increase" :
             level == 3 ? "Moderate Increase" :
             level == 4 ? "Strong Volume" :
             level == 5 ? "High Volume" : "Extreme Volume"

// === Plot Volume Intensity Histogram ===
plot(level * 50, title="Volume Intensity Level", style=plot.style_columns, color=levelColor, linewidth=6)

// === Reference Lines ===
hline(0, "Low Volume", color=color.gray, linestyle=hline.style_dotted)
hline(50, "Normal", color=color.silver, linestyle=hline.style_dotted)
hline(100, "Slight Increase", color=color.green, linestyle=hline.style_dotted)
hline(150, "Moderate Increase", color=color.green, linestyle=hline.style_dotted)
hline(200, "Strong Volume", color=color.blue, linestyle=hline.style_dotted)
hline(250, "High Volume", color=color.orange, linestyle=hline.style_dotted)
hline(300, "Extreme Volume", color=color.red, linestyle=hline.style_dotted)

// === Background Highlight (Extreme Conditions) ===
bgcolor(level == 6 ? color.new(color.red, 90) :
       level == 0 ? color.new(color.gray, 95) : na)

// === Data Table (Reserved) ===
if barstate.islast
    var table infoTable = table.new(position.top_right, 2, 8, bgcolor=color.white, border_width=1)
````
