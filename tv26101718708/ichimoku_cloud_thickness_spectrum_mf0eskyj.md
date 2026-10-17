# Ichimoku Cloud Thickness Spectrum

- url: https://www.tradingview.com/script/mF0ESKYj-Ichimoku-Cloud-Thickness-Spectrum/
- type: indicator
- pine_id: PUB;97010d7e921247d1ae33b2b70273ad23
- version: 2.0

## Description

Overview

Ichimoku Cloud Thickness Spectrum is an overlay for studying the geometry and relative thickness of the projected Ichimoku cloud. It plots the classical Tenkan-sen, Kijun-sen, Senkou Span A, Senkou Span B, and an optional Chikou Span, then adds a configurable research layer derived only from the distance and relationship between the two Senkou spans.

The script is designed to make three questions easier to inspect:

- How wide is the projected cloud in a unit suited to the current instrument?
- How unusual is that width compared with the cloud's own recent history?
- Is the smoothed cloud thickness expanding, contracting, or comparatively stable?

This is a context and visualization tool. It does not generate buy or sell instructions, forecasts, targets, stops, position sizing, or performance claims.

Original contribution

Cloud thickness is a known Ichimoku concept. The original contribution of this implementation is the integrated workflow used to transform raw Span A/B distance into a configurable research display:

1. Selectable ATR, percentage, or raw-price normalization.
2. Rolling empirical percentile ranking of the selected thickness measure.
3. Percentile-weighted cloud opacity and an optional dense inner core.
4. A stabilized expansion/contraction spine with a near-zero denominator floor and release-ratio hysteresis.
5. Confirmed thin-cloud seams filtered by thin-state membership, two-sided prominence, and minimum spacing.
6. Directional projected-cloud twist markers.
7. Separate handling of the newly calculated forward cloud and the historically shifted cloud aligned with the current price bar.
8. A bilingual confirmed/live readout, confirmed-bar alerts, and Data Window diagnostics.

The classical Ichimoku formulas are standard, widely known calculations. The percentile, motion-state, seam-filtering, visualization, readout, and alert logic were implemented for this script. No source code from another Community Script is reused.

Core calculations

- Tenkan-sen: midpoint of the highest high and lowest low over the Conversion length.
- Kijun-sen: midpoint of the highest high and lowest low over the Base length.
- Senkou Span A: average of Tenkan-sen and Kijun-sen.
- Senkou Span B: midpoint of the highest high and lowest low over the Span B length.
- Raw cloud thickness: absolute distance between Senkou Span A and Senkou Span B.
- Cloud midpoint: average of Senkou Span A and Senkou Span B.

Thickness modes and percentile ranking

- ATR: raw cloud thickness divided by ATR. This is the default and relates cloud width to recent price range.
- Percent: raw cloud thickness divided by the absolute close, multiplied by 100.
- Raw: the unnormalized price distance between Span A and Span B.

The selected measure is ranked against its own rolling history with a percent-rank calculation. A reading near 10 is relatively thin within the selected lookback, while a reading near 90 is relatively thick. The result is specific to the symbol, timeframe, settings, and available history; it is not a universal market-strength score.

Stabilized expansion and contraction

The selected thickness measure is smoothed with an EMA. A one-bar percentage change is then calculated. Near a cloud twist, Span A and Span B can converge and the previous thickness can approach zero, which can make an unrestricted percentage change unstable. To reduce this effect, the denominator cannot fall below a configurable fraction of a slower EMA baseline.

The state classifier also uses release-ratio hysteresis. Entry into expansion or contraction requires the main sensitivity threshold, while release from an existing state uses a smaller configurable threshold. This reduces bar-to-bar color chatter. The state uses the previous bar and does not rely on intrabar-only persistent memory.

Visual interpretation

- Teal cloud: Senkou Span A is at or above Senkou Span B.
- Red cloud: Senkou Span A is below Senkou Span B.
- More transparent cloud: lower thickness percentile.
- More visible cloud: higher thickness percentile.
- Dense inner core: optional emphasis when thickness percentile is above the selected threshold.
- Blue midpoint spine: thickness is in an expanding state.
- Purple midpoint spine: thickness is in a contracting state.
- Gray midpoint spine: thickness motion is inside the release threshold.
- Yellow upward/downward triangle: confirmed bullish/bearish projected-cloud twist.
- Small pink X: confirmed local thin-cloud seam that passed the thin-state, prominence, and spacing filters.

The cloud opacity and inner core encode relative thickness only. They do not guarantee support, resistance, continuation, reversal, or breakout behavior.

Filtered thin-cloud seams

A thin seam is not every low-thickness bar. It must be a confirmed local minimum in the thickness percentile, remain at or below the user-defined thin threshold, rebound by at least the selected prominence on both sides, and pass the minimum-spacing filter.

The pivot becomes known only after the selected number of right-side bars has closed. By default, a marker is not placed to the left of the bar where confirmation became available. The optional Allow seam placement before confirmation setting can place the marker at the original pivot-projected cloud position after confirmation. This changes the visual location only and does not make the event available earlier.

Projected cloud versus current aligned cloud

The newly calculated Span A and Span B values are displayed forward by the selected displacement. This positive offset shifts calculations made from current and historical bars into future chart positions; it does not access future market data.

Price-context calculations use a different alignment. They reference the historically shifted spans that are actually visible at the current price bar. Optional inside-cloud highlighting and current-cloud transition alerts therefore do not compare current price with the newly calculated cloud plotted in the future.

Forward readout, alerts, and research outputs

The three-line readout displays the thickness state and percentile, the selected normalized thickness value and motion state, and the future-cloud direction with Live or Confirmed status. English is the default. Japanese changes the readout, hover tooltip, and combined dynamic alert messages; input names and tooltips are bilingual.

