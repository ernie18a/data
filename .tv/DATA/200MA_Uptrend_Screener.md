<!-- tradingview-pine-id: PUB;5597146022a7445291ef79399aac43d6 -->
<!-- tradingviewscripts-format: 1 -->
# 200MA Uptrend Screener

Source: https://www.tradingview.com/script/exVdVRAr/

## Description

English

200MA Uptrend Screener

A simple trend filter designed to identify stocks with a rising 200-day moving average.

Instead of relying on the visual angle of the moving average, this script determines the long-term trend by comparing the current 200-day moving average with its value a specified number of trading days ago.

Default condition:

Current 200MA > 200MA 20 trading days ago

The lookback period is adjustable, allowing users to change how the long-term trend is measured.

This indicator is designed as a basic long-term trend filter rather than a standalone buy or sell signal. It can be combined with other criteria such as earnings growth, relative strength, volume analysis, and volatility contraction.

How to use with the TradingView Screener:

Add this indicator to the screener and set:

Scanner = 1

This will display only stocks whose 200-day moving average is rising according to the selected lookback period.

日本語

200MA Uptrend Screener

200日移動平均線が上昇トレンドにある銘柄を抽出するための、シンプルなトレンドフィルターです。

移動平均線の見た目の角度ではなく、現在の200日MAと指定した営業日前の200日MAを比較することで、長期トレンドが上向いているかを判定します。

デフォルト条件：

現在の200MA > 20営業日前の200MA

Lookback期間は変更可能なので、長期トレンドを判定する期間を自由に調整できます。

本インジケーターは単独の売買シグナルではなく、EPS成長、RS（相対的強さ）、出来高分析、ボラティリティ収縮などと組み合わせるための基本的な長期トレンドフィルターとして設計しています。

TradingViewスクリーナーでの使用方法：

本インジケーターをスクリーナーに追加し、

Scanner = 1

に設定してください。

これにより、指定したLookback期間において200日MAが右肩上がりになっている銘柄だけを抽出できます。

---

## Source Code

````pine
//@version=6
indicator("200MA Uptrend Screener", overlay=false)

lookback = input.int(20, "Lookback Days", minval=1)

ma200 = ta.sma(close, 200)

// 200MAがN営業日前より上
ma200Up = ma200 > ma200[lookback]

// Screener
scanner = ma200Up ? 1 : 0

plot(scanner, "Scanner")
````
