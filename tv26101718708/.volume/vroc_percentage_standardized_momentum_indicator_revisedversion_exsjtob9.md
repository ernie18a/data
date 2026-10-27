# VROC Percentage Standardized Momentum Indicator (RevisedVersion)

- url: https://www.tradingview.com/script/ExSJtOB9-VROC-Percentage-Standardized-Momentum-Indicator-RevisedVersion/
- type: indicator
- pine_id: PUB;1e7fd579d3824ad29722e734c4563d52
- version: 1.0

## Description

指標走勢，幫你做一個即時嘅 「量化分析解讀」：

1. 指標當前狀態分析
VROC 數值 (目前約 0.61)：數值係正數，代表輝達（NVDA）目前嘅動能依然係向上推升緊。

柱狀圖高度：你留意到最近嘅柱位雖然係青色，但高度似乎比之前一兩波爆發時矮咗少少。呢個就係你想要捕捉嘅「升勢變慢」跡象。

2. 「背離」預警嘅實戰觀察
未見三角形？ 如果圖表暫時未見橙色三角形，代表目前雖然升勢慢咗，但仲未達到「價格創新高但動能大幅萎縮」嘅極端背離條件。

領先性驗證：根據我哋 Python 之前測出嚟嘅 Lag 3 同 Lag 21。你可以睇返圖入面 VROC 轉向（由高位跌返落嚟）嗰一刻，股價通常會喺 3 日後 開始停滯，或者喺 一個月後 出現明顯調整。

3. 未來操作建議
留意背離出現：如果股價繼續衝，但下面呢啲青色柱（VROC）不斷縮短，橙色三角形就會彈出嚟。嗰個就係大戶開始「派貨」嘅統計學鑒定。

參數微調：

如果你覺得訊號太慢，可以喺 Setting 將 「速率週期 (n)」 由 22 改細啲（例如 10）。

如果你想睇更長線嘅派貨，就保持 22 或者改大佢。

Indicator Trends: Real-time Quantitative Analysis and Interpretation:

1. Current Indicator Status Analysis

VROC Value (Currently around 0.61): The value is positive, indicating that NVDA's momentum is still pushing upwards.

Histogram Height: You may have noticed that while the recent bars are cyan, their height seems slightly lower than during the previous one or two surges. This is the "slowing uptrend" sign you're looking for.

2. Practical Observation of "Divergence" Warnings
No Triangle? If the chart doesn't currently show an orange triangle, it means that although the uptrend has slowed, it hasn't yet reached the extreme divergence condition of "price making a new high but momentum significantly weakening."

Leading Validation: Based on our previous Python tests of Lag 3 and Lag 21... You can see in the chart that when the VROC turns (falling back from a high), the stock price usually stagnates after 3 days or shows a significant correction after a month.

3. Future Trading Suggestions

Watch for divergence: If the stock price continues to rise, but the lower blue bars (VROC) keep shortening, an orange triangle will appear. This is a statistical indicator that large investors are starting to "distribute" their holdings.

Parameter Fine-tuning:

If you feel the signal is too slow, you can change the "Rate Period (n)" in Settings from 22 to a smaller value (e.g., 10).

If you want to observe a longer-term distribution pattern, keep it at 22 or increase it.

## Source Code

````pine
// @version=5
indicator("VROC 百分比標準化動能指標 (修正版)", overlay=false, precision=2)

// --- 1. 設定參數 ---
n_velocity  = input.int(22, "速率週期 (n)", minval=1)
avg_vol_n   = input.int(60, "成交量基準週期", minval=1)
vroc_smooth = input.int(10, "指標平滑週期", minval=1)
lookback_div = input.int(60, "背離對比期", minval=1)

// --- 2. 核心計算 ---
// 價格速率 (v) 改為百分比，解決股價高低不合理問題
velocity_pct = ((open - open[n_velocity]) / open[n_velocity]) * 100 / n_velocity

// 成交量權重 (w)
avg_volume = ta.sma(volume, avg_vol_n)
volume_weight = volume / avg_volume

// 最終 VROC
vroc_raw = velocity_pct * volume_weight
vroc_ma  = ta.sma(vroc_raw, vroc_smooth)

// --- 3. 自動偵測「派貨背離」 ---
price_high = ta.highest(high, lookback_div)
// 修正點：搵出上一次高位出現時嘅 VROC 數值
vroc_at_prev_high = ta.valuewhen(high == price_high, vroc_ma, 1)

// 背離條件 (Line 24)：統一變數名為 vroc_at_prev_high
is_top_div = (high >= price_high[1]) and (vroc_ma < vroc_at_prev_high) and (vroc_ma > 0)

// --- 4. 視覺化繪圖 ---
vroc_color = vroc_ma >= 0 ? color.new(color.teal, 50) : color.new(color.red, 50)
plot(vroc_ma, title="VROC 動能值", color=vroc_color, style=plot.style_columns)

// 零軸
hline(0, "零軸", color=color.gray, linestyle=hline.style_dashed)

// 標示背離訊號
plotshape(is_top_div, title="大戶派貨預警", style=shape.triangledown, location=location.top, color=color.orange, size=size.small, text="派貨?")

// --- 5. 狀態欄 ---
var label stats_label = na
if barstate.islast
    label.delete(stats_label)
    stats_label := label.new(bar_index, vroc_ma, 
         text="[VROC 百分比版]\n" +
              "平均每日變動: " + str.tostring(velocity_pct, "#.##") + "%\n" +
              "成交量強度: " + str.tostring(volume_weight, "#.##") + "x",
         color=color.black, textcolor=color.white, style=label.style_label_left)
````
