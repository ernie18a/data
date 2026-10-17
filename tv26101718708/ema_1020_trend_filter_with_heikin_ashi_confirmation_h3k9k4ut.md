# EMA 10/20 Trend Filter with Heikin Ashi Confirmation

- url: https://www.tradingview.com/script/h3K9K4uT/
- type: indicator
- pine_id: PUB;bc63ddab1ff14b21924d52862eee239f
- version: 1.0

## Description

This indicator combines EMA 10, EMA 20, and Heikin Ashi candle confirmation into one simple trend-following framework.

The purpose of this script is to help traders observe short-term trend direction, momentum changes, and possible trend continuation or trend weakening areas.

How it works:

1. EMA 10 and EMA 20 are used as the main trend filter.
When EMA 10 is above EMA 20, the market may be in a stronger short-term bullish structure.
When EMA 10 is below EMA 20, the market may be in a weaker short-term bearish structure.

2. Heikin Ashi candle direction is used as a secondary confirmation tool.
Green Heikin Ashi candles may suggest stronger upside momentum.
Red Heikin Ashi candles may suggest weaker price action or downside momentum.

3. This indicator is designed for trend observation, not for predicting the future.
It does not guarantee entries, exits, profits, or win rate.

Suggested usage:

Traders can use this tool to observe whether price action is aligned with the EMA trend direction and Heikin Ashi momentum. It may be used as a visual aid for trend-following strategies, pullback observation, or avoiding counter-trend decisions.

Important notes:

This script does not provide financial advice.
This script does not guarantee trading results.
Users should combine it with their own risk management, position sizing, and market analysis.
Past price behavior does not guarantee future performance.

中文說明：

這個指標結合 EMA 10、EMA 20 與 Heikin Ashi K 棒方向，主要用來協助交易者觀察短線趨勢方向、動能變化，以及趨勢延續或轉弱的可能區域。

使用邏輯：

1. EMA 10 與 EMA 20 作為主要趨勢濾網。
當 EMA 10 在 EMA 20 上方，代表短線結構偏強。
當 EMA 10 在 EMA 20 下方，代表短線結構偏弱。

2. Heikin Ashi K 棒方向作為輔助確認。
綠色 HA K 棒可用來觀察多方動能。
紅色 HA K 棒可用來觀察空方動能或價格轉弱。

3. 這個指標主要用於趨勢觀察，不是預測未來，也不是保證獲利的買賣訊號。

建議使用方式：

交易者可以用這個工具觀察價格是否順著 EMA 趨勢方向，以及 HA 動能是否同步。它適合作為趨勢交易、回調觀察、避免逆勢操作時的視覺輔助工具。

重要提醒：

本指標不構成投資建議。
本指標不保證任何交易結果。
使用者仍需搭配自己的風險控管、倉位管理與市場分析。
過去價格行為不代表未來一定會重複發生。

## Source Code

````pine
//@version=6
indicator("EMA 10/20 with HA_by DR", overlay=true, precision=2)

// === Check whether the current chart is Heikin Ashi ===
isHA = chart.is_heikinashi

// === EMA calculation ===
fast = ta.ema(close, 10)
slow = ta.ema(close, 20)

// === Show EMA only on regular candlestick charts; hide EMA on Heikin Ashi charts ===
plot(isHA ? na : fast, color=color.blue, title="EMA 10", linewidth=2, display=display.pane)
plot(isHA ? na : slow, color=color.red, title="EMA 20", linewidth=2, display=display.pane)

// === Calculate current candle percentage change ===
amplitude = (close - open) / open * 100

// === Show Heikin Ashi candle percentage change in the status line only when using HA chart ===
plot(isHA ? amplitude : na, color=color.orange, display=display.status_line, title="Heikin Ashi Candle Change", format=format.percent)

// === Show percentage label next to the latest candle only when using Heikin Ashi chart ===
var label percentLabel = na

if barstate.islast
    if not na(percentLabel)
        label.delete(percentLabel)

    if isHA
        labelText = amplitude >= 0 ? "+" + str.tostring(amplitude, "#.##") + "%" : str.tostring(amplitude, "#.##") + "%"
        labelColor = amplitude >= 0 ? color.red : color.green
        labelY = amplitude >= 0 ? high : low
        labelStyle = amplitude >= 0 ? label.style_label_down : label.style_label_up

        percentLabel := label.new(
             bar_index,
             labelY,
             labelText,
             style=labelStyle,
             color=labelColor,
             textcolor=color.white,
             size=size.normal
        )
````
