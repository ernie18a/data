# HTF Bias Strength

- url: https://www.tradingview.com/script/yElwl6ZW/
- type: indicator
- pine_id: PUB;5025394fc9214b9c96b16971690ab594
- version: 2.0

## Description

# HTF Bias Strength

HTF Bias Strength is a trend-strength indicator designed to measure the directional bias of the market using the distance between a fast EMA and a slow EMA, normalized by ATR.

Unlike traditional trend indicators that only display bullish or bearish conditions, HTF Bias Strength visualizes the intensity of market bias through a dynamic histogram, making it easier to identify accumulation, trend expansion, and trend exhaustion phases.

## Key Features

### ATR-Normalized EMA Distance

The indicator measures the distance between a fast EMA and a slow EMA and divides it by ATR.

This normalization allows the indicator to adapt across different markets and timeframes without being affected by price scale.

### Dynamic Bias Strength

Instead of a simple Bull/Bear signal, the histogram displays the actual strength of market bias.

* Positive values indicate bullish pressure.
* Negative values indicate bearish pressure.
* Values near zero indicate market compression or equilibrium.

### Gradient Color Visualization

Histogram colors automatically adjust according to trend strength.

* Light Green → Weak Bullish Bias
* Bright Green → Strong Bullish Bias
* Light Red → Weak Bearish Bias
* Bright Red → Strong Bearish Bias

This allows traders to quickly assess the current market environment at a glance.

### Compression Detection

When the EMA distance contracts toward zero, the market is entering a compression phase.

These areas often represent:

* Accumulation
* Consolidation
* Rebalancing
* Pre-breakout conditions

The indicator highlights these low-bias zones to help traders identify potential setup locations.

## Practical Uses

### Trend Identification

Monitor whether bullish or bearish pressure is increasing or decreasing over time.

### Market Structure Analysis

Observe transitions between:

* Compression
* Expansion
* Trend Development
* Trend Exhaustion

### AMD Framework Support

The indicator is particularly useful when applying the Accumulation-Manipulation-Distribution (AMD) model.

Typical behavior:

* Accumulation → Histogram contracts toward zero.
* Manipulation → Bias rapidly expands from equilibrium.
* Distribution → Strong directional bias remains active.

### Trade Filtering

Use the indicator as a higher-timeframe bias filter to avoid trading against dominant market pressure.

## Suitable Markets

* Forex
* Gold (XAUUSD)
* Indices
* Stocks
* Cryptocurrency

## Recommended Timeframes

The indicator is designed to work across all timeframes and can be used for:

* Scalping
* Intraday Trading
* Swing Trading
* Position Trading

## Interpretation Guide

* Strong Green Histogram → Strong Bullish Bias
* Weak Green Histogram → Weak Bullish Bias
* Near Zero Histogram → Compression / Range
* Weak Red Histogram → Weak Bearish Bias
* Strong Red Histogram → Strong Bearish Bias

## Disclaimer

This indicator measures directional bias and trend strength only. It does not generate buy or sell signals. Traders should combine it with market structure analysis, liquidity concepts, and proper risk management before making trading decisions.

## Source Code

````pine
//@version=6
indicator("EMA Bias", overlay=true)

// ═══════════════════════════════════════════════════════════════
// Settings
// ═══════════════════════════════════════════════════════════════

emaLength = input.int(
     32,
     "EMA Length",
     minval=1
     )

// 比較目前 EMA 與幾根 K 棒前的 EMA，用來判斷 EMA 斜率。
// EMA 越長，使用的斜率觀察距離也會跟著增加。
slopeLookback = math.round(emaLength / 4)

// Normalized 模式的方向門檻。
// 正常情況下，EMA 斜率需要達到盤整基準的 1.2 倍，才視為有明確方向。
// 由於歷史正、負斜率都以絕對值計算，基準同時包含多頭與空頭斜率，
// 因此實際使用的門檻為 1.2 ÷ 2 = 0.6。
normalizedThreshold = 0.6

// ═══════════════════════════════════════════════════════════════
// Normalized Settings
// ═══════════════════════════════════════════════════════════════

// 固定使用 600 個歷史斜率樣本。
// 不讓使用者手動調整，避免不同設定造成標準化基準失去一致性。
normalizationSamples = 600

