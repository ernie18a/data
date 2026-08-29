<!-- tradingview-pine-id: PUB;292d5b042a0d484a86b9363d6e754584 -->
<!-- tradingviewscripts-format: 1 -->
# ATR % (Volatility) [COCOSTA]

Source: https://www.tradingview.com/script/WzASe9a2-ATR-Volatility-COCOSTA/

## Description

English
ATR % (Volatility) [COCOSTA]

This indicator converts Average True Range (ATR) into a percentage of price, making volatility comparable across different assets and price levels — something raw ATR (an absolute value) can't do.

How it works:

ATR % = ATR(14) / Close × 100, plotted in a separate pane below the chart
A shaded range channel shows the highest and lowest ATR % values over the past 262 bars, excluding the current bar
When the current ATR % breaks above or below that 262-bar range, the line changes color (red = upside breakout, orange = downside breakout) and the background highlights, so unusual volatility expansions/contractions stand out at a glance
Settings:

ATR Length (default 14) — the standard Wilder ATR period
Range Lookback (default 262, ≈1 trading year on the daily chart) — the historical window used to build the high/low channel, fully adjustable
This tool is designed to help identify when volatility is moving outside its recent historical norm, which can be useful for spotting potential breakouts, squeezes, or regime changes. It is not a standalone buy/sell signal — use it alongside your own analysis and risk management.

日本語
ATR % (Volatility) [COCOSTA]

このインジケーターは、ATR（Average True Range）を価格に対する%に変換したものです。ATRは絶対値のため銘柄や価格水準が違うと単純比較ができませんが、%化することで異なる銘柄・時間軸間でもボラティリティを横並びで比較できます。

仕組み:

ATR% = ATR(14) ÷ 終値 × 100 を計算し、チャート下のサブ画面に表示
当日を含まない過去262本分のATR%の最高値・最低値でできるレンジをチャネル（帯）として塗りつぶし表示
当日のATR%がこの過去262本のレンジを上抜け・下抜けすると、ラインの色が変化（赤＝上方ブレイク、オレンジ＝下方ブレイク）し、背景にもハイライトが入るため、通常のレンジから外れたボラティリティの拡大・縮小が一目でわかります
設定項目:

ATR Length（初期値14）— 標準的なワイルダー式ATR期間
Range Lookback（初期値262、日足で約1年間に相当）— レンジ算出に使う過去期間。自由に変更可能
このツールは、ボラティリティが直近の通常レンジから外れたタイミングを把握する補助として設計されています。ブレイクアウトやスクイーズ、相場のレジーム変化の兆候を捉える際にご活用ください。単独の売買シグナルではないため、ご自身の分析・リスク管理と併せてご利用ください。

---

## Source Code

````pine
//@version=6
// Created by COCOSTA
indicator("ATR % (Volatility) [COCOSTA]", overlay=false, precision=2)

atrLength = input.int(14, title="ATR Length", minval=1)
rangeLength = input.int(262, title="Range Lookback (excl. current bar)", minval=1)

atrValue = ta.atr(atrLength)
atrPct   = atrValue / close * 100

upperBand = ta.highest(atrPct[1], rangeLength)
lowerBand = ta.lowest(atrPct[1], rangeLength)

breakoutUp   = atrPct > upperBand
breakoutDown = atrPct < lowerBand

upperPlot = plot(upperBand, title="Range High", color=color.new(color.gray, 60), linewidth=2)
lowerPlot = plot(lowerBand, title="Range Low", color=color.new(color.gray, 60), linewidth=2)
fill(upperPlot, lowerPlot, color=color.new(#2962FF, 90), title="Range Fill")

lineColor = breakoutUp ? color.red : breakoutDown ? color.orange : color.new(#2962FF, 0)
plot(atrPct, title="ATR %", color=lineColor, linewidth=2)

bgcolor(breakoutUp ? color.new(color.red, 85) : breakoutDown ? color.new(color.orange, 85) : na, title="Breakout Highlight")
````
