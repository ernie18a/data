# GPIFBalance

- url: https://www.tradingview.com/script/n6Y8TSay/
- type: indicator
- pine_id: PUB;3ac4e735bce8479199cb0f96be47561e
- version: 2.0

## Description

年金ファンド GPIF バランス （4資産スプレッド比較）

概要：
日本の年金積立金管理運用独立行政法人（GPIF）の基本ポートフォリオを構成する「伝統的4資産」の相対的な力関係（スプレッド）を可視化するプロ仕様のインジケーターです。市場全体のトレンド（ベータ）を排除し、資産間の資金循環や強弱のみを抽出して分析することができます。

構成銘柄（デフォルト設定）：

国内株式：NEXT FUNDS TOPIX連動型上場投信 (1306)

国内債券：NEXT FUNDS 国内債券・NOMURA-BPI総合 (2510)

外国株式：上場インデックスファンド世界株式 (1554)

外国債券：NEXT FUNDS 外国債券・FTSE世界国債 (1677)

主な特徴：

相対スプレッド分析： 4つの資産のパフォーマンスの「平均値」を常に0ラインとし、そこから各資産が何％乖離（オーバーパフォーム/アンダーパフォーム）しているかを描画します。資金の逃避（株から債券へ）やリスクオンの動きが一目でわかります。

ワンタッチ期間設定： 設定画面のプルダウンから「測定スタート年（2020〜）」と「四半期（Q1〜Q4）」を選ぶだけで、瞬時にその期間からの相対パフォーマンスに切り替わります。マクロ経済のサイクル分析に最適です。

サブウィンドウ表示： メインのローソク足チャートを一切邪魔しないよう、画面下部の別枠に独立して表示されます。

おすすめの使い方：
四半期ごとの資金フロー（セクターローテーション）の確認や、グローバル分散投資におけるリバランスの最適なタイミングを計るためのツールとしてご活用ください。

【English Version】
Title: Pension Fund GPIF Balance NOW (4-Asset Spread Analyzer)

Description:
A professional-grade macro indicator designed to visualize the relative strength and spread of the "Traditional 4 Assets" modeled after the core portfolio of Japan's Government Pension Investment Fund (GPIF). This tool isolates capital rotation and relative momentum by neutralizing overall market trends.

Tracked Assets (Default ETFs):

Domestic Equities (Japan): TOPIX ETF (1306)

Domestic Bonds (Japan): NOMURA-BPI Bond ETF (2510)

Global Equities: MSCI ACWI ETF (1554)

Global Bonds: FTSE World Government Bond ETF (1677)

Key Features:

Relative Spread Analysis: The script calculates the average performance of the 4 assets and plots this mean as the dynamic "0" line. It plots each asset's deviation (spread) from this average, instantly revealing which assets are overperforming or underperforming (e.g., visualizing flight-to-safety flows from equities to bonds).

One-Click Period Selection: Easily change the measurement starting point via intuitive dropdown menus. Select the starting "Year" and "Quarter" (Q1-Q4) to instantly track performance across specific macro-economic cycles.

Sub-Window Display: Renders cleanly in a separate lower pane (overlay=false), ensuring your main price chart remains completely unobstructed and easy to read.

Best Use Case:
Ideal for tracking quarterly capital rotations, analyzing macro risk-on/risk-off sentiment, and identifying optimal timing for portfolio rebalancing within a globally diversified strategy.

## Source Code

````pine
//@version=5
indicator("年金ファンド GPIF バランス NOW", overlay=false)

// --- 銘柄の入力設定 ---
grp_sym = "【比較する銘柄】"
sym1 = input.symbol("TSE:1306", title="① 国内株 (1306)", group=grp_sym)
sym2 = input.symbol("TSE:2510", title="② 国内債券 (2510)", group=grp_sym)
sym3 = input.symbol("TSE:1554", title="③ 世界株 (1554)", group=grp_sym)
sym4 = input.symbol("TSE:1677", title="④ 海外債券 (1677)", group=grp_sym)