// 每個歷史樣本使用與目前斜率相同的 Lookback。
// 例如 Slope Lookback = 8：
//
// EMA[8]  vs EMA[16]
// EMA[16] vs EMA[24]
// EMA[24] vs EMA[32]
// ...
//
// 每個樣本彼此不重疊，避免同一段行情被重複計算。
sampleSpacing = slopeLookback

// ═══════════════════════════════════════════════════════════════
// EMA
// ═══════════════════════════════════════════════════════════════

ema = ta.ema(close, emaLength)

// ═══════════════════════════════════════════════════════════════
// Current EMA Slope
// ═══════════════════════════════════════════════════════════════

// 目前 EMA 與 N 根前 EMA 的百分比變化。
currentSlope = ema[slopeLookback] != 0
     ? (ema - ema[slopeLookback]) / ema[slopeLookback] * 100
     : 0

// ═══════════════════════════════════════════════════════════════
// Historical Non-Overlapping Slopes
// ═══════════════════════════════════════════════════════════════

// 累加歷史斜率的絕對值。
// 正、負斜率都轉為正數，避免多空斜率互相抵銷。
historicalSlopeSum = 0.0

// 實際取得的有效樣本數。
validSamples = 0

// 從上一個完整區間開始往回取樣。
// 第一個樣本：EMA[8] vs EMA[16]
// 第二個樣本：EMA[16] vs EMA[24]
// 第三個樣本：EMA[24] vs EMA[32]
// ...
for i = 1 to normalizationSamples

    currentOffset = i * sampleSpacing
    previousOffset = (i + 1) * sampleSpacing

    historicalEMA = ema[currentOffset]
    olderEMA = ema[previousOffset]

    if not na(historicalEMA) and not na(olderEMA) and olderEMA != 0

        historicalSlope =
             (historicalEMA - olderEMA) /
             olderEMA *
             100

        historicalSlopeSum += math.abs(historicalSlope)

        validSamples += 1

// ═══════════════════════════════════════════════════════════════
// Average Historical Slope
// ═══════════════════════════════════════════════════════════════

// 600 個歷史斜率的平均絕對值。
// 代表這個品種、這個時間週期的歷史正常斜率幅度。
averageHistoricalSlope = validSamples > 0
     ? historicalSlopeSum / validSamples
     : 0

// ═══════════════════════════════════════════════════════════════
// Normalized Slope
// ═══════════════════════════════════════════════════════════════

// 將目前斜率除以歷史正常斜率。
//
// 例如：
//
// Current Slope = +0.06%
// Historical Average = 0.10%
//
// Normalized Slope = +0.60
//
// 正數 = EMA 向上
// 負數 = EMA 向下
normalizedSlope = averageHistoricalSlope > 0
     ? currentSlope / averageHistoricalSlope
     : 0

// ═══════════════════════════════════════════════════════════════
// Bias
// ═══════════════════════════════════════════════════════════════

// 目前斜率達到歷史正常斜率的門檻 → 才給方向。
// 未達門檻 → Neutral / 盤整。
bullish =
     normalizedSlope >= normalizedThreshold

bearish =
     normalizedSlope <= -normalizedThreshold

neutral =
     not bullish and not bearish

// ═══════════════════════════════════════════════════════════════
// Bias Background
// ═══════════════════════════════════════════════════════════════

biasColor =
     bullish ? color.new(color.green, 90) :
     bearish ? color.new(color.red, 90) :
     color.new(color.gray, 93)

bgcolor(
     biasColor,
     title="Bias Background"
     )

// ═══════════════════════════════════════════════════════════════
// EMA Line
// ═══════════════════════════════════════════════════════════════

plot(
     ema,
     title="EMA",
     color=color.red,
     linewidth=1
     )

// ═══════════════════════════════════════════════════════════════
// Bias Display
// ═══════════════════════════════════════════════════════════════

var table biasTable = table.new(
     position.top_right,
     1,
     1,
     border_width=0
     )

biasText =
     bullish ? "BULLISH" :
     bearish ? "BEARISH" :
     "NEUTRAL"

biasBgColor =
     bullish ? color.new(color.green, 82) :
     bearish ? color.new(color.red, 82) :
     color.new(color.gray, 88)

if barstate.islast
    table.cell(
         biasTable,
         0,
         0,
         "BIAS\n" + biasText,
         text_color=color.rgb(40, 40, 40),
         bgcolor=biasBgColor,
         text_size=size.small
         )
````
