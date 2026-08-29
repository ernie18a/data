<!-- tradingview-pine-id: PUB;ab922cb018e941b481dda60997fdff3b -->
<!-- tradingviewscripts-format: 1 -->
# RSI + MACD + Ichimoku Composite Signal

Source: https://www.tradingview.com/script/wdWvCyhY-RMI-Signal-RSI-MACD-Ichimoku/

## Description

RMI Signalは、RSI・MACD・一目均衡表という3つの独立したテクニカル指標のバイアス(強気/弱気)を統合し、3指標の一致度に基づいて複合エントリーシグナルを生成するオシレーター型インジケーターです。
単一指標のダマシに惑わされず、複数の異なるロジックが同じ方向を示したときにのみシグナルを出すことで、判断の質を高めることを目的としています。
あわせてRSI上でのレギュラーダイバージェンス自動検出も搭載しています。

🔶 主な機能

- 📊 RSIバイアス — RSI(50)を基準に強気/弱気を判定。RSI-50をメインラインとしてプロット

- 📈 MACDバイアス — MACDヒストグラムの符号で強気/弱気を判定。MACDライン・シグナルラインも同時表示可能

- ☁️ 一目均衡表バイアス — 「価格が雲の上/下にあるか」と「転換線・基準線のクロス方向」が一致した場合のみ強気/弱気と判定(簡易版の三役好転/逆転ロジック)

- 🎯 複合シグナル — 3指標のうち何個が一致すればシグナルとするか(2/3または3/3)を設定可能。一致時は背景色点灯+BUY/SELLラベルを表示

- 🔍 RSIダイバージェンス検出 — RSIのピボット高値/安値と価格を比較し、強気/弱気のレギュラーダイバージェンスをRSIライン上にライン・ラベルで自動描画
- 📋 ステータステーブル — 各指標のバイアスと複合シグナルの状態を一覧表示

🔶 仕組み

★各指標は独立して +1(強気) / -1(弱気) / 0(中立) のスコアを算出します。

- RSI: RSI > 50 → 強気、RSI < 50 → 弱気
- MACD: ヒストグラム > 0 → 強気、< 0 → 弱気
- 一目均衡表: 価格が雲の上 かつ 転換線 > 基準線 → 強気(逆は弱気)

強気スコアの合計、または弱気スコアの合計が設定した一致数(既定3/3)に達した時点で、
複合【BUY/SELL】シグナルが確定します。

🔶 設定

- RSI: 期間・ソースの変更
- MACD: Fast/Slow/Signal期間、MACDライン表示のON/OFF
- 一目均衡表: 転換線・基準線・先行スパンB・移動幅の各期間
- 複合ロジック: シグナル成立に必要な一致数(2または3)
- ダイバージェンス: 検出Pivot長、有効期間、表示色
- 表示設定: テーブル表示・BUY/SELLラベル表示・テーブル位置

🔶 使い方

1. 背景色が点灯し、BUY/SELLラベルが表示されたタイミングを複合的なトレンド転換の目安として活用してください
2. テーブルで各指標が「どちらに何個一致しているか」を確認し、シグナルの根拠を把握できます
3. RSIライン上の"Bear Div"/"Bull Div"は、モメンタムの減衰を示す先行的なシグナルとして、複合シグナルの補助的な確認材料に利用してください

🔶 アラート

複合BUYシグナル・複合SELLシグナル・弱気ダイバージェンス・強気ダイバージェンスの発生時にそれぞれアラートを設定できます。

⚠️ 免責事項

本インジケーターは教育・情報提供のみを目的としたものであり、投資助言ではありません。過去のデータに基づくシグナルは将来の値動きを保証するものではなく、実際の取引判断はご自身の責任で行ってください。

---

RMI Signal — RSI + MACD + Ichimoku Composite Signal & Divergence Detector

🔶 OVERVIEW

RMI Signal is an oscillator-style indicator that combines the bias (bullish/bearish) of three independent technical tools — RSI, MACD, and Ichimoku Kinko Hyo — into a single composite entry signal based on how many of them agree. 
Rather than relying on any single indicator (which can produce false signals on its own), this tool only triggers when multiple independent methods align, aiming to improve signal quality. It also includes automatic regular divergence detection plotted directly on the RSI line.

