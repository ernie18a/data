# Gap [Zemu]

- url: https://www.tradingview.com/script/R9HAQ0cV-Gap-Zemu/
- type: indicator
- pine_id: PUB;3abab856a2b644258ab7cceab41b6474
- version: 1.0

## Description

[b]Gap [Zemu][/b]

[b]1. Description[/b]
Zemu is a gap continuation indicator focused on the relationship between overnight displacement and intraday follow-through. The indicator visualizes whether the opening imbalance was accepted, rejected, or faded during the session by comparing the gap against the subsequent intraday move. The goal is structural clarity, using a compact visual format to make continuation and failed continuation regimes easier to identify.
[image]https://www.tradingview.com/x/RDvQsqIX/[/image]
[b]2. Features[/b]
Zemu plots the opening gap as a stepped bar structure, allowing overnight displacement to remain visually persistent throughout the session. Intraday follow-through and the combined net position are plotted as column structures using directional coloring derived from the intraday move. This allows continuation, disagreement, and reversal states to remain visually distinct without additional overlays or complexity.

Gap Calculation:
[pine](Open - Previous Close) / Previous Close[/pine]
Intraday Move:
[pine](Close - Open) / Open[/pine]
The indicator intentionally uses a minimal visual architecture focused on readability and interpretation.[image]https://www.tradingview.com/x/2RprWNsO/[/image]
[b]3. Context[/b]
Overnight session gaps and subsequent intraday continuation dynamics are most pronounced due to exchange-based trading hours. Whilst primarily designed for stocks on the daily timeframe, this indicator can also be applied to indices, futures, and forex markets, although gap behavior in these instruments may exhibit weaker continuation characteristics depending on session overlap and trading structure. Cryptocurrency markets are generally less suited to the framework due to their continuous 24/7 trading environment.[image]https://www.tradingview.com/x/Xi05r6Vr/[/image]
[b]4. Framework[/b]
Zemu is part of the ETMassif framework that is focused on price displacement and participation. Related work within the same research space examines how volume and price vectors interact during and after gap events, how wick-local participation reveals institutional activity at price extremes, and how persistent gap and wick levels continue to influence price structure over time.

[b]日本語概要 (Japanese Summary)[/b]
Zemuは、ギャップ（窓開け）と当日の値動きの関係を可視化するためのインジケーターです。寄付き後にトレンドが継続したのか、ダマシ（失敗）に終わったのか、あるいはもみ合い（吸収）となったのかをシンプルな構造で表示します。ギャップはステップ（階段）構造として表示され、日中の値動きと合成されたネットポジションはカラム（柱状）形式で描画されます。視認性と構造の把握を重視し、不要な複雑化を避けた設計となっています。

[b]中文概要（Chinese Summary）[/b]
Zemu 是一款用於分析跳空缺口與日內走勢關聯性的指標。本指標透過比較跳空缺口（Gap）與後續的日內走勢，藉此觀察市場對開盤失衡的延續、失敗或反轉表現。缺口以階梯式結構呈現，日內延續與淨位移則以柱狀圖（Column）形式顯示。整體設計強調簡潔、高可讀性與價格結構本身，避免過度複雜化。

[b]Disclaimer:[/b]
This script is a research tool for market structure analysis and educational purposes only. It does not constitute financial advice. Trading involves risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © et20tradeview

//@version=6
indicator("Raw Gap", overlay = false)

// Gap %
gap = (open - close[1]) / close[1] * 100

// Intrabar move %
move = (close - open) / open * 100

combined = gap + move

// Same direction?
follow = math.sign(gap) == math.sign(move)

// Direction color
col = move >= 0 ? color.rgb(113, 243, 73) : color.rgb(248, 136, 226)


//Plots
plot(gap, "Gap %", color = gap >= 0 ? color.green : color.red, linewidth = 2, style=plot.style_steplinebr)
plot(follow ? na: gap, style=plot.style_columns, color=color.new(col, 85))

// Optional: show move as histogram
// Thin columns (visual proxy for outline)
plot(combined, style=plot.style_columns, color=color.new(col, 85))

// Zero line
hline(0, "Zero", color = color.gray)
````