Use confirmed values in readout is enabled by default. While the latest realtime bar is open, the label uses the previous closed bar. Once the latest bar is confirmed, it uses that bar. Users can disable the setting to inspect the open realtime bar, in which case the label shows Live and may change until close.

Confirmed-bar alert conditions are available for projected twists, thin/thick state transitions, current-cloud position transitions, expansion/contraction changes, and filtered thin seams. A combined bilingual alert is also available through Any alert() function call. Additional raw, normalized, percentile, motion, seam, current-cloud, direction, and state values are provided in the Data Window.

Realtime behavior and limitations

The script does not use request.security(), lookahead, or future bars. On an open realtime bar, Tenkan-sen, Kijun-sen, the projected spans, cloud opacity, and motion state can update as the bar's high, low, and close change. Confirmed historical values do not use intrabar-only memory. The supplied alert conditions are evaluated on confirmed bars, and the combined alert() call uses once-per-bar-close frequency.

Percentile readings require sufficient history and can show a warming-up state. Results depend on the symbol, timeframe, Ichimoku lengths, normalization basis, percentile lookback, and available data. Non-time-based charts and sparse datasets may behave differently from standard time-based candles.

A thick cloud is not automatically strong support or resistance. A thin or contracting cloud is not a breakout prediction. This script provides research context and should be combined with the user's own analysis and risk process.

日本語概要

Ichimoku Cloud Thickness Spectrumは、一目均衡表の将来雲について、方向だけでなく、厚み、履歴内の相対順位、拡大・収縮状態を研究するためのオーバーレイ型インジケーターです。転換線、基準線、先行スパン1・2、任意の遅行スパンを表示し、追加分析はすべて先行スパン1と2の距離および関係から算出します。

主な特徴

- 雲の厚みをATR比率、価格比率、価格差から選択可能。
- 選択した厚みを直近履歴内のパーセンタイルへ変換。
- 厚み順位を雲の透明度と任意の高密度インナーコアへ反映。
- ゼロ近傍の分母下限とヒステリシスを備えた拡大・収縮中心線。
- 薄い状態、左右プロミネンス、最小間隔を満たした確認済み局所薄化点。
- 上向き・下向きを分けた確認済み将来雲ツイスト。
- 将来へ描画する新規計算雲と、現在価格バーへ整列した過去計算雲を分離。
- 英語・日本語を切り替えられる将来ラベル、確定足アラート、データウィンドウ研究値。

雲の厚みという概念自体は既知です。本実装の差異は、生の雲幅を正規化し、履歴順位化し、厚みの動きを安定化し、薄化点を確認・選別し、それらを一貫した視覚表現と研究出力へ統合している点です。標準一目均衡表の計算式は広く知られた古典計算であり、追加した順位化、状態判定、薄化点フィルター、表示、ラベル、アラートのロジックは本スクリプト用に実装しています。他のCommunity Scriptのソースコードは再利用していません。

表示の読み方

- 青緑の雲: 先行スパン1が先行スパン2以上。
- 赤の雲: 先行スパン1が先行スパン2未満。
- 透明度が高い雲: 厚み順位が低い。
- 濃い雲とインナーコア: 厚み順位が高い。
- 青の中心線: 厚みが拡大状態。
- 紫の中心線: 厚みが収縮状態。
- 灰色の中心線: 安定状態。
- 黄色の三角: 確認済みの上向き・下向き将来雲ツイスト。
- 小さなピンクのX: 条件を満たした確認済み局所薄化点。

厚み順位は銘柄、時間足、設定、参照期間、利用可能な履歴に依存する相対値です。雲の濃さやインナーコアは支持抵抗の保証ではありません。

確認、シフト、ライブ動作

将来雲は、現在および過去バーから計算した先行スパンを正のoffsetで将来位置へ描画したもので、未来データを取得していません。現在価格との関係には、現在バー上に実際に整列している過去計算の先行スパンを使用します。

薄化点は右側に指定本数の確定バーを必要とするため、認識に意図的な遅延があります。初期設定では確認可能になったバーより左側へ表示しません。任意設定で元の投影位置へ表示する場合も、認識自体は確認後です。

未確定リアルタイムバーでは、高値・安値・終値の更新に伴い、転換線、基準線、先行スパン、雲の透明度、拡大・収縮状態が終値確定まで変化する場合があります。将来ラベルは初期設定で確定値を使用し、用意したアラートは確定足で判定します。

本インジケーターは研究・可視化ツールです。売買指示、将来予測、目標価格、損切り、ポジションサイズ、成績統計、投資助言を提供しません。厚い雲を必ず強い支持抵抗、薄い雲や収縮中の雲を必ずブレイクする状態とは定義していません。

## Source Code

````pine
//@version=6
indicator("Ichimoku Cloud Thickness Spectrum", overlay = true, behind_chart = true, max_labels_count = 10)

// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// © SG_Group
// Original implementation built from standard Ichimoku formulas and Pine Script built-ins.
// Public update 1.3.2: improved interface readability and consistency across settings, tooltips,
// the forward readout and dynamic alerts while preserving all calculations and behavior.

//------------------------------------------------------------------------------
// Constants and utility functions
//------------------------------------------------------------------------------
const string G_GENERAL   = "1. General"
const string G_STRUCTURE = "2. Ichimoku Structure"
const string G_THICKNESS = "3. Thickness Research"
const string G_VISUALS   = "4. Visuals"
const string G_EVENTS    = "5. Events and Alerts"
const string G_COLORS    = "6. Colors"