🔶 KEY FEATURES

- 📊 RSI Bias — Bullish above 50, bearish below. The RSI-50 series is plotted as the main oscillator line.
- 📈 MACD Bias — Determined by the sign of the MACD histogram. MACD/Signal lines can be overlaid on the same pane.
- ☁️ Ichimoku Bias — Bullish only when price is above the Kumo (cloud) AND Tenkan-sen is above Kijun-sen (bearish requires both conditions to align in the opposite direction) — a simplified version of the classic "three-line confirmation."
- 🎯 Composite Signal — Choose how many of the 3 indicators must agree (2-of-3 or 3-of-3) to trigger a signal. On alignment, the panel background highlights and a BUY/SELL label is plotted.
- 🔍 RSI Divergence Detection — Compares RSI pivot highs/lows against price to automatically detect and draw bullish/bearish regular divergence directly on the RSI line.
- 📋 Status Table — At-a-glance table showing the current bias of each indicator and the overall composite state.

🔶 HOW IT WORKS

Each component independently scores +1 (bullish), -1 (bearish), or 0 (neutral):

- RSI: RSI > 50 → bullish, RSI < 50 → bearish
- MACD: histogram > 0 → bullish, < 0 → bearish
- Ichimoku: price above cloud AND Tenkan > Kijun → bullish (opposite for bearish)

A composite BUY or SELL signal fires once the number of aligned bullish (or bearish) components reaches your chosen threshold (default: 3-of-3).

🔶 SETTINGS

- RSI: length, source
- MACD: fast/slow/signal length, toggle for MACD/Signal line plots
- Ichimoku: Tenkan, Kijun, Senkou Span B lengths, displacement
- Composite Logic: required agreement count (2 or 3)
- Divergence: pivot length, validity window, colors
- Display: table toggle, label toggle, table position

🔶 HOW TO USE

1. Treat the background highlight + BUY/SELL label as a confluence-based trend-shift cue.
2. Use the status table to see exactly which components are aligned and how many, to gauge signal conviction.
3. Treat "Bear Div" / "Bull Div" markers on the RSI line as an early warning of momentum exhaustion — a supporting confirmation alongside the composite signal, not a standalone trigger.

🔶 ALERTS

Alerts are available for: Composite Buy, Composite Sell, Bearish RSI Divergence, and Bullish RSI Divergence.

⚠️ DISCLAIMER

This indicator is provided for educational and informational purposes only and does not constitute financial advice. Signals are based on historical price data and do not guarantee future performance. Always do your own research and manage risk according to your own trading plan.

---

## Source Code

````pine
// This Pine Script code is a new, standalone indicator (separate from the
// "Technical Volume catch with Macro" combined indicator built earlier).
//
// RSI + MACD + Ichimoku Composite Signal
// ─────────────────────────────────────────────────────────────────────────
// 3つの指標それぞれからバイアス(+1=強気/-1=弱気/0=中立)を算出し、
// 一致数が閾値(既定3/3、2/3にも変更可)を超えたらBUY/SELLの複合シグナルとする。
//
// ・RSI: 50を基準に強気/弱気を判定（RSI-50を主軸ラインとしてプロット）
// ・MACD: ヒストグラムの符号（+なら強気, -なら弱気）
// ・一目均衡表: 「価格が雲の上/下」かつ「転換線と基準線のクロス方向」が
//   一致した場合のみ強気/弱気（三役好転/逆転の簡易版。遅行スパンは未使用）
//
// テーブル/ラベルの見せ方は、参考として頂いたダイバージェンス検出器の
// スタイル（table.new + label.new + 淡色背景セル）を踏襲しています。
// =============================================================================

//@version=6
indicator("RSI + MACD + Ichimoku Composite Signal", shorttitle="RMI Signal",
     overlay=false, max_labels_count=500, max_lines_count=500)

// =============================================================================
// ════════════════════════ Inputs ═════════════════════════════════════════
// =============================================================================

