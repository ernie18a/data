<!-- tradingview-pine-id: PUB;2df519a138c24e619fb8d4f051e6f9e1 -->
<!-- tradingview-pine-version: 4.0 -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: Price-MA Deviation (PMAD) v1.9.3

Source: https://www.tradingview.com/script/VUjO85yq-TF-Price-MA-Deviation-PMAD/

## Description

TradingFlow: Price-MA Deviation (PMAD)

TradingFlow: Price-MA Deviation (PMAD) is a mean-reversion indicator that measures how far price has deviated from its moving average, normalized to a 0–100 scale based on recent historical range. Raw percentage deviation varies widely across assets and timeframes, so PMAD takes a different approach. It answers a simple question: where does the current deviation sit relative to recent history? This makes PMAD comparable across different symbols, timeframes, and market conditions. A reading of 85 on Bitcoin means the same thing as a reading of 85 on a stock. Price is stretched to the upper end of its recent deviation range.

Key Features:

Normalized Deviation (0–100)
The core line oscillates between 0 and 100. At 50, price is at its moving average. Above 50, price is above the MA. Below 50, price is below. The value shows where the current deviation falls within the highest and lowest deviations over the normalization lookback period.

Adaptive Timeframe Scaling
PMAD automatically adjusts its MA and normalization periods based on the chart timeframe. On intraday charts, shorter periods keep the indicator responsive. On daily and higher timeframes, the full user-specified periods produce a smoother macro view. Intraday scaling can be fine-tuned with exposed base period and normalization multiplier inputs.

Auto Market-Hour Detection
PMAD detects the asset type and sets trading hours automatically. Crypto and forex get 24 hours, futures get 23 hours, and equities get 6.5 hours. A manual override is available for non-standard sessions.

Overbought and Oversold Zones
Dotted reference lines at 85 and 15 mark potential overbought and oversold conditions. The area above 85 is shaded red; the area below 15 is shaded green. These levels are configurable.

Signal Line
An optional smoothed line (SMA or EMA) of the deviation can be displayed. Crossovers between the deviation line and the signal line can help identify shifts in momentum. The signal line period is set in bars and works across all timeframes.

Alerts
Six built-in alert conditions are available: overbought cross, oversold cross, signal bullish cross, signal bearish cross, bullish regime (above 50), and bearish regime (below 50).

How to Read the Chart

A reading above 50 means price is trading above its moving average. A reading below 50 means price is below. The further from 50, the more extended the deviation.

Overbought (above 85) means price has deviated to the upper end of its recent range. Oversold (below 15) means price has deviated to the lower end. These zones suggest potential mean-reversion conditions, but should not be treated as automatic entry or exit signals.

When the deviation line crosses above the signal line, short-term momentum is increasing. When it crosses below, momentum is decreasing.

Flexible Configuration
PMAD supports SMA and EMA moving-average types, adjustable MA and normalization periods, configurable thresholds, and per-asset trading hour settings. Intraday base period and normalization multiplier can be fine-tuned for different markets or trading styles.

Practical Use
PMAD can identify extended price conditions, monitor mean-reversion opportunities, filter entries against the broader deviation context, and compare relative strength across multiple symbols. It works best alongside price action, support and resistance, volume, volatility analysis, and disciplined risk management.

PMAD does not predict future price movement and should not be used as a standalone entry or exit system.

---

TradingFlow: Price-MA Deviation (PMAD)

TradingFlow: Price-MA Deviation (PMAD) 是一個均值回歸指標，衡量價格偏離移動平均線的程度，並根據近期歷史範圍歸一化至 0–100 的刻度。不同商品和時間週期之間的百分比偏離差異很大，PMAD 不顯示原始偏離值，而是回答一個簡單的問題：目前的偏離程度，在近期歷史中處於什麼位置？這讓 PMAD 可以在不同標的、時間週期和市場條件之間進行比較。Bitcoin 上的 85 讀數與股票上的 85 讀數含義相同。價格已偏離至其近期偏離範圍的上端。

核心功能：