const string TT_OFFSET   = "Sets the Ichimoku displacement. The separate alignment option chooses TradingView-compatible Displacement - 1 or the exact entered bar count."
const string TT_BASIS    = "ATR: cloud width divided by ATR. Percent: cloud width divided by absolute close and multiplied by 100. Raw: unnormalized price distance."
const string TT_RANK     = "Ranks the selected thickness measure against its own recent history. The result is relative to the symbol, timeframe and lookback."
const string TT_MOTION   = "Prevents percentage-change spikes when smoothed cloud thickness approaches zero near a twist. The change denominator cannot fall below this percentage of a slower EMA baseline whose length is max(10, smoothing x 4). Set a very small value to approximate the original unrestricted calculation."
const string TT_HYSTERESIS = "Sets the release threshold as a percentage of the entry sensitivity. Lower values hold an expansion/contraction state longer and reduce bar-to-bar color chatter; 100% disables hysteresis. The state uses only the previous bar, not intrabar varip memory, so confirmed historical and realtime results remain reproducible."
const string TT_CORE     = "Shows a denser inner band only when thickness percentile is at or above the selected threshold. This is a visual encoding, not a support/resistance guarantee."
const string TT_SEAM     = "Marks confirmed local minima in thickness percentile. A seam must be inside the thin state, rebound by the minimum prominence on both sides, and pass the minimum spacing filter. It is known only after the required right-side bars have closed."
const string TT_SEAM_POS = "When enabled, the marker may be placed left of the confirmation bar if the original pivot-projected cloud position is earlier. The pivot is still detected only after all required right-side bars close. This option changes presentation only and does not provide earlier knowledge."
const string TT_CURRENT  = "Uses the historically shifted spans that are visible at the current price bar, rather than the newly calculated cloud projected into the future."
const string TT_CONTRAST = "Automatically selects white or near-black text from the readout background brightness. Disable it to use the manual Readout text color setting."

f_midrange(int length) =>
    (ta.highest(high, length) + ta.lowest(low, length)) / 2.0

f_append(string baseText, string newText) =>
    str.length(baseText) == 0 ? newText : baseText + " | " + newText

f_rank_state(float rankValue, float thinLevel, float thickLevel, float extremeLevel) =>
    string result = na(rankValue) ? "Warming up" :
      rankValue <= thinLevel ? "Thin" :
      rankValue >= extremeLevel ? "Extreme" :
      rankValue >= thickLevel ? "Thick" :
      "Balanced"
    result

f_measure_text(float value, string basis) =>
    string result = switch basis
        "ATR" => na(value) ? "n/a" : str.tostring(value, "#.##") + " ATR"
        "Percent" => na(value) ? "n/a" : str.tostring(value, "#.##") + "%"
        => na(value) ? "n/a" : str.tostring(value, format.mintick)
    result

f_readable_text_color(color backgroundColor, color manualColor, bool automatic) =>
    float brightness = color.r(backgroundColor) * 0.299 + color.g(backgroundColor) * 0.587 + color.b(backgroundColor) * 0.114
    automatic ? (brightness >= 160.0 ? color.rgb(24, 24, 24) : color.white) : manualColor

//------------------------------------------------------------------------------
// Inputs
// Every input uses display.none so the chart legend shows only the indicator name.
//------------------------------------------------------------------------------
bool useConfirmedReadout = input.bool(true, "Use confirmed values in readout", tooltip = "When enabled, the readout substitutes the previous closed bar only while the latest realtime bar is still open. Once the latest bar is confirmed, the readout uses that bar. The plotted cloud itself continues to update normally.", group = G_GENERAL, display = display.none)

int conversionLength = input.int(9, "Conversion length (Tenkan)", minval = 1, maxval = 500, group = G_STRUCTURE, display = display.none)
int baseLength = input.int(26, "Base length (Kijun)", minval = 1, maxval = 500, group = G_STRUCTURE, display = display.none)
int spanBLength = input.int(52, "Leading Span B length", minval = 1, maxval = 1000, group = G_STRUCTURE, display = display.none)
int displacement = input.int(26, "Displacement", minval = 1, maxval = 100, tooltip = TT_OFFSET, group = G_STRUCTURE, display = display.none)
string alignmentMode = input.string("TradingView-compatible", "Offset alignment", options = ["TradingView-compatible", "Exact bar count"], tooltip = "TradingView-compatible uses Displacement - 1, matching TradingView's built-in visual alignment. Exact bar count uses the entered value directly.", group = G_STRUCTURE, display = display.none)
bool showTenkan = input.bool(true, "Show Tenkan", group = G_STRUCTURE, inline = "lines1", display = display.none)
bool showKijun = input.bool(true, "Show Kijun", group = G_STRUCTURE, inline = "lines1", display = display.none)
bool showChikou = input.bool(false, "Show Chikou", group = G_STRUCTURE, display = display.none)
int tenkanWidth = input.int(2, "Tenkan width", minval = 1, maxval = 4, group = G_STRUCTURE, inline = "widths1", display = display.none)
int kijunWidth = input.int(2, "Kijun width", minval = 1, maxval = 4, group = G_STRUCTURE, inline = "widths1", display = display.none)
int chikouWidth = input.int(1, "Chikou width", minval = 1, maxval = 4, group = G_STRUCTURE, inline = "widths2", display = display.none)
int cloudEdgeWidth = input.int(1, "Cloud edge width", minval = 1, maxval = 4, group = G_STRUCTURE, inline = "widths2", display = display.none)

