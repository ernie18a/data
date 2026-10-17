# 007_Perfect Order

- url: https://www.tradingview.com/script/QXNGl6b7/
- type: indicator
- pine_id: PUB;b183bd8049414e808d38eef839efc1dd
- version: 1.0

## Description

15分足のパーフェクトオーダーを見逃していて悔しい思いをしたので作ってみました。
１）レンジを含めたトレンド判定
２）20SMA,75SMA,200EMAの位置関係でパーフェクトオーダー完成を判定
３）サインとともに、設定で通知やメール送信可能。
４）各機能はONOFFを自由に選べる

## Source Code

````pine
// This Pine Script™ v5 indicator is subject to the Terms of Use:
// https://www.tradingview.com/pine-script-docs/
//
// パーフェクトオーダー検出インジケーター (TradingView版)
//
// 機能:
//   1) 20SMA, 75SMA, 200EMA の描画
//   2) 75SMAの傾きによるトレンド判定（ラベル表示）
//   3) パーフェクトオーダー成立判定（矢印表示）
//   4) アラート通知（メール・プッシュ通知・ポップアップ）
//      ※ TradingViewではアラート条件を設定し、
//        ユーザーがアラートダイアログでメール/プッシュ等を選択する仕組み

//@version=5
indicator("Perfect Order", overlay=true, max_labels_count=500)

// ============================================================
// 外部パラメータ
// ============================================================

// --- MA期間 ---
sma20Period  = input.int(20,  title="短期SMA期間",  minval=1, group="移動平均線")
sma75Period  = input.int(75,  title="中期SMA期間",  minval=1, group="移動平均線")
ema200Period = input.int(200, title="長期EMA期間",  minval=1, group="移動平均線")

// --- MA色 ---
sma20Color  = input.color(color.lime,    title="短期SMAの色",  group="移動平均線")
sma75Color  = input.color(color.orange,  title="中期SMAの色",  group="移動平均線")
ema200Color = input.color(color.fuchsia, title="長期EMAの色",  group="移動平均線")

// --- 線幅 ---
lineWidth = input.int(2, title="MAの線幅", minval=1, maxval=5, group="移動平均線")

// --- 矢印色 ---
bullishArrowColor = input.color(color.new(color.blue, 0),  title="上昇PO矢印の色", group="矢印表示")
bearishArrowColor = input.color(color.new(color.red, 0),   title="下降PO矢印の色", group="矢印表示")

// --- トレンド判定 ---
slopeLookback = input.int(3, title="トレンド判定の比較本数", minval=1, maxval=50, group="トレンド判定")

// --- アラート設定 ---
enableAlerts = input.bool(true, title="アラートを有効にする", group="アラート",
     tooltip="TradingViewのアラート機能を使用します。\nインジケーター適用後、チャート上で「アラートを追加」してください。\nメール・プッシュ通知はアラート設定画面で選択できます。")

// ============================================================
// 1) 移動平均線の計算・描画
// ============================================================
sma20  = ta.sma(close, sma20Period)
sma75  = ta.sma(close, sma75Period)
ema200 = ta.ema(close, ema200Period)

plot(sma20,  title="20 SMA",  color=sma20Color,  linewidth=lineWidth)
plot(sma75,  title="75 SMA",  color=sma75Color,  linewidth=lineWidth)
plot(ema200, title="200 EMA", color=ema200Color, linewidth=lineWidth)

// ============================================================
// 2) トレンド判定 (75SMAの傾き)
// ============================================================
// 現在の75SMAとN本前の75SMAを比較
// 戻り値: 1=上昇, -1=下降, 0=レンジ
trendDirection = if sma75 > sma75[slopeLookback]
    1
else if sma75 < sma75[slopeLookback]
    -1
else
    0

// --- トレンドラベル表示（チャート右上） ---
trendText  = trendDirection == 1 ? "↑ 上昇トレンド" : trendDirection == -1 ? "↓ 下降トレンド" : "→ レンジ"
trendColor = trendDirection == 1 ? color.new(color.blue, 0) : trendDirection == -1 ? color.new(color.red, 0) : color.gray

// 最新バーのみにラベルを表示（過去のラベルは削除）
var label trendLabel = na
if barstate.islast
    if not na(trendLabel)
        label.delete(trendLabel)
    trendLabel := label.new(
         bar_index + 3, high,
         text=trendText,
         style=label.style_label_left,
         color=color.new(color.black, 80),
         textcolor=trendColor,
         size=size.normal,
         yloc=yloc.price,
         y=ta.highest(high, 20) * 1.001)

// ============================================================
// 3) パーフェクトオーダー判定
// ============================================================

// --- 確定バー（1本前）でのトレンド判定 ---
trendAtBar1 = if sma75[1] > sma75[1 + slopeLookback]
    1
else if sma75[1] < sma75[1 + slopeLookback]
    -1
else
    0

// --- パーフェクトオーダー判定 ---
// 上昇PO: 上昇トレンド中 かつ 20SMA > 75SMA > 200EMA
bullishPO = trendAtBar1 == 1 and sma20[1] > sma75[1] and sma75[1] > ema200[1]
// 下降PO: 下降トレンド中 かつ 200EMA > 75SMA > 20SMA
bearishPO = trendAtBar1 == -1 and ema200[1] > sma75[1] and sma75[1] > sma20[1]

