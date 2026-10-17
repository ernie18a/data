# RSI + TSI Normalized v4

- url: https://www.tradingview.com/script/qVLbizeG/
- type: indicator
- pine_id: PUB;0ceff675a6874eeab5c802bd5eb18ffe
- version: 1.0

## Description

============================================================================
 RSI + TSI Normalized v4 — Script Overview
 ============================================================================

 ── English ─────────────────────────────────────────────────────────────────

 PURPOSE
 This indicator unifies RSI and TSI (True Strength Index) into a single
 oscillator pane by normalizing both to a common ±50 scale centered on zero.
 It then derives a weighted composite line from four components (RSI, RSI-MA,
 TSI, TSI Signal) and draws an adaptive linear regression channel on that
 composite — similar to the Adaptive Trend Finder concept, but applied to
 momentum space rather than price.

 CORE COMPONENTS
 1. RSI (Normalized)       — standard RSI shifted so that 50 → 0
 2. RSI-MA (EMA of RSI)    — smoothed RSI, drawable with user-defined offset
 3. TSI                    — double-smoothed momentum, normalized to ±50
 4. TSI Signal (EMA of TSI)— smoothed TSI, drawable with user-defined offset
 5. Composite Line         — weighted average of (1)–(4), scaled by a
                             user coefficient (0.5–1.5)
 6. Regression Channel     — straight-line linear regression on the composite,
                             with ±σ deviation bands, R² color coding,
                             and optional history overlay

 OFFSET SYSTEM
 RSI-MA and TSI Signal can each be shifted left or right (±20 bars).
 All crossover detections between offset lines and non-offset lines
 (composite, RSI, TSI) use a "visual crossover" algorithm that compares
 values at the same *drawing* X-coordinate, not the same bar_index.
 This ensures markers appear exactly where lines visually intersect.

 CROSSOVER SIGNALS
 ③ RSI × RSI-MA       — basic RSI momentum cross (hidden by default)
 ④ RSI × TSI          — inter-indicator cross (hidden by default)
    TSI Signal × RSI   — diamond markers (hidden by default)
    RSIMA × TSI Signal — offset-aware cross (hidden by default)
 ⑤ RSIMA × Composite  — triangle markers, shown by default
 ⑥ TSI Signal × Composite — circle markers, shown by default

 REGRESSION CHANNEL
 Computed via manual least-squares on the composite over a configurable
 lookback period. Recalculated every N bars. R² is displayed as a label
 at the channel's right edge. Channel color intensity adapts to R²:
 high R² = vivid blue/teal (strong trend), low R² = gray (noisy).
 Past channels are preserved as dotted gray lines for trend history.

 DASHBOARD TABLE
 Top-right table shows real-time values: RSI, RSI-MA, TSI, TSI Signal,
 MA–Signal spread, offset settings, composite value, and R².

 ALERTS
 JSON-formatted alertconditions for all crossover types, ready for
 webhook integration.

 ── 日本語 ──────────────────────────────────────────────────────────────────

 目的
 RSI と TSI（True Strength Index）を共通の ±50 スケールに正規化し、
 1つのオシレーターペインに統合するインジケーター。
 4つの構成要素（RSI, RSI-MA, TSI, TSI Signal）の加重平均から合成値を算出し、
 その合成値に対して Adaptive Trend Finder 風の直線回帰チャネルを描画する。
 価格ではなく「モメンタム空間」にチャネル分析を適用するのが特徴。

 主要コンポーネント
 1. RSI（正規化）        — 標準RSIを50=0基準にシフト
 2. RSI-MA（RSIのEMA）   — 平滑化RSI。ユーザー指定のオフセットで左右シフト可能
 3. TSI                  — 二重平滑化モメンタム。±50に正規化
 4. TSI Signal（TSIのEMA）— 平滑化TSI。ユーザー指定のオフセットで左右シフト可能
 5. 合成値ライン          — (1)〜(4)の加重平均 × ユーザー係数（0.5〜1.5）
 6. 回帰チャネル          — 合成値に対する直線回帰。±σ偏差バンド、
                           R²に応じた色変化、過去チャネルの履歴表示

 オフセットシステム
 RSI-MA と TSI Signal はそれぞれ ±20本の描画シフトが可能。
 オフセット付きラインと非オフセットライン（合成値等）のクロス判定は、
 「描画上の同じX座標」でのY値を比較する方式を採用。
 マーカーは視覚的な交差点に正確に表示される。

 クロスシグナル
 ③ RSI × RSI-MA         — RSIモメンタムの基本クロス（デフォルト非表示）
 ④ RSI × TSI            — 異種指標間クロス（デフォルト非表示）
    TSI Signal × RSI     — ダイヤモンドマーカー（デフォルト非表示）
    RSIMA × TSI Signal   — オフセット対応クロス（デフォルト非表示）
 ⑤ RSIMA × 合成値        — 三角マーカー（デフォルト表示）
 ⑥ TSI Signal × 合成値   — 丸マーカー（デフォルト表示）

 回帰チャネル
 合成値に対して最小二乗法で傾き・切片を算出し、line.new()で直線描画。
 N本ごとに再計算。R²をチャネル右端にラベル表示。
 R²が高い=鮮やかな青/緑（明確なトレンド）、低い=灰色（ノイズ）。
 過去チャネルは灰色ドット線で残り、トレンド推移を確認可能。

 ダッシュボードテーブル
 右上にリアルタイム値を表示: RSI, RSI-MA, TSI, TSI Signal,
 MA-Signal差, オフセット設定, 合成値, R²。

 アラート
 全クロスタイプのJSON形式alertconditionを搭載。Webhook連携対応。