string thicknessBasis = input.string("ATR", "Thickness basis", options = ["ATR", "Percent", "Raw"], tooltip = TT_BASIS, group = G_THICKNESS, display = display.none)
int atrLength = input.int(26, "ATR length", minval = 1, maxval = 500, group = G_THICKNESS, active = thicknessBasis == "ATR", display = display.none)
int rankLookback = input.int(252, "Percentile lookback", minval = 20, maxval = 2000, tooltip = TT_RANK, group = G_THICKNESS, display = display.none)
int thicknessSmoothing = input.int(5, "Expansion smoothing", minval = 1, maxval = 100, group = G_THICKNESS, display = display.none)
float expansionSensitivity = input.float(0.35, "Expansion sensitivity (%)", minval = 0.0, maxval = 25.0, step = 0.05, tooltip = "Minimum one-bar stabilized percentage change in the smoothed thickness measure required to enter expansion or contraction.", group = G_THICKNESS, display = display.none)
float motionReleasePercent = input.float(55.0, "Motion release ratio (%)", minval = 0.0, maxval = 100.0, step = 5.0, tooltip = TT_HYSTERESIS, group = G_THICKNESS, display = display.none)
float motionFloorPercent = input.float(5.0, "Near-zero motion floor (%)", minval = 0.1, maxval = 50.0, step = 0.5, tooltip = TT_MOTION, group = G_THICKNESS, display = display.none)
float thinRankInput = input.float(20.0, "Thin threshold percentile", minval = 1.0, maxval = 49.0, step = 1.0, group = G_THICKNESS, inline = "rankcuts", display = display.none)
float thickRankInput = input.float(70.0, "Thick threshold percentile", minval = 51.0, maxval = 95.0, step = 1.0, group = G_THICKNESS, inline = "rankcuts", display = display.none)
float extremeRankInput = input.float(90.0, "Extreme threshold percentile", minval = 60.0, maxval = 100.0, step = 1.0, group = G_THICKNESS, display = display.none)

bool showCloud = input.bool(true, "Show cloud", group = G_VISUALS, display = display.none)
bool showCloudEdges = input.bool(true, "Show Span A and B edges", group = G_VISUALS, display = display.none)
bool showEquilibriumSpine = input.bool(true, "Show expansion spine", tooltip = "Plots the midpoint of Span A and Span B. Its color identifies expansion, contraction or stability of the smoothed thickness measure.", group = G_VISUALS, display = display.none)
int spineWidth = input.int(2, "Expansion spine width", minval = 1, maxval = 4, group = G_VISUALS, active = showEquilibriumSpine, display = display.none)
bool showDenseCore = input.bool(true, "Show dense inner core", tooltip = TT_CORE, group = G_VISUALS, display = display.none)
float coreWidthPercent = input.float(38.0, "Core width (% of cloud)", minval = 5.0, maxval = 90.0, step = 1.0, group = G_VISUALS, inline = "core", active = showCloud and showDenseCore, display = display.none)
float coreMinimumRank = input.float(60.0, "Core minimum percentile", minval = 0.0, maxval = 100.0, step = 1.0, group = G_VISUALS, inline = "core", active = showCloud and showDenseCore, display = display.none)
int thinCloudTransparency = input.int(92, "Thin cloud transparency", minval = 0, maxval = 100, group = G_VISUALS, inline = "opacity", display = display.none)
int thickCloudTransparency = input.int(67, "Thick cloud transparency", minval = 0, maxval = 100, group = G_VISUALS, inline = "opacity", display = display.none)
int coreOpacityBoost = input.int(16, "Core opacity boost", minval = 0, maxval = 60, group = G_VISUALS, active = showCloud and showDenseCore, display = display.none)
bool showForwardReadout = input.bool(true, "Show forward thickness readout", group = G_VISUALS, display = display.none)
int readoutTextSize = input.int(12, "Readout text size", minval = 8, maxval = 24, step = 1, group = G_VISUALS, inline = "readout1", active = showForwardReadout, display = display.none)
int readoutTransparency = input.int(4, "Readout transparency", minval = 0, maxval = 100, group = G_VISUALS, inline = "readout1", active = showForwardReadout, display = display.none)
bool readoutBold = input.bool(true, "Bold readout text", group = G_VISUALS, inline = "readout2", active = showForwardReadout, display = display.none)
bool autoReadoutTextContrast = input.bool(true, "Automatic text contrast", tooltip = TT_CONTRAST, group = G_VISUALS, inline = "readout2", active = showForwardReadout, display = display.none)
bool showReadoutStatus = input.bool(true, "Show Live/Confirmed tag", group = G_VISUALS, active = showForwardReadout, display = display.none)
int readoutHorizontalShift = input.int(0, "Readout horizontal shift (bars)", minval = -25, maxval = 50, step = 1, tooltip = "Moves only the forward readout horizontally relative to its projected cloud point. It does not change any calculation or alert.", group = G_VISUALS, active = showForwardReadout, display = display.none)
bool highlightPriceInsideCloud = input.bool(false, "Highlight closes inside current cloud", tooltip = TT_CURRENT, group = G_VISUALS, display = display.none)
int insideBarTransparency = input.int(20, "Inside-cloud bar transparency", minval = 0, maxval = 100, group = G_VISUALS, active = highlightPriceInsideCloud, display = display.none)

bool showTwistMarkers = input.bool(true, "Show future twist markers", group = G_EVENTS, display = display.none)
bool showThinSeams = input.bool(true, "Show confirmed thin seams", tooltip = TT_SEAM, group = G_EVENTS, display = display.none)
int seamPivotBars = input.int(3, "Thin-seam pivot bars", minval = 1, maxval = 20, group = G_EVENTS, active = showThinSeams, display = display.none)
float seamMinProminence = input.float(5.0, "Minimum seam prominence", minval = 0.0, maxval = 50.0, step = 0.5, tooltip = "Required rebound in percentile points on both sides of the pivot. Set 0 to disable this filter.", group = G_EVENTS, active = showThinSeams, display = display.none)
int seamMinSpacingBars = input.int(8, "Minimum seam spacing", minval = 0, maxval = 250, tooltip = "Minimum number of source bars between accepted seams. Set 0 to disable this filter.", group = G_EVENTS, active = showThinSeams, display = display.none)
bool allowSeamBeforeConfirmation = input.bool(false, "Allow seam placement before confirmation", tooltip = TT_SEAM_POS, group = G_EVENTS, active = showThinSeams, display = display.none)
bool enableDynamicAlerts = input.bool(true, "Enable dynamic alerts", tooltip = "Create an alert using 'Any alert() function call' to receive dynamic event messages. Separate alertcondition choices are also available.", group = G_EVENTS, display = display.none)