歸一化偏離值（0–100）
核心線在 0 到 100 之間震盪。位於 50 時，價格正好在移動平均線上。高於50，價格在均線上方；低於50，價格在均線下方。該數值代表目前偏離值在歸一化回看期內最高和最低偏離值之間的位置。

自適應時間週期縮放
PMAD 會根據圖表時間週期自動調整 MA 和歸一化的期間。在日內圖表上使用較短的週期以保持靈敏度；在日線及以上圖表上使用完整的使用者設定週期，以獲得更平滑的宏觀視角。日內縮放可透過基礎期間和歸一化倍數進行微調。

自動市場時數偵測
PMAD 會偵測資產類型並自動設定交易時數。加密貨幣和外匯為24小時，期貨為23小時，股票為6.5小時。也提供手動覆蓋選項，適用於非標準交易時段。

超買和超賣區域
85 和15 的虛線參考標記潛在的超買和超賣狀態。85 以上區域以紅色陰影標示；15 以下區域以綠色陰影標示。這些水平可自行調整。

訊號線
可選擇顯示偏離值的平滑線（SMA 或 EMA）。偏離線與訊號線之間的交叉，有助於識別動能的轉變。訊號線期間以 K 棒數設定，適用於所有時間週期。

警報
內建六種警報條件：超買突破、超賣跌破、訊號線多頭交叉、訊號線空頭交叉、多頭狀態（50 以上）及空頭狀態（50 以下）。

如何閱讀圖表

當偏離線高於50時，價格交易在移動平均線上方；低於50時，價格在均線下方。距離50越遠，偏離越極端。

當線條進入超買區域（高於85），價格已偏離至近期範圍的上端；進入超賣區域（低於15），價格已偏離至下端。這些區域暗示可能的均值回歸條件，但不應視為自動的進場或出場訊號。

當偏離線向上穿越訊號線，短期動能正在增強；向下穿越則代表動能減弱。

彈性設定
PMAD 支援 SMA 和 EMA 移動平均類型、可調整的 MA 和歸一化期間、可設定的閾值，以及每種資產的交易時數設定。日內基礎期間和歸一化倍數可針對不同市場或交易風格進行微調。

實際使用方式
PMAD 可用於辨識極端價格條件、觀察均值回歸機會、根據偏離背景過濾交易，以及比較多個標的的相對強弱。它適合搭配價格行為、支撐阻力、成交量、波動率分析與風險管理一起使用。

PMAD 無法預測未來價格走勢，也不應單獨用作進場或出場系統。

---

TradingFlow: Price-MA Deviation (PMAD)

TradingFlow: Price-MA Deviation (PMAD) は、価格が移動平均線からどれだけ乖離しているかを測定し、直近の歴史的なレンジに基づいて 0〜100 に正規化する平均回帰型インジケーターです。生の乖離率は銘柄や時間足によって大きく異なるため、PMAD は異なるアプローチを採用しています。シンプルな問いかけに答えます。現在の乖離は、直近の歴史の中でどの位置にあるか。これにより、異なる銘柄、時間足、市場条件間で比較が可能になります。Bitcoin で 85 という読み値は、株式で 85 と同じ意味を持ちます。価格が直近の乖離レンジの上限にまで引き伸ばされている状態です。

主な機能:

正規化乖離値（0〜100）
コアとなるラインは 0 から 100 の間で推移します。50 は価格が移動平均線上にある状態を示します。50 以上なら価格は MA を上回り、50 以下なら下回ります。この値は、正規化のルックバック期間における最高乖離値と最低乖離値のレンジの中で、現在の乖離がどの位置にあるかを示しています。

アダプティブタイムフレームスケーリング
PMAD はチャートの時間足に応じて、MA と正規化の期間を自動調整します。日中足では短い期間を採用し、インジケーターの応答性を維持します。日足以上の時間足では、ユーザーが指定した期間をそのまま使用し、より滑らかなマクロ視点を実現します。日中のスケーリングは、ベース期間と正規化倍数の入力パラメーターで微調整可能です。

