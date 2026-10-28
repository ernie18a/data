# Multi-Timeframe Anchored VWAP Deviation Oscillator 

- url: https://www.tradingview.com/script/sOcfh2bz/
- type: indicator
- pine_id: PUB;3394d8fd2fe3401dad7ae4819d6284f6
- version: 1.0

## Description

マルチ期間対応 VWAP乖離率オシレーター（±10% 過熱感アラート付き）

概要：
特定の基準（アンカー）から引いたVWAP（出来高加重平均価格）に対し、現在の株価が何パーセント離れているか（乖離率）を視覚化するプロ仕様のオシレーターです。市場の「平均コスト」からの行き過ぎ（買われすぎ・売られすぎ）を的確に捉え、逆張りや利益確定のタイミングを計るのに役立ちます。

主な特徴：

マルチ期間アンカー対応： 設定画面から「日」「週」「月」「四半期」「決算日」、さらには「任意の指定日時（日本時間対応）」をワンタッチで選択し、VWAPの計算スタート地点を自在に切り替えることができます。

一目でわかる強弱カラー： 乖離率がプラス（VWAPより上）なら青色、マイナス（下）なら赤色に自動で変化。0%ラインとの間が塗りつぶされるため、モメンタムの強弱がヒストグラムのように直感的に把握できます。

±10% アラートバンド内蔵： 上下10%の位置に点線のガイドラインを表示。短期的な過熱感（+10%）や、パニック売りによる底打ちシグナル（-10%）の目安として強力に機能します。

サブウィンドウ表示： メインのローソク足チャートを邪魔しないよう、画面下部の別枠（サブウィンドウ）にスッキリと表示されます。

おすすめの使い方：
デイトレードでの分足チャートに適用して「日（Daily）」ベースでの行き過ぎを狙ったり、スイングトレードで「決算日」や「直近の安値（指定日時）」を起点とした機関投資家の平均建玉ラインからの乖離を分析したりするのに最適です。

【English Version】
Title: Multi-Timeframe Anchored VWAP Deviation Oscillator (with ±10% Bands)

Description:
A professional-grade oscillator designed to visualize the percentage deviation between the current price and an Anchored Volume Weighted Average Price (VWAP). This tool helps traders identify price extremes away from the institutional average cost basis, making it highly effective for spotting overbought/oversold conditions and timing mean-reversion trades.

Key Features:

Multi-Anchor Support: Easily reset the VWAP calculation starting point via a simple dropdown menu. Choose from Daily, Weekly, Monthly, Quarterly, Earnings dates, or a completely Custom Date & Time (optimized for the Asia/Tokyo timezone).

Intuitive Color Coding: The deviation line turns Blue when positive (price > VWAP) and Red when negative (price < VWAP). The filled area down to the 0% baseline creates a clear visual representation of momentum shifts.

±10% Over-extension Bands: Features built-in dashed guidelines at the +10% and -10% levels. These act as immediate visual alerts for statistically overextended (frothy) markets or capitulation (oversold) zones.

Sub-Window Display: Renders cleanly in a separate lower pane (overlay=false) to ensure your main candlestick chart remains uncluttered.

Best Use Case:
Perfect for day traders using short timeframes to fade daily extremes, or swing traders anchoring VWAP to recent earnings gaps or significant swing lows to gauge true market sentiment and institutional support.

## Source Code

````pine
//@version=5
indicator("VWAP乖離率", overlay=false)

// --- 設定項目 ---
grp_main = "【VWAPの基準期間 (アンカー)】"
anchor_input = input.string("週 (Weekly)", title="リセット間隔を選択", options=["日 (Daily)", "週 (Weekly)", "月 (Monthly)", "四半期 (Quarterly)", "決算 (Earnings)", "指定日時 (Custom Range)"], group=grp_main)

grp_custom = "【指定日時 (Custom) の設定】"
c_year = input.int(2026, "年", group=grp_custom)
c_month = input.int(1, "月", minval=1, maxval=12, group=grp_custom)
c_day = input.int(1, "日", minval=1, maxval=31, group=grp_custom)
c_hour = input.int(9, "時", minval=0, maxval=23, group=grp_custom)
c_min = input.int(0, "分", minval=0, maxval=59, group=grp_custom)

// --- 外部データの取得（条件分岐の外で行う） ---
earn = request.earnings(syminfo.tickerid, earnings.actual, ignore_invalid_symbol=true)
earn_changed = nz(ta.change(earn)) != 0

// --- リセット条件の判定 ---
bool do_reset = false

if anchor_input == "日 (Daily)"
    do_reset := ta.change(time("D")) != 0
else if anchor_input == "週 (Weekly)"
    do_reset := ta.change(time("W")) != 0
else if anchor_input == "月 (Monthly)"
    do_reset := ta.change(time("M")) != 0
else if anchor_input == "四半期 (Quarterly)"
    do_reset := ta.change(time("3M")) != 0
else if anchor_input == "決算 (Earnings)"
    do_reset := earn_changed
else if anchor_input == "指定日時 (Custom Range)"
    target_time = timestamp("Asia/Tokyo", c_year, c_month, c_day, c_hour, c_min, 0)
    do_reset := time >= target_time and (na(time[1]) or time[1] < target_time)

// --- 手動VWAPの計算 ---
var float sum_vol_price = 0.0
var float sum_vol = 0.0

if do_reset or barstate.isfirst
    sum_vol_price := hlc3 * volume
    sum_vol := volume
else
    sum_vol_price := sum_vol_price + nz(hlc3 * volume)
    sum_vol := sum_vol + nz(volume)

my_vwap = sum_vol > 0 ? sum_vol_price / sum_vol : na

// --- 乖離率(%)の計算 ---
kairi = na(my_vwap) ? na : ((close - my_vwap) / my_vwap * 100)

// --- 色の設定 ---
c_color = kairi >= 0 ? color.blue : color.red

// --- チャートへの描画 ---
p_kairi = plot(kairi, title="乖離率(%)", color=c_color, linewidth=2)
p_zero = plot(0, title="0%ライン", color=color.gray, linewidth=1)
fill(p_kairi, p_zero, color=color.new(c_color, 85))

// ★ ここを追加しました：上下10%の目安ライン
hline(10, title="+10%ライン", color=color.red, linestyle=hline.style_dashed, linewidth=1)
hline(-10, title="-10%ライン", color=color.green, linestyle=hline.style_dashed, linewidth=1)

// --- ここまで ---
````