color tenkanColor = input.color(color.rgb(0, 188, 212), "Tenkan color", group = G_COLORS, display = display.none)
color kijunColor = input.color(color.rgb(255, 152, 0), "Kijun color", group = G_COLORS, display = display.none)
color chikouColor = input.color(color.rgb(156, 39, 176), "Chikou color", group = G_COLORS, display = display.none)
color spanAColor = input.color(color.rgb(38, 166, 154), "Span A edge", group = G_COLORS, display = display.none)
color spanBColor = input.color(color.rgb(239, 83, 80), "Span B edge", group = G_COLORS, display = display.none)
color bullishCloudColor = input.color(color.rgb(0, 150, 136), "Bullish cloud", group = G_COLORS, display = display.none)
color bearishCloudColor = input.color(color.rgb(229, 57, 53), "Bearish cloud", group = G_COLORS, display = display.none)
color expandingSpineColor = input.color(color.rgb(41, 121, 255), "Expanding spine", group = G_COLORS, display = display.none)
color contractingSpineColor = input.color(color.rgb(126, 87, 194), "Contracting spine", group = G_COLORS, display = display.none)
color stableSpineColor = input.color(color.rgb(158, 158, 158), "Stable spine", group = G_COLORS, display = display.none)
color twistMarkerColor = input.color(color.rgb(255, 235, 59), "Twist marker", group = G_COLORS, display = display.none)
color thinSeamColor = input.color(color.rgb(255, 64, 129), "Thin-seam marker", group = G_COLORS, display = display.none)
color insideCloudBarColor = input.color(color.rgb(255, 193, 7), "Inside-cloud bars", group = G_COLORS, display = display.none)
color bullishReadoutColor = input.color(color.rgb(0, 105, 92), "Bullish readout background", group = G_COLORS, display = display.none)
color bearishReadoutColor = input.color(color.rgb(183, 28, 28), "Bearish readout background", group = G_COLORS, display = display.none)
color readoutTextColor = input.color(color.white, "Manual readout text", group = G_COLORS, active = not autoReadoutTextContrast, display = display.none)

//------------------------------------------------------------------------------
// Classical Ichimoku structure
//------------------------------------------------------------------------------
int cloudOffset = alignmentMode == "TradingView-compatible" ? displacement - 1 : displacement
float tenkan = f_midrange(conversionLength)
float kijun = f_midrange(baseLength)
float spanA = (tenkan + kijun) / 2.0
float spanB = f_midrange(spanBLength)
bool cloudReady = not na(spanA) and not na(spanB)
float cloudMid = cloudReady ? (spanA + spanB) / 2.0 : na
float rawThickness = cloudReady ? math.abs(spanA - spanB) : na
bool bullishCloud = cloudReady and spanA >= spanB

//------------------------------------------------------------------------------
// Thickness normalization, percentile spectrum and expansion state
//------------------------------------------------------------------------------
float atrValue = ta.atr(atrLength)
float thicknessMeasure = switch thicknessBasis
    "ATR" => not na(rawThickness) and atrValue > 0.0 ? rawThickness / atrValue : na
    "Percent" => not na(rawThickness) and math.abs(close) > 0.0 ? rawThickness / math.abs(close) * 100.0 : na
    => rawThickness

float thicknessRank = ta.percentrank(thicknessMeasure, rankLookback)
float smoothedThickness = ta.ema(thicknessMeasure, thicknessSmoothing)
float priorSmoothedThickness = smoothedThickness[1]
int motionBaselineLength = math.max(10, thicknessSmoothing * 4)
float motionBaseline = ta.ema(smoothedThickness, motionBaselineLength)
float motionFloor = math.max(nz(math.abs(motionBaseline), 0.0) * motionFloorPercent / 100.0, 0.0000000001)
float motionDenominator = math.max(nz(math.abs(priorSmoothedThickness), 0.0), motionFloor)
float thicknessChangePercent = not na(smoothedThickness) and not na(priorSmoothedThickness) ?
  (smoothedThickness - priorSmoothedThickness) / motionDenominator * 100.0 : 0.0
float motionReleaseSensitivity = expansionSensitivity * motionReleasePercent / 100.0
var int motionState = 0
int priorMotionState = nz(motionState[1], 0)
if na(smoothedThickness) or na(priorSmoothedThickness)
    motionState := 0
else if thicknessChangePercent > expansionSensitivity
    motionState := 1
else if thicknessChangePercent < -expansionSensitivity
    motionState := -1
else if priorMotionState == 1 and thicknessChangePercent > motionReleaseSensitivity
    motionState := 1
else if priorMotionState == -1 and thicknessChangePercent < -motionReleaseSensitivity
    motionState := -1
else
    motionState := 0
bool isExpanding = motionState == 1
bool isContracting = motionState == -1
bool beginsExpanding = isExpanding and priorMotionState != 1
bool beginsContracting = isContracting and priorMotionState != -1

float thinRank = thinRankInput
float thickRank = thickRankInput
float extremeRank = math.min(100.0, math.max(extremeRankInput, thickRank + 1.0))
float rankForVisual = math.max(0.0, math.min(100.0, nz(thicknessRank, 50.0)))
float transparencyFloat = thinCloudTransparency + (thickCloudTransparency - thinCloudTransparency) * rankForVisual / 100.0
int cloudTransparency = int(math.max(0.0, math.min(100.0, math.round(transparencyFloat))))
int coreTransparency = int(math.max(0.0, cloudTransparency - coreOpacityBoost))
color cloudBaseColor = bullishCloud ? bullishCloudColor : bearishCloudColor
color cloudFillColor = showCloud and cloudReady ? color.new(cloudBaseColor, cloudTransparency) : na
color coreFillColor = showCloud and showDenseCore and cloudReady and rankForVisual >= coreMinimumRank ? color.new(cloudBaseColor, coreTransparency) : na
color spineColor = isExpanding ? expandingSpineColor : isContracting ? contractingSpineColor : stableSpineColor

