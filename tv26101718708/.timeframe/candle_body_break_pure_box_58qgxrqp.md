# Candle body break - Pure Box

- url: https://www.tradingview.com/script/58qgxrqP/
- type: indicator
- pine_id: PUB;81b34814a7254ddfa7853250993ea43a
- version: 1.0

## Description

Short Description
Visually charts the exact highs and lows of the three most recent confirmed higher-timeframe (HTF) candles as pure, independent boxes without any repainting.

Detailed Description
Overview
This indicator dynamically calculates and tracks three distinct levels of higher timeframes (HTFs) relative to your current chart interval. It visualizes the precise historical boundary (High to Low) and duration (Open time to Close time) of the most recently closed HTF candles as clean, separate boxes.

Key Features

Zero Repainting: Built strictly with lookahead=barmerge.lookahead_off and referencing confirmed data ([1]). The boxes never shift, calculation is locked upon session close, ensuring historical accuracy.

Dynamic Timeframe Selection: Automatically scales the three higher timeframes based on whether you are viewing intraday, daily, or weekly charts.

Independent Visual Isolation: Each timeframe maintains its own dedicated memory pool (array) and visual layer, keeping the historical market structure unpolluted.

How to Use
Use these pure structural boxes to identify major macro support/resistance zones, evaluate candle body gaps, and monitor multi-timeframe structural breaks right from your current lower-timeframe execution chart.

日本語表記（国内・個人用説明文）
概要
現在のチャート足（下位足）に応じて動的に判定された「3つの上位足」の、直近で完全に確定したローソク足（1本前）の高値・安値・期間を、リペイントを一切排除した純粋なボックスとして独立描写するマルチタイムフレーム（MTF）インジケーターです。

主な特徴と設計規律
完全ノンリペイント（確定値の厳守）:
lookahead=barmerge.lookahead_off を採用し、すでに市場の合意が得られた確定足（[1]）のデータのみを抽出しています。リアルタイム形成中の上位足のブレに惑わされることはありません。

動的な時間軸自動切り替え:
分足、日足、週足など、表示している現在のタイムフレームに合わせて、最適な上位足3階層を内部ロジックで自動選択します。

独立したデータ構造:
それぞれの時間軸ごとに独立したボックス配列（Pool）を生成し、表示本数を制御しているため、過去の重要なマクロ構造の壁を曇りなく正確に視覚化します。

トレードへの活用
下位足でのエントリー執行中に、マクロ（大局）の物理的なレジスタンス・サポートラインや、ローソク足の実体・ヒゲによるブレイクアウトの事実を、同一チャート上で一目で把握するために最適化されています。

## Source Code

````pine
//@version=6
indicator("Candle body break - Pure Box", overlay=true, max_boxes_count=400)

// ==========================================
// 入力設定 (Inputs)
// ==========================================
showHigherTF1   = input.bool(true,  "上位足1を表示")
boxMaxCount1    = input.int(10,     "上位足1の表示本数", minval=1)

showHigherTF2   = input.bool(true,  "上位足2を表示")
boxMaxCount2    = input.int(10,     "上位足2の表示本数", minval=1)

showHigherTF3   = input.bool(true,  "上位足3を表示")
boxMaxCount3    = input.int(10,     "上位足3の表示本数", minval=1)

// ==========================================
// タイムフレーム決定ロジック (Timeframe Logic)
// ==========================================
get_higher_tf(step) =>
    m = timeframe.multiplier
    timeframe.isintraday ? (m < 5 ? (step == 1 ? "5" : step == 2 ? "15" : "60") : m < 15 ? (step == 1 ? "15" : step == 2 ? "60" : "240") : m < 60 ? (step == 1 ? "60" : step == 2 ? "240" : "D") : m < 240 ? (step == 1 ? "240" : step == 2 ? "D" : "W") : (step == 1 ? "D" : step == 2 ? "W" : "M")) : (timeframe.isdaily ? (step == 1 ? "W" : step == 2 ? "M" : "3M") : timeframe.isweekly ? (step == 1 ? "M" : step == 2 ? "3M" : "12M") : "12M")

higher_tf1 = get_higher_tf(1)
higher_tf2 = get_higher_tf(2)
higher_tf3 = get_higher_tf(3)

// ==========================================
// ボックス管理配列の初期化 (Data Storage)
// ==========================================
var box[] boxPool1 = array.new_box(0)
var box[] boxPool2 = array.new_box(0)
var box[] boxPool3 = array.new_box(0)

// ==========================================
// 描画関数 (Drawing Function)
// ==========================================
draw_pure_box(tf, show, pool, maxCount) =>
    [h, l, o, c, t, t_close] = request.security(syminfo.tickerid, tf, [high[1], low[1], open[1], close[1], time[1], time_close[1]], lookahead=barmerge.lookahead_off)
    if show and ta.change(t) != 0 and not na(t)
        s_col = c >= o ? color.blue : color.red
        array.push(pool, box.new(t, h, t_close, l, xloc=xloc.bar_time, border_color=color.new(s_col, 40), bgcolor=color.new(s_col, 85)))
    if array.size(pool) > maxCount
        box.delete(array.shift(pool))

// ==========================================
// 実行処理 (Execution)
// ==========================================
draw_pure_box(higher_tf1, showHigherTF1, boxPool1, boxMaxCount1)
draw_pure_box(higher_tf2, showHigherTF2, boxPool2, boxMaxCount2)
draw_pure_box(higher_tf3, showHigherTF3, boxPool3, boxMaxCount3)
````
