# Sand (200MA)

- url: https://www.tradingview.com/script/xfGOWwWr/
- type: indicator
- pine_id: PUB;7ad4b30d2d774f3b81ba154ec1a68347
- version: 2.0

## Description

此指標由 Sand 提供，依據波段交易 SOP 設計，整合三道買進關卡與雙重賣出機制。

【買進三關】
第一關：股價站上 200MA（年線），且 BIAS 乖離率未超過 25%，確認長線多頭環境。
第二關：SAR 由上方翻轉至 K 線下方，或 5MA 向上穿越 20MA（黃金交叉），確認短線動能啟動。
第三關：確認上方 60MA 與 120MA 無近距壓力，若壓力均線距離過近則觀望。

【賣出機制】
策略 A（技術反轉）：SAR 翻轉至 K 線上方，且股價跌破 20MA，為必賣訊號。
策略 B（移動停利）：買入後追蹤最高價，回落 5%（保守）或 8%（寬鬆）時出場。

【注意事項】
本系統適用於趨勢股，景氣循環股（鋼鐵、航運、金融、電信等）請避免使用，
技術指標在此類股票上容易於關鍵時刻失效。

Idea provided by Sand.

## Source Code

````pine
// ============================================================
// 波段交易 SOP Strategy Indicator
// 功能：買進三關訊號 | 賣出訊號 | 移動停利線 | BIAS乖離率過濾
// ============================================================
//@version=5
indicator("波段交易Sand_V2(20MA)", overlay=true, max_lines_count=500, max_labels_count=500)

// ──────────────────────────────────────────────
// 【參數設定】
// ──────────────────────────────────────────────
grp_sar   = "SAR 設定"
grp_trail = "移動停利設定"
grp_bias  = "BIAS 乖離率設定"

// SAR
sar_start = input.float(0.03, "SAR 起始步長", step=0.01, minval=0.001, maxval=0.5, group=grp_sar)
sar_inc   = input.float(0.03, "SAR 遞增步長", step=0.01, minval=0.001, maxval=0.5, group=grp_sar)
sar_max   = input.float(0.6,  "SAR 最大步長", step=0.01, minval=0.01,  maxval=1.0, group=grp_sar)

// 移動停利
show_trail      = input.bool(true,  "顯示移動停利線",     group=grp_trail)
show_trail_cons = input.bool(true,  "顯示保守停利 (95%)", group=grp_trail)
show_trail_wide = input.bool(true,  "顯示寬鬆停利 (92%)", group=grp_trail)
trail_cons_pct  = input.float(5.0,  "保守回檔 %", minval=1.0, maxval=20.0, step=0.5, group=grp_trail)
trail_wide_pct  = input.float(8.0,  "寬鬆回檔 %", minval=1.0, maxval=20.0, step=0.5, group=grp_trail)

// BIAS
bias_threshold = input.float(25.0, "BIAS 過熱閾值 (%)", minval=5.0, maxval=50.0, step=1.0, group=grp_bias)
show_bias_warn = input.bool(true,  "顯示 BIAS 過熱提示",                         group=grp_bias)

// ──────────────────────────────────────────────
// 【均線計算】
// ──────────────────────────────────────────────
ma5   = ta.sma(close, 5)
ma20  = ta.sma(close, 20)
ma60  = ta.sma(close, 60)
ma120 = ta.sma(close, 120)
ma200 = ta.sma(close, 200)

// 均線僅用於訊號計算，不繪製（由外部指標顯示）

// ──────────────────────────────────────────────
// 【SAR 計算】
// ──────────────────────────────────────────────
sar_val = ta.sar(sar_start, sar_inc, sar_max)

// SAR 方向：上升（bull）= SAR 在 K 線下方
sar_bull = sar_val < close
sar_bear = sar_val > close

// SAR 翻轉偵測
sar_flip_up   = sar_bull and not sar_bull[1]   // 空轉多（跌轉漲）
sar_flip_down = sar_bear and not sar_bear[1]   // 多轉空（漲轉跌）

plot(sar_val, "SAR", color=sar_bull ? color.new(#26a69a, 0) : color.new(#ef5350, 0),
     style=plot.style_circles, linewidth=2)

// ──────────────────────────────────────────────
// 【BIAS 乖離率】
// ──────────────────────────────────────────────
bias = (close - ma200) / ma200 * 100
bias_hot = bias > bias_threshold
````