// --- 配分比率（ウェイト）の設定 ---
grp_weight = "【ポートフォリオ配分比率 (%)】"
w1_input = input.float(25.0, title="① 国内株の配分 (%)", group=grp_weight)
w2_input = input.float(25.0, title="② 国内債券の配分 (%)", group=grp_weight)
w3_input = input.float(25.0, title="③ 世界株の配分 (%)", group=grp_weight)
w4_input = input.float(25.0, title="④ 海外債券の配分 (%)", group=grp_weight)

// 入力された％を計算用に変換（合計が100%になるよう自動調整）
total_w = w1_input + w2_input + w3_input + w4_input
w1 = w1_input / total_w
w2 = w2_input / total_w
w3 = w3_input / total_w
w4 = w4_input / total_w

// --- 基準日の設定（年・四半期のプルダウン式） ---
grp_date = "【測定スタート地点の設定】"
use_all_time = input.bool(false, title="全期間で表示する（下の設定を無視）", group=grp_date)
target_year = input.string("2024", title="スタートする年", options=["2020", "2021", "2022", "2023", "2024", "2025", "2026", "2027", "2028", "2029", "2030"], group=grp_date)
target_q = input.string("Q1 (1月〜)", title="スタートする四半期", options=["Q1 (1月〜)", "Q2 (4月〜)", "Q3 (7月〜)", "Q4 (10月〜)"], group=grp_date)

int start_y = int(str.tonumber(target_year))
int start_m = target_q == "Q1 (1月〜)" ? 1 : target_q == "Q2 (4月〜)" ? 4 : target_q == "Q3 (7月〜)" ? 7 : 10

// --- 価格データの取得 ---
p1 = request.security(sym1, timeframe.period, close, ignore_invalid_symbol=true)
p2 = request.security(sym2, timeframe.period, close, ignore_invalid_symbol=true)
p3 = request.security(sym3, timeframe.period, close, ignore_invalid_symbol=true)
p4 = request.security(sym4, timeframe.period, close, ignore_invalid_symbol=true)

// --- 基準日以降かどうかを判定 ---
is_after_start = use_all_time ? true : time >= timestamp(start_y, start_m, 1, 0, 0, 0)

// --- 基準価格の取得（指定日以降の最初の価格をロック） ---
var float start_p1 = na
var float start_p2 = na
var float start_p3 = na
var float start_p4 = na

if ta.change(time("D")) and not is_after_start
    start_p1 := na
    start_p2 := na
    start_p3 := na
    start_p4 := na

if is_after_start
    if na(start_p1) and not na(p1)
        start_p1 := p1
    if na(start_p2) and not na(p2)
        start_p2 := p2
    if na(start_p3) and not na(p3)
        start_p3 := p3
    if na(start_p4) and not na(p4)
        start_p4 := p4

// --- 1. 通常のパフォーマンス（%）を計算 ---
perf1 = na(start_p1) ? na : ((p1 / start_p1) - 1) * 100
perf2 = na(start_p2) ? na : ((p2 / start_p2) - 1) * 100
perf3 = na(start_p3) ? na : ((p3 / start_p3) - 1) * 100
perf4 = na(start_p4) ? na : ((p4 / start_p4) - 1) * 100

// --- 2. 4つのETFの「加重平均パフォーマンス」を計算（各25%） ---
avg_perf = (perf1 * w1) + (perf2 * w2) + (perf3 * w3) + (perf4 * w4)

// --- 3. 各ETFが、加重平均からどれだけ乖離しているかを計算 ---
diff1 = perf1 - avg_perf
diff2 = perf2 - avg_perf
diff3 = perf3 - avg_perf
diff4 = perf4 - avg_perf

// --- チャートへの描画 ---
plot(diff1, title="国内株 (乖離)", color=color.new(color.blue, 0), linewidth=2)
plot(diff2, title="国内債券 (乖離)", color=color.new(color.red, 0), linewidth=2)
plot(diff3, title="世界株 (乖離)", color=color.new(color.green, 0), linewidth=2)
plot(diff4, title="海外債券 (乖離)", color=color.new(color.orange, 0), linewidth=2)

// 加重平均線（これが常に0になります）
hline(0, "加重平均線 (0)", color=color.gray, linestyle=hline.style_dotted, linewidth=2)
````