float coreHalfWidth = rawThickness * coreWidthPercent / 200.0
float coreUpper = cloudReady ? cloudMid + coreHalfWidth : na
float coreLower = cloudReady ? cloudMid - coreHalfWidth : na

//------------------------------------------------------------------------------
// Current visible cloud alignment for price-context research
//------------------------------------------------------------------------------
float currentSpanA = spanA[cloudOffset]
float currentSpanB = spanB[cloudOffset]
bool currentCloudReady = not na(currentSpanA) and not na(currentSpanB)
float currentCloudUpper = currentCloudReady ? math.max(currentSpanA, currentSpanB) : na
float currentCloudLower = currentCloudReady ? math.min(currentSpanA, currentSpanB) : na
bool priceInsideCurrentCloud = currentCloudReady and close <= currentCloudUpper and close >= currentCloudLower
bool priceCrossAboveCurrentCloud = ta.crossover(close, currentCloudUpper)
bool priceCrossBelowCurrentCloud = ta.crossunder(close, currentCloudLower)
bool priceBreakAboveCurrentCloud = currentCloudReady and priceCrossAboveCurrentCloud
bool priceBreakBelowCurrentCloud = currentCloudReady and priceCrossBelowCurrentCloud
float priceCloudPosition = not currentCloudReady ? na : close > currentCloudUpper ? 1.0 : close < currentCloudLower ? -1.0 : 0.0
float thicknessStateCode = na(thicknessRank) ? na : thicknessRank <= thinRank ? 1.0 : thicknessRank >= extremeRank ? 4.0 : thicknessRank >= thickRank ? 3.0 : 2.0
float cloudMotionCode = isExpanding ? 1.0 : isContracting ? -1.0 : 0.0
float futureCloudDirectionCode = not cloudReady ? na : bullishCloud ? 1.0 : -1.0

//------------------------------------------------------------------------------
// Event logic
//------------------------------------------------------------------------------
bool bullishFutureTwist = ta.crossover(spanA, spanB)
bool bearishFutureTwist = ta.crossunder(spanA, spanB)
bool confirmedBullishFutureTwist = barstate.isconfirmed and bullishFutureTwist
bool confirmedBearishFutureTwist = barstate.isconfirmed and bearishFutureTwist
bool confirmedFutureCloudTwist = confirmedBullishFutureTwist or confirmedBearishFutureTwist

bool entersThinState = ta.crossunder(thicknessRank, thinRank)
bool leavesThinState = ta.crossover(thicknessRank, thinRank)
bool entersThickState = ta.crossover(thicknessRank, thickRank)

float thinRankPivot = ta.pivotlow(thicknessRank, seamPivotBars, seamPivotBars)
float seamLeftShoulderRank = ta.highest(thicknessRank[seamPivotBars + 1], seamPivotBars)
float seamRightShoulderRank = ta.highest(thicknessRank, seamPivotBars)
float thinSeamProminence = not na(thinRankPivot) and not na(seamLeftShoulderRank) and not na(seamRightShoulderRank) ?
  math.max(0.0, math.min(seamLeftShoulderRank - thinRankPivot, seamRightShoulderRank - thinRankPivot)) : na
int seamSourceBar = bar_index - seamPivotBars
var int lastThinSeamSourceBar = na
bool seamSpacingPass = na(lastThinSeamSourceBar) or seamSourceBar - lastThinSeamSourceBar >= seamMinSpacingBars
bool confirmedThinSeam = barstate.isconfirmed and not na(thinRankPivot) and thinRankPivot <= thinRank and
  nz(thinSeamProminence, 0.0) >= seamMinProminence and seamSpacingPass
if confirmedThinSeam
    lastThinSeamSourceBar := seamSourceBar

float thinSeamPrice = confirmedThinSeam ? cloudMid[seamPivotBars] : na
int requestedSeamOffset = cloudOffset - seamPivotBars
int seamPlotOffset = allowSeamBeforeConfirmation ? requestedSeamOffset : math.max(0, requestedSeamOffset)

//------------------------------------------------------------------------------
// Main plots
//------------------------------------------------------------------------------
plot(showTenkan ? tenkan : na, title = "Tenkan-sen", color = tenkanColor, linewidth = tenkanWidth, editable = false, display = display.pane + display.data_window)
plot(showKijun ? kijun : na, title = "Kijun-sen", color = kijunColor, linewidth = kijunWidth, editable = false, display = display.pane + display.data_window)
plot(showChikou ? close : na, title = "Chikou Span", color = chikouColor, linewidth = chikouWidth, offset = -cloudOffset, editable = false, display = display.pane + display.data_window)

spanAPlot = plot(spanA, title = "Senkou Span A", color = showCloudEdges ? spanAColor : na, linewidth = cloudEdgeWidth, offset = cloudOffset, editable = false, display = display.pane + display.data_window)
spanBPlot = plot(spanB, title = "Senkou Span B", color = showCloudEdges ? spanBColor : na, linewidth = cloudEdgeWidth, offset = cloudOffset, editable = false, display = display.pane + display.data_window)
fill(spanAPlot, spanBPlot, color = cloudFillColor, title = "Percentile-weighted cloud", editable = false, display = display.all)