マーケット時間の自動検出
PMAD はアセットの種類を検出し、取引時間を自動設定します。暗号通貨と FX は 24 時間、先物は 23 時間、株式は 6.5 時間が適用されます。非標準の取引セッションにも対応できる手動設定が用意されています。

買われすぎ・売られすぎゾーン
85 と 15 の破線は、買われすぎ・売られすぎの目安を示します。85 以上の領域は赤で塗りつぶされ、15 以下の領域は緑で塗りつぶされます。これらの水準は変更可能です。

シグナルライン
乖離値を平滑化した線（SMA または EMA）をオプションで表示できます。乖離線とシグナルラインのクロスは、勢いの変化を捉えるのに役立ちます。シグナルラインの期間はバー数で指定し、すべての時間足で動作します。

アラート
6 種類のアラート条件を標準装備しています。買われすぎ突破、売られすぎ下抜け、シグナルラインの買いクロス、シグナルラインの売りクロス、強気レジーム（50 以上のクロス）、弱気レジーム（50 以下のクロス）です。

チャートの読み方

乖離値が 50 を上回れば、価格は移動平均線の上で推移しています。50 を下回れば、下で推移しています。50 から離れるほど、乖離は極端になります。

買われすぎ（85 以上）は、価格が直近レンジの上限に達していることを示します。売られすぎ（15 以下）は、下限に達していることを示します。これらのゾーンは平均回帰の可能性を示唆しますが、自動的な売買シグナルとして扱うべきではありません。

乖離線がシグナルラインを上抜けた場合は短期の勢いが増し、下抜けた場合は勢いが衰減しています。

柔軟な設定
PMAD は SMA と EMA の移動平均タイプ、MA と正規化の期間調整、閾値の設定、アセット別の取引時間設定に対応しています。日中のベース期間と正規化倍数は、市場やトレードスタイルに合わせて微調整可能です。

実際の使い方
PMAD は、価格の過熱状態の把握、平均回帰の機会の監視、乖離のコンテキストに基づくエントリーのフィルタリング、複数銘柄間の相対ストレングスの比較に活用できます。価格アクション、サポート・レジスタンス、出来高、ボラティリティ分析、そして規律あるリスク管理と組み合わせて使用することが推奨されます。

PMAD は将来の価格動向を予測するものではなく、単独での売買システムとして使用すべきではありません。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// -----------------------------------------------------------------------------
//  TradingFlow: Price-MA Deviation
//  MA & Normalization periods adapt to the chart timeframe.
// -----------------------------------------------------------------------------
indicator("TradingFlow: Price-MA Deviation (PMAD) v1.9.3", shorttitle="TF: PMAD", overlay=false, precision=2, explicit_plot_zorder=true)

// ==================================================
// PRICE & PERIODS
// ==================================================

grp_tf = "Price & Periods"
src     = input.source(hlc3, title="Source", group=grp_tf, display=display.data_window)
maType  = input.string("EMA", title="MA Type", options=["SMA", "EMA"], group=grp_tf)
useAdaptive    = input.bool(true, title="Adaptive Periods (Auto-Scale)", tooltip="Automatically scales MA & Normalization periods for balanced sensitivity across intraday and daily charts.", group=grp_tf)
intraBaseBars  = input.int(150, title="Intraday Base MA Period (Bars)", minval=30, maxval=500, step=10, tooltip="MA bars at 15 minutes; other intraday timeframes scale from this base (min 30 bars).", group=grp_tf)
intraNormRatio = input.float(4.0, title="Intraday Normalization Multiplier", minval=1.0, maxval=10.0, step=0.5, tooltip="Multiplier for intraday normalization lookback relative to MA period (e.g., 4.0 = 4x MA length).", group=grp_tf)
maLenDays      = input.int(200, title="MA Period (Days for D+)", minval=10, maxval=5000, step=10, tooltip="Trading-day target on Daily+ charts. Used directly as bars when adaptation is off or on tick charts.", group=grp_tf)
normLenDays    = input.int(200, title="Normalization Lookback (Days for D+)", minval=10, maxval=5000, step=10, tooltip="Trading-day target on Daily+ charts (min 10 bars). Used directly as bars when adaptation is off or on tick charts.", group=grp_tf)
calendarMode = input.string("Auto", title="Daily+ Trading Calendar", options=["Auto", "5-day week", "7-day week"], tooltip="Converts trading-day targets on weekly/monthly charts. Auto assumes 7 days/week for crypto and 5 otherwise. Months average 30.4375 calendar days; holidays are not modeled. Does not affect intraday scaling.", group=grp_tf)