// 現在のPO状態
currentPO = bullishPO or bearishPO
poDirection = bullishPO ? 1 : bearishPO ? -1 : 0

// --- 前回のPO状態（1本前のバーの判定結果） ---
prevBullishPO = trendAtBar1[1] == 1 and sma20[2] > sma75[2] and sma75[2] > ema200[2]

// 前回のトレンド判定
prevTrendAtBar1 = if sma75[2] > sma75[2 + slopeLookback]
    1
else if sma75[2] < sma75[2 + slopeLookback]
    -1
else
    0
prevBearishPO_calc = prevTrendAtBar1 == -1 and ema200[2] > sma75[2] and sma75[2] > sma20[2]
prevBullishPO_calc = prevTrendAtBar1 == 1 and sma20[2] > sma75[2] and sma75[2] > ema200[2]
prevPO = prevBullishPO_calc or prevBearishPO_calc
prevPODirection = prevBullishPO_calc ? 1 : prevBearishPO_calc ? -1 : 0

// --- 新規成立判定（重複送信防止） ---
// 前回PO不成立 → 今回成立、または方向が変わった場合のみ
isNewPO = currentPO and (not prevPO or prevPODirection != poDirection)

// --- 確定バーでのみ判定（barstate.isconfirmed） ---
isNewPOConfirmed = isNewPO and barstate.isconfirmed

// ============================================================
// 4) 矢印描画
// ============================================================

// 上昇パーフェクトオーダー: 安値の下に上向き矢印
plotshape(isNewPOConfirmed and poDirection == 1 ? low[1] - (high[1] - low[1]) * 0.3 : na,
     title="上昇PO矢印",
     style=shape.triangleup,
     location=location.absolute,
     color=bullishArrowColor,
     size=size.small,
     offset=-1,
     text="PO↑",
     textcolor=bullishArrowColor)

// 下降パーフェクトオーダー: 高値の上に下向き矢印
plotshape(isNewPOConfirmed and poDirection == -1 ? high[1] + (high[1] - low[1]) * 0.3 : na,
     title="下降PO矢印",
     style=shape.triangledown,
     location=location.absolute,
     color=bearishArrowColor,
     size=size.small,
     offset=-1,
     text="PO↓",
     textcolor=bearishArrowColor)

// ============================================================
// 5) アラート条件（メール・プッシュ通知対応）
// ============================================================
// TradingViewではalertcondition()でアラート条件を定義し、
// ユーザーがアラート追加時にメール/プッシュ/Webhook等を選択する

alertcondition(
     isNewPOConfirmed and poDirection == 1,
     title="上昇パーフェクトオーダー成立",
     message="[PerfectOrder] {{ticker}} {{interval}} - 上昇パーフェクトオーダー成立\n\n通貨ペア: {{ticker}}\n時間足: {{interval}}\n方向: 上昇\n発生時刻: {{time}}\n\n--- MA値 ---\n20SMA: {{plot_0}}\n75SMA: {{plot_1}}\n200EMA: {{plot_2}}\n\n--- 価格情報 ---\n始値: {{open}}\n高値: {{high}}\n安値: {{low}}\n終値: {{close}}")

alertcondition(
     isNewPOConfirmed and poDirection == -1,
     title="下降パーフェクトオーダー成立",
     message="[PerfectOrder] {{ticker}} {{interval}} - 下降パーフェクトオーダー成立\n\n通貨ペア: {{ticker}}\n時間足: {{interval}}\n方向: 下降\n発生時刻: {{time}}\n\n--- MA値 ---\n20SMA: {{plot_0}}\n75SMA: {{plot_1}}\n200EMA: {{plot_2}}\n\n--- 価格情報 ---\n始値: {{open}}\n高値: {{high}}\n安値: {{low}}\n終値: {{close}}")

alertcondition(
     isNewPOConfirmed,
     title="パーフェクトオーダー成立（上昇・下降両方）",
     message="[PerfectOrder] {{ticker}} {{interval}} - パーフェクトオーダー成立\n\n通貨ペア: {{ticker}}\n時間足: {{interval}}\n発生時刻: {{time}}\n終値: {{close}}")

// ============================================================
// 6) テーブルによるステータス表示
// ============================================================
var table statusTable = table.new(position.top_right, 1, 3,
     bgcolor=color.new(color.black, 80),
     border_width=1,
     border_color=color.new(color.gray, 60))

if barstate.islast
    // トレンド状態
    table.cell(statusTable, 0, 0,
         text=trendText,
         text_color=trendColor,
         text_size=size.normal)

    // パーフェクトオーダー状態
    poStatusText  = currentPO ? (poDirection == 1 ? "✅ 上昇PO成立中" : "✅ 下降PO成立中") : "❌ PO不成立"
    poStatusColor = currentPO ? (poDirection == 1 ? color.new(color.blue, 0) : color.new(color.red, 0)) : color.gray
    table.cell(statusTable, 0, 1,
         text=poStatusText,
         text_color=poStatusColor,
         text_size=size.normal)

    // MA値表示
    maInfo = "20SMA: " + str.tostring(sma20, format.mintick) +
             " | 75SMA: " + str.tostring(sma75, format.mintick) +
             " | 200EMA: " + str.tostring(ema200, format.mintick)
    table.cell(statusTable, 0, 2,
         text=maInfo,
         text_color=color.white,
         text_size=size.tiny)
````
