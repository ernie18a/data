# Traded Value Tracker (JPY Billions)

- url: https://www.tradingview.com/script/ljPGHpNG/
- type: indicator
- pine_id: PUB;c133eb4e8b334af699d15e869fe8d064
- version: 1.0

## Description

[b]【概要】[/b]
このスクリプトは、株式投資における「流動性リスク」をエンジニアリング的な視点で管理するために開発されました。
通常の出来高（株数）ではなく、**売買代金（金額ベース）**を表示することで、その銘柄にどれだけの「実弾（資金）」が投入されているかを一目で判別できます。

[b]【なぜ「売買代金」が必要なのか？】[/b]
株価が異なる銘柄同士を比較する際、株数ベースの出来高だけでは、本当の流動性を測ることはできません。

例： 株価100円の銘柄の10万株（1,000万円）と、株価10,000円の銘柄の10万株（10億円）では、板の厚みもリスクの大きさも全く異なります。

このインジケーターを使用することで、**「時価総額に対して十分なトラフィック（売買代金）があるか」「自分の注文で板を壊してしまわないか」**を正確にデバッグすることが可能です。

[b]【主な機能】[/b]
億円単位の表示: 日本株の分析に最適化された「億円」単位での表示。
移動平均線 (Volume MA): 直近の平均的な流動性と比較して、今日の盛り上がりを視覚化。
判定ロジックのスイッチ:
[list]
[*]前日比での色判定（デフォルト）：トレンドの継続性を重視。
[*]当日始値比での色判定：当日の勢いを重視。
[/list]
カスタマイズ可能な基準線: 自分が最低限必要とする流動性（例：10億円など）を水平線として表示可能。

[b]【推奨される使い方】[/b]
銘柄選定のフィルタリング: 売買代金10億円、時価総額500億円以上の「安全圏」銘柄を特定する。
急落の予兆検知: 価格が停滞しているのに売買代金だけが異常に膨らむ（エネルギーの衝突）を検知。
ジリ安の回避: 売買代金が平均を下回り、ダラダラと下げる「関心の喪失」状態を回避。

## Source Code

````pine
//@version=6
indicator("売買代金（億円）", overlay=false, precision=2)

// ==========================================
// 1. パラメーター（Inputs）
// ==========================================
maLength     = input.int(20, title="MAの期間", minval=1, group="ロジック")
unitDivider  = input.float(100000000.0, title="除数（1億＝億円単位）", group="ロジック")
usePrevClose = input.bool(true, title="前のバーの終値を基に色を判定", group="ロジック")
baseLineVal  = input.float(10.0, title="基準線の閾値（億円）", group="ロジック")

// ==========================================
// 2. ロジック（Calculations）
// ==========================================
tv = (close * volume) / unitDivider
tvMA = ta.sma(tv, maLength)

isUp = usePrevClose ? (close > close[1]) : (close > open)

// ==========================================
// 3. 描画（Plots）
// ==========================================
// color.new() を使い、デフォルトの透明度を 50 に設定
colorUp   = color.new(#26a69a, 50)
colorDown = color.new(#ef5350, 50)
plotColor = isUp ? colorUp : colorDown

plot(tv, title="売買代金", style=plot.style_columns, color=plotColor)

// 移動平均線（MAの色も透明度が必要なら同様に color.new で設定可能）
plot(tvMA, title="Volume MA", color=color.new(#2196f3, 0), linewidth=2)

// 基準線
plot(baseLineVal, title="基準線", color=color.new(color.gray, 0))
````
