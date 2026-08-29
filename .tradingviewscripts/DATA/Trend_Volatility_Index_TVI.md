<!-- tradingview-pine-id: PUB;6e47e05b5aec4a9f9577acbefddfaf28 -->
<!-- tradingviewscripts-format: 1 -->
# Trend Volatility Index (TVI)

Source: https://www.tradingview.com/script/U55O07q4/

## Description

Trend Volatility Index (TVI)

A robust nonparametric oscillator for structural trend volatility detection

⸻

What is this?

TVI is a volatility oscillator designed to measure the strength and emergence of price trends using nonparametric statistics.
It calculates a U-statistic based on the Gini mean difference across multiple simple moving averages.
This allows for objective, robust, and unbiased quantification of trend volatility in tick-scale values.

⸻

What can it do?
	•	Quantify trend strength as a continuous value aligned with tick price scale
	•	Detect trend breakouts and volatility expansions
	•	Identify range-bound market states
	•	Detect early signs of new trends with minimal lag

⸻

What can’t it do?
	•	Predict future price levels
	•	Predict trend direction before confirmation

⸻

How it works

TVI computes a nonparametric dispersion metric (Gini mean difference) from multiple SMAs of different lengths.
As this metric shares the same dimension as price ticks, it can be directly interpreted on the chart as a volatility gauge.
The output is plotted using candlestick-style charts to enhance visibility of change rate and trend behavior.

⸻

Disclaimer

TVI does not predict price. It is a structural indicator designed to support discretionary judgment.
Trading carries inherent risk, and this tool does not guarantee profitability. Use at your own discretion.

⸻

Innovation

This indicator introduces a novel approach to trend volatility by applying U-statistics over time series
to produce a nonparametric, unbiased, and robust estimate of structural volatility.

日本語要約

Trend Volatility Index (TVI) は、ノンパラメトリックなU統計量（Gini平均差）を使ってトレンドの強度を客観的に測定することを目的に開発されたボラティリティ・オシレーターです。
ティック単位で連続的に変化し、トレンドのブレイク・レンジ・初動の予兆を定量的に検出します。
未来の価格や方向は予測せず、現在の構造的ばらつきだけをロバストに評価します。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chikaharu

//@version=6
indicator(title = 'Trend Volatility Index (TVI)', overlay = false)

// ====== Source Input ====== //
src = input.source(close, title = 'Base Price')
tickStep = input.float(1.0, title = "Step Factor",tooltip = "Rounds output to nearest price step. Use tick size as a guide.\n出力を価格ステップに丸めます。ティックサイズを目安に。")
mode = input.string("Candle",options = ["Candle","Heikin-Ashi"])
colorMode = input.string("Candle",options = ["Candle","Heikin-Ashi"],tooltip = "Notice:Heikin-Ashi lagged detected color change Reversal Point.\n注意:平均足だとリバーサルポイントの検出がが遅延します")
ATR_len = input.int(14)
Range_len = input.int(14)

// ====== sma Periods for TVI Calculation ====== //
sma1 = ta.sma(src, 10)   // Approx. sma 8
sma4 = ta.sma(src, 20)  // Approx. sma 16
sma6 = ta.sma(src, 40)  // Approx. sma 31
sma9 = ta.sma(src, 70)  // sma 65

// ====== Scatter Score Calculation ====== //
n = 1
abs_diff_1_4 = math.abs(math.pow(sma1 - sma4, n))
abs_diff_1_6 = math.abs(math.pow(sma1 - sma6, n))
abs_diff_1_9 = math.abs(math.pow(sma1 - sma9, n))
abs_diff_4_6 = math.abs(math.pow(sma4 - sma6, n))
abs_diff_4_9 = math.abs(math.pow(sma4 - sma9, n))
abs_diff_6_9 = math.abs(math.pow(sma6 - sma9, n))

// === U統計量のgini平均差で散らばり具合をノンパラメトリックに定義 === //

gini_mean_diff = (abs_diff_1_4 + abs_diff_1_6 + abs_diff_1_9 + abs_diff_4_6 + abs_diff_4_9 + abs_diff_6_9) / 6
TVI = gini_mean_diff
lowerTVI= math.floor(TVI/tickStep)*tickStep
upperTVI= math.ceil(TVI/tickStep)*tickStep

// ====== Reference Indicators ====== //
atr = ta.atr(ATR_len)
hl_range = ta.sma(high - low, Range_len)

// ====== Plot Outputs ====== //
// plot(lowerTVI, title = 'TVI', color = color.new(color.purple, 0), linewidth = 1)
// plot(upperTVI, title = 'TVI', color = color.new(color.purple, 0), linewidth = 1)
// plot(TVI,'raw TVI',color.new(color.purple,50),1,plot.style_line)
plot(atr, title = 'ATR (28)', color = color.new(color.red,70), linewidth = 1,style = plot.style_area)
plot(hl_range, title = 'High-Low Range MA (28)', color =color.new(color.black,80), linewidth = 1,style = plot.style_area)


cl = TVI
op = TVI[1]
hi = math.max(op, upperTVI, cl)
lo = math.min(op, lowerTVI, cl)

// plotcandle(op,hi,lo,cl,"TVI candle chart Market Price scale",color = (op>cl?color.red:color.green))
var float ha_op = na
var float ha_cl = na

// 最初のバーだけ初期化
if na(ha_op)
    ha_cl := (op + hi + lo + cl) / 4
    ha_op := (op + cl) / 2
else
    ha_op := (ha_op[1] + ha_cl[1]) / 2
    ha_cl := (op + hi + lo + cl) / 4

ha_hi = math.max(hi, ha_op, ha_cl)
ha_lo = math.min(lo, ha_op, ha_cl)

float ca_op = na
float ca_hi = na
float ca_lo = na
float ca_cl = na

if mode == "Candle"
    ca_op := op
    ca_hi := hi
    ca_lo := lo
    ca_cl := cl
else
    ca_op := ha_op
    ca_hi := ha_hi
    ca_lo := ha_lo
    ca_cl := ha_cl

color candleColor = na

if colorMode == "Candle"
    candleColor :=  cl > op  ? #009076 : #F8213D
else
    candleColor := ha_cl > ha_op ? #009076 : #F8213D

plotcandle(ca_op,ca_hi,ca_lo,ca_cl,"TVI candle chart Market Price scale",color = candleColor,wickcolor = candleColor,bordercolor = candleColor)
````