// ==================================================
// SIGNAL LINE
// ==================================================

grp_signal = "Signal Line"
signalType = input.string("SMA", title="Signal MA Type", options=["SMA", "EMA"], group=grp_signal)
signalLen   = input.int(50, title="Signal Period (Bars)", minval=2, maxval=5000, tooltip="Fixed number of chart bars on every timeframe. Independent of Adaptive Periods; higher values smooth more and respond more slowly.", group=grp_signal)

// ==================================================
// LEVELS & ALERTS
// ==================================================

grp_thresh = "Levels & Alerts"
obLevel = input.int(85, title="Overbought Level", minval=51, maxval=99, group=grp_thresh)
osLevel = input.int(15, title="Oversold Level", minval=1, maxval=49, group=grp_thresh)
confirmAlerts = input.bool(true, title="Confirm Alerts at Bar Close", tooltip="Waits for the current bar to close before an alert can trigger. The plotted lines and colors still update live.", group=grp_thresh)

// ==================================================
// DISPLAY
// ==================================================

grp_display = "Display"
showSignal = input.bool(true, title="Show Signal Line", group=grp_display)
showLengths = input.bool(true, title="Show Active Lengths", group=grp_display)

// ==================================================
// ADAPTIVE LENGTHS
// ==================================================

// Convert Daily+ trading-day targets to bars, including multi-unit timeframes.
sevenDayWeek = calendarMode == "7-day week" or (calendarMode == "Auto" and syminfo.type == "crypto")
daysPerWeek  = sevenDayWeek ? 7.0 : 5.0
daysPerMonth = 30.4375 * daysPerWeek / 7.0
daysPerBar   = (timeframe.isweekly ? daysPerWeek : timeframe.ismonthly ? daysPerMonth : 1.0) * timeframe.multiplier

// Intraday: bar-based scaling anchored at 15 minutes, independent of market hours.
// Tick charts use configured bar lengths directly, since ticks have no fixed duration.
tfMin     = timeframe.isticks ? 1.0 : timeframe.in_seconds() / 60.0
intraMA   = math.round(math.max(30, math.min(1000, float(intraBaseBars) * math.pow(math.max(1.0, tfMin) / 15.0, 0.25))))
intraNorm = math.round(intraMA * intraNormRatio)
adaptPeriods = useAdaptive and not timeframe.isticks

maLen   = adaptPeriods ? (timeframe.isintraday ? intraMA : math.max(2, math.min(5000, math.round(maLenDays / daysPerBar)))) : maLenDays
normLen = adaptPeriods ? (timeframe.isintraday ? math.min(5000, intraNorm) : math.max(10, math.min(5000, math.round(normLenDays / daysPerBar)))) : normLenDays

// ==================================================
// CORE CALCULATION
// ==================================================

maVal   = maType == "SMA" ? ta.sma(src, maLen) : ta.ema(src, maLen)
rawDev  = maVal == 0 ? 0.0 : ((src - maVal) / maVal) * 100.0
highest = ta.highest(rawDev, normLen)
lowest  = ta.lowest(rawDev, normLen)
rangeDv = highest - lowest
valSlow = rangeDv == 0 ? 50.0 : ((rawDev - lowest) / rangeDv) * 100.0

// 50 is the midpoint of the rolling deviation range, not necessarily zero deviation.
// Signal Line calculation
signalLine = signalType == "EMA" ? ta.ema(valSlow, signalLen) : ta.sma(valSlow, signalLen)

// ==================================================
// PLOTTING
// ==================================================

