# MTF MA System by ogudora

- url: https://www.tradingview.com/script/8CoafNwV/
- type: indicator
- pine_id: PUB;ac79ff65126b443bb2b1bac7646cf8b6
- version: 1.0

## Description

# MTF MA System by ogudora

A multi-timeframe moving average indicator designed for traders who need to read multiple MAs at a glance without losing track of which line belongs to which timeframe.

## What it does

Plots short, mid, and long-term moving averages from up to four timeframes simultaneously: the current chart timeframe, 1H, 4H, and Daily. Each line is identified by three independent visual dimensions:

- **Color** indicates the period (short / mid / long)
- **ATR-based halo width** indicates the timeframe (higher TF = wider halo)
- **Line style and thickness** add another layer of timeframe distinction

This three-axis encoding eliminates the common problem of MTF MA indicators where users lose track of which line is which.

## Key features

**RTH-only calculation by default.** Upper timeframe MAs are calculated using Regular Trading Hours data only, independent of the chart's Extended Hours setting. This ensures that the same MA value appears regardless of which timeframe chart you are viewing. ETH-inclusive mode is available as a toggle.

**ATR-based halo bands.** Instead of a single thin line, each MA is drawn with a translucent halo whose width scales with current ATR. Higher timeframes get wider halos, so a daily MA visually feels like a zone, while a 1H MA reads as a precise line.

**Per-timeframe line thickness and style.** Each TF group has independent settings for line thickness (1 to 4) and style (plain / stepline / stepline with diamonds). The default uses a diamond stepline for 4H to give it a distinctive "ladder" appearance.

**Keep-out labels.** Optional labels along each MA line at regular intervals, useful for marking visual zones across the chart.

**Auto TF filtering.** Lower timeframe MAs are automatically hidden when you switch to a higher chart TF, preventing visual clutter on long-term charts.

## Default configuration

- **MA type:** EMA, periods 20 / 50 / 200
- **Timeframes:** 1H, 4H, Daily (current chart TF off by default)
- **Session:** RTH only
- **Colors:** magenta (short) / green (mid) / purple (long)
- **Halo widths:** 1H = 0.1×ATR, 4H = 0.1×ATR, Daily = 0.4×ATR
- **Line thickness:** 1H = 3, 4H = 1, Daily = 3
- **4H line style:** stepline with diamonds

These defaults are tuned for U.S. equities and Japanese equities on intraday-to-swing timeframes. All values are user-configurable.

## Notes on session handling

For U.S. stocks, the 4H EMA200 calculated from RTH data and from ETH-inclusive data can differ by 10–15% during volatile periods. The default RTH mode aligns with how most institutional desks read moving averages. If you trade extended-hours moves and prefer ETH-inclusive calculation, toggle the session setting in the indicator inputs.

## Compatible markets

Designed and tested on U.S. equities (NASDAQ, NYSE) and Japanese equities. Should work on any symbol where the underlying exchange has a defined Regular Trading Hours session.

## Why I built this

After years of running MTF MA indicators that became unreadable once more than four or five lines were on screen, I wanted a system that uses encoding redundancy — color, halo width, and line style — so that any single line could be identified without reading its legend. This indicator is the result of that iteration.

Feedback and suggestions are welcome.

## Source Code

````pine
//@version=6
indicator("MTF MA System by ogudora", shorttitle="MTF-MA", overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=5000)

// ============================================================
// MTF Moving Average System v8
// 設計思想:
//   期間 = 色 (慣習色を尊重)
//   TF   = ハイライター幅 (ATRベース、上位足ほど太く)
//   TF   = 線種 (4Hダイヤ付きステップで識別性向上)
//   実装: fill() で本線の上下を塗りつぶし → 太いハロー実現
// 
// v8 変更点 (セッション設定追加):
//   - デフォルトで RTH (Regular Trading Hours) のみで計算
//   - スイッチでチャート設定に従う (ETH含む) モードに切替可能
//   - 検証: ZSの過去チャートで RTH版 4H EMA200 が
//     下落トレンドの戻り売りライン、上昇トレンドのサポートとして
//     繰り返し機能することを確認 (画像1/4/7の検証)
// ============================================================

GRP_MA   = "■ MA設定"
GRP_TF   = "■ 表示するTF"
GRP_SESS = "■ セッション設定"
GRP_COL  = "■ 色 (期間ベース)"
GRP_HALO = "■ ハイライター (ATRベース)"
GRP_STYL = "■ 線種 (TFベース)"
GRP_LBL  = "■ Keep Outラベル"
GRP_FLT  = "■ 自動TFフィルタ"