rsiLen = input.int(14, "RSI期間", minval=1, group="RSI")
rsiSrc = input.source(close, "RSI Source", group="RSI")

macdFast = input.int(12, "MACD Fast", minval=1, group="MACD")
macdSlow = input.int(26, "MACD Slow", minval=1, group="MACD")
macdSig  = input.int(9,  "MACD Signal", minval=1, group="MACD")
showMacdLine = input.bool(true, "MACDライン(MACD/Signal)を表示", group="MACD")

tenkanLen     = input.int(9,  "転換線期間",       minval=1, group="一目均衡表")
kijunLen      = input.int(26, "基準線期間",       minval=1, group="一目均衡表")
senkouBLen    = input.int(52, "先行スパンB期間",  minval=1, group="一目均衡表")
displacement  = input.int(26, "先行スパン移動幅", minval=1, group="一目均衡表")

requiredAgree = input.int(3, "シグナル成立に必要な一致数", minval=2, maxval=3, group="複合ロジック")

showTable  = input.bool(true, "テーブルを表示",        group="表示設定")
showLabels = input.bool(true, "BUY/SELLラベルを表示",  group="表示設定")
tablePos   = input.string(position.top_right, "テーブル位置",
     options=[position.bottom_center,position.bottom_left,position.bottom_right,
              position.middle_center,position.middle_left,position.middle_right,
              position.top_center,position.top_left,position.top_right],
     group="表示設定")

showDiv     = input.bool(true, "RSIダイバージェンスを表示",       group="ダイバージェンス")
divLen      = input.int(5,  "ダイバージェンス Pivot長",   minval=2, group="ダイバージェンス")
divMaxBars  = input.int(60, "ダイバージェンス有効期間(本数)", minval=1, group="ダイバージェンス")
bullDivColor = input.color(color.rgb(40, 177, 52), "強気ダイバージェンス色", group="ダイバージェンス")
bearDivColor = input.color(color.rgb(216, 66, 66), "弱気ダイバージェンス色", group="ダイバージェンス")

// =============================================================================
// ════════════════════════ 各指標のバイアス計算 ═══════════════════════════
// =============================================================================

// ── RSI ──
rsiVal  = ta.rsi(rsiSrc, rsiLen)
rsiBias = rsiVal > 50 ? 1 : rsiVal < 50 ? -1 : 0

// ── MACD ──
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
macdBias = macdHist > 0 ? 1 : macdHist < 0 ? -1 : 0

// ── 一目均衡表 ──
tenkan = (ta.highest(high, tenkanLen) + ta.lowest(low, tenkanLen)) / 2
kijun  = (ta.highest(high, kijunLen)  + ta.lowest(low, kijunLen))  / 2
spanA  = (tenkan + kijun) / 2
spanB  = (ta.highest(high, senkouBLen) + ta.lowest(low, senkouBLen)) / 2

// 現在のローソク足の下に実際に描かれる雲の水準（displacement分過去の値）と比較
cloudTop    = math.max(spanA[displacement], spanB[displacement])
cloudBottom = math.min(spanA[displacement], spanB[displacement])

ichiPriceBias = close > cloudTop ? 1 : close < cloudBottom ? -1 : 0
ichiTkBias    = tenkan > kijun ? 1 : tenkan < kijun ? -1 : 0
ichiBias      = (ichiPriceBias == 1 and ichiTkBias == 1) ? 1 : (ichiPriceBias == -1 and ichiTkBias == -1) ? -1 : 0

// =============================================================================
// ════════════════════════ 複合判定 ═══════════════════════════════════════
// =============================================================================

totalBull = (rsiBias == 1 ? 1 : 0) + (macdBias == 1 ? 1 : 0) + (ichiBias == 1 ? 1 : 0)
totalBear = (rsiBias == -1 ? 1 : 0) + (macdBias == -1 ? 1 : 0) + (ichiBias == -1 ? 1 : 0)

compositeBuy  = totalBull >= requiredAgree
compositeSell = totalBear >= requiredAgree

