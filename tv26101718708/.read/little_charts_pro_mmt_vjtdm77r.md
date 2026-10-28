# Little Charts Pro [MMT]

- url: https://www.tradingview.com/script/vJtDm77R-Little-Charts-Pro-MMT/
- type: indicator
- pine_id: PUB;f5d9647bf2ad4e378d46b21b920f8c6f
- version: 1.0

## Description

[b]Little Charts Pro [MMT][/b] is a compact, multi‑timeframe overlay indicator for TradingView that lets you embed small “mini‑charts” directly on your main chart, each showing price action, moving averages, CBC flip signals, Fair Value Gaps (FVGs), and order‑block‑style zones. It is designed to give you a quick, multi‑timeframe snapshot of trend, structure, and order‑flow context without cluttering your workspace.

[b]What the indicator does[/b]

- [b]Multiple mini‑charts[/b]

Displays up to six mini‑charts on the right side of your main chart, each representing a different timeframe (configurable from 5m up to W1).
Each mini‑chart shows candles, background box, and a compact timeframe label, all dynamically sized and positioned based on your layout settings.

- [b]Moving averages & trend[/b]

Plots two custom MAs per mini‑chart (type and length configurable: EMA, SMA, WMA, HMA, DEMA, TEMA, SMMA) so you can instantly see trend direction and key dynamic levels on each higher timeframe.

- [b]CBC flip arrows[/b]

Shows CBC‑style flip arrows when price closes above a prior high (bullish flip) or below a prior low (bearish flip), only on the state change. Arrows help you spot aggressive breaks in higher‑timeframe structure and changes in momentum.

- [b]Fair Value Gaps (FVGs)[/b]

Automatically highlights bullish and bearish FVGs on each mini‑chart, with a user‑set maximum per chart to avoid visual overload. This helps you quickly identify where unfilled gaps in liquidity may attract price later.

- [b]Order blocks (OBs)[/b]

Detects simple order‑block‑style zones (e.g., bullish OB when today’s close is above open while previous bar closed below its open) and shades them on the relevant mini‑chart. Labels can be toggled on/off for cleaner or more explicit structure.

[b]Key customization features[/b]

- [b]Layout & sizing[/b]

You can adjust mini‑chart width in bars, horizontal offset, horizontal gap between charts, overall vertical height scale, and a small vertical buffer percentage so the mini‑charts fit neatly without covering your main price.

- [b]Multi‑timeframe selection[/b]

Each of the six mini‑charts can have its own timeframe and bar count (how many candles back to display), letting you mix intraday, daily, and weekly views in one indicator.

- [b]Style & colors[/b]

Fully customizable:

[list]
[*]Up / down candle colors.
[*]Background and border colors for the mini‑chart boxes.
[*]Text color for labels and MA/FVG/OB colors so the indicator can match your preferred chart theme.
[/list]

## Source Code