// Colors
colGreen   = color.rgb(0, 181, 162, 0)
colGreenLt = color.rgb(0, 181, 162, 35)
colRed     = color.rgb(255, 100, 100, 0)
colRedLt   = color.rgb(255, 100, 100, 35)
colMidAqua = color.rgb(102, 192, 192, 0)
colSignal  = color.new(color.orange, 0)
colMaxLine = color.new(color.red, 90)
colObLine  = color.new(color.red, 50)
colObFill  = color.new(color.red, 95)
colMinLine = color.new(color.green, 90)
colOsLine  = color.new(color.green, 50)
colOsFill  = color.new(color.green, 95)

// Retain the last side at equality; this does not filter repeated crossings.
// Seed on first available values to avoid initial red bias.
var int sigState = 0
var int midState = 0
if sigState == 0 and not na(valSlow) and not na(signalLine)
    sigState := valSlow >= signalLine ? 1 : -1
if midState == 0 and not na(valSlow)
    midState := valSlow >= 50 ? 1 : -1
if ta.crossover(valSlow, signalLine)
    sigState := 1
if ta.crossunder(valSlow, signalLine)
    sigState := -1
if ta.crossover(valSlow, 50)
    midState := 1
if ta.crossunder(valSlow, 50)
    midState := -1

aboveSig = sigState == 1
aboveMid = midState == 1
colSlow = na(signalLine) ? color.gray : aboveSig ? (aboveMid ? colGreen : colGreenLt) : (aboveMid ? colRedLt : colRed)

hTop    = hline(100, "Max", color=colMaxLine, linestyle=hline.style_solid, linewidth=1)
hUpper  = hline(obLevel, "Overbought Ref", color=colObLine, linestyle=hline.style_dotted, linewidth=2)
hMid    = hline(50, "Midpoint", color=colMidAqua, linestyle=hline.style_dashed, linewidth=1)
hLower  = hline(osLevel, "Oversold Ref", color=colOsLine, linestyle=hline.style_dotted, linewidth=2)
hBottom = hline(0, "Min", color=colMinLine, linestyle=hline.style_solid, linewidth=1)

fill(hTop, hUpper, color=colObFill, title="Overbought Zone")
fill(hBottom, hLower, color=colOsFill, title="Oversold Zone")

plot(showSignal ? signalLine : na, title="Signal Line", color=colSignal, linewidth=1)
plot(valSlow, title="Deviation", color=colSlow, linewidth=2)

// Info table: active lengths in bars
var table lenTbl = table.new(position.top_right, 1, 1)
if barstate.islast
    if showLengths
        table.cell(lenTbl, 0, 0, text="MA " + str.tostring(maLen) + " / Norm " + str.tostring(normLen) + " / Signal " + str.tostring(signalLen), text_size=size.tiny, text_color=chart.fg_color, bgcolor=chart.bg_color)
    else
        table.clear(lenTbl, 0, 0)

// ==================================================
// ALERTS
// ==================================================

alertcondition(ta.crossover(valSlow, obLevel) and (not confirmAlerts or barstate.isconfirmed), title="Overbought Cross", message="PMAD crossed above overbought level")
alertcondition(ta.crossunder(valSlow, osLevel) and (not confirmAlerts or barstate.isconfirmed), title="Oversold Cross", message="PMAD crossed below oversold level")
alertcondition(ta.crossover(valSlow, signalLine) and (not confirmAlerts or barstate.isconfirmed), title="Signal Bullish Cross", message="PMAD crossed above Signal line")
alertcondition(ta.crossunder(valSlow, signalLine) and (not confirmAlerts or barstate.isconfirmed), title="Signal Bearish Cross", message="PMAD crossed below Signal line")
alertcondition(ta.crossover(valSlow, 50) and (not confirmAlerts or barstate.isconfirmed), title="Deviation Midpoint Cross Up", message="PMAD crossed above its deviation-range midpoint (50)")
alertcondition(ta.crossunder(valSlow, 50) and (not confirmAlerts or barstate.isconfirmed), title="Deviation Midpoint Cross Down", message="PMAD crossed below its deviation-range midpoint (50)")
````
