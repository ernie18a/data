<!-- tradingview-pine-id: PUB;898c9c24feed4b9c9981fbb207fde1f5 -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: ERAMA Trend (ET) v1.0.0

Source: https://www.tradingview.com/script/T81HuVT5-TF-ERAMA-Trend-ET/

## Description

TradingFlow: ERAMA Trend (ET)

TradingFlow: ERAMA Trend (ET) turns the Efficiency Ratio Adaptive Moving Average ([ERAMA](https://www.tradingview.com/script/NSGvTF3X-Efficiency-Ratio-Adaptive-Moving-Average-ERAMA/)) into a color-coded trend-line tool. Regression slope identifies rising and falling direction, while ATR-normalized movement identifies confirmed flat-trend conditions with a hysteresis boundary for steadier state changes.

ET offers two independently configurable ERAMA lines, and users can display either one or both. They can be used as a fast/slow pair, or assigned separate roles: one for shorter-term trend context and the other for the longer-term main trend. The default EMA lengths are 20 and 200. Each displayed line receives its own length-adjusted lag reduction and trend-state classification while sharing the same price source and adaptive core.

How the ERAMA Core Is Calculated

1. Efficiency Ratio

ERAMA first measures how efficiently the selected Source has moved over the ER Length:

Change = |Source − Source from ER Length bars ago|
Volatility = Sum of |Source − Previous Source| over the ER Length
ER = Change ÷ Volatility

The Efficiency Ratio stays between 0 and 1. A reading near 1 means most movement contributed to net progress in one direction. A reading near 0 means price traveled back and forth with little net progress relative to its total path.

2. Efficiency-Adaptive EMA Blend

The Fast and Slow lengths create two EMAs of the same Source:
Fast EMA = EMA(Source, Fast Length)
Slow EMA = EMA(Source, Slow Length)
Adaptive = Slow EMA + ER × (Fast EMA − Slow EMA)

High ER moves the adaptive result toward the Fast EMA. Low ER keeps it closer to the Slow EMA. This uses Kaufman's Efficiency Ratio as an adaptive weight, but it is not the standard recursive Kaufman Adaptive Moving Average (KAMA) formula.

3. Shared WMA Base

Both ERAMA lines use the same adaptive blend and WMA stage:

WMA Base = WMA(Adaptive, WMA Smooth Length)

Sharing this base ensures that differences between the two displayed lines come from their EMA lengths and corresponding lag-reduction scales, not from separate ER measurements.

4. Per-Line Smoothing and Lag Reduction

Each line applies its own EMA length N:

Smoothed(N) = EMA(WMA Base, N)
Responsiveness Scale(N) = Min(1, 50 ÷ N)^Responsiveness Length Decay
Effective Responsiveness(N) = Responsiveness × Responsiveness Scale(N)
ERAMA(N) = Smoothed(N) + Effective Responsiveness(N) × [Smoothed(N) − EMA(Smoothed(N), N)]

The final difference term is a partial DEMA-style lag correction. For EMA lengths of 50 or less, the full selected Responsiveness is used. Above 50, Responsiveness decreases gradually according to the length-decay setting. This lets the shorter and longer ERAMA lines share one control without applying the same correction strength indiscriminately across very different horizons.

5. Direction Classification

Each line's direction is measured independently using its linear-regression slope over the Flat Confirmation Period:

Slope(N) = LinReg[ERAMA(N), Period, Offset 0] − LinReg[ERAMA(N), Period, Offset 1]

A positive slope sets that line's confirmed direction to rising. A negative slope sets it to falling. If the slope is exactly zero, the previous non-zero direction is retained.

6. ATR-Normalized Flat State

Flatness is also calculated independently for each ERAMA line:

Average Movement(N) = SMA(|ERAMA(N) − Previous ERAMA(N)|, Flat Confirmation Period)
Normalized Movement(N) = Average Movement(N) ÷ ATR(14)

A line enters its flat state when Normalized Movement is at or below the Flat Movement Threshold. It exits only after movement rises above 1.5 times the threshold. These separate entry and exit levels create hysteresis and reduce rapid gray/color switching near the boundary.

Direction and flat-state changes are committed on confirmed bars. The ERAMA values themselves can still update with the current open bar.

Using One or Two ERAMA Lines

Each ERAMA line functions as an independent color-coded trend line. Users can choose the arrangement that best fits their workflow:
• Display one line as a standalone trend tool
• Display both lines as a fast/slow pair
• Use ERAMA 1 for shorter-term trend context and ERAMA 2 for the longer-term main trend

The defaults use EMA lengths of 20 and 200, but both are configurable. Because the lines share the same Efficiency Ratio, EMA anchors, and WMA base, differences between them come from their smoothing horizons and length-adjusted lag reduction. Each line remains independently interpretable.

How to Read ERAMA Trend

Green — Rising
Green indicates a confirmed positive regression slope and a non-flat state. Price holding above a rising ERAMA supports a bullish directional interpretation for that line's horizon.

Red — Falling
Red indicates a confirmed negative regression slope and a non-flat state. Price holding below a falling ERAMA supports a bearish directional interpretation for that line's horizon.

Gray — Flat
Gray means the line's average movement is small relative to ATR. This often appears during consolidation, compression, or transition. Flatness is evaluated separately, so one ERAMA can be gray while the other remains directional.

Agreement Between the Lines

When both ERAMA lines rise, short- and long-horizon direction agree to the upside. When both fall, they agree to the downside. Mixed colors indicate that the two horizons are moving differently, which can occur during pullbacks, early reversals, or broader trend transitions. The relative position and crossings of the two lines provide additional context about trend alignment and transition.

Single-Color Mode

Disabling Color Lines by Trend removes the state colors. ERAMA 1 is then displayed in aqua and ERAMA 2 in gold. Their calculations do not change.

Understanding the Settings

Source
Selects the shared price series. The default is HLCC4: the average of High, Low, Close, and Close.

ER Length
Controls the shared Efficiency Ratio window. Lower values react to recent path changes sooner. Higher values evaluate directional efficiency over a broader sample.

Fast Length
Sets the Fast EMA anchor used by the shared adaptive blend. Fast Length must be lower than Slow Length.

Slow Length
Sets the Slow EMA anchor used by the shared adaptive blend. Slow Length must be higher than Fast Length.

Responsiveness
Controls the base strength of the partial DEMA-style lag correction. Higher values reduce more lag but can increase turning sensitivity and overshoot.

Responsiveness Length Decay
Controls how strongly Responsiveness decreases for EMA lengths above 50. Higher values apply a larger reduction to longer-period lines. A value of 0 disables length-based scaling.

WMA Smooth Length
Controls the shared WMA stage before the two output branches. Higher values create a steadier base with more delay.

ERAMA 1 EMA Length
Controls the first line's smoothing horizon and lag-reduction period. Its default is 20.

ERAMA 2 EMA Length
Controls the second line's smoothing horizon and lag-reduction period. Its default is 200.

Color Lines by Trend
Enables independent green, red, and gray state colors. When disabled, the lines use fixed aqua and gold colors.

Flat Confirmation Period
Controls the regression-slope window and average-movement window used by both lines. Higher values create steadier but slower state changes.

Flat Movement Threshold
Sets the maximum average ERAMA movement, measured in ATR units per bar, that is considered flat. Higher values classify more conditions as flat. Each line must exceed 1.5 times this threshold to leave the flat state.

Practical Use

ERAMA Trend can be used as a color-coded trend baseline, adaptive pullback reference, directional filter, or trend-management tool. A single line can represent the user's preferred trend horizon. When both lines are shown, the shorter line can provide earlier context while the longer line frames the main trend.

Colors provide a compact summary of each line's slope and movement state. The two configurable horizons can be combined with price structure to build a trend-reading framework suited to the user's timeframe.

---

TradingFlow: ERAMA Trend (ET)

TradingFlow: ERAMA Trend (ET) 把效率比率自適應移動平均線（[ERAMA](https://www.tradingview.com/script/NSGvTF3X-Efficiency-Ratio-Adaptive-Moving-Average-ERAMA/)）轉化為具顏色狀態的趨勢線工具。線性回歸斜率用來識別上升與下降方向；ATR 標準化移動則識別已確認的平坦趨勢，並透過遲滯邊界令狀態轉換更穩定。

ET 提供兩條可獨立調整的 ERAMA 線，使用者可選擇顯示其中一條或同時顯示兩條。它們可作為 Fast/Slow 雙線組合，亦可分別擔任不同角色：一條觀察較短期趨勢，另一條界定較長期主趨勢。預設 EMA 長度為 20 與 200。每條顯示線都有自己按長度調整的延遲縮減及趨勢狀態分類，同時共用價格來源及自適應核心。

ERAMA 核心如何計算

1. 效率比率

ERAMA 先衡量所選 Source 在 ER Length 期間內的移動效率：

變化 = |目前 Source − ER Length 之前的 Source|
波動 = ER Length 內每根 K 線之 |Source − 前一個 Source| 總和
ER = 變化 ÷ 波動

效率比率保持在 0 至 1 之間。接近 1 表示大部分移動形成單一方向的淨進展；接近 0 則表示價格反覆來回，相對總路徑只有有限淨進展。

2. 效率自適應 EMA 混合

Fast 與 Slow 長度會從同一 Source 建立兩條 EMA：

Fast EMA = EMA（Source，Fast Length）
Slow EMA = EMA（Source，Slow Length）
Adaptive = Slow EMA + ER ×（Fast EMA − Slow EMA）

ER 偏高時，自適應結果會靠近 Fast EMA；ER 偏低時，則靠近 Slow EMA。這個結構使用考夫曼效率比率作為自適應權重，但並不是標準的遞迴考夫曼自適應移動平均線（KAMA）公式。

3. 共用 WMA 基準

兩條 ERAMA 使用同一個自適應混合結果及 WMA 階段：

WMA Base = WMA（Adaptive，WMA Smooth Length）

共用基準確保兩條線之間的差異來自 EMA 長度及相應的延遲縮減，而不是使用不同的 ER 量度。

4. 每條線的平滑及延遲縮減

每條線分別套用自己的 EMA 長度 N：

Smoothed(N) = EMA（WMA Base，N）
Responsiveness Scale(N) = Min（1，50 ÷ N）^Responsiveness Length Decay
Effective Responsiveness(N) = Responsiveness × Responsiveness Scale(N)
ERAMA(N) = Smoothed(N) + Effective Responsiveness(N) × [Smoothed(N) − EMA（Smoothed(N)，N）]

最後的差值項是部分 DEMA 式延遲修正。EMA 長度為 50 或以下時，會完整使用所選 Responsiveness；高於 50 後，Responsiveness 會按 Length Decay 逐步下降，讓長短週期共用同一設定時，不會不加區分地套用相同修正強度。

5. 方向分類

每條線都使用 Flat Confirmation Period 內的線性回歸斜率，獨立判斷方向：

Slope(N) = LinReg[ERAMA(N)，Period，Offset 0] − LinReg[ERAMA(N)，Period，Offset 1]

正斜率會把該線的已確認方向設為上升；負斜率則設為下降。斜率剛好等於零時，會保留上一個非零方向。

6. ATR 標準化平坦狀態

每條 ERAMA 的平坦程度亦會獨立計算：

Average Movement(N) = SMA（|ERAMA(N) − 前一個 ERAMA(N)|，Flat Confirmation Period）
Normalized Movement(N) = Average Movement(N) ÷ ATR（14）

當 Normalized Movement 小於或等於 Flat Movement Threshold，該線會進入平坦狀態；只有在移動升穿門檻的 1.5 倍後才會退出。不同的進入及退出門檻形成遲滯，可減少邊界附近灰色與方向顏色的頻繁切換。

方向及平坦狀態只會在 K 線確認後更新；ERAMA 數值本身仍可隨目前未收市 K 線變化。

使用一條或兩條 ERAMA

每條 ERAMA 都可獨立作為具顏色狀態的趨勢線。使用者可根據自己的方法選擇顯示方式：
• 只顯示一條線，作為獨立趨勢工具
• 同時顯示兩條線，作為 Fast/Slow 組合
• 使用 ERAMA 1 觀察較短期趨勢，並以 ERAMA 2 作為較長期主趨勢

預設 EMA 長度為 20 與 200，但兩者都可調整。由於兩條線共用效率比率、Fast/Slow EMA 錨點及 WMA 基準，它們之間的差異來自平滑週期及按長度調整的延遲縮減。每條線都可獨立解讀。

如何閱讀 ERAMA Trend

綠色 — 上升
綠色表示已確認的正線性回歸斜率，而且目前不處於平坦狀態。價格維持在上升 ERAMA 之上，可支持該線所代表週期的偏多方向判斷。

紅色 — 下降
紅色表示已確認的負線性回歸斜率，而且目前不處於平坦狀態。價格維持在下降 ERAMA 之下，可支持該線所代表週期的偏空方向判斷。

灰色 — 平坦
灰色表示線條的平均移動相對 ATR 較小，常見於整固、壓縮或轉換階段。兩條線的平坦狀態獨立判斷，因此其中一條可以顯示灰色，而另一條仍保持方向顏色。

兩條線的方向配合

兩條 ERAMA 同時上升，表示短期與長期方向均偏上；兩者同時下降，則表示兩個週期均偏下。顏色不一致代表兩個週期的移動方向不同，可能出現在回調、早期反轉或較大型趨勢轉換期間。兩條線的相對位置及交叉，可進一步提供趨勢配合及轉換背景。

單色模式

關閉 Color Lines by Trend 後，狀態顏色會停用。ERAMA 1 會以水藍色顯示，ERAMA 2 則使用金色；兩條線的計算不會改變。

設定說明

Source
選擇共用價格序列。預設為 HLCC4，即 High、Low、Close、Close 的平均值。

ER Length
控制共用效率比率的計算期間。較低數值會更快反映近期路徑變化；較高數值則在較廣樣本內評估方向效率。

Fast Length
設定共用自適應混合使用的 Fast EMA 錨點。Fast Length 必須低於 Slow Length。

Slow Length
設定共用自適應混合使用的 Slow EMA 錨點。Slow Length 必須高於 Fast Length。

Responsiveness
控制部分 DEMA 式延遲修正的基本強度。較高數值會追回更多延遲，但亦可能增加轉向靈敏度及超調。

Responsiveness Length Decay
控制 EMA 長度高於 50 後，Responsiveness 隨長度下降的幅度。較高數值會對長週期線條施加較大降幅；設為 0 會停用按長度縮放。

WMA Smooth Length
控制兩條輸出分支之前的共用 WMA 階段。較高數值會形成更穩定但延遲更多的基準。

ERAMA 1 EMA Length
控制第一條線的平滑週期及延遲縮減週期，預設值為 20。

ERAMA 2 EMA Length
控制第二條線的平滑週期及延遲縮減週期，預設值為 200。

Color Lines by Trend
啟用每條線獨立的綠色、紅色及灰色狀態。關閉後，兩條線分別使用固定水藍色及金色。

Flat Confirmation Period
控制兩條線使用的回歸斜率及平均移動期間。較高數值會令狀態變化更穩定但較慢。

Flat Movement Threshold
設定每根 K 線平均 ERAMA 移動的上限，並以 ATR 單位表示。較高數值會把更多市況分類為平坦；每條線必須升穿門檻的 1.5 倍才會退出平坦狀態。

實際應用

ERAMA Trend 可作為具顏色狀態的趨勢基準、自適應回調參考、方向過濾器或趨勢管理工具。單一線條可代表使用者所選的趨勢週期；同時顯示兩條時，較短線可提供較早背景，較長線則用來界定主趨勢。

顏色可簡潔概括每條線的斜率及移動狀態。兩個可調整週期可與價格結構配合，建立適合使用者時間週期的趨勢解讀框架。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// ------------------------------------------------------------------------------
//  TradingFlow: ERAMA Trend
//
//  ERAMA balances smoothness and responsiveness across EMA lengths.
//  It uses the Efficiency Ratio to shift between fast and slow EMAs,
//  then smooths the blended result and applies length-adjusted lag reduction.
//
//  ER          = |source - source[ER length]| / sum(|change(source)|, ER length)
//  Adaptive    = slow EMA + ER * (fast EMA - slow EMA)
//  Smoothed    = EMA(WMA(Adaptive, WMA length), EMA length)
//  R effective = Responsiveness * min(1, 50 / EMA length)^Length Decay
//  ERAMA       = Smoothed + R effective * (Smoothed - EMA(Smoothed, EMA length))
// ------------------------------------------------------------------------------
indicator("TradingFlow: ERAMA Trend (ET) v1.0.0", "TF: ET", true, timeframe = "", timeframe_gaps = true)

// Shared ERAMA Inputs
float sourceInput  = input.source(hlcc4, "Source")
int   erLenInput   = input.int(10, "ER Length", 2)
int   fastLenInput = input.int(2,  "Fast Length", 1, tooltip = "Must be lower than Slow Length to preserve the intended adaptive response.")
int   slowLenInput = input.int(30, "Slow Length", 2, tooltip = "Must be higher than Fast Length to preserve the intended adaptive response.")
float responsivenessInput = input.float(0.88, "Responsiveness", minval = 0.00, maxval = 2.00, step = 0.01, tooltip = "Responsiveness at EMA lengths up to 50. It is reduced gradually for longer EMA lengths to control overshoot.")
float responsivenessDecayInput = input.float(0.15, "Responsiveness Length Decay", minval = 0.00, maxval = 1.00, step = 0.01, tooltip = "Controls how strongly responsiveness decreases above EMA 50. Set to 0 to disable length-based scaling.")
int   wmaLenInput  = input.int(12, "WMA Smooth Length", 1)

// ERAMA Line Inputs
const string ERAMA_LENGTHS_GROUP = "ERAMA Lengths"
int emaLen1Input = input.int(20, "ERAMA 1 EMA Length", 1, group = ERAMA_LENGTHS_GROUP)
int emaLen2Input = input.int(200, "ERAMA 2 EMA Length", 1, group = ERAMA_LENGTHS_GROUP)

if fastLenInput >= slowLenInput
    runtime.error("Fast Length must be lower than Slow Length.")

// Trend Display Inputs
const string DISPLAY_GROUP = "Display"
const float FLAT_EXIT_MULTIPLIER = 1.5
bool colorByTrendInput = input.bool(true, "Color Lines by Trend", group = DISPLAY_GROUP)
int flatPeriodInput = input.int(
     3, "Flat Confirmation Period", minval = 2, group = DISPLAY_GROUP, active = colorByTrendInput,
     tooltip = "Number of bars used to measure each ERAMA line and confirm a flat period.")
float flatThresholdInput = input.float(
     0.010, "Flat Movement Threshold (ATR per Bar)", minval = 0.000, step = 0.005, group = DISPLAY_GROUP, active = colorByTrendInput,
     tooltip = "Maximum average ERAMA movement per bar, measured as a fraction of ATR, that is considered flat.")

// 1. Adapt between the slow and fast EMAs using Kaufman's Efficiency Ratio.
float priceChange = math.abs(sourceInput - sourceInput[erLenInput])
float volatility = ta.sma(math.abs(ta.change(sourceInput)), erLenInput) * erLenInput
float efficiencyRatio = volatility == 0.0 ? 0.0 : priceChange / volatility
float fastEma = ta.ema(sourceInput, fastLenInput)
float slowEma = ta.ema(sourceInput, slowLenInput)
float adaptiveMa = slowEma + efficiencyRatio * (fastEma - slowEma)

// 2. Apply WMA and EMA smoothing, then lag reduction.
float wmaBase = ta.wma(adaptiveMa, wmaLenInput)
// ERAMA 1
float smoothed1 = ta.ema(wmaBase, emaLen1Input)
float responsivenessScale1 = math.pow(math.min(1.0, 50.0 / emaLen1Input), responsivenessDecayInput)
float effectiveResponsiveness1 = responsivenessInput * responsivenessScale1
float erama1 = smoothed1 + effectiveResponsiveness1 * (smoothed1 - ta.ema(smoothed1, emaLen1Input))
// ERAMA 2
float smoothed2 = ta.ema(wmaBase, emaLen2Input)
float responsivenessScale2 = math.pow(math.min(1.0, 50.0 / emaLen2Input), responsivenessDecayInput)
float effectiveResponsiveness2 = responsivenessInput * responsivenessScale2
float erama2 = smoothed2 + effectiveResponsiveness2 * (smoothed2 - ta.ema(smoothed2, emaLen2Input))

// Independent trend colors
float atrValue = math.max(ta.atr(14), syminfo.mintick)
// ERAMA 1
float lineSlope1 = ta.linreg(erama1, flatPeriodInput, 0) - ta.linreg(erama1, flatPeriodInput, 1)
float averageMovement1 = ta.sma(math.abs(ta.change(erama1)), flatPeriodInput)
float normalizedMovement1 = averageMovement1 / atrValue
bool flatSetup1 = not na(normalizedMovement1) and normalizedMovement1 <= flatThresholdInput
bool trendSetup1 = not na(normalizedMovement1) and normalizedMovement1 > flatThresholdInput * FLAT_EXIT_MULTIPLIER
// ERAMA 2
float lineSlope2 = ta.linreg(erama2, flatPeriodInput, 0) - ta.linreg(erama2, flatPeriodInput, 1)
float averageMovement2 = ta.sma(math.abs(ta.change(erama2)), flatPeriodInput)
float normalizedMovement2 = averageMovement2 / atrValue
bool flatSetup2 = not na(normalizedMovement2) and normalizedMovement2 <= flatThresholdInput
bool trendSetup2 = not na(normalizedMovement2) and normalizedMovement2 > flatThresholdInput * FLAT_EXIT_MULTIPLIER

var bool isFlat1 = false
var bool isFlat2 = false
var int trendDirection1 = 0
var int trendDirection2 = 0
if barstate.isconfirmed
    if not isFlat1 and flatSetup1
        isFlat1 := true
    else if isFlat1 and trendSetup1
        isFlat1 := false

    if not isFlat2 and flatSetup2
        isFlat2 := true
    else if isFlat2 and trendSetup2
        isFlat2 := false

    if lineSlope1 > 0.0
        trendDirection1 := 1
    else if lineSlope1 < 0.0
        trendDirection1 := -1

    if lineSlope2 > 0.0
        trendDirection2 := 1
    else if lineSlope2 < 0.0
        trendDirection2 := -1

color aqua = color.aqua
color green = #0bce5c
color red = #FF5252
color gray = #787B86
color gold = #F5B700

color directionalColor1 = trendDirection1 == 1 ? green : trendDirection1 == -1 ? red : aqua
color directionalColor2 = trendDirection2 == 1 ? green : trendDirection2 == -1 ? red : gold
color trendColor1 = isFlat1 ? gray : directionalColor1
color trendColor2 = isFlat2 ? gray : directionalColor2
color lineColor1 = colorByTrendInput ? trendColor1 : aqua
color lineColor2 = colorByTrendInput ? trendColor2 : gold

// Plot
plot(erama1, "ERAMA 1", color = lineColor1, linewidth = 2)
plot(erama2, "ERAMA 2", color = lineColor2, linewidth = 3)
````