compositeBuyTrigger  = compositeBuy  and not compositeBuy[1]
compositeSellTrigger = compositeSell and not compositeSell[1]

alertcondition(compositeBuyTrigger,  "Composite Buy",  "RSI+MACD+Ichimoku Bullish alignment")
alertcondition(compositeSellTrigger, "Composite Sell", "RSI+MACD+Ichimoku Bearish alignment")

// =============================================================================
// ════════════════════════ RSIダイバージェンス検出 ═════════════════════════
// RSIのピボット高値/安値と、同時点の価格の高値/安値を比較する古典的な
// レギュラーダイバージェンス判定（頂いた参考コードと同じ手法をRSI専用に適用）。
// =============================================================================

rsiPH = ta.pivothigh(rsiVal, divLen, divLen)
rsiPL = ta.pivotlow(rsiVal, divLen, divLen)

bearPivotFound = not na(rsiPH)
bullPivotFound = not na(rsiPL)

// 弱気ダイバージェンス：価格は高値更新、RSIは高値切り下げ
lastHighPrice = ta.valuewhen(bearPivotFound, high[divLen],   0)
prevHighPrice = ta.valuewhen(bearPivotFound, high[divLen],   1)
lastHighRsi   = ta.valuewhen(bearPivotFound, rsiVal[divLen], 0)
prevHighRsi   = ta.valuewhen(bearPivotFound, rsiVal[divLen], 1)
lastHighBar   = ta.valuewhen(bearPivotFound, bar_index[divLen], 0)
prevHighBar   = ta.valuewhen(bearPivotFound, bar_index[divLen], 1)

bearishDivergence = bearPivotFound and not na(prevHighBar) and (lastHighBar - prevHighBar) < divMaxBars and (lastHighPrice > prevHighPrice) and (lastHighRsi < prevHighRsi)
bearDivTrigger = showDiv and bearishDivergence and not na(ta.change(lastHighPrice)) and ta.change(lastHighPrice) != 0

// 強気ダイバージェンス：価格は安値更新、RSIは安値切り上げ
lastLowPrice = ta.valuewhen(bullPivotFound, low[divLen],    0)
prevLowPrice = ta.valuewhen(bullPivotFound, low[divLen],    1)
lastLowRsi   = ta.valuewhen(bullPivotFound, rsiVal[divLen], 0)
prevLowRsi   = ta.valuewhen(bullPivotFound, rsiVal[divLen], 1)
lastLowBar   = ta.valuewhen(bullPivotFound, bar_index[divLen], 0)
prevLowBar   = ta.valuewhen(bullPivotFound, bar_index[divLen], 1)

bullishDivergence = bullPivotFound and not na(prevLowBar) and (lastLowBar - prevLowBar) < divMaxBars and (lastLowPrice < prevLowPrice) and (lastLowRsi > prevLowRsi)
bullDivTrigger = showDiv and bullishDivergence and not na(ta.change(lastLowPrice)) and ta.change(lastLowPrice) != 0

alertcondition(bearDivTrigger, "Bearish RSI Divergence", "Bearish divergence detected on RSI")
alertcondition(bullDivTrigger, "Bullish RSI Divergence", "Bullish divergence detected on RSI")

// =============================================================================
// ════════════════════════ プロット ════════════════════════════════════════
// =============================================================================

rsiPlotVal = rsiVal - 50
plot(rsiPlotVal, "RSI-50", color = rsiPlotVal >= 0 ? color.rgb(76, 175, 79) : color.rgb(255, 82, 82), linewidth = 2)

// MACDライン / シグナルライン（生値。価格レンジがRSI-50と大きく異なる銘柄では、
// TradingView上でこのプロットを右クリック→スケールを独立させると見やすくなります）
plot(showMacdLine ? macdLine   : na, "MACD Line",   color = color.rgb(41, 98, 255), linewidth = 1)
plot(showMacdLine ? macdSignal : na, "Signal Line", color = color.rgb(255, 109, 0), linewidth = 1)