// ===== MA種別と期間 =====
ma_type     = input.string("EMA", "MA種別", options=["EMA", "SMA"], group=GRP_MA)
len_short   = input.int(20,  "短期 期間", minval=1, group=GRP_MA)
len_mid     = input.int(50,  "中期 期間", minval=1, group=GRP_MA)
len_long    = input.int(200, "長期 期間", minval=1, group=GRP_MA)

// ===== 表示TF =====
show_min  = input.bool(false, "現在チャートTF", group=GRP_TF)
show_1h   = input.bool(true,  "1時間足", group=GRP_TF)
show_4h   = input.bool(true,  "4時間足", group=GRP_TF)
show_d    = input.bool(true,  "日足",    group=GRP_TF)

tf_1h     = input.timeframe("60",  "1H TF", group=GRP_TF)
tf_4h     = input.timeframe("240", "4H TF", group=GRP_TF)
tf_d      = input.timeframe("D",   "Daily TF", group=GRP_TF)

// ===== セッション設定 =====
session_mode = input.string("RTH (時間外を含まない)", "上位足MAのセッション",
     options=["RTH (時間外を含まない)", "チャート設定に従う (時間外含む可)"],
     tooltip="RTHは米国株の通常取引時間のみで計算。チャート設定に従う場合、Extended Hours表示時は時間外取引も含めて計算される。",
     group=GRP_SESS)