coreUpperPlot = plot(showCloud and showDenseCore ? coreUpper : na, title = "Dense core upper", color = na, offset = cloudOffset, editable = false, display = display.pane)
coreLowerPlot = plot(showCloud and showDenseCore ? coreLower : na, title = "Dense core lower", color = na, offset = cloudOffset, editable = false, display = display.pane)
fill(coreUpperPlot, coreLowerPlot, color = coreFillColor, title = "Dense inner core", editable = false, display = display.all)

plot(showEquilibriumSpine ? cloudMid : na, title = "Cloud expansion spine", color = spineColor, linewidth = spineWidth, offset = cloudOffset, editable = false, display = display.pane)
plotshape(showTwistMarkers and confirmedBullishFutureTwist ? cloudMid : na, title = "Bullish future cloud twist", style = shape.triangleup, location = location.absolute, color = twistMarkerColor, offset = cloudOffset, size = size.tiny, editable = false, display = display.pane)
plotshape(showTwistMarkers and confirmedBearishFutureTwist ? cloudMid : na, title = "Bearish future cloud twist", style = shape.triangledown, location = location.absolute, color = twistMarkerColor, offset = cloudOffset, size = size.tiny, editable = false, display = display.pane)
plotshape(showThinSeams ? thinSeamPrice : na, title = "Confirmed thin seam", style = shape.xcross, location = location.absolute, color = thinSeamColor, offset = seamPlotOffset, size = size.tiny, editable = false, display = display.pane)

color insideBarColor = highlightPriceInsideCloud and priceInsideCurrentCloud ? color.new(insideCloudBarColor, insideBarTransparency) : na
barcolor(insideBarColor, title = "Price inside current cloud", editable = false, display = display.all)

// Research outputs remain out of the legend and price scale, but are available in the Data Window.
plot(rawThickness, title = "Raw Cloud Thickness", editable = false, display = display.data_window)
plot(thicknessMeasure, title = "Cloud Thickness Measure", editable = false, display = display.data_window)
plot(thicknessRank, title = "Cloud Thickness Percentile", editable = false, display = display.data_window)
plot(smoothedThickness, title = "Smoothed Cloud Thickness", editable = false, display = display.data_window)
plot(thicknessChangePercent, title = "Stabilized Cloud Thickness Change Percent", editable = false, display = display.data_window)
plot(motionDenominator, title = "Cloud Motion Denominator", editable = false, display = display.data_window)
plot(motionReleaseSensitivity, title = "Cloud Motion Release Threshold", editable = false, display = display.data_window)
plot(thinSeamProminence, title = "Thin Seam Prominence", editable = false, display = display.data_window)
plot(currentCloudUpper, title = "Current Cloud Upper", editable = false, display = display.data_window)
plot(currentCloudLower, title = "Current Cloud Lower", editable = false, display = display.data_window)
plot(priceCloudPosition, title = "Price Cloud Position Code", editable = false, display = display.data_window)
plot(thicknessStateCode, title = "Thickness State Code", editable = false, display = display.data_window)
plot(cloudMotionCode, title = "Cloud Motion Code", editable = false, display = display.data_window)
plot(futureCloudDirectionCode, title = "Future Cloud Direction Code", editable = false, display = display.data_window)

//------------------------------------------------------------------------------
// Forward readout
//------------------------------------------------------------------------------
bool openRealtimeBar = barstate.isrealtime and not barstate.isconfirmed
bool readoutUsesPreviousBar = useConfirmedReadout and openRealtimeBar
int readoutShift = readoutUsesPreviousBar ? 1 : 0
float readoutRawThickness = rawThickness[readoutShift]
float readoutMeasure = thicknessMeasure[readoutShift]
float readoutRank = thicknessRank[readoutShift]
float readoutChangePercent = thicknessChangePercent[readoutShift]
float readoutMid = cloudMid[readoutShift]
bool readoutBullish = bullishCloud[readoutShift]
bool readoutExpanding = isExpanding[readoutShift]
bool readoutContracting = isContracting[readoutShift]
bool readoutIsLive = not useConfirmedReadout and openRealtimeBar
color readoutBaseColor = readoutBullish ? bullishReadoutColor : bearishReadoutColor
color effectiveReadoutTextColor = f_readable_text_color(readoutBaseColor, readoutTextColor, autoReadoutTextContrast)
readoutFormatting = readoutBold ? text.format_bold : text.format_none

string measureText = f_measure_text(readoutMeasure, thicknessBasis)
string rankText = na(readoutRank) ? "n/a" : str.tostring(readoutRank, "#")
string stateText = f_rank_state(readoutRank, thinRank, thickRank, extremeRank)
string motionText = readoutExpanding ? "Expanding" : readoutContracting ? "Contracting" : "Stable"
string directionText = readoutBullish ? "Bullish cloud" : "Bearish cloud"
string statusText = readoutIsLive ? "Live" : "Confirmed"
string statusSuffix = showReadoutStatus ? "  •  " + statusText : ""
string readoutText = stateText + "  •  P" + rankText + "\n" + measureText + "  •  " + motionText + "\n" + directionText + statusSuffix

string rawThicknessText = na(readoutRawThickness) ? "n/a" : str.tostring(readoutRawThickness, format.mintick)
string changeText = na(readoutChangePercent) ? "n/a" : str.tostring(readoutChangePercent, "#.##") + "%"
string modeDetail = readoutUsesPreviousBar ?
  "Uses the previous closed bar instead of the open realtime bar." : readoutIsLive ?
  "Uses the open realtime bar and can change until close." :
  "Uses the latest confirmed bar."
string readoutTooltip = "Forward cloud thickness\nRaw width: " + rawThicknessText + "\nNormalized: " + measureText + "\nPercentile: " + rankText + " / 100\nStabilized change: " + changeText + "\nState: " + stateText + "\nMotion: " + motionText + "\nDirection: " + directionText + "\n" + modeDetail

