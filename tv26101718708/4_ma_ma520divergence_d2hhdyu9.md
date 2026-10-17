# 4 MA + MA5(20%Divergence)

- url: https://www.tradingview.com/script/d2hhdyu9/
- type: indicator
- pine_id: PUB;52e7decf8a184e75814f9e8adba07448
- version: 1.0

## Description

指標名稱： 4 MA 趨勢軌道與 20% 偏離通道 (4 MA Lines & 20% Deviation Channel)指標概述：本指標是一款專為技術分析設計的複合型均線工具，整合了四條自定義長度的簡單移動平均線（MA），以及一條基於短期均線計算的 20% 固定乖離線（MA 5）。

Indicator Name: 4 MA Lines & 20% Deviation ChannelOverview:This is a comprehensive Moving Average toolkit designed for multi-timeframe trend analysis. It combines four fully customizable Simple Moving Averages (MAs) with a 20% fixed deviation line (MA 5) calculated from the short-term MA.

## Source Code

````pine
//@version=6
indicator(title="4 MA + MA5(MA1 20%乖離)", overlay=true, timeframe="", timeframe_gaps=true)

//==== 參數輸入 ====
// 4條基礎 MA 的長度設定
len1 = input.int(9,  "MA 1 長度", minval=1)
len2 = input.int(21, "MA 2 長度", minval=1)
len3 = input.int(50, "MA 3 長度", minval=1)
len4 = input.int(200,"MA 4 長度", minval=1)

// 乖離率參數設定（預設 20%）
bias_pct = input.float(20.0, "MA 5 乖離率 (%)", minval=0.0) / 100

//==== 計算 MA ====
ma1 = ta.sma(close, len1)
ma2 = ta.sma(close, len2)
ma3 = ta.sma(close, len3)
ma4 = ta.sma(close, len4)

//==== 計算 MA 5 (MA 1 向上乖離 20% 的線) ====
ma5 = ma1 * (1 + bias_pct)

//==== 繪製圖表 ====
// 繪製前 4 條 MA
plot(ma1, color=color.rgb(255, 0, 0),    linewidth=1, title="MA 1")
plot(ma2, color=color.rgb(67, 160, 71),  linewidth=1, title="MA 2")
plot(ma3, color=color.rgb(33, 150, 243), linewidth=2, title="MA 3")
plot(ma4, color=color.rgb(255, 152, 0),  linewidth=2, title="MA 4")

// 繪製 MA 5 (使用 v6 正確的虛線 linestyle 語法)
plot(ma5, color=color.rgb(156, 39, 176), linewidth=2, style=plot.style_line, linestyle=plot.linestyle_dashed, title="MA 5 (MA 1 + 20%)")
````