## Source Code

````pine
// ============================================================================
// RSI + TSI Normalized  v4 (fixed)
// ============================================================================
//@version=6
indicator("RSI + TSI Normalized v4", overlay=false, max_bars_back=1000,
     max_lines_count=500, max_labels_count=100)

// ════════════════════════════════════════
// 入力
// ════════════════════════════════════════
var G_RSI   = "RSI"
var G_TSI   = "TSI"
var G_NRM   = "表示設定"
var G_OFS   = "Offset（描画シフト）"
var G_REG   = "回帰チャネル"
var G_COL   = "カラー設定"
var G_CROSS = "クロス設定"

rsi_len    = input.int(14, "RSI Length",    group=G_RSI)
rsi_ma_len = input.int(14, "RSI MA Length", group=G_RSI)

tsi_long   = input.int(22, "TSI Long",      group=G_TSI)
tsi_short  = input.int(11, "TSI Short",     group=G_TSI)
tsi_signal = input.int(11, "TSI Signal",    group=G_TSI)

nrm_scale = input.float(50.0, "正規化スケール(±)", group=G_NRM)
show_raw  = input.bool(true, "テーブル表示", group=G_NRM)

ofs_rsima  = input.int(0, "RSI-MA オフセット(本)",     minval=-20, maxval=20, group=G_OFS)
ofs_tsisig = input.int(0, "TSI Signal オフセット(本)", minval=-20, maxval=20, group=G_OFS)

reg_len      = input.int(40,   "回帰期間",         minval=10,  maxval=200, group=G_REG)
reg_dev      = input.float(2.0,"偏差バンド倍率",    minval=0.5, maxval=4.0, step=0.1, group=G_REG)
reg_recalc   = input.int(10,   "再計算間隔(本)",    minval=1,   maxval=50,  group=G_REG)
reg_extend   = input.int(5,    "チャネル延長(本)",  minval=0,   maxval=30,  group=G_REG)
reg_w_rsi    = input.float(1.0,"合成: RSI重み",     minval=0, maxval=3.0, step=0.1, group=G_REG)
reg_w_rsima  = input.float(1.0,"合成: RSIMA重み",   minval=0, maxval=3.0, step=0.1, group=G_REG)
reg_w_tsi    = input.float(1.0,"合成: TSI重み",     minval=0, maxval=3.0, step=0.1, group=G_REG)
reg_w_tsisig = input.float(1.0,"合成: TSISig重み",  minval=0, maxval=3.0, step=0.1, group=G_REG)
reg_comp_k   = input.float(1.0,"合成値 係数",       minval=0.5, maxval=1.5, step=0.05, group=G_REG,
     tooltip="合成値全体にかける係数。1.0=そのまま。\n<1.0: 振幅縮小 / >1.0: 振幅拡大")