// ===== 色 =====
col_short = input.color(color.new(#E91E63, 0), "短期 色", group=GRP_COL)
col_mid   = input.color(color.new(#4CAF50, 0), "中期 色", group=GRP_COL)
col_long  = input.color(color.new(#9C27B0, 0), "長期 色", group=GRP_COL)

// ===== ハイライター =====
atr_len     = input.int(14, "ATR算出期間", minval=1, group=GRP_HALO)
halo_min_x  = input.float(0.0, "現TF ハロー幅 (×ATR)", minval=0, maxval=5, step=0.1, group=GRP_HALO)
halo_1h_x   = input.float(0.1, "1H  ハロー幅 (×ATR)", minval=0, maxval=5, step=0.1, group=GRP_HALO)
halo_4h_x   = input.float(0.2, "4H  ハロー幅 (×ATR)", minval=0, maxval=5, step=0.1, group=GRP_HALO)
halo_d_x    = input.float(0.4, "日足 ハロー幅 (×ATR)", minval=0, maxval=5, step=0.1, group=GRP_HALO)
halo_transp = input.int(65, "ハロー透過度", minval=50, maxval=95, group=GRP_HALO)
line_w_main = input.int(2, "本線の太さ", minval=1, maxval=4, group=GRP_HALO)

// ===== 線種 (TFベース) =====
style_min_s = input.string("plain",            "現TF 線種", options=["plain", "stepline", "stepline_diamond"], group=GRP_STYL)
style_1h_s  = input.string("plain",            "1H  線種", options=["plain", "stepline", "stepline_diamond"], group=GRP_STYL)
style_4h_s  = input.string("stepline_diamond", "4H  線種", options=["plain", "stepline", "stepline_diamond"], group=GRP_STYL)
style_d_s   = input.string("plain",            "日足 線種", options=["plain", "stepline", "stepline_diamond"], group=GRP_STYL)

f_pstyle(s) =>
    s == "stepline"          ? plot.style_stepline          :
     s == "stepline_diamond"  ? plot.style_stepline_diamond  :
     plot.style_line

pst_min = f_pstyle(style_min_s)
pst_1h  = f_pstyle(style_1h_s)
pst_4h  = f_pstyle(style_4h_s)
pst_d   = f_pstyle(style_d_s)

// ===== ラベル =====
show_labels   = input.bool(true, "ラベル表示", group=GRP_LBL)
labels_per_ln = input.int(5, "1本あたりラベル数", minval=2, maxval=10, group=GRP_LBL)
label_size    = input.string("normal", "ラベルサイズ", options=["tiny","small","normal"], group=GRP_LBL)

// ===== TFフィルタ =====
auto_filter   = input.bool(true, "現在TF未満を非表示", group=GRP_FLT)

// ============================================================
// セッション固定 ticker の構築
// RTHモード時: ticker.modify で session.regular を強制
// チャート従属モード時: syminfo.tickerid をそのまま使用
// ============================================================
use_rth = session_mode == "RTH (時間外を含まない)"
sym_for_mtf = use_rth ? ticker.modify(syminfo.tickerid, session=session.regular) : syminfo.tickerid

// ============================================================
// 現TF MA (チャートと同じTFなのでセッション設定は適用しない)
// ============================================================
f_ma(src, len) =>
    ma_type == "EMA" ? ta.ema(src, len) : ta.sma(src, len)

ma_min_s = f_ma(close, len_short)
ma_min_m = f_ma(close, len_mid)
ma_min_l = f_ma(close, len_long)
atr_cur  = ta.atr(atr_len)

// ============================================================
// MTF MA: request.security を個別に呼び出す
// セッション固定 ticker を使うことで RTH/ETH を制御
// ============================================================
is_ema = ma_type == "EMA"

// 1H
ma_1h_s = request.security(sym_for_mtf, tf_1h,
     is_ema ? ta.ema(close, len_short) : ta.sma(close, len_short),
     barmerge.gaps_off, barmerge.lookahead_off)
ma_1h_m = request.security(sym_for_mtf, tf_1h,
     is_ema ? ta.ema(close, len_mid) : ta.sma(close, len_mid),
     barmerge.gaps_off, barmerge.lookahead_off)
ma_1h_l = request.security(sym_for_mtf, tf_1h,
     is_ema ? ta.ema(close, len_long) : ta.sma(close, len_long),
     barmerge.gaps_off, barmerge.lookahead_off)

// 4H
ma_4h_s = request.security(sym_for_mtf, tf_4h,
     is_ema ? ta.ema(close, len_short) : ta.sma(close, len_short),
     barmerge.gaps_off, barmerge.lookahead_off)
ma_4h_m = request.security(sym_for_mtf, tf_4h,
     is_ema ? ta.ema(close, len_mid) : ta.sma(close, len_mid),
     barmerge.gaps_off, barmerge.lookahead_off)
ma_4h_l = request.security(sym_for_mtf, tf_4h,
     is_ema ? ta.ema(close, len_long) : ta.sma(close, len_long),
     barmerge.gaps_off, barmerge.lookahead_off)

// 日足
ma_d_s = request.security(sym_for_mtf, tf_d,
     is_ema ? ta.ema(close, len_short) : ta.sma(close, len_short),
     barmerge.gaps_off, barmerge.lookahead_off)
ma_d_m = request.security(sym_for_mtf, tf_d,
     is_ema ? ta.ema(close, len_mid) : ta.sma(close, len_mid),
     barmerge.gaps_off, barmerge.lookahead_off)
ma_d_l = request.security(sym_for_mtf, tf_d,
     is_ema ? ta.ema(close, len_long) : ta.sma(close, len_long),
     barmerge.gaps_off, barmerge.lookahead_off)

// ============================================================
// TFフィルタ
// ============================================================
cur_tf_sec = timeframe.in_seconds(timeframe.period)
sec_1h     = timeframe.in_seconds(tf_1h)
sec_4h     = timeframe.in_seconds(tf_4h)
sec_d      = timeframe.in_seconds(tf_d)

disp_min = show_min
disp_1h  = show_1h and (not auto_filter or cur_tf_sec <= sec_1h)
disp_4h  = show_4h and (not auto_filter or cur_tf_sec <= sec_4h)
disp_d   = show_d  and (not auto_filter or cur_tf_sec <= sec_d)

// ============================================================
// ハロー幅
// ============================================================
w_min = atr_cur * halo_min_x
w_1h  = atr_cur * halo_1h_x
w_4h  = atr_cur * halo_4h_x
w_d   = atr_cur * halo_d_x

// ============================================================
// 本線
// ============================================================
plot(disp_min ? ma_min_s : na, "現TF-短", color=col_short, linewidth=line_w_main, style=pst_min)
plot(disp_min ? ma_min_m : na, "現TF-中", color=col_mid,   linewidth=line_w_main, style=pst_min)
plot(disp_min ? ma_min_l : na, "現TF-長", color=col_long,  linewidth=line_w_main, style=pst_min)

plot(disp_1h ? ma_1h_s : na, "1H-短", color=col_short, linewidth=line_w_main, style=pst_1h)
plot(disp_1h ? ma_1h_m : na, "1H-中", color=col_mid,   linewidth=line_w_main, style=pst_1h)
plot(disp_1h ? ma_1h_l : na, "1H-長", color=col_long,  linewidth=line_w_main, style=pst_1h)

plot(disp_4h ? ma_4h_s : na, "4H-短", color=col_short, linewidth=line_w_main, style=pst_4h)
plot(disp_4h ? ma_4h_m : na, "4H-中", color=col_mid,   linewidth=line_w_main, style=pst_4h)
plot(disp_4h ? ma_4h_l : na, "4H-長", color=col_long,  linewidth=line_w_main, style=pst_4h)

plot(disp_d ? ma_d_s : na, "日足-短", color=col_short, linewidth=line_w_main, style=pst_d)
plot(disp_d ? ma_d_m : na, "日足-中", color=col_mid,   linewidth=line_w_main, style=pst_d)
plot(disp_d ? ma_d_l : na, "日足-長", color=col_long,  linewidth=line_w_main, style=pst_d)

// ============================================================
// ハロー上下境界
// ============================================================
p_min_s_up = plot(disp_min and w_min > 0 ? ma_min_s + w_min/2 : na, display=display.none)
p_min_s_dn = plot(disp_min and w_min > 0 ? ma_min_s - w_min/2 : na, display=display.none)
p_min_m_up = plot(disp_min and w_min > 0 ? ma_min_m + w_min/2 : na, display=display.none)
p_min_m_dn = plot(disp_min and w_min > 0 ? ma_min_m - w_min/2 : na, display=display.none)
p_min_l_up = plot(disp_min and w_min > 0 ? ma_min_l + w_min/2 : na, display=display.none)
p_min_l_dn = plot(disp_min and w_min > 0 ? ma_min_l - w_min/2 : na, display=display.none)

p_1h_s_up = plot(disp_1h and w_1h > 0 ? ma_1h_s + w_1h/2 : na, display=display.none)
p_1h_s_dn = plot(disp_1h and w_1h > 0 ? ma_1h_s - w_1h/2 : na, display=display.none)
p_1h_m_up = plot(disp_1h and w_1h > 0 ? ma_1h_m + w_1h/2 : na, display=display.none)
p_1h_m_dn = plot(disp_1h and w_1h > 0 ? ma_1h_m - w_1h/2 : na, display=display.none)
p_1h_l_up = plot(disp_1h and w_1h > 0 ? ma_1h_l + w_1h/2 : na, display=display.none)
p_1h_l_dn = plot(disp_1h and w_1h > 0 ? ma_1h_l - w_1h/2 : na, display=display.none)

p_4h_s_up = plot(disp_4h and w_4h > 0 ? ma_4h_s + w_4h/2 : na, display=display.none)
p_4h_s_dn = plot(disp_4h and w_4h > 0 ? ma_4h_s - w_4h/2 : na, display=display.none)
p_4h_m_up = plot(disp_4h and w_4h > 0 ? ma_4h_m + w_4h/2 : na, display=display.none)
p_4h_m_dn = plot(disp_4h and w_4h > 0 ? ma_4h_m - w_4h/2 : na, display=display.none)
p_4h_l_up = plot(disp_4h and w_4h > 0 ? ma_4h_l + w_4h/2 : na, display=display.none)
p_4h_l_dn = plot(disp_4h and w_4h > 0 ? ma_4h_l - w_4h/2 : na, display=display.none)

p_d_s_up = plot(disp_d and w_d > 0 ? ma_d_s + w_d/2 : na, display=display.none)
p_d_s_dn = plot(disp_d and w_d > 0 ? ma_d_s - w_d/2 : na, display=display.none)
p_d_m_up = plot(disp_d and w_d > 0 ? ma_d_m + w_d/2 : na, display=display.none)
p_d_m_dn = plot(disp_d and w_d > 0 ? ma_d_m - w_d/2 : na, display=display.none)
p_d_l_up = plot(disp_d and w_d > 0 ? ma_d_l + w_d/2 : na, display=display.none)
p_d_l_dn = plot(disp_d and w_d > 0 ? ma_d_l - w_d/2 : na, display=display.none)

// ============================================================
// fill() でハロー描画
// ============================================================
fill(p_min_s_up, p_min_s_dn, color=color.new(col_short, halo_transp))
fill(p_min_m_up, p_min_m_dn, color=color.new(col_mid,   halo_transp))
fill(p_min_l_up, p_min_l_dn, color=color.new(col_long,  halo_transp))

fill(p_1h_s_up, p_1h_s_dn, color=color.new(col_short, halo_transp))
fill(p_1h_m_up, p_1h_m_dn, color=color.new(col_mid,   halo_transp))
fill(p_1h_l_up, p_1h_l_dn, color=color.new(col_long,  halo_transp))

fill(p_4h_s_up, p_4h_s_dn, color=color.new(col_short, halo_transp))
fill(p_4h_m_up, p_4h_m_dn, color=color.new(col_mid,   halo_transp))
fill(p_4h_l_up, p_4h_l_dn, color=color.new(col_long,  halo_transp))

fill(p_d_s_up, p_d_s_dn, color=color.new(col_short, halo_transp))
fill(p_d_m_up, p_d_m_dn, color=color.new(col_mid,   halo_transp))
fill(p_d_l_up, p_d_l_dn, color=color.new(col_long,  halo_transp))

// ============================================================
// Keep Outラベル
// ============================================================
var label[] g_labels = array.new<label>()

f_lbl_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     size.normal

f_safe_get(series float s, int off) =>
    off >= 0 and off <= bar_index ? s[off] : na

if barstate.islast and show_labels
    while array.size(g_labels) > 0
        lb = array.pop(g_labels)
        label.delete(lb)

    left_t  = chart.left_visible_bar_time
    right_t = chart.right_visible_bar_time

    bars_visible = 100
    if not na(left_t) and not na(right_t) and right_t > left_t
        tf_ms = timeframe.in_seconds(timeframe.period) * 1000
        if tf_ms > 0
            calc = int((right_t - left_t) / tf_ms)
            bars_visible := math.max(20, math.min(calc, 200))

    max_lookback = math.min(bar_index, 200)
    bars_visible := math.min(bars_visible, max_lookback)

    step = math.max(1, int(bars_visible / labels_per_ln))
    sz = f_lbl_size(label_size)

    for i = 0 to labels_per_ln - 1
        offset = step * i
        if offset > max_lookback
            continue
        bi = bar_index - offset

        if disp_min
            v_s = f_safe_get(ma_min_s, offset)
            v_m = f_safe_get(ma_min_m, offset)
            v_l = f_safe_get(ma_min_l, offset)
            if not na(v_s)
                array.push(g_labels, label.new(bi, v_s, "現-S" + str.tostring(len_short), xloc=xloc.bar_index, style=label.style_none, textcolor=col_short, size=sz))
            if not na(v_m)
                array.push(g_labels, label.new(bi, v_m, "現-M" + str.tostring(len_mid),   xloc=xloc.bar_index, style=label.style_none, textcolor=col_mid,   size=sz))
            if not na(v_l)
                array.push(g_labels, label.new(bi, v_l, "現-L" + str.tostring(len_long),  xloc=xloc.bar_index, style=label.style_none, textcolor=col_long,  size=sz))

        if disp_1h
            v_s = f_safe_get(ma_1h_s, offset)
            v_m = f_safe_get(ma_1h_m, offset)
            v_l = f_safe_get(ma_1h_l, offset)
            if not na(v_s)
                array.push(g_labels, label.new(bi, v_s, "1H-S" + str.tostring(len_short), xloc=xloc.bar_index, style=label.style_none, textcolor=col_short, size=sz))
            if not na(v_m)
                array.push(g_labels, label.new(bi, v_m, "1H-M" + str.tostring(len_mid),   xloc=xloc.bar_index, style=label.style_none, textcolor=col_mid,   size=sz))
            if not na(v_l)
                array.push(g_labels, label.new(bi, v_l, "1H-L" + str.tostring(len_long),  xloc=xloc.bar_index, style=label.style_none, textcolor=col_long,  size=sz))

        if disp_4h
            v_s = f_safe_get(ma_4h_s, offset)
            v_m = f_safe_get(ma_4h_m, offset)
            v_l = f_safe_get(ma_4h_l, offset)
            if not na(v_s)
                array.push(g_labels, label.new(bi, v_s, "4H-S" + str.tostring(len_short), xloc=xloc.bar_index, style=label.style_none, textcolor=col_short, size=sz))
            if not na(v_m)
                array.push(g_labels, label.new(bi, v_m, "4H-M" + str.tostring(len_mid),   xloc=xloc.bar_index, style=label.style_none, textcolor=col_mid,   size=sz))
            if not na(v_l)
                array.push(g_labels, label.new(bi, v_l, "4H-L" + str.tostring(len_long),  xloc=xloc.bar_index, style=label.style_none, textcolor=col_long,  size=sz))

        if disp_d
            v_s = f_safe_get(ma_d_s, offset)
            v_m = f_safe_get(ma_d_m, offset)
            v_l = f_safe_get(ma_d_l, offset)
            if not na(v_s)
                array.push(g_labels, label.new(bi, v_s, "D-S" + str.tostring(len_short), xloc=xloc.bar_index, style=label.style_none, textcolor=col_short, size=sz))
            if not na(v_m)
                array.push(g_labels, label.new(bi, v_m, "D-M" + str.tostring(len_mid),   xloc=xloc.bar_index, style=label.style_none, textcolor=col_mid,   size=sz))
            if not na(v_l)
                array.push(g_labels, label.new(bi, v_l, "D-L" + str.tostring(len_long),  xloc=xloc.bar_index, style=label.style_none, textcolor=col_long,  size=sz))
````