hline(0,   "Mid (RSI50)", color = color.rgb(132, 132, 133), linestyle = hline.style_dashed)
hline(20,  "RSI70",       color = color.rgb(132, 132, 133), linestyle = hline.style_dotted)
hline(-20, "RSI30",       color = color.rgb(132, 132, 133), linestyle = hline.style_dotted)

bgcolor(compositeBuy ? color.new(color.green, 85) : compositeSell ? color.new(color.red, 85) : na)

plotshape(showLabels and compositeBuyTrigger,  "Composite BUY",  shape.labelup,   location.bottom, color.green, text="BUY",  textcolor=color.white)
plotshape(showLabels and compositeSellTrigger, "Composite SELL", shape.labeldown, location.top,    color.red,   text="SELL", textcolor=color.white)

// RSIライン上にダイバージェンスをライン＋ラベルで描画（直近1件を保持し、都度更新）
var line  bearDivLine  = na
var label bearDivLabel = na
var line  bullDivLine  = na
var label bullDivLabel = na

if bearDivTrigger
    line.delete(bearDivLine)
    label.delete(bearDivLabel)
    bearDivLine  := line.new(prevHighBar, prevHighRsi - 50, lastHighBar, lastHighRsi - 50, color = bearDivColor, width = 2)
    bearDivLabel := label.new(lastHighBar, lastHighRsi - 50, "Bear Div", color = bearDivColor, textcolor = color.white, style = label.style_label_down, size = size.tiny)

if bullDivTrigger
    line.delete(bullDivLine)
    label.delete(bullDivLabel)
    bullDivLine  := line.new(prevLowBar, prevLowRsi - 50, lastLowBar, lastLowRsi - 50, color = bullDivColor, width = 2)
    bullDivLabel := label.new(lastLowBar, lastLowRsi - 50, "Bull Div", color = bullDivColor, textcolor = color.white, style = label.style_label_up, size = size.tiny)

// =============================================================================
// ════════════════════════ テーブル ════════════════════════════════════════
// =============================================================================

f_biasText(b) =>
    b == 1 ? "▲ Bull" : b == -1 ? "▼ Bear" : "→ Neutral"

f_biasColor(b) =>
    b == 1 ? color.rgb(40, 177, 52) : b == -1 ? color.rgb(216, 66, 66) : color.gray

var compTable = table.new(position = tablePos, columns = 2, rows = 5,
     bgcolor = color.rgb(235, 234, 234, 75), frame_width = 1,
     frame_color = color.black, border_color = color.black, border_width = 1)

if showTable
    table.cell(compTable, 0, 0, "指標",     text_size = size.small, bgcolor = color.rgb(11, 20, 36), text_color = color.white)
    table.cell(compTable, 1, 0, "バイアス", text_size = size.small, bgcolor = color.rgb(11, 20, 36), text_color = color.white)

    table.cell(compTable, 0, 1, "RSI(" + str.tostring(rsiLen) + ")", text_size = size.small)
    table.cell(compTable, 1, 1, f_biasText(rsiBias), text_size = size.small, text_color = f_biasColor(rsiBias))

    table.cell(compTable, 0, 2, "MACD(" + str.tostring(macdFast) + "," + str.tostring(macdSlow) + "," + str.tostring(macdSig) + ")", text_size = size.small)
    table.cell(compTable, 1, 2, f_biasText(macdBias), text_size = size.small, text_color = f_biasColor(macdBias))

    table.cell(compTable, 0, 3, "一目均衡表", text_size = size.small)
    table.cell(compTable, 1, 3, f_biasText(ichiBias), text_size = size.small, text_color = f_biasColor(ichiBias))

    table.cell(compTable, 0, 4, "複合シグナル (" + str.tostring(requiredAgree) + "/3)", text_size = size.small)
    table.cell(compTable, 1, 4,
         compositeBuy ? "BUY (" + str.tostring(totalBull) + "/3)" : compositeSell ? "SELL (" + str.tostring(totalBear) + "/3)" : "Neutral",
         text_size = size.small,
         text_color = compositeBuy ? color.rgb(40, 177, 52) : compositeSell ? color.rgb(216, 66, 66) : color.gray)
````