show_reg     = input.bool(true,"回帰チャネル表示",   group=G_REG)
show_comp    = input.bool(true,"合成値ライン表示",   group=G_REG)
show_history = input.bool(true,"過去チャネル残す",   group=G_REG)
max_channels = input.int(8,    "過去チャネル最大数", minval=1, maxval=20, group=G_REG)
band_transp  = input.int(20,   "バンド透明度(0-90)", minval=0, maxval=90, step=5, group=G_REG)
center_transp = input.int(0,   "中心線透明度(0-90)", minval=0, maxval=90, step=5, group=G_REG)
hist_transp  = input.int(60,   "過去チャネル透明度(0-90)", minval=0, maxval=90, step=5, group=G_REG)

col_rsi      = input.color(#a855f7, "RSI",          inline="col1", group=G_COL)
col_rsima    = input.color(#e8a838, "RSI-MA",       inline="col1", group=G_COL)
col_tsi      = input.color(#5b9cf6, "TSI",          inline="col2", group=G_COL)
col_tsisig   = input.color(#ef4444, "TSI Signal",   inline="col2", group=G_COL)
col_comp     = input.color(#000000, "合成値",        inline="col3", group=G_COL)
col_hline20  = input.color(#FF9800, "±20ライン",    inline="col4", group=G_COL)

show_rsima_comp_cross = input.bool(true, "RSIMA×合成値クロス表示", group=G_CROSS)
show_tsisig_comp_cross = input.bool(true, "TSISig×合成値クロス表示", group=G_CROSS)
col_cross_bull = input.color(#3fb950, "ブルクロス色",  inline="cx1", group=G_CROSS)
col_cross_bear = input.color(#f85149, "ベアクロス色",  inline="cx1", group=G_CROSS)

// ════════════════════════════════════════
// RSI計算
// ════════════════════════════════════════
float rsi_val     = ta.rsi(close, rsi_len)
float rsi_ma      = ta.ema(rsi_val, rsi_ma_len)
float rsi_norm    = (rsi_val - 50.0) / 50.0 * nrm_scale
float rsi_ma_norm = (rsi_ma  - 50.0) / 50.0 * nrm_scale

// ════════════════════════════════════════
// TSI計算
// ════════════════════════════════════════
float pc      = ta.change(close)
float ds      = ta.ema(ta.ema(pc,          tsi_long), tsi_short)
float ds_abs  = ta.ema(ta.ema(math.abs(pc), tsi_long), tsi_short)
float tsi_val = ds_abs != 0.0 ? 100.0 * ds / ds_abs : 0.0
float tsi_sig = ta.ema(tsi_val, tsi_signal)
float tsi_norm     = tsi_val / 100.0 * nrm_scale
float tsi_sig_norm = tsi_sig / 100.0 * nrm_scale

// ════════════════════════════════════════
// 合成値（係数適用済み）
// ════════════════════════════════════════
float w_total = reg_w_rsi + reg_w_rsima + reg_w_tsi + reg_w_tsisig
float composite = w_total > 0 ? (rsi_norm * reg_w_rsi + rsi_ma_norm * reg_w_rsima + tsi_norm * reg_w_tsi + tsi_sig_norm * reg_w_tsisig) / w_total * reg_comp_k : 0.0

// ════════════════════════════════════════
// RSIMA × 合成値 クロス検出（オフセット対応）
// ════════════════════════════════════════
// RSIMAの描画: offset=ofs_rsima で描画シフト
// 合成値の描画: offset=0（シフトなし）
//
// 視覚的クロス = 同じ「描画X座標」上でのY値の交差
//
// RSIMAのbar_index=B での値は、描画位置 X = B + ofs_rsima に表示される。
// 合成値のbar_index=B での値は、描画位置 X = B に表示される。
//
// 描画位置 X に表示されるのは:
//   RSIMA:  bar_index = X - ofs_rsima で計算された rsi_ma_norm
//   合成値: bar_index = X で計算された composite
//
// 現バー(bar_index)が描画位置 X のとき:
//   RSIMA側:  rsi_ma_norm[X - (X - ofs_rsima)] ではなく
//             bar_index = X - ofs_rsima のときの値
//           = rsi_ma_norm[-ofs_rsima] （-ofs_rsimaが正なら過去参照可能）
//   合成値側: composite（現バー）
//
// ofs_rsima < 0 (例: -4):
//   -ofs_rsima = 4 → rsi_ma_norm[4] vs composite
//   「4本前に計算されたRSIMA」が描画上は現バー位置に表示されている
//   マーカーはoffset=0（現バー描画位置に表示）
//
// ofs_rsima > 0 (例: +3):
//   -ofs_rsima = -3 → 未来参照になり不可
//   → 逆に composite[ofs_rsima] vs rsi_ma_norm で比較
//   マーカーはoffset=ofs_rsima
//
// ofs_rsima = 0: そのまま比較

int abs_ofs_r = math.abs(ofs_rsima)

float cr_rsima_now  = na
float cr_rsima_prev = na
float cr_rcomp_now  = na
float cr_rcomp_prev = na
int   cr_marker_ofs = 0

if ofs_rsima < 0
    // 描画上の現バー位置: abs_ofs_r本前のRSIMA vs 現バーのcomposite
    cr_rsima_now  := rsi_ma_norm[abs_ofs_r]
    cr_rsima_prev := rsi_ma_norm[abs_ofs_r + 1]
    cr_rcomp_now  := composite
    cr_rcomp_prev := composite[1]
    cr_marker_ofs := 0
else if ofs_rsima > 0
    // 描画上の現バー位置: 現バーのRSIMA vs ofs_rsima本前のcomposite
    cr_rsima_now  := rsi_ma_norm
    cr_rsima_prev := rsi_ma_norm[1]
    cr_rcomp_now  := composite[ofs_rsima]
    cr_rcomp_prev := composite[ofs_rsima + 1]
    cr_marker_ofs := ofs_rsima
else
    cr_rsima_now  := rsi_ma_norm
    cr_rsima_prev := rsi_ma_norm[1]
    cr_rcomp_now  := composite
    cr_rcomp_prev := composite[1]
    cr_marker_ofs := 0

float rc_diff_now  = cr_rsima_now  - cr_rcomp_now
float rc_diff_prev = cr_rsima_prev - cr_rcomp_prev

bool cross_rsima_comp_up = rc_diff_now > 0 and rc_diff_prev <= 0
bool cross_rsima_comp_dn = rc_diff_now < 0 and rc_diff_prev >= 0
bool rsima_above_comp    = rc_diff_now > 0

// ════════════════════════════════════════
// TSI Signal × 合成値 クロス検出（オフセット対応）
// ════════════════════════════════════════
// 同じロジック: ofs_tsisig で描画シフトされたTSI Signal vs offset=0の合成値

int abs_ofs_t = math.abs(ofs_tsisig)

float cr_tsisig_now  = na
float cr_tsisig_prev = na
float cr_tcomp_now   = na
float cr_tcomp_prev  = na
int   cr_tsisig_marker_ofs = 0

if ofs_tsisig < 0
    cr_tsisig_now  := tsi_sig_norm[abs_ofs_t]
    cr_tsisig_prev := tsi_sig_norm[abs_ofs_t + 1]
    cr_tcomp_now   := composite
    cr_tcomp_prev  := composite[1]
    cr_tsisig_marker_ofs := 0
else if ofs_tsisig > 0
    cr_tsisig_now  := tsi_sig_norm
    cr_tsisig_prev := tsi_sig_norm[1]
    cr_tcomp_now   := composite[ofs_tsisig]
    cr_tcomp_prev  := composite[ofs_tsisig + 1]
    cr_tsisig_marker_ofs := ofs_tsisig
else
    cr_tsisig_now  := tsi_sig_norm
    cr_tsisig_prev := tsi_sig_norm[1]
    cr_tcomp_now   := composite
    cr_tcomp_prev  := composite[1]
    cr_tsisig_marker_ofs := 0

float tc_diff_now  = cr_tsisig_now  - cr_tcomp_now
float tc_diff_prev = cr_tsisig_prev - cr_tcomp_prev

bool cross_tsisig_comp_up = tc_diff_now > 0 and tc_diff_prev <= 0
bool cross_tsisig_comp_dn = tc_diff_now < 0 and tc_diff_prev >= 0

// ════════════════════════════════════════
// 回帰計算
// ════════════════════════════════════════
calcLinReg(float src, int len) =>
    float sumX  = 0.0
    float sumY  = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    float sumResid2 = 0.0
    float sumY2dev  = 0.0
    for i = 0 to len - 1
        float x = float(i)
        float y = nz(src[len - 1 - i], 0.0)
        sumX  += x
        sumY  += y
        sumXY += x * y
        sumX2 += x * x
    float n     = float(len)
    float denom = n * sumX2 - sumX * sumX
    float slope = denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0
    float intercept = (sumY - slope * sumX) / n
    float meanY = sumY / n
    for i = 0 to len - 1
        float x = float(i)
        float y = nz(src[len - 1 - i], 0.0)
        float predicted = intercept + slope * x
        sumResid2 += math.pow(y - predicted, 2)
        sumY2dev  += math.pow(y - meanY, 2)
    float stdev = math.sqrt(sumResid2 / n)
    float r2 = sumY2dev > 0 ? 1.0 - sumResid2 / sumY2dev : 0.0
    float y_start = intercept
    float y_end   = intercept + slope * (n - 1)
    [y_start, y_end, slope, stdev, r2]

// ════════════════════════════════════════
// 直線チャネル描画
// ════════════════════════════════════════
var line line_upper  = na
var line line_center = na
var line line_lower  = na
var label lbl_r2     = na
var array<line> hist_lines = array.new_line()

bool doCalc = show_reg and bar_index >= reg_len and bar_index % reg_recalc == 0

if doCalc
    [y_start, y_end, slope, stdev, r2] = calcLinReg(composite, reg_len)
    float band = stdev * reg_dev
    int x_left  = bar_index - reg_len + 1
    int x_right = bar_index + reg_extend
    float y_ext = y_end + slope * reg_extend

    float r2_clamped = math.max(0.0, math.min(1.0, r2))
    color col_center_line = color.from_gradient(r2_clamped, 0.0, 1.0, color.new(#888888, center_transp), color.new(#42A5F5, center_transp))
    color col_band_line   = color.from_gradient(r2_clamped, 0.0, 1.0, color.new(#888888, band_transp), color.new(#26A69A, band_transp))

    if show_history
        if not na(line_upper)
            array.push(hist_lines, line_upper)
            array.push(hist_lines, line_center)
            array.push(hist_lines, line_lower)
        while array.size(hist_lines) > max_channels * 3
            line old = array.shift(hist_lines)
            line.delete(old)
    else
        line.delete(line_upper)
        line.delete(line_center)
        line.delete(line_lower)

    label.delete(lbl_r2)

    if show_history and array.size(hist_lines) > 0
        for i = 0 to array.size(hist_lines) - 1
            line l = array.get(hist_lines, i)
            if not na(l)
                line.set_color(l, color.new(#888888, hist_transp))
                line.set_width(l, 1)
                line.set_style(l, line.style_dotted)

    line_center := line.new(x_left, y_start, x_right, y_ext, color=col_center_line, width=2, style=line.style_solid)
    line_upper  := line.new(x_left, y_start + band, x_right, y_ext + band, color=col_band_line, width=1, style=line.style_dashed)
    line_lower  := line.new(x_left, y_start - band, x_right, y_ext - band, color=col_band_line, width=1, style=line.style_dashed)

    string r2_str = "R²=" + str.tostring(math.round(r2, 2))
    color lbl_col = r2_clamped > 0.5 ? color.new(#26A69A, 20) : color.new(#888888, 20)
    lbl_r2 := label.new(x_right + 1, y_ext, r2_str, color=color.new(#000000, 100), textcolor=lbl_col, style=label.style_label_left, size=size.small)

// ════════════════════════════════════════
// 水平ライン
// ════════════════════════════════════════
hline(0,                "ゼロライン",  color.new(#888888, 40), linestyle=hline.style_solid,  linewidth=1)
hline( nrm_scale,       "+Scale",     color.new(#888888, 70), linestyle=hline.style_dashed)
hline(-nrm_scale,       "-Scale",     color.new(#888888, 70), linestyle=hline.style_dashed)
hline( nrm_scale * 0.4, "+40%",       color.new(#888888, 85), linestyle=hline.style_dotted)
hline(-nrm_scale * 0.4, "-40%",       color.new(#888888, 85), linestyle=hline.style_dotted)
hline( 20,              "+20",        color.new(col_hline20, 60), linestyle=hline.style_dashed, linewidth=1)
hline(-20,              "-20",        color.new(col_hline20, 60), linestyle=hline.style_dashed, linewidth=1)

// ════════════════════════════════════════
// プロット
// ════════════════════════════════════════
rsi_plot     = plot(rsi_norm,     "RSI(正規化)",        col_rsi,    linewidth=1)
rsi_ma_plot  = plot(rsi_ma_norm,  "RSI-MA(正規化)",     col_rsima,  linewidth=2, offset=ofs_rsima)
tsi_plot     = plot(tsi_norm,     "TSI(正規化)",        col_tsi,    linewidth=1)
tsi_sig_plot = plot(tsi_sig_norm, "TSI Signal(正規化)", col_tsisig, linewidth=2, offset=ofs_tsisig)

fill(rsi_plot, rsi_ma_plot,
     rsi_norm > rsi_ma_norm ? color.new(col_rsi, 88) : color.new(col_tsi, 88))

// 合成値: 単色、linewidth=2（スタイルはスタイルタブから変更可能）
plot(show_comp ? composite : na, "合成値", col_comp, linewidth=2, style=plot.style_line)

// ════════════════════════════════════════
// クロス検出（既存）
// ════════════════════════════════════════
bool cross_rsi_ma_up = ta.crossover( rsi_norm, rsi_ma_norm)
bool cross_rsi_ma_dn = ta.crossunder(rsi_norm, rsi_ma_norm)
bool cross_rsi_tsi_up = ta.crossover( rsi_norm, tsi_norm)
bool cross_rsi_tsi_dn = ta.crossunder(rsi_norm, tsi_norm)
bool cross_tsisig_rsi_up = ta.crossover( tsi_sig_norm, rsi_norm)
bool cross_tsisig_rsi_dn = ta.crossunder(tsi_sig_norm, rsi_norm)

int ofs_diff = ofs_rsima - ofs_tsisig
int abs_diff = math.abs(ofs_diff)
float vis_rma_now  = ofs_diff <= 0 ? rsi_ma_norm    : rsi_ma_norm[abs_diff]
float vis_tss_now  = ofs_diff >= 0 ? tsi_sig_norm   : tsi_sig_norm[abs_diff]
float vis_rma_prev = ofs_diff <= 0 ? rsi_ma_norm[1] : rsi_ma_norm[abs_diff + 1]
float vis_tss_prev = ofs_diff >= 0 ? tsi_sig_norm[1] : tsi_sig_norm[abs_diff + 1]
float vis_diff_now  = vis_rma_now  - vis_tss_now
float vis_diff_prev = vis_rma_prev - vis_tss_prev
bool cross_rsima_tsisig_up = vis_diff_now > 0 and vis_diff_prev <= 0
bool cross_rsima_tsisig_dn = vis_diff_now < 0 and vis_diff_prev >= 0
int shape_mt_ofs = math.round((ofs_rsima + ofs_tsisig) / 2)

// 既存クロスマーカー（デフォルト非表示）
plotshape(cross_rsi_ma_up,       "③↑ RSI×MA上抜",      shape.triangleup,   location.bottom, color.new(col_rsi, 0),      size=size.tiny,  offset=ofs_rsima,   display=display.none)
plotshape(cross_rsi_ma_dn,       "③↓ RSI×MA下抜",      shape.triangledown, location.top,    color.new(col_rsi, 0),      size=size.tiny,  offset=ofs_rsima,   display=display.none)
plotshape(cross_rsi_tsi_up,      "④↑ RSI×TSI上抜",     shape.triangleup,   location.bottom, color.new(col_cross_bull,0), size=size.small, offset=0,           display=display.none)
plotshape(cross_rsi_tsi_dn,      "④↓ RSI×TSI下抜",     shape.triangledown, location.top,    color.new(col_cross_bear,0), size=size.small, offset=0,           display=display.none)
plotshape(cross_tsisig_rsi_up,   "↑ TSISig×RSI上抜",   shape.diamond,      location.bottom, color.new(#c084fc, 0),      size=size.tiny,  offset=ofs_tsisig,  display=display.none)
plotshape(cross_tsisig_rsi_dn,   "↓ TSISig×RSI下抜",   shape.diamond,      location.top,    color.new(#c084fc, 0),      size=size.tiny,  offset=ofs_tsisig,  display=display.none)
plotshape(cross_rsima_tsisig_up, "↑ RSIMA×TSISig上抜", shape.cross,        location.bottom, color.new(col_cross_bull,0), size=size.small, offset=shape_mt_ofs, display=display.none)
plotshape(cross_rsima_tsisig_dn, "↓ RSIMA×TSISig下抜", shape.cross,        location.top,    color.new(col_cross_bear,0), size=size.small, offset=shape_mt_ofs, display=display.none)

// RSIMA × 合成値 クロスマーカー
plotshape(show_rsima_comp_cross and cross_rsima_comp_up, "⑤↑ RSIMA×合成値 上抜", shape.triangleup,   location.bottom, color.new(col_cross_bull, 0), size=size.small, offset=cr_marker_ofs)
plotshape(show_rsima_comp_cross and cross_rsima_comp_dn, "⑤↓ RSIMA×合成値 下抜", shape.triangledown, location.top,    color.new(col_cross_bear, 0), size=size.small, offset=cr_marker_ofs)

// TSI Signal × 合成値 クロスマーカー
plotshape(show_tsisig_comp_cross and cross_tsisig_comp_up, "⑥↑ TSISig×合成値 上抜", shape.circle, location.bottom, color.new(col_cross_bull, 0), size=size.tiny, offset=cr_tsisig_marker_ofs)
plotshape(show_tsisig_comp_cross and cross_tsisig_comp_dn, "⑥↓ TSISig×合成値 下抜", shape.circle, location.top,    color.new(col_cross_bear, 0), size=size.tiny, offset=cr_tsisig_marker_ofs)

// ════════════════════════════════════════
// テーブル
// ════════════════════════════════════════
var table raw_tbl = table.new(position.top_right, 2, 11,
     bgcolor=color.new(#161b22, 10),
     border_color=color.new(#30363d, 0), border_width=1)

if barstate.islast and show_raw
    table.cell(raw_tbl, 0, 0, "指標",         text_color=#8b949e, text_size=size.normal, bgcolor=#21262d)
    table.cell(raw_tbl, 1, 0, "状態",          text_color=#8b949e, text_size=size.normal, bgcolor=#21262d)
    table.cell(raw_tbl, 0, 1, "RSI",           text_color=col_rsi, text_size=size.normal)
    table.cell(raw_tbl, 1, 1, str.tostring(math.round(rsi_val, 1)),
         text_color=rsi_val>=70?#f85149:rsi_val<=30?#3fb950:#f0f6fc, text_size=size.normal)
    table.cell(raw_tbl, 0, 2, "RSI-MA",        text_color=col_rsima, text_size=size.normal)
    table.cell(raw_tbl, 1, 2, str.tostring(math.round(rsi_ma, 1)),
         text_color=rsi_ma_norm>0?#3fb950:#f85149, text_size=size.normal)
    table.cell(raw_tbl, 0, 3, "TSI",           text_color=col_tsi, text_size=size.normal)
    table.cell(raw_tbl, 1, 3, str.tostring(math.round(tsi_val, 3)),
         text_color=tsi_val>0?#3fb950:#f85149, text_size=size.normal)
    table.cell(raw_tbl, 0, 4, "TSI Signal",    text_color=col_tsisig, text_size=size.normal)
    table.cell(raw_tbl, 1, 4, str.tostring(math.round(tsi_sig, 3)),
         text_color=tsi_sig_norm>0?#3fb950:#f85149, text_size=size.normal)
    table.cell(raw_tbl, 0, 5, "MA-Sig差",      text_color=#f0f6fc, text_size=size.normal)
    table.cell(raw_tbl, 1, 5, str.tostring(math.round(rsi_ma_norm - tsi_sig_norm, 2)),
         text_color=rsi_ma_norm - tsi_sig_norm>0?#3fb950:#f85149, text_size=size.normal)
    table.cell(raw_tbl, 0, 6, "RSI-MA Ofs",    text_color=#8b949e, text_size=size.normal)
    table.cell(raw_tbl, 1, 6, str.tostring(ofs_rsima) + "本",
         text_color=ofs_rsima!=0?#d29922:#8b949e, text_size=size.normal)
    table.cell(raw_tbl, 0, 7, "TSISig Ofs",    text_color=#8b949e, text_size=size.normal)
    table.cell(raw_tbl, 1, 7, str.tostring(ofs_tsisig) + "本",
         text_color=ofs_tsisig!=0?#d29922:#8b949e, text_size=size.normal)
    table.cell(raw_tbl, 0, 8, "──回帰──",      text_color=#8b949e, text_size=size.small, bgcolor=#21262d)
    table.cell(raw_tbl, 1, 8, "",               text_color=#8b949e, text_size=size.small, bgcolor=#21262d)
    table.cell(raw_tbl, 0, 9, "合成値",         text_color=#42A5F5, text_size=size.normal)
    table.cell(raw_tbl, 1, 9, str.tostring(math.round(composite, 1)),
         text_color=composite>0?#3fb950:#f85149, text_size=size.normal)
    float comp_stdev = ta.stdev(composite, reg_len)
    float reg_stdev = ta.stdev(composite - ta.linreg(composite, reg_len, 0), reg_len)
    float disp_r2 = comp_stdev > 1e-10 ? math.max(0.0, 1.0 - math.pow(reg_stdev / comp_stdev, 2)) : 0.0
    table.cell(raw_tbl, 0, 10, "R²",            text_color=#42A5F5, text_size=size.normal)
    table.cell(raw_tbl, 1, 10, str.tostring(math.round(disp_r2, 3)),
         text_color=disp_r2>0.5?#3fb950:disp_r2>0.25?#d29922:#f85149, text_size=size.normal)

// ════════════════════════════════════════
// アラート
// ════════════════════════════════════════
alertcondition(cross_rsi_ma_up,       "③↑ RSI が RSI-MA を上抜け",       '{"type":"RSI_MA_UP","time":"{{timenow}}"}')
alertcondition(cross_rsi_ma_dn,       "③↓ RSI が RSI-MA を下抜け",       '{"type":"RSI_MA_DN","time":"{{timenow}}"}')
alertcondition(cross_rsi_tsi_up,      "④↑ RSI が TSI を上抜け",          '{"type":"RSI_TSI_UP","time":"{{timenow}}"}')
alertcondition(cross_rsi_tsi_dn,      "④↓ RSI が TSI を下抜け",          '{"type":"RSI_TSI_DN","time":"{{timenow}}"}')
alertcondition(cross_tsisig_rsi_up,   "↑ TSI Signal が RSI を上抜け",    '{"type":"TSISIG_RSI_UP","time":"{{timenow}}"}')
alertcondition(cross_tsisig_rsi_dn,   "↓ TSI Signal が RSI を下抜け",    '{"type":"TSISIG_RSI_DN","time":"{{timenow}}"}')
alertcondition(cross_rsima_tsisig_up, "↑ RSIMA が TSI Signal を上抜け",  '{"type":"RSIMA_TSISIG_UP","time":"{{timenow}}"}')
alertcondition(cross_rsima_tsisig_dn, "↓ RSIMA が TSI Signal を下抜け",  '{"type":"RSIMA_TSISIG_DN","time":"{{timenow}}"}')
alertcondition(cross_rsima_comp_up,   "⑤↑ RSIMA が 合成値を上抜け",     '{"type":"RSIMA_COMP_UP","time":"{{timenow}}"}')
alertcondition(cross_rsima_comp_dn,   "⑤↓ RSIMA が 合成値を下抜け",     '{"type":"RSIMA_COMP_DN","time":"{{timenow}}"}')
alertcondition(cross_tsisig_comp_up,  "⑥↑ TSISig が 合成値を上抜け",    '{"type":"TSISIG_COMP_UP","time":"{{timenow}}"}')
alertcondition(cross_tsisig_comp_dn,  "⑥↓ TSISig が 合成値を下抜け",    '{"type":"TSISIG_COMP_DN","time":"{{timenow}}"}')
````