````pine
//@version=5
indicator("Little Charts Pro [MMT]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ========================================================================= //
// =============================== INPUTS ================================== //
// ========================================================================= //

// --- POSITIONING ---
grp_pos = "POSITIONING"
i_width   = input.int(50,   "Mini Chart Width (Bars)", group=grp_pos)
i_offset  = input.int(6,    "Horizontal Offset",       group=grp_pos)
i_gapX    = input.int(10,    "Horizontal Gap (Bars)",   group=grp_pos)
i_vScale  = input.float(35.0, "Overall Height Scale",    group=grp_pos, step=0.1)
i_vBuffer = input.float(0.02,"Vertical Buffer (%)",     group=grp_pos, step=0.01)

// --- TIMEFRAMES & CANDLES ---
grp_tf = "CUSTOM TIMEFRAMES & CANDLES"
tf1  = input.timeframe("5",   "Timeframe 1", inline="tf1", group=grp_tf)
len1 = input.int(20, "",      inline="tf1",  group=grp_tf)
tf2  = input.timeframe("15",  "Timeframe 2", inline="tf2", group=grp_tf)
len2 = input.int(20, "",      inline="tf2",  group=grp_tf)
tf3  = input.timeframe("60",  "Timeframe 3", inline="tf3", group=grp_tf)
len3 = input.int(20, "",      inline="tf3",  group=grp_tf)
tf4  = input.timeframe("240", "Timeframe 4", inline="tf4", group=grp_tf)
len4 = input.int(20, "",      inline="tf4",  group=grp_tf)
tf5  = input.timeframe("D",   "Timeframe 5", inline="tf5", group=grp_tf)
len5 = input.int(15, "",      inline="tf5",  group=grp_tf)
tf6  = input.timeframe("W",   "Timeframe 6", inline="tf6", group=grp_tf)
len6 = input.int(10, "",      inline="tf6",  group=grp_tf)

// --- STYLE ---
grp_style = "STYLE"
c_up     = input.color(color.new(color.white, 0), "Up Color",         group=grp_style)
c_down   = input.color(color.new(color.gray, 0),  "Down Color",       group=grp_style)
c_bg     = input.color(color.new(#1a1a1a, 80),    "Background Color", group=grp_style)
c_border = input.color(color.new(#1a1a1a, 50),    "Border Color",     group=grp_style)
c_text   = input.color(color.new(color.gray, 0),  "Text Color",       group=grp_style)

// --- MOVING AVERAGES ---
grp_ma = "MOVING AVERAGES"
show_ma1 = input.bool(true,    "MA 1",   inline="ma1", group=grp_ma)
ma1_type = input.string("EMA", "",       inline="ma1", group=grp_ma, options=["EMA","SMA","WMA","HMA","DEMA","TEMA","SMMA"])
ma1_len  = input.int(9,        "Length", inline="ma1", group=grp_ma, minval=1)
c_ma1    = input.color(color.new(#00e5ff, 0), "", inline="ma1", group=grp_ma)

show_ma2 = input.bool(true,    "MA 2",   inline="ma2", group=grp_ma)
ma2_type = input.string("EMA", "",       inline="ma2", group=grp_ma, options=["EMA","SMA","WMA","HMA","DEMA","TEMA","SMMA"])
ma2_len  = input.int(21,       "Length", inline="ma2", group=grp_ma, minval=1)
c_ma2    = input.color(color.new(#ff9800, 0), "", inline="ma2", group=grp_ma)

// --- CBC FLIP ---
grp_cbc = "CBC FLIP (MapleStax)"
show_cbc   = input.bool(true, "Show CBC Flip Arrows", group=grp_cbc, tooltip="Bullish Flip = close > prev high  |  Bearish Flip = close < prev low. Arrow only appears on state change.")
c_cbc_bull = input.color(color.new(#00e676, 0), "Bull Color", inline="cbc_col", group=grp_cbc)
c_cbc_bear = input.color(color.new(#ff1744, 0), "Bear Color", inline="cbc_col", group=grp_cbc)
cbc_size_str = input.string("tiny", "Arrow Size", group=grp_cbc, options=["tiny","small","normal"])

// --- FVG ---
grp_fvg = "FVG SETTINGS"
show_fvg   = input.bool(true, "Show FVGs", group=grp_fvg)
c_fvg_bull = input.color(color.new(color.green, 80), "Bullish FVG", group=grp_fvg)
c_fvg_bear = input.color(color.new(color.red,   80), "Bearish FVG", group=grp_fvg)
max_fvg    = input.int(3, "Max Per Chart", group=grp_fvg)

// --- ORDER BLOCKS ---
grp_ob = "ORDER BLOCK SETTINGS"
show_ob     = input.bool(true, "Show OBs",       group=grp_ob)
show_ob_lbl = input.bool(true, "Show OB Labels", group=grp_ob)
c_ob_bull   = input.color(color.new(color.gray,   80), "Bullish OB", group=grp_ob)
c_ob_bear   = input.color(color.new(color.maroon, 80), "Bearish OB", group=grp_ob)
c_ob_text   = input.color(color.new(color.black,   0), "OB Text",    group=grp_ob)
max_ob      = input.int(2, "Max Per Chart (each side)", group=grp_ob)


// ========================================================================= //
// ============================ DATA FETCHING ============================== //
// ========================================================================= //

type HTF_Data
    array<float> o
    array<float> h
    array<float> l
    array<float> c

f_get_htf_data(tf, length) =>
    var float[] o_arr = array.new_float(0)
    var float[] h_arr = array.new_float(0)
    var float[] l_arr = array.new_float(0)
    var float[] c_arr = array.new_float(0)
    [o, h, l, c] = request.security(syminfo.tickerid, tf, [open, high, low, close])
    if ta.change(time(tf)) != 0
        array.push(o_arr, o[1])
        array.push(h_arr, h[1])
        array.push(l_arr, l[1])
        array.push(c_arr, c[1])
        if array.size(o_arr) > length
            array.shift(o_arr)
            array.shift(h_arr)
            array.shift(l_arr)
            array.shift(c_arr)
    HTF_Data.new(o_arr, h_arr, l_arr, c_arr)

data1 = f_get_htf_data(tf1, len1)
data2 = f_get_htf_data(tf2, len2)
data3 = f_get_htf_data(tf3, len3)
data4 = f_get_htf_data(tf4, len4)
data5 = f_get_htf_data(tf5, len5)
data6 = f_get_htf_data(tf6, len6)


// ========================================================================= //
// ========================= MA HELPERS & DISPATCH ========================= //
// ========================================================================= //

f_ema_pass(float[] src, float k) =>
    int     n   = array.size(src)
    float[] out = array.new_float(n, na)
    if n > 0
        float prev = array.get(src, 0)
        array.set(out, 0, prev)
        for i = 1 to n - 1
            float v = array.get(src, i)
            float e = not na(v) and not na(prev) ? v * k + prev * (1.0 - k) : prev
            array.set(out, i, e)
            prev := e
    out

f_wma_pass(float[] src, int length) =>
    int     n   = array.size(src)
    float[] out = array.new_float(n, na)
    for i = length - 1 to n - 1
        float wsum = 0.0, ws = 0.0
        for j = 0 to length - 1
            float v = array.get(src, i - j)
            if not na(v)
                float w = length - j
                wsum += v * w
                ws   += w
        if ws > 0
            array.set(out, i, wsum / ws)
    out

f_calc_ma(float[] closes, string ma_type, int length) =>
    int     n   = array.size(closes)
    float[] out = array.new_float(n, na)
    if n > 0
        if ma_type == "SMA"
            for i = length - 1 to n - 1
                float s = 0.0
                for j = i - length + 1 to i
                    s += array.get(closes, j)
                array.set(out, i, s / length)
        else if ma_type == "EMA"
            out := f_ema_pass(closes, 2.0 / (length + 1))
        else if ma_type == "WMA"
            out := f_wma_pass(closes, length)
        else if ma_type == "SMMA"
            float val = na, float sm = 0.0, int cnt = 0
            for i = 0 to n - 1
                float v = array.get(closes, i)
                if na(val)
                    sm  += v
                    cnt += 1
                    if cnt >= length
                        val := sm / length
                        array.set(out, i, val)
                else
                    val := (val * (length - 1) + v) / length
                    array.set(out, i, val)
        else if ma_type == "DEMA"
            float k    = 2.0 / (length + 1)
            float[] e1 = f_ema_pass(closes, k)
            float[] e2 = f_ema_pass(e1, k)
            for i = 0 to n - 1
                float v1 = array.get(e1, i), float v2 = array.get(e2, i)
                if not na(v1) and not na(v2)
                    array.set(out, i, 2.0 * v1 - v2)
        else if ma_type == "TEMA"
            float k    = 2.0 / (length + 1)
            float[] e1 = f_ema_pass(closes, k)
            float[] e2 = f_ema_pass(e1, k)
            float[] e3 = f_ema_pass(e2, k)
            for i = 0 to n - 1
                float v1 = array.get(e1, i)
                float v2 = array.get(e2, i)
                float v3 = array.get(e3, i)
                if not na(v1) and not na(v2) and not na(v3)
                    array.set(out, i, 3.0 * v1 - 3.0 * v2 + v3)
        else if ma_type == "HMA"
            int half  = math.max(1, int(length / 2))
            int sq    = math.max(1, int(math.sqrt(length)))
            float[] wh = f_wma_pass(closes, half)
            float[] wf = f_wma_pass(closes, length)
            float[] df = array.new_float(n, na)
            for i = 0 to n - 1
                float vh = array.get(wh, i), float vf = array.get(wf, i)
                if not na(vh) and not na(vf)
                    array.set(df, i, 2.0 * vh - vf)
            out := f_wma_pass(df, sq)
    out


// ========================================================================= //
// =========================== CBC CALCULATION ============================= //
// ========================================================================= //

f_calc_cbc(HTF_Data data) =>
    int   n     = array.size(data.c)
    int[] out   = array.new_int(n, 0)
    int   state = 0
    for i = 1 to n - 1
        float ck = array.get(data.c, i)
        float ph = array.get(data.h, i - 1)
        float pl = array.get(data.l, i - 1)
        if ck > ph
            array.set(out, i, state == 1 ? 2 : 1)
            state := 1
        else if ck < pl
            array.set(out, i, state == -1 ? -2 : -1)
            state := -1
        else
            array.set(out, i, state == 1 ? 2 : state == -1 ? -2 : 0)
    out


// ========================================================================= //
// =========================== DRAWING LOGIC =============================== //
// ========================================================================= //

var box[]   bg_boxes   = array.new_box()
var box[]   candle_b   = array.new_box()
var line[]  candle_w   = array.new_line()
var box[]   fvg_boxes  = array.new_box()
var box[]   ob_boxes   = array.new_box()
var label[] ob_labels  = array.new_label()
var line[]  ma1_lines  = array.new_line()
var line[]  ma2_lines  = array.new_line()
var label[] cbc_labels = array.new_label()

f_cleanup() =>
    for b in bg_boxes
        box.delete(b)
    for b in candle_b
        box.delete(b)
    for l in candle_w
        line.delete(l)
    for b in fvg_boxes
        box.delete(b)
    for b in ob_boxes
        box.delete(b)
    for l in ob_labels
        label.delete(l)
    for l in ma1_lines
        line.delete(l)
    for l in ma2_lines
        line.delete(l)
    for l in cbc_labels
        label.delete(l)
    array.clear(bg_boxes),  array.clear(candle_b),  array.clear(candle_w)
    array.clear(fvg_boxes), array.clear(ob_boxes),  array.clear(ob_labels)
    array.clear(ma1_lines), array.clear(ma2_lines), array.clear(cbc_labels)

f_format_tf(string tf) =>
    num = str.tonumber(tf)
    if not na(num)
        num >= 60 ? str.tostring(int(num / 60)) + "h" : str.tostring(int(num)) + "m"
    else
        tf

f_draw_minichart(HTF_Data data, string tf_label, int candles, int level) =>
    if array.size(data.c) > 2
        float hv = ta.highest(high, 300)
        float lv = ta.lowest(low, 300)
        float cr = hv - lv == 0 ? syminfo.mintick * 100 : hv - lv
        float my = (hv + lv) / 2
        float er = cr * i_vScale

        int   col_idx = level % 2
        int   row_idx = int(level / 2)
        float row_gap = er * i_vBuffer
        float bh      = (er - row_gap * 2) / 3
        float start_y = my + er / 2
        float top_y   = start_y - row_idx * (bh + row_gap)
        float bot_y   = top_y - bh

        int start_x = bar_index + i_offset + col_idx * (i_width + i_gapX)
        int end_x   = start_x + i_width

        float itop = top_y - bh * 0.02
        float ibot = bot_y + bh * 0.02
        float ir   = itop - ibot

        float max_h = array.max(data.h)
        float min_l = array.min(data.l)
        float hr    = max_h - min_l == 0 ? syminfo.mintick : max_h - min_l

        // ← Timeframe label only, no candle count
        array.push(bg_boxes, box.new(start_x, top_y, end_x, bot_y,
             border_color=c_border, bgcolor=c_bg,
             text=f_format_tf(tf_label),
             text_color=c_text, text_halign=text.align_center,
             text_valign=text.align_bottom, text_size=size.small))

        float bs = float(i_width) / candles
        int   n  = array.size(data.c)

        float[] m1v = show_ma1 ? f_calc_ma(data.c, ma1_type, ma1_len) : array.new_float(0)
        float[] m2v = show_ma2 ? f_calc_ma(data.c, ma2_type, ma2_len) : array.new_float(0)
        int[]   cbv = show_cbc ? f_calc_cbc(data)                      : array.new_int(0)

        string sz = cbc_size_str == "small" ? size.small : cbc_size_str == "normal" ? size.normal : size.tiny

        int fbc = 0, int fcc = 0, int obc = 0

        for i = 0 to n - 1
            int   idx = n - 1 - i
            float _o  = array.get(data.o, idx)
            float _h  = array.get(data.h, idx)
            float _l  = array.get(data.l, idx)
            float _c  = array.get(data.c, idx)

            float so = ibot + ((_o - min_l) / hr) * ir
            float sh = ibot + ((_h - min_l) / hr) * ir
            float sl = ibot + ((_l - min_l) / hr) * ir
            float sc = ibot + ((_c - min_l) / hr) * ir

            int   xp  = end_x - int(i * bs)
            color col = _c >= _o ? c_up : c_down

            array.push(candle_w, line.new(xp, sh, xp, sl, color=col))
            array.push(candle_b, box.new(xp - 1, so, xp + 1, sc, border_color=col, bgcolor=col))

            if i < n - 1
                int nxp  = end_x - int((i + 1) * bs)
                int nidx = idx - 1
                if show_ma1
                    float v1 = array.get(m1v, idx)
                    float v2 = array.get(m1v, nidx)
                    if not na(v1) and not na(v2)
                        array.push(ma1_lines, line.new(xp, ibot + ((v1 - min_l) / hr) * ir,
                             nxp, ibot + ((v2 - min_l) / hr) * ir, color=c_ma1, width=1))
                if show_ma2
                    float v1 = array.get(m2v, idx)
                    float v2 = array.get(m2v, nidx)
                    if not na(v1) and not na(v2)
                        array.push(ma2_lines, line.new(xp, ibot + ((v1 - min_l) / hr) * ir,
                             nxp, ibot + ((v2 - min_l) / hr) * ir, color=c_ma2, width=1))

            if show_cbc and array.size(cbv) > 0
                int cv = array.get(cbv, idx)
                if cv == 1 or cv == -1
                    bool bull = cv == 1
                    array.push(cbc_labels, label.new(
                         xp,
                         bull ? sl - ir * 0.015 : sh + ir * 0.015,
                         bull ? "▲" : "▼",
                         color     = color.new(color.white, 100),
                         textcolor = bull ? c_cbc_bull : c_cbc_bear,
                         style     = bull ? label.style_label_up : label.style_label_down,
                         size      = sz))

            if show_fvg and idx >= 2
                float _l2 = array.get(data.l, idx - 2)
                float _h2 = array.get(data.h, idx - 2)
                if _l > _h2 and fbc < max_fvg
                    array.push(fvg_boxes, box.new(xp, ibot + ((_l  - min_l) / hr) * ir,
                         end_x,    ibot + ((_h2 - min_l) / hr) * ir, bgcolor=c_fvg_bull, border_color=na))
                    fbc += 1
                if _h < _l2 and fcc < max_fvg
                    array.push(fvg_boxes, box.new(xp, ibot + ((_l2 - min_l) / hr) * ir,
                         end_x,    ibot + ((_h  - min_l) / hr) * ir, bgcolor=c_fvg_bear, border_color=na))
                    fcc += 1

            if show_ob and idx >= 1
                float _c1 = array.get(data.c, idx - 1)
                float _o1 = array.get(data.o, idx - 1)
                float _l1 = array.get(data.l, idx - 1)
                if _c > _o and _c1 < _o1 and obc < max_ob
                    float ob_top = ibot + ((_o1 - min_l) / hr) * ir
                    float ob_bot = ibot + ((_l1 - min_l) / hr) * ir
                    array.push(ob_boxes, box.new(xp, ob_top, end_x, ob_bot, bgcolor=c_ob_bull, border_color=na))
                    if show_ob_lbl
                        array.push(ob_labels, label.new(end_x, ob_bot, "+OB",
                             color=color.new(color.white, 100), textcolor=c_ob_text,
                             style=label.style_none, size=size.tiny))
                    obc += 1

if barstate.islast
    f_cleanup()
    f_draw_minichart(data1, tf1, len1, 0)
    f_draw_minichart(data2, tf2, len2, 1)
    f_draw_minichart(data3, tf3, len3, 2)
    f_draw_minichart(data4, tf4, len4, 3)
    f_draw_minichart(data5, tf5, len5, 4)
    f_draw_minichart(data6, tf6, len6, 5)
````