var label forwardReadout = label.new(
  x = na,
  y = na,
  text = "",
  xloc = xloc.bar_index,
  yloc = yloc.price,
  style = label.style_label_left,
  color = color.new(color.black, 100),
  textcolor = color.white,
  size = 12,
  textalign = text.align_left,
  tooltip = "",
  text_formatting = text.format_none)

if barstate.islast
    bool validReadout = showForwardReadout and not na(readoutMid)
    if validReadout
        label.set_xy(forwardReadout, bar_index + cloudOffset - readoutShift + readoutHorizontalShift, readoutMid)
        label.set_text(forwardReadout, readoutText)
        label.set_color(forwardReadout, color.new(readoutBaseColor, readoutTransparency))
        label.set_textcolor(forwardReadout, effectiveReadoutTextColor)
        label.set_size(forwardReadout, readoutTextSize)
        label.set_textalign(forwardReadout, text.align_left)
        label.set_tooltip(forwardReadout, readoutTooltip)
        label.set_text_formatting(forwardReadout, readoutFormatting)
    else
        label.set_xy(forwardReadout, bar_index, na)
        label.set_text(forwardReadout, "")
        label.set_color(forwardReadout, color.new(color.black, 100))
        label.set_tooltip(forwardReadout, "")

//------------------------------------------------------------------------------
// Confirmed alert conditions
//------------------------------------------------------------------------------
bool confirmedTwist = confirmedFutureCloudTwist
bool confirmedEntersThin = barstate.isconfirmed and entersThinState
bool confirmedLeavesThin = barstate.isconfirmed and leavesThinState
bool confirmedEntersThick = barstate.isconfirmed and entersThickState
bool confirmedBreakAbove = barstate.isconfirmed and priceBreakAboveCurrentCloud
bool confirmedBreakBelow = barstate.isconfirmed and priceBreakBelowCurrentCloud
bool confirmedBeginsExpanding = barstate.isconfirmed and beginsExpanding
bool confirmedBeginsContracting = barstate.isconfirmed and beginsContracting
bool confirmedThinSeamAlert = confirmedThinSeam

alertcondition(confirmedTwist, title = "Any future cloud twist", message = "Ichimoku Cloud Thickness Spectrum: Senkou Span A and B formed a confirmed future cloud twist.")
alertcondition(confirmedBullishFutureTwist, title = "Bullish future cloud twist", message = "Ichimoku Cloud Thickness Spectrum: Senkou Span A crossed above Senkou Span B in the projected cloud.")
alertcondition(confirmedBearishFutureTwist, title = "Bearish future cloud twist", message = "Ichimoku Cloud Thickness Spectrum: Senkou Span A crossed below Senkou Span B in the projected cloud.")
alertcondition(confirmedEntersThin, title = "Cloud enters thin state", message = "Ichimoku Cloud Thickness Spectrum: cloud thickness percentile entered the user-defined thin state.")
alertcondition(confirmedLeavesThin, title = "Cloud leaves thin state", message = "Ichimoku Cloud Thickness Spectrum: cloud thickness percentile left the user-defined thin state.")
alertcondition(confirmedEntersThick, title = "Cloud enters thick state", message = "Ichimoku Cloud Thickness Spectrum: cloud thickness percentile entered the user-defined thick state.")
alertcondition(confirmedBreakAbove, title = "Close position transitions above current cloud", message = "Ichimoku Cloud Thickness Spectrum: the confirmed close position transitioned above the cloud aligned with the current bar.")
alertcondition(confirmedBreakBelow, title = "Close position transitions below current cloud", message = "Ichimoku Cloud Thickness Spectrum: the confirmed close position transitioned below the cloud aligned with the current bar.")
alertcondition(confirmedBeginsExpanding, title = "Cloud begins expanding", message = "Ichimoku Cloud Thickness Spectrum: the stabilized smoothed-thickness change moved into expansion.")
alertcondition(confirmedBeginsContracting, title = "Cloud begins contracting", message = "Ichimoku Cloud Thickness Spectrum: the stabilized smoothed-thickness change moved into contraction.")
alertcondition(confirmedThinSeamAlert, title = "Confirmed filtered thin-cloud seam", message = "Ichimoku Cloud Thickness Spectrum: a confirmed local thickness minimum passed the thin-state, prominence and spacing filters.")

// Dynamic alert() messages use English.
if enableDynamicAlerts and barstate.isconfirmed
    string eventText = ""
    if bullishFutureTwist
        eventText := f_append(eventText, "Bullish future cloud twist")
    if bearishFutureTwist
        eventText := f_append(eventText, "Bearish future cloud twist")
    if entersThinState
        eventText := f_append(eventText, "Cloud entered thin state")
    if leavesThinState
        eventText := f_append(eventText, "Cloud left thin state")
    if entersThickState
        eventText := f_append(eventText, "Cloud entered thick state")
    if priceBreakAboveCurrentCloud
        eventText := f_append(eventText, "Close position transitioned above current cloud")
    if priceBreakBelowCurrentCloud
        eventText := f_append(eventText, "Close position transitioned below current cloud")
    if beginsExpanding
        eventText := f_append(eventText, "Cloud thickness changed to expanding")
    if beginsContracting
        eventText := f_append(eventText, "Cloud thickness changed to contracting")
    if confirmedThinSeam
        eventText := f_append(eventText, "Confirmed filtered thin-cloud seam")
    if str.length(eventText) > 0
        string runtimeRank = na(thicknessRank) ? "n/a" : str.tostring(thicknessRank, "#")
        string runtimeMeasure = f_measure_text(thicknessMeasure, thicknessBasis)
        string runtimeSuffix = " | Thickness " + runtimeMeasure + " | P" + runtimeRank
        alert(syminfo.tickerid + " " + timeframe.period + " | " + eventText + runtimeSuffix, alert.freq_once_per_bar_close)
````
